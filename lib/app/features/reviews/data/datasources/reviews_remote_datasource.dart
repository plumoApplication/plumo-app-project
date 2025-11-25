import 'package:plumo/app/features/reviews/data/models/review_model.dart';

abstract class ReviewsRemoteDataSource {
  /// Insere a avaliação na tabela 'reviews' do Supabase.
  Future<void> createReview(ReviewModel review);

  Future<bool> hasUserReviewed(String bookingId);
}
