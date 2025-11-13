import 'package:dartz/dartz.dart';
import 'package:plumo/app/core/errors/failures.dart';
import 'package:plumo/app/features/driver_create_trip/domain/entities/trip_entity.dart';

// Este é o contrato do DOMÍNIO.
// Ele define as regras de negócio "limpas".

abstract class CreateTripRepository {
  /// Cria uma nova viagem (incluindo seus waypoints) no banco de dados.
  ///
  /// Recebe uma [TripEntity] completa (já com a lista de waypoints)
  /// que foi montada pela UI (Cubit).
  ///
  /// Retorna [void] em caso de sucesso (Right).
  /// Retorna uma [Failure] (ex: ServerFailure) em caso de erro (Left).
  Future<Either<Failure, void>> createTrip(TripEntity trip);
}
