// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get navLive => 'Эфир';

  @override
  String get navFavorites => 'Избранное';

  @override
  String get navMovies => 'Фильмы';

  @override
  String get navSeries => 'Сериалы';

  @override
  String get navSources => 'Источники';

  @override
  String get navSettings => 'Настройки';

  @override
  String get navMore => 'Ещё';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get commonClose => 'Закрыть';

  @override
  String get commonRetry => 'Повторить';

  @override
  String get welcomeTitle => 'Добро пожаловать';

  @override
  String get welcomeBody =>
      'Добавьте источник: учётную запись Xtream Codes или плейлист M3U. Приложение не предоставляет каналы, все данные остаются на этом устройстве.';

  @override
  String get addSource => 'Добавить источник';

  @override
  String get allSources => 'Все источники';

  @override
  String get allCategories => 'Все';

  @override
  String get noCategoryName => 'Без категории';

  @override
  String get filterCategories => 'Фильтр категорий';

  @override
  String get emptyList => 'Здесь пока ничего нет.';

  @override
  String get emptyWhileImporting =>
      'Идёт импорт, каталог появится, как только будет готов.';

  @override
  String itemCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString элементов',
      few: '$countString элемента',
      one: '$countString элемент',
      zero: 'Нет элементов',
    );
    return '$_temp0';
  }

  @override
  String get viewCompact => 'Компактный список';

  @override
  String get viewDetailed => 'Подробный список';

  @override
  String get viewGrid => 'Сетка';

  @override
  String get searchHint => 'Поиск';

  @override
  String noResults(String query) {
    return 'По запросу «$query» ничего не найдено.';
  }

  @override
  String get sortLabel => 'Сортировка';

  @override
  String get sortSource => 'Порядок источника';

  @override
  String get sortNameAsc => 'Название (А → Я)';

  @override
  String get sortNameDesc => 'Название (Я → А)';

  @override
  String get sortRecent => 'Недавно добавленные';

  @override
  String get sortRating => 'С высоким рейтингом';

  @override
  String get filterLabel => 'Фильтры';

  @override
  String get filterCountry => 'Страна или язык';

  @override
  String get filterAllCountries => 'Все страны';

  @override
  String get itemSource => 'Источник';

  @override
  String get itemCategory => 'Категория';

  @override
  String get itemCountry => 'Страна или язык';

  @override
  String get itemFormat => 'Формат';

  @override
  String get itemRating => 'Рейтинг';

  @override
  String get favAdd => 'В избранное';

  @override
  String get favRemove => 'Убрать из избранного';

  @override
  String get favPickLists => 'Списки избранного';

  @override
  String get favNewList => 'Новый список';

  @override
  String get favDefaultName => 'Избранное';

  @override
  String get favListName => 'Название списка';

  @override
  String get favListIcon => 'Значок';

  @override
  String get favRename => 'Изменить список';

  @override
  String get favDeleteList => 'Удалить список';

  @override
  String favDeleteConfirm(String name) {
    return 'Удалить список «$name»? Каналы останутся в каталоге.';
  }

  @override
  String get favEmptyLists =>
      'Создайте свои списки: спорт, новости, детям… Один канал может быть в нескольких списках.';

  @override
  String get favEmptyList => 'Список пуст. Добавляйте каналы звёздочкой.';

  @override
  String get favManage => 'Управление списками';

  @override
  String get favMoveUp => 'Вверх';

  @override
  String get favMoveDown => 'Вниз';

  @override
  String favListLine(String name, int count) {
    return '$name ($count)';
  }

  @override
  String get filteredIntro =>
      'FILTERED автоматически объединяет группы источников по странам, регионам и темам. Вкладка «Эфир» и плейлисты не меняются.';

  @override
  String get filteredNoGroups =>
      'Пока нет групп для анализа. Обновите источник.';

  @override
  String get filteredAnalyze => 'Упорядочить автоматически';

  @override
  String get filteredManage => 'Классификация';

  @override
  String get filteredReanalyze => 'Повторить анализ и исправить';

  @override
  String get filteredRestore => 'Вернуть автоматическую классификацию';

  @override
  String get filteredRestoreConfirm =>
      'Ваши ручные исправления будут забыты. Перед подтверждением вы увидите предпросмотр.';

  @override
  String get filteredPreviewTitle => 'Предпросмотр';

  @override
  String filteredSummary(int groups, int nodes) {
    final intl.NumberFormat groupsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String groupsString = groupsNumberFormat.format(groups);
    final intl.NumberFormat nodesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String nodesString = nodesNumberFormat.format(nodes);

    return 'Групп: $groupsString, категорий: $nodesString';
  }

  @override
  String filteredDelta(int added, int removed) {
    return 'С прошлого анализа: новых $added, исчезло $removed';
  }

  @override
  String filteredNewGroups(int count) {
    return 'Новых групп: $count. Открыть предпросмотр';
  }

  @override
  String filteredToCheck(int count) {
    return 'Проверить ($count)';
  }

  @override
  String filteredUnclassified(int count) {
    return 'Без категории ($count)';
  }

  @override
  String filteredExcluded(int count) {
    return 'Исключённые группы ($count)';
  }

  @override
  String filteredGroupsCount(int count) {
    return 'Групп: $count';
  }

  @override
  String get filteredValidate => 'Подтвердить классификацию';

  @override
  String get filteredAccept => 'Всё верно';

  @override
  String get filteredMove => 'Поместить в…';

  @override
  String get filteredExclude => 'Исключить из классификации';

  @override
  String get filteredRestoreGroup => 'Вернуть';

  @override
  String get filteredNewCategory => 'Новая категория';

  @override
  String get filteredRename => 'Переименовать';

  @override
  String get filteredMerge => 'Объединить с…';

  @override
  String get sourcesTitle => 'Источники IPTV';

  @override
  String get refreshAll => 'Обновить все';

  @override
  String get refresh => 'Обновить';

  @override
  String get editSource => 'Изменить';

  @override
  String get deleteSource => 'Удалить источник';

  @override
  String deleteSourceConfirm(String name) {
    return 'Удалить «$name» и весь каталог с этого устройства?';
  }

  @override
  String get sourceEnabled => 'Включён';

  @override
  String get makeDefault => 'Сделать основным';

  @override
  String get isDefault => 'Основной источник';

  @override
  String get kindXtream => 'Xtream Codes';

  @override
  String get kindM3uUrl => 'Плейлист онлайн';

  @override
  String get kindM3uFile => 'Файл M3U';

  @override
  String countsLine(int live, int movies, int series) {
    final intl.NumberFormat liveNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String liveString = liveNumberFormat.format(live);
    final intl.NumberFormat moviesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String moviesString = moviesNumberFormat.format(movies);
    final intl.NumberFormat seriesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String seriesString = seriesNumberFormat.format(series);

    return 'Каналы: $liveString · фильмы: $moviesString · сериалы: $seriesString';
  }

  @override
  String get neverRefreshed => 'Ещё не обновлялся';

  @override
  String refreshedAt(String date) {
    return 'Обновлён $date';
  }

  @override
  String expiresAt(String date) {
    return 'Подписка действует до $date';
  }

  @override
  String maxConnections(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Одновременных просмотров: $count',
      one: '1 одновременный просмотр',
    );
    return '$_temp0';
  }

  @override
  String get applyAnyway => 'Применить всё равно';

  @override
  String reportDone(String name, int added, int updated, int missing) {
    final intl.NumberFormat addedNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String addedString = addedNumberFormat.format(added);
    final intl.NumberFormat updatedNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String updatedString = updatedNumberFormat.format(updated);
    final intl.NumberFormat missingNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String missingString = missingNumberFormat.format(missing);

    return '«$name»: добавлено $addedString, изменено $updatedString, исчезло $missingString.';
  }

  @override
  String get stageConnecting => 'Подключение к серверу…';

  @override
  String get stageLive => 'Загрузка каналов…';

  @override
  String get stageMovies => 'Загрузка фильмов…';

  @override
  String get stageSeries => 'Загрузка сериалов…';

  @override
  String get stagePlaylist => 'Загрузка плейлиста…';

  @override
  String get stageWriting => 'Сохранение каталога…';

  @override
  String stageWritingCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Сохранено элементов: $countString…';
  }

  @override
  String get stageQueued => 'Ожидание…';

  @override
  String get errorNetwork =>
      'Сервер недоступен. Проверьте адрес и подключение.';

  @override
  String get errorTimeout => 'Сервер слишком долго не отвечает.';

  @override
  String get errorCredentials => 'Сервер отклонил логин или пароль.';

  @override
  String get errorExpired => 'Срок подписки истёк.';

  @override
  String get errorNotFound => 'Адрес не найден на этом сервере.';

  @override
  String get errorNotPlaylist => 'Это не плейлист M3U.';

  @override
  String get errorInvalidData => 'Сервер прислал нечитаемый ответ.';

  @override
  String get errorEmpty => 'Источник пуст: текущий каталог сохранён.';

  @override
  String errorSuspicious(String detail) {
    return 'Список подозрительно мал ($detail): текущий каталог сохранён.';
  }

  @override
  String get errorFileMissing => 'Файл не найден или не читается.';

  @override
  String get errorUnknown => 'Не удалось обновить. Текущий каталог сохранён.';

  @override
  String get formNewTitle => 'Новый источник';

  @override
  String get formEditTitle => 'Изменить источник';

  @override
  String get formName => 'Название';

  @override
  String get formNameHint => 'Например: Гостиная, Подписка 1';

  @override
  String get formServer => 'Адрес сервера';

  @override
  String get formUsername => 'Имя пользователя';

  @override
  String get formPassword => 'Пароль';

  @override
  String get formShowPassword => 'Показать пароль';

  @override
  String get formPlaylistUrl => 'Адрес плейлиста (M3U или M3U8)';

  @override
  String get formFile => 'Файл плейлиста';

  @override
  String get formChooseFile => 'Выбрать файл';

  @override
  String get formNoFile => 'Файл не выбран';

  @override
  String get formFileUnavailable => 'На этом устройстве нет выбора файлов.';

  @override
  String get formRequired => 'Обязательное поле';

  @override
  String get formInvalidUrl => 'Неверный адрес';

  @override
  String get formContentTitle => 'Что импортировать';

  @override
  String get formContentHint =>
      'Эфир импортируется всегда. Без фильмов и сериалов загрузка намного легче.';

  @override
  String get formMovies => 'Фильмы';

  @override
  String get formSeries => 'Сериалы';

  @override
  String get formContentRemoved =>
      'Уже импортированные элементы и их избранное будут удалены с устройства.';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get languageSystem => 'Язык системы';

  @override
  String get settingsApp => 'Приложение';

  @override
  String settingsVersion(String version) {
    return 'Версия $version';
  }

  @override
  String get settingsPrivacy =>
      'Без учётной записи и телеметрии: источники и данные остаются на устройстве.';

  @override
  String get settingsShortcuts =>
      'Ctrl+F: поиск · F5: обновить все · Ctrl+1–9: вкладки';

  @override
  String get playerPlay => 'Смотреть';

  @override
  String get playerPause => 'Пауза';

  @override
  String get playerPrevious => 'Назад';

  @override
  String get playerNext => 'Далее';

  @override
  String get playerRefresh => 'Перезагрузить поток';

  @override
  String get playerFullscreen => 'Во весь экран';

  @override
  String get playerExitFullscreen => 'Выйти из полноэкранного режима';

  @override
  String get playerMute => 'Без звука';

  @override
  String get playerUnmute => 'Включить звук';

  @override
  String get playerLive => 'ЭФИР';

  @override
  String playerReconnecting(int attempt, int total) {
    return 'Переподключение… ($attempt/$total)';
  }

  @override
  String get playerSignalLost => 'Сигнал потерян…';

  @override
  String get playerFailedTitle => 'Не удаётся воспроизвести';

  @override
  String get playerFailedBody =>
      'Поток не отвечает. Возможно, он недоступен или подписка уже используется на другом устройстве.';

  @override
  String get playerEndedTitle => 'Воспроизведение завершено';

  @override
  String get playerBackToList => 'Назад к списку';

  @override
  String get externalTitle => 'Внешний плеер';

  @override
  String get externalOpen => 'Открыть во внешнем плеере';

  @override
  String get externalNone =>
      'Плеер не найден. VLC используется автоматически, если установлен.';

  @override
  String get externalFailed =>
      'Не удалось запустить внешний плеер. Проверьте его путь в настройках.';

  @override
  String get externalDefault => 'Использовать VLC';

  @override
  String get seriesFailed => 'Не удалось загрузить серии.';

  @override
  String get seriesEmpty => 'Нет доступных серий.';

  @override
  String seriesSeason(int number) {
    return 'Сезон $number';
  }

  @override
  String seriesEpisode(int number) {
    return 'Серия $number';
  }

  @override
  String seriesMinutes(int count) {
    return '$count мин';
  }

  @override
  String get navGuide => 'Телегид';

  @override
  String get guideTitle => 'Телегид';

  @override
  String get guideScope => 'Показываемые каналы';

  @override
  String get guideAllChannels => 'Все каналы';

  @override
  String get guideNow => 'Сейчас';

  @override
  String get guideToday => 'Сегодня';

  @override
  String get guideYesterday => 'Вчера';

  @override
  String get guideTomorrow => 'Завтра';

  @override
  String get guideEarlier => 'На 2 часа раньше';

  @override
  String get guideLater => 'На 2 часа позже';

  @override
  String get guideEmptyTitle => 'Телегида пока нет';

  @override
  String get guideEmptyBody =>
      'Импортируйте телегид из источников или добавьте адрес либо файл XMLTV в настройках.';

  @override
  String get guideImport => 'Импортировать телегид';

  @override
  String guideImporting(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Импорт телегида… передач: $countString';
  }

  @override
  String guideDone(int programs, int channels) {
    final intl.NumberFormat programsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String programsString = programsNumberFormat.format(programs);
    final intl.NumberFormat channelsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String channelsString = channelsNumberFormat.format(channels);

    return 'Телегид обновлён: передач — $programsString, связанных каналов — $channelsString.';
  }

  @override
  String guideFailed(String names) {
    return 'Телегид недоступен: $names. Прежний сохранён.';
  }

  @override
  String guideSourceLine(int count, String date) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Передач: $countString · $date';
  }

  @override
  String get guideNeverRefreshed => 'Ещё не обновлялся';

  @override
  String get guideLastFailed => 'Последнее обновление не удалось.';

  @override
  String get guideRefresh => 'Обновить телегид';

  @override
  String get guideAddUrl => 'Добавить адрес';

  @override
  String get guideAddFile => 'Добавить файл';

  @override
  String get guideUrlHint => 'Адрес телегида XMLTV';

  @override
  String get guideWatchLive => 'Смотреть в эфире';

  @override
  String get guideReplay => 'Смотреть запись';

  @override
  String get guideReplayOff => 'Запись этой передачи недоступна.';

  @override
  String get guideComing => 'Скоро';

  @override
  String get guideChannel => 'Программа канала';

  @override
  String get guideLink => 'Связать с телегидом';

  @override
  String get guideLinkHint => 'Название или идентификатор канала';

  @override
  String get guideNoProgram => 'Для этого канала нет передач.';

  @override
  String get guideNoChannels =>
      'Ни у одного канала из этой выборки нет телегида.';

  @override
  String get backupTitle => 'Резервная копия';

  @override
  String get backupExport => 'Создать копию';

  @override
  String get backupImport => 'Восстановить из копии';

  @override
  String get backupRestore => 'Восстановить';

  @override
  String get backupSecrets => 'Включить пароли';

  @override
  String get backupSecretsBody =>
      'Тогда файл шифруется вашей парольной фразой. Иначе пароли и полные адреса плейлистов не сохраняются.';

  @override
  String get backupPassphrase => 'Парольная фраза';

  @override
  String get backupPassphraseAgain => 'Повторите парольную фразу';

  @override
  String get backupPassphraseShort => 'Не менее 8 символов.';

  @override
  String get backupPassphraseMismatch => 'Фразы не совпадают.';

  @override
  String get backupSaved => 'Копия сохранена.';

  @override
  String get backupFailed => 'Не удалось записать файл.';

  @override
  String get backupNotOurs => 'Этот файл не является копией Chud IPTV.';

  @override
  String get backupTooNew =>
      'Эта копия создана более новой версией приложения.';

  @override
  String get backupDamaged => 'Эта копия повреждена.';

  @override
  String get backupWrongPassphrase => 'Неверная фраза, либо файл изменён.';

  @override
  String get backupConfirmTitle => 'Восстановить эту копию?';

  @override
  String backupConfirmBody(String date, int sources, int lists, int favorites) {
    return 'Копия от $date. Источники: $sources, списки: $lists, избранное: $favorites. Текущие данные сохраняются и дополняются; заменяются только настройки.';
  }

  @override
  String get backupRestored => 'Восстановление завершено.';

  @override
  String backupIncomplete(int count) {
    return 'Восстановление завершено. Источников для дополнения: $count. Пароля или адреса не было в файле.';
  }

  @override
  String get autoTitle => 'Автообновление';

  @override
  String get autoOff => 'Выключено';

  @override
  String autoEvery(int hours) {
    return 'Каждые $hours ч';
  }

  @override
  String get dataTitle => 'Локальные данные';

  @override
  String cacheLine(String size) {
    return 'Кэш логотипов: $size МБ';
  }

  @override
  String get cacheClear => 'Очистить кэш';

  @override
  String get cacheCleared => 'Кэш очищен.';

  @override
  String get wipeButton => 'Стереть все данные';

  @override
  String get wipeTitle => 'Стереть всё?';

  @override
  String get wipeBody =>
      'Источники, избранное, телегид, загрузки и настройки будут удалены с этого устройства. Это действие необратимо.';

  @override
  String get wipeConfirm => 'Стереть всё';

  @override
  String get updateTitle => 'Обновления';

  @override
  String get updateAuto => 'Проверять автоматически';

  @override
  String get updateCheck => 'Проверить обновления';

  @override
  String get updateChecking => 'Проверка…';

  @override
  String get updateLatest => 'У вас последняя версия.';

  @override
  String updateAvailable(String version) {
    return 'Доступна версия $version';
  }

  @override
  String get updateSee => 'Показать';

  @override
  String get updateInstall => 'Обновить';

  @override
  String updateDownloading(int percent) {
    return 'Загрузка… $percent %';
  }

  @override
  String get updateVerifying => 'Проверка файла…';

  @override
  String get updateRestarting => 'Установка: приложение перезапустится.';

  @override
  String get updateConfirmSystem => 'Подтвердите установку в окне системы.';

  @override
  String get updateOpened =>
      'Загрузка открыта в браузере: установите её и перезапустите приложение.';

  @override
  String get updateCancelled => 'Обновление отменено.';

  @override
  String get updateNoChannel => 'Эта сборка не подключена к каналу обновлений.';

  @override
  String get updateFailedNetwork => 'Сервер обновлений недоступен.';

  @override
  String get updateFailedSignature => 'Неверная подпись: обновление отклонено.';

  @override
  String get updateFailedIntegrity => 'Файл повреждён: ничего не установлено.';

  @override
  String get updateFailedInstall => 'Не удалось выполнить установку.';

  @override
  String updateDone(String version) {
    return 'Обновление до версии $version установлено.';
  }

  @override
  String updateNotApplied(String version) {
    return 'Не удалось установить обновление до версии $version: осталась прежняя версия.';
  }

  @override
  String get navDownloads => 'Загрузки';

  @override
  String get downloadAction => 'Скачать';

  @override
  String get downloadSeason => 'Скачать сезон';

  @override
  String downloadAdded(String title) {
    return 'Добавлено в загрузки: $title';
  }

  @override
  String get downloadPlay => 'Воспроизвести файл';

  @override
  String get downloadEmptyTitle => 'Загрузок нет';

  @override
  String get downloadEmptyBody =>
      'Скачайте фильм с его страницы или серию из сериала, чтобы смотреть без подключения.';

  @override
  String get downloadQueued => 'В очереди';

  @override
  String get downloadPaused => 'Пауза';

  @override
  String get downloadHeld => 'Ожидает окончания воспроизведения';

  @override
  String get downloadPause => 'Приостановить';

  @override
  String get downloadResume => 'Продолжить';

  @override
  String get downloadDeleteTitle => 'Удалить эту загрузку?';

  @override
  String downloadDeleteBody(String title) {
    return '«$title» будет удалено с этого устройства.';
  }

  @override
  String get downloadFolder => 'Папка загрузок';

  @override
  String downloadSizeMb(String size) {
    return '$size МБ';
  }

  @override
  String downloadSizeGb(String size) {
    return '$size ГБ';
  }

  @override
  String get downloadErrorNetwork =>
      'Соединение потеряно. Файл сохранён: загрузка продолжится с того же места.';

  @override
  String get downloadErrorServer =>
      'Сервер отказал. Возможно, ваше подключение занято другим просмотром.';

  @override
  String get downloadErrorFormat =>
      'Этот контент передаётся по частям, его нельзя скачать.';

  @override
  String get downloadErrorDisk =>
      'Не удалось записать: мало места или папка недоступна.';

  @override
  String get downloadErrorSource =>
      'Источник этой загрузки больше не существует.';

  @override
  String get downloadErrorMissing => 'Файл перемещён или удалён.';

  @override
  String get downloadFolderChoose => 'Выбрать папку';

  @override
  String get downloadFolderReset => 'Папка по умолчанию';

  @override
  String get downloadFolderApp => 'Папка приложения, удаляется вместе с ним';

  @override
  String get downloadFolderHint =>
      'Действует для следующих загрузок. Завершённые останутся на месте.';

  @override
  String get favChooseBody =>
      'У вас пока нет списков. Куда добавить это избранное?';

  @override
  String get favGlobal => 'Общее избранное';

  @override
  String get settingsPhoneTitle => 'Воспроизведение на телефоне';

  @override
  String get settingsPip => 'Картинка в картинке';

  @override
  String get settingsPipBody =>
      'Видео продолжается в маленьком окне, когда вы выходите из приложения. В плеере появляется кнопка.';

  @override
  String get settingsRadio => 'Режим радио';

  @override
  String get settingsRadioBody =>
      'Звук продолжается, когда телефон заблокирован или приложение в фоне. В плеере появляется кнопка.';

  @override
  String get playerPipOn => 'Картинка в картинке включена';

  @override
  String get playerPipOff => 'Картинка в картинке выключена';

  @override
  String get playerRadioOn => 'Режим радио включён';

  @override
  String get playerRadioOff => 'Режим радио выключен';

  @override
  String get radioNotificationStop => 'Остановить';
}
