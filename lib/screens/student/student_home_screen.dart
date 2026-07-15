import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/opportunity_provider.dart';
import '../../providers/application_provider.dart';
import '../../providers/bookmark_provider.dart';
import '../../widgets/opportunity_card.dart';
import '../../constants.dart';
import 'opportunity_detail_screen.dart';
import 'my_applications_screen.dart';
import 'bookmarks_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  // which bottom tab is currently selected
  int selectedTab = 0;

  @override
  void initState() {
    super.initState();
    // start listening to this student's applications and bookmarks
    // as soon as the home screen opens, not only when they open the tab
    var auth = context.read<AuthProvider>();
    context.read<ApplicationProvider>().listenToMyApplications(auth.myUser!.uid);
    context.read<BookmarkProvider>().listenToBookmarks(auth.myUser!.uid);
  }

  @override
  Widget build(BuildContext context) {
    var auth = context.watch<AuthProvider>();

    // titles shown in the app bar for each tab
    List<String> titles = ["Browse Opportunities", "My Applications", "Saved"];

    List<Widget> tabBodies = [
      const _BrowseTab(),
      const MyApplicationsScreen(),
      const BookmarksScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[selectedTab]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => auth.logOut(),
          ),
        ],
      ),
      body: tabBodies[selectedTab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab,
        onDestinationSelected: (index) {
          setState(() {
            selectedTab = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.search), label: "Browse"),
          NavigationDestination(icon: Icon(Icons.assignment_outlined), label: "Applications"),
          NavigationDestination(icon: Icon(Icons.bookmark_outline), label: "Saved"),
        ],
      ),
    );
  }
}

// the "Browse" tab: search box, category filter chips, and the opportunity list
class _BrowseTab extends StatelessWidget {
  const _BrowseTab();

  @override
  Widget build(BuildContext context) {
    var opportunityProvider = context.watch<OpportunityProvider>();
    var bookmarkProvider = context.watch<BookmarkProvider>();
    var auth = context.read<AuthProvider>();

    List<String> categories = ["All", ...opportunityCategories];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            decoration: const InputDecoration(
              hintText: "Search opportunities...",
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              opportunityProvider.updateSearchText(value);
            },
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              String category = categories[index];
              bool selected = opportunityProvider.categoryFilter == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(category),
                  selected: selected,
                  onSelected: (_) {
                    opportunityProvider.updateCategoryFilter(category);
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: opportunityProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : opportunityProvider.filteredOpportunities.isEmpty
                  ? const Center(
                      child: Text(
                        "No opportunities match your search",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: opportunityProvider.filteredOpportunities.length,
                      itemBuilder: (context, index) {
                        var opportunity = opportunityProvider.filteredOpportunities[index];
                        bool bookmarked = bookmarkProvider.isBookmarked(opportunity.id);
                        return OpportunityCard(
                          opportunity: opportunity,
                          trailing: IconButton(
                            icon: Icon(
                              bookmarked ? Icons.bookmark : Icons.bookmark_border,
                              color: const Color(0xFF1F6F5C),
                            ),
                            onPressed: () {
                              bookmarkProvider.toggleBookmark(
                                auth.myUser!.uid,
                                opportunity.id,
                              );
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    OpportunityDetailScreen(opportunity: opportunity),
                              ),
                            );
                          },
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
