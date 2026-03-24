part of 'values.dart';

class StringConst {
  // First Onboarding Screen
  static const String firstOnboardingTitle = 'Grow Your Wealth with\nConfidence';
  static const String firstOnboardingDescription =
      'Access trusted investment solutions designed\naround your goals. Start your journey to financial\nfreedom today.';

  // Second Onboarding Screen
  static const String secondOnboardingTitle = 'Your Financial Partner for \nLife';
  static const String secondOnboardingDescription =
      'From savings to structured investments, Hillcrest\nhelps you reach your goals with ease and confidence.';

  // Third Onboarding Screen
  static const String thirdOnboardingTitle = 'Invest Smart, Grow Steady';
  static const String thirdOnboardingDescription =
      'With Hillcrest, you can save, invest, and track your\ngrowth — all in one place. Let’s build your future together.';

  // Welcome & Onboarding
  static const String welcome = 'Welcome!';
  static const String getStarted = 'Get Started';
  static const String getStartedSubtitle = 'Create your account to access \npersonalized services.';

  // --- Authentication - Sign In ---
  // Updated signInPrompt to signInSubtitle
  static const String signInSubtitle = 'Sign in to access your personal dashboard.';
  static const String emailLabel = 'Email Address';
  static const String emailHint = 'e.g chineduokafor@gmail.com';
  static const String passwordLabel = 'Password';
  static const String passwordHint = 'Enter your Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String continueButton = 'Continue';
  static const String noAccountPrompt = 'Do not have an account? ';
  static const String createOne = 'Create one';
  static const String existingCustomerPrompt = 'Already a customer? ';
  static const String setUpOnlineProfile = 'Set up online profile';
  static const String login = 'Login';
  // New: Back to Sign In link text
  static const String backToSignIn = 'Back to Sign In';
  static const String myAccount = 'My Account';
  static const String logout = 'Logout';
  static const String profile = 'Profile';

  static const String continueToPayment = 'Continue to Payment';
  static const String amountLabel = 'Amount';
  static const String amountHint = 'Enter amount';
  static const String fundWallet = 'Fund Wallet';
  static const String transfer = 'Transfer';





  // --- Password Reset ---
  static const String passwordResetTitle = 'Password Reset';
  static const String passwordResetInstruction = 'Enter the email address associated to your HillCrest account';
  static const String enterCodeTitle = 'Enter Code';
  static const String codeSentMessage = 'A 6-Digit code has been sent to chineduok***@gmail.com. Enter code.';
  static const String resendCodePrompt = 'Didn’t receive any code? ';
  static const String resendAction = 'Resend';
  static const String createNewPassword = 'Create new Password';
  static const String passwordRequirements = 'Must be different from the old password and have at least 8 characters.';
  static const String passwordChangeSuccessTitle = 'Password Change Successful';
  static const String passwordChangeSuccessMessage = 'Your password has been successfully changed.';

  // --- Registration - Create Account ---
  static const String firstNameLabel = 'First Name';
  static const String firstNameHint = 'Chinedu';
  static const String lastNameLabel = 'Last Name';
  static const String lastNameHint = 'Okafor';
  static const String usernameLabel = 'Username';
  static const String usernameHint = 'chineduokafor';
  static const String phoneNumberLabel = 'Phone number';
  static const String countryCodeHint = '+234';
  static const String phoneNumberHint = '915 4567 562';
  static const String accountTypeLabel = 'Account Type';
  static const String accountTypeHint = 'Select your account type';
  static const String confirmPasswordLabel = 'Confirm Password';
  static const String confirmPasswordHint = 'Enter your Password';
  static const String termsAgreement = 'I agree to the';
  static const String termsandConditions = 'Terms & Conditions';
  static const String privacyPolicy = 'Privacy Policy';
  static const String alreadyHaveAccountPrompt = 'Already have an account? ';
  static const String signIn = 'Sign in';
  static const String and = ' and ';
  static const String termsContent = 'Detailed Terms and Conditions content goes here...';

  // --- Verification - Email & Phone ---
  static const String emailVerificationSuccessTitle = 'Verification Successful';
  static const String emailVerificationSuccessMessage =
      'Your Email has been verified successfully. Kindly proceed to verifying your phone number';
  static const String verifyPhoneTitle = 'Verify Phone Number';
  static const String phoneCodeSentMessage = 'A 6-Digit code has been sent to your phone number. Enter code.';
  static const String phoneVerificationCompleteTitle = 'Verification Completed';
  static const String phoneVerificationCompleteMessage =
      'Your phone number has been verified successfully. Kindly proceed to your dashboard';
  static const String goToDashboard = 'Go to Dashboard';
  // New: OTP Email Subject/Template
  static const String otpEmailSubject = 'OTP Verification';
  static const String otpEmailMessageTemplate =
      'Good day,\n\nThis is your One-time password for your online profile creation with HillCrest Finance.\n\nPin: ';

