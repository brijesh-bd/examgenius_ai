import 'package:examgenius_ai/features/dashboard/data/mock_dashboard_repository.dart';
import 'package:examgenius_ai/features/question_generator/data/mock_question_generator_repository.dart';
import 'package:examgenius_ai/features/question_generator/data/mock_syllabus_repository.dart';
import 'package:examgenius_ai/features/question_generator/domain/generated_question.dart';
import 'package:examgenius_ai/features/question_generator/domain/question_generator_repository.dart';
import 'package:examgenius_ai/features/question_generator/domain/syllabus.dart';
import 'package:examgenius_ai/features/question_generator/presentation/providers/question_generator_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

GenerationRequest _req(List<String> topics, Difficulty d, int count) =>
    GenerationRequest(
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

  test(
    'sample bank is well-formed and every topic exists in some syllabus',
    () async {
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
    },
  );

  test('selection: exact topic first, same level only, capped at count', () {
    final out = selectQuestions(
      _req(['quant.time_work'], Difficulty.medium, 3),
      kSampleQuestionBank,
    );
    expect(out.length, 3);
    expect(out.first.topicId, 'quant.time_work');
    expect(out.every((q) => q.difficulty == Difficulty.medium), isTrue);
    expect(out.every((q) => subjectIdOf(q.topicId) == 'quant'), isTrue);
  });

  test('selection never crosses into unselected subjects', () {
    final out = selectQuestions(
      _req(['english.synonyms'], Difficulty.easy, 30),
      kSampleQuestionBank,
    );
    expect(out, isNotEmpty);
    expect(out.every((q) => q.topicId.startsWith('english.')), isTrue);
  });

  test(
    'form is complete as soon as a topic is picked (level and count default)',
    () {
      expect(const GeneratorForm().isComplete, isFalse);
      expect(
        const GeneratorForm(topicIds: {'quant.average'}).isComplete,
        isTrue,
      );
      expect(const GeneratorForm().difficulty, Difficulty.medium);
      expect(const GeneratorForm().count, 10);
    },
  );

  test('request JSON matches backend contract', () {
    expect(_req(['quant.average'], Difficulty.hard, 10).toJson(), {
      'examId': 'ssc_cgl',
      'examName': 'SSC CGL',
      'mode': 'topics',
      'topicIds': ['quant.average'],
      'difficulty': 'hard',
      'count': 10,
      'source': 'bank',
      'level': 'exam',
    });
  });

  test(
    'quick practice is complete without topics; source defaults to bank',
    () {
      const quick = GeneratorForm(mode: PracticeMode.quick);
      expect(quick.isComplete, isTrue);
      expect(quick.source, QuestionSource.bank);
      expect(kQuestionCountOptions, [5, 10, 20, 30, 40]);
    },
  );

  group('create practice form', () {
    const subject = SyllabusSubject(
      id: 'math',
      name: 'Mathematics',
      topics: [
        SyllabusTopic(id: 'math.a', name: 'A'),
        SyllabusTopic(id: 'math.b', name: 'B'),
        SyllabusTopic(id: 'math.c', name: 'C'),
      ],
    );
    late ProviderContainer c;
    GeneratorFormController ctl() =>
        c.read(generatorFormProvider('x').notifier);
    GeneratorForm form() => c.read(generatorFormProvider('x'));

    setUp(() {
      c = ProviderContainer();
      c.listen(generatorFormProvider('x'), (_, _) {}); // keep autoDispose alive
    });
    tearDown(() => c.dispose());

    test('defaults: Medium, 10 questions; complete once a topic is picked', () {
      expect(form().difficulty, Difficulty.medium);
      expect(form().count, 10);
      expect(form().isComplete, isFalse);
      ctl().toggleTopic('math.a');
      expect(form().isComplete, isTrue);
    });

    test('multi-select across subjects, select all and clear per subject', () {
      ctl().toggleTopic('math.a');
      ctl().toggleTopic('gk.x');
      ctl().toggleTopic('math.a');
      expect(form().topicIds, {'gk.x'});
      ctl().selectAllIn(subject);
      expect(form().topicIds, {'math.a', 'math.b', 'math.c', 'gk.x'});
      ctl().clearSubject(subject);
      expect(form().topicIds, {'gk.x'});
    });

    test('source, mode and active subject survive other edits', () {
      ctl().setSource(QuestionSource.ai);
      ctl().setActiveSubject('math');
      ctl().setCount(5);
      ctl().setMode(PracticeMode.quick);
      expect(form().source, QuestionSource.ai);
      expect(form().mode, PracticeMode.quick);
      expect(form().activeSubjectId, 'math');
    });

    test('select all only adds the topics visible in a search', () {
      ctl().selectAllIn(subject, visible: ['math.b']);
      expect(form().topicIds, {'math.b'});
      ctl().clearTopics();
      expect(form().topicIds, isEmpty);
    });
  });

  test('last practice is remembered per exam', () async {
    SharedPreferences.setMockInitialValues({});
    final store = LastPracticeStore(await SharedPreferences.getInstance());
    expect(store.read('rrb_ntpc'), isNull);
    await store.save(
      LastPracticeConfig.fromRequest(
        _req(
          ['quant.percentage', 'quant.average'],
          Difficulty.hard,
          20,
        ).copyWith(source: QuestionSource.ai),
        language: 'hi',
      ),
    );
    final last = store.read('ssc_cgl');
    expect(last?.topicIds, ['quant.percentage', 'quant.average']);
    expect(last?.subjectIds, ['quant']);
    expect(last?.difficulty, Difficulty.hard);
    expect(last?.count, 20);
    expect(last?.source, QuestionSource.ai);
    expect(last?.language, 'hi');
    expect(store.read('rrb_ntpc'), isNull);
  });
}
