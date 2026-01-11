class LoginPasswordValidator {
  static String? validate(String password) {
    password = password.trim();

    if (password.isEmpty) {
      return 'Password cannot be empty';
    } else if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null; // valid password
  }
}
