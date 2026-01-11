class EmailValidator {
  static String? validate(String email) {
    email = email.trim();

    bool emailValid = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);

    if (email.isEmpty) {
      return 'Email cannot be empty';
    } else if (!emailValid) {
      return 'Please enter a valid email';
    }

    return null; // valid email
  }
}
