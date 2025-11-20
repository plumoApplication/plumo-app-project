import 'package:dartz/dartz.dart';
import 'package:plumo/app/core/errors/failures.dart';
import 'package:plumo/app/features/payment/data/models/payment_response_model.dart';

abstract class PaymentRepository {
  Future<Either<Failure, PaymentResponseModel>> processPayment({
    required String bookingId,
    required String description,
    required double amount,
    required String paymentMethodId,
  });
}
