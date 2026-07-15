import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/opportunity_provider.dart';
import '../../providers/startup_provider.dart';
import '../../models/opportunity.dart';
import '../../constants.dart';

class PostOpportunityScreen extends StatefulWidget {
  const PostOpportunityScreen({super.key});

  @override
  State<PostOpportunityScreen> createState() => _PostOpportunityScreenState();
}

class _PostOpportunityScreenState extends State<PostOpportunityScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final skillsController = TextEditingController();
  String selectedCategory = opportunityCategories.first;
  bool isRemote = false;
  bool posting = false;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    skillsController.dispose();
    super.dispose();
  }

  void handlePost() async {
    if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in the title and description")),
      );
      return;
    }

    setState(() {
      posting = true;
    });

    var auth = context.read<AuthProvider>();
    var startupProvider = context.read<StartupProvider>();
    var opportunityProvider = context.read<OpportunityProvider>();

    // turn "flutter, figma, canva" into ["flutter", "figma", "canva"]
    List<String> skillsList = skillsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    var newOpportunity = Opportunity(
      id: '', // Firestore will make an id for us when we add it
      startupId: auth.myUser!.uid,
      startupName: startupProvider.myStartup!.startupName,
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      category: selectedCategory,
      skillsNeeded: skillsList,
      isRemote: isRemote,
      isOpen: true,
      createdAt: DateTime.now(),
    );

    await opportunityProvider.postOpportunity(newOpportunity);

    setState(() {
      posting = false;
    });

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Post Opportunity")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Opportunity Title"),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(labelText: "Category"),
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
                  controller: skillsController,
                  decoration: const InputDecoration(
                    labelText: "Skills needed (comma separated)",
                    hintText: "e.g. Flutter, Figma, Canva",
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text("This is a remote opportunity"),
                  value: isRemote,
                  onChanged: (value) {
                    setState(() {
                      isRemote = value;
                    });
                  },
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: posting ? null : handlePost,
                  child: posting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("Post Opportunity"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
