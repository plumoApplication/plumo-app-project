import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:plumo/app/core/constants/api_constants.dart';
import 'package:plumo/app/core/services/mercadopago/mercadopago_service.dart';

// ... (Imports de Auth) ...
import 'package:plumo/app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:plumo/app/features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'package:plumo/app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:plumo/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:plumo/app/features/auth/presentation/cubit/auth_cubit.dart';

// ... (Imports de Profile) ...
import 'package:plumo/app/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:plumo/app/features/profile/data/datasources/profile_remote_datasource_impl.dart';
import 'package:plumo/app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:plumo/app/features/profile/domain/repositories/profile_repository.dart';
import 'package:plumo/app/features/profile/presentation/cubit/profile_cubit.dart';

// ... (Imports de Trip Search) ...
import 'package:plumo/app/features/trip_search/data/repositories/trip_search_repository_impl.dart';
import 'package:plumo/app/features/trip_search/presentation/cubit/trip_search_cubit.dart';
import 'package:plumo/app/features/trip_search/data/datasources/trip_search_remote_datasource.dart';
import 'package:plumo/app/features/trip_search/data/datasources/trip_search_remote_datasource_impl.dart';
import 'package:plumo/app/features/trip_search/domain/repositories/trip_search_repository.dart';

// ... (Imports de Create Trip) ...
import 'package:plumo/app/features/driver_create_trip/data/datasources/create_trip_remote_datasource.dart';
import 'package:plumo/app/features/driver_create_trip/data/datasources/create_trip_remote_datasource_impl.dart';
import 'package:plumo/app/features/driver_create_trip/data/repositories/create_trip_repository_impl.dart';
import 'package:plumo/app/features/driver_create_trip/domain/repositories/create_trip_repository.dart';
import 'package:plumo/app/features/driver_create_trip/presentation/cubit/create_trip_cubit.dart';

// ... (Imports de Driver Trips) ...
import 'package:plumo/app/features/driver_trips/data/datasources/driver_trips_remote_datasource.dart';
import 'package:plumo/app/features/driver_trips/data/datasources/driver_trips_remote_datasource_impl.dart';
import 'package:plumo/app/features/driver_trips/data/repositories/driver_trips_repository_impl.dart';
import 'package:plumo/app/features/driver_trips/domain/repositories/driver_trips_repository.dart';
import 'package:plumo/app/features/driver_trips/presentation/cubit/driver_trips_cubit.dart';

// ... (Imports de Booking) ...
import 'package:plumo/app/features/booking/data/datasources/booking_remote_datasource.dart';
import 'package:plumo/app/features/booking/data/datasources/booking_remote_datasource_impl.dart';
import 'package:plumo/app/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:plumo/app/features/booking/domain/repositories/booking_repository.dart';
import 'package:plumo/app/features/booking/presentation/cubit/booking_cubit.dart';

// ... (Imports de My Trips - Data/Domain) ...
import 'package:plumo/app/features/my_trips/data/datasources/my_trips_remote_datasource.dart';
import 'package:plumo/app/features/my_trips/data/datasources/my_trips_remote_datasource_impl.dart';
import 'package:plumo/app/features/my_trips/data/repositories/my_trips_repository_impl.dart';
import 'package:plumo/app/features/my_trips/domain/repositories/my_trips_repository.dart';

// === IMPORT ADICIONADO (My Trips Cubit) ===
import 'package:plumo/app/features/my_trips/presentation/cubit/my_trips_cubit.dart';

// === IMPORTS ADICIONADOS (Feature PAYMENT) ===
import 'package:plumo/app/features/payment/data/datasources/payment_remote_datasource.dart';
import 'package:plumo/app/features/payment/data/datasources/payment_remote_datasource_impl.dart';
import 'package:plumo/app/features/payment/data/repositories/payment_repository_impl.dart';
import 'package:plumo/app/features/payment/domain/repositories/payment_repository.dart';
import 'package:plumo/app/features/payment/presentation/cubit/payment_cubit.dart';

