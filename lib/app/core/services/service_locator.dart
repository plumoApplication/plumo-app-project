import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:plumo/app/core/constants/api_constants.dart';

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
import 'package:plumo/app/features/trip_search/presentation/cubit/trip_search_cubit.dart';

// ... (Imports de Create Trip) ...
import 'package:plumo/app/features/driver_create_trip/data/datasources/create_trip_remote_datasource.dart';
import 'package:plumo/app/features/driver_create_trip/data/datasources/create_trip_remote_datasource_impl.dart';
import 'package:plumo/app/features/driver_create_trip/data/repositories/create_trip_repository_impl.dart';
import 'package:plumo/app/features/driver_create_trip/domain/repositories/create_trip_repository.dart';
import 'package:plumo/app/features/driver_create_trip/presentation/cubit/create_trip_cubit.dart';

// ... (Imports de Driver Trips - Data/Domain) ...
import 'package:plumo/app/features/driver_trips/data/datasources/driver_trips_remote_datasource.dart';
import 'package:plumo/app/features/driver_trips/data/datasources/driver_trips_remote_datasource_impl.dart';
import 'package:plumo/app/features/driver_trips/data/repositories/driver_trips_repository_impl.dart';
import 'package:plumo/app/features/driver_trips/domain/repositories/driver_trips_repository.dart';

// === IMPORT ADICIONADO (Driver Trips Cubit) ===
import 'package:plumo/app/features/driver_trips/presentation/cubit/driver_trips_cubit.dart';
// ==============================================

final sl = GetIt.instance;

void setupServiceLocator() {
  // --== CORE ==--
  sl.registerSingleton<SupabaseClient>(Supabase.instance.client);
  sl.registerSingleton<FlutterGooglePlacesSdk>(
    FlutterGooglePlacesSdk(ApiConstants.googleApiKey),
  );

  // --== FEATURES ==--

  // ================== AUTH (Autenticação) ==================
  sl.registerFactory(
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
  sl.registerFactory(() => TripSearchCubit());

  // ================== CREATE TRIP (Criar Viagem) ==================
  sl.registerFactory(() => CreateTripCubit(createTripRepository: sl()));
  sl.registerLazySingleton<CreateTripRepository>(
    () => CreateTripRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<CreateTripRemoteDataSource>(
    () => CreateTripRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // ================== DRIVER TRIPS (Minhas Viagens) ==================
  // Presentation (Cubit)
  sl.registerFactory(() => DriverTripsCubit(driverTripsRepository: sl()));
  // ------------------------

  // Repository (Gerente)
  sl.registerLazySingleton<DriverTripsRepository>(
    () => DriverTripsRepositoryImpl(remoteDataSource: sl()),
  );

  // DataSource (Trabalhador)
  sl.registerLazySingleton<DriverTripsRemoteDataSource>(
    () => DriverTripsRemoteDataSourceImpl(supabaseClient: sl()),
  );
}
