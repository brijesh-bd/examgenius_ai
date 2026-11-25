// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'ExamGenius AI';

  @override
  String get appTagline => 'सरकारी सफलता का आपका सेतु';

  @override
  String get skip => 'छोड़ें';

  @override
  String get next => 'आगे';

  @override
  String get getStarted => 'शुरू करें';

  @override
  String get chooseLanguage => 'अपनी भाषा चुनें';

  @override
  String get chooseLanguageSubtitle =>
      'आप इसे कभी भी प्रोफ़ाइल से बदल सकते हैं।';

  @override
  String get onboarding1Title => 'AI-आधारित अभ्यास';

  @override
  String get onboarding1Body =>
      'AI की शक्ति से तुरंत परीक्षा-स्तरीय प्रश्न पाएं';

  @override
  String get onboarding2Title => 'मॉक टेस्ट';

  @override
  String get onboarding2Body =>
      'असली परीक्षा पैटर्न के साथ फुल-लेंथ और टॉपिक-वाइज़ टेस्ट';

  @override
  String get onboarding3Title => 'प्रदर्शन विश्लेषण';

  @override
  String get onboarding3Body =>
      'सटीकता ट्रैक करें, कमज़ोर अध्याय पहचानें और रोज़ सुधार करें';

  @override
  String get welcomeBack => 'फिर से स्वागत है';

  @override
  String get loginSubtitle => 'अपनी तैयारी जारी रखने के लिए लॉग इन करें';

  @override
  String get mobileNumber => 'मोबाइल नंबर';

  @override
  String get password => 'पासवर्ड';

  @override
  String get forgotPassword => 'पासवर्ड भूल गए?';

  @override
  String get login => 'लॉग इन';

  @override
  String get loginWithOtp => 'OTP से जारी रखें';

  @override
  String get noAccount => 'खाता नहीं है?';

  @override
  String get register => 'रजिस्टर करें';

  @override
  String get createAccount => 'खाता बनाएं';

  @override
  String get registerSubtitle => 'सरकारी नौकरी की ओर अपनी यात्रा शुरू करें';

  @override
  String get fullName => 'पूरा नाम';

  @override
  String get email => 'ईमेल (वैकल्पिक)';

  @override
  String get confirmPassword => 'पासवर्ड की पुष्टि करें';

  @override
  String get targetExam => 'लक्षित परीक्षा';

  @override
  String get alreadyHaveAccount => 'पहले से खाता है?';

  @override
  String get agreeTerms => 'मैं सेवा की शर्तों और गोपनीयता नीति से सहमत हूँ';

  @override
  String get errorRequired => 'यह फ़ील्ड आवश्यक है';

  @override
  String get errorMobile => 'मान्य 10 अंकों का भारतीय मोबाइल नंबर दर्ज करें';

  @override
  String get errorPassword => 'पासवर्ड कम से कम 8 अक्षरों का होना चाहिए';

  @override
  String get errorPasswordMatch => 'पासवर्ड मेल नहीं खाते';

  @override
  String get errorEmail => 'मान्य ईमेल पता दर्ज करें';

  @override
  String get errorName => 'अपना पूरा नाम दर्ज करें';

  @override
  String get errorTerms => 'आगे बढ़ने के लिए शर्तें स्वीकार करें';

  @override
  String get errorGeneric => 'कुछ गलत हो गया। कृपया पुनः प्रयास करें।';

  @override
  String get errorInvalidCredentials => 'अमान्य ईमेल/मोबाइल या पासवर्ड';

  @override
  String get errorNetwork =>
      'ExamGenius सर्वर से कनेक्ट नहीं हो सका। अपना इंटरनेट जांचें और फिर से प्रयास करें।';

  @override
  String get errorMobileTaken =>
      'यह मोबाइल नंबर पहले से पंजीकृत है। कृपया लॉगिन करें।';

  @override
  String get errorEmailTaken => 'यह ईमेल पहले से पंजीकृत है। कृपया लॉगिन करें।';

  @override
  String get errorAiBusy =>
      'AI अभी व्यस्त है। कृपया एक मिनट बाद फिर से प्रयास करें।';

  @override
  String get errorSessionExpired =>
      'आपका सत्र समाप्त हो गया। कृपया फिर से लॉगिन करें।';

  @override
  String get proName => 'ExamGenius Pro';

  @override
  String get proTagline => 'AI व्याख्याओं के साथ असीमित अभ्यास';

  @override
  String get planFree => 'फ्री';

  @override
  String get planPro => 'प्रो';

  @override
  String get myPlan => 'मेरा प्लान';

  @override
  String get seePlans => 'प्रो प्लान देखें';

  @override
  String get upgradeToPro => 'प्रो में अपग्रेड करें';

  @override
  String get maybeLater => 'बाद में';

  @override
  String startTrial(int days) {
    return '$days दिन का फ्री ट्रायल शुरू करें';
  }

  @override
  String get trialStarted =>
      'आपका प्रो ट्रायल शुरू हो गया। असीमित अभ्यास का आनंद लें!';

  @override
  String get trialFailed =>
      'ट्रायल शुरू नहीं हो सका। कृपया फिर से प्रयास करें।';

  @override
  String proUntil(String date) {
    return '$date तक प्रो';
  }

  @override
  String trialUntil(String date) {
    return '$date तक फ्री ट्रायल';
  }

  @override
  String freeSetsLeft(int left, int total) {
    return 'आज $total में से $left फ्री सेट बाकी';
  }

  @override
  String perMonth(int price) {
    return '₹$price/माह';
  }

  @override
  String planMonths(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months माह',
      one: '1 माह',
    );
    return '$_temp0';
  }

  @override
  String priceInr(int price) {
    return '₹$price';
  }

  @override
  String savePercent(int percent) {
    return '$percent% बचत';
  }

  @override
  String get mostPopular => 'सबसे लोकप्रिय';

  @override
  String choosePlan(String plan) {
    return '$plan चुनें';
  }

  @override
  String get paymentsComingSoon =>
      'ऑनलाइन भुगतान जल्द आ रहा है। अभी प्रो इस्तेमाल करने के लिए फ्री ट्रायल शुरू करें।';

  @override
  String get featureCompare => 'फ्री बनाम प्रो';

  @override
  String get featurePracticeSets => 'अभ्यास सेट';

  @override
  String featureFreeSets(int count) {
    return '$count प्रतिदिन';
  }

  @override
  String get featureUnlimited => 'असीमित';

  @override
  String get featureQuestionsPerSet => 'प्रति सेट प्रश्न';

  @override
  String featureUpTo(int count) {
    return '$count तक';
  }

  @override
  String get featureReview => 'स्कोरकार्ड और व्याख्याएं';

  @override
  String get featureSaved => 'सेव किए गए अभ्यास';

  @override
  String get featureFreshAi => 'बिल्कुल नए AI प्रश्न';

  @override
  String get pricesIncludeGst => 'कीमतों में GST शामिल है। कभी भी रद्द करें।';

  @override
  String get limitDailySetsTitle => 'आज के फ्री सेट इस्तेमाल हो चुके हैं';

  @override
  String limitDailySetsBody(int max) {
    return 'फ्री प्लान में प्रतिदिन $max अभ्यास सेट मिलते हैं। नए सेट आधी रात को खुलेंगे, या असीमित अभ्यास के लिए प्रो लें।';
  }

  @override
  String get limitDailyQuestionsTitle => 'दैनिक सीमा पूरी हुई';

  @override
  String limitDailyQuestionsBody(int max) {
    return 'आपने आज $max प्रश्नों का अभ्यास किया। बहुत बढ़िया! और प्रश्न आधी रात को खुलेंगे।';
  }

  @override
  String get limitSetSizeTitle => 'बड़े सेट प्रो सुविधा है';

  @override
  String limitSetSizeBody(int max) {
    return 'फ्री प्लान में प्रति सेट $max प्रश्न तक। 30 प्रश्नों तक के सेट के लिए प्रो लें।';
  }

  @override
  String get limitSavedTitle => 'सेव किए गए अभ्यास भर गए';

  @override
  String limitSavedBody(int max) {
    return 'फ्री प्लान में $max सेव सेट रहते हैं। एक हटाएं या असीमित के लिए प्रो लें।';
  }

  @override
  String get limitFreshTitle => 'बिल्कुल नए AI प्रश्न प्रो में हैं';

  @override
  String get limitFreshBody =>
      'फ्री प्लान प्रश्न बैंक का उपयोग करता है। हर बार नए AI प्रश्नों के लिए प्रो लें।';

  @override
  String get freshAiToggle => 'बिल्कुल नए AI प्रश्न';

  @override
  String get freshAiToggleHint => 'प्रश्न बैंक छोड़कर नए प्रश्न बनाएं (प्रो)';

  @override
  String get proLocked => 'प्रो';

  @override
  String get createPractice => 'अभ्यास बनाएं';

  @override
  String get changeExam => 'परीक्षा बदलें';

  @override
  String get stepSubject => 'विषय';

  @override
  String get stepTopics => 'टॉपिक';

  @override
  String get stepLevel => 'स्तर';

  @override
  String get stepQuestions => 'प्रश्न';

  @override
  String selectedCount(int count) {
    return '$count चुने गए';
  }

  @override
  String subjectWithCount(String name, int count) {
    return '$name ($count)';
  }

  @override
  String practiceSummary(String subjects, int topics, String level, int count) {
    return '$subjects · $topics टॉपिक · $level · $count प्रश्न';
  }

  @override
  String get selectAtLeastOneTopic => 'शुरू करने के लिए कम से कम 1 टॉपिक चुनें';

  @override
  String get quick10 => 'क्विक 10';

  @override
  String get quick10Hint => 'पूरी परीक्षा से मिश्रित';

  @override
  String get lastPractice => 'पिछला अभ्यास';

  @override
  String get lastPracticeHint => 'अपना पिछला सेटअप दोहराएं';

  @override
  String get weakTopics => 'कमजोर टॉपिक';

  @override
  String get weakTopicsHint => 'जहां अंक कटते हैं वहां ध्यान दें';

  @override
  String get noLastPractice => 'इस परीक्षा के लिए अभी कोई पिछला अभ्यास नहीं।';

  @override
  String get noWeakTopics =>
      'पहले कुछ सेट अभ्यास करें। फिर हम आपके कमजोर टॉपिक खोजेंगे।';

  @override
  String get quickStart => 'क्विक स्टार्ट';

  @override
  String get orBuildYourOwn => 'या अपना खुद का बनाएं';

  @override
  String get retry => 'पुनः प्रयास करें';

  @override
  String get comingSoon => 'जल्द आ रहा है';

  @override
  String get comingSoonBody =>
      'यह सुविधा बनाई जा रही है और अगले अपडेट में उपलब्ध होगी।';

  @override
  String greeting(String name) {
    return 'नमस्ते, $name';
  }

  @override
  String preparingFor(String exam) {
    return '$exam की तैयारी';
  }

  @override
  String get dailyGoal => 'आज का लक्ष्य';

  @override
  String dailyGoalProgress(int done, int total) {
    return '$total में से $done प्रश्न';
  }

  @override
  String streakDays(int count) {
    return '$count दिन की स्ट्रीक';
  }

  @override
  String get continuePreparation => 'तैयारी जारी रखें';

  @override
  String get resume => 'जारी रखें';

  @override
  String get aiGeneratorTitle => 'AI प्रश्न जनरेटर';

  @override
  String get aiGeneratorSubtitle => 'तुरंत परीक्षा-स्तरीय प्रश्न बनाएं';

  @override
  String get generateNow => 'अभी बनाएं';

  @override
  String get quickActions => 'त्वरित विकल्प';

  @override
  String get mockTests => 'मॉक टेस्ट';

  @override
  String get dailyPractice => 'दैनिक अभ्यास';

  @override
  String get previousYear => 'पिछले वर्ष के प्रश्न';

  @override
  String get analytics => 'एनालिटिक्स';

  @override
  String get examCategories => 'परीक्षा श्रेणियाँ';

  @override
  String get seeAll => 'सभी देखें';

  @override
  String get railwayExams => 'रेलवे परीक्षाएँ';

  @override
  String get sscExams => 'SSC परीक्षाएँ';

  @override
  String get bankingExams => 'बैंकिंग परीक्षाएँ';

  @override
  String examsCount(int count) {
    return '$count परीक्षाएँ';
  }

  @override
  String get performance => 'प्रदर्शन';

  @override
  String get accuracy => 'सटीकता';

  @override
  String get testsTaken => 'दिए गए टेस्ट';

  @override
  String get avgScore => 'औसत अंक';

  @override
  String get recentResults => 'हाल के परिणाम';

  @override
  String get noResultsYet => 'अभी तक कोई टेस्ट नहीं दिया';

  @override
  String get noResultsBody => 'परिणाम देखने के लिए अपना पहला मॉक टेस्ट दें।';

  @override
  String get subscriptionFree => 'फ्री प्लान';

  @override
  String subscriptionFreeBody(int left) {
    return 'आज $left AI प्रश्न शेष';
  }

  @override
  String get upgrade => 'अपग्रेड';

  @override
  String get navHome => 'होम';

  @override
  String get navSaved => 'लाइब्रेरी';

  @override
  String get navPractice => 'अभ्यास';

  @override
  String get navAnalytics => 'एनालिटिक्स';

  @override
  String get navProfile => 'प्रोफ़ाइल';

  @override
  String get notifications => 'सूचनाएँ';

  @override
  String get profile => 'प्रोफ़ाइल';

  @override
  String get language => 'भाषा';

  @override
  String get theme => 'थीम';

  @override
  String get themeSystem => 'सिस्टम';

  @override
  String get themeLight => 'लाइट';

  @override
  String get themeDark => 'डार्क';

  @override
  String get logout => 'लॉग आउट';

  @override
  String get english => 'English';

  @override
  String get hindi => 'हिन्दी';

  @override
  String get orDivider => 'या';

  @override
  String get greetingSubtitle =>
      'आइए अपनी सपनों की नौकरी की स्मार्ट तैयारी करें!';

  @override
  String get bookmarks => 'बुकमार्क';

  @override
  String get subscription => 'सदस्यता';

  @override
  String get changeLanguage => 'भाषा बदलें';

  @override
  String get aiPowered => 'AI संचालित';

  @override
  String get startNow => 'शुरू करें';

  @override
  String get chooseYourExam => 'अपनी परीक्षा चुनें';

  @override
  String get viewAll => 'सभी देखें';

  @override
  String get myProgress => 'मेरी प्रगति';

  @override
  String get prepProgressTitle => 'आपकी तैयारी की प्रगति';

  @override
  String get prepProgressBody => 'लगे रहें! आप बहुत अच्छा कर रहे हैं।';

  @override
  String get recentTestResults => 'हाल के टेस्ट परिणाम';

  @override
  String questionsCount(int count) {
    return '$count प्रश्न';
  }

  @override
  String get goPremium => 'प्रीमियम लें';

  @override
  String get goPremiumBody =>
      'असीमित AI प्रश्न, पूर्ण मॉक टेस्ट और बहुत कुछ अनलॉक करें';

  @override
  String get upgradeNow => 'अभी अपग्रेड करें';

  @override
  String get menu => 'मेनू';

  @override
  String get selectExam => 'परीक्षा चुनें';

  @override
  String get dailyPrepTitle => 'आज की तैयारी';

  @override
  String get premiumActive => 'प्रीमियम सक्रिय';

  @override
  String get premiumActiveBody => 'असीमित AI प्रश्न और पूर्ण मॉक टेस्ट';

  @override
  String get selectedExam => 'चयनित परीक्षा';

  @override
  String get goalComplete => 'लक्ष्य पूरा! बहुत बढ़िया।';

  @override
  String get chooseExamPrompt => 'परीक्षा चुनें और अपनी तैयारी शुरू करें';

  @override
  String get generateQuestions => 'प्रश्न बनाएं';

  @override
  String get quickAccess => 'त्वरित पहुँच';

  @override
  String get selectExamBody => 'वह परीक्षा चुनें जिसकी आप तैयारी कर रहे हैं';

  @override
  String get currentTarget => 'वर्तमान लक्ष्य';

  @override
  String get syllabusTitle => 'पाठ्यक्रम';

  @override
  String get selectTopics => 'विषय चुनें';

  @override
  String get clear => 'हटाएं';

  @override
  String subjectsCount(int count) {
    return '$count विषय';
  }

  @override
  String topicsCount(int count) {
    return '$count टॉपिक';
  }

  @override
  String topicsSelected(int count) {
    return '$count चयनित';
  }

  @override
  String get difficultyLevel => 'कठिनाई स्तर';

  @override
  String get difficultyEasy => 'आसान';

  @override
  String get difficultyMedium => 'मध्यम';

  @override
  String get difficultyHard => 'कठिन';

  @override
  String get numberOfQuestions => 'प्रश्नों की संख्या';

  @override
  String get generatorIncomplete =>
      'टॉपिक, कठिनाई स्तर और प्रश्नों की संख्या चुनें';

  @override
  String get generatedQuestionsTitle => 'अभ्यास प्रश्न';

  @override
  String get generatingQuestions =>
      'AI परीक्षा-स्तर के प्रश्न तैयार कर रहा है…';

  @override
  String get noQuestionsForSelection =>
      'इस चयन के लिए अभी प्रश्न उपलब्ध नहीं हैं। कोई अन्य टॉपिक या स्तर चुनें।';

  @override
  String get sampleQuestionsNote =>
      'पूर्वावलोकन मोड: ये नमूना परीक्षा-स्तर के प्रश्न हैं। ExamGenius सर्वर जुड़ने के बाद लाइव AI प्रश्न बनेंगे।';

  @override
  String fewerQuestionsNote(int available, int requested) {
    return 'इस चयन के लिए $requested में से $available प्रश्न उपलब्ध हैं';
  }

  @override
  String scoreSoFar(int correct, int attempted) {
    return 'स्कोर: $correct/$attempted';
  }

  @override
  String questionNumber(int number) {
    return 'प्र$number';
  }

  @override
  String get correctAnswer => 'सही!';

  @override
  String get incorrectAnswer => 'गलत';

  @override
  String get explanation => 'व्याख्या';

  @override
  String greetingMorning(String name) {
    return 'सुप्रभात, $name';
  }

  @override
  String greetingAfternoon(String name) {
    return 'नमस्कार, $name';
  }

  @override
  String greetingEvening(String name) {
    return 'शुभ संध्या, $name';
  }

  @override
  String get defaultStudentName => 'अभ्यर्थी';

  @override
  String get keepLearning => 'सीखते रहें, आगे बढ़ते रहें!';

  @override
  String get homeChooseExam => 'अपनी परीक्षा चुनें';

  @override
  String get railway => 'रेलवे';

  @override
  String get ssc => 'एसएससी';

  @override
  String get banking => 'बैंकिंग';

  @override
  String get mockTestsSub => 'फुल-लेंथ और टॉपिक टेस्ट';

  @override
  String get dailyPracticeSub => 'छोटे सेट, बड़ी प्रगति';

  @override
  String get previousYearPapers => 'पिछले वर्ष के पेपर';

  @override
  String get previousYearSub => 'असली परीक्षा प्रश्न';

  @override
  String get more => 'और';

  @override
  String get aiLabel => 'AI';

  @override
  String get doneButton => 'हो गया';

  @override
  String get singleSelection => 'एकल';

  @override
  String get multipleSelection => 'एकाधिक';

  @override
  String get selectionType => 'चयन का प्रकार';

  @override
  String get singleSelectionHint => 'एक टॉपिक चुनें';

  @override
  String get multipleSelectionHint => 'एक या अधिक टॉपिक चुनें';

  @override
  String get selectAll => 'सभी चुनें';

  @override
  String get emailOrMobile => 'ईमेल या मोबाइल नंबर';

  @override
  String get errorEmailOrMobile =>
      'मान्य ईमेल या 10 अंकों का मोबाइल नंबर दर्ज करें';

  @override
  String get rememberMe => 'मुझे याद रखें';

  @override
  String get showPassword => 'पासवर्ड दिखाएं';

  @override
  String get hidePassword => 'पासवर्ड छिपाएं';

  @override
  String get loginHeadlinePrepare => 'तैयारी करें';

  @override
  String get loginHeadlineSmarter => 'स्मार्ट तरीके से।';

  @override
  String get loginHeadlineAchieve => 'पाएं';

  @override
  String get loginHeadlineMore => 'ज़्यादा।';

  @override
  String get loginTagline =>
      'आपकी रेलवे, SSC और बैंकिंग की तैयारी यहीं से शुरू होती है।';

  @override
  String get signUp => 'साइन अप';

  @override
  String get continueWithMobileOtp => 'मोबाइल OTP से जारी रखें';

  @override
  String get forgotTitle => 'पासवर्ड भूल गए?';

  @override
  String get forgotSubtitle =>
      'अपना पंजीकृत ईमेल या मोबाइल नंबर दर्ज करें। हम आपको रीसेट लिंक या OTP भेजेंगे।';

  @override
  String get sendResetLink => 'रीसेट लिंक भेजें';

  @override
  String get rememberPassword => 'पासवर्ड याद आ गया?';

  @override
  String get resetSentTitle => 'अपना इनबॉक्स देखें';

  @override
  String resetSentBody(String target) {
    return 'हमने पासवर्ड रीसेट निर्देश $target पर भेज दिए हैं';
  }

  @override
  String get backToLogin => 'लॉगिन पर वापस जाएं';

  @override
  String get didntReceive => 'नहीं मिला?';

  @override
  String get resend => 'फिर से भेजें';

  @override
  String get resetSecureNote =>
      'आपकी सुरक्षा के लिए, लिंक 15 मिनट में समाप्त हो जाएगा।';

  @override
  String questionOfTotal(int current, int total) {
    return 'प्रश्न $current / $total';
  }

  @override
  String answeredOfTotal(int answered, int total) {
    return '$answered/$total उत्तर दिए';
  }

  @override
  String get previousQuestion => 'पिछला';

  @override
  String get nextQuestion => 'अगला';

  @override
  String get clearAnswer => 'उत्तर हटाएं';

  @override
  String get questionPalette => 'प्रश्न पैलेट';

  @override
  String get paletteAnswered => 'उत्तर दिया';

  @override
  String get paletteNotAnswered => 'उत्तर नहीं दिया';

  @override
  String get paletteCurrent => 'वर्तमान';

  @override
  String get submitTest => 'टेस्ट सबमिट करें';

  @override
  String answerAllToSubmit(int left) {
    return 'सबमिट के लिए सभी प्रश्नों के उत्तर दें ($left शेष)';
  }

  @override
  String get allAnsweredReady =>
      'सभी प्रश्नों के उत्तर दे दिए गए। अब आप सबमिट कर सकते हैं।';

  @override
  String timeLeftLabel(String time) {
    return 'शेष समय $time';
  }

  @override
  String get timeUpSubmitting => 'समय समाप्त! आपका टेस्ट सबमिट हो रहा है…';

  @override
  String get leaveTestTitle => 'टेस्ट छोड़ें?';

  @override
  String get leaveTestBody => 'आपके उत्तर सेव नहीं होंगे।';

  @override
  String get leaveTest => 'छोड़ें';

  @override
  String get continueTest => 'टेस्ट जारी रखें';

  @override
  String get selectOptionHint => 'एक विकल्प चुनें';

  @override
  String get submitConfirmTitle => 'टेस्ट सबमिट करें';

  @override
  String get submitConfirmBody =>
      'क्या आप वाकई अपना टेस्ट सबमिट करना चाहते हैं?';

  @override
  String get totalQuestions => 'कुल प्रश्न';

  @override
  String get answeredQuestions => 'उत्तर दिए';

  @override
  String get unansweredQuestions => 'उत्तर नहीं दिए';

  @override
  String get timeRemaining => 'शेष समय';

  @override
  String get submitWarningUnanswered =>
      'बिना उत्तर वाले प्रश्नों के 0 अंक मिलेंगे।';

  @override
  String get submitNoChanges => 'सबमिट करने के बाद आप उत्तर नहीं बदल सकते।';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get submittingTest => 'आपका टेस्ट सबमिट हो रहा है…';

  @override
  String get submitFailed =>
      'टेस्ट सबमिट नहीं हो सका। अपना कनेक्शन जांचें और फिर से प्रयास करें।';

  @override
  String get testCompleted => 'टेस्ट पूरा हुआ';

  @override
  String get finalScore => 'अंतिम स्कोर';

  @override
  String get correctAnswers => 'सही';

  @override
  String get incorrectAnswers => 'गलत';

  @override
  String get backToDashboard => 'डैशबोर्ड पर वापस जाएं';

  @override
  String get autoSubmittedNote =>
      'समय समाप्त हो गया, इसलिए आपका टेस्ट अपने आप सबमिट हो गया।';

  @override
  String get congratulations => 'बधाई हो!';

  @override
  String completedOn(String date) {
    return '$date को पूरा किया';
  }

  @override
  String get unattempted => 'छोड़े गए';

  @override
  String get accuracyLabel => 'सटीकता';

  @override
  String scoreOutOf(String max) {
    return '$max में से';
  }

  @override
  String get markingScheme => '+1 सही · −0.25 गलत · 0 छोड़े गए';

  @override
  String get answerBreakdown => 'सही बनाम गलत';

  @override
  String get timeTaken => 'लिया गया समय';

  @override
  String get avgPerQuestion => 'प्रति प्रश्न औसत';

  @override
  String get performanceAnalysis => 'प्रदर्शन विश्लेषण';

  @override
  String get strongTopics => 'मजबूत टॉपिक';

  @override
  String get quickWeakTopics => 'कमजोर टॉपिक';

  @override
  String get noneYet => 'अभी कोई नहीं';

  @override
  String get topicWiseAccuracy => 'टॉपिक-वार सटीकता';

  @override
  String topicScore(int correct, int total) {
    return '$correct/$total सही';
  }

  @override
  String get recommendedPractice => 'सुझाया गया अभ्यास';

  @override
  String recommendRevise(String topic, int correct, int total) {
    return '$topic दोहराएं: आपने $total में से $correct सही किए। इसी स्तर पर फिर से अभ्यास करें।';
  }

  @override
  String get recommendNextLevel =>
      'बहुत बढ़िया! सुधार जारी रखने के लिए अगला कठिनाई स्तर आज़माएं।';

  @override
  String get recommendKeepGoing =>
      'अच्छा प्रयास! व्याख्याएं पढ़ें और अपनी गलतियों का फिर से अभ्यास करें।';

  @override
  String get reviewAnswers => 'उत्तर देखें';

  @override
  String get savePractice => 'अभ्यास सेव करें';

  @override
  String get retryWrong => 'गलत प्रश्न फिर से करें';

  @override
  String get reviewTitle => 'उत्तर समीक्षा';

  @override
  String get filterAll => 'सभी';

  @override
  String filterWithCount(String label, int count) {
    return '$label ($count)';
  }

  @override
  String get yourAnswer => 'आपका उत्तर';

  @override
  String get correctAnswerLabel => 'सही उत्तर';

  @override
  String get notAnswered => 'उत्तर नहीं दिया';

  @override
  String get statusCorrect => 'सही';

  @override
  String get statusIncorrect => 'गलत';

  @override
  String get statusUnattempted => 'छोड़ा गया';

  @override
  String get whyCorrect => 'यह सही क्यों है';

  @override
  String get whyWrong => 'आपका उत्तर गलत क्यों था';

  @override
  String wrongChoiceNote(String yours, String correct) {
    return 'आपने $yours चुना, लेकिन सही उत्तर $correct है।';
  }

  @override
  String unattemptedNote(String correct) {
    return 'आपने यह प्रश्न छोड़ दिया। सही उत्तर $correct है।';
  }

  @override
  String get explanationTitle => 'व्याख्या';

  @override
  String get stepByStep => 'चरण-दर-चरण हल';

  @override
  String get formulaTitle => 'सूत्र';

  @override
  String get conceptTitle => 'संक्षिप्त अवधारणा';

  @override
  String get tipTitle => 'सीखने की टिप';

  @override
  String stepLabel(int n) {
    return 'चरण $n';
  }

  @override
  String get noReviewItems => 'इस फ़िल्टर में कोई प्रश्न नहीं।';

  @override
  String optionCorrectLabel(String letter, String text) {
    return 'विकल्प $letter, सही उत्तर: $text';
  }

  @override
  String optionWrongLabel(String letter, String text) {
    return 'विकल्प $letter, आपका गलत उत्तर: $text';
  }

  @override
  String get noWrongToRetry =>
      'दोबारा करने के लिए कोई गलत उत्तर नहीं। बहुत बढ़िया!';

  @override
  String get savingPractice => 'सेव हो रहा है…';

  @override
  String get practiceSaved => 'मेरे अभ्यास में सेव किया गया';

  @override
  String get saveSuccess =>
      'सभी प्रश्न, उत्तर, व्याख्याएं और आपका स्कोरकार्ड सेव हो गया।';

  @override
  String get saveFailed =>
      'आपका अभ्यास सेव नहीं हो सका। अपना कनेक्शन जांचें और फिर से प्रयास करें।';

  @override
  String get mySavedPractice => 'मेरे सेव किए गए अभ्यास';

  @override
  String get viewAction => 'देखें';

  @override
  String get savedEmptyTitle => 'आपकी लाइब्रेरी खाली है';

  @override
  String get savedEmptyBody =>
      'टेस्ट के बाद, स्कोरकार्ड पर अभ्यास सेव करें दबाएं ताकि दोहराने के लिए यह यहां रहे।';

  @override
  String savedOn(String date) {
    return '$date को सेव किया';
  }

  @override
  String questionsShort(int count) {
    return '$count प्रश्न';
  }

  @override
  String get reviewPractice => 'देखें';

  @override
  String get practiceAgain => 'फिर से अभ्यास';

  @override
  String get retryWrongShort => 'गलत दोबारा';

  @override
  String get deletePractice => 'हटाएं';

  @override
  String get deletePracticeTitle => 'यह अभ्यास हटाएं?';

  @override
  String get deletePracticeBody =>
      'यह अभ्यास सेट, इसके प्रयासों का इतिहास, बुकमार्क और नोट्स हमेशा के लिए हटा दिए जाएंगे।';

  @override
  String get practiceDeleted => 'अभ्यास हटा दिया गया।';

  @override
  String get deleteFailed =>
      'हटाया नहीं जा सका। अपना कनेक्शन जांचें और फिर से प्रयास करें।';

  @override
  String get scoreLabel => 'स्कोर';

  @override
  String get moreActions => 'और विकल्प';

  @override
  String accuracyChartLabel(String percent) {
    return 'सटीकता $percent';
  }

  @override
  String optionLabel(String letter, String text) {
    return 'विकल्प $letter: $text';
  }

  @override
  String get orUpper => 'या';

  @override
  String get myLibrary => 'मेरी लर्निंग लाइब्रेरी';

  @override
  String get libraryStatSets => 'अभ्यास सेट';

  @override
  String get libraryStatQuestions => 'प्रश्न';

  @override
  String get libraryStatNotes => 'नोट्स';

  @override
  String get libraryCategories => 'आपकी लाइब्रेरी';

  @override
  String librarySetsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सेट',
      one: '1 सेट',
      zero: 'अभी कोई सेट नहीं',
    );
    return '$_temp0';
  }

  @override
  String get recentPracticeSets => 'हाल ही में बनाए गए';

  @override
  String get libraryEmptyTitle => 'आपकी लाइब्रेरी खाली है';

  @override
  String get libraryEmptyBody =>
      'आप जो भी अभ्यास सेट बनाते हैं, वह प्रश्नों, उत्तरों और व्याख्याओं के साथ यहां अपने आप सेव हो जाता है।';

  @override
  String categoryLibraryTitle(String category) {
    return '$category लाइब्रेरी';
  }

  @override
  String categoryEmptyTitle(String category) {
    return 'अभी कोई $category अभ्यास नहीं';
  }

  @override
  String get categoryEmptyBody =>
      'इस श्रेणी की किसी परीक्षा के लिए अभ्यास सेट बनाएं, वह यहां दिखेगा।';

  @override
  String get noMatchingSets => 'इन फ़िल्टर से कोई अभ्यास सेट नहीं मिला';

  @override
  String get clearFilters => 'फ़िल्टर हटाएं';

  @override
  String get searchSetsHint => 'परीक्षा, विषय या टॉपिक खोजें';

  @override
  String get filterExam => 'परीक्षा';

  @override
  String get filterSubject => 'विषय';

  @override
  String get filterTopic => 'टॉपिक';

  @override
  String get filterDifficulty => 'कठिनाई';

  @override
  String get filterLanguage => 'भाषा';

  @override
  String get filterDate => 'तारीख';

  @override
  String get filterAny => 'सभी';

  @override
  String get sortLatest => 'नए पहले';

  @override
  String get sortOldest => 'पुराने पहले';

  @override
  String get dateLast7 => 'पिछले 7 दिन';

  @override
  String get dateLast30 => 'पिछले 30 दिन';

  @override
  String get dateCustom => 'तारीख चुनें…';

  @override
  String get dateAny => 'कभी भी';

  @override
  String get notAttempted => 'प्रयास नहीं किया';

  @override
  String attemptsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रयास',
      one: '1 प्रयास',
    );
    return '$_temp0';
  }

  @override
  String get latestScore => 'नवीनतम स्कोर';

  @override
  String get viewHistory => 'इतिहास';

  @override
  String get attemptFirstToReview =>
      'पहले यह सेट हल करें — सबमिट करने के बाद उत्तर और व्याख्या खुलेंगे।';

  @override
  String get loadMore => 'और देखें';

  @override
  String get savedToLibrary => 'आपकी लाइब्रेरी में अपने आप सेव हो गया';

  @override
  String get openLibrary => 'लाइब्रेरी खोलें';

  @override
  String get openingPractice => 'अभ्यास खुल रहा है…';

  @override
  String get aiStudyNotes => 'AI स्टडी नोट्स';

  @override
  String get aiStudyNotesSub => 'AI नोट्स से हर टॉपिक को समझें।';

  @override
  String get notesChooseCategory => 'श्रेणी चुनें';

  @override
  String get notesChooseCategoryBody =>
      'अपनी परीक्षा श्रेणी चुनें, फिर परीक्षा और पढ़ने का टॉपिक।';

  @override
  String get notesChooseTopic => 'टॉपिक चुनें';

  @override
  String notesChooseTopicBody(String exam) {
    return 'नोट्स बनाने के लिए $exam सिलेबस से एक टॉपिक चुनें।';
  }

  @override
  String get createNotesTitle => 'नोट्स बनाएँ';

  @override
  String get notesExam => 'परीक्षा';

  @override
  String get notesSubject => 'विषय';

  @override
  String get notesTopic => 'टॉपिक';

  @override
  String get notesLevel => 'व्याख्या का स्तर';

  @override
  String get noteLevelBasic => 'बेसिक';

  @override
  String get noteLevelExam => 'परीक्षा स्तर';

  @override
  String get noteLevelAdvanced => 'एडवांस्ड';

  @override
  String get notesSections => 'नोट्स में शामिल करें';

  @override
  String get notesSectionsReset => 'रीसेट';

  @override
  String get secExplanation => 'विस्तृत अवधारणा व्याख्या';

  @override
  String get secDefinitions => 'परिभाषाएँ';

  @override
  String get secExamples => 'वास्तविक जीवन के उदाहरण';

  @override
  String get secStepByStep => 'चरण-दर-चरण व्याख्या';

  @override
  String get secDiagrams => 'डायग्राम और फ्लोचार्ट';

  @override
  String get secGraphs => 'ग्राफ़ (जहाँ उपयोगी हो)';

  @override
  String get secFormulas => 'सूत्र और तालिकाएँ';

  @override
  String get secTips => 'परीक्षा टिप्स और ट्रिक्स';

  @override
  String get secMistakes => 'आम गलतियाँ';

  @override
  String get secKeyPoints => 'महत्वपूर्ण परीक्षा बिंदु';

  @override
  String get secRevision => 'त्वरित रिवीजन नोट्स';

  @override
  String get secMcqs => 'व्याख्या सहित टॉपिक MCQ';

  @override
  String get notesPickOneSection => 'कम से कम एक भाग चुनें।';

  @override
  String get generateNotes => 'पूरे नोट्स बनाएँ';

  @override
  String get generatingNotes =>
      'आपके नोट्स लिखे जा रहे हैं… इसमें एक मिनट तक लग सकता है।';

  @override
  String get notesFailed => 'नोट्स नहीं बन सके। कुछ भी सेव नहीं हुआ।';

  @override
  String get notesSaved => 'आपकी लाइब्रेरी में सेव हो गया';

  @override
  String get notesContents => 'विषय-सूची';

  @override
  String get nOverview => 'टॉपिक परिचय';

  @override
  String get nDetailed => 'विस्तृत व्याख्या';

  @override
  String get nConcepts => 'महत्वपूर्ण अवधारणाएँ';

  @override
  String get nExamples => 'उदाहरण';

  @override
  String get nDiagrams => 'डायग्राम, फ्लोचार्ट और ग्राफ़';

  @override
  String get nFormulas => 'सूत्र और तालिकाएँ';

  @override
  String get nTips => 'परीक्षा टिप्स और ट्रिक्स';

  @override
  String get nMistakes => 'आम गलतियाँ';

  @override
  String get nKeyPoints => 'महत्वपूर्ण परीक्षा बिंदु';

  @override
  String get nRevision => 'त्वरित रिवीजन';

  @override
  String get nMcqs => 'महत्वपूर्ण प्रश्न और MCQ';

  @override
  String get nNext => 'आगे क्या पढ़ें';

  @override
  String noteStep(int n) {
    return 'चरण $n';
  }

  @override
  String noteAnswer(String answer) {
    return 'उत्तर: $answer';
  }

  @override
  String get noteShowAnswer => 'उत्तर दिखाएँ';

  @override
  String get noteHideAnswer => 'उत्तर छिपाएँ';

  @override
  String get noteNotFound => 'यह नोट नहीं खुल सका।';

  @override
  String get noteExpandAll => 'सब खोलें';

  @override
  String get noteCollapseAll => 'सब बंद करें';

  @override
  String get myPracticeSets => 'मेरे अभ्यास सेट';

  @override
  String get myStudyNotes => 'मेरे स्टडी नोट्स';

  @override
  String notesLibraryTitle(String category) {
    return '$category नोट्स';
  }

  @override
  String notesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count नोट्स',
      one: '1 नोट',
      zero: 'अभी कोई नोट्स नहीं',
    );
    return '$_temp0';
  }

  @override
  String get searchNotesHint => 'टॉपिक, विषय या परीक्षा से खोजें';

  @override
  String notesEmptyTitle(String category) {
    return 'अभी कोई $category नोट्स नहीं';
  }

  @override
  String get notesEmptyBody =>
      'किसी भी टॉपिक के AI स्टडी नोट्स बनाएँ — वे यहाँ अपने-आप सेव होंगे।';

  @override
  String get noMatchingNotes => 'इन फ़िल्टर से कोई नोट्स नहीं मिले';

  @override
  String get createNotesCta => 'नोट्स बनाएँ';

  @override
  String noteCreatedOn(String date) {
    return '$date को बनाया';
  }

  @override
  String get noteBookmark => 'बुकमार्क करें';

  @override
  String get noteRemoveBookmark => 'बुकमार्क हटाएँ';

  @override
  String get noteBookmarked => 'नोट बुकमार्क हो गया';

  @override
  String get noteUnbookmarked => 'बुकमार्क हटा दिया';

  @override
  String get noteMoreActions => 'और विकल्प';

  @override
  String get personalNote => 'व्यक्तिगत नोट';

  @override
  String get personalNoteHint => 'अपने पॉइंट, शॉर्टकट या संदेह लिखें…';

  @override
  String get personalNoteAdd => 'व्यक्तिगत नोट जोड़ें';

  @override
  String get personalNoteEdit => 'बदलें';

  @override
  String get personalNoteSaved => 'व्यक्तिगत नोट सेव हो गया';

  @override
  String get noteSave => 'सेव करें';

  @override
  String get noteDelete => 'नोट हटाएँ';

  @override
  String get noteDeleteTitle => 'यह नोट हटाएँ?';

  @override
  String get noteDeleteBody =>
      'यह नोट और इस पर आपका व्यक्तिगत नोट हमेशा के लिए हट जाएगा।';

  @override
  String get noteDeleted => 'नोट हटा दिया गया';

  @override
  String get quickRevision => 'त्वरित रिवीजन';

  @override
  String get flashcards => 'फ्लैशकार्ड';

  @override
  String get flashcardTapToFlip => 'उत्तर देखने के लिए कार्ड पर टैप करें';

  @override
  String flashcardCount(int n, int total) {
    return '$n / $total';
  }

  @override
  String get flashcardPrev => 'पिछला';

  @override
  String get flashcardNext => 'अगला';

  @override
  String get noFlashcards =>
      'इस नोट में फ्लैशकार्ड बनाने लायक अवधारणाएँ या सूत्र नहीं हैं।';

  @override
  String get noRevision => 'इस नोट में रिवीजन पॉइंट नहीं हैं।';

  @override
  String get notesViewAll => 'सभी';

  @override
  String get notesViewBookmarked => 'बुकमार्क';

  @override
  String get notesViewPersonal => 'व्यक्तिगत नोट्स';

  @override
  String get noBookmarkedNotes => 'यहाँ अभी कोई बुकमार्क नोट नहीं';

  @override
  String get noBookmarkedNotesBody =>
      'किसी नोट पर बुकमार्क आइकन टैप करें, वह यहाँ दिखेगा।';

  @override
  String get noPersonalNotes => 'यहाँ अभी कोई व्यक्तिगत नोट नहीं';

  @override
  String get noPersonalNotesBody =>
      'कोई नोट खोलें और अपने पॉइंट जोड़ें — वे यहाँ दिखेंगे।';

  @override
  String get historyTitle => 'अभ्यास इतिहास';

  @override
  String get historyEmpty =>
      'अभी कोई प्रयास नहीं। इतिहास बनाने के लिए यह सेट हल करें।';

  @override
  String historyAttempt(int n) {
    return 'प्रयास $n';
  }

  @override
  String historyLine(String score, String max, String percent) {
    return 'स्कोर $score/$max · सटीकता $percent';
  }

  @override
  String get learningPath => 'लर्निंग पाथ';

  @override
  String get openLearningPath => 'लर्निंग पाथ';

  @override
  String learningPathProgress(int done, int total) {
    return '$total में से $done टॉपिक पूरे';
  }

  @override
  String learningTopicPosition(int n, int total) {
    return 'टॉपिक $n / $total';
  }

  @override
  String get markCompleted => 'पूरा हुआ चिह्नित करें';

  @override
  String get markedCompleted => 'पूरा हुआ चिह्नित किया';

  @override
  String get markedNotCompleted => 'अधूरा चिह्नित किया';

  @override
  String get continueNextTopic => 'अगले टॉपिक पर जाएँ';

  @override
  String get statusCompleted => 'पूरा';

  @override
  String get statusCurrent => 'वर्तमान';

  @override
  String get statusUpcoming => 'आगामी';

  @override
  String get notesReady => 'नोट्स तैयार';

  @override
  String get allTopicsCompleted => 'सभी टॉपिक पूरे — बहुत बढ़िया!';

  @override
  String get nextTopicHint => 'नोट्स बनाने के लिए टॉपिक पर टैप करें';

  @override
  String get errorAiQuota =>
      'आज की AI सीमा पूरी हो गई है। आपका चयन सुरक्षित है — कृपया बाद में फिर प्रयास करें।';

  @override
  String get sampleContentLabel =>
      'डेवलपमेंट सैंपल — प्लेसहोल्डर सामग्री। AI से बनी नहीं, सत्यापित अध्ययन सामग्री नहीं।';

  @override
  String get outlineDraft => 'ड्राफ्ट रूपरेखा — समीक्षा में';

  @override
  String outlineProgress(int done, int total) {
    return '$total में से $done सेक्शन पूरे';
  }

  @override
  String get outlineContinue => 'जारी रखें';

  @override
  String get outlineCoverageComplete => 'सभी सेक्शन पूरे';

  @override
  String get learningModeQuick => 'त्वरित रिवीजन';

  @override
  String get learningModeDetailed => 'विस्तृत';

  @override
  String get learningModeComplete => 'पूर्ण तैयारी';

  @override
  String get sectionStatePending => 'शुरू नहीं';

  @override
  String get sectionStateGenerated => 'पढ़ने के लिए तैयार';

  @override
  String get sectionStateCompleted => 'पूरा';

  @override
  String get sectionStateFailed => 'लोड नहीं हुआ — फिर से टैप करें';

  @override
  String get sectionRecommended => 'अनुशंसित';

  @override
  String get sectionAiSuggested => 'AI-सुझाया';

  @override
  String get sectionOftenTested => 'अक्सर पूछा जाता है';

  @override
  String get sectionPreparing => 'यह सेक्शन तैयार हो रहा है…';

  @override
  String get sectionMarkComplete => 'पूरा करें';

  @override
  String get sectionMarkedComplete => 'पूरा';

  @override
  String get sectionPrevious => 'पिछला';

  @override
  String get sectionNext => 'अगला';

  @override
  String sectionOf(int index, int total) {
    return 'सेक्शन $index / $total';
  }

  @override
  String get limitDailyAiTitle => 'आज का AI सेट इस्तेमाल हो गया';

  @override
  String limitDailyAiBody(int max) {
    return 'आपके प्लान में प्रतिदिन $max AI-जनित प्रैक्टिस सेट शामिल हैं। आप अभी भी प्रश्न बैंक से अभ्यास कर सकते हैं, या अधिक AI सेट के लिए Premium लें।';
  }

  @override
  String get limitAiNotInPlanTitle => 'AI प्रश्न Premium सुविधा है';

  @override
  String get limitAiNotInPlanBody =>
      'आपका प्लान प्रश्न बैंक का उपयोग करता है। नए AI प्रश्नों के लिए Premium लें।';

  @override
  String get planBadgeFree => 'FREE';

  @override
  String get planBadgePro => 'PREMIUM';

  @override
  String get practiceTypeTitle => 'अभ्यास का प्रकार';

  @override
  String get practiceTypeQuick => 'त्वरित अभ्यास';

  @override
  String get practiceTypeQuickHint =>
      'इस परीक्षा के सभी विषयों से मिले-जुले प्रश्न';

  @override
  String get practiceTypeTopics => 'टॉपिक-वार';

  @override
  String get practiceTypeTopicsHint => 'विषय और टॉपिक चुनें';

  @override
  String get questionSourceTitle => 'प्रश्नों का स्रोत';

  @override
  String get sourceBank => 'प्रश्न बैंक';

  @override
  String get sourceBankHint => 'संग्रहीत अभ्यास प्रश्न';

  @override
  String get sourceAi => 'AI-जनित';

  @override
  String get sourceAiHint => 'आपके लिए नए प्रश्न';

  @override
  String get sourceAiNote =>
      'AI-जनित अभ्यास प्रश्न — पिछले वर्ष के प्रश्नपत्र नहीं।';

  @override
  String usageSetsLeft(int left, int total) {
    return 'आज $total में से $left प्रैक्टिस सेट बाकी';
  }

  @override
  String usageQuestionsLeft(int left) {
    return 'आज $left प्रश्न बाकी (फेयर यूज़)';
  }

  @override
  String aiCreditsLeft(int left) {
    return 'आज बचे AI सेट: $left';
  }

  @override
  String get aiCreditsIncluded => 'AI सेट शामिल';

  @override
  String startPracticeCount(int count) {
    return 'अभ्यास शुरू करें – $count प्रश्न';
  }

  @override
  String generateAiCount(int count) {
    return 'AI प्रश्न बनाएँ – $count प्रश्न';
  }

  @override
  String get searchTopics => 'टॉपिक खोजें';

  @override
  String get noTopicsMatch => 'कोई टॉपिक नहीं मिला';

  @override
  String get customCount => 'कस्टम';

  @override
  String get customCountTitle => 'प्रश्नों की संख्या';

  @override
  String customCountHint(int max) {
    return '1 से $max के बीच';
  }

  @override
  String get apply => 'लागू करें';

  @override
  String get bankInsufficientTitle => 'पर्याप्त संग्रहीत प्रश्न नहीं';

  @override
  String bankInsufficientBody(int available, int requested) {
    return 'आपके चयन से केवल $available संग्रहीत प्रश्न मेल खाते हैं। आपने $requested माँगे।';
  }

  @override
  String get bankNoneBody =>
      'आपके चयन से अभी कोई संग्रहीत प्रश्न मेल नहीं खाता।';

  @override
  String bankUseAvailable(int available) {
    return '$available प्रश्नों का अभ्यास करें';
  }

  @override
  String get bankUseAi => 'AI-जनित प्रश्न उपयोग करें';

  @override
  String get changeSelection => 'चयन बदलें';

  @override
  String lastPracticeDetails(int count, String level) {
    return '$count प्रश्न · $level';
  }

  @override
  String get questionsLabel => 'प्रश्न';

  @override
  String get aiQuestionsBadge => 'AI-जनित';

  @override
  String get bankQuestionsBadge => 'प्रश्न बैंक';

  @override
  String get nObjectives => 'सीखने के उद्देश्य';

  @override
  String get nTimeline => 'समयरेखा';

  @override
  String get nSql => 'SQL उदाहरण';

  @override
  String get nSqlOutput => 'अपेक्षित आउटपुट';

  @override
  String get nDerivations => 'व्युत्पत्ति';

  @override
  String get nKeyFacts => 'महत्वपूर्ण तथ्य';

  @override
  String get nPractice => 'अभ्यास प्रश्न';

  @override
  String get nRelated => 'संबंधित अवधारणाएँ';

  @override
  String get nFurther => 'आगे क्या पढ़ें';

  @override
  String get showAnswer => 'उत्तर देखें';

  @override
  String get treeNextRecommended => 'अगला सुझाया गया';

  @override
  String treeSectionsProgress(int done, int total) {
    return '$total में से $done सेक्शन पढ़े';
  }

  @override
  String treeContentReady(int ready, int total) {
    return 'सामग्री तैयार: $total में से $ready';
  }

  @override
  String get contentReady => 'सामग्री तैयार';

  @override
  String get contentNotGenerated => 'अभी तैयार नहीं';

  @override
  String get contentGenerating => 'तैयार हो रही है';

  @override
  String get contentIncomplete => 'अधूरी — फिर से प्रयास करें';

  @override
  String get contentFailed => 'तैयार नहीं हो सकी';

  @override
  String get progressStudied => 'पढ़ लिया';

  @override
  String outlineContentCoverage(int ready, int total) {
    return 'सामग्री कवरेज: $total में से $ready सेक्शन तैयार';
  }

  @override
  String outlineYourProgress(int done, int total) {
    return 'आपकी प्रगति: $total में से $done सेक्शन पढ़े';
  }

  @override
  String get sectionGeneratingTitle => 'यह सेक्शन तैयार हो रहा है';

  @override
  String get sectionGeneratingBody =>
      'यह अभी तैयार किया जा रहा है। कुछ सेकंड बाद फिर देखें।';

  @override
  String get checkAgain => 'फिर देखें';

  @override
  String get errorContentIncomplete =>
      'यह सेक्शन अभी हमारे गुणवत्ता मानक तक पूरा नहीं हो सका। कुछ भी सहेजा नहीं गया — कृपया फिर से प्रयास करें।';

  @override
  String sectionMissingList(String items) {
    return 'अभी बाकी: $items';
  }

  @override
  String get statusAiChecked => 'AI द्वारा जाँचा गया · विशेषज्ञ समीक्षा नहीं';

  @override
  String get statusReviewed => 'विशेषज्ञ द्वारा समीक्षित';

  @override
  String get statusUnderReview => 'प्रीव्यू — समीक्षा बाकी';

  @override
  String get statusFactsUnverified => 'तथ्य स्वतंत्र रूप से सत्यापित नहीं';

  @override
  String get statusStructureOnly =>
      'केवल संरचना जाँची गई (कवरेज सूची अभी नहीं)';

  @override
  String get draftLabel => 'ड्राफ्ट';

  @override
  String get recContinue => 'जहाँ छोड़ा था वहीं से जारी रखें';

  @override
  String get recRevise => 'इन टॉपिक्स को दोहराएँ';

  @override
  String recAccuracy(int pct, int attempted) {
    return 'अभ्यास में $pct% सटीकता ($attempted प्रश्न)';
  }

  @override
  String get recStudyFirst => 'नोट्स पढ़ें';

  @override
  String get recReviseNotes => 'नोट्स दोहराएँ';

  @override
  String progressTopicsDone(int done, int total) {
    return '$total में से $done टॉपिक पूरे';
  }

  @override
  String prepTitle(String category) {
    return '$category तैयारी';
  }

  @override
  String get stepExam => 'परीक्षा';

  @override
  String get chooseSubjectFirst => 'टॉपिक देखने के लिए विषय चुनें';

  @override
  String get clearTopics => 'हटाएँ';

  @override
  String showAllTopics(int count) {
    return 'सभी देखें ($count)';
  }

  @override
  String get showFewer => 'कम देखें';

  @override
  String get moreQuestionsPremium =>
      'प्रति सेट 20, 30 और 40 प्रश्न Premium में उपलब्ध हैं।';

  @override
  String get conceptSearchHint => 'अध्याय और अवधारणाएँ खोजें';

  @override
  String get clearSearch => 'खोज साफ़ करें';

  @override
  String get conceptNoMatch => 'आपकी खोज से कोई अध्याय या अवधारणा नहीं मिली।';

  @override
  String get expand => 'खोलें';

  @override
  String get collapse => 'बंद करें';

  @override
  String get stepConcepts => 'अध्याय और अवधारणाएँ';

  @override
  String conceptsSelected(int count) {
    return '$count अवधारणाएँ';
  }

  @override
  String get selectConceptHint => 'कम से कम एक अध्याय या अवधारणा चुनें';

  @override
  String get notesExactConcept => 'सटीक अवधारणा चुनें';

  @override
  String get notesExactConceptBody =>
      'रेलवे गणित के किसी एक अध्याय, विषय या अवधारणा के नोट्स';

  @override
  String get notesConceptPickerTitle => 'गणित की अवधारणाएँ';

  @override
  String get syllabusUnverifiedNote =>
      'पाठ्यक्रम परीक्षा-तैयारी स्रोतों पर आधारित; आधिकारिक सत्यापन बाकी है।';

  @override
  String get summaryAll => 'सभी';

  @override
  String summaryMore(int count) {
    return '+$count और';
  }
}
