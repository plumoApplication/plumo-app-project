import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plumo/app/features/booking/domain/repositories/booking_repository.dart';
import 'package:plumo/app/features/driver_trips/domain/repositories/driver_trips_repository.dart';
import 'package:plumo/app/features/driver_trips/presentation/cubit/driver_trips_state.dart';
import 'package:plumo/app/features/driver_create_trip/domain/entities/trip_entity.dart';
import 'package:plumo/app/features/booking/domain/entities/booking_entity.dart';

class DriverTripsCubit extends Cubit<DriverTripsState> {
  final DriverTripsRepository driverTripsRepository;
  final BookingRepository bookingRepository;

  DriverTripsCubit({
    required this.driverTripsRepository,
    required this.bookingRepository,
  }) : super(DriverTripsLoading());

  Future<void> fetchMyTrips() async {
    emit(DriverTripsLoading());

    final results = await Future.wait([
      driverTripsRepository.getMyTrips(),
      bookingRepository.getDriverPendingBookings(),
    ]);

    final tripsResult = results[0];
    final bookingsResult = results[1];

    tripsResult.fold(
      (failure) => emit(DriverTripsError(message: failure.message)),
      (trips) {
        bookingsResult.fold(
          (failure) => emit(DriverTripsError(message: failure.message)),
          (bookings) {
            // CAST SEGURO: Garantimos ao Dart que as listas são do tipo correto
            final tripsList = trips as List<TripEntity>;
            final bookingsList = bookings as List<BookingEntity>;

            emit(
              DriverTripsSuccess(
                trips: tripsList,
                pendingRequests: bookingsList,
              ),
            );
          },
        );
      },
    );
  }

  /// Aprova uma solicitação de reserva
  Future<void> approveRequest(String bookingId) async {
    // (Poderíamos emitir um estado de 'Loading' específico, mas
    //  para o MVP vamos apenas emitir o loading geral e recarregar)
    emit(DriverTripsLoading());

    final result = await bookingRepository.updateBookingStatus(
      bookingId: bookingId,
      newStatus: 'approved', // Status de Aprovado
    );

    result.fold((failure) => emit(DriverTripsError(message: failure.message)), (
      _,
    ) {
      // Se deu certo, recarrega tudo para a lista atualizar (sumir o card)
      fetchMyTrips();
    });
  }

  /// Recusa uma solicitação de reserva
  Future<void> denyRequest(String bookingId) async {
    emit(DriverTripsLoading());

    final result = await bookingRepository.updateBookingStatus(
      bookingId: bookingId,
      newStatus: 'denied', // Status de Recusado
    );

    result.fold((failure) => emit(DriverTripsError(message: failure.message)), (
      _,
    ) {
      fetchMyTrips();
    });
  }
}
