import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/application_provider.dart';
import '../../models/opportunity.dart';

class ApplicantsScreen extends StatefulWidget {
  final Opportunity opportunity;

  const ApplicantsScreen({super.key, required this.opportunity});

  @override
  State<ApplicantsScreen> createState() => _ApplicantsScreenState();
}

class _ApplicantsScreenState extends State<ApplicantsScreen> {
  @override
  void initState() {
    super.initState();
    // start listening for anyone who applies to this opportunity
    context.read<ApplicationProvider>().listenToApplicants(widget.opportunity.id);
  }

  Color statusColor(String status) {
    if (status == "accepted") return Colors.green;
    if (status == "rejected") return Colors.red;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    var applications = context.watch<ApplicationProvider>().applicantsForOpportunity;

    return Scaffold(
      appBar: AppBar(title: Text(widget.opportunity.title)),
      body: applications.isEmpty
          ? const Center(child: Text("No applicants yet"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: applications.length,
              itemBuilder: (context, index) {
                var app = applications[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              app.studentName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Chip(
                              label: Text(app.status),
                              backgroundColor:
                                  statusColor(app.status).withValues(alpha: 0.15),
                              labelStyle: TextStyle(color: statusColor(app.status)),
                            ),
                          ],
                        ),
                        Text(app.studentEmail, style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text(app.coverNote),
                        if (app.status == "pending") ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    context
                                        .read<ApplicationProvider>()
                                        .updateApplicationStatus(app.id, "rejected");
                                  },
                                  child: const Text("Reject"),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    context
                                        .read<ApplicationProvider>()
                                        .updateApplicationStatus(app.id, "accepted");
                                  },
                                  child: const Text("Accept"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
