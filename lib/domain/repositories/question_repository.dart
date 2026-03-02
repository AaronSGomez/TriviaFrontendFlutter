import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';

final questionRepositoryProvider = Provider<QuestionRepository>((ref) {
  return QuestionRepository(ref.watch(dioProvider));
});

class QuestionRepository {
  final Dio _dio;
  QuestionRepository(this._dio);

  Future<void> createQuestion({
    required String statement,
    required String subject,
    required String topic,
    required String optionA,
    required String optionB,
    required String optionC,
    required String optionD,
    required String correctOption,
    required String explanation,
    String difficulty = "Medio",
    bool active = true,
  }) async {
    await _dio.post(
      '/api/v1/questions',
      data: {
        'statement': statement,
        'subject': subject,
        'topic': topic,
        'optionA': optionA,
        'optionB': optionB,
        'optionC': optionC,
        'optionD': optionD,
        'correctOption': correctOption,
        'explanation': explanation,
        'difficulty': difficulty,
        'active': active,
      },
    );
  }
}
