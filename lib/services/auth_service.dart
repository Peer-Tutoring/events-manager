import 'package:events_manager/models/app_user.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  static Future<AppUser?> signUp(String email, String password) async {
    try {
      final UserCredential credential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (credential.user != null) {
        return AppUser(
          id: credential.user!.uid,
          email: credential.user!.email!,
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
