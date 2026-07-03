import '../../features/models/user.dart';

class Session {
  static User? currentUser;

  static void clear() {
    currentUser = null;
  }
}
