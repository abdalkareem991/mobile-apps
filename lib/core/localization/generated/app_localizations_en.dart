// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Nabd Chat';

  @override
  String get chats => 'Chats';

  @override
  String get contacts => 'Contacts';

  @override
  String get settings => 'Settings';

  @override
  String get yourChats => 'Your chats';

  @override
  String get searchChats => 'Search your chats';

  @override
  String get noMatchingChats => 'No matching chats';

  @override
  String get newChat => 'New chat';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get callTooltip => 'Voice call';

  @override
  String get moreTooltip => 'More';

  @override
  String get onlineNow => 'Online now';

  @override
  String get lastSeenRecently => 'Last seen recently';

  @override
  String get addAttachment => 'Add attachment';

  @override
  String get messageHint => 'Write a message...';

  @override
  String get send => 'Send';

  @override
  String get accountPlaceholder => 'Account settings are coming next.';

  @override
  String get contactsPlaceholder => 'Your local contacts will appear here.';

  @override
  String get sampleGreeting => 'Hello! How are you?';

  @override
  String get sampleReply => 'I am well, hope you are too';

  @override
  String get sampleClosing => 'Great, see you soon';

  @override
  String get welcomeTitle => 'Welcome to Nabd Chat';

  @override
  String get welcomeSubtitle =>
      'Your conversations stay on this device in local mode.';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get phoneNumberHint => '+1 555 000 0000';

  @override
  String get continueAction => 'Continue';

  @override
  String get profileSetupTitle => 'Set up your profile';

  @override
  String get profileSetupSubtitle =>
      'Choose how people will see you in this app.';

  @override
  String get realName => 'Your name';

  @override
  String get displayName => 'Display name';

  @override
  String get about => 'About (optional)';

  @override
  String get saveProfile => 'Save profile';

  @override
  String get requiredField => 'This field is required';

  @override
  String get invalidPhone => 'Enter a valid phone number';

  @override
  String get logout => 'Log out';

  @override
  String get logoutConfirm =>
      'Log out of this local account? Your local history will stay on this device.';

  @override
  String get cancel => 'Cancel';

  @override
  String get loggedOut => 'You are logged out';

  @override
  String get importContacts => 'Import contacts';

  @override
  String get searchContacts => 'Search contacts';

  @override
  String get contactsEmpty =>
      'No local contacts yet. Import them from your phone.';

  @override
  String get contactsPermissionDenied =>
      'Contacts permission was denied. You can allow it in system settings.';

  @override
  String get contactsImportFailed =>
      'Contacts could not be imported. Try again.';

  @override
  String get onNabd => 'On Nabd';

  @override
  String get inviteSection => 'Invite to Nabd';

  @override
  String get retry => 'Retry';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get otpTitle => 'Verify your phone';

  @override
  String get otpSubtitle => 'Enter the code sent to';

  @override
  String get otpCode => 'Verification code';

  @override
  String get verifyCode => 'Verify phone';

  @override
  String get otpFailed => 'We could not send the verification code. Try again.';

  @override
  String get otpInvalid => 'Enter the 6-digit verification code.';

  @override
  String get noMessagesYet => 'No messages yet. Start the conversation.';
}
