import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('ar')
  ];

  /// The application name/title
  ///
  /// In en, this message translates to:
  /// **'Lakhsly'**
  String get appTitle;

  /// Onboarding screen welcome title
  ///
  /// In en, this message translates to:
  /// **'Welcome to\nLakhsly'**
  String get welcomeToApp;

  /// Onboarding screen description text
  ///
  /// In en, this message translates to:
  /// **'The future of car service management is here. Track your orders, manage your garage, and connect with service providers seamlessly.'**
  String get onboardingDescription;

  /// Onboarding CTA button
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// Login screen title
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// Login screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue to your account'**
  String get signInSubtitle;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Email field hint text
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get emailHint;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Password field hint text
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// Forgot password link text
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// Sign in button text
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Register prompt text
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// Create account link text
  ///
  /// In en, this message translates to:
  /// **'Create one'**
  String get createOne;

  /// Email validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// Email format validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get pleaseEnterValidEmail;

  /// Password validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred.'**
  String get unknownError;

  /// Register screen title and button
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Register screen heading
  ///
  /// In en, this message translates to:
  /// **'Join Us!'**
  String get joinUs;

  /// First name field hint
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// Last name field hint
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// Phone number field hint
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// Confirm password field hint
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// User type selection label
  ///
  /// In en, this message translates to:
  /// **'I am a:'**
  String get iAmA;

  /// Client user type
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get client;

  /// Technician user type
  ///
  /// In en, this message translates to:
  /// **'Technician'**
  String get technician;

  /// Loading state for create account button
  ///
  /// In en, this message translates to:
  /// **'Creating Account...'**
  String get creatingAccount;

  /// First name validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your first name'**
  String get pleaseEnterFirstName;

  /// Last name validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your last name'**
  String get pleaseEnterLastName;

  /// Phone number validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get pleaseEnterPhoneNumber;

  /// Password required validation
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get pleaseEnterAPassword;

  /// Password length validation
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters long'**
  String get passwordMinLength;

  /// Confirm password mismatch error
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Add car screen title
  ///
  /// In en, this message translates to:
  /// **'Add Your Car'**
  String get addYourCar;

  /// Add car screen heading
  ///
  /// In en, this message translates to:
  /// **'Tell us about your car'**
  String get tellUsAboutYourCar;

  /// Car type field hint
  ///
  /// In en, this message translates to:
  /// **'Car Type'**
  String get carType;

  /// Car model field hint
  ///
  /// In en, this message translates to:
  /// **'Car Model'**
  String get carModel;

  /// Car color field hint
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// Plate number field hint
  ///
  /// In en, this message translates to:
  /// **'Plate Number'**
  String get plateNumber;

  /// Car year field hint
  ///
  /// In en, this message translates to:
  /// **'Car Year (optional)'**
  String get carYearOptional;

  /// Loading state for save button
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// Save and continue button
  ///
  /// In en, this message translates to:
  /// **'Save & Continue'**
  String get saveAndContinue;

  /// Success message after saving car
  ///
  /// In en, this message translates to:
  /// **'Car saved successfully!'**
  String get carSavedSuccessfully;

  /// Car type validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter the car type'**
  String get pleaseEnterCarType;

  /// Car model validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter the car model'**
  String get pleaseEnterCarModel;

  /// Color validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter the color'**
  String get pleaseEnterColor;

  /// Plate number validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter the plate number'**
  String get pleaseEnterPlateNumber;

  /// Forgot password screen title
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// Forgot password screen heading
  ///
  /// In en, this message translates to:
  /// **'Reset Your Password'**
  String get resetYourPassword;

  /// Forgot password description
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we will send you a link to reset your password.'**
  String get resetPasswordDescription;

  /// Send reset link button
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// Success message after sending reset link
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent! Please check your email.'**
  String get passwordResetSent;

  /// Home screen title
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Profile button tooltip
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Orders button tooltip and screen title
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// Logout button tooltip
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Text shown when user is not logged in
  ///
  /// In en, this message translates to:
  /// **'Not logged in.'**
  String get notLoggedIn;

  /// Fallback when email is null
  ///
  /// In en, this message translates to:
  /// **'No email'**
  String get noEmail;

  /// Notification feature placeholder
  ///
  /// In en, this message translates to:
  /// **'Notifications coming soon.'**
  String get notificationsComingSoon;

  /// Home screen service section header
  ///
  /// In en, this message translates to:
  /// **'What service do you need?'**
  String get whatServiceDoYouNeed;

  /// Mechanical service category
  ///
  /// In en, this message translates to:
  /// **'Mechanical'**
  String get mechanical;

  /// Electrical service category
  ///
  /// In en, this message translates to:
  /// **'Electrical'**
  String get electrical;

  /// Diagnostics service category
  ///
  /// In en, this message translates to:
  /// **'Diagnostics'**
  String get diagnostics;

  /// Spare parts service category
  ///
  /// In en, this message translates to:
  /// **'Spare Parts'**
  String get spareParts;

  /// Welcome message with user name
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}!'**
  String welcomeUser(String name);

  /// Logout error message
  ///
  /// In en, this message translates to:
  /// **'Logout failed: {error}'**
  String logoutFailed(String error);

  /// Error display prefix
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorPrefix(String error);

  /// Profile screen title
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Profile screen heading
  ///
  /// In en, this message translates to:
  /// **'Update Your Information'**
  String get updateYourInformation;

  /// Full name field label
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// Update profile button
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get updateProfile;

  /// Success message after profile update
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdatedSuccessfully;

  /// Name validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterName;

  /// Map screen title for location selection
  ///
  /// In en, this message translates to:
  /// **'Select Location'**
  String get selectLocation;

  /// Map screen title for tracking mode
  ///
  /// In en, this message translates to:
  /// **'Live Tracking'**
  String get liveTracking;

  /// Map loading message
  ///
  /// In en, this message translates to:
  /// **'Loading map...'**
  String get loadingMap;

  /// Distance label
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// Estimated time of arrival label
  ///
  /// In en, this message translates to:
  /// **'ETA'**
  String get eta;

  /// My location button tooltip
  ///
  /// In en, this message translates to:
  /// **'My Location'**
  String get myLocation;

  /// Confirm location button
  ///
  /// In en, this message translates to:
  /// **'Confirm Location'**
  String get confirmLocation;

  /// Error when location services are off
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled. Please enable GPS.'**
  String get locationServicesDisabled;

  /// Error when location permission denied
  ///
  /// In en, this message translates to:
  /// **'Location permission is required to continue.'**
  String get locationPermissionRequired;

  /// Error when location permission permanently denied
  ///
  /// In en, this message translates to:
  /// **'Location permission is permanently denied. Enable it in app settings.'**
  String get locationPermissionDeniedForever;

  /// Error when unable to get GPS position
  ///
  /// In en, this message translates to:
  /// **'Unable to get current position.'**
  String get unableToGetPosition;

  /// Error when no location selected
  ///
  /// In en, this message translates to:
  /// **'Please choose a pickup location.'**
  String get pleaseSelectLocation;

  /// Error when location outside allowed bounds
  ///
  /// In en, this message translates to:
  /// **'Please select a location inside Cairo or Giza.'**
  String get selectInsideCairoGiza;

  /// Success message after order creation
  ///
  /// In en, this message translates to:
  /// **'Order created successfully!'**
  String get orderCreatedSuccessfully;

  /// Order creation error
  ///
  /// In en, this message translates to:
  /// **'Failed to create order: {error}'**
  String failedToCreateOrder(String error);

  /// Service request screen section label
  ///
  /// In en, this message translates to:
  /// **'Selected Service'**
  String get selectedService;

  /// Vehicle selection section header
  ///
  /// In en, this message translates to:
  /// **'Select Vehicle'**
  String get selectVehicle;

  /// Empty state when no cars
  ///
  /// In en, this message translates to:
  /// **'No vehicles found'**
  String get noVehiclesFound;

  /// Add vehicle button
  ///
  /// In en, this message translates to:
  /// **'Add a vehicle'**
  String get addAVehicle;

  /// Problem description section header
  ///
  /// In en, this message translates to:
  /// **'Problem Description'**
  String get problemDescription;

  /// Problem description hint
  ///
  /// In en, this message translates to:
  /// **'Describe the issue you are experiencing...'**
  String get describeIssue;

  /// Problem description validation error
  ///
  /// In en, this message translates to:
  /// **'Please describe the problem.'**
  String get pleaseDescribeProblem;

  /// Upload image section header
  ///
  /// In en, this message translates to:
  /// **'Upload Image (optional)'**
  String get uploadImageOptional;

  /// Upload image placeholder text
  ///
  /// In en, this message translates to:
  /// **'Tap to upload an image'**
  String get tapToUploadImage;

  /// Image format hint
  ///
  /// In en, this message translates to:
  /// **'JPG, PNG up to 10MB'**
  String get imageFormatHint;

  /// Upload success label
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get uploaded;

  /// Continue button
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Image pick error
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image: {error}'**
  String failedToPickImage(String error);

  /// Image upload error
  ///
  /// In en, this message translates to:
  /// **'Failed to upload image: {error}'**
  String failedToUploadImage(String error);

  /// Vehicle selection validation error
  ///
  /// In en, this message translates to:
  /// **'Please select a vehicle.'**
  String get pleaseSelectVehicle;

  /// Vehicle load error
  ///
  /// In en, this message translates to:
  /// **'Failed to load vehicles: {error}'**
  String failedToLoadVehicles(String error);

  /// Go back button
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// Payment screen title
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// Payment summary card title
  ///
  /// In en, this message translates to:
  /// **'Payment Summary'**
  String get paymentSummary;

  /// Service label
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get service;

  /// Vehicle label
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get vehicle;

  /// Amount due label
  ///
  /// In en, this message translates to:
  /// **'Amount Due'**
  String get amountDue;

  /// Pay now button and badge
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get payNow;

  /// Payment method section header
  ///
  /// In en, this message translates to:
  /// **'Choose Payment Method'**
  String get choosePaymentMethod;

  /// Wallet payment method
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// Wallet payment description
  ///
  /// In en, this message translates to:
  /// **'Pay from your wallet balance'**
  String get payFromWallet;

  /// Card payment method
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get card;

  /// Card payment description
  ///
  /// In en, this message translates to:
  /// **'Pay with saved card'**
  String get payWithCard;

  /// Payment method validation error
  ///
  /// In en, this message translates to:
  /// **'Please select a payment method.'**
  String get pleaseSelectPaymentMethod;

  /// Payment success message
  ///
  /// In en, this message translates to:
  /// **'Payment successful. Your order is now paid.'**
  String get paymentSuccessful;

  /// Payment processing error
  ///
  /// In en, this message translates to:
  /// **'Failed to process payment: {error}'**
  String failedToProcessPayment(String error);

  /// Not available abbreviation
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get nA;

  /// Orders loading message
  ///
  /// In en, this message translates to:
  /// **'Loading orders...'**
  String get loadingOrders;

  /// Orders load error
  ///
  /// In en, this message translates to:
  /// **'Could not load orders: {error}'**
  String couldNotLoadOrders(String error);

  /// Empty orders state title
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get noOrdersYet;

  /// Empty orders state description
  ///
  /// In en, this message translates to:
  /// **'Request a service to see your orders here'**
  String get noOrdersDescription;

  /// Pending status label
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// Accepted status label
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// On the way status label
  ///
  /// In en, this message translates to:
  /// **'Technician on the Way'**
  String get technicianOnTheWay;

  /// Arrived status label
  ///
  /// In en, this message translates to:
  /// **'Technician Arrived'**
  String get technicianArrived;

  /// Working status label
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// Finished status label
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get finished;

  /// Completed status label
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// Paid status label
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// Unknown status label
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// Date label
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Payment status label
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentStatus;

  /// Track technician button
  ///
  /// In en, this message translates to:
  /// **'Track Technician'**
  String get trackTechnician;

  /// Message when order already paid
  ///
  /// In en, this message translates to:
  /// **'This order is already paid.'**
  String get thisOrderIsPaid;

  /// Invalid order error
  ///
  /// In en, this message translates to:
  /// **'Invalid order data.'**
  String get invalidOrderData;

  /// Orders load error snackbar
  ///
  /// In en, this message translates to:
  /// **'Failed to load orders: {error}'**
  String failedToLoadOrders(String error);

  /// Technician home screen title
  ///
  /// In en, this message translates to:
  /// **'Technician'**
  String get technicianHome;

  /// Status label
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// Online status
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// Offline status
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// Online status description
  ///
  /// In en, this message translates to:
  /// **'Receiving new service requests'**
  String get receivingRequests;

  /// Offline status description
  ///
  /// In en, this message translates to:
  /// **'Tap to go online and receive requests'**
  String get tapToGoOnline;

  /// Statistics section header
  ///
  /// In en, this message translates to:
  /// **'Today\'s Statistics'**
  String get todaysStatistics;

  /// Rating label
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// Quick actions section header
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// Incoming requests action title
  ///
  /// In en, this message translates to:
  /// **'Incoming Requests'**
  String get incomingRequests;

  /// Incoming requests action subtitle
  ///
  /// In en, this message translates to:
  /// **'New service requests from customers'**
  String get incomingRequestsSubtitle;

  /// Accepted requests action title and screen title
  ///
  /// In en, this message translates to:
  /// **'Accepted Requests'**
  String get acceptedRequests;

  /// Accepted requests action subtitle
  ///
  /// In en, this message translates to:
  /// **'Your active service jobs'**
  String get acceptedRequestsSubtitle;

  /// Completed jobs action title and screen title
  ///
  /// In en, this message translates to:
  /// **'Completed Jobs'**
  String get completedJobs;

  /// Completed jobs action subtitle
  ///
  /// In en, this message translates to:
  /// **'History of finished services'**
  String get completedJobsSubtitle;

  /// Empty accepted requests title
  ///
  /// In en, this message translates to:
  /// **'No Active Jobs'**
  String get noActiveJobs;

  /// Empty accepted requests description
  ///
  /// In en, this message translates to:
  /// **'Accept a request to start working on a service job.'**
  String get noActiveJobsMessage;

  /// View incoming requests button
  ///
  /// In en, this message translates to:
  /// **'View Incoming'**
  String get viewIncoming;

  /// Active job label
  ///
  /// In en, this message translates to:
  /// **'Active Job'**
  String get activeJob;

  /// Details label
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// View job button
  ///
  /// In en, this message translates to:
  /// **'View Job'**
  String get viewJob;

  /// Distance display
  ///
  /// In en, this message translates to:
  /// **'{distance} km away'**
  String kmAway(String distance);

  /// Job details screen title
  ///
  /// In en, this message translates to:
  /// **'Job Details'**
  String get jobDetails;

  /// Job details loading message
  ///
  /// In en, this message translates to:
  /// **'Loading job details...'**
  String get loadingJobDetails;

  /// Job load error
  ///
  /// In en, this message translates to:
  /// **'Failed to load job: {error}'**
  String failedToLoadJob(String error);

  /// Job not found message
  ///
  /// In en, this message translates to:
  /// **'Job not found'**
  String get jobNotFound;

  /// View live status button
  ///
  /// In en, this message translates to:
  /// **'View Live Status'**
  String get viewLiveStatus;

  /// Live status screen title
  ///
  /// In en, this message translates to:
  /// **'Live Status'**
  String get liveStatus;

  /// Customer section label
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// Problem section label
  ///
  /// In en, this message translates to:
  /// **'Problem'**
  String get problem;

  /// Progress section header
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// Navigate button
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get navigate;

  /// Start driving button
  ///
  /// In en, this message translates to:
  /// **'Start Driving'**
  String get startDriving;

  /// Status update success message
  ///
  /// In en, this message translates to:
  /// **'Status updated to Driving'**
  String get statusUpdatedToDriving;

  /// Mark arrived button
  ///
  /// In en, this message translates to:
  /// **'Mark Arrived'**
  String get markArrived;

  /// Status update success message
  ///
  /// In en, this message translates to:
  /// **'Status updated to Arrived'**
  String get statusUpdatedToArrived;

  /// Start working button
  ///
  /// In en, this message translates to:
  /// **'Start Working'**
  String get startWorking;

  /// Status update success message
  ///
  /// In en, this message translates to:
  /// **'Status updated to Working'**
  String get statusUpdatedToWorking;

  /// Finish job button and screen title
  ///
  /// In en, this message translates to:
  /// **'Finish Job'**
  String get finishJob;

  /// Job not found screen title
  ///
  /// In en, this message translates to:
  /// **'Job Not Found'**
  String get jobNotFoundTitle;

  /// Error display
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorPrefixTitle(String error);

  /// Finish job summary card title
  ///
  /// In en, this message translates to:
  /// **'Service Summary'**
  String get serviceSummary;

  /// Service notes section header
  ///
  /// In en, this message translates to:
  /// **'Service Notes'**
  String get serviceNotes;

  /// Service notes hint
  ///
  /// In en, this message translates to:
  /// **'Describe the work done...'**
  String get describeWorkDone;

  /// Total amount section header
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// Amount field hint
  ///
  /// In en, this message translates to:
  /// **'Enter total amount'**
  String get enterTotalAmount;

  /// Loading state for submit button
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get submitting;

  /// Notes validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter service notes'**
  String get pleaseEnterServiceNotes;

  /// Amount validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter total amount'**
  String get pleaseEnterTotalAmount;

  /// Amount format validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get pleaseEnterValidAmount;

  /// Job finish success message
  ///
  /// In en, this message translates to:
  /// **'Job finished successfully'**
  String get jobFinishedSuccessfully;

  /// Job finish error
  ///
  /// In en, this message translates to:
  /// **'Failed to finish job: {error}'**
  String failedToFinishJob(String error);

  /// Empty incoming requests title
  ///
  /// In en, this message translates to:
  /// **'No Incoming Requests'**
  String get noIncomingRequests;

  /// Empty incoming requests description
  ///
  /// In en, this message translates to:
  /// **'New service requests will appear here in real-time.'**
  String get noIncomingRequestsMessage;

  /// Refresh button
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Requests loading message
  ///
  /// In en, this message translates to:
  /// **'Loading requests...'**
  String get loadingRequests;

  /// Requests load error
  ///
  /// In en, this message translates to:
  /// **'Failed to load requests: {error}'**
  String failedToLoadRequests(String error);

  /// Accept success message
  ///
  /// In en, this message translates to:
  /// **'Request accepted'**
  String get requestAccepted;

  /// Accept error
  ///
  /// In en, this message translates to:
  /// **'Failed to accept: {error}'**
  String failedToAccept(String error);

  /// Reject success message
  ///
  /// In en, this message translates to:
  /// **'Request rejected'**
  String get requestRejected;

  /// Reject button
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// Accept button
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// New request label
  ///
  /// In en, this message translates to:
  /// **'New Request'**
  String get newRequest;

  /// Time label for less than 1 minute ago
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// Time label for minutes ago
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String minutesAgo(int count);

  /// Time label for hours ago
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String hoursAgo(int count);

  /// Empty completed jobs title
  ///
  /// In en, this message translates to:
  /// **'No Completed Jobs'**
  String get noCompletedJobs;

  /// Empty completed jobs description
  ///
  /// In en, this message translates to:
  /// **'Your finished jobs will appear here once completed.'**
  String get noCompletedJobsMessage;

  /// View active jobs button
  ///
  /// In en, this message translates to:
  /// **'View Active Jobs'**
  String get viewActiveJobs;

  /// Jobs loading message
  ///
  /// In en, this message translates to:
  /// **'Loading jobs...'**
  String get loadingJobs;

  /// Jobs load error
  ///
  /// In en, this message translates to:
  /// **'Failed to load jobs: {error}'**
  String failedToLoadJobs(String error);

  /// Total earned label
  ///
  /// In en, this message translates to:
  /// **'Total Earned'**
  String get totalEarned;

  /// Generic error title
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Invalid map data error
  ///
  /// In en, this message translates to:
  /// **'Invalid map data.'**
  String get invalidMapData;

  /// Invalid payment data error
  ///
  /// In en, this message translates to:
  /// **'Invalid payment data.'**
  String get invalidPaymentData;

  /// Invalid service request data error
  ///
  /// In en, this message translates to:
  /// **'Invalid service request data.'**
  String get invalidServiceRequestData;

  /// Invalid live status data error
  ///
  /// In en, this message translates to:
  /// **'Invalid live status data.'**
  String get invalidLiveStatusData;

  /// Invalid finish job data error
  ///
  /// In en, this message translates to:
  /// **'Invalid finish job data.'**
  String get invalidFinishJobData;

  /// App bootstrap failure message
  ///
  /// In en, this message translates to:
  /// **'Application failed to start.\n\n{error}'**
  String applicationFailedToStart(String error);

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Arabic language name
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// Driving status label
  ///
  /// In en, this message translates to:
  /// **'On The Way'**
  String get onTheWay;

  /// Arrived status label
  ///
  /// In en, this message translates to:
  /// **'Arrived'**
  String get arrived;

  /// Working status label
  ///
  /// In en, this message translates to:
  /// **'Working'**
  String get working;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
