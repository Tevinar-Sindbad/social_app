/// App-owned profile data returned by the backend profile feature.
class Profile {
  /// Creates a [Profile].
  const Profile({
    required this.id,
    required this.name,
  });

  /// Stable app user identifier.
  final String id;

  /// Public profile name.
  final String name;
}
