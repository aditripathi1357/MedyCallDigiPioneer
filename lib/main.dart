import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:medycall/firebase_options.dart';
import 'package:medycall/home/home_screen.dart';
import 'package:medycall/providers/user_provider.dart';
import 'package:provider/provider.dart';
//import 'package:medycall/splashscreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://caeavcnufqmiosagnwlz.supabase.co';
const supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNhZWF2Y251ZnFtaW9zYWdud2x6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUzNTAwMzksImV4cCI6MjA2MDkyNjAzOX0.fB0iQ5aCRiYYNPw7nS4PHkxEJNLc30eGxJ14CuyWiVs';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: const MedyCallApp(),
    ),
  );
}

class MedyCallApp extends StatelessWidget {
  const MedyCallApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      title: 'MedyCall',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00796B)),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: const HomeScreen(),
    );
  }
}
