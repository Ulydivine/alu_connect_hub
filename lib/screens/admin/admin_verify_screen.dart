import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/startup_provider.dart';

// this screen only shows up for the admin account (see isAdmin in AuthProvider)
// it lists every startup that signed up but has not been approved yet
class AdminVerifyScreen extends StatefulWidget {
  const AdminVerifyScreen({super.key});

  @override
  State<AdminVerifyScreen> createState() => _AdminVerifyScreenState();
}

class _AdminVerifyScreenState extends State<AdminVerifyScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StartupProvider>().listenToPendingStartups();
  }

  @override
  Widget build(BuildContext context) {
    var startupProvider = context.watch<StartupProvider>();
    var pending = startupProvider.pendingStartups;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Startup Verification"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().logOut(),
          ),
        ],
      ),
      body: pending.isEmpty
          ? const Center(
              child: Text(
                "No startups waiting for approval",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pending.length,
              itemBuilder: (context, index) {
                var startup = pending[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          startup.startupName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(startup.category, style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text(startup.description),
                        const SizedBox(height: 6),
                        Text(
                          "Contact: ${startup.contactEmail}",
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  startupProvider.rejectStartup(startup.startupId);
                                },
                                child: const Text("Reject"),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  startupProvider.approveStartup(startup.startupId);
                                },
                                child: const Text("Approve"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
