import 'package:flutter/widgets.dart';

import 'generated/app_localizations.dart' as generated;

export 'generated/app_localizations.dart';

extension AppLocalizationsContext on BuildContext {
  generated.AppLocalizations get l10n => generated.AppLocalizations.of(this);
}
