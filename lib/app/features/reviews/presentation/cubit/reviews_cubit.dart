import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plumo/app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:plumo/app/features/auth/presentation/cubit/auth_state.dart';
import 'package:plumo/app/features/booking/domain/entities/booking_entity.dart';
import 'package:plumo/app/features/reviews/domain/entities/review_entity.dart';
import 'package:plumo/app/features/reviews/domain/repositories/reviews_repository.dart';
import 'package:plumo/app/features/reviews/presentation/cubit/reviews_state.dart';

class ReviewsCubit extends Cubit<ReviewsState> {
  final ReviewsRepository reviewsRepository;
  final AuthCubit authCubit; // Precisamos saber quem está avaliando

  ReviewsCubit({required this.reviewsRepository, required this.authCubit})
    : super(ReviewsInitial());

  Future<void> submitReview({
    required BookingEntity booking,
    required int rating,
    String? comment,
  }) async {
    try {
      emit(ReviewsLoading());

      final authState = authCubit.state;
      if (authState is! Authenticated) {
        emit(const ReviewsError(message: "Usuário não autenticado."));
        return;
      }

      final myUserId = authState.profile.id;

      // Descobre quem é o "Alvo" da avaliação (Reviewee)
      // Se eu sou o passageiro, avalio o motorista.
      // Se eu sou o motorista, avalio o passageiro.
      String revieweeId;
      if (myUserId == booking.passengerId) {
        revieweeId = booking.driverId;
      } else {
        revieweeId = booking.passengerId;
      }

      final review = ReviewEntity(
        bookingId: booking.id!,
        reviewerId: myUserId,
        revieweeId: revieweeId,
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
      );

      final result = await reviewsRepository.createReview(review);

      result.fold(
        (failure) => emit(ReviewsError(message: failure.message)),
        (_) => emit(ReviewsSuccess()),
      );
    } catch (e) {
      emit(ReviewsError(message: "Erro inesperado: $e"));
    }
  }

  Future<void> checkReviewStatus(String bookingId) async {
    // Não emitimos Loading para não piscar a tela, apenas checamos
    final result = await reviewsRepository.hasUserReviewed(bookingId);

    result.fold(
      (failure) => emit(const ReviewStatusChecked(hasReviewed: false)),
      (hasReviewed) => emit(ReviewStatusChecked(hasReviewed: hasReviewed)),
    );
  }
}
