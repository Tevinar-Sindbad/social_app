// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CachedPostsTable extends CachedPosts
    with TableInfo<$CachedPostsTable, CachedPost> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedPostsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _posterIdMeta = const VerificationMeta(
    'posterId',
  );
  @override
  late final GeneratedColumn<String> posterId = GeneratedColumn<String>(
    'poster_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageRedirectUrlMeta = const VerificationMeta(
    'imageRedirectUrl',
  );
  @override
  late final GeneratedColumn<String> imageRedirectUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _topicsJsonMeta = const VerificationMeta(
    'topicsJson',
  );
  @override
  late final GeneratedColumn<String> topicsJson = GeneratedColumn<String>(
    'topics_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _posterNameMeta = const VerificationMeta(
    'posterName',
  );
  @override
  late final GeneratedColumn<String> posterName = GeneratedColumn<String>(
    'poster_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    posterId,
    title,
    content,
    imageRedirectUrl,
    topicsJson,
    createdAt,
    updatedAt,
    posterName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_posts';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedPost> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('poster_id')) {
      context.handle(
        _posterIdMeta,
        posterId.isAcceptableOrUnknown(data['poster_id']!, _posterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_posterIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageRedirectUrlMeta,
        imageRedirectUrl.isAcceptableOrUnknown(
          data['image_url']!,
          _imageRedirectUrlMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_imageRedirectUrlMeta);
    }
    if (data.containsKey('topics_json')) {
      context.handle(
        _topicsJsonMeta,
        topicsJson.isAcceptableOrUnknown(data['topics_json']!, _topicsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_topicsJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('poster_name')) {
      context.handle(
        _posterNameMeta,
        posterName.isAcceptableOrUnknown(data['poster_name']!, _posterNameMeta),
      );
    } else if (isInserting) {
      context.missing(_posterNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedPost map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedPost(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      posterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}poster_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      imageRedirectUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      )!,
      topicsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topics_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      posterName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}poster_name'],
      )!,
    );
  }

  @override
  $CachedPostsTable createAlias(String alias) {
    return $CachedPostsTable(attachedDatabase, alias);
  }
}

class CachedPost extends DataClass implements Insertable<CachedPost> {
  /// The unique identifier for the post.
  /// This is the primary key for the table.
  final String id;

  /// The identifier of the user who posted the post.
  final String posterId;

  /// The title of the post.
  final String title;

  /// The content of the post.
  final String content;

  /// The backend redirect URL of the image associated with the post.
  final String imageRedirectUrl;

  /// The JSON string representing the topics of the post.
  final String topicsJson;

  /// The date and time when the post was created.
  final DateTime createdAt;

  /// The date and time when the post was last updated.
  final DateTime updatedAt;

