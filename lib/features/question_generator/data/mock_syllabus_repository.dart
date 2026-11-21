import '../domain/question_generator_repository.dart';
import '../domain/syllabus.dart';

/// Seed syllabi, shaped like `GET /api/v1/exams/:examId/syllabus`. Subjects are
/// composed from shared topic blocks because many exams share sections.
class MockSyllabusRepository implements SyllabusRepository {
  @override
  Future<Syllabus> fetchSyllabus(String examId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final subjects = _examSubjects[examId];
    if (subjects == null) throw StateError('No syllabus for $examId');
    return Syllabus.fromJson({'examId': examId, 'subjects': subjects});
  }
}

Map<String, dynamic> _subject(String id, String name, Map<String, String> topics) => {
      'id': id,
      'name': name,
      'topics': [
        for (final e in topics.entries) {'id': '$id.${e.key}', 'name': e.value},
      ],
    };

const _arithmetic = {
  'percentage': 'Percentage',
  'ratio_proportion': 'Ratio & Proportion',
  'average': 'Average',
  'profit_loss': 'Profit & Loss',
  'simple_compound_interest': 'Simple & Compound Interest',
  'time_work': 'Time & Work',
  'time_speed_distance': 'Time, Speed & Distance',
};

const _basicNumbers = {
  'number_system': 'Number System',
  'lcm_hcf': 'LCM & HCF',
  'decimals_fractions': 'Decimals & Fractions',
  'simplification': 'Simplification',
};

final _quantSsc = _subject('quant', 'Quantitative Aptitude', {
  'number_system': 'Number System',
  'simplification': 'Simplification',
  ..._arithmetic,
  'mixtures_alligation': 'Mixture & Alligation',
  'mensuration': 'Mensuration (2D & 3D)',
  'algebra': 'Algebra',
  'geometry': 'Geometry',
  'trigonometry': 'Trigonometry',
  'data_interpretation': 'Data Interpretation',
});

final _quantRailway = _subject('quant', 'Mathematics', {
  ..._basicNumbers,
  ..._arithmetic,
  'pipes_cisterns': 'Pipes & Cisterns',
  'age_problems': 'Problems on Ages',
  'mensuration': 'Mensuration',
  'algebra': 'Elementary Algebra',
  'geometry': 'Geometry',
  'trigonometry': 'Trigonometry',
  'statistics': 'Elementary Statistics',
  'data_interpretation': 'Data Interpretation',
});

final _quantBasic = _subject('quant', 'Numerical Aptitude', {
  ..._basicNumbers,
  ..._arithmetic,
  'mensuration': 'Mensuration',
});

final _quantBanking = _subject('quant', 'Quantitative Aptitude', {
  'simplification': 'Simplification & Approximation',
  'number_series': 'Number Series',
  'quadratic_equations': 'Quadratic Equations',
  'data_interpretation': 'Data Interpretation',
  ..._arithmetic,
  'mixtures_alligation': 'Mixture & Alligation',
  'mensuration': 'Mensuration',
  'probability': 'Probability',
  'permutation_combination': 'Permutation & Combination',
  'data_sufficiency': 'Data Sufficiency',
});

final _reasoningGeneral = _subject('reasoning', 'General Intelligence & Reasoning', {
  'analogy': 'Analogy',
  'classification': 'Classification (Odd One Out)',
  'number_letter_series': 'Number & Letter Series',
  'coding_decoding': 'Coding-Decoding',
  'blood_relations': 'Blood Relations',
  'direction_sense': 'Direction Sense',
  'order_ranking': 'Order & Ranking',
  'syllogism': 'Syllogism',
  'venn_diagrams': 'Venn Diagrams',
  'statement_conclusion': 'Statement & Conclusion',
  'calendar_clock': 'Calendar & Clock',
  'mathematical_operations': 'Mathematical Operations',
  'seating_arrangement': 'Seating Arrangement',
  'non_verbal': 'Non-Verbal (Mirror, Water Image, Paper Folding)',
});

final _reasoningBanking = _subject('reasoning', 'Reasoning Ability', {
  'puzzles': 'Puzzles',
  'seating_arrangement': 'Seating Arrangement',
  'syllogism': 'Syllogism',
  'inequality': 'Inequality',
  'coding_decoding': 'Coding-Decoding',
  'blood_relations': 'Blood Relations',
  'direction_sense': 'Direction Sense',
  'order_ranking': 'Order & Ranking',
  'alphanumeric_series': 'Alphanumeric Series',
  'input_output': 'Input-Output',
  'statement_conclusion': 'Statement, Assumption & Conclusion',
  'data_sufficiency': 'Data Sufficiency',
});

