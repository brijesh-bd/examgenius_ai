import 'package:examgenius_ai/features/dashboard/data/mock_dashboard_repository.dart';
import 'package:examgenius_ai/features/question_generator/data/mock_question_generator_repository.dart';
import 'package:examgenius_ai/features/question_generator/data/mock_syllabus_repository.dart';
import 'package:examgenius_ai/features/question_generator/domain/generated_question.dart';
import 'package:examgenius_ai/features/question_generator/domain/question_generator_repository.dart';
import 'package:examgenius_ai/features/question_generator/domain/syllabus.dart';
import 'package:examgenius_ai/features/question_generator/presentation/providers/question_generator_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

GenerationRequest _req(List<String> topics, Difficulty d, int count) => GenerationRequest(
      examId: 'ssc_cgl',
      examName: 'SSC CGL',
      topicIds: topics,
      difficulty: d,
      count: count,
    );

void main() {
  test('every exam in the catalog has a non-empty syllabus', () async {
    final repo = MockSyllabusRepository();
    for (final c in kExamCatalog) {
      for (final e in c.exams) {
        final s = await repo.fetchSyllabus(e.id);
        expect(s.subjects, isNotEmpty, reason: e.id);
        for (final subj in s.subjects) {
          expect(subj.topics, isNotEmpty, reason: '${e.id}/${subj.id}');
          for (final t in subj.topics) {
            expect(t.subjectId, subj.id);
          }
        }
      }
    }
  });

  test('sample bank is well-formed and every topic exists in some syllabus', () async {
    final repo = MockSyllabusRepository();
    final allTopics = <String>{};
    for (final c in kExamCatalog) {
      for (final e in c.exams) {
        final s = await repo.fetchSyllabus(e.id);
        allTopics.addAll(s.subjects.expand((x) => x.topics).map((t) => t.id));
      }
    }
    final ids = <String>{};
    for (final q in kSampleQuestionBank) {
      expect(ids.add(q.id), isTrue);
      expect(q.options.length, 4, reason: q.question);
      expect(q.correctIndex, inInclusiveRange(0, 3));
      expect(q.options.toSet().length, 4, reason: q.question);
      expect(allTopics, contains(q.topicId));
    }
  });

  test('selection: exact topic first, same level only, capped at count', () {
    final out = selectQuestions(_req(['quant.time_work'], Difficulty.medium, 3), kSampleQuestionBank);
    expect(out.length, 3);
    expect(out.first.topicId, 'quant.time_work');
    expect(out.every((q) => q.difficulty == Difficulty.medium), isTrue);
    expect(out.every((q) => subjectIdOf(q.topicId) == 'quant'), isTrue);
  });

  test('selection never crosses into unselected subjects', () {
    final out = selectQuestions(_req(['english.synonyms'], Difficulty.easy, 30), kSampleQuestionBank);
    expect(out, isNotEmpty);
    expect(out.every((q) => q.topicId.startsWith('english.')), isTrue);
  });

  test('form is complete only when topic, difficulty and count are set', () {
    expect(const GeneratorForm().isComplete, isFalse);
    expect(const GeneratorForm(topicIds: {'quant.average'}, difficulty: Difficulty.easy).isComplete,
        isFalse);
    expect(
      const GeneratorForm(topicIds: {'quant.average'}, difficulty: Difficulty.easy, count: 10)
          .isComplete,
      isTrue,
    );
  });

  test('request JSON matches backend contract', () {
    expect(_req(['quant.average'], Difficulty.hard, 10).toJson(), {
      'examId': 'ssc_cgl',
      'examName': 'SSC CGL',
      'topicIds': ['quant.average'],
      'difficulty': 'hard',
      'count': 10,
      'level': 'exam',
    });
  });

  group('topic selection modes', () {
    const subject = SyllabusSubject(id: 'math', name: 'Mathematics', topics: [
      SyllabusTopic(id: 'math.a', name: 'A'),
      SyllabusTopic(id: 'math.b', name: 'B'),
      SyllabusTopic(id: 'math.c', name: 'C'),
    ]);
    late ProviderContainer c;
    GeneratorFormController ctl() => c.read(generatorFormProvider('x').notifier);
    Set<String> ids() => c.read(generatorFormProvider('x')).topicIds;

    setUp(() {
      c = ProviderContainer();
      c.listen(generatorFormProvider('x'), (_, _) {}); // keep autoDispose alive
    });
    tearDown(() => c.dispose());

    test('multiple: toggles, select all and clear per subject', () {
      ctl().selectTopic('math.a');
      ctl().selectTopic('math.b');
      ctl().selectTopic('gk.x');
      expect(ids(), {'math.a', 'math.b', 'gk.x'});
      ctl().selectTopic('math.a');
      expect(ids(), {'math.b', 'gk.x'});
      ctl().selectAllIn(subject);
      expect(ids(), {'math.a', 'math.b', 'math.c', 'gk.x'});
      ctl().clearSubject(subject);
      expect(ids(), {'gk.x'});
    });

    test('single: one topic per subject, switching trims extras', () {
      ctl().selectTopic('math.a');
      ctl().selectTopic('math.b');
      ctl().setMultiSelect(false);
      expect(ids(), {'math.a'});
      ctl().selectTopic('math.c');
      ctl().selectTopic('gk.x');
      expect(ids(), {'math.c', 'gk.x'}); // other subjects untouched
      ctl().selectTopic('math.c');
      expect(ids(), {'gk.x'}); // tap again clears
      ctl().selectAllIn(subject);
      expect(ids(), {'gk.x'}); // select all is multiple-only
    });
  });
}
