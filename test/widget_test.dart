// Basic tests for the ALU Link app.
// We can't test the full app here because it needs Firebase to be running,
// so instead we test small pieces that don't need Firebase: the Opportunity
// model and the OpportunityCard widget.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alu_link/models/opportunity.dart';
import 'package:alu_link/widgets/opportunity_card.dart';

void main() {
  // a sample opportunity we can reuse in the tests below
  final sampleOpportunity = Opportunity(
    id: '1',
    startupId: 'startup1',
    startupName: 'Kigali Devs',
    title: 'Flutter Intern',
    description: 'Help us build our mobile app',
    category: 'Software Development',
    skillsNeeded: ['Flutter', 'Firebase'],
    isRemote: true,
    isOpen: true,
    createdAt: DateTime(2026, 1, 1),
  );

  test('Opportunity toMap and fromMap keep the same data', () {
    var map = sampleOpportunity.toMap();
    // Firestore stores dates as Timestamp, so we mimic that here
    // to test fromMap the same way it works with real Firestore data
    map['createdAt'] = Timestamp.fromDate(sampleOpportunity.createdAt);
    var rebuilt = Opportunity.fromMap('1', map);

    expect(rebuilt.title, sampleOpportunity.title);
    expect(rebuilt.category, sampleOpportunity.category);
    expect(rebuilt.skillsNeeded, sampleOpportunity.skillsNeeded);
  });

  testWidgets('OpportunityCard shows the title and startup name',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OpportunityCard(
            opportunity: sampleOpportunity,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Flutter Intern'), findsOneWidget);
    expect(find.text('Kigali Devs'), findsOneWidget);
    expect(find.text('Remote'), findsOneWidget);
  });
}
