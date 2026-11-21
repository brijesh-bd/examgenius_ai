import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'ExamGenius AI'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Your Bridge to Government Success'**
  String get appTagline;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get chooseLanguage;

  /// No description provided for @chooseLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can change this anytime from your profile.'**
  String get chooseLanguageSubtitle;

  /// No description provided for @onboarding1Title.
  ///
  /// In en, this message translates to:
  /// **'AI-Powered Practice'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Body.
  ///
  /// In en, this message translates to:
  /// **'Get exam-level questions instantly with the power of AI'**
  String get onboarding1Body;

  /// No description provided for @onboarding2Title.
  ///
  /// In en, this message translates to:
  /// **'Mock Tests'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Body.
  ///
  /// In en, this message translates to:
  /// **'Full-length and topic-wise tests with real exam pattern'**
  String get onboarding2Body;

  /// No description provided for @onboarding3Title.
  ///
  /// In en, this message translates to:
  /// **'Performance Analytics'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Body.
  ///
  /// In en, this message translates to:
  /// **'Track accuracy, find weak chapters and improve every day'**
  String get onboarding3Body;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Login to continue your preparation'**
  String get loginSubtitle;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loginWithOtp.
  ///
  /// In en, this message translates to:
  /// **'Continue with OTP'**
  String get loginWithOtp;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start your journey to a government job'**
  String get registerSubtitle;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get email;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @targetExam.
  ///
  /// In en, this message translates to:
  /// **'Target exam'**
  String get targetExam;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @agreeTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms of Service and Privacy Policy'**
  String get agreeTerms;

  /// No description provided for @errorRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get errorRequired;

  /// No description provided for @errorMobile.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 10-digit Indian mobile number'**
  String get errorMobile;

  /// No description provided for @errorPassword.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get errorPassword;

  /// No description provided for @errorPasswordMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get errorPasswordMatch;

  /// No description provided for @errorEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get errorEmail;

  /// No description provided for @errorName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get errorName;

  /// No description provided for @errorTerms.
  ///
  /// In en, this message translates to:
  /// **'Please accept the terms to continue'**
  String get errorTerms;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid mobile number or password'**
  String get errorInvalidCredentials;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @comingSoonBody.
  ///
  /// In en, this message translates to:
  /// **'This feature is being built and will be available in the next update.'**
  String get comingSoonBody;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String greeting(String name);

  /// No description provided for @preparingFor.
  ///
  /// In en, this message translates to:
  /// **'Preparing for {exam}'**
  String preparingFor(String exam);

  /// No description provided for @dailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Today\'s goal'**
  String get dailyGoal;

  /// No description provided for @dailyGoalProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} questions'**
  String dailyGoalProgress(int done, int total);

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{count} day streak'**
  String streakDays(int count);

  /// No description provided for @continuePreparation.
  ///
  /// In en, this message translates to:
  /// **'Continue preparation'**
  String get continuePreparation;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @aiGeneratorTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Question Generator'**
  String get aiGeneratorTitle;

  /// No description provided for @aiGeneratorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Generate exam-level questions instantly'**
  String get aiGeneratorSubtitle;

  /// No description provided for @generateNow.
  ///
  /// In en, this message translates to:
  /// **'Generate Now'**
  String get generateNow;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quickActions;

  /// No description provided for @mockTests.
  ///
  /// In en, this message translates to:
  /// **'Mock Tests'**
  String get mockTests;

  /// No description provided for @dailyPractice.
  ///
  /// In en, this message translates to:
  /// **'Daily Practice'**
  String get dailyPractice;

  /// No description provided for @previousYear.
  ///
  /// In en, this message translates to:
  /// **'Previous Year Questions'**
  String get previousYear;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @examCategories.
  ///
  /// In en, this message translates to:
  /// **'Exam categories'**
  String get examCategories;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @railwayExams.
  ///
  /// In en, this message translates to:
  /// **'Railway Exams'**
  String get railwayExams;

  /// No description provided for @sscExams.
  ///
  /// In en, this message translates to:
  /// **'SSC Exams'**
  String get sscExams;

  /// No description provided for @bankingExams.
  ///
  /// In en, this message translates to:
  /// **'Banking Exams'**
  String get bankingExams;

  /// No description provided for @examsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} exams'**
  String examsCount(int count);

  /// No description provided for @performance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get performance;

  /// No description provided for @accuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get accuracy;

  /// No description provided for @testsTaken.
  ///
  /// In en, this message translates to:
  /// **'Tests taken'**
  String get testsTaken;

  /// No description provided for @avgScore.
  ///
  /// In en, this message translates to:
  /// **'Avg score'**
  String get avgScore;

  /// No description provided for @recentResults.
  ///
  /// In en, this message translates to:
  /// **'Recent results'**
  String get recentResults;

  /// No description provided for @noResultsYet.
  ///
  /// In en, this message translates to:
  /// **'No tests attempted yet'**
  String get noResultsYet;

  /// No description provided for @noResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Take your first mock test to see results here.'**
  String get noResultsBody;

  /// No description provided for @subscriptionFree.
  ///
  /// In en, this message translates to:
  /// **'Free plan'**
  String get subscriptionFree;

  /// No description provided for @subscriptionFreeBody.
  ///
  /// In en, this message translates to:
  /// **'{left} AI questions left today'**
  String subscriptionFreeBody(int left);

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navTests.
  ///
  /// In en, this message translates to:
  /// **'Tests'**
  String get navTests;

  /// No description provided for @navPractice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get navPractice;

  /// No description provided for @navAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get navAnalytics;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get hindi;

  /// No description provided for @orDivider.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orDivider;

  /// No description provided for @greetingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s prepare smart for your dream job!'**
  String get greetingSubtitle;

  /// No description provided for @bookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get bookmarks;

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get changeLanguage;

  /// No description provided for @aiPowered.
  ///
  /// In en, this message translates to:
  /// **'AI Powered'**
  String get aiPowered;

  /// No description provided for @startNow.
  ///
  /// In en, this message translates to:
  /// **'Start Now'**
  String get startNow;

  /// No description provided for @chooseYourExam.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Exam'**
  String get chooseYourExam;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @myProgress.
  ///
  /// In en, this message translates to:
  /// **'My Progress'**
  String get myProgress;

  /// No description provided for @prepProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Preparation Progress'**
  String get prepProgressTitle;

  /// No description provided for @prepProgressBody.
  ///
  /// In en, this message translates to:
  /// **'Keep going! You are doing great.'**
  String get prepProgressBody;

  /// No description provided for @recentTestResults.
  ///
  /// In en, this message translates to:
  /// **'Recent Test Results'**
  String get recentTestResults;

  /// No description provided for @questionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Questions'**
  String questionsCount(int count);

  /// No description provided for @goPremium.
  ///
  /// In en, this message translates to:
  /// **'Go Premium'**
  String get goPremium;

  /// No description provided for @goPremiumBody.
  ///
  /// In en, this message translates to:
  /// **'Unlock unlimited AI questions, full mock tests & more'**
  String get goPremiumBody;

  /// No description provided for @upgradeNow.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Now'**
  String get upgradeNow;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @selectExam.
  ///
  /// In en, this message translates to:
  /// **'Select exam'**
  String get selectExam;

  /// No description provided for @dailyPrepTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Preparation'**
  String get dailyPrepTitle;

  /// No description provided for @premiumActive.
  ///
  /// In en, this message translates to:
  /// **'Premium active'**
  String get premiumActive;

  /// No description provided for @premiumActiveBody.
  ///
  /// In en, this message translates to:
  /// **'Unlimited AI questions and full mock tests'**
  String get premiumActiveBody;

  /// No description provided for @selectedExam.
  ///
  /// In en, this message translates to:
  /// **'Selected exam'**
  String get selectedExam;

  /// No description provided for @goalComplete.
  ///
  /// In en, this message translates to:
  /// **'Goal complete! Great work.'**
  String get goalComplete;

  /// No description provided for @chooseExamPrompt.
  ///
  /// In en, this message translates to:
  /// **'Choose an exam and start your preparation'**
  String get chooseExamPrompt;

  /// No description provided for @generateQuestions.
  ///
  /// In en, this message translates to:
  /// **'Generate Questions'**
  String get generateQuestions;

  /// No description provided for @quickAccess.
  ///
  /// In en, this message translates to:
  /// **'Quick access'**
  String get quickAccess;

  /// No description provided for @selectExamBody.
  ///
  /// In en, this message translates to:
  /// **'Select the exam you are preparing for'**
  String get selectExamBody;

  /// No description provided for @currentTarget.
  ///
  /// In en, this message translates to:
  /// **'Current target'**
  String get currentTarget;

  /// No description provided for @syllabusTitle.
  ///
  /// In en, this message translates to:
  /// **'Syllabus'**
  String get syllabusTitle;

  /// No description provided for @selectTopics.
  ///
  /// In en, this message translates to:
  /// **'Select topics'**
  String get selectTopics;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @subjectsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} subjects'**
  String subjectsCount(int count);

  /// No description provided for @topicsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} topics'**
  String topicsCount(int count);

  /// No description provided for @topicsSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String topicsSelected(int count);

  /// No description provided for @difficultyLevel.
  ///
  /// In en, this message translates to:
  /// **'Difficulty level'**
  String get difficultyLevel;

  /// No description provided for @difficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficultyEasy;

  /// No description provided for @difficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get difficultyMedium;

  /// No description provided for @difficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficultyHard;

  /// No description provided for @numberOfQuestions.
  ///
  /// In en, this message translates to:
  /// **'Number of questions'**
  String get numberOfQuestions;

  /// No description provided for @generatorIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Select topics, difficulty and number of questions'**
  String get generatorIncomplete;

  /// No description provided for @generatedQuestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice Questions'**
  String get generatedQuestionsTitle;

  /// No description provided for @generatingQuestions.
  ///
  /// In en, this message translates to:
  /// **'AI is preparing exam-level questions…'**
  String get generatingQuestions;

  /// No description provided for @noQuestionsForSelection.
  ///
  /// In en, this message translates to:
  /// **'No questions available for this selection yet. Try another topic or level.'**
  String get noQuestionsForSelection;

  /// No description provided for @sampleQuestionsNote.
  ///
  /// In en, this message translates to:
  /// **'Preview mode: these are sample exam-level questions. Live AI generation starts once the ExamGenius server is connected.'**
  String get sampleQuestionsNote;

  /// No description provided for @fewerQuestionsNote.
  ///
  /// In en, this message translates to:
  /// **'{available} of {requested} questions available for this selection'**
  String fewerQuestionsNote(int available, int requested);

  /// No description provided for @scoreSoFar.
  ///
  /// In en, this message translates to:
  /// **'Score: {correct}/{attempted}'**
  String scoreSoFar(int correct, int attempted);

  /// No description provided for @questionNumber.
  ///
  /// In en, this message translates to:
  /// **'Q{number}'**
  String questionNumber(int number);

  /// No description provided for @correctAnswer.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get correctAnswer;

  /// No description provided for @incorrectAnswer.
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get incorrectAnswer;

  /// No description provided for @explanation.
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get explanation;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning, {name}'**
  String greetingMorning(String name);

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon, {name}'**
  String greetingAfternoon(String name);

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening, {name}'**
  String greetingEvening(String name);

  /// No description provided for @defaultStudentName.
  ///
  /// In en, this message translates to:
  /// **'Aspirant'**
  String get defaultStudentName;

  /// No description provided for @keepLearning.
  ///
  /// In en, this message translates to:
  /// **'Keep learning, keep improving!'**
  String get keepLearning;

  /// No description provided for @homeChooseExam.
  ///
  /// In en, this message translates to:
  /// **'Choose your exam'**
  String get homeChooseExam;

  /// No description provided for @railway.
  ///
  /// In en, this message translates to:
  /// **'Railway'**
  String get railway;

  /// No description provided for @ssc.
  ///
  /// In en, this message translates to:
  /// **'SSC'**
  String get ssc;

  /// No description provided for @banking.
  ///
  /// In en, this message translates to:
  /// **'Banking'**
  String get banking;

  /// No description provided for @mockTestsSub.
  ///
  /// In en, this message translates to:
  /// **'Full-length & topic tests'**
  String get mockTestsSub;

  /// No description provided for @dailyPracticeSub.
  ///
  /// In en, this message translates to:
  /// **'Small sets, big progress'**
  String get dailyPracticeSub;

  /// No description provided for @previousYearPapers.
  ///
  /// In en, this message translates to:
  /// **'Previous Year Papers'**
  String get previousYearPapers;

  /// No description provided for @previousYearSub.
  ///
  /// In en, this message translates to:
  /// **'Real exam questions'**
  String get previousYearSub;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @aiLabel.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get aiLabel;

  /// No description provided for @doneButton.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneButton;

  /// No description provided for @singleSelection.
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get singleSelection;

  /// No description provided for @multipleSelection.
  ///
  /// In en, this message translates to:
  /// **'Multiple'**
  String get multipleSelection;

  /// No description provided for @selectionType.
  ///
  /// In en, this message translates to:
  /// **'Selection type'**
  String get selectionType;

  /// No description provided for @singleSelectionHint.
  ///
  /// In en, this message translates to:
  /// **'Choose one topic'**
  String get singleSelectionHint;

  /// No description provided for @multipleSelectionHint.
  ///
  /// In en, this message translates to:
  /// **'Choose one or more topics'**
  String get multipleSelectionHint;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get selectAll;

  /// No description provided for @emailOrMobile.
  ///
  /// In en, this message translates to:
  /// **'Email or Mobile Number'**
  String get emailOrMobile;

  /// No description provided for @errorEmailOrMobile.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email or 10-digit mobile number'**
  String get errorEmailOrMobile;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember Me'**
  String get rememberMe;

  /// No description provided for @loginHeadlinePrepare.
  ///
  /// In en, this message translates to:
  /// **'Prepare'**
  String get loginHeadlinePrepare;

  /// No description provided for @loginHeadlineSmarter.
  ///
  /// In en, this message translates to:
  /// **'smarter.'**
  String get loginHeadlineSmarter;

  /// No description provided for @loginHeadlineAchieve.
  ///
  /// In en, this message translates to:
  /// **'Achieve'**
  String get loginHeadlineAchieve;

  /// No description provided for @loginHeadlineMore.
  ///
  /// In en, this message translates to:
  /// **'more.'**
  String get loginHeadlineMore;

  /// No description provided for @loginTagline.
  ///
  /// In en, this message translates to:
  /// **'Your Railway, SSC & Banking preparation starts here.'**
  String get loginTagline;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @continueWithMobileOtp.
  ///
  /// In en, this message translates to:
  /// **'Continue with Mobile OTP'**
  String get continueWithMobileOtp;

  /// No description provided for @forgotTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotTitle;

  /// No description provided for @forgotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your registered email or mobile number. We will send you a reset link or OTP.'**
  String get forgotSubtitle;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @rememberPassword.
  ///
  /// In en, this message translates to:
  /// **'Remember your password?'**
  String get rememberPassword;

  /// No description provided for @resetSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox'**
  String get resetSentTitle;

  /// No description provided for @resetSentBody.
  ///
  /// In en, this message translates to:
  /// **'We have sent password reset instructions to {target}'**
  String resetSentBody(String target);

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @didntReceive.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive it?'**
  String get didntReceive;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @resetSecureNote.
  ///
  /// In en, this message translates to:
  /// **'For your security, the link expires in 15 minutes.'**
  String get resetSecureNote;

  /// No description provided for @questionOfTotal.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String questionOfTotal(int current, int total);

  /// No description provided for @answeredOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{answered}/{total} answered'**
  String answeredOfTotal(int answered, int total);

  /// No description provided for @previousQuestion.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previousQuestion;

  /// No description provided for @nextQuestion.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextQuestion;

  /// No description provided for @clearAnswer.
  ///
  /// In en, this message translates to:
  /// **'Clear Answer'**
  String get clearAnswer;

  /// No description provided for @questionPalette.
  ///
  /// In en, this message translates to:
  /// **'Question Palette'**
  String get questionPalette;

  /// No description provided for @paletteAnswered.
  ///
  /// In en, this message translates to:
  /// **'Answered'**
  String get paletteAnswered;

  /// No description provided for @paletteNotAnswered.
  ///
  /// In en, this message translates to:
  /// **'Not Answered'**
  String get paletteNotAnswered;

  /// No description provided for @paletteCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get paletteCurrent;

  /// No description provided for @submitTest.
  ///
  /// In en, this message translates to:
  /// **'Submit Test'**
  String get submitTest;

  /// No description provided for @answerAllToSubmit.
  ///
  /// In en, this message translates to:
  /// **'Answer all questions to enable Submit ({left} left)'**
  String answerAllToSubmit(int left);

  /// No description provided for @allAnsweredReady.
  ///
  /// In en, this message translates to:
  /// **'All questions answered. You can submit now.'**
  String get allAnsweredReady;

  /// No description provided for @timeLeftLabel.
  ///
  /// In en, this message translates to:
  /// **'Time left {time}'**
  String timeLeftLabel(String time);

  /// No description provided for @timeUpSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Time is up! Submitting your test…'**
  String get timeUpSubmitting;

  /// No description provided for @leaveTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave this test?'**
  String get leaveTestTitle;

  /// No description provided for @leaveTestBody.
  ///
  /// In en, this message translates to:
  /// **'Your answers will not be saved.'**
  String get leaveTestBody;

  /// No description provided for @leaveTest.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leaveTest;

  /// No description provided for @continueTest.
  ///
  /// In en, this message translates to:
  /// **'Continue Test'**
  String get continueTest;

  /// No description provided for @selectOptionHint.
  ///
  /// In en, this message translates to:
  /// **'Select one option'**
  String get selectOptionHint;

  /// No description provided for @submitConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Submit Test'**
  String get submitConfirmTitle;

  /// No description provided for @submitConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to submit your test?'**
  String get submitConfirmBody;

  /// No description provided for @totalQuestions.
  ///
  /// In en, this message translates to:
  /// **'Total Questions'**
  String get totalQuestions;

  /// No description provided for @answeredQuestions.
  ///
  /// In en, this message translates to:
  /// **'Answered'**
  String get answeredQuestions;

  /// No description provided for @unansweredQuestions.
  ///
  /// In en, this message translates to:
  /// **'Unanswered'**
  String get unansweredQuestions;

  /// No description provided for @timeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Time Remaining'**
  String get timeRemaining;

  /// No description provided for @submitWarningUnanswered.
  ///
  /// In en, this message translates to:
  /// **'Unanswered questions get 0 marks.'**
  String get submitWarningUnanswered;

  /// No description provided for @submitNoChanges.
  ///
  /// In en, this message translates to:
  /// **'You cannot change answers after submitting.'**
  String get submitNoChanges;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @submittingTest.
  ///
  /// In en, this message translates to:
  /// **'Submitting your test…'**
  String get submittingTest;

  /// No description provided for @submitFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not submit your test. Check your connection and try again.'**
  String get submitFailed;

  /// No description provided for @testCompleted.
  ///
  /// In en, this message translates to:
  /// **'Test Completed'**
  String get testCompleted;

  /// No description provided for @finalScore.
  ///
  /// In en, this message translates to:
  /// **'Final Score'**
  String get finalScore;

  /// No description provided for @correctAnswers.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get correctAnswers;

  /// No description provided for @incorrectAnswers.
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get incorrectAnswers;

  /// No description provided for @backToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Back to Dashboard'**
  String get backToDashboard;

  /// No description provided for @autoSubmittedNote.
  ///
  /// In en, this message translates to:
  /// **'Time ran out, so your test was submitted automatically.'**
  String get autoSubmittedNote;

  /// No description provided for @congratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulations;

  /// No description provided for @completedOn.
  ///
  /// In en, this message translates to:
  /// **'Completed on {date}'**
  String completedOn(String date);

  /// No description provided for @unattempted.
  ///
  /// In en, this message translates to:
  /// **'Unattempted'**
  String get unattempted;

  /// No description provided for @accuracyLabel.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get accuracyLabel;

  /// No description provided for @scoreOutOf.
  ///
  /// In en, this message translates to:
  /// **'out of {max}'**
  String scoreOutOf(String max);

  /// No description provided for @markingScheme.
  ///
  /// In en, this message translates to:
  /// **'+1 correct · −0.25 incorrect · 0 unattempted'**
  String get markingScheme;

  /// No description provided for @answerBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Correct vs Incorrect'**
  String get answerBreakdown;

  /// No description provided for @timeTaken.
  ///
  /// In en, this message translates to:
  /// **'Time Taken'**
  String get timeTaken;

  /// No description provided for @avgPerQuestion.
  ///
  /// In en, this message translates to:
  /// **'Avg per Question'**
  String get avgPerQuestion;

  /// No description provided for @performanceAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Performance Analysis'**
  String get performanceAnalysis;

  /// No description provided for @strongTopics.
  ///
  /// In en, this message translates to:
  /// **'Strong Topics'**
  String get strongTopics;

  /// No description provided for @weakTopics.
  ///
  /// In en, this message translates to:
  /// **'Weak Topics'**
  String get weakTopics;

  /// No description provided for @noneYet.
  ///
  /// In en, this message translates to:
  /// **'None yet'**
  String get noneYet;

  /// No description provided for @topicWiseAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Topic-wise Accuracy'**
  String get topicWiseAccuracy;

  /// No description provided for @topicScore.
  ///
  /// In en, this message translates to:
  /// **'{correct}/{total} correct'**
  String topicScore(int correct, int total);

  /// No description provided for @recommendedPractice.
  ///
  /// In en, this message translates to:
  /// **'Recommended Practice'**
  String get recommendedPractice;

  /// No description provided for @recommendRevise.
  ///
  /// In en, this message translates to:
  /// **'Revise {topic}: you got {correct} of {total} right. Practise it again at the same level.'**
  String recommendRevise(String topic, int correct, int total);

  /// No description provided for @recommendNextLevel.
  ///
  /// In en, this message translates to:
  /// **'Great work! Try the next difficulty level to keep improving.'**
  String get recommendNextLevel;

  /// No description provided for @recommendKeepGoing.
  ///
  /// In en, this message translates to:
  /// **'Good effort! Review the explanations and practise your mistakes once more.'**
  String get recommendKeepGoing;

  /// No description provided for @reviewAnswers.
  ///
  /// In en, this message translates to:
  /// **'Review Answers'**
  String get reviewAnswers;

  /// No description provided for @savePractice.
  ///
  /// In en, this message translates to:
  /// **'Save Practice'**
  String get savePractice;

  /// No description provided for @retryWrong.
  ///
  /// In en, this message translates to:
  /// **'Retry Wrong Questions'**
  String get retryWrong;

  /// No description provided for @reviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Answer Review'**
  String get reviewTitle;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterWithCount.
  ///
  /// In en, this message translates to:
  /// **'{label} ({count})'**
  String filterWithCount(String label, int count);

  /// No description provided for @yourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get yourAnswer;

  /// No description provided for @correctAnswerLabel.
  ///
  /// In en, this message translates to:
  /// **'Correct answer'**
  String get correctAnswerLabel;

  /// No description provided for @notAnswered.
  ///
  /// In en, this message translates to:
  /// **'Not answered'**
  String get notAnswered;

  /// No description provided for @statusCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get statusCorrect;

  /// No description provided for @statusIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get statusIncorrect;

  /// No description provided for @statusUnattempted.
  ///
  /// In en, this message translates to:
  /// **'Unattempted'**
  String get statusUnattempted;

  /// No description provided for @whyCorrect.
  ///
  /// In en, this message translates to:
  /// **'Why this is correct'**
  String get whyCorrect;

  /// No description provided for @whyWrong.
  ///
  /// In en, this message translates to:
  /// **'Why your answer was wrong'**
  String get whyWrong;

  /// No description provided for @wrongChoiceNote.
  ///
  /// In en, this message translates to:
  /// **'You chose {yours}, but the correct answer is {correct}.'**
  String wrongChoiceNote(String yours, String correct);

  /// No description provided for @unattemptedNote.
  ///
  /// In en, this message translates to:
  /// **'You skipped this question. The correct answer is {correct}.'**
  String unattemptedNote(String correct);

  /// No description provided for @explanationTitle.
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get explanationTitle;

  /// No description provided for @stepByStep.
  ///
  /// In en, this message translates to:
  /// **'Step-by-step Solution'**
  String get stepByStep;

  /// No description provided for @formulaTitle.
  ///
  /// In en, this message translates to:
  /// **'Formula'**
  String get formulaTitle;

  /// No description provided for @conceptTitle.
  ///
  /// In en, this message translates to:
  /// **'Short Concept'**
  String get conceptTitle;

  /// No description provided for @tipTitle.
  ///
  /// In en, this message translates to:
  /// **'Learning Tip'**
  String get tipTitle;

  /// No description provided for @stepLabel.
  ///
  /// In en, this message translates to:
  /// **'Step {n}'**
  String stepLabel(int n);

  /// No description provided for @noReviewItems.
  ///
  /// In en, this message translates to:
  /// **'No questions in this filter.'**
  String get noReviewItems;

  /// No description provided for @optionCorrectLabel.
  ///
  /// In en, this message translates to:
  /// **'Option {letter}, correct answer: {text}'**
  String optionCorrectLabel(String letter, String text);

  /// No description provided for @optionWrongLabel.
  ///
  /// In en, this message translates to:
  /// **'Option {letter}, your wrong answer: {text}'**
  String optionWrongLabel(String letter, String text);

  /// No description provided for @noWrongToRetry.
  ///
  /// In en, this message translates to:
  /// **'No wrong answers to retry. Great job!'**
  String get noWrongToRetry;

  /// No description provided for @savingPractice.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get savingPractice;

  /// No description provided for @practiceSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved to My Practice'**
  String get practiceSaved;

  /// No description provided for @saveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Practice saved with all questions, answers, explanations and your scorecard.'**
  String get saveSuccess;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save your practice. Check your connection and try again.'**
  String get saveFailed;

  /// No description provided for @mySavedPractice.
  ///
  /// In en, this message translates to:
  /// **'My Saved Practice'**
  String get mySavedPractice;

  /// No description provided for @viewAction.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get viewAction;

  /// No description provided for @accuracyChartLabel.
  ///
  /// In en, this message translates to:
  /// **'Accuracy {percent}'**
  String accuracyChartLabel(String percent);

  /// No description provided for @optionLabel.
  ///
  /// In en, this message translates to:
  /// **'Option {letter}: {text}'**
  String optionLabel(String letter, String text);

  /// No description provided for @orUpper.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get orUpper;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
