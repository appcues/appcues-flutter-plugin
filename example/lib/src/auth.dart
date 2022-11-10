import 'package:flutter/widgets.dart';

/// A mock authentication service
class ExampleAuth extends ChangeNotifier {
  bool _signedIn = false;
  String _username = "";

  bool get signedIn => _signedIn;
  String get username => _username;

  // In this example app, just using the convention that an empty string username
  // represents an anonymous user.  In a real app, there would be some structure
  // around how an anonymous user is idenfified and tracked.
  //
  // The Appcues SDK will generate an anonymous ID internally for this case
  // when anonymous() is called.
  bool get isAnonymous => _username == "";

  void signOut() {
    // Sign out.
    _signedIn = false;
    _username = "";
    notifyListeners();
  }

  void signIn(String username) {
    // Sign in. Allow any password.
    _signedIn = true;
    _username = username;
    notifyListeners();
  }

  @override
  bool operator ==(Object other) =>
      other is ExampleAuth && other._signedIn == _signedIn;

  @override
  int get hashCode => _signedIn.hashCode;
}

class ExampleAuthScope extends InheritedNotifier<ExampleAuth> {
  const ExampleAuthScope({
    required super.notifier,
    required super.child,
    super.key,
  });

  static ExampleAuth of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ExampleAuthScope>()!.notifier!;
}
