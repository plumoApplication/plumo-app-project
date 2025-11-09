import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:get_it/get_it.dart';
import 'package:plumo/app/core/constants/api_constants.dart';
import 'package:plumo/app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:plumo/app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:plumo/app/features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'package:plumo/app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:plumo/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:plumo/app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:plumo/app/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:plumo/app/features/profile/data/datasources/profile_remote_datasource_impl.dart';
import 'package:plumo/app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:plumo/app/features/profile/domain/repositories/profile_repository.dart';

// Cria uma instância global do GetIt
final sl = GetIt.instance;

/// Função de inicialização do Service Locator
void setupServiceLocator() {
  sl.registerSingleton<SupabaseClient>(Supabase.instance.client);

  sl.registerFactory(
    () => AuthCubit(authRepository: sl(), profileRepository: sl()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(supabaseClient: sl()),
  );

  sl.registerFactory(() => ProfileCubit(profileRepository: sl()));

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(supabaseClient: sl()),
  );

  sl.registerSingleton<FlutterGooglePlacesSdk>(
    FlutterGooglePlacesSdk(ApiConstants.googleApiKey),
  );
}
