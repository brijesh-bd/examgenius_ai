// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'ExamGenius AI';

  @override
  String get appTagline => 'Your Bridge to Government Success';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started';

  @override
  String get chooseLanguage => 'Choose your language';

  @override
  String get chooseLanguageSubtitle =>
      'You can change this anytime from your profile.';

  @override
  String get onboarding1Title => 'AI-Powered Practice';

  @override
  String get onboarding1Body =>
      'Get exam-level questions instantly with the power of AI';

  @override
  String get onboarding2Title => 'Mock Tests';

  @override
  String get onboarding2Body =>
      'Full-length and topic-wise tests with real exam pattern';

  @override
  String get onboarding3Title => 'Performance Analytics';

  @override
  String get onboarding3Body =>
      'Track accuracy, find weak chapters and improve every day';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get loginSubtitle => 'Login to continue your preparation';

  @override
  String get mobileNumber => 'Mobile Number';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get login => 'Login';

  @override
  String get loginWithOtp => 'Continue with OTP';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get register => 'Register';

  @override
  String get createAccount => 'Create account';

  @override
  String get registerSubtitle => 'Start your journey to a government job';

  @override
  String get fullName => 'Full name';

  @override
  String get email => 'Email (optional)';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get targetExam => 'Target exam';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get agreeTerms => 'I agree to the Terms of Service and Privacy Policy';

  @override
  String get errorRequired => 'This field is required';

  @override
  String get errorMobile => 'Enter a valid 10-digit Indian mobile number';

  @override
  String get errorPassword => 'Password must be at least 8 characters';

  @override
  String get errorPasswordMatch => 'Passwords do not match';

  @override
  String get errorEmail => 'Enter a valid email address';

  @override
  String get errorName => 'Enter your full name';

  @override
  String get errorTerms => 'Please accept the terms to continue';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorInvalidCredentials => 'Invalid email/mobile or password';

  @override
  String get errorNetwork =>
      'Cannot reach the ExamGenius server. Check your internet connection and try again.';

  @override
  String get errorMobileTaken =>
      'This mobile number is already registered. Please log in.';

  @override
  String get errorEmailTaken =>
      'This email is already registered. Please log in.';

  @override
  String get errorAiBusy =>
      'AI is busy right now. Please try again in a minute.';

  @override
  String get errorSessionExpired =>
      'Your session expired. Please log in again.';

  @override
  String get proName => 'ExamGenius Pro';

  @override
  String get proTagline => 'Unlimited practice with AI explanations';

  @override
  String get planFree => 'Free';

  @override
  String get planPro => 'Pro';

  @override
  String get myPlan => 'My Plan';

  @override
  String get seePlans => 'See Pro plans';

  @override
  String get upgradeToPro => 'Upgrade to Pro';

  @override
  String get maybeLater => 'Maybe later';

  @override
  String startTrial(int days) {
    return 'Start $days-day free trial';
  }

  @override
  String get trialStarted =>
      'Your Pro trial has started. Enjoy unlimited practice!';

  @override
  String get trialFailed => 'Could not start the trial. Please try again.';

  @override
  String proUntil(String date) {
    return 'Pro until $date';
  }

  @override
  String trialUntil(String date) {
    return 'Free trial until $date';
  }

  @override
  String freeSetsLeft(int left, int total) {
    return '$left of $total free sets left today';
  }

  @override
  String perMonth(int price) {
    return '₹$price/month';
  }

  @override
  String planMonths(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months Months',
      one: '1 Month',
    );
    return '$_temp0';
  }

  @override
  String priceInr(int price) {
    return '₹$price';
  }

  @override
  String savePercent(int percent) {
    return 'Save $percent%';
  }

  @override
  String get mostPopular => 'Most Popular';

  @override
  String choosePlan(String plan) {
    return 'Choose $plan';
  }

  @override
  String get paymentsComingSoon =>
      'Online payment is coming soon. Start the free trial to use Pro now.';

  @override
  String get featureCompare => 'Free vs Pro';

  @override
  String get featurePracticeSets => 'Practice sets';

  @override
  String featureFreeSets(int count) {
    return '$count per day';
  }

  @override
  String get featureUnlimited => 'Unlimited';

  @override
  String get featureQuestionsPerSet => 'Questions per set';

  @override
  String featureUpTo(int count) {
    return 'Up to $count';
  }

  @override
  String get featureReview => 'Scorecard & explanations';

  @override
  String get featureSaved => 'Saved practice';

  @override
  String get featureFreshAi => 'Brand-new AI questions';

  @override
  String get pricesIncludeGst => 'Prices include GST. Cancel anytime.';

  @override
  String get limitDailySetsTitle => 'You have used today\'s free sets';

  @override
  String limitDailySetsBody(int max) {
    return 'Free plan includes $max practice sets per day. New sets unlock at midnight, or go Pro for unlimited practice.';
  }

  @override
  String get limitDailyQuestionsTitle => 'Daily limit reached';

  @override
  String limitDailyQuestionsBody(int max) {
    return 'You have practised $max questions today. Great work! More unlock at midnight.';
  }

  @override
  String get limitSetSizeTitle => 'Bigger sets are a Pro feature';

  @override
  String limitSetSizeBody(int max) {
    return 'Free plan allows up to $max questions per set. Go Pro for sets of up to 30.';
  }

  @override
  String get limitSavedTitle => 'Saved practice is full';

  @override
  String limitSavedBody(int max) {
    return 'Free plan keeps $max saved sets. Delete one or go Pro for unlimited saved practice.';
  }

  @override
  String get limitFreshTitle => 'Brand-new AI questions are Pro';

  @override
  String get limitFreshBody =>
      'Free plan uses our question bank. Go Pro to get freshly generated AI questions every time.';

  @override
  String get freshAiToggle => 'Brand-new AI questions';

  @override
  String get freshAiToggleHint =>
      'Skip the question bank and generate new ones (Pro)';

  @override
  String get proLocked => 'Pro';

  @override
  String get createPractice => 'Create Practice';

  @override
  String get changeExam => 'Change exam';

  @override
  String get stepSubject => 'Subject';

  @override
  String get stepTopics => 'Topics';

  @override
  String get stepLevel => 'Level';

  @override
  String get stepQuestions => 'Questions';

  @override
  String selectedCount(int count) {
    return '$count selected';
  }

  @override
  String subjectWithCount(String name, int count) {
    return '$name ($count)';
  }

  @override
  String practiceSummary(String subjects, int topics, String level, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      topics,
      locale: localeName,
      other: '$topics topics',
      one: '1 topic',
    );
    return '$subjects · $_temp0 · $level · $count Qs';
  }

  @override
  String get selectAtLeastOneTopic => 'Select at least 1 topic to start';

  @override
  String get quick10 => 'Quick 10';

  @override
  String get quick10Hint => 'Mixed from the whole exam';

  @override
  String get lastPractice => 'Last practice';

  @override
  String get lastPracticeHint => 'Repeat your last setup';

  @override
  String get weakTopics => 'Weak Topics';

  @override
  String get weakTopicsHint => 'Focus where you lose marks';

  @override
  String get noLastPractice => 'No previous practice for this exam yet.';

  @override
  String get noWeakTopics =>
      'Practise a few sets first. We will then find your weak topics.';

  @override
  String get quickStart => 'Quick start';

  @override
  String get orBuildYourOwn => 'Or build your own';

  @override
  String get retry => 'Retry';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get comingSoonBody =>
      'This feature is being built and will be available in the next update.';

  @override
  String greeting(String name) {
    return 'Hello, $name';
  }

  @override
  String preparingFor(String exam) {
    return 'Preparing for $exam';
  }

  @override
  String get dailyGoal => 'Today\'s goal';

  @override
  String dailyGoalProgress(int done, int total) {
    return '$done of $total questions';
  }

  @override
  String streakDays(int count) {
    return '$count day streak';
  }

  @override
  String get continuePreparation => 'Continue preparation';

  @override
  String get resume => 'Resume';

  @override
  String get aiGeneratorTitle => 'AI Question Generator';

  @override
  String get aiGeneratorSubtitle => 'Generate exam-level questions instantly';

  @override
  String get generateNow => 'Generate Now';

  @override
  String get quickActions => 'Quick actions';

  @override
  String get mockTests => 'Mock Tests';

  @override
  String get dailyPractice => 'Daily Practice';

  @override
  String get previousYear => 'Previous Year Questions';

  @override
  String get analytics => 'Analytics';

  @override
  String get examCategories => 'Exam categories';

  @override
  String get seeAll => 'See all';

  @override
  String get railwayExams => 'Railway Exams';

  @override
  String get sscExams => 'SSC Exams';

  @override
  String get bankingExams => 'Banking Exams';

  @override
  String examsCount(int count) {
    return '$count exams';
  }

  @override
  String get performance => 'Performance';

  @override
  String get accuracy => 'Accuracy';

  @override
  String get testsTaken => 'Tests taken';

  @override
  String get avgScore => 'Avg score';

  @override
  String get recentResults => 'Recent results';

  @override
  String get noResultsYet => 'No tests attempted yet';

  @override
  String get noResultsBody => 'Take your first mock test to see results here.';

  @override
  String get subscriptionFree => 'Free plan';

  @override
  String subscriptionFreeBody(int left) {
    return '$left AI questions left today';
  }

  @override
  String get upgrade => 'Upgrade';

  @override
  String get navHome => 'Home';

  @override
  String get navSaved => 'Library';

  @override
  String get navPractice => 'Practice';

  @override
  String get navAnalytics => 'Analytics';

  @override
  String get navProfile => 'Profile';

  @override
  String get notifications => 'Notifications';

  @override
  String get profile => 'Profile';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get logout => 'Log out';

  @override
  String get english => 'English';

  @override
  String get hindi => 'हिन्दी';

  @override
  String get orDivider => 'or';

  @override
  String get greetingSubtitle => 'Let\'s prepare smart for your dream job!';

  @override
  String get bookmarks => 'Bookmarks';

  @override
  String get subscription => 'Subscription';

  @override
  String get changeLanguage => 'Change language';

  @override
  String get aiPowered => 'AI Powered';

  @override
  String get startNow => 'Start Now';

  @override
  String get chooseYourExam => 'Choose Your Exam';

  @override
  String get viewAll => 'View All';

  @override
  String get myProgress => 'My Progress';

  @override
  String get prepProgressTitle => 'Your Preparation Progress';

  @override
  String get prepProgressBody => 'Keep going! You are doing great.';

  @override
  String get recentTestResults => 'Recent Test Results';

  @override
  String questionsCount(int count) {
    return '$count Questions';
  }

  @override
  String get goPremium => 'Go Premium';

  @override
  String get goPremiumBody =>
      'Unlock unlimited AI questions, full mock tests & more';

  @override
  String get upgradeNow => 'Upgrade Now';

  @override
  String get menu => 'Menu';

  @override
  String get selectExam => 'Select exam';

  @override
  String get dailyPrepTitle => 'Today\'s Preparation';

  @override
  String get premiumActive => 'Premium active';

  @override
  String get premiumActiveBody => 'Unlimited AI questions and full mock tests';

  @override
  String get selectedExam => 'Selected exam';

  @override
  String get goalComplete => 'Goal complete! Great work.';

  @override
  String get chooseExamPrompt => 'Choose an exam and start your preparation';

  @override
  String get generateQuestions => 'Generate Questions';

  @override
  String get quickAccess => 'Quick access';

  @override
  String get selectExamBody => 'Select the exam you are preparing for';

  @override
  String get currentTarget => 'Current target';

  @override
  String get syllabusTitle => 'Syllabus';

  @override
  String get selectTopics => 'Select topics';

  @override
  String get clear => 'Clear';

  @override
  String subjectsCount(int count) {
    return '$count subjects';
  }

  @override
  String topicsCount(int count) {
    return '$count topics';
  }

  @override
  String topicsSelected(int count) {
    return '$count selected';
  }

  @override
  String get difficultyLevel => 'Difficulty level';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get numberOfQuestions => 'Number of questions';

  @override
  String get generatorIncomplete =>
      'Select topics, difficulty and number of questions';

  @override
  String get generatedQuestionsTitle => 'Practice Questions';

  @override
  String get generatingQuestions => 'AI is preparing exam-level questions…';

  @override
  String get noQuestionsForSelection =>
      'No questions available for this selection yet. Try another topic or level.';

  @override
  String get sampleQuestionsNote =>
      'Preview mode: these are sample exam-level questions. Live AI generation starts once the ExamGenius server is connected.';

  @override
  String fewerQuestionsNote(int available, int requested) {
    return '$available of $requested questions available for this selection';
  }

  @override
  String scoreSoFar(int correct, int attempted) {
    return 'Score: $correct/$attempted';
  }

  @override
  String questionNumber(int number) {
    return 'Q$number';
  }

  @override
  String get correctAnswer => 'Correct!';

  @override
  String get incorrectAnswer => 'Incorrect';

  @override
  String get explanation => 'Explanation';

  @override
  String greetingMorning(String name) {
    return 'Good morning, $name';
  }

  @override
  String greetingAfternoon(String name) {
    return 'Good afternoon, $name';
  }

  @override
  String greetingEvening(String name) {
    return 'Good evening, $name';
  }

  @override
  String get defaultStudentName => 'Aspirant';

  @override
  String get keepLearning => 'Keep learning, keep improving!';

  @override
  String get homeChooseExam => 'Choose your exam';

  @override
  String get railway => 'Railway';

  @override
  String get ssc => 'SSC';

  @override
  String get banking => 'Banking';

  @override
  String get mockTestsSub => 'Full-length & topic tests';

  @override
  String get dailyPracticeSub => 'Small sets, big progress';

  @override
  String get previousYearPapers => 'Previous Year Papers';

  @override
  String get previousYearSub => 'Real exam questions';

  @override
  String get more => 'More';

  @override
  String get aiLabel => 'AI';

  @override
  String get doneButton => 'Done';

  @override
  String get singleSelection => 'Single';

  @override
  String get multipleSelection => 'Multiple';

  @override
  String get selectionType => 'Selection type';

  @override
  String get singleSelectionHint => 'Choose one topic';

  @override
  String get multipleSelectionHint => 'Choose one or more topics';

  @override
  String get selectAll => 'Select all';

  @override
  String get emailOrMobile => 'Email or Mobile Number';

  @override
  String get errorEmailOrMobile =>
      'Enter a valid email or 10-digit mobile number';

  @override
  String get rememberMe => 'Remember Me';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get loginHeadlinePrepare => 'Prepare';

  @override
  String get loginHeadlineSmarter => 'smarter.';

  @override
  String get loginHeadlineAchieve => 'Achieve';

  @override
  String get loginHeadlineMore => 'more.';

  @override
  String get loginTagline =>
      'Your Railway, SSC & Banking preparation starts here.';

  @override
  String get signUp => 'Sign Up';

  @override
  String get continueWithMobileOtp => 'Continue with Mobile OTP';

  @override
  String get forgotTitle => 'Forgot Password?';

  @override
  String get forgotSubtitle =>
      'Enter your registered email or mobile number. We will send you a reset link or OTP.';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get rememberPassword => 'Remember your password?';

  @override
  String get resetSentTitle => 'Check your inbox';

  @override
  String resetSentBody(String target) {
    return 'We have sent password reset instructions to $target';
  }

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get didntReceive => 'Didn\'t receive it?';

  @override
  String get resend => 'Resend';

  @override
  String get resetSecureNote =>
      'For your security, the link expires in 15 minutes.';

  @override
  String questionOfTotal(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String answeredOfTotal(int answered, int total) {
    return '$answered/$total answered';
  }

  @override
  String get previousQuestion => 'Previous';

  @override
  String get nextQuestion => 'Next';

  @override
  String get clearAnswer => 'Clear Answer';

  @override
  String get questionPalette => 'Question Palette';

  @override
  String get paletteAnswered => 'Answered';

  @override
  String get paletteNotAnswered => 'Not Answered';

  @override
  String get paletteCurrent => 'Current';

  @override
  String get submitTest => 'Submit Test';

  @override
  String answerAllToSubmit(int left) {
    return 'Answer all questions to enable Submit ($left left)';
  }

  @override
  String get allAnsweredReady => 'All questions answered. You can submit now.';

  @override
  String timeLeftLabel(String time) {
    return 'Time left $time';
  }

  @override
  String get timeUpSubmitting => 'Time is up! Submitting your test…';

  @override
  String get leaveTestTitle => 'Leave this test?';

  @override
  String get leaveTestBody => 'Your answers will not be saved.';

  @override
  String get leaveTest => 'Leave';

  @override
  String get continueTest => 'Continue Test';

  @override
  String get selectOptionHint => 'Select one option';

  @override
  String get submitConfirmTitle => 'Submit Test';

  @override
  String get submitConfirmBody => 'Are you sure you want to submit your test?';

  @override
  String get totalQuestions => 'Total Questions';

  @override
  String get answeredQuestions => 'Answered';

  @override
  String get unansweredQuestions => 'Unanswered';

  @override
  String get timeRemaining => 'Time Remaining';

  @override
  String get submitWarningUnanswered => 'Unanswered questions get 0 marks.';

  @override
  String get submitNoChanges => 'You cannot change answers after submitting.';

  @override
  String get cancel => 'Cancel';

  @override
  String get submittingTest => 'Submitting your test…';

  @override
  String get submitFailed =>
      'Could not submit your test. Check your connection and try again.';

  @override
  String get testCompleted => 'Test Completed';

  @override
  String get finalScore => 'Final Score';

  @override
  String get correctAnswers => 'Correct';

  @override
  String get incorrectAnswers => 'Incorrect';

  @override
  String get backToDashboard => 'Back to Dashboard';

  @override
  String get autoSubmittedNote =>
      'Time ran out, so your test was submitted automatically.';

  @override
  String get congratulations => 'Congratulations!';

  @override
  String completedOn(String date) {
    return 'Completed on $date';
  }

  @override
  String get unattempted => 'Unattempted';

  @override
  String get accuracyLabel => 'Accuracy';

  @override
  String scoreOutOf(String max) {
    return 'out of $max';
  }

  @override
  String get markingScheme => '+1 correct · −0.25 incorrect · 0 unattempted';

  @override
  String get answerBreakdown => 'Correct vs Incorrect';

  @override
  String get timeTaken => 'Time Taken';

  @override
  String get avgPerQuestion => 'Avg per Question';

  @override
  String get performanceAnalysis => 'Performance Analysis';

  @override
  String get strongTopics => 'Strong Topics';

  @override
  String get quickWeakTopics => 'Weak topics';

  @override
  String get noneYet => 'None yet';

  @override
  String get topicWiseAccuracy => 'Topic-wise Accuracy';

  @override
  String topicScore(int correct, int total) {
    return '$correct/$total correct';
  }

  @override
  String get recommendedPractice => 'Recommended Practice';

  @override
  String recommendRevise(String topic, int correct, int total) {
    return 'Revise $topic: you got $correct of $total right. Practise it again at the same level.';
  }

  @override
  String get recommendNextLevel =>
      'Great work! Try the next difficulty level to keep improving.';

  @override
  String get recommendKeepGoing =>
      'Good effort! Review the explanations and practise your mistakes once more.';

  @override
  String get reviewAnswers => 'Review Answers';

  @override
  String get savePractice => 'Save Practice';

  @override
  String get retryWrong => 'Retry Wrong Questions';

  @override
  String get reviewTitle => 'Answer Review';

  @override
  String get filterAll => 'All';

  @override
  String filterWithCount(String label, int count) {
    return '$label ($count)';
  }

  @override
  String get yourAnswer => 'Your answer';

  @override
  String get correctAnswerLabel => 'Correct answer';

  @override
  String get notAnswered => 'Not answered';

  @override
  String get statusCorrect => 'Correct';

  @override
  String get statusIncorrect => 'Incorrect';

  @override
  String get statusUnattempted => 'Unattempted';

  @override
  String get whyCorrect => 'Why this is correct';

  @override
  String get whyWrong => 'Why your answer was wrong';

  @override
  String wrongChoiceNote(String yours, String correct) {
    return 'You chose $yours, but the correct answer is $correct.';
  }

  @override
  String unattemptedNote(String correct) {
    return 'You skipped this question. The correct answer is $correct.';
  }

  @override
  String get explanationTitle => 'Explanation';

  @override
  String get stepByStep => 'Step-by-step Solution';

  @override
  String get formulaTitle => 'Formula';

  @override
  String get conceptTitle => 'Short Concept';

  @override
  String get tipTitle => 'Learning Tip';

  @override
  String stepLabel(int n) {
    return 'Step $n';
  }

  @override
  String get noReviewItems => 'No questions in this filter.';

  @override
  String optionCorrectLabel(String letter, String text) {
    return 'Option $letter, correct answer: $text';
  }

  @override
  String optionWrongLabel(String letter, String text) {
    return 'Option $letter, your wrong answer: $text';
  }

  @override
  String get noWrongToRetry => 'No wrong answers to retry. Great job!';

  @override
  String get savingPractice => 'Saving…';

  @override
  String get practiceSaved => 'Saved to My Practice';

  @override
  String get saveSuccess =>
      'Practice saved with all questions, answers, explanations and your scorecard.';

  @override
  String get saveFailed =>
      'Could not save your practice. Check your connection and try again.';

  @override
  String get mySavedPractice => 'My Saved Practice';

  @override
  String get viewAction => 'View';

  @override
  String get savedEmptyTitle => 'Your Library is empty';

  @override
  String get savedEmptyBody =>
      'After a test, tap Save Practice on the scorecard to keep it here for revision.';

  @override
  String savedOn(String date) {
    return 'Saved $date';
  }

  @override
  String questionsShort(int count) {
    return '$count Qs';
  }

  @override
  String get reviewPractice => 'Review';

  @override
  String get practiceAgain => 'Practice Again';

  @override
  String get retryWrongShort => 'Retry Wrong';

  @override
  String get deletePractice => 'Delete';

  @override
  String get deletePracticeTitle => 'Delete this practice?';

  @override
  String get deletePracticeBody =>
      'This practice set, its attempt history, bookmarks and notes will be permanently removed.';

  @override
  String get practiceDeleted => 'Practice deleted.';

  @override
  String get deleteFailed =>
      'Could not delete. Check your connection and try again.';

  @override
  String get scoreLabel => 'Score';

  @override
  String get moreActions => 'More actions';

  @override
  String accuracyChartLabel(String percent) {
    return 'Accuracy $percent';
  }

  @override
  String optionLabel(String letter, String text) {
    return 'Option $letter: $text';
  }

  @override
  String get orUpper => 'OR';

  @override
  String get myLibrary => 'My Learning Library';

  @override
  String get libraryStatSets => 'Practice sets';

  @override
  String get libraryStatQuestions => 'Questions';

  @override
  String get libraryStatNotes => 'Notes';

  @override
  String get libraryCategories => 'Your libraries';

  @override
  String librarySetsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sets',
      one: '1 set',
      zero: 'No sets yet',
    );
    return '$_temp0';
  }

  @override
  String get recentPracticeSets => 'Recently generated';

  @override
  String get libraryEmptyTitle => 'Your Library is empty';

  @override
  String get libraryEmptyBody =>
      'Every practice set you generate is saved here automatically, with its questions, answers and explanations.';

  @override
  String categoryLibraryTitle(String category) {
    return '$category Library';
  }

  @override
  String categoryEmptyTitle(String category) {
    return 'No $category practice yet';
  }

  @override
  String get categoryEmptyBody =>
      'Generate a practice set for an exam in this category and it will appear here.';

  @override
  String get noMatchingSets => 'No practice sets match these filters';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get searchSetsHint => 'Search exam, subject or topic';

  @override
  String get filterExam => 'Exam';

  @override
  String get filterSubject => 'Subject';

  @override
  String get filterTopic => 'Topic';

  @override
  String get filterDifficulty => 'Difficulty';

  @override
  String get filterLanguage => 'Language';

  @override
  String get filterDate => 'Date';

  @override
  String get filterAny => 'All';

  @override
  String get sortLatest => 'Latest first';

  @override
  String get sortOldest => 'Oldest first';

  @override
  String get dateLast7 => 'Last 7 days';

  @override
  String get dateLast30 => 'Last 30 days';

  @override
  String get dateCustom => 'Choose dates…';

  @override
  String get dateAny => 'Any time';

  @override
  String get notAttempted => 'Not attempted';

  @override
  String attemptsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count attempts',
      one: '1 attempt',
    );
    return '$_temp0';
  }

  @override
  String get latestScore => 'Latest score';

  @override
  String get viewHistory => 'History';

  @override
  String get attemptFirstToReview =>
      'Attempt this set first — answers and explanations unlock after you submit.';

  @override
  String get loadMore => 'Load more';

  @override
  String get savedToLibrary => 'Saved to your Library automatically';

  @override
  String get openLibrary => 'Open Library';

  @override
  String get openingPractice => 'Opening practice…';

  @override
  String get aiStudyNotes => 'AI Study Notes';

  @override
  String get aiStudyNotesSub => 'Understand every topic with AI-powered notes.';

  @override
  String get notesChooseCategory => 'Choose a category';

  @override
  String get notesChooseCategoryBody =>
      'Pick your exam category, then an exam and a topic to study.';

  @override
  String get notesChooseTopic => 'Choose a topic';

  @override
  String notesChooseTopicBody(String exam) {
    return 'Pick one topic from the $exam syllabus to create notes.';
  }

  @override
  String get createNotesTitle => 'Create Notes';

  @override
  String get notesExam => 'Exam';

  @override
  String get notesSubject => 'Subject';

  @override
  String get notesTopic => 'Topic';

  @override
  String get notesLevel => 'Explanation level';

  @override
  String get noteLevelBasic => 'Basic';

  @override
  String get noteLevelExam => 'Exam Standard';

  @override
  String get noteLevelAdvanced => 'Advanced';

  @override
  String get notesSections => 'Include in your notes';

  @override
  String get notesSectionsReset => 'Reset';

  @override
  String get secExplanation => 'Detailed concept explanation';

  @override
  String get secDefinitions => 'Definitions';

  @override
  String get secExamples => 'Real-life examples';

  @override
  String get secStepByStep => 'Step-by-step explanations';

  @override
  String get secDiagrams => 'Diagrams & flowcharts';

  @override
  String get secGraphs => 'Graphs (where useful)';

  @override
  String get secFormulas => 'Formulas & tables';

  @override
  String get secTips => 'Exam tips & tricks';

  @override
  String get secMistakes => 'Common mistakes';

  @override
  String get secKeyPoints => 'Important exam points';

  @override
  String get secRevision => 'Quick revision notes';

  @override
  String get secMcqs => 'Topic MCQs with explanations';

  @override
  String get notesPickOneSection => 'Select at least one section.';

  @override
  String get generateNotes => 'Generate Complete Notes';

  @override
  String get generatingNotes =>
      'Writing your notes… this can take up to a minute.';

  @override
  String get notesFailed => 'Notes could not be generated. Nothing was saved.';

  @override
  String get notesSaved => 'Saved to your Library';

  @override
  String get notesContents => 'Contents';

  @override
  String get nOverview => 'Topic Overview';

  @override
  String get nDetailed => 'Detailed Explanation';

  @override
  String get nConcepts => 'Important Concepts';

  @override
  String get nExamples => 'Examples';

  @override
  String get nDiagrams => 'Diagrams, Flowcharts & Graphs';

  @override
  String get nFormulas => 'Formulas & Tables';

  @override
  String get nTips => 'Exam Tips & Tricks';

  @override
  String get nMistakes => 'Common Mistakes';

  @override
  String get nKeyPoints => 'Important Exam Points';

  @override
  String get nRevision => 'Quick Revision';

  @override
  String get nMcqs => 'Important Questions & MCQs';

  @override
  String get nNext => 'What to Study Next';

  @override
  String noteStep(int n) {
    return 'Step $n';
  }

  @override
  String noteAnswer(String answer) {
    return 'Answer: $answer';
  }

  @override
  String get noteShowAnswer => 'Show answer';

  @override
  String get noteHideAnswer => 'Hide answer';

  @override
  String get noteNotFound => 'This note could not be opened.';

  @override
  String get noteExpandAll => 'Expand all';

  @override
  String get noteCollapseAll => 'Collapse all';

  @override
  String get myPracticeSets => 'My Practice Sets';

  @override
  String get myStudyNotes => 'My Study Notes';

  @override
  String notesLibraryTitle(String category) {
    return '$category Notes';
  }

  @override
  String notesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes',
      one: '1 note',
      zero: 'No notes yet',
    );
    return '$_temp0';
  }

  @override
  String get searchNotesHint => 'Search by topic, subject or exam';

  @override
  String notesEmptyTitle(String category) {
    return 'No $category notes yet';
  }

  @override
  String get notesEmptyBody =>
      'Create AI Study Notes for any topic and they are saved here automatically.';

  @override
  String get noMatchingNotes => 'No notes match these filters';

  @override
  String get createNotesCta => 'Create notes';

  @override
  String noteCreatedOn(String date) {
    return 'Created $date';
  }

  @override
  String get noteBookmark => 'Bookmark';

  @override
  String get noteRemoveBookmark => 'Remove bookmark';

  @override
  String get noteBookmarked => 'Note bookmarked';

  @override
  String get noteUnbookmarked => 'Bookmark removed';

  @override
  String get noteMoreActions => 'More actions';

  @override
  String get personalNote => 'Personal note';

  @override
  String get personalNoteHint => 'Write your own points, shortcuts or doubts…';

  @override
  String get personalNoteAdd => 'Add personal note';

  @override
  String get personalNoteEdit => 'Edit';

  @override
  String get personalNoteSaved => 'Personal note saved';

  @override
  String get noteSave => 'Save';

  @override
  String get noteDelete => 'Delete note';

  @override
  String get noteDeleteTitle => 'Delete this note?';

  @override
  String get noteDeleteBody =>
      'This note and your personal note on it will be permanently removed.';

  @override
  String get noteDeleted => 'Note deleted';

  @override
  String get quickRevision => 'Quick revision';

  @override
  String get flashcards => 'Flashcards';

  @override
  String get flashcardTapToFlip => 'Tap the card to see the answer';

  @override
  String flashcardCount(int n, int total) {
    return '$n / $total';
  }

  @override
  String get flashcardPrev => 'Previous';

  @override
  String get flashcardNext => 'Next';

  @override
  String get noFlashcards =>
      'This note has no concepts or formulas to turn into flashcards.';

  @override
  String get noRevision => 'This note has no revision points.';

  @override
  String get notesViewAll => 'All';

  @override
  String get notesViewBookmarked => 'Bookmarked';

  @override
  String get notesViewPersonal => 'Personal notes';

  @override
  String get noBookmarkedNotes => 'No bookmarked notes here yet';

  @override
  String get noBookmarkedNotesBody =>
      'Tap the bookmark icon on a note to keep it here.';

  @override
  String get noPersonalNotes => 'No personal notes here yet';

  @override
  String get noPersonalNotesBody =>
      'Open a note and add your own points — they will appear here.';

  @override
  String get historyTitle => 'Practice history';

  @override
  String get historyEmpty =>
      'No attempts yet. Practise this set to build its history.';

  @override
  String historyAttempt(int n) {
    return 'Attempt $n';
  }

  @override
  String historyLine(String score, String max, String percent) {
    return 'Score $score/$max · Accuracy $percent';
  }

  @override
  String get learningPath => 'Learning path';

  @override
  String get openLearningPath => 'Learning path';

  @override
  String learningPathProgress(int done, int total) {
    return '$done of $total topics completed';
  }

  @override
  String learningTopicPosition(int n, int total) {
    return 'Topic $n of $total';
  }

  @override
  String get markCompleted => 'Mark as completed';

  @override
  String get markedCompleted => 'Marked as completed';

  @override
  String get markedNotCompleted => 'Marked as not completed';

  @override
  String get continueNextTopic => 'Continue to Next Topic';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCurrent => 'Current';

  @override
  String get statusUpcoming => 'Upcoming';

  @override
  String get notesReady => 'Notes ready';

  @override
  String get allTopicsCompleted => 'All topics completed — great work!';

  @override
  String get nextTopicHint => 'Tap a topic to create its notes';

  @override
  String get errorAiQuota =>
      'Today\'s AI limit has been reached. Your selection is kept — please try again later.';

  @override
  String get sampleContentLabel =>
      'Development sample — placeholder content. Not AI-generated, not verified study material.';

  @override
  String get outlineDraft => 'Draft outline — under review';

  @override
  String outlineProgress(int done, int total) {
    return '$done of $total sections completed';
  }

  @override
  String get outlineContinue => 'Continue';

  @override
  String get outlineCoverageComplete => 'All sections completed';

  @override
  String get learningModeQuick => 'Quick revision';

  @override
  String get learningModeDetailed => 'Detailed';

  @override
  String get learningModeComplete => 'Complete prep';

  @override
  String get sectionStatePending => 'Not started';

  @override
  String get sectionStateGenerated => 'Ready to read';

  @override
  String get sectionStateCompleted => 'Completed';

  @override
  String get sectionStateFailed => 'Could not load — tap to retry';

  @override
  String get sectionRecommended => 'Recommended';

  @override
  String get sectionAiSuggested => 'AI-suggested';

  @override
  String get sectionOftenTested => 'Often tested';

  @override
  String get sectionPreparing => 'Preparing this section…';

  @override
  String get sectionMarkComplete => 'Mark complete';

  @override
  String get sectionMarkedComplete => 'Completed';

  @override
  String get sectionPrevious => 'Previous';

  @override
  String get sectionNext => 'Next';

  @override
  String sectionOf(int index, int total) {
    return 'Section $index of $total';
  }

  @override
  String get limitDailyAiTitle => 'Today\'s AI set is used';

  @override
  String limitDailyAiBody(int max) {
    return 'Your plan includes $max AI-generated practice set(s) per day. You can still practise from the Question Bank, or go Premium for more AI sets.';
  }

  @override
  String get limitAiNotInPlanTitle => 'AI questions are a Premium feature';

  @override
  String get limitAiNotInPlanBody =>
      'Your plan uses the Question Bank. Go Premium for freshly generated AI questions.';

  @override
  String get planBadgeFree => 'FREE';

  @override
  String get planBadgePro => 'PREMIUM';

  @override
  String get practiceTypeTitle => 'Practice type';

  @override
  String get practiceTypeQuick => 'Quick Practice';

  @override
  String get practiceTypeQuickHint =>
      'Mixed questions across this exam\'s subjects';

  @override
  String get practiceTypeTopics => 'Topic-wise';

  @override
  String get practiceTypeTopicsHint => 'Choose subjects and topics';

  @override
  String get questionSourceTitle => 'Question source';

  @override
  String get sourceBank => 'Question Bank';

  @override
  String get sourceBankHint => 'Stored practice questions';

  @override
  String get sourceAi => 'AI-Generated';

  @override
  String get sourceAiHint => 'Fresh questions for you';

  @override
  String get sourceAiNote =>
      'AI-generated practice questions — not previous-year papers.';

  @override
  String usageSetsLeft(int left, int total) {
    return '$left of $total practice sets left today';
  }

  @override
  String usageQuestionsLeft(int left) {
    return '$left questions left today (fair use)';
  }

  @override
  String aiCreditsLeft(int left) {
    return 'AI sets left today: $left';
  }

  @override
  String get aiCreditsIncluded => 'AI sets included';

  @override
  String startPracticeCount(int count) {
    return 'Start Practice – $count Questions';
  }

  @override
  String generateAiCount(int count) {
    return 'Generate AI Questions – $count Questions';
  }

  @override
  String get searchTopics => 'Search topics';

  @override
  String get noTopicsMatch => 'No topics match your search';

  @override
  String get customCount => 'Custom';

  @override
  String get customCountTitle => 'Number of questions';

  @override
  String customCountHint(int max) {
    return 'Between 1 and $max';
  }

  @override
  String get apply => 'Apply';

  @override
  String get bankInsufficientTitle => 'Not enough stored questions';

  @override
  String bankInsufficientBody(int available, int requested) {
    return 'Only $available stored questions match your selection. You asked for $requested.';
  }

  @override
  String get bankNoneBody => 'No stored questions match your selection yet.';

  @override
  String bankUseAvailable(int available) {
    return 'Practise $available questions';
  }

  @override
  String get bankUseAi => 'Use AI-generated questions';

  @override
  String get changeSelection => 'Change selection';

  @override
  String lastPracticeDetails(int count, String level) {
    return '$count questions · $level';
  }

  @override
  String get questionsLabel => 'Questions';

  @override
  String get aiQuestionsBadge => 'AI-generated';

  @override
  String get bankQuestionsBadge => 'Question Bank';

  @override
  String get nObjectives => 'Learning Objectives';

  @override
  String get nTimeline => 'Timeline';

  @override
  String get nSql => 'SQL Examples';

  @override
  String get nSqlOutput => 'Expected output';

  @override
  String get nDerivations => 'Derivations';

  @override
  String get nKeyFacts => 'Important Facts';

  @override
  String get nPractice => 'Practice Exercises';

  @override
  String get nRelated => 'Related Concepts';

  @override
  String get nFurther => 'Further learning';

  @override
  String get showAnswer => 'Show answer';

  @override
  String get treeNextRecommended => 'Next recommended';

  @override
  String treeSectionsProgress(int done, int total) {
    return '$done of $total sections studied';
  }

  @override
  String treeContentReady(int ready, int total) {
    return 'Content ready: $ready of $total';
  }

  @override
  String get contentReady => 'Content ready';

  @override
  String get contentNotGenerated => 'Not prepared yet';

  @override
  String get contentGenerating => 'Being prepared';

  @override
  String get contentIncomplete => 'Incomplete — retry';

  @override
  String get contentFailed => 'Could not be prepared';

  @override
  String get progressStudied => 'Studied';

  @override
  String outlineContentCoverage(int ready, int total) {
    return 'Content coverage: $ready of $total sections ready';
  }

  @override
  String outlineYourProgress(int done, int total) {
    return 'Your progress: $done of $total sections studied';
  }

  @override
  String get sectionGeneratingTitle => 'This section is being prepared';

  @override
  String get sectionGeneratingBody =>
      'It is being prepared right now. Check again in a few seconds.';

  @override
  String get checkAgain => 'Check again';

  @override
  String get errorContentIncomplete =>
      'This section could not be completed to our quality standard yet. Nothing was saved — please try again.';

  @override
  String sectionMissingList(String items) {
    return 'Still missing: $items';
  }

  @override
  String get statusAiChecked => 'AI-checked · not human-reviewed';

  @override
  String get statusReviewed => 'Reviewed by an expert';

  @override
  String get statusUnderReview => 'Preview — awaiting review';

  @override
  String get statusFactsUnverified => 'Facts not independently verified';

  @override
  String get statusStructureOnly =>
      'Checked for structure only (no coverage list yet)';

  @override
  String get draftLabel => 'Draft';

  @override
  String get recContinue => 'Continue where you left off';

  @override
  String get recRevise => 'Revise these topics';

  @override
  String recAccuracy(int pct, int attempted) {
    return '$pct% accuracy in practice ($attempted questions)';
  }

  @override
  String get recStudyFirst => 'Study the notes';

  @override
  String get recReviseNotes => 'Revise the notes';

  @override
  String progressTopicsDone(int done, int total) {
    return '$done of $total topics completed';
  }

  @override
  String prepTitle(String category) {
    return '$category Preparation';
  }

  @override
  String get stepExam => 'Examination';

  @override
  String get chooseSubjectFirst => 'Choose a subject to see its topics';

  @override
  String get clearTopics => 'Clear';

  @override
  String showAllTopics(int count) {
    return 'Show all ($count)';
  }

  @override
  String get showFewer => 'Show fewer';

  @override
  String get moreQuestionsPremium =>
      '20, 30 and 40 questions per set are available with Premium.';

  @override
  String get conceptSearchHint => 'Search chapters and concepts';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get conceptNoMatch => 'No chapter or concept matches your search.';

  @override
  String get expand => 'Expand';

  @override
  String get collapse => 'Collapse';

  @override
  String get stepConcepts => 'Chapters & concepts';

  @override
  String conceptsSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count concepts',
      one: '1 concept',
    );
    return '$_temp0';
  }

  @override
  String get selectConceptHint => 'Select at least one chapter or concept';

  @override
  String get notesExactConcept => 'Choose an exact concept';

  @override
  String get notesExactConceptBody =>
      'Notes for one chapter, topic or concept of Railway Mathematics';

  @override
  String get notesConceptPickerTitle => 'Mathematics concepts';

  @override
  String get syllabusUnverifiedNote =>
      'Syllabus built from exam-preparation sources; official verification pending.';

  @override
  String get summaryAll => 'all';

  @override
  String summaryMore(int count) {
    return '+$count more';
  }
}