  // --- Profile Setup ---
  static const String setProfileTitle = 'Set Profile';
  // Updated instruction to subtitle
  static const String setProfileSubtitle =
      'Set up your online profile with HillCrest account by providing the details';
  static const String accountNumberLabel = 'Account Number';
  static const String accountNumberHint = 'Enter account no';
  static const String profileEmailLabel = 'Email Address';
  static const String profileEmailHint = 'e.g chineduokafor@gmail.com';
  static const String createProfileButton = 'Create Profile';
  static const String profilePasswordRequirements =
      'Must be different from the old password and have at least 8 characters.';
  static const String profileCreatedTitle = 'Profile Created';
  static const String profileCreatedMessage =
      'Your online profile has been successfully created, kindly proceed to your dashboard';

  // --- New: Logic/Error Messages (from signup_active.dart logic) ---
  static const String accountExistsTitle = 'Account Exists';
  static const String accountExistsMessage = 'An account with this email already exists. Please reset your password.';
  static const String resetPasswordButton = 'Reset Password';
  static const String cancelButton = 'Cancel';
  static const String detailsMismatchError = 'Email or Phone Number does not match our records.';
  static const String customerDetailsNotFoundError = 'Customer details not found.';
  static const String genericFetchError = 'Something went wrong. Please try again.';

  // Add these to your existing StringConst class
  static const String verifyMail = "Verify Mail";
  static const String verifyMailSubtitle = "A 6-Digit code has been sent to ";
  static const String enterCode = ". Enter code.";
  static const String resendPrompt = "Didn’t receive any code? ";
  static const String resendLink = "Resend";
  // Add these to your StringConst class
  static const String registrationSuccess = "Registration Successful";
  static const String registrationSuccessSub = "Your email has been successfully verified. Please proceed to verify your phone number.";

  // Add these to your existing StringConst class
  static const String verifyPhone = "Verify Phone Number";
  static const String verifyPhoneSubtitle = "A 6-Digit code has been sent to ";
  static const String phoneRegistrationSuccess = "Verification Complete";
  static const String phoneRegistrationSuccessSub = "Your phone number has been successfully verified. Let's set up your profile.";
  // --- New: Personal Information Page ---
  static const String personalDetailsAppBarTitle = 'Personal Details';
  static const String personalInfoTitle = 'Personal Information';
  static const String personalInfoSubtitle =
      'Create an account by providing the details needed below.';
  static const String middleNameOptionalHint = 'Middle Name (Optional)';
  static const String dobPlaceholder = 'Date of Birth (DD/MM/YYYY)';
  static const String genderHint = 'Select your Gender';
  static const String kycDocumentUploadTitle = 'KYC Document Upload';
  static const String kycDocumentUploadSubtitle=
      'Upload a valid means of identification to proceed with your account setup.';

  static const String home = 'Home';
  static const String welcomeUser = 'Welcome,';
  static const String editProfile = 'Edit Profile';
  static const String totalBalance = 'Total Balance';
  static const String send = 'Send';
  static const String topUp = 'Top Up';
  static const String viewAll = 'View All';
  static const String airtime = 'Airtime';
  static const String data = 'Data';
  static const String bills = 'Bills';
  static const String more = 'More';
  static const String recentTransactions = 'Recent Transactions';
  static const String quickActions = 'Quick Actions';

  // Add these to your StringConst class (after the existing strings)

// --- Onboarding Completion Modal ---
  static const String welcomeOnboard = 'Welcome on board!';
  static const String finishSettingUpProfile = 'Finish setting up your profile.';
  static const String provideDetailsPrompt = 'Provide the following details to get the most of our services';
  static const String signUpCompleted = 'Sign up completed';
  static const String personalInformation = 'Personal information';
  static const String kycDocumentUpload = 'KYC Document Upload';
  static const String continueOnboarding = 'Continue Onboarding';

  // Profile Screen Strings
  // static const String profile = "Profile";
  static const String profileName = "Tolu";
  static const String profileEmail = "tolulola@gmail.com";
  static const String generateReferenceLetter = "Generate Reference Letter";
  static const String generateAccountStatement = "Generate Account Statement";
  static const String order = "Order";
  static const String viewFundPrice = "View Fund Price";
  static const String faqs = "FAQs";
  static const String appVersionLabel = "App version";
  static const String appVersionValue = "1.1.0";
  static const String supportHeader = "SUPPORT";
  static const String supportEmail = "Email";
  static const String supportLine = "Support line";
  // static const String logout = "Logout";

