import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/application_provider.dart';
import '../../models/opportunity.dart';
import '../../models/application.dart';

class ApplyScreen extends StatefulWidget {
  final Opportunity opportunity;

  const ApplyScreen({super.key, required this.opportunity});

  @override
  State<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends State<ApplyScreen> {
  final coverNoteController = TextEditingController();
  bool sending = false;

  @override
  void dispose() {
    coverNoteController.dispose();
    super.dispose();
  }

  void handleSubmit() async {
    if (coverNoteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please write a short note about why you're a good fit")),
      );
      return;
    }

    setState(() {
      sending = true;
    });

    var auth = context.read<AuthProvider>();
    var applicationProvider = context.read<ApplicationProvider>();

    var application = Application(
      id: '',
      opportunityId: widget.opportunity.id,
      opportunityTitle: widget.opportunity.title,
      startupId: widget.opportunity.startupId,
      studentUid: auth.myUser!.uid,
      studentName: auth.myUser!.name,
      studentEmail: auth.myUser!.email,
      coverNote: coverNoteController.text.trim(),
      status: "pending",
      appliedAt: DateTime.now(),
    );

    String? errorMessage = await applicationProvider.submitApplication(application);

    setState(() {
      sending = false;
    });

    if (!mounted) return;

    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Application sent!")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Apply to ${widget.opportunity.title}")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Why are you a good fit for this role?",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: coverNoteController,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: "Tell the startup about your skills and interest...",
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: sending ? null : handleSubmit,
                child: sending
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text("Submit Application"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