final _generalAwareness = _subject('general_awareness', 'General Awareness', {
  'history': 'History',
  'polity': 'Indian Polity & Constitution',
  'geography': 'Geography',
  'economy': 'Indian Economy',
  'art_culture': 'Art & Culture',
  'static_gk': 'Static GK',
  'current_affairs': 'Current Affairs',
  'sports': 'Sports',
  'awards_honours': 'Awards & Honours',
  'books_authors': 'Books & Authors',
  'government_schemes': 'Government Schemes',
  'science_technology': 'Science & Technology',
});

final _generalScience = _subject('general_science', 'General Science', {
  'physics': 'Physics',
  'chemistry': 'Chemistry',
  'biology': 'Biology (Life Sciences)',
});

final _english = _subject('english', 'English Language', {
  'reading_comprehension': 'Reading Comprehension',
  'cloze_test': 'Cloze Test',
  'error_spotting': 'Error Spotting',
  'fill_blanks': 'Fill in the Blanks',
  'sentence_improvement': 'Sentence Improvement',
  'synonyms': 'Synonyms',
  'antonyms': 'Antonyms',
  'idioms_phrases': 'Idioms & Phrases',
  'one_word_substitution': 'One Word Substitution',
  'active_passive': 'Active & Passive Voice',
  'direct_indirect': 'Direct & Indirect Speech',
  'spelling': 'Spelling Correction',
  'para_jumbles': 'Para Jumbles',
});

final _computer = _subject('computer', 'Computer Knowledge', {
  'fundamentals': 'Computer Fundamentals',
  'memory': 'Memory & Storage',
  'ms_office': 'MS Office',
  'internet_networking': 'Internet & Networking',
  'operating_system': 'Operating System',
  'security': 'Cyber Security',
});

final _bankingAwareness = _subject('banking_awareness', 'General / Banking Awareness', {
  'banking_terms': 'Banking Terms & Services',
  'rbi_monetary_policy': 'RBI & Monetary Policy',
  'acts_regulations': 'Banking Acts & Regulations',
  'financial_awareness': 'Financial Awareness',
  'government_schemes': 'Government Schemes',
  'current_affairs': 'Current Affairs',
  'static_gk': 'Static GK',
});

final _professionalIt = _subject('professional_it', 'Professional Knowledge (IT)', {
  'dbms': 'DBMS',
  'data_structures': 'Data Structures',
  'networking': 'Computer Networks',
  'operating_system': 'Operating System',
  'software_engineering': 'Software Engineering',
  'web_technology': 'Web Technology',
  'security': 'Information Security',
});

final _technicalAlp = _subject('technical', 'Basic Science & Engineering', {
  'units_measurements': 'Units & Measurements',
  'basic_electricity': 'Basic Electricity',
  'work_power_energy': 'Work, Power & Energy',
  'levers_pulleys': 'Levers & Simple Machines',
  'engineering_drawing': 'Engineering Drawing',
  'heat_temperature': 'Heat & Temperature',
});

final _technicalJe = _subject('technical', 'Technical Abilities', {
  'basic_electricity': 'Basic Electrical Engineering',
  'units_measurements': 'Units & Measurements',
  'engineering_mechanics': 'Engineering Mechanics',
  'materials': 'Engineering Materials',
  'engineering_drawing': 'Engineering Drawing',
  'environment': 'Environment & Pollution Control',
});

final _sscStandard = [_quantSsc, _reasoningGeneral, _english, _generalAwareness];
final _sscBasic = [_reasoningGeneral, _generalAwareness, _quantBasic, _english];
final _bankStandard = [_reasoningBanking, _quantBanking, _english, _bankingAwareness, _computer];

final Map<String, List<Map<String, dynamic>>> _examSubjects = {
  'rrb_ntpc': [_quantRailway, _reasoningGeneral, _generalAwareness, _generalScience],
  'rrb_group_d': [_quantRailway, _reasoningGeneral, _generalScience, _generalAwareness],
  'rrb_alp': [_quantRailway, _reasoningGeneral, _generalScience, _generalAwareness, _technicalAlp],
  'rrb_je': [_quantRailway, _reasoningGeneral, _generalAwareness, _generalScience, _technicalJe],
  'ssc_cgl': [..._sscStandard, _computer],
  'ssc_chsl': [..._sscStandard, _computer],
  'ssc_mts': _sscBasic,
  'ssc_gd': _sscBasic,
  'ssc_cpo': _sscStandard,
  'ibps_po': _bankStandard,
  'ibps_clerk': _bankStandard,
  'ibps_rrb_po': _bankStandard,
  'ibps_rrb_clerk': _bankStandard,
  'sbi_po': _bankStandard,
  'sbi_clerk': _bankStandard,
  'ibps_so_it': [_reasoningBanking, _english, _quantBanking, _professionalIt],
};
