import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/startup_provider.dart';
import 'create_startup_profile_screen.dart';
import 'startup_home_screen.dart';

// this screen figures out what a logged in startup user should see:
// - no profile yet -> fill in the create profile form
// - profile made but not verified yet -> waiting screen
// - verified -> normal startup home screen
class StartupGate extends StatefulWidget {
  const StartupGate({super.key});

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  void loadProfile() async {
    var auth = context.read<AuthProvider>();
    var startupProvider = context.read<StartupProvider>();
    await startupProvider.loadMyStartup(auth.myUser!.uid);
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    var startupProvider = context.watch<StartupProvider>();

    if (startupProvider.myStartup == null) {
      return const CreateStartupProfileScreen();
    }

    if (!startupProvider.myStartup!.isVerified) {
      return const _PendingVerificationScreen();
    }

    return const StartupHomeScreen();
  }
}

// simple waiting screen while an admin has not approved the startup yet
class _PendingVerificationScreen extends StatelessWidget {
  const _PendingVerificationScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verification Pending"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().logOut(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.hourglass_top, size: 60, color: Colors.orange),
              const SizedBox(height: 16),
              const Text(
                "Your startup is waiting for admin approval",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Once an ALU Link admin confirms your startup is a "
                "recognized ALU venture, you'll be able to post opportunities.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
