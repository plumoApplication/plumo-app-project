import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plumo/app/features/driver_create_trip/domain/entities/trip_entity.dart';
import 'package:plumo/app/features/driver_create_trip/domain/entities/trip_waypoint_entity.dart';
import 'package:plumo/app/features/driver_create_trip/domain/repositories/create_trip_repository.dart';
import 'package:plumo/app/features/driver_create_trip/presentation/cubit/create_trip_state.dart';
import 'package:plumo/app/features/profile/domain/entities/profile_entity.dart';

class CreateTripCubit extends Cubit<CreateTripState> {
  final CreateTripRepository createTripRepository;

  CreateTripCubit({required this.createTripRepository})
    : super(CreateTripInitial());

  /// Método chamado pela UI quando o usuário clica em "Salvar Viagem"
  Future<void> submitCreateTrip({
    required ProfileEntity driverProfile, // O perfil do motorista logado
    required DateTime departureTime,
    required int availableSeats,
    required List<TripWaypointEntity> waypoints, // A lista de paradas
  }) async {
    try {
      // 1. Emite "Carregando"
      emit(CreateTripLoading());

      // 2. Validação de Negócio (ex: deve ter pelo menos 2 paradas)
      if (waypoints.length < 2) {
        emit(
          const CreateTripError(
            message:
                'Uma viagem deve ter pelo menos um ponto de partida e um destino.',
          ),
        );
        return;
      }

      // 3. Monta a Entidade 'TripEntity' (com os IDs nulos)
      //    que o repositório espera receber.
      final TripEntity newTrip = TripEntity(
        // driverId será pego pelo DataSource, mas podemos passar
        // (Na verdade, nosso DataSource pega o ID logado. Perfeito.)
        departureTime: departureTime,
        availableSeats: availableSeats,
        status: 'scheduled', // Valor padrão
        waypoints: waypoints, // A lista de paradas
        // (id, driverId, createdAt serão nulos, o que está correto)
      );

      // 4. Chama o repositório (o "gerente")
      final result = await createTripRepository.createTrip(newTrip);

      // 5. Processa o resultado
      result.fold(
        // 5a. Se deu 'Left' (Falha)
        (failure) => emit(CreateTripError(message: failure.message)),
        // 5b. Se deu 'Right' (Sucesso)
        (_) => emit(CreateTripSuccess()),
      );
    } catch (e) {
      // Captura qualquer erro inesperado
      emit(
        CreateTripError(message: 'Um erro inesperado ocorreu: ${e.toString()}'),
      );
    }
  }
}
