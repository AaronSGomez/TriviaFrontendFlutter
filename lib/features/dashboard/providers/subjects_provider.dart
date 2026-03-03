import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/repositories/question_repository.dart';

class SubjectInfo {
  final String name;
  final int count;

  SubjectInfo({required this.name, required this.count});
}

final subjectsProvider = FutureProvider.autoDispose<List<SubjectInfo>>((ref) async {
  final repository = ref.watch(questionRepositoryProvider);
  final questions = await repository.getAllQuestions();

  final Map<String, int> counts = {};
  for (final q in questions) {
    if (q.subject.isNotEmpty) {
      counts[q.subject] = (counts[q.subject] ?? 0) + 1;
    }
  }

  final sortedSubjects = counts.entries.map((e) => SubjectInfo(name: e.key, count: e.value)).toList()
    ..sort((a, b) => a.name.compareTo(b.name));

  return sortedSubjects;
});
