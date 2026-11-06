import 'package:flutter_test/flutter_test.dart';
import 'package:finledger/main.dart';
import 'package:finledger/core/services/token_service.dart';
import 'package:finledger/core/services/loading_service.dart';
import 'package:finledger/core/api/dio_client.dart';

void main() {
  testWidgets('FinLedger smoke test', (WidgetTester tester) async {
    final tokenService = TokenService();
    final loadingService = LoadingService();
    final dioClient = DioClient(
      tokenService: tokenService,
      loadingService: loadingService,
    );

    await tester.pumpWidget(
      FinLedgerApp(
        tokenService: tokenService,
        loadingService: loadingService,
        dioClient: dioClient,
      ),
    );

    // Initial frame loads
    expect(find.byType(FinLedgerApp), findsOneWidget);
  });
}
