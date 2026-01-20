import 'package:dartz/dartz.dart';
import 'package:plumo/app/core/errors/exceptions.dart';
import 'package:plumo/app/core/errors/failures.dart';
import 'package:plumo/app/features/payment/data/datasources/payment_remote_datasource.dart';
import 'package:plumo/app/features/payment/data/models/payment_response_model.dart';
import 'package:plumo/app/features/payment/domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;

  PaymentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PaymentResponseModel>> processPayment({
    required String bookingId,
    required String description,
    required double amount,
    required String paymentMethodId,
    String? token,
    int? installments,
    String? issuerId,
    String? docNumber,
  }) async {
    try {
      final result = await remoteDataSource.processPayment(
        bookingId: bookingId,
        description: description,
        amount: amount,
        paymentMethodId: paymentMethodId,
        token: token,
        installments: installments,
        issuerId: issuerId,
        docNumber: docNumber,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
