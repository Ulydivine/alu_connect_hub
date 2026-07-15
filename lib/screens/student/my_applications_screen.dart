import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/application_provider.dart';

// this is the "My Applications" tab, shown inside StudentHomeScreen
// it lists every opportunity the student has applied to and its status
class MyApplicationsScreen extends StatelessWidget {
  const MyApplicationsScreen({super.key});

  Color statusColor(String status) {
    if (status == "accepted") return Colors.green;
    if (status == "rejected") return Colors.red;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    var applications = context.watch<ApplicationProvider>().myApplications;

    if (applications.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            "You haven't applied to anything yet.\nGo to Browse to find opportunities.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: applications.length,
      itemBuilder: (context, index) {
        var app = applications[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(app.opportunityTitle),
            subtitle: Text(
              "Applied on ${DateFormat.yMMMd().format(app.appliedAt)}",
            ),
            trailing: Chip(
              label: Text(app.status),
              backgroundColor: statusColor(app.status).withValues(alpha: 0.15),
              labelStyle: TextStyle(color: statusColor(app.status)),
            ),
          ),
        );
      },
    );
  }
}
