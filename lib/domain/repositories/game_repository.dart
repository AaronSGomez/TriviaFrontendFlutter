import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../models/game_session.dart';
import '../models/question.dart';
import '../models/game_result.dart';
import '../models/answer_result.dart';

final gameRepositoryProvider = Provider<GameRepository>((ref) {
  return GameRepository(ref.watch(dioProvider));
});

class GameRepository {
  final Dio _dio;
  GameRepository(this._dio);

  void _validateSessionId(String sessionId) {
    if (sessionId.trim().isEmpty) {
      throw ArgumentError('sessionId cannot be empty');
    }
  }

  Future<GameSession> startSession(String playerId, String subject, int totalQuestions) async {
    final response = await _dio.post(
      '/api/v1/session',
      data: {'playerId': playerId, 'subject': subject, 'totalQuestions': totalQuestions},
    );
    return GameSession.fromJson(response.data);
  }

  Future<Question?> getNextQuestion(String sessionId) async {
    _validateSessionId(sessionId);
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

  Future<AnswerResult> submitAnswer(
    String sessionId,
    int questionId,
    String selectedOption,
    int timeElapsedSeconds,
  ) async {
    _validateSessionId(sessionId);
    final response = await _dio.post(
      '/api/v1/session/$sessionId/answer',
      data: {'questionId': questionId, 'selectedOption': selectedOption, 'timeElapsedSeconds': timeElapsedSeconds},
    );
    return AnswerResult.fromJson(response.data);
  }

  Future<GameResult> finishSession(String sessionId) async {
    _validateSessionId(sessionId);
    final response = await _dio.post('/api/v1/session/$sessionId/finish');
    return GameResult.fromJson(response.data);
  }

  Future<List<GameSession>> getLeaderboard() async {
    final response = await _dio.get('/api/v1/session/leaderboard');
    return (response.data as List).map((x) => GameSession.fromJson(x)).toList();
  }

  Future<List<GameSession>> getWeeklyLeaderboard() async {
    final response = await _dio.get('/api/v1/session/leaderboard/weekly');
    return (response.data as List).map((x) => GameSession.fromJson(x)).toList();
  }
}
