import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../models/game_session.dart';
import '../models/question.dart';
import '../models/game_result.dart';

final gameRepositoryProvider = Provider<GameRepository>((ref) {
  return GameRepository(ref.watch(dioProvider));
});

class GameRepository {
  final Dio _dio;
  GameRepository(this._dio);

  Future<GameSession> startSession(String playerId, String subject, int totalQuestions) async {
    final response = await _dio.post(
      '/api/v1/session',
      data: {'playerId': playerId, 'subject': subject, 'totalQuestions': totalQuestions},
    );
    return GameSession.fromJson(response.data);
  }

  Future<Question?> getNextQuestion(String sessionId) async {
    try {
      final response = await _dio.get('/api/v1/session/$sessionId/next-question');
      return Question.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null; // No more questions
      }
      rethrow;
    }
  }

  Future<bool> submitAnswer(String sessionId, int answerIndex) async {
    final response = await _dio.post('/api/v1/session/$sessionId/answer', data: {'answer': answerIndex});
    // Returns bool if correct
    return response.data['isCorrect'] as bool? ?? false;
  }

  Future<GameResult> finishSession(String sessionId) async {
    final response = await _dio.post('/api/v1/session/$sessionId/finish');
    return GameResult.fromJson(response.data);
  }
}
