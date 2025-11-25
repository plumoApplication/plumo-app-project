import 'package:dartz/dartz.dart';
import 'package:plumo/app/core/errors/exceptions.dart';
import 'package:plumo/app/core/errors/failures.dart';
import 'package:plumo/app/features/reviews/data/datasources/reviews_remote_datasource.dart';
import 'package:plumo/app/features/reviews/data/models/review_model.dart';
import 'package:plumo/app/features/reviews/domain/entities/review_entity.dart';
import 'package:plumo/app/features/reviews/domain/repositories/reviews_repository.dart';

class ReviewsRepositoryImpl implements ReviewsRepository {
  final ReviewsRemoteDataSource remoteDataSource;

  ReviewsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> createReview(ReviewEntity review) async {
    try {
      // Converte Entidade (Domain) para Modelo (Data)
      final reviewModel = ReviewModel(
        id: review.id,
        bookingId: review.bookingId,
        reviewerId: review.reviewerId,
        revieweeId: review.revieweeId,
        rating: review.rating,
        comment: review.comment,
        createdAt: review.createdAt,
      );

      await remoteDataSource.createReview(reviewModel);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> hasUserReviewed(String bookingId) async {
    try {
      final result = await remoteDataSource.hasUserReviewed(bookingId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
