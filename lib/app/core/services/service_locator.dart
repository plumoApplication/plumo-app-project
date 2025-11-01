import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Imports do Data/Domain (como antes)
import 'package:plumo/app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:plumo/app/features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'package:plumo/app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:plumo/app/features/auth/domain/repositories/auth_repository.dart';

// === IMPORTS ADICIONADOS ===
import 'package:plumo/app/features/auth/presentation/cubit/auth_cubit.dart';
// =============================

// Cria uma instância global do GetIt
final sl = GetIt.instance;

/// Função de inicialização do Service Locator
/// Aqui registraremos todas as nossas dependências
void setupServiceLocator() {
  // --== CORE ==--
  sl.registerSingleton<SupabaseClient>(Supabase.instance.client);

  // --== FEATURES ==--

  // ================== AUTH (Autenticação) ==================

  // Presentation (Cubit)
  // NOTA: Usamos 'registerFactory' para Cubits/Blocs.
  // Isso significa que o GetIt criará uma *nova instância*
  // do AuthCubit toda vez que ele for solicitado.
  // Isso é crucial para evitar que estados persistam entre telas.
  sl.registerFactory(
    () => AuthCubit(
      // O GetIt "pede" (sl()) pelo 'AuthRepository'
      // e entrega o singleton que registramos abaixo.
      authRepository: sl(),
    ),
  );

  // Repository (Gerente)
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // DataSource (Trabalhador)
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(supabaseClient: sl()),
  );
}
