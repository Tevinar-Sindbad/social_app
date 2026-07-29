import 'package:social_app/core/serialization/json_reader.dart';
import 'package:social_app/features/profile/domain/entities/profile.dart';

/// Data model used to serialize profile payloads returned by the backend.
class ProfileModel {
  /// Creates a [ProfileModel].
  const ProfileModel({
    required this.id,
    required this.name,
  });

  /// Creates a [ProfileModel] from a domain [Profile].
  factory ProfileModel.fromEntity(Profile profile) {
    return ProfileModel(
      id: profile.id,
      name: profile.name,
    );
  }

  /// Creates a [ProfileModel] from backend JSON.
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: JsonReader.readString(json, 'id'),
      name: JsonReader.readString(json, 'name'),
    );
  }

  /// Stable app user identifier.
  final String id;

  /// Public profile name.
  final String name;

  /// Converts this model to the domain [Profile].
  Profile toEntity() {
    return Profile(
      id: id,
      name: name,
    );
  }
}
