import 'package:events_manager/enums/auth_status.dart';
import 'package:events_manager/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthNotifier extends StateNotifier<AuthStatus> {
  final AuthService authService;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AuthNotifier(this.authService) : super(AuthStatus.unauthenticated) {
    _firebaseAuth.authStateChanges().listen((User? user) {
      state =
          user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    });
  }

  Future<void> signUp(String email, String password) async {
    state = AuthStatus.loading;
    await AuthService.signUp(email, password);
    state = AuthStatus.unauthenticated;
  }

  Future<void> signIn(String email, String password) async {
    state = AuthStatus.loading;
    final user = await AuthService.signIn(email, password);
    state =
        user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
  }

  Future<void> signOut() async {
    await AuthService.signOut();
    state = AuthStatus.unauthenticated;
  }
}
