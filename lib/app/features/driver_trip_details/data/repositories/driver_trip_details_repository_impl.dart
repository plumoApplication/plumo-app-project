import 'package:dartz/dartz.dart';
import 'package:plumo/app/core/errors/exceptions.dart';
import 'package:plumo/app/core/errors/failures.dart';
import 'package:plumo/app/features/booking/domain/entities/booking_entity.dart';
import 'package:plumo/app/features/driver_create_trip/domain/entities/trip_entity.dart';
import 'package:plumo/app/features/driver_trip_details/data/datasources/driver_trip_details_remote_datasource.dart';
import 'package:plumo/app/features/driver_trip_details/domain/repositories/driver_trip_details_repository.dart';

class DriverTripDetailsRepositoryImpl implements DriverTripDetailsRepository {
  final DriverTripDetailsRemoteDataSource remoteDataSource;

  DriverTripDetailsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<BookingEntity>>> getTripPassengers(
    String tripId,
  ) async {
    try {
      final result = await remoteDataSource.getTripPassengers(tripId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateTrip(TripEntity trip) async {
    try {
      await remoteDataSource.updateTrip(
        trip,
      ); // Vamos criar esse metodo no datasource ja ja
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