  /// The name of the user who posted the post.
  final String posterName;
  const CachedPost({
    required this.id,
    required this.posterId,
    required this.title,
    required this.content,
    required this.imageRedirectUrl,
    required this.topicsJson,
    required this.createdAt,
    required this.updatedAt,
    required this.posterName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['poster_id'] = Variable<String>(posterId);
    map['title'] = Variable<String>(title);
    map['content'] = Variable<String>(content);
    map['image_url'] = Variable<String>(imageRedirectUrl);
    map['topics_json'] = Variable<String>(topicsJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['poster_name'] = Variable<String>(posterName);
    return map;
  }

  CachedPostsCompanion toCompanion(bool nullToAbsent) {
    return CachedPostsCompanion(
      id: Value(id),
      posterId: Value(posterId),
      title: Value(title),
      content: Value(content),
      imageRedirectUrl: Value(imageRedirectUrl),
      topicsJson: Value(topicsJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      posterName: Value(posterName),
    );
  }

  factory CachedPost.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedPost(
      id: serializer.fromJson<String>(json['id']),
      posterId: serializer.fromJson<String>(json['posterId']),
      title: serializer.fromJson<String>(json['title']),
      content: serializer.fromJson<String>(json['content']),
      imageRedirectUrl: serializer.fromJson<String>(json['imageRedirectUrl']),
      topicsJson: serializer.fromJson<String>(json['topicsJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      posterName: serializer.fromJson<String>(json['posterName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'posterId': serializer.toJson<String>(posterId),
      'title': serializer.toJson<String>(title),
      'content': serializer.toJson<String>(content),
      'imageRedirectUrl': serializer.toJson<String>(imageRedirectUrl),
      'topicsJson': serializer.toJson<String>(topicsJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'posterName': serializer.toJson<String>(posterName),
    };
  }

  CachedPost copyWith({
    String? id,
    String? posterId,
    String? title,
    String? content,
    String? imageRedirectUrl,
    String? topicsJson,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? posterName,
  }) => CachedPost(
    id: id ?? this.id,
    posterId: posterId ?? this.posterId,
    title: title ?? this.title,
    content: content ?? this.content,
    imageRedirectUrl: imageRedirectUrl ?? this.imageRedirectUrl,
    topicsJson: topicsJson ?? this.topicsJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    posterName: posterName ?? this.posterName,
  );
  CachedPost copyWithCompanion(CachedPostsCompanion data) {
    return CachedPost(
      id: data.id.present ? data.id.value : this.id,
      posterId: data.posterId.present ? data.posterId.value : this.posterId,
      title: data.title.present ? data.title.value : this.title,
      content: data.content.present ? data.content.value : this.content,
      imageRedirectUrl: data.imageRedirectUrl.present
          ? data.imageRedirectUrl.value
          : this.imageRedirectUrl,
      topicsJson: data.topicsJson.present
          ? data.topicsJson.value
          : this.topicsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      posterName: data.posterName.present
          ? data.posterName.value
          : this.posterName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedPost(')
          ..write('id: $id, ')
          ..write('posterId: $posterId, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('imageRedirectUrl: $imageRedirectUrl, ')
          ..write('topicsJson: $topicsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('posterName: $posterName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    posterId,
    title,
    content,
    imageRedirectUrl,
    topicsJson,
    createdAt,
    updatedAt,
    posterName,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedPost &&
          other.id == this.id &&
          other.posterId == this.posterId &&
          other.title == this.title &&
          other.content == this.content &&
          other.imageRedirectUrl == this.imageRedirectUrl &&
          other.topicsJson == this.topicsJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.posterName == this.posterName);
}

class CachedPostsCompanion extends UpdateCompanion<CachedPost> {
  final Value<String> id;
  final Value<String> posterId;
  final Value<String> title;
  final Value<String> content;
  final Value<String> imageRedirectUrl;
  final Value<String> topicsJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> posterName;
  final Value<int> rowid;
  const CachedPostsCompanion({
    this.id = const Value.absent(),
    this.posterId = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.imageRedirectUrl = const Value.absent(),
    this.topicsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.posterName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedPostsCompanion.insert({
    required String id,
    required String posterId,
    required String title,
    required String content,
    required String imageRedirectUrl,
    required String topicsJson,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String posterName,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       posterId = Value(posterId),
       title = Value(title),
       content = Value(content),
       imageRedirectUrl = Value(imageRedirectUrl),
       topicsJson = Value(topicsJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       posterName = Value(posterName);
  static Insertable<CachedPost> custom({
    Expression<String>? id,
    Expression<String>? posterId,
    Expression<String>? title,
    Expression<String>? content,
    Expression<String>? imageRedirectUrl,
    Expression<String>? topicsJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? posterName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (posterId != null) 'poster_id': posterId,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (imageRedirectUrl != null) 'image_url': imageRedirectUrl,
      if (topicsJson != null) 'topics_json': topicsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (posterName != null) 'poster_name': posterName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedPostsCompanion copyWith({
    Value<String>? id,
    Value<String>? posterId,
    Value<String>? title,
    Value<String>? content,
    Value<String>? imageRedirectUrl,
    Value<String>? topicsJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? posterName,
    Value<int>? rowid,
  }) {
    return CachedPostsCompanion(
      id: id ?? this.id,
      posterId: posterId ?? this.posterId,
      title: title ?? this.title,
      content: content ?? this.content,
      imageRedirectUrl: imageRedirectUrl ?? this.imageRedirectUrl,
      topicsJson: topicsJson ?? this.topicsJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      posterName: posterName ?? this.posterName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (posterId.present) {
      map['poster_id'] = Variable<String>(posterId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (imageRedirectUrl.present) {
      map['image_url'] = Variable<String>(imageRedirectUrl.value);
    }
    if (topicsJson.present) {
      map['topics_json'] = Variable<String>(topicsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (posterName.present) {
      map['poster_name'] = Variable<String>(posterName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedPostsCompanion(')
          ..write('id: $id, ')
          ..write('posterId: $posterId, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('imageRedirectUrl: $imageRedirectUrl, ')
          ..write('topicsJson: $topicsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('posterName: $posterName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CurrentProfilesTable extends CurrentProfiles
    with TableInfo<$CurrentProfilesTable, CurrentProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CurrentProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _singletonKeyMeta = const VerificationMeta(
    'singletonKey',
  );
  @override
  late final GeneratedColumn<int> singletonKey = GeneratedColumn<int>(
    'singleton_key',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [singletonKey, id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'current_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<CurrentProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('singleton_key')) {
      context.handle(
        _singletonKeyMeta,
        singletonKey.isAcceptableOrUnknown(
          data['singleton_key']!,
          _singletonKeyMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {singletonKey};
  @override
  CurrentProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CurrentProfile(
      singletonKey: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}singleton_key'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $CurrentProfilesTable createAlias(String alias) {
    return $CurrentProfilesTable(attachedDatabase, alias);
  }
}

class CurrentProfile extends DataClass implements Insertable<CurrentProfile> {
  /// Singleton row identifier used to keep at most one cached profile row.
  final int singletonKey;

  /// Stable app user identifier.
  final String id;

  /// Public profile name.
  final String name;
  const CurrentProfile({
    required this.singletonKey,
    required this.id,
    required this.name,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['singleton_key'] = Variable<int>(singletonKey);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  CurrentProfilesCompanion toCompanion(bool nullToAbsent) {
    return CurrentProfilesCompanion(
      singletonKey: Value(singletonKey),
      id: Value(id),
      name: Value(name),
    );
  }

  factory CurrentProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CurrentProfile(
      singletonKey: serializer.fromJson<int>(json['singletonKey']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'singletonKey': serializer.toJson<int>(singletonKey),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  CurrentProfile copyWith({int? singletonKey, String? id, String? name}) =>
      CurrentProfile(
        singletonKey: singletonKey ?? this.singletonKey,
        id: id ?? this.id,
        name: name ?? this.name,
      );
  CurrentProfile copyWithCompanion(CurrentProfilesCompanion data) {
    return CurrentProfile(
      singletonKey: data.singletonKey.present
          ? data.singletonKey.value
          : this.singletonKey,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CurrentProfile(')
          ..write('singletonKey: $singletonKey, ')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(singletonKey, id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CurrentProfile &&
          other.singletonKey == this.singletonKey &&
          other.id == this.id &&
          other.name == this.name);
}

class CurrentProfilesCompanion extends UpdateCompanion<CurrentProfile> {
  final Value<int> singletonKey;
  final Value<String> id;
  final Value<String> name;
  const CurrentProfilesCompanion({
    this.singletonKey = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  CurrentProfilesCompanion.insert({
    this.singletonKey = const Value.absent(),
    required String id,
    required String name,
  }) : id = Value(id),
       name = Value(name);
  static Insertable<CurrentProfile> custom({
    Expression<int>? singletonKey,
    Expression<String>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (singletonKey != null) 'singleton_key': singletonKey,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  CurrentProfilesCompanion copyWith({
    Value<int>? singletonKey,
    Value<String>? id,
    Value<String>? name,
  }) {
    return CurrentProfilesCompanion(
      singletonKey: singletonKey ?? this.singletonKey,
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (singletonKey.present) {
      map['singleton_key'] = Variable<int>(singletonKey.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CurrentProfilesCompanion(')
          ..write('singletonKey: $singletonKey, ')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedPostsTable cachedPosts = $CachedPostsTable(this);
  late final $CurrentProfilesTable currentProfiles = $CurrentProfilesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cachedPosts,
    currentProfiles,
  ];
}

typedef $$CachedPostsTableCreateCompanionBuilder =
    CachedPostsCompanion Function({
      required String id,
      required String posterId,
      required String title,
      required String content,
      required String imageRedirectUrl,
      required String topicsJson,
      required DateTime createdAt,
      required DateTime updatedAt,
      required String posterName,
      Value<int> rowid,
    });
typedef $$CachedPostsTableUpdateCompanionBuilder =
    CachedPostsCompanion Function({
      Value<String> id,
      Value<String> posterId,
      Value<String> title,
      Value<String> content,
      Value<String> imageRedirectUrl,
      Value<String> topicsJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> posterName,
      Value<int> rowid,
    });

class $$CachedPostsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedPostsTable> {
  $$CachedPostsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get posterId => $composableBuilder(
    column: $table.posterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageRedirectUrl => $composableBuilder(
    column: $table.imageRedirectUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topicsJson => $composableBuilder(
    column: $table.topicsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get posterName => $composableBuilder(
    column: $table.posterName,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedPostsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedPostsTable> {
  $$CachedPostsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get posterId => $composableBuilder(
    column: $table.posterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageRedirectUrl => $composableBuilder(
    column: $table.imageRedirectUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topicsJson => $composableBuilder(
    column: $table.topicsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get posterName => $composableBuilder(
    column: $table.posterName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedPostsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedPostsTable> {
  $$CachedPostsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get posterId =>
      $composableBuilder(column: $table.posterId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get imageRedirectUrl => $composableBuilder(
    column: $table.imageRedirectUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get topicsJson => $composableBuilder(
    column: $table.topicsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get posterName => $composableBuilder(
    column: $table.posterName,
    builder: (column) => column,
  );
}

class $$CachedPostsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedPostsTable,
          CachedPost,
          $$CachedPostsTableFilterComposer,
          $$CachedPostsTableOrderingComposer,
          $$CachedPostsTableAnnotationComposer,
          $$CachedPostsTableCreateCompanionBuilder,
          $$CachedPostsTableUpdateCompanionBuilder,
          (
            CachedPost,
            BaseReferences<_$AppDatabase, $CachedPostsTable, CachedPost>,
          ),
          CachedPost,
          PrefetchHooks Function()
        > {
  $$CachedPostsTableTableManager(_$AppDatabase db, $CachedPostsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedPostsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedPostsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedPostsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> posterId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> imageRedirectUrl = const Value.absent(),
                Value<String> topicsJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> posterName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedPostsCompanion(
                id: id,
                posterId: posterId,
                title: title,
                content: content,
                imageRedirectUrl: imageRedirectUrl,
                topicsJson: topicsJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                posterName: posterName,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String posterId,
                required String title,
                required String content,
                required String imageRedirectUrl,
                required String topicsJson,
                required DateTime createdAt,
                required DateTime updatedAt,
                required String posterName,
                Value<int> rowid = const Value.absent(),
              }) => CachedPostsCompanion.insert(
                id: id,
                posterId: posterId,
                title: title,
                content: content,
                imageRedirectUrl: imageRedirectUrl,
                topicsJson: topicsJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                posterName: posterName,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedPostsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedPostsTable,
      CachedPost,
      $$CachedPostsTableFilterComposer,
      $$CachedPostsTableOrderingComposer,
      $$CachedPostsTableAnnotationComposer,
      $$CachedPostsTableCreateCompanionBuilder,
      $$CachedPostsTableUpdateCompanionBuilder,
      (
        CachedPost,
        BaseReferences<_$AppDatabase, $CachedPostsTable, CachedPost>,
      ),
      CachedPost,
      PrefetchHooks Function()
    >;
typedef $$CurrentProfilesTableCreateCompanionBuilder =
    CurrentProfilesCompanion Function({
      Value<int> singletonKey,
      required String id,
      required String name,
    });
typedef $$CurrentProfilesTableUpdateCompanionBuilder =
    CurrentProfilesCompanion Function({
      Value<int> singletonKey,
      Value<String> id,
      Value<String> name,
    });

class $$CurrentProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $CurrentProfilesTable> {
  $$CurrentProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get singletonKey => $composableBuilder(
    column: $table.singletonKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CurrentProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $CurrentProfilesTable> {
  $$CurrentProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get singletonKey => $composableBuilder(
    column: $table.singletonKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CurrentProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CurrentProfilesTable> {
  $$CurrentProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get singletonKey => $composableBuilder(
    column: $table.singletonKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$CurrentProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CurrentProfilesTable,
          CurrentProfile,
          $$CurrentProfilesTableFilterComposer,
          $$CurrentProfilesTableOrderingComposer,
          $$CurrentProfilesTableAnnotationComposer,
          $$CurrentProfilesTableCreateCompanionBuilder,
          $$CurrentProfilesTableUpdateCompanionBuilder,
          (
            CurrentProfile,
            BaseReferences<
              _$AppDatabase,
              $CurrentProfilesTable,
              CurrentProfile
            >,
          ),
          CurrentProfile,
          PrefetchHooks Function()
        > {
  $$CurrentProfilesTableTableManager(
    _$AppDatabase db,
    $CurrentProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CurrentProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CurrentProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CurrentProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> singletonKey = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => CurrentProfilesCompanion(
                singletonKey: singletonKey,
                id: id,
                name: name,
              ),
          createCompanionCallback:
              ({
                Value<int> singletonKey = const Value.absent(),
                required String id,
                required String name,
              }) => CurrentProfilesCompanion.insert(
                singletonKey: singletonKey,
                id: id,
                name: name,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CurrentProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CurrentProfilesTable,
      CurrentProfile,
      $$CurrentProfilesTableFilterComposer,
      $$CurrentProfilesTableOrderingComposer,
      $$CurrentProfilesTableAnnotationComposer,
      $$CurrentProfilesTableCreateCompanionBuilder,
      $$CurrentProfilesTableUpdateCompanionBuilder,
      (
        CurrentProfile,
        BaseReferences<_$AppDatabase, $CurrentProfilesTable, CurrentProfile>,
      ),
      CurrentProfile,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedPostsTableTableManager get cachedPosts =>
      $$CachedPostsTableTableManager(_db, _db.cachedPosts);
  $$CurrentProfilesTableTableManager get currentProfiles =>
      $$CurrentProfilesTableTableManager(_db, _db.currentProfiles);
}