// ... (Imports de Driver Earnings) ...
import 'package:plumo/app/features/driver_earnings/data/datasources/earnings_remote_datasource.dart';
import 'package:plumo/app/features/driver_earnings/data/datasources/earnings_remote_datasource_impl.dart';
import 'package:plumo/app/features/driver_earnings/data/repositories/earnings_repository_impl.dart';
import 'package:plumo/app/features/driver_earnings/domain/repositories/earnings_repository.dart';
import 'package:plumo/app/features/driver_earnings/presentation/cubit/driver_earnings_cubit.dart';

// ... (Imports Driver Trip Details) ...
import 'package:plumo/app/features/driver_trip_details/data/datasources/driver_trip_details_remote_datasource.dart';
import 'package:plumo/app/features/driver_trip_details/data/datasources/driver_trip_details_remote_datasource_impl.dart';
import 'package:plumo/app/features/driver_trip_details/data/repositories/driver_trip_details_repository_impl.dart';
import 'package:plumo/app/features/driver_trip_details/domain/repositories/driver_trip_details_repository.dart';
import 'package:plumo/app/features/driver_trip_details/presentation/cubit/driver_trip_details_cubit.dart';
// ==========================================

final sl = GetIt.instance;

void setupServiceLocator() {
  // --== CORE ==--
  sl.registerSingleton<SupabaseClient>(Supabase.instance.client);
  sl.registerSingleton<FlutterGooglePlacesSdk>(
    FlutterGooglePlacesSdk(ApiConstants.googleApiKey),
  );
  sl.registerLazySingleton<MercadoPagoService>(() => MercadoPagoService());

  // --== FEATURES ==--

  // ================== AUTH (Autenticação) ==================
  sl.registerLazySingleton(
    () => AuthCubit(authRepository: sl(), profileRepository: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // ================== PROFILE (Perfil) ==================
  sl.registerFactory(() => ProfileCubit(profileRepository: sl()));
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // ================== TRIP SEARCH (Busca de Viagem) ==================
  sl.registerLazySingleton(() => TripSearchCubit(tripSearchRepository: sl()));
  sl.registerLazySingleton<TripSearchRepository>(
    () => TripSearchRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<TripSearchRemoteDataSource>(
    () => TripSearchRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // ================== CREATE TRIP (Criar Viagem) ==================
  sl.registerFactory(() => CreateTripCubit(createTripRepository: sl()));
  sl.registerLazySingleton<CreateTripRepository>(
    () => CreateTripRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<CreateTripRemoteDataSource>(
    () => CreateTripRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // ================== DRIVER TRIPS (Minhas Viagens - Motorista) ==================
  sl.registerFactory(
    () =>
        DriverTripsCubit(driverTripsRepository: sl(), bookingRepository: sl()),
  );
  sl.registerLazySingleton<DriverTripsRepository>(
    () => DriverTripsRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<DriverTripsRemoteDataSource>(
    () => DriverTripsRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // ================== BOOKING (Reserva) ==================
  sl.registerFactory(
    () => BookingCubit(bookingRepository: sl(), authCubit: sl()),
  );
  sl.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<BookingRemoteDataSource>(
    () => BookingRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // ================== MY TRIPS (Reservas do Passageiro) ==================
  sl.registerFactory(() => MyTripsCubit(myTripsRepository: sl()));

  sl.registerLazySingleton<MyTripsRepository>(
    () => MyTripsRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<MyTripsRemoteDataSource>(
    () => MyTripsRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // ================== PAYMENT (Pagamento) ==================
  sl.registerFactory(
    () => PaymentCubit(paymentRepository: sl(), mercadoPagoService: sl()),
  );

  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<PaymentRemoteDataSource>(
    () => PaymentRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // ================== DRIVER EARNINGS (Ganhos) ==================
  sl.registerFactory(() => DriverEarningsCubit(earningsRepository: sl()));

  sl.registerLazySingleton<EarningsRepository>(
    () => EarningsRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<EarningsRemoteDataSource>(
    () => EarningsRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // ================== DRIVER TRIP DETAILS (Detalhes da Viagem) ==================
  sl.registerFactory(() => DriverTripDetailsCubit(repository: sl()));

  sl.registerLazySingleton<DriverTripDetailsRepository>(
    () => DriverTripDetailsRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<DriverTripDetailsRemoteDataSource>(
    () => DriverTripDetailsRemoteDataSourceImpl(supabaseClient: sl()),
  );
  // ========================
}
