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
  String get errorInvalidCredentials => 'Invalid mobile number or password';

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
  String get navTests => 'Tests';

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
  String get weakTopics => 'Weak Topics';

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
  String accuracyChartLabel(String percent) {
    return 'Accuracy $percent';
  }

  @override
  String optionLabel(String letter, String text) {
    return 'Option $letter: $text';
  }

  @override
  String get orUpper => 'OR';
}
