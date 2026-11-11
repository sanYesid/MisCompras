import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'data/repositories/purchase_repository_impl.dart';
import 'domain/repositories/purchase_repository.dart';
import 'presentation/providers/purchase_provider.dart';
import 'presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicialización de formatos de fecha en español
  await initializeDateFormatting('es', null);
  await initializeDateFormatting('es_ES', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Inyección del repositorio (Data -> Domain)
        Provider<PurchaseRepository>(
          create: (_) => PurchaseRepositoryImpl(),
        ),
        // Proveedor del estado de la aplicación (Presentation)
        ChangeNotifierProvider<PurchaseProvider>(
          create: (context) => PurchaseProvider(
            context.read<PurchaseRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'GastoDiario',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00796B), // Verde azulado elegante
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
            scrolledUnderElevation: 2,
          ),
          cardTheme: const CardThemeData(
            elevation: 0,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00796B),
            brightness: Brightness.dark,
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
            scrolledUnderElevation: 2,
          ),
          cardTheme: const CardThemeData(
            elevation: 0,
          ),
        ),
        themeMode: ThemeMode.system,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'ES'),
          Locale('es', ''),
          Locale('en', 'US'),
        ],
        locale: const Locale('es', 'ES'),
        home: const HomeScreen(),
      ),
    );
  }
}
