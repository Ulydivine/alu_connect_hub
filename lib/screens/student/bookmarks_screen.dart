import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/opportunity_provider.dart';
import '../../providers/bookmark_provider.dart';
import '../../widgets/opportunity_card.dart';
import 'opportunity_detail_screen.dart';

// this is the "Bookmarks" tab, shown inside StudentHomeScreen
class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var bookmarkProvider = context.watch<BookmarkProvider>();
    var allOpportunities = context.watch<OpportunityProvider>().allOpportunities;

    // only keep the opportunities whose id is in the bookmarked list
    var savedOpportunities = allOpportunities
        .where((op) => bookmarkProvider.bookmarkedIds.contains(op.id))
        .toList();

    if (savedOpportunities.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            "No saved opportunities yet.\nTap the bookmark icon on any opportunity to save it here.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: savedOpportunities.length,
      itemBuilder: (context, index) {
        var opportunity = savedOpportunities[index];
        return OpportunityCard(
          opportunity: opportunity,
          trailing: const Icon(Icons.bookmark, color: Color(0xFF1F6F5C)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OpportunityDetailScreen(opportunity: opportunity),
              ),
            );
          },
        );
      },
    );
  }
}
