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

/// Sucesso: O pagamento Pix foi criado.
/// Carregamos o modelo com o QR Code e o Copia-e-Cola.
class PaymentPixCreated extends PaymentState {
  final PaymentResponseModel paymentData;

  const PaymentPixCreated({required this.paymentData});

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
