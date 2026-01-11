class SignupUsernameValidator {
  static String? validate(String username) {
    username = username.trim();

    if (username.isEmpty) {
      return 'Name cannot be empty';
    } else if (username.length < 3) {
      return 'Name must be at least 3 characters long';
    } else if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      return 'Name can only contain letters, numbers, and underscores';
    } else {
      return null; // valid username
    }
  }
}
