import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../models/question.dart';

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

  Future<void> updateQuestion({
    required int id,
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
    await _dio.put(
      '/api/v1/questions/$id',
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

  Future<void> deleteQuestion(int id) async {
    await _dio.delete('/api/v1/questions/$id');
  }

  Future<List<Question>> getAllQuestions() async {
    final response = await _dio.get('/api/v1/questions');
    final data = response.data as List;
    return data.map((q) => Question.fromJson(q)).toList();
  }

  Future<Question> getQuestionById(int id) async {
    final response = await _dio.get('/api/v1/questions/$id');
    return Question.fromJson(response.data);
  }
}
