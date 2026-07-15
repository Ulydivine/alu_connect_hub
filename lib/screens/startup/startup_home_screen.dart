import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/opportunity_provider.dart';
import '../../providers/startup_provider.dart';
import '../../widgets/opportunity_card.dart';
import 'post_opportunity_screen.dart';
import 'applicants_screen.dart';

class StartupHomeScreen extends StatelessWidget {
  const StartupHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var auth = context.watch<AuthProvider>();
    var startupProvider = context.watch<StartupProvider>();
    var opportunityProvider = context.watch<OpportunityProvider>();

    var myOpportunities = opportunityProvider.myOpportunities(auth.myUser!.uid);

    return Scaffold(
      appBar: AppBar(
        title: Text(startupProvider.myStartup?.startupName ?? "My Startup"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => auth.logOut(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PostOpportunityScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Post Opportunity"),
      ),
      body: myOpportunities.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  "You haven't posted any opportunities yet.\nTap the button below to add your first one.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: myOpportunities.length,
              itemBuilder: (context, index) {
                var opportunity = myOpportunities[index];
                return OpportunityCard(
                  opportunity: opportunity,
                  trailing: Icon(
                    Icons.people_outline,
                    color: opportunity.isOpen ? Colors.green : Colors.grey,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ApplicantsScreen(opportunity: opportunity),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
