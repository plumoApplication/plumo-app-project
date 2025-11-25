import 'package:dartz/dartz.dart';
import 'package:plumo/app/core/errors/failures.dart';
import 'package:plumo/app/features/reviews/domain/entities/review_entity.dart';

abstract class ReviewsRepository {
  /// Cria uma nova avaliação no banco de dados.
  Future<Either<Failure, void>> createReview(ReviewEntity review);

  Future<Either<Failure, bool>> hasUserReviewed(String bookingId);
}
