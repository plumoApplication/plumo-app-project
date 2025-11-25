import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final String? id;
  final String bookingId;
  final String reviewerId; // Quem avaliou
  final String revieweeId; // Quem recebeu a avaliação
  final int rating; // 1 a 5
  final String? comment;
  final DateTime? createdAt;

  const ReviewEntity({
    this.id,
    required this.bookingId,
    required this.reviewerId,
    required this.revieweeId,
    required this.rating,
    this.comment,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    bookingId,
    reviewerId,
    revieweeId,
    rating,
    comment,
    createdAt,
  ];
}
