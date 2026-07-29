import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/core/errors/failures/remote_data_source_exceptions_to_failures_mapper.dart';
import 'package:social_app/core/errors/remote_data_source_exceptions/remote_data_source_exceptions.dart';
import 'package:social_app/features/post/domain/failures/post_failure_messages.dart';

/// Maps post-owned exceptions and backend error codes into [Failure]s.
Failure mapPostExceptionToFailure(Object error) {
  if (error is RemoteServerException) {
    switch (error.code) {
      case 'invalid_post_cursor':
        return const ValidationFailure(PostFailureMessages.invalidCursor);

      case 'invalid_post_title':
        return const ValidationFailure(PostFailureMessages.titleRequired);

      case 'invalid_post_content':
        return const ValidationFailure(PostFailureMessages.contentRequired);

      case 'invalid_post_image':
        return const ValidationFailure(PostFailureMessages.imageRequired);

      case 'invalid_post_topic':
        return const ValidationFailure(
          PostFailureMessages.topicSelectionRequired,
        );

      case 'post_not_found':
        return const NotFoundFailure(PostFailureMessages.notFound);
    }
  }

  return mapRemoteDataSourceExceptionToFailure(error);
}
