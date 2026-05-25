import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'data/firebase_options.dart';
import 'package:pawter/ui/home/navhost.dart'; 
import 'package:pawter/ui/screens/acceso/cliente/cliente_viewmodel.dart';
import 'package:pawter/ui/screens/acceso/veterinario/vet_viewmodel.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('es_ES', null);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ClienteViewModel()),
        ChangeNotifierProvider(create: (_) => VeterinarioViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); 

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      title: 'Pawter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5A9F68)),
        useMaterial3: true,
      ),
    );
  }
}