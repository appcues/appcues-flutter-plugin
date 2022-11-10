/// Contains the properties of a supported route
class RouteDefinition {
  final String path;
  final String title;

  static const RouteDefinition signin = RouteDefinition._('/signin', 'Sign In');
  static const RouteDefinition events =
      RouteDefinition._('/events', 'Trigger Events');
  static const RouteDefinition profile =
      RouteDefinition._('/profile', 'Update Profile');
  static const RouteDefinition group =
      RouteDefinition._('/group', 'Update Group');

  const RouteDefinition._(this.path, this.title);
}
