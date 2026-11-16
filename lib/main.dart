import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'core/theme/app_theme.dart';
import 'core/services/token_service.dart';
import 'core/services/loading_service.dart';
import 'core/api/dio_client.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final tokenService = TokenService();
  await tokenService.init();

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
    return legacy_provider.MultiProvider(
      providers: [
        legacy_provider.ChangeNotifierProvider<TokenService>.value(value: widget.tokenService),
        legacy_provider.ChangeNotifierProvider<LoadingService>.value(value: widget.loadingService),
        legacy_provider.Provider<DioClient>.value(value: widget.dioClient),
      ],
      child: ProviderScope(
        overrides: [
          tokenServiceProvider.overrideWithValue(widget.tokenService),
          dioClientProvider.overrideWithValue(widget.dioClient),
        ],
        child: MaterialApp.router(
          title: 'FinLedger - Double-Entry Accounting',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: _router,
        ),
      ),
    );
  }
}
