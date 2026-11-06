import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/services/token_service.dart';
import 'core/services/loading_service.dart';
import 'core/api/dio_client.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final tokenService = TokenService();
  await tokenService.init();

  // Pre-seed demo session if empty so user can immediately experience the Application Shell & modules
  if (!tokenService.isAuthenticated) {
    await tokenService.setDemoSession();
  }

  final loadingService = LoadingService();

  final dioClient = DioClient(
    tokenService: tokenService,
    loadingService: loadingService,
  );

  runApp(
    FinLedgerApp(
      tokenService: tokenService,
      loadingService: loadingService,
      dioClient: dioClient,
    ),
  );
}

class FinLedgerApp extends StatefulWidget {
  final TokenService tokenService;
  final LoadingService loadingService;
  final DioClient dioClient;

  const FinLedgerApp({
    super.key,
    required this.tokenService,
    required this.loadingService,
    required this.dioClient,
  });

  @override
  State<FinLedgerApp> createState() => _FinLedgerAppState();
}

class _FinLedgerAppState extends State<FinLedgerApp> {
  late final _router = createAppRouter(widget.tokenService);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TokenService>.value(value: widget.tokenService),
        ChangeNotifierProvider<LoadingService>.value(value: widget.loadingService),
        Provider<DioClient>.value(value: widget.dioClient),
      ],
      child: MaterialApp.router(
        title: 'FinLedger - Double-Entry Accounting',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
      ),
    );
  }
}
