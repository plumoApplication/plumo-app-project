import 'package:get_it/get_it.dart';
import 'package:plumo/app/features/trip_search/data/repositories/trip_search_repository_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:plumo/app/core/constants/api_constants.dart';
import 'package:plumo/app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:plumo/app/features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'package:plumo/app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:plumo/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:plumo/app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:plumo/app/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:plumo/app/features/profile/data/datasources/profile_remote_datasource_impl.dart';
import 'package:plumo/app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:plumo/app/features/profile/domain/repositories/profile_repository.dart';
import 'package:plumo/app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:plumo/app/features/trip_search/presentation/cubit/trip_search_cubit.dart';
import 'package:plumo/app/features/trip_search/data/datasources/trip_search_remote_datasource.dart';
import 'package:plumo/app/features/trip_search/data/datasources/trip_search_remote_datasource_impl.dart';
import 'package:plumo/app/features/trip_search/domain/repositories/trip_search_repository.dart';
import 'package:plumo/app/features/driver_create_trip/data/datasources/create_trip_remote_datasource.dart';
import 'package:plumo/app/features/driver_create_trip/data/datasources/create_trip_remote_datasource_impl.dart';
import 'package:plumo/app/features/driver_create_trip/data/repositories/create_trip_repository_impl.dart';
import 'package:plumo/app/features/driver_create_trip/domain/repositories/create_trip_repository.dart';
import 'package:plumo/app/features/driver_create_trip/presentation/cubit/create_trip_cubit.dart';
import 'package:plumo/app/features/driver_trips/data/datasources/driver_trips_remote_datasource.dart';
import 'package:plumo/app/features/driver_trips/data/datasources/driver_trips_remote_datasource_impl.dart';
import 'package:plumo/app/features/driver_trips/data/repositories/driver_trips_repository_impl.dart';
import 'package:plumo/app/features/driver_trips/domain/repositories/driver_trips_repository.dart';
import 'package:plumo/app/features/driver_trips/presentation/cubit/driver_trips_cubit.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  // --== CORE ==--
  sl.registerSingleton<SupabaseClient>(Supabase.instance.client);
  sl.registerSingleton<FlutterGooglePlacesSdk>(
    FlutterGooglePlacesSdk(ApiConstants.googleApiKey),
  );

  // --== FEATURES ==--

  // ... (Registros de AUTH) ...
  sl.registerFactory(
    () => AuthCubit(authRepository: sl(), profileRepository: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // ... (Registros de PROFILE) ...
  sl.registerFactory(() => ProfileCubit(profileRepository: sl()));
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // ================== TRIP SEARCH (Busca de Viagem) ==================
  // Presentation (Cubit)
  sl.registerFactory(() => TripSearchCubit(tripSearchRepository: sl()));

  // --- BLOCO ADICIONADO ---
  // Repository (Gerente)
  sl.registerLazySingleton<TripSearchRepository>(
    () => TripSearchRepositoryImpl(remoteDataSource: sl()),
  );

  // DataSource (Trabalhador)
  sl.registerLazySingleton<TripSearchRemoteDataSource>(
    () => TripSearchRemoteDataSourceImpl(supabaseClient: sl()),
  );
  // --- FIM DO BLOCO ---

  // ... (Registros de CREATE TRIP) ...
  sl.registerFactory(() => CreateTripCubit(createTripRepository: sl()));
  sl.registerLazySingleton<CreateTripRepository>(
    () => CreateTripRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<CreateTripRemoteDataSource>(
    () => CreateTripRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // ... (Registros de DRIVER TRIPS) ...
  sl.registerFactory(() => DriverTripsCubit(driverTripsRepository: sl()));
  sl.registerLazySingleton<DriverTripsRepository>(
    () => DriverTripsRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<DriverTripsRemoteDataSource>(
    () => DriverTripsRemoteDataSourceImpl(supabaseClient: sl()),
  );
}
