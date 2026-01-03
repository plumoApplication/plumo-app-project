import 'package:dartz/dartz.dart';
import 'package:plumo/app/core/errors/exceptions.dart';
import 'package:plumo/app/core/errors/failures.dart';
import 'package:plumo/app/features/booking/data/datasources/booking_remote_datasource.dart';
import 'package:plumo/app/features/booking/data/models/booking_model.dart';
import 'package:plumo/app/features/booking/domain/entities/booking_entity.dart';
import 'package:plumo/app/features/booking/domain/repositories/booking_repository.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;

  BookingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> createBooking(BookingEntity booking) async {
    try {
      // CONVERSÃO MANUAL DE ENTITY -> MODEL
      // Necessário para garantir que os novos campos (originName, seats, etc) sejam passados
      final bookingModel = BookingModel(
        // ID é gerado pelo banco, pode ser nulo na criação
        id: booking.id,
        tripId: booking.tripId,
        passengerId: booking.passengerId,
        driverId: booking.driverId,
        status: booking.status,
        totalPrice: booking.totalPrice,

        originName: booking.originName,
        destinationName: booking.destinationName,
        seats: booking.seats,

        // Campos opcionais
        paymentId: booking.paymentId,
        createdAt: booking.createdAt,
        pickupLat: booking.pickupLat,
        pickupLng: booking.pickupLng,
        pickupAddress: booking.pickupAddress,

        message: booking.message,
        paymentMethod: booking.paymentMethod,
      );

      await remoteDataSource.createBooking(bookingModel);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BookingEntity>>>
  getDriverPendingBookings() async {
    try {
      final bookings = await remoteDataSource.getDriverPendingBookings();
      return Right(bookings);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateBookingStatus({
    required String bookingId,
    required String newStatus,
  }) async {
    try {
      await remoteDataSource.updateBookingStatus(
        bookingId: bookingId,
        newStatus: newStatus,
      );
      return const Right(null);
    } on ServerException catch (e) {
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
