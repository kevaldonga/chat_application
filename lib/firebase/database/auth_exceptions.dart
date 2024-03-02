class ExceptionAuth {
  static List<String> handleExceptions(String e) {
    switch (e) {
      case "invalid-email":
        return ["invalid email !", "entered email is invalid !!"];
      case "email-already-in-use":
        return ["email exist !", "given email already exist !!"];
      case "operation-not-allowed":
        return ["not allowed !", "operation you're doing is not allowed !!"];
      case "requires-recent-login":
        return ["no login !", "you complete the operation login first !!"];
      case "weak-password":
        return ["weak password !", "entered passowrd is very weak, try stronger one."];
      case "user-disabled":
        return ["disabled", "this operation is disabled by the user"];
      case "user-not-found":
        return ["not found !", "this user is not found !"];
      case "wrong-password":
        return ["wrong password", "entered password is wrong !!"];
      default:
        return ["fatal error occured",e.toString()];
    }
  }
}