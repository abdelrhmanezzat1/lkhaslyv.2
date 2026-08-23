// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Lakhsly';

  @override
  String get welcomeToApp => 'Welcome to\nLakhsly';

  @override
  String get onboardingDescription =>
      'The future of car service management is here. Track your orders, manage your garage, and connect with service providers seamlessly.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get signInSubtitle => 'Sign in to continue to your account';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get signIn => 'Sign In';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get createOne => 'Create one';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email address';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get unknownError => 'An unknown error occurred.';

  @override
  String get createAccount => 'Create Account';

  @override
  String get joinUs => 'Join Us!';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get iAmA => 'I am a:';

  @override
  String get client => 'Client';

  @override
  String get technician => 'Technician';

  @override
  String get creatingAccount => 'Creating Account...';

  @override
  String get pleaseEnterFirstName => 'Please enter your first name';

  @override
  String get pleaseEnterLastName => 'Please enter your last name';

  @override
  String get pleaseEnterPhoneNumber => 'Please enter your phone number';

  @override
  String get pleaseEnterAPassword => 'Please enter a password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters long';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get addYourCar => 'Add Your Car';

  @override
  String get tellUsAboutYourCar => 'Tell us about your car';

  @override
  String get carType => 'Car Type';

  @override
  String get carModel => 'Car Model';

  @override
  String get color => 'Color';

  @override
  String get plateNumber => 'Plate Number';

  @override
  String get carYearOptional => 'Car Year (optional)';

  @override
  String get saving => 'Saving...';

  @override
  String get saveAndContinue => 'Save & Continue';

  @override
  String get carSavedSuccessfully => 'Car saved successfully!';

  @override
  String get pleaseEnterCarType => 'Please enter the car type';

  @override
  String get pleaseEnterCarModel => 'Please enter the car model';

  @override
  String get pleaseEnterColor => 'Please enter the color';

  @override
  String get pleaseEnterPlateNumber => 'Please enter the plate number';

  @override
  String get forgotPasswordTitle => 'Forgot Password';

  @override
  String get resetYourPassword => 'Reset Your Password';

  @override
  String get resetPasswordDescription =>
      'Enter your email and we will send you a link to reset your password.';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get passwordResetSent =>
      'Password reset link sent! Please check your email.';

  @override
  String get home => 'Home';

  @override
  String get profile => 'Profile';

  @override
  String get myOrders => 'My Orders';

  @override
  String get logout => 'Logout';

  @override
  String get notLoggedIn => 'Not logged in.';

  @override
  String get noEmail => 'No email';

  @override
  String get notificationsComingSoon => 'Notifications coming soon.';

  @override
  String get whatServiceDoYouNeed => 'What service do you need?';

  @override
  String get mechanical => 'Mechanical';

  @override
  String get electrical => 'Electrical';

  @override
  String get diagnostics => 'Diagnostics';

  @override
  String get spareParts => 'Spare Parts';

  @override
  String welcomeUser(String name) {
    return 'Welcome, $name!';
  }

  @override
  String logoutFailed(String error) {
    return 'Logout failed: $error';
  }

  @override
  String errorPrefix(String error) {
    return 'Error: $error';
  }

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get updateYourInformation => 'Update Your Information';

  @override
  String get fullName => 'Full Name';

  @override
  String get updateProfile => 'Update Profile';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully!';

  @override
  String get pleaseEnterName => 'Please enter your name';

  @override
  String get selectLocation => 'Select Location';

  @override
  String get liveTracking => 'Live Tracking';

  @override
  String get loadingMap => 'Loading map...';

  @override
  String get distance => 'Distance';

  @override
  String get eta => 'ETA';

  @override
  String get myLocation => 'My Location';

  @override
  String get confirmLocation => 'Confirm Location';

  @override
  String get locationServicesDisabled =>
      'Location services are disabled. Please enable GPS.';

  @override
  String get locationPermissionRequired =>
      'Location permission is required to continue.';

  @override
  String get locationPermissionDeniedForever =>
      'Location permission is permanently denied. Enable it in app settings.';

  @override
  String get unableToGetPosition => 'Unable to get current position.';

  @override
  String get pleaseSelectLocation => 'Please choose a pickup location.';

  @override
  String get selectInsideCairoGiza =>
      'Please select a location inside Cairo or Giza.';

  @override
  String get orderCreatedSuccessfully => 'Order created successfully!';

  @override
  String failedToCreateOrder(String error) {
    return 'Failed to create order: $error';
  }

  @override
  String get selectedService => 'Selected Service';

  @override
  String get selectVehicle => 'Select Vehicle';

  @override
  String get noVehiclesFound => 'No vehicles found';

  @override
  String get addAVehicle => 'Add a vehicle';

  @override
  String get problemDescription => 'Problem Description';

  @override
  String get describeIssue => 'Describe the issue you are experiencing...';

  @override
  String get pleaseDescribeProblem => 'Please describe the problem.';

  @override
  String get uploadImageOptional => 'Upload Image (optional)';

  @override
  String get tapToUploadImage => 'Tap to upload an image';

  @override
  String get imageFormatHint => 'JPG, PNG up to 10MB';

  @override
  String get uploaded => 'Uploaded';

  @override
  String get continueButton => 'Continue';

  @override
  String failedToPickImage(String error) {
    return 'Failed to pick image: $error';
  }

  @override
  String failedToUploadImage(String error) {
    return 'Failed to upload image: $error';
  }

  @override
  String get pleaseSelectVehicle => 'Please select a vehicle.';

  @override
  String failedToLoadVehicles(String error) {
    return 'Failed to load vehicles: $error';
  }

  @override
  String get goBack => 'Go Back';

  @override
  String get payment => 'Payment';

  @override
  String get paymentSummary => 'Payment Summary';

  @override
  String get service => 'Service';

  @override
  String get vehicle => 'Vehicle';

  @override
  String get amountDue => 'Amount Due';

  @override
  String get payNow => 'Pay Now';

  @override
  String get choosePaymentMethod => 'Choose Payment Method';

  @override
  String get wallet => 'Wallet';

  @override
  String get payFromWallet => 'Pay from your wallet balance';

  @override
  String get card => 'Card';

  @override
  String get payWithCard => 'Pay with saved card';

  @override
  String get pleaseSelectPaymentMethod => 'Please select a payment method.';

  @override
  String get paymentSuccessful => 'Payment successful. Your order is now paid.';

  @override
  String failedToProcessPayment(String error) {
    return 'Failed to process payment: $error';
  }

  @override
  String get nA => 'N/A';

  @override
  String get loadingOrders => 'Loading orders...';

  @override
  String couldNotLoadOrders(String error) {
    return 'Could not load orders: $error';
  }

  @override
  String get noOrdersYet => 'No orders yet';

  @override
  String get noOrdersDescription => 'Request a service to see your orders here';

  @override
  String get pending => 'Pending';

  @override
  String get accepted => 'Accepted';

  @override
  String get technicianOnTheWay => 'Technician on the Way';

  @override
  String get technicianArrived => 'Technician Arrived';

  @override
  String get inProgress => 'In Progress';

  @override
  String get finished => 'Finished';

  @override
  String get completed => 'Completed';

  @override
  String get paid => 'Paid';

  @override
  String get unknown => 'Unknown';

  @override
  String get date => 'Date';

  @override
  String get paymentStatus => 'Payment';

  @override
  String get trackTechnician => 'Track Technician';

  @override
  String get thisOrderIsPaid => 'This order is already paid.';

  @override
  String get invalidOrderData => 'Invalid order data.';

  @override
  String failedToLoadOrders(String error) {
    return 'Failed to load orders: $error';
  }

  @override
  String get technicianHome => 'Technician';

  @override
  String get status => 'Status';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get receivingRequests => 'Receiving new service requests';

  @override
  String get tapToGoOnline => 'Tap to go online and receive requests';

  @override
  String get todaysStatistics => 'Today\'s Statistics';

  @override
  String get rating => 'Rating';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get incomingRequests => 'Incoming Requests';

  @override
  String get incomingRequestsSubtitle => 'New service requests from customers';

  @override
  String get acceptedRequests => 'Accepted Requests';

  @override
  String get acceptedRequestsSubtitle => 'Your active service jobs';

  @override
  String get completedJobs => 'Completed Jobs';

  @override
  String get completedJobsSubtitle => 'History of finished services';

  @override
  String get noActiveJobs => 'No Active Jobs';

  @override
  String get noActiveJobsMessage =>
      'Accept a request to start working on a service job.';

  @override
  String get viewIncoming => 'View Incoming';

  @override
  String get activeJob => 'Active Job';

  @override
  String get details => 'Details';

  @override
  String get viewJob => 'View Job';

  @override
  String kmAway(String distance) {
    return '$distance km away';
  }

  @override
  String get jobDetails => 'Job Details';

  @override
  String get loadingJobDetails => 'Loading job details...';

  @override
  String failedToLoadJob(String error) {
    return 'Failed to load job: $error';
  }

  @override
  String get jobNotFound => 'Job not found';

  @override
  String get viewLiveStatus => 'View Live Status';

  @override
  String get liveStatus => 'Live Status';

  @override
  String get customer => 'Customer';

  @override
  String get problem => 'Problem';

  @override
  String get progress => 'Progress';

  @override
  String get navigate => 'Navigate';

  @override
  String get startDriving => 'Start Driving';

  @override
  String get statusUpdatedToDriving => 'Status updated to Driving';

  @override
  String get markArrived => 'Mark Arrived';

  @override
  String get statusUpdatedToArrived => 'Status updated to Arrived';

  @override
  String get startWorking => 'Start Working';

  @override
  String get statusUpdatedToWorking => 'Status updated to Working';

  @override
  String get finishJob => 'Finish Job';

  @override
  String get jobNotFoundTitle => 'Job Not Found';

  @override
  String errorPrefixTitle(String error) {
    return 'Error: $error';
  }

  @override
  String get serviceSummary => 'Service Summary';

  @override
  String get serviceNotes => 'Service Notes';

  @override
  String get describeWorkDone => 'Describe the work done...';

  @override
  String get totalAmount => 'Total Amount';

  @override
  String get enterTotalAmount => 'Enter total amount';

  @override
  String get submitting => 'Submitting...';

  @override
  String get pleaseEnterServiceNotes => 'Please enter service notes';

  @override
  String get pleaseEnterTotalAmount => 'Please enter total amount';

  @override
  String get pleaseEnterValidAmount => 'Please enter a valid amount';

  @override
  String get jobFinishedSuccessfully => 'Job finished successfully';

  @override
  String failedToFinishJob(String error) {
    return 'Failed to finish job: $error';
  }

  @override
  String get noIncomingRequests => 'No Incoming Requests';

  @override
  String get noIncomingRequestsMessage =>
      'New service requests will appear here in real-time.';

  @override
  String get refresh => 'Refresh';

  @override
  String get loadingRequests => 'Loading requests...';

  @override
  String failedToLoadRequests(String error) {
    return 'Failed to load requests: $error';
  }

  @override
  String get requestAccepted => 'Request accepted';

  @override
  String failedToAccept(String error) {
    return 'Failed to accept: $error';
  }

  @override
  String get requestRejected => 'Request rejected';

  @override
  String get reject => 'Reject';

  @override
  String get accept => 'Accept';

  @override
  String get newRequest => 'New Request';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String hoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String get noCompletedJobs => 'No Completed Jobs';

  @override
  String get noCompletedJobsMessage =>
      'Your finished jobs will appear here once completed.';

  @override
  String get viewActiveJobs => 'View Active Jobs';

  @override
  String get loadingJobs => 'Loading jobs...';

  @override
  String failedToLoadJobs(String error) {
    return 'Failed to load jobs: $error';
  }

  @override
  String get totalEarned => 'Total Earned';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get invalidMapData => 'Invalid map data.';

  @override
  String get invalidPaymentData => 'Invalid payment data.';

  @override
  String get invalidServiceRequestData => 'Invalid service request data.';

  @override
  String get invalidLiveStatusData => 'Invalid live status data.';

  @override
  String get invalidFinishJobData => 'Invalid finish job data.';

  @override
  String applicationFailedToStart(String error) {
    return 'Application failed to start.\n\n$error';
  }

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get onTheWay => 'On The Way';

  @override
  String get arrived => 'Arrived';

  @override
  String get working => 'Working';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsEmpty => 'No notifications yet';

  @override
  String get markAllAsRead => 'Mark all as read';
}
