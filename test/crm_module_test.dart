import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finledger/features/crm/data/services/crm_service.dart';
import 'package:finledger/features/crm/presentation/pipeline_board_screen.dart';
import 'package:finledger/features/crm/presentation/opportunity_detail_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CRM Service & Business Logic Tests', () {
    test('Default board data matches Figure 4 (Page 13)', () async {
      final service = CrmService();
      final board = await service.getBoardData();

      // Check 4 KPI cards
      expect(board.kpis.openPipeline, 1264000.0);
      expect(board.kpis.weightedForecast, 481700.0);
      expect(board.kpis.wonThisQuarter, 342500.0);
      expect(board.kpis.winRatePct, 34.0);

      // Check 5 Stages
      expect(board.stages, ['New', 'Qualified', 'Proposal', 'Negotiation', 'Won']);

      // Check New stage deals
      final newDeals = board.stageOpportunities['New']!;
      expect(newDeals.any((d) => d.title == 'Clinic air quality upgrade'), true);
      expect(newDeals.any((d) => d.title == 'Office HEPA rollout'), true);
      expect(newDeals.any((d) => d.title == 'School classrooms phase 1'), true);

      // Check Proposal stage contains OPP-2026-0142
      final proposalDeals = board.stageOpportunities['Proposal']!;
      final hospitalWard = proposalDeals.firstWhere((d) => d.opportunityNo == 'OPP-2026-0142');
      expect(hospitalWard.title, 'Hospital ward units');
      expect(hospitalWard.customerName, 'Riyadh Medical Centre');
      expect(hospitalWard.expectedValue, 126000.0);
      expect(hospitalWard.probabilityPct, 50);
      expect(hospitalWard.ownerName, 'Raj');
    });

    test('Search and filter board data works accurately', () async {
      final service = CrmService();

      // Search query
      final searchResult = await service.getBoardData(search: 'ward units');
      final proposalDeals = searchResult.stageOpportunities['Proposal']!;
      expect(proposalDeals.length, 1);
      expect(proposalDeals.first.opportunityNo, 'OPP-2026-0142');

      // Owner filter
      final saraDeals = await service.getBoardData(owner: 'Sara');
      for (final opps in saraDeals.stageOpportunities.values) {
        for (final opp in opps) {
          expect(opp.ownerName, 'Sara');
        }
      }
    });

    test('Moving to WON requires an associated customer (Page 29 Rule)', () async {
      final service = CrmService();

      // Deal without customer
      expect(
        () async => await service.updateOpportunityStage(
          opportunityId: 101, // Clinic air quality upgrade has customerId: null
          newStage: 'Won',
        ),
        throwsA(isA<Exception>()),
      );

      // Moving to Won with linked customer succeeds and sets closed_at
      final wonDeal = await service.updateOpportunityStage(
        opportunityId: 101,
        newStage: 'Won',
        customerId: 999,
        customerName: 'Al Zahra Medical Group LLC',
      );

      expect(wonDeal.stage, 'Won');
      expect(wonDeal.customerId, 999);
      expect(wonDeal.closedAt, isNotNull);
      expect(wonDeal.probabilityPct, 100);
    });

    test('Moving to LOST requires a mandatory lost reason (Page 29 Rule)', () async {
      final service = CrmService();

      // Deal moved to Lost without reason fails
      expect(
        () async => await service.updateOpportunityStage(
          opportunityId: 102,
          newStage: 'Lost',
          lostReason: '',
        ),
        throwsA(isA<Exception>()),
      );

      // Moving to Lost with valid reason succeeds
      final lostDeal = await service.updateOpportunityStage(
        opportunityId: 102,
        newStage: 'Lost',
        lostReason: 'Competitor chosen: Lower pricing on filters',
      );

      expect(lostDeal.stage, 'Lost');
      expect(lostDeal.lostReason, 'Competitor chosen: Lower pricing on filters');
      expect(lostDeal.closedAt, isNotNull);
      expect(lostDeal.probabilityPct, 0);
    });

    test('Drop rollback simulation triggers failure', () async {
      final service = CrmService();

      expect(
        () async => await service.updateOpportunityStage(
          opportunityId: 103,
          newStage: 'Qualified',
          simulateFailure: true,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('Opportunity detail returns Figure 5 mock data and operations work', () async {
      final service = CrmService();
      final detail = await service.getOpportunityDetail(1);

      // Check Opportunity details
      expect(detail.opportunity.opportunityNo, 'OPP-2026-0142');
      expect(detail.opportunity.title, 'Hospital ward units');
      expect(detail.opportunity.expectedValue, 126000.0);
      expect(detail.opportunity.probabilityPct, 50);

      // Check Primary Contact
      expect(detail.contact, isNotNull);
      expect(detail.contact!.fullName, 'Dr. Khalid Al-Harbi');
      expect(detail.contact!.jobTitle, 'Head of Facilities');
      expect(detail.contact!.email, 'k.alharbi@rmc.sa');
      expect(detail.contact!.phone, '+966 11 000 0000');
      expect(detail.contact!.location, 'Riyadh, Saudi Arabia');
      expect(detail.contact!.initials, 'KA');

      // Check Linked Quotation
      expect(detail.quotations.length, 1);
      final quote = detail.quotations.first;
      expect(quote.quotationNo, 'QT-2026-0098');
      expect(quote.currencyCode, 'SAR');
      expect(quote.total, 129375.0);
      expect(quote.status, 'SENT');

      // Check Timeline Activities
      expect(detail.activities.length, 4);
      expect(detail.activities.any((a) => a.activityType == 'MEETING'), true);
      expect(detail.activities.any((a) => a.activityType == 'EMAIL'), true);
      expect(detail.activities.any((a) => a.activityType == 'CALL'), true);

      // Check Open Tasks
      expect(detail.openTasks.length, 3);
      expect(detail.openTasks[0].title, 'Send revised quote with AMC option');
      expect(detail.openTasks[0].dueDateLabel, 'Due 31-Oct');
      expect(detail.openTasks[1].title, 'Follow-up call with procurement');
      expect(detail.openTasks[1].dueDateLabel, 'Due 03-Nov');
      expect(detail.openTasks[2].title, 'Arrange demo unit delivery');
      expect(detail.openTasks[2].dueDateLabel, 'Due 05-Nov');

      // Check Quick logging activity
      final loggedCall = await service.logActivity(
        opportunityId: 1,
        activityType: 'CALL',
        subject: 'Call — follow up with procurement director',
        details: 'Confirmed PO signature by end of week.',
      );
      expect(loggedCall.subject, 'Call — follow up with procurement director');

      // Check Toggling Task
      await service.toggleTaskCompletion(opportunityId: 1, taskId: 1, isCompleted: true);
      final updatedDetail = await service.getOpportunityDetail(1);
      expect(updatedDetail.openTasks.firstWhere((t) => t.id == 1).isCompleted, true);

      // Check Converting to Customer
      final convertedOpp = await service.convertLeadToCustomer(
        opportunityId: 1,
        customerName: 'Riyadh Medical Centre PJSC',
        trn: '300012345600003',
      );
      expect(convertedOpp.customerName, 'Riyadh Medical Centre PJSC');
      expect(convertedOpp.customerId, isNotNull);
    });
  });

  group('CRM Widget Integration Tests', () {
    testWidgets('PipelineBoardScreen renders top bar, KPIs and Kanban columns (Figure 4)', (tester) async {
      final service = CrmService();

      await tester.binding.setSurfaceSize(const Size(1300, 900));

      await tester.pumpWidget(
        MaterialApp(
          home: PipelineBoardScreen(crmService: service),
        ),
      );
      await tester.pumpAndSettle();

      // Check Title & Breadcrumbs
      expect(find.text('Sales Pipeline'), findsOneWidget);
      expect(find.text('CRM'), findsOneWidget);
      expect(find.text('Pipeline'), findsOneWidget);

      // Check Top Filter bar
      expect(find.text('Search opportunity...'), findsOneWidget);
      expect(find.text('Owner: All'), findsOneWidget);
      expect(find.text('Close: This quarter'), findsOneWidget);
      expect(find.text('Board'), findsOneWidget);
      expect(find.text('List'), findsOneWidget);
      expect(find.text('Import Leads'), findsOneWidget);
      expect(find.text('+ New Opportunity'), findsOneWidget);

      // Check 4 KPI Cards
      expect(find.text('Open pipeline'), findsOneWidget);
      expect(find.text('Weighted forecast'), findsOneWidget);
      expect(find.text('Won this quarter'), findsOneWidget);
      expect(find.text('Win rate (90 days)'), findsOneWidget);
      expect(find.text('34%'), findsOneWidget);

      // Check 5 Kanban column headers
      expect(find.textContaining('New •'), findsOneWidget);
      expect(find.textContaining('Qualified •'), findsOneWidget);
      expect(find.textContaining('Proposal •'), findsOneWidget);
      expect(find.textContaining('Negotiation •'), findsOneWidget);
      expect(find.textContaining('Won •'), findsOneWidget);

      // Check Opportunity cards
      expect(find.text('Clinic air quality upgrade'), findsOneWidget);
      expect(find.text('Hospital ward units'), findsOneWidget);
      expect(find.text('Riyadh Medical Centre'), findsOneWidget);

      // Toggle to List View
      await tester.tap(find.text('List'));
      await tester.pumpAndSettle();
      expect(find.byType(ListView), findsWidgets);

      // Toggle back to Board View
      await tester.tap(find.text('Board'));
      await tester.pumpAndSettle();
      expect(find.text('Clinic air quality upgrade'), findsOneWidget);
    });

    testWidgets('OpportunityDetailScreen renders 3 columns, stage bar, and quick actions (Figure 5)', (tester) async {
      final service = CrmService();

      await tester.binding.setSurfaceSize(const Size(1300, 900));

      await tester.pumpWidget(
        MaterialApp(
          home: OpportunityDetailScreen(
            opportunityId: 1,
            crmService: service,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check Breadcrumbs & Deal Title
      expect(find.text('OPP-2026-0142'), findsWidgets);
      expect(find.text('Riyadh Medical Centre — Hospital ward units'), findsOneWidget);

      // Check Stage Progress Bar
      expect(find.text('New'), findsWidgets);
      expect(find.text('Qualified'), findsWidgets);
      expect(find.text('Proposal'), findsWidgets);
      expect(find.text('Negotiation'), findsWidgets);
      expect(find.text('Won'), findsWidgets);

      // Check Action Buttons
      expect(find.text('Mark Lost'), findsOneWidget);
      expect(find.text('+ Quotation'), findsOneWidget);
      expect(find.text('Convert to Customer'), findsOneWidget);

      // Left Column checks
      expect(find.text('Deal details'), findsOneWidget);
      expect(find.text('AED 126,000'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(find.text('Contact'), findsOneWidget);
      expect(find.text('Dr. Khalid Al-Harbi'), findsOneWidget);
      expect(find.text('k.alharbi@rmc.sa'), findsOneWidget);
      expect(find.text('+966 11 000 0000'), findsOneWidget);
      expect(find.text('Quotations'), findsOneWidget);
      expect(find.text('QT-2026-0098'), findsOneWidget);

      // Center Column checks
      expect(find.text('Activity'), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);
      expect(find.text('Emails'), findsOneWidget);
      expect(find.text('Files (3)'), findsOneWidget);
      expect(find.text('Call'), findsOneWidget);
      expect(find.text('Meeting'), findsOneWidget);
      expect(find.text('Task'), findsOneWidget);
      expect(find.text('Meeting — site survey of wards 3-5'), findsOneWidget);
      expect(find.text('Email — proposal sent'), findsOneWidget);

      // Right Column checks
      expect(find.text('Open tasks'), findsOneWidget);
      expect(find.text('Send revised quote with AMC option'), findsOneWidget);
      expect(find.text('Due 31-Oct'), findsOneWidget);
      expect(find.text('Due 03-Nov'), findsOneWidget);
      expect(find.text('Stage history'), findsOneWidget);
      expect(find.text('· 24-Oct'), findsOneWidget);
    });
  });
}
