import 'package:plumo/app/features/reviews/domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    super.id,
    required super.bookingId,
    required super.reviewerId,
    required super.revieweeId,
    required super.rating,
    super.comment,
    super.createdAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] as String,
      bookingId: map['booking_id'] as String,
      reviewerId: map['reviewer_id'] as String,
      revieweeId: map['reviewee_id'] as String,
      rating: map['rating'] as int,
      comment: map['comment'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'booking_id': bookingId,
      'reviewer_id': reviewerId,
      'reviewee_id': revieweeId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
