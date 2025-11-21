import 'package:dartz/dartz.dart';
import 'package:plumo/app/core/errors/exceptions.dart';
import 'package:plumo/app/core/errors/failures.dart';
import 'package:plumo/app/features/booking/data/datasources/booking_remote_datasource.dart';
import 'package:plumo/app/features/booking/data/models/booking_model.dart';
import 'package:plumo/app/features/booking/domain/entities/booking_entity.dart';
import 'package:plumo/app/features/booking/domain/repositories/booking_repository.dart';

// Esta é a IMPLEMENTAÇÃO do nosso Repositório (o "Gerente")

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;

  BookingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> createBooking(BookingEntity booking) async {
    try {
      // 1. Converte a Entidade 'limpa' em um Modelo de Dados
      //    (Precisamos fazer isso pois o DataSource espera um 'BookingModel')
      final bookingModel = BookingModel(
        id: booking.id,
        tripId: booking.tripId,
        passengerId: booking.passengerId,
        driverId: booking.driverId,
        status: booking.status,
        totalPrice: booking.totalPrice,
        originWaypointId: booking.originWaypointId,
        destinationWaypointId: booking.destinationWaypointId,
        paymentId: booking.paymentId,
        createdAt: booking.createdAt,
      );

      // 2. Chama o "trabalhador" (DataSource)
      await remoteDataSource.createBooking(bookingModel);

      // 3. Se deu certo, retorna Sucesso (Right)
      return const Right(null);
    } on ServerException catch (e) {
      // 4. Se o DataSource lançou uma exceção, traduz para Falha (Left)
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateBookingStatus({
    required String bookingId,
    required String newStatus,
  }) async {
    try {
      // 1. Chama o "trabalhador" (DataSource)
      await remoteDataSource.updateBookingStatus(
        bookingId: bookingId,
        newStatus: newStatus,
      );
      // 2. Se deu certo, retorna Sucesso (Right)
      return const Right(null);
    } on ServerException catch (e) {
      // 3. Se o DataSource lançou uma exceção, traduz para Falha (Left)
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<BookingEntity>>>
  getDriverPendingBookings() async {
    try {
      // 1. Chama o DataSource para buscar a lista de Modelos
      final bookingModels = await remoteDataSource.getDriverPendingBookings();

      // 2. Retorna Sucesso (Right)
      // (A lista de modelos é compatível com a lista de entidades)
      return Right(bookingModels);
    } on ServerException catch (e) {
      // 3. Trata o erro
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, String>> cancelBooking(String bookingId) async {
    try {
      final message = await remoteDataSource.cancelBooking(bookingId);
      return Right(message);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
