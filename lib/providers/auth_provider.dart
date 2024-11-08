import 'package:events_manager/enums/auth_status.dart';
import 'package:events_manager/notifiers/auth_notifier.dart';
import 'package:events_manager/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthStatus>((ref) {
  return AuthNotifier(AuthService());
});
