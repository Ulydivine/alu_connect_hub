import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/startup_provider.dart';
import '../../models/startup_profile.dart';
import '../../constants.dart';

class CreateStartupProfileScreen extends StatefulWidget {
  const CreateStartupProfileScreen({super.key});

  @override
  State<CreateStartupProfileScreen> createState() =>
      _CreateStartupProfileScreenState();
}

class _CreateStartupProfileScreenState
    extends State<CreateStartupProfileScreen> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final contactController = TextEditingController();
  String selectedCategory = opportunityCategories.first;
  bool saving = false;

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    contactController.dispose();
    super.dispose();
  }

  void handleSave() async {
    if (nameController.text.isEmpty || descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in the startup name and description")),
      );
      return;
    }

    setState(() {
      saving = true;
    });

    var auth = context.read<AuthProvider>();
    var startupProvider = context.read<StartupProvider>();

    var profile = StartupProfile(
      startupId: auth.myUser!.uid,
      ownerUid: auth.myUser!.uid,
      startupName: nameController.text.trim(),
      description: descriptionController.text.trim(),
      category: selectedCategory,
      contactEmail: contactController.text.trim().isEmpty
          ? auth.myUser!.email
          : contactController.text.trim(),
      isVerified: false,
      createdAt: DateTime.now(),
    );

    await startupProvider.createStartupProfile(profile);

    setState(() {
      saving = false;
    });
    // no need to navigate, StartupGate watches this and switches automatically
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Set Up Your Startup"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().logOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Tell students about your startup",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  "An admin will check this is a real ALU-recognized "
                  "startup before you can post opportunities.",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Startup Name"),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: "What does your startup do?",
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(labelText: "Main Category"),
                  items: opportunityCategories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value.toString();
                    });
                  },
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: contactController,
                  decoration: const InputDecoration(
                    labelText: "Contact Email (optional)",
                  ),
                ),
                const SizedBox(height: 22),
                ElevatedButton(
                  onPressed: saving ? null : handleSave,
                  child: saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("Save and Continue"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
