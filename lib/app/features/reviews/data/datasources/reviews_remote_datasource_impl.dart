import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:plumo/app/core/errors/exceptions.dart';
import 'package:plumo/app/features/reviews/data/datasources/reviews_remote_datasource.dart';
import 'package:plumo/app/features/reviews/data/models/review_model.dart';

class ReviewsRemoteDataSourceImpl implements ReviewsRemoteDataSource {
  final supabase.SupabaseClient supabaseClient;

  ReviewsRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<void> createReview(ReviewModel review) async {
    try {
      // 1. Converte para Map
      final reviewMap = review.toMap();

      // 2. Remove campos que o banco gera automaticamente
      reviewMap.remove('id');
      reviewMap.remove('created_at');

      // 3. Insere no Supabase
      // (A RLS garante que o usuário só pode inserir se for o reviewer_id)
      await supabaseClient.from('reviews').insert(reviewMap);
    } catch (e) {
      throw ServerException(
        message: 'Erro ao enviar avaliação: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> hasUserReviewed(String bookingId) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) return false;

      // Verifica se existe alguma linha na tabela reviews
      final response = await supabaseClient
          .from('reviews')
          .select('id')
          .eq('booking_id', bookingId)
          .eq('reviewer_id', userId)
          .maybeSingle(); // Retorna null se não achar

      return response != null; // True se achou, False se não
    } catch (e) {
      // Se der erro, assumimos false para não bloquear a UI,
      // mas logamos o erro.
      print('Erro ao checar review: $e');
      return false;
    }
  }
}
