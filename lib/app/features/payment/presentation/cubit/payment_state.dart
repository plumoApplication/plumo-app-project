import 'package:equatable/equatable.dart';
import 'package:plumo/app/features/payment/data/models/payment_response_model.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {
  final String bookingId;
  const PaymentLoading({required this.bookingId});
  @override
  List<Object> get props => [bookingId];
}

/// Sucesso: O pagamento foi processado (seja Pix ou Cartão).
/// A UI decidirá o que mostrar baseada no 'paymentData.status' e 'paymentData.qrCode'.
class PaymentProcessed extends PaymentState {
  final PaymentResponseModel paymentData;

  const PaymentProcessed({required this.paymentData});

  @override
  List<Object> get props => [paymentData];
}

/// -------------------------

class PaymentError extends PaymentState {
  final String message;
  const PaymentError({required this.message});
  @override
  List<Object> get props => [message];
}
