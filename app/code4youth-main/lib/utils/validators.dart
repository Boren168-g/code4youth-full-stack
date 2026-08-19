/// Field validation.
///
/// Every message says what is wrong in plain language and, where it can, what
/// to do about it. "Invalid input" is never an acceptable message.
abstract final class Validators {
  static final RegExp _email = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$field cannot be empty.';
    return null;
  }

  static String? email(String? value) {
    final String v = value?.trim() ?? '';
    if (v.isEmpty) return 'Enter your email address.';
    if (!_email.hasMatch(v)) {
      return 'That does not look like an email address. Check for a missing @ '
          'or a typo.';
    }
    return null;
  }

  static String? guardianEmail(String? value, {String? ownEmail}) {
    final String? base = email(value);
    if (base != null) return base;
    if (ownEmail != null &&
        value!.trim().toLowerCase() == ownEmail.trim().toLowerCase()) {
      return 'This must be a parent or guardian\'s email, not your own.';
    }
    return null;
  }

  static String? password(String? value) {
    final String v = value ?? '';
    if (v.isEmpty) return 'Enter a password.';
    if (v.length < 8) {
      return 'Passwords need at least 8 characters. Yours has ${v.length}.';
    }
    if (!v.contains(RegExp(r'[0-9]'))) {
      return 'Add at least one number so your password is harder to guess.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Type your password again.';
    if (value != original) return 'The two passwords do not match.';
    return null;
  }

  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) return 'Enter your password.';
    return null;
  }

  static String? displayName(String? value) {
    final String v = value?.trim() ?? '';
    if (v.isEmpty) return 'Enter the name you want other learners to see.';
    if (v.length < 2) return 'Names need at least 2 characters.';
    return null;
  }

  static String? otp(String? value) {
    final String v = value?.trim() ?? '';
    if (v.isEmpty) return 'Enter the 6 digit code we emailed you.';
    if (v.length != 6 || int.tryParse(v) == null) {
      return 'The code is 6 digits. You entered ${v.length}.';
    }
    return null;
  }

  /// A challenge answer must not be empty — an empty field is never submitted.
  static String? answer(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Type your answer before checking it.';
    }
    return null;
  }
}
