import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plumo/app/features/driver_trip_details/domain/repositories/driver_trip_details_repository.dart';
import 'package:plumo/app/features/driver_trip_details/presentation/cubit/driver_trip_details_state.dart';

class DriverTripDetailsCubit extends Cubit<DriverTripDetailsState> {
  final DriverTripDetailsRepository repository;

  DriverTripDetailsCubit({required this.repository})
    : super(DriverTripDetailsInitial());

  Future<void> fetchPassengers(String tripId) async {
    emit(DriverTripDetailsLoading());

    final result = await repository.getTripPassengers(tripId);

    result.fold(
      (failure) => emit(DriverTripDetailsError(message: failure.message)),
      (passengers) => emit(DriverTripDetailsLoaded(passengers: passengers)),
    );
  }
}
