RegExp emailRegExp() {
  return RegExp(r'^[\w-]+(\.[\w-]+)*(\+\w+)?@[\w-]+(\.[\w-]+)+$');
}

String? validateEmail(String email) {
  if (email.isEmpty) {
    return "Email is empty";
  } else {
    return emailRegExp().hasMatch(email) ? null : "Email is invalid";
  }
}

String? validatePasswordIncludeLength(String password) {
  if (password.isEmpty) {
    return "Password is empty";
  } else if (password.length < 6) {
    return "Password must not be shorter than 6 characters";
  } else {
    return null;
  }
}

String? validatePasswordExcludeLength(String value) {
  if (value.isEmpty) {
    return "Password is empty";
  } else {
    return null;
  }
}
