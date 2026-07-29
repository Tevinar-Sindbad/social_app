/// Represents a post topic
enum PostTopic {
  /// Lifestyle topic
  lifestyle('Lifestyle'),

  /// Travel topic
  travel('Travel'),

  /// Wellness topic
  wellness('Wellness'),

  /// Culture topic
  culture('Culture')
  ;

  const PostTopic(this.value);

  /// The string value of the topic
  final String value;

  /// Creates a [PostTopic] from a string value.
  static PostTopic fromValue(String name) {
    return PostTopic.values.firstWhere(
      (topic) => topic.name == name,
      orElse: () => throw FormatException(
        'Unknown post topic: $name',
      ),
    );
  }
}
