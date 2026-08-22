// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'لخسلي';

  @override
  String get welcomeToApp => 'مرحباً بك في\nلخسلي';

  @override
  String get onboardingDescription =>
      'مستقبل إدارة خدمات السيارات هنا. تابع طلباتك، وأدر ورشتك، وتواصل مع مقدمي الخدمات بسلاسة.';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get welcomeBack => 'مرحباً بعودتك';

  @override
  String get signInSubtitle => 'سجّل الدخول للمتابعة إلى حسابك';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get password => 'كلمة المرور';

  @override
  String get passwordHint => 'أدخل كلمة المرور';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟ ';

  @override
  String get createOne => 'أنشئ واحداً';

  @override
  String get pleaseEnterEmail => 'يرجى إدخال بريدك الإلكتروني';

  @override
  String get pleaseEnterValidEmail => 'يرجى إدخال عنوان بريد إلكتروني صحيح';

  @override
  String get pleaseEnterPassword => 'يرجى إدخال كلمة المرور';

  @override
  String get unknownError => 'حدث خطأ غير معروف.';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get joinUs => 'انضم إلينا!';

  @override
  String get firstName => 'الاسم الأول';

  @override
  String get lastName => 'اسم العائلة';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get iAmA => 'أنا:';

  @override
  String get client => 'عميل';

  @override
  String get technician => 'فني';

  @override
  String get creatingAccount => 'جارٍ إنشاء الحساب...';

  @override
  String get pleaseEnterFirstName => 'يرجى إدخال الاسم الأول';

  @override
  String get pleaseEnterLastName => 'يرجى إدخال اسم العائلة';

  @override
  String get pleaseEnterPhoneNumber => 'يرجى إدخال رقم الهاتف';

  @override
  String get pleaseEnterAPassword => 'يرجى إدخال كلمة المرور';

  @override
  String get passwordMinLength =>
      'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get addYourCar => 'أضف سيارتك';

  @override
  String get tellUsAboutYourCar => 'أخبرنا عن سيارتك';

  @override
  String get carType => 'نوع السيارة';

  @override
  String get carModel => 'موديل السيارة';

  @override
  String get color => 'اللون';

  @override
  String get plateNumber => 'رقم اللوحة';

  @override
  String get carYearOptional => 'سنة الصنع (اختياري)';

  @override
  String get saving => 'جارٍ الحفظ...';

  @override
  String get saveAndContinue => 'حفظ ومتابعة';

  @override
  String get carSavedSuccessfully => 'تم حفظ السيارة بنجاح!';

  @override
  String get pleaseEnterCarType => 'يرجى إدخال نوع السيارة';

  @override
  String get pleaseEnterCarModel => 'يرجى إدخال موديل السيارة';

  @override
  String get pleaseEnterColor => 'يرجى إدخال اللون';

  @override
  String get pleaseEnterPlateNumber => 'يرجى إدخال رقم اللوحة';

  @override
  String get forgotPasswordTitle => 'نسيت كلمة المرور';

  @override
  String get resetYourPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get resetPasswordDescription =>
      'أدخل بريدك الإلكتروني وسنرسل لك رابطاً لإعادة تعيين كلمة المرور.';

  @override
  String get sendResetLink => 'إرسال رابط إعادة التعيين';

  @override
  String get passwordResetSent =>
      'تم إرسال رابط إعادة تعيين كلمة المرور! يرجى التحقق من بريدك الإلكتروني.';

  @override
  String get home => 'الرئيسية';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get myOrders => 'طلباتي';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get notLoggedIn => 'غير مسجل الدخول.';

  @override
  String get noEmail => 'لا يوجد بريد إلكتروني';

  @override
  String get notificationsComingSoon => 'الإشعارات قريباً.';

  @override
  String get whatServiceDoYouNeed => 'ما الخدمة التي تحتاجها؟';

  @override
  String get mechanical => 'ميكانيكا';

  @override
  String get electrical => 'كهرباء';

  @override
  String get diagnostics => 'تشخيص';

  @override
  String get spareParts => 'قطع غيار';

  @override
  String welcomeUser(String name) {
    return 'مرحباً، $name!';
  }

  @override
  String logoutFailed(String error) {
    return 'فشل تسجيل الخروج: $error';
  }

  @override
  String errorPrefix(String error) {
    return 'خطأ: $error';
  }

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get updateYourInformation => 'تحديث معلوماتك';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get updateProfile => 'تحديث الملف الشخصي';

  @override
  String get profileUpdatedSuccessfully => 'تم تحديث الملف الشخصي بنجاح!';

  @override
  String get pleaseEnterName => 'يرجى إدخال اسمك';

  @override
  String get selectLocation => 'اختر الموقع';

  @override
  String get liveTracking => 'تتبع مباشر';

  @override
  String get loadingMap => 'جارٍ تحميل الخريطة...';

  @override
  String get distance => 'المسافة';

  @override
  String get eta => 'الوقت المتوقع';

  @override
  String get myLocation => 'موقعي';

  @override
  String get confirmLocation => 'تأكيد الموقع';

  @override
  String get locationServicesDisabled => 'خدمات الموقع معطلة. يرجى تفعيل GPS.';

  @override
  String get locationPermissionRequired => 'إذن الموقع مطلوب للمتابعة.';

  @override
  String get locationPermissionDeniedForever =>
      'إذن الموقع مرفوض بشكل دائم. فعّله من إعدادات التطبيق.';

  @override
  String get unableToGetPosition => 'تعذر الحصول على الموقع الحالي.';

  @override
  String get pleaseSelectLocation => 'يرجى اختيار موقع الالتقاط.';

  @override
  String get selectInsideCairoGiza =>
      'يرجى اختيار موقع داخل القاهرة أو الجيزة.';

  @override
  String get orderCreatedSuccessfully => 'تم إنشاء الطلب بنجاح!';

  @override
  String failedToCreateOrder(String error) {
    return 'فشل إنشاء الطلب: $error';
  }

  @override
  String get selectedService => 'الخدمة المحددة';

  @override
  String get selectVehicle => 'اختر المركبة';

  @override
  String get noVehiclesFound => 'لا توجد مركبات';

  @override
  String get addAVehicle => 'أضف مركبة';

  @override
  String get problemDescription => 'وصف المشكلة';

  @override
  String get describeIssue => 'صِف المشكلة التي تواجهها...';

  @override
  String get pleaseDescribeProblem => 'يرجى وصف المشكلة.';

  @override
  String get uploadImageOptional => 'رفع صورة (اختياري)';

  @override
  String get tapToUploadImage => 'اضغط لرفع صورة';

  @override
  String get imageFormatHint => 'JPG, PNG حتى 10 ميجابايت';

  @override
  String get uploaded => 'تم الرفع';

  @override
  String get continueButton => 'متابعة';

  @override
  String failedToPickImage(String error) {
    return 'فشل اختيار الصورة: $error';
  }

  @override
  String failedToUploadImage(String error) {
    return 'فشل رفع الصورة: $error';
  }

  @override
  String get pleaseSelectVehicle => 'يرجى اختيار مركبة.';

  @override
  String failedToLoadVehicles(String error) {
    return 'فشل تحميل المركبات: $error';
  }

  @override
  String get goBack => 'عودة';

  @override
  String get payment => 'الدفع';

  @override
  String get paymentSummary => 'ملخص الدفع';

  @override
  String get service => 'الخدمة';

  @override
  String get vehicle => 'المركبة';

  @override
  String get amountDue => 'المبلغ المستحق';

  @override
  String get payNow => 'ادفع الآن';

  @override
  String get choosePaymentMethod => 'اختر طريقة الدفع';

  @override
  String get wallet => 'المحفظة';

  @override
  String get payFromWallet => 'ادفع من رصيد محفظتك';

  @override
  String get card => 'بطاقة';

  @override
  String get payWithCard => 'ادفع ببطاقة محفوظة';

  @override
  String get pleaseSelectPaymentMethod => 'يرجى اختيار طريقة الدفع.';

  @override
  String get paymentSuccessful => 'تم الدفع بنجاح. طلبك مدفوع الآن.';

  @override
  String failedToProcessPayment(String error) {
    return 'فشل معالجة الدفع: $error';
  }

  @override
  String get nA => 'غير متاح';

  @override
  String get loadingOrders => 'جارٍ تحميل الطلبات...';

  @override
  String couldNotLoadOrders(String error) {
    return 'تعذر تحميل الطلبات: $error';
  }

  @override
  String get noOrdersYet => 'لا توجد طلبات بعد';

  @override
  String get noOrdersDescription => 'اطلب خدمة لترى طلباتك هنا';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get accepted => 'مقبول';

  @override
  String get technicianOnTheWay => 'الفني في الطريق';

  @override
  String get technicianArrived => 'وصل الفني';

  @override
  String get inProgress => 'قيد التنفيذ';

  @override
  String get finished => 'منتهي';

  @override
  String get completed => 'مكتمل';

  @override
  String get paid => 'مدفوع';

  @override
  String get unknown => 'غير معروف';

  @override
  String get date => 'التاريخ';

  @override
  String get paymentStatus => 'حالة الدفع';

  @override
  String get trackTechnician => 'تتبع الفني';

  @override
  String get thisOrderIsPaid => 'هذا الطلب مدفوع بالفعل.';

  @override
  String get invalidOrderData => 'بيانات الطلب غير صالحة.';

  @override
  String failedToLoadOrders(String error) {
    return 'فشل تحميل الطلبات: $error';
  }

  @override
  String get technicianHome => 'الفني';

  @override
  String get status => 'الحالة';

  @override
  String get online => 'متصل';

  @override
  String get offline => 'غير متصل';

  @override
  String get receivingRequests => 'يستقبل طلبات خدمة جديدة';

  @override
  String get tapToGoOnline => 'اضغط للاتصال واستقبال الطلبات';

  @override
  String get todaysStatistics => 'إحصائيات اليوم';

  @override
  String get rating => 'التقييم';

  @override
  String get quickActions => 'إجراءات سريعة';

  @override
  String get incomingRequests => 'الطلبات الواردة';

  @override
  String get incomingRequestsSubtitle => 'طلبات خدمة جديدة من العملاء';

  @override
  String get acceptedRequests => 'الطلبات المقبولة';

  @override
  String get acceptedRequestsSubtitle => 'وظائف الخدمة النشطة لديك';

  @override
  String get completedJobs => 'الوظائف المكتملة';

  @override
  String get completedJobsSubtitle => 'سجل الخدمات المنتهية';

  @override
  String get noActiveJobs => 'لا توجد وظائف نشطة';

  @override
  String get noActiveJobsMessage => 'اقبل طلباً لبدء العمل على وظيفة خدمة.';

  @override
  String get viewIncoming => 'عرض الوارد';

  @override
  String get activeJob => 'وظيفة نشطة';

  @override
  String get details => 'التفاصيل';

  @override
  String get viewJob => 'عرض الوظيفة';

  @override
  String kmAway(String distance) {
    return '$distance كم';
  }

  @override
  String get jobDetails => 'تفاصيل الوظيفة';

  @override
  String get loadingJobDetails => 'جارٍ تحميل تفاصيل الوظيفة...';

  @override
  String failedToLoadJob(String error) {
    return 'فشل تحميل الوظيفة: $error';
  }

  @override
  String get jobNotFound => 'الوظيفة غير موجودة';

  @override
  String get viewLiveStatus => 'عرض الحالة المباشرة';

  @override
  String get liveStatus => 'الحالة المباشرة';

  @override
  String get customer => 'العميل';

  @override
  String get problem => 'المشكلة';

  @override
  String get progress => 'التقدم';

  @override
  String get navigate => 'تنقل';

  @override
  String get startDriving => 'بدء القيادة';

  @override
  String get statusUpdatedToDriving => 'تم تحديث الحالة إلى في الطريق';

  @override
  String get markArrived => 'تأكيد الوصول';

  @override
  String get statusUpdatedToArrived => 'تم تحديث الحالة إلى وصلت';

  @override
  String get startWorking => 'بدء العمل';

  @override
  String get statusUpdatedToWorking => 'تم تحديث الحالة إلى قيد التنفيذ';

  @override
  String get finishJob => 'إنهاء الوظيفة';

  @override
  String get jobNotFoundTitle => 'الوظيفة غير موجودة';

  @override
  String errorPrefixTitle(String error) {
    return 'خطأ: $error';
  }

  @override
  String get serviceSummary => 'ملخص الخدمة';

  @override
  String get serviceNotes => 'ملاحظات الخدمة';

  @override
  String get describeWorkDone => 'صِف العمل المنجز...';

  @override
  String get totalAmount => 'المبلغ الإجمالي';

  @override
  String get enterTotalAmount => 'أدخل المبلغ الإجمالي';

  @override
  String get submitting => 'جارٍ الإرسال...';

  @override
  String get pleaseEnterServiceNotes => 'يرجى إدخال ملاحظات الخدمة';

  @override
  String get pleaseEnterTotalAmount => 'يرجى إدخال المبلغ الإجمالي';

  @override
  String get pleaseEnterValidAmount => 'يرجى إدخال مبلغ صحيح';

  @override
  String get jobFinishedSuccessfully => 'تم إنهاء الوظيفة بنجاح';

  @override
  String failedToFinishJob(String error) {
    return 'فشل إنهاء الوظيفة: $error';
  }

  @override
  String get noIncomingRequests => 'لا توجد طلبات واردة';

  @override
  String get noIncomingRequestsMessage =>
      'ستظهر طلبات الخدمة الجديدة هنا في الوقت الفعلي.';

  @override
  String get refresh => 'تحديث';

  @override
  String get loadingRequests => 'جارٍ تحميل الطلبات...';

  @override
  String failedToLoadRequests(String error) {
    return 'فشل تحميل الطلبات: $error';
  }

  @override
  String get requestAccepted => 'تم قبول الطلب';

  @override
  String failedToAccept(String error) {
    return 'فشل القبول: $error';
  }

  @override
  String get requestRejected => 'تم رفض الطلب';

  @override
  String get reject => 'رفض';

  @override
  String get accept => 'قبول';

  @override
  String get newRequest => 'طلب جديد';

  @override
  String get justNow => 'الآن';

  @override
  String minutesAgo(int count) {
    return 'منذ $count د';
  }

  @override
  String hoursAgo(int count) {
    return 'منذ $count س';
  }

  @override
  String get noCompletedJobs => 'لا توجد وظائف مكتملة';

  @override
  String get noCompletedJobsMessage =>
      'ستظهر وظائفك المنتهية هنا بمجرد اكتمالها.';

  @override
  String get viewActiveJobs => 'عرض الوظائف النشطة';

  @override
  String get loadingJobs => 'جارٍ تحميل الوظائف...';

  @override
  String failedToLoadJobs(String error) {
    return 'فشل تحميل الوظائف: $error';
  }

  @override
  String get totalEarned => 'الإجمالي المكتسب';

  @override
  String get somethingWentWrong => 'حدث خطأ ما';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get invalidMapData => 'بيانات الخريطة غير صالحة.';

  @override
  String get invalidPaymentData => 'بيانات الدفع غير صالحة.';

  @override
  String get invalidServiceRequestData => 'بيانات طلب الخدمة غير صالحة.';

  @override
  String get invalidLiveStatusData => 'بيانات الحالة المباشرة غير صالحة.';

  @override
  String get invalidFinishJobData => 'بيانات إنهاء الوظيفة غير صالحة.';

  @override
  String applicationFailedToStart(String error) {
    return 'فشل تشغيل التطبيق.\n\n$error';
  }

  @override
  String get language => 'اللغة';

  @override
  String get english => 'الإنجليزية';

  @override
  String get arabic => 'العربية';

  @override
  String get onTheWay => 'في الطريق';

  @override
  String get arrived => 'وصل';

  @override
  String get working => 'قيد العمل';
}
