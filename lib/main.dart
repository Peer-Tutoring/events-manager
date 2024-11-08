import 'package:events_manager/enums/auth_status.dart';
import 'package:events_manager/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/firebase_options.dart';
import 'screens/login.dart';
import 'screens/signup.dart';
import 'screens/home.dart';
import 'screens/event_detail.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Events Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthWidget(),
      routes: {
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/eventDetail': (context) => const EventDetailScreen(),
      },
    );
  }
}

class AuthWidget extends ConsumerWidget {
  const AuthWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStatus = ref.watch(authProvider);

    return authStatus == AuthStatus.authenticated
        ? const HomeScreen()
        : const LoginScreen();
  }
}
