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
  String get navSaved => 'सेव किए';

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
  String get weakTopics => 'कमजोर टॉपिक';

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
  String get savedEmptyTitle => 'अभी कोई सेव किया गया अभ्यास नहीं';

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
      'यह सेव किया गया सेट और इसकी समीक्षा हटा दी जाएगी। आपके अन्य प्रयास प्रभावित नहीं होंगे।';

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
}
