import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';

/// The language Keyhold speaks: the device's own when Keyhold has it, English otherwise.
final Locale appLocale = basicLocaleListResolution(
  WidgetsBinding.instance.platformDispatcher.locales,
  AppLocalizations.supportedLocales,
);

/// Keyhold's texts in [appLocale], also for code with no screen around it.
final AppLocalizations t = lookupAppLocalizations(appLocale);
