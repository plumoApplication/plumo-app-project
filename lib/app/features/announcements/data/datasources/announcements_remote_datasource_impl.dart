import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:plumo/app/core/errors/exceptions.dart';
import 'package:plumo/app/features/announcements/data/datasources/announcements_remote_datasource.dart';
import 'package:plumo/app/features/announcements/data/models/announcement_model.dart';

class AnnouncementsRemoteDataSourceImpl
    implements AnnouncementsRemoteDataSource {
  final supabase.SupabaseClient supabaseClient;

  AnnouncementsRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<AnnouncementModel>> getAnnouncements(String role) async {
    try {
      // Consulta ao Supabase
      final response = await supabaseClient
          .from('announcements')
          .select()
          .eq('active', true) // Apenas avisos ativos
          // Filtro OR: target_role é 'all' OU target_role é igual ao meu role
          .or('target_role.eq.all,target_role.eq.$role')
          .order('created_at', ascending: false); // Mais recentes primeiro

      final List<dynamic> data = response as List<dynamic>;

      return data
          .map(
            (json) => AnnouncementModel.fromMap(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      // Em caso de erro, lançamos nossa exceção padrão
      throw ServerException(message: 'Erro ao buscar avisos: ${e.toString()}');
    }
  }
}
