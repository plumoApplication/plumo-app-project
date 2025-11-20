import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plumo/app/features/payment/domain/repositories/payment_repository.dart';
import 'package:plumo/app/features/payment/presentation/cubit/payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final PaymentRepository paymentRepository;

  PaymentCubit({required this.paymentRepository}) : super(PaymentInitial());

  /// Inicia um pagamento via PIX
  Future<void> payWithPix({
    required String bookingId,
    required String title,
    required double price,
  }) async {
    // Emite loading específico para este botão
    emit(PaymentLoading(bookingId: bookingId));

    final result = await paymentRepository.processPayment(
      bookingId: bookingId,
      description: title,
      amount: price,
      paymentMethodId: 'pix', // <-- Forçamos PIX por enquanto
    );

    result.fold(
      (failure) => emit(PaymentError(message: failure.message)),
      (paymentData) => emit(PaymentPixCreated(paymentData: paymentData)),
    );
  }

  void reset() {
    emit(PaymentInitial());
  }
}
