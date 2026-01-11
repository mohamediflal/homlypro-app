class SignupPasswordValidator {
  static String? validate(String password) {
    password = password.trim();

    if (password.isEmpty) {
      return 'Password cannot be empty';
    } else if (password.length < 6) {
      return 'Password must be at least 6 characters long';
    } else if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter';
    } else if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number';
    } else {
      return null; // valid password
    }
  }
}
