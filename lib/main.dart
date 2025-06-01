import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:medycall/firebase_options.dart';
import 'package:medycall/home/home_screen.dart';
import 'package:medycall/providers/user_provider.dart';
import 'package:medycall/providers/theme_provider.dart';
import 'package:medycall/splashscreen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://caeavcnufqmiosagnwlz.supabase.co';
const supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNhZWF2Y251ZnFtaW9zYWdud2x6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUzNTAwMzksImV4cCI6MjA2MDkyNjAzOX0.fB0iQ5aCRiYYNPw7nS4PHkxEJNLc30eGxJ14CuyWiVs';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(
          create: (context) => ThemeProvider()..loadThemePreference(),
        ),
      ],
      child: const MedyCallApp(),
    ),
  );
}

class MedyCallApp extends StatelessWidget {
  const MedyCallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // Update system UI overlay style based on theme
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                themeProvider.isDarkMode ? Brightness.light : Brightness.dark,
            statusBarBrightness:
                themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
            systemNavigationBarColor:
                themeProvider.isDarkMode
                    ? const Color(0xFF121212)
                    : Colors.white,
            systemNavigationBarIconBrightness:
                themeProvider.isDarkMode ? Brightness.light : Brightness.dark,
          ),
        );

        return MaterialApp(
          title: 'MedyCall',
          debugShowCheckedModeBanner: false,
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          themeMode: themeProvider.themeMode,
          home: const SplashScreen(),
        );
      },
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00796B),
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.grey[50],

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF00796B),
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.grey.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Text Theme
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black54),
        bodySmall: TextStyle(color: Colors.black45),
        headlineLarge: TextStyle(color: Colors.black87),
        headlineMedium: TextStyle(color: Colors.black87),
        headlineSmall: TextStyle(color: Colors.black87),
        titleLarge: TextStyle(color: Colors.black87),
        titleMedium: TextStyle(color: Colors.black87),
        titleSmall: TextStyle(color: Colors.black87),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(color: Colors.black54),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF00796B)),
        ),
        labelStyle: const TextStyle(color: Colors.black54),
        hintStyle: const TextStyle(color: Colors.black38),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00796B),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(color: Colors.grey.shade300, thickness: 1),

      // List Tile Theme
      listTileTheme: const ListTileThemeData(
        textColor: Colors.black87,
        iconColor: Colors.black54,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00796B),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF121212),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1F1F1F),
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Card Theme
      cardTheme: const CardTheme(
        color: Color(0xFF1E1E1E),
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white70),
        bodySmall: TextStyle(color: Colors.white60),
        headlineLarge: TextStyle(color: Colors.white),
        headlineMedium: TextStyle(color: Colors.white),
        headlineSmall: TextStyle(color: Colors.white),
        titleLarge: TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Colors.white),
        titleSmall: TextStyle(color: Colors.white),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(color: Colors.white70),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF404040)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF404040)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF00796B)),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white38),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00796B),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: Color(0xFF404040),
        thickness: 1,
      ),

      // List Tile Theme
      listTileTheme: const ListTileThemeData(
        textColor: Colors.white,
        iconColor: Colors.white70,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1F1F1F),
        selectedItemColor: Color(0xFF00796B),
        unselectedItemColor: Colors.white54,
      ),

      // Dialog Theme
      dialogTheme: const DialogTheme(
        backgroundColor: Color(0xFF1E1E1E),
        titleTextStyle: TextStyle(color: Colors.white),
        contentTextStyle: TextStyle(color: Colors.white70),
      ),
    );
  }
}
