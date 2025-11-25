import 'package:equatable/equatable.dart';

abstract class ReviewsState extends Equatable {
  const ReviewsState();
  @override
  List<Object> get props => [];
}

class ReviewsInitial extends ReviewsState {}

class ReviewsLoading extends ReviewsState {}

class ReviewsSuccess extends ReviewsState {}

class ReviewsError extends ReviewsState {
  final String message;
  const ReviewsError({required this.message});
  @override
  List<Object> get props => [message];
}

class ReviewStatusChecked extends ReviewsState {
  final bool hasReviewed;
  const ReviewStatusChecked({required this.hasReviewed});
  @override
  List<Object> get props => [hasReviewed];
}
