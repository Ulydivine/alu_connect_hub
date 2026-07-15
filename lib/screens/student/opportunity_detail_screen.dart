import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/application_provider.dart';
import '../../providers/bookmark_provider.dart';
import '../../models/opportunity.dart';
import 'apply_screen.dart';

class OpportunityDetailScreen extends StatelessWidget {
  final Opportunity opportunity;

  const OpportunityDetailScreen({super.key, required this.opportunity});

  @override
  Widget build(BuildContext context) {
    var auth = context.watch<AuthProvider>();
    var bookmarkProvider = context.watch<BookmarkProvider>();
    var applicationProvider = context.watch<ApplicationProvider>();

    // check if this student already applied to this opportunity
    bool alreadyApplied = applicationProvider.myApplications
        .any((app) => app.opportunityId == opportunity.id);

    bool bookmarked = bookmarkProvider.isBookmarked(opportunity.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Opportunity Details"),
        actions: [
          IconButton(
            icon: Icon(bookmarked ? Icons.bookmark : Icons.bookmark_border),
            onPressed: () {
              bookmarkProvider.toggleBookmark(auth.myUser!.uid, opportunity.id);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  opportunity.title,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  opportunity.startupName,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(label: Text(opportunity.category)),
                    if (opportunity.isRemote) const Chip(label: Text("Remote")),
                    Chip(
                      label: Text(opportunity.isOpen ? "Open" : "Closed"),
                      backgroundColor: opportunity.isOpen
                          ? Colors.green.withValues(alpha: 0.15)
                          : Colors.red.withValues(alpha: 0.15),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(opportunity.description),
                const SizedBox(height: 20),
                if (opportunity.skillsNeeded.isNotEmpty) ...[
                  const Text("Skills Needed", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: opportunity.skillsNeeded
                        .map((skill) => Chip(label: Text(skill)))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                ],
                Text(
                  "Posted on ${DateFormat.yMMMd().format(opportunity.createdAt)}",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 24),
                if (!opportunity.isOpen)
                  const Text(
                    "This opportunity is closed and is not taking new applicants.",
                    style: TextStyle(color: Colors.red),
                  )
                else if (alreadyApplied)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 10),
                        Text("You already applied to this opportunity"),
                      ],
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ApplyScreen(opportunity: opportunity),
                        ),
                      );
                    },
                    child: const Text("Apply Now"),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
