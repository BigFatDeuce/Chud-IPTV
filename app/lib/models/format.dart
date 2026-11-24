import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import 'catalog.dart';
import 'source.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Majuscules correctes selon la langue : en turc, « i » devient « İ » et « ı » devient « I ».
extension LocalizedUpper on String {
  String upperIn(String language) {
    if (language != 'tr') return toUpperCase();
    return replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();
  }
}

/// Date et heure dans la langue de l'interface.
String formatDateTime(DateTime date, AppLocalizations l) => DateFormat.yMd(l.localeName).add_Hm().format(date);

String formatDate(DateTime date, AppLocalizations l) => DateFormat.yMMMd(l.localeName).format(date);

/// Texte compréhensible pour l'échec d'une actualisation.
String importErrorText(ImportError error, String detail, AppLocalizations l) => switch (error) {
      ImportError.network => l.errorNetwork,
      ImportError.timeout => l.errorTimeout,
      ImportError.credentials => l.errorCredentials,
      ImportError.expired => l.errorExpired,
      ImportError.notFound => l.errorNotFound,
      ImportError.notPlaylist => l.errorNotPlaylist,
      ImportError.invalidData => l.errorInvalidData,
      ImportError.empty => l.errorEmpty,
      ImportError.suspicious => l.errorSuspicious(detail),
      ImportError.fileMissing => l.errorFileMissing,
      ImportError.unknown => l.errorUnknown,
    };

String sortLabel(ItemSort sort, AppLocalizations l) => switch (sort) {
      ItemSort.source => l.sortSource,
      ItemSort.nameAscending => l.sortNameAsc,
      ItemSort.nameDescending => l.sortNameDesc,
      ItemSort.recent => l.sortRecent,
      ItemSort.rating => l.sortRating,
    };

String sourceKindText(SourceKind kind, AppLocalizations l) => switch (kind) {
      SourceKind.xtream => l.kindXtream,
      SourceKind.m3uUrl => l.kindM3uUrl,
      SourceKind.m3uFile => l.kindM3uFile,
    };