  // --- Generate Reference Letter Screen Specifics ---
  static const String enterAccurateDetails = "Enter accurate details below";
  static const String selectFundsHint = "Select Fund(s)";
  static const String recipientNameLabel = "Recipient Name";
  static const String recipientAddressLabel = "Recipient Address";
  static const String cityLabel = "City";
  static const String stateLabel = "State";
  static const String countryLabel = "Country";
  static const String currencyLabel = "Currency";
  static const String postalCodeLabel = "Postal Code";
  static const String enterHereHint = "Enter here";
  static const String reviewCheckboxText = "By checking this box, you can review.";
  static const String generateButton = "Generate";

  //generate account statement
  static const String generateStatement = "Generate Statement";
  static const String selectFunds = "Select Fund(s)";
  static const String startDateLabel = "Start Date";
  static const String endDateLabel = "End Date";
  static const String dateHint = "dd/MM/yyyy";
  static const String fieldRequiredError = "This field is required";


  //Fund Price
  static const String fundPriceTitle ='Fund Price';
  static const String fundPriceDescription ='Below is a list of funds';
  static const String hillCrestBalanceFund = 'Hill Crest Balance Funds ';
  static const String bidPriceTitle = 'Bid Price';
  static const String offerPriceTitle = ' Offer Price';
  static const String bidPriceAmount ='NGN 9,508.93';
  static const String offerPriceAmount ='NGN 9,591.52';


  static const String faqsTitle = "FAQS";
  static const String frequentlyAskedQuestions = "Frequently Asked Questions";

  // FAQ Questions
  static const String faqQ1 = "What is the Hillcrest Balanced Fund?";
  static const String faqQ2 = "Who is the fund suitable for?";
  static const String faqQ3 = "What is the minimum investment amount?";
  static const String faqQ4 = "How risky is the Hillcrest Balanced Fund?";
  static const String faqQ5 = "Can I lose my money?";
  static const String faqQ6 = "How do I earn returns from the fund?";
  static const String faqQ7 = "How long should I stay invested?";
  static const String faqQ8 = "Can I withdraw my investment at any time?";
  static const String faqQ9 = "Who manages the Hillcrest Balanced Fund?";
  static const String faqQ10 = "How is the fund regulated?";
  static const String faqQ11 = "Are there any fees?";
  static const String faqQ12 = "Where can I get more information or speak to someone?";

  // FAQ Answers
  static const String faqA1 = "The Hillcrest Balanced Fund is a professionally managed investment fund that invests in a mix of fixed income instruments and equities. The goal is to provide investors with a balance of steady income and long-term capital growth.";
  static const String faqA2 = "The fund is suitable for investors who want better returns than traditional savings or money market instruments, but with lower risk than investing fully in equities. It is ideal for medium- to long-term investors seeking growth with stability.";
  static const String faqA3 = "The minimum investment amount is set to make the fund accessible to a wide range of investors. The minimum investment is N5,000.";
  static const String faqA4 = "The fund carries a moderate level of risk. While returns are not guaranteed, diversification across asset classes helps reduce volatility compared to investing solely in equities.";
  static const String faqA5 = "Like all investments, the value of the fund can go up or down due to market conditions. However, the balanced investment approach is designed to reduce extreme fluctuations and protect capital over the long term.";
  static const String faqA6 = "Investors earn returns through appreciation in the unit price of the fund and, where applicable, distributions from the fund.";
  static const String faqA7 = "The fund is best suited for medium- to long-term investment horizons, typically 90 days and above, to fully benefit from market cycles. Any redemption below 90 days is subject to a fee of 20% on accrued interest.";
  static const String faqA8 = "Yes, investors can redeem their units subject to the fund’s redemption terms and notice period as stated in the offer document.";
  static const String faqA9 = "The fund is managed by Hillcrest Capital Management Ltd, a licensed fund manager with experienced professionals responsible for research, asset allocation, and risk management.";
  static const String faqA10 = "The Hillcrest Balanced Fund is regulated by the Securities and Exchange Commission (SEC) of Nigeria and operates in compliance with all applicable regulations.";
  static const String faqA11 = "Yes, the fund charges management and other allowable fees as disclosed in the fund’s offer document. These fees are already reflected in the fund’s performance.";
  static const String faqA12 = "You can contact Hillcrest Capital Management Ltd directly through our office, website, or customer service channels for personalized guidance.";


}