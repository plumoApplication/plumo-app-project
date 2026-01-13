import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plumo/app/features/booking/domain/entities/booking_entity.dart';
import 'package:plumo/app/features/driver_create_trip/domain/entities/trip_entity.dart';
import 'package:plumo/app/features/driver_trip_details/domain/repositories/driver_trip_details_repository.dart';
import 'package:plumo/app/features/driver_trip_details/presentation/cubit/driver_trip_details_state.dart';

class DriverTripDetailsCubit extends Cubit<DriverTripDetailsState> {
  final DriverTripDetailsRepository repository;

  DriverTripDetailsCubit({required this.repository})
    : super(DriverTripDetailsInitial());

  Future<void> loadTripDetails(TripEntity trip) async {
    emit(DriverTripDetailsLoading());

    final result = await repository.getTripPassengers(trip.id!);

    result.fold(
      (failure) => emit(DriverTripDetailsError(message: failure.message)),
      (allBookings) {
        // 1. Filtra apenas passageiros relevantes (Aprovados ou Pagos)
        // Ignora: Recusados, Cancelados, Pendentes (se você quiser filtrar pendentes também)
        final confirmedPassengers = allBookings.where((b) {
          final s = b.status?.toLowerCase() ?? '';
          return s == 'approved' || s == 'paid' || s == 'confirmed';
        }).toList();

        // 2. Calcula o Lucro Estimado (Soma dos preços dos confirmados)
        double totalEarnings = 0.0;
        for (var booking in confirmedPassengers) {
          totalEarnings += booking.totalPrice;
        }

        // 3. Emite o estado com os dados processados
        emit(
          DriverTripDetailsLoaded(
            trip: trip,
            passengers: confirmedPassengers,
            estimatedProfit: totalEarnings,
          ),
        );
      },
    );
  }

  /// Verifica se pode editar Data/Hora (Nenhum passageiro aprovado na viagem inteira)
  bool canEditDateTime(List<BookingEntity> passengers) {
    return !passengers.any((p) => _isConfirmed(p));
  }

  /// Verifica se pode editar Taxa de Busca (Nenhum passageiro aprovado QUE USE busca específica)
  bool canEditPickupFee(List<BookingEntity> passengers) {
    return !passengers.any((p) => _isConfirmed(p) && p.isCustomPickup);
  }

  /// Verifica se pode editar o Preço Base ou de um Waypoint específico
  /// Regra: Não pode editar se houver passageiro confirmado passando por esse ponto ou trecho
  bool canEditPrice(List<BookingEntity> passengers, {String? waypointId}) {
    if (passengers.isEmpty) return true;

    // Se waypointId for null, estamos falando do preço base (Origem->Destino)
    if (waypointId == null) {
      // Bloqueia se tiver alguém indo da Origem até o Destino final
      // Simplificação: Bloqueia se tiver QUALQUER passageiro confirmado na viagem (mais seguro)
      return !passengers.any((p) => _isConfirmed(p));
    } else {
      // Verifica se algum passageiro confirmado embarca ou desembarca NESTE waypoint
      // Ou se a rota dele passa por este waypoint (lógica mais complexa, mas vamos simplificar pelo uso)
      return !passengers.any((p) {
        if (!_isConfirmed(p)) return false;
        return _isConfirmed(p);
      });
    }
  }

  bool _isConfirmed(BookingEntity b) {
    final s = b.status?.toLowerCase() ?? '';
    return s == 'approved' || s == 'paid' || s == 'confirmed';
  }

  // --- AÇÃO DE ATUALIZAR ---

  Future<void> updateTripData(TripEntity updatedTrip) async {
    // Verifica se estamos no estado carregado para preservar a lista de passageiros
    if (state is DriverTripDetailsLoaded) {
      final currentState = state as DriverTripDetailsLoaded;
      // Chamada ao repositório
      final result = await repository.updateTrip(updatedTrip);

      result.fold(
        (failure) => emit(
          DriverTripDetailsError(message: failure.message),
        ), // Ideal seria um SnackBarErrorState
        (_) {
          // [SUCESSO]: Emitimos o novo estado com a trip ATUALIZADA imediatamente.
          emit(
            DriverTripDetailsLoaded(
              trip:
                  updatedTrip, // <--- O PULO DO GATO: Atualiza a trip no estado
              passengers:
                  currentState.passengers, // Mantém os passageiros antigos
              estimatedProfit: currentState.estimatedProfit,
            ),
          );
          // Sucesso: Recarrega os dados para garantir sincronia (garantir 100% que o banco está igual)
          loadTripDetails(updatedTrip);
        },
      );
    }
  }
}
