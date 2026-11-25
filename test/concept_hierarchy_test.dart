import 'package:examgenius_ai/features/question_generator/data/concept_hierarchy_repository.dart';
import 'package:examgenius_ai/features/question_generator/domain/generated_question.dart';
import 'package:examgenius_ai/features/question_generator/domain/concept_hierarchy.dart';
import 'package:examgenius_ai/features/question_generator/domain/syllabus.dart';
import 'package:examgenius_ai/features/question_generator/presentation/providers/question_generator_providers.dart';
import 'package:examgenius_ai/features/question_generator/presentation/widgets/concept_tree.dart';
import 'package:examgenius_ai/features/study_notes/domain/study_note.dart';
import 'package:examgenius_ai/features/study_notes/presentation/screens/notes_concept_screen.dart';
import 'package:examgenius_ai/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:examgenius_ai/core/services/preferences_service.dart';

const _rules = 'rm.number_system.divisibility.rules';
const _by2 = '$_rules.by_2';
const _by3 = '$_rules.by_3';
const _by11 = '$_rules.by_11';

Future<ConceptHierarchy> _tree([String examId = 'rrb_je']) async =>
    (await MockConceptHierarchyRepository().fetchTree(examId, 'quant'))!;

Widget _host(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

/// Stateful harness: the tree owns its selection like the real form.
class _Picker extends StatefulWidget {
  const _Picker(this.tree, {this.lang = 'en'});
  final ConceptHierarchy tree;
  final String lang;
  @override
  State<_Picker> createState() => _PickerState();
}

class _PickerState extends State<_Picker> {
  Set<String> selection = {};
  @override
  Widget build(BuildContext context) => ConceptTree(
    tree: widget.tree,
    languageCode: widget.lang,
    selection: selection,
    onToggle: (id) =>
        setState(() => selection = widget.tree.toggle(id, selection)),
  );
}

void main() {
  group('ConceptHierarchy selection (pure)', () {
    test('parent selection covers children; stored once', () async {
      final t = await _tree();
      var s = t.toggle('rm.number_system.divisibility', {});
      expect(s, {'rm.number_system.divisibility'});
      expect(t.conceptsOf(s), {_by2, _by3, _by11});
      expect(t.stateOf(_by3, s), SelectionState.all);
      // Selecting a child that is already covered does not duplicate it.
      expect(t.normalise({...s, _by3}), s);
    });

    test(
      'child selection gives partial parents; completing collapses up',
      () async {
        final t = await _tree();
        var s = t.toggle(_by3, {});
        expect(s, {_by3});
        expect(t.stateOf(_rules, s), SelectionState.partial);
        expect(t.stateOf('rm.number_system', s), SelectionState.partial);
        expect(t.stateOf('rm.percentage', s), SelectionState.none);
        s = t.toggle(_by2, s);
        s = t.toggle(_by11, s);
        // All three concepts → the whole divisibility topic (no descendants listed).
        expect(s, {'rm.number_system.divisibility'});
      },
    );

    test(
      'unselecting a child of a selected parent keeps its siblings',
      () async {
        final t = await _tree();
        var s = t.toggle('rm.number_system', {});
        s = t.toggle(_by11, s);
        expect(t.conceptsOf(s).contains(_by11), isFalse);
        expect(t.conceptsOf(s).containsAll({_by2, _by3}), isTrue);
        expect(t.stateOf('rm.number_system', s), SelectionState.partial);
        expect(s.contains('rm.number_system'), isFalse);
      },
    );

    test('unknown ids are dropped; order follows the syllabus', () async {
      final t = await _tree();
      final s = t.normalise({'rm.percentage', 'rm.nope', _by11});
      expect(s, {'rm.percentage', _by11});
      expect(t.ordered(s), [_by11, 'rm.percentage']);
    });

    test('search matches English and Hindi with ancestors', () async {
      final t = await _tree();
      expect(t.visibleFor(''), isNull);
      final v = t.visibleFor('by 11')!;
      expect(v, containsAll(['rm.number_system', _rules, _by11]));
      expect(v.contains(_by2), isFalse);
      expect(t.visibleFor('प्रतिशत')!, contains('rm.percentage'));
      expect(t.visibleFor('zzz'), isEmpty);
    });

    test('exam applicability comes from the server tree', () async {
      expect((await _tree('rrb_ntpc')).contains('rm.calendar_clock'), isFalse);
      expect((await _tree('rrb_je')).contains('rm.calendar_clock'), isTrue);
      expect(
        await MockConceptHierarchyRepository().fetchTree('ssc_cgl', 'quant'),
        isNull,
      );
    });
  });

  group('requests use exact node ids', () {
    test('practice request carries subjectId + selectedNodeIds', () async {
      final t = await _tree();
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final c = container.read(generatorFormProvider('rrb_je').notifier);
      c.selectSubject(kMathSubjectId);
      c.toggleNode(t, 'rm.percentage');
      c.toggleNode(t, _by3);
      c.toggleNode(t, _by3); // off again
      c.toggleNode(t, _by11);
      final r = c.buildRequest(
        examName: 'RRB JE',
        syllabus: const Syllabus(examId: 'rrb_je', subjects: []),
        mathTree: t,
      )!;
      expect(r.selectedNodeIds, [_by11, 'rm.percentage']);
      final json = r.toJson();
      expect(json['subjectId'], 'quant');
      expect(json['selectedNodeIds'], [_by11, 'rm.percentage']);
      // Changing subject (or exam = another form) resets the selection.
      c.selectSubject('reasoning');
      expect(container.read(generatorFormProvider('rrb_je')).nodeIds, isEmpty);
      expect(
        container.read(generatorFormProvider('rrb_ntpc')).nodeIds,
        isEmpty,
      );
    });

    test('notes request sends nodeId for a concept, topicId otherwise', () {
      Map<String, dynamic> body(String id) => NotesRequest(
        examId: 'rrb_je',
        topicId: id,
        language: 'hi',
        level: NoteLevel.examStandard,
        sections: {NoteSection.explanation},
      ).toJson();
      expect(body(_by11)['nodeId'], _by11);
      expect(body(_by11).containsKey('topicId'), isFalse);
      expect(body('quant.percentage')['topicId'], 'quant.percentage');
      expect(body('quant.percentage').containsKey('nodeId'), isFalse);
    });

    test('GenerationRequest equality includes node ids', () {
      const a = GenerationRequest(
        examId: 'e',
        examName: 'E',
        topicIds: [],
        difficulty: Difficulty.medium,
        count: 10,
        selectedNodeIds: ['rm.a'],
      );
      const b = GenerationRequest(
        examId: 'e',
        examName: 'E',
        topicIds: [],
        difficulty: Difficulty.medium,
        count: 10,
        selectedNodeIds: ['rm.b'],
      );
      expect(a == b, isFalse);
    });
  });

  group('ConceptTree widget', () {
    testWidgets('expand, collapse, select parent / child / partial', (
      tester,
    ) async {
      final t = await tester.runAsync(_tree);
      await tester.pumpWidget(_host(_Picker(t!)));
      // Collapsed: chapters only.
      expect(find.text('Number System'), findsOneWidget);
      expect(find.text('Divisibility'), findsNothing);

      await tester.tap(find.byKey(const ValueKey('expand_rm.number_system')));
      await tester.pumpAndSettle();
      expect(find.text('Divisibility'), findsOneWidget);
      await tester.tap(
        find.byKey(const ValueKey('expand_rm.number_system.divisibility')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('expand_$_rules')));
      await tester.pumpAndSettle();
      expect(find.text('Divisibility by 11'), findsOneWidget);

      Checkbox box(String id) =>
          tester.widget<Checkbox>(find.byKey(ValueKey('check_$id')));

      await tester.tap(find.byKey(const ValueKey('check_$_by3')));
      await tester.pump();
      expect(box(_by3).value, isTrue);
      expect(box(_rules).value, isNull, reason: 'partial');
      expect(box('rm.number_system').value, isNull);

      await tester.tap(find.byKey(const ValueKey('check_rm.number_system')));
      await tester.pump();
      expect(box(_by11).value, isTrue);
      expect(box('rm.number_system').value, isTrue);
      final state = tester.state<_PickerState>(find.byType(_Picker));
      expect(state.selection, {'rm.number_system'}, reason: 'no duplicates');

      await tester.tap(find.byKey(const ValueKey('check_rm.number_system')));
      await tester.pump();
      expect(state.selection, isEmpty);

      // Collapse hides descendants again.
      await tester.tap(find.byKey(const ValueKey('expand_rm.number_system')));
      await tester.pumpAndSettle();
      expect(find.text('Divisibility'), findsNothing);
    });

    testWidgets('search filters (EN/HI) and shows an empty state', (
      tester,
    ) async {
      final t = await tester.runAsync(_tree);
      await tester.pumpWidget(_host(_Picker(t!, lang: 'hi')));
      expect(
        find.text('संख्या पद्धति'),
        findsOneWidget,
        reason: 'Hindi labels',
      );
      await tester.enterText(
        find.byKey(const Key('conceptSearch')),
        'cyclicity',
      );
      await tester.pump();
      expect(find.text('अंकों की चक्रीयता'), findsOneWidget);
      expect(find.text('प्रतिशत'), findsNothing);
      await tester.enterText(find.byKey(const Key('conceptSearch')), 'qqq');
      await tester.pump();
      expect(find.byType(Checkbox), findsNothing);
      expect(find.byType(Text).evaluate().length, greaterThan(0));
    });

    testWidgets('exam switch resets expansion', (tester) async {
      final je = await tester.runAsync(() => _tree('rrb_je'));
      final ntpc = await tester.runAsync(() => _tree('rrb_ntpc'));
      final key = GlobalKey();
      await tester.pumpWidget(
        _host(
          ConceptTree(key: key, tree: je!, languageCode: 'en', onPick: (_) {}),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('expand_rm.number_system')));
      await tester.pumpAndSettle();
      expect(find.text('Divisibility'), findsOneWidget);
      expect(find.text('Calendar and Clock'), findsOneWidget);
      await tester.pumpWidget(
        _host(
          ConceptTree(
            key: key,
            tree: ntpc!,
            languageCode: 'en',
            onPick: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Divisibility'), findsNothing);
      expect(find.text('Calendar and Clock'), findsNothing);
    });
  });

  group('Notes concept picker', () {
    Future<void> pump(
      WidgetTester tester,
      ConceptHierarchyRepository repo,
    ) async {
      SharedPreferences.setMockInitialValues({'locale_code': 'en'});
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            conceptHierarchyRepositoryProvider.overrideWithValue(repo),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const NotesConceptScreen(
              examId: 'rrb_je',
              subjectId: 'quant',
            ),
          ),
        ),
      );
    }

    testWidgets('loading then tree', (tester) async {
      await pump(tester, MockConceptHierarchyRepository());
      expect(find.byType(ConceptTree), findsNothing, reason: 'loading');
      await tester.pumpAndSettle();
      expect(find.byType(ConceptTree), findsOneWidget);
      expect(find.byType(Checkbox), findsNothing, reason: 'single-pick mode');
    });

    testWidgets('error with retry', (tester) async {
      final repo = MockConceptHierarchyRepository(fail: true);
      await pump(tester, repo);
      await tester.pumpAndSettle();
      expect(find.byType(ConceptTree), findsNothing);
      expect(find.text('Retry'), findsOneWidget);
      repo.fail = false;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.byType(ConceptTree), findsOneWidget);
    });
  });

  group('Any subject: exam-specific hierarchical syllabus', () {
    Future<ConceptHierarchy?> reasoning(String examId) =>
        MockConceptHierarchyRepository().fetchTree(examId, 'reasoning');

    test(
      'each exam loads its own tree; NTPC-only chapter does not leak',
      () async {
        final ntpc = (await reasoning('rrb_ntpc'))!;
        final groupD = (await reasoning('rrb_group_d'))!;
        expect(ntpc.subjectId, 'reasoning');
        expect(ntpc.contains('rr.maps_graphs'), isTrue);
        expect(groupD.contains('rr.maps_graphs'), isFalse);
        expect(groupD.node('rr.analogy')!.status, NodeStatus.unverified);
        expect(groupD.node('rr.analogy.number')!.status, NodeStatus.draft);
        expect(groupD.hasOfficial, isFalse);
        expect(
          await MockConceptHierarchyRepository().fetchTree('rrb_je', 'english'),
          isNull,
        );
      },
    );

    test('node ids map to their subject', () {
      expect(conceptSubjectOf('rr.analogy'), 'reasoning');
      expect(conceptSubjectOf('ga.history.ancient'), 'general_awareness');
      expect(conceptSubjectOf('gs.physics'), 'general_science');
      expect(conceptSubjectOf('rm.percentage'), 'quant');
      expect(isConceptNode('reasoning.analogy'), isFalse);
    });

    test('whole-subject toggle and micro-concept request', () async {
      final t = (await reasoning('rrb_je'))!;
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final c = container.read(generatorFormProvider('rrb_je').notifier);
      c.selectSubject('reasoning');
      c.toggleWholeSubject(t);
      expect(container.read(generatorFormProvider('rrb_je')).nodeIds, {
        'rr.analogy',
        'rr.number_series',
      });
      c.toggleWholeSubject(t);
      expect(container.read(generatorFormProvider('rrb_je')).nodeIds, isEmpty);
      c.toggleNode(t, 'rr.number_series.task.missing_term');
      final r = c.buildRequest(
        examName: 'RRB JE',
        syllabus: const Syllabus(examId: 'rrb_je', subjects: []),
        mathTree: t,
      )!;
      expect(r.toJson()['subjectId'], 'reasoning');
      expect(r.selectedNodeIds, ['rr.number_series.task.missing_term']);
    });

    test('notes request uses nodeId for any subject', () {
      final body = const NotesRequest(
        examId: 'rrb_je',
        topicId: 'ga.history.ancient.mauryan.ashoka',
        language: 'en',
        level: NoteLevel.examStandard,
        sections: {NoteSection.explanation},
      ).toJson();
      expect(body['nodeId'], 'ga.history.ancient.mauryan.ashoka');
    });

    testWidgets('selection summary is compact', (tester) async {
      final t = await tester.runAsync(() => reasoning('rrb_ntpc'));
      await tester.pumpWidget(
        _host(
          SelectionSummary(
            tree: t!,
            selection: const {'rr.analogy', 'rr.number_series.task.wrong_term'},
            languageCode: 'en',
          ),
        ),
      );
      expect(find.text('Analogy (all) · Number Series (1)'), findsOneWidget);
    });
  });

  test("Station Master node ids map to the CEN 08/2026 sections", () {
    expect(
      conceptSubjectOf("smb.basic_science_math.mathematics.probability"),
      "sm_science_math",
    );
    expect(
      conceptSubjectOf("sml.reading_comprehension.main_idea"),
      "sm_logical",
    );
    expect(conceptSubjectOf("smr.analogy"), "sm_mental");
    expect(isConceptNode("smr.analogy"), isTrue);
  });

  group("SSC", () {
    test("SSC node ids map to their subjects", () {
      expect(conceptSubjectOf("sq.arithmetic.discount"), "quant");
      expect(conceptSubjectOf("sr.address_matching"), "reasoning");
      expect(conceptSubjectOf("en.grammar.voice"), "english");
      expect(conceptSubjectOf("jc.surveying"), "je_civil");
      expect(conceptSubjectOf("jl.machines"), "je_electrical");
      expect(conceptSubjectOf("jm.thermal"), "je_mechanical");
      expect(conceptSubjectOf("ck.software"), "computer");
    });

    test(
      "SSC CGL reasoning tree: official chapters, leaf chapters selectable",
      () async {
        final t = (await MockConceptHierarchyRepository().fetchTree(
          "ssc_cgl",
          "reasoning",
        ))!;
        expect(t.hasOfficial, isTrue);
        expect(t.node("sr.semantic_analogy")!.status, NodeStatus.official);
        expect(
          t.node("sr.number_series.question_type.missing_term")!.status,
          NodeStatus.supplementary,
        );
        // A chapter without children is itself a selectable concept.
        final s = t.toggle("sr.address_matching", {});
        expect(t.conceptsOf(s), {"sr.address_matching"});
        final r = t.toggle("sr.number_series", s);
        expect(t.ordered(r), ["sr.number_series", "sr.address_matching"]);
      },
    );

    test(
      "SSC practice request carries the exam subject and node ids",
      () async {
        final t = (await MockConceptHierarchyRepository().fetchTree(
          "ssc_cgl",
          "reasoning",
        ))!;
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final c = container.read(generatorFormProvider("ssc_cgl").notifier);
        c.selectSubject("reasoning");
        c.toggleNode(t, "sr.number_series.question_type.missing_term");
        final r = c.buildRequest(
          examName: "SSC CGL",
          syllabus: const Syllabus(examId: "ssc_cgl", subjects: []),
          mathTree: t,
        )!;
        expect(r.toJson()["subjectId"], "reasoning");
        // Its only concept → normalised to the whole chapter (no duplicate child id).
        expect(r.selectedNodeIds, ["sr.number_series"]);
      },
    );
  });
}
