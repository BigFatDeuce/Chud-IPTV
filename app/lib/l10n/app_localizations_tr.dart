// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get navLive => 'Canlı';

  @override
  String get navFavorites => 'Favoriler';

  @override
  String get navMovies => 'Filmler';

  @override
  String get navSeries => 'Diziler';

  @override
  String get navSources => 'Kaynaklar';

  @override
  String get navSettings => 'Ayarlar';

  @override
  String get navMore => 'Daha fazla';

  @override
  String get commonCancel => 'İptal';

  @override
  String get commonSave => 'Kaydet';

  @override
  String get commonDelete => 'Sil';

  @override
  String get commonClose => 'Kapat';

  @override
  String get commonRetry => 'Yeniden dene';

  @override
  String get welcomeTitle => 'Hoş geldiniz';

  @override
  String get welcomeBody =>
      'Başlamak için bir kaynak ekleyin: Xtream Codes hesabı veya M3U listesi. Uygulama kanal sağlamaz, her şey bu cihazda kalır.';

  @override
  String get addSource => 'Kaynak ekle';

  @override
  String get allSources => 'Tüm kaynaklar';

  @override
  String get allCategories => 'Tümü';

  @override
  String get noCategoryName => 'Kategorisiz';

  @override
  String get filterCategories => 'Kategorileri süz';

  @override
  String get emptyList => 'Burada gösterilecek bir şey yok.';

  @override
  String get emptyWhileImporting =>
      'İçe aktarılıyor, katalog hazır olunca görünecek.';

  @override
  String itemCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString öğe',
      zero: 'Öğe yok',
    );
    return '$_temp0';
  }

  @override
  String get viewCompact => 'Sıkı liste';

  @override
  String get viewDetailed => 'Ayrıntılı liste';

  @override
  String get viewGrid => 'Izgara';

  @override
  String get searchHint => 'Ara';

  @override
  String noResults(String query) {
    return '“$query” için sonuç yok.';
  }

  @override
  String get sortLabel => 'Sırala';

  @override
  String get sortSource => 'Kaynak sırası';

  @override
  String get sortNameAsc => 'Ad (A → Z)';

  @override
  String get sortNameDesc => 'Ad (Z → A)';

  @override
  String get sortRecent => 'Son eklenenler';

  @override
  String get sortRating => 'En yüksek puanlılar';

  @override
  String get filterLabel => 'Filtreler';

  @override
  String get filterCountry => 'Ülke veya dil';

  @override
  String get filterAllCountries => 'Tüm ülkeler';

  @override
  String get itemSource => 'Kaynak';

  @override
  String get itemCategory => 'Kategori';

  @override
  String get itemCountry => 'Ülke veya dil';

  @override
  String get itemFormat => 'Biçim';

  @override
  String get itemRating => 'Puan';

  @override
  String get favAdd => 'Favorilere ekle';

  @override
  String get favRemove => 'Favorilerden çıkar';

  @override
  String get favPickLists => 'Favori listeleri';

  @override
  String get favNewList => 'Yeni liste';

  @override
  String get favDefaultName => 'Favoriler';

  @override
  String get favListName => 'Liste adı';

  @override
  String get favListIcon => 'Simge';

  @override
  String get favRename => 'Listeyi düzenle';

  @override
  String get favDeleteList => 'Listeyi sil';

  @override
  String favDeleteConfirm(String name) {
    return '“$name” listesi silinsin mi? Kanallar katalogda kalır.';
  }

  @override
  String get favEmptyLists =>
      'Listelerinizi oluşturun: spor, haber, çocuk… Aynı kanal birden çok listede olabilir.';

  @override
  String get favEmptyList => 'Bu liste boş. Yıldızla kanal ekleyin.';

  @override
  String get favManage => 'Listeleri yönet';

  @override
  String get favMoveUp => 'Yukarı taşı';

  @override
  String get favMoveDown => 'Aşağı taşı';

  @override
  String favListLine(String name, int count) {
    return '$name ($count)';
  }

  @override
  String get filteredIntro =>
      'FILTERED, kaynaklarınızdaki grupları ülke, bölge ve temaya göre otomatik toplar. Canlı sekmesi ve listeleriniz değişmez.';

  @override
  String get filteredNoGroups =>
      'Henüz çözümlenecek grup yok. Bir kaynağı yenileyin.';

  @override
  String get filteredAnalyze => 'Otomatik düzenle';

  @override
  String get filteredManage => 'Düzenleme';

  @override
  String get filteredReanalyze => 'Yeniden çözümle ve düzelt';

  @override
  String get filteredRestore => 'Otomatik düzeni geri yükle';

  @override
  String get filteredRestoreConfirm =>
      'Elle yaptığınız düzeltmeler unutulur. Onaylamadan önce önizlemeyi görürsünüz.';

  @override
  String get filteredPreviewTitle => 'Düzen önizlemesi';

  @override
  String filteredSummary(int groups, int nodes) {
    final intl.NumberFormat groupsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String groupsString = groupsNumberFormat.format(groups);
    final intl.NumberFormat nodesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String nodesString = nodesNumberFormat.format(nodes);

    return '$nodesString kategoride $groupsString grup';
  }

  @override
  String filteredDelta(int added, int removed) {
    return 'Son çözümlemeden beri: $added yeni, $removed kaldırıldı';
  }

  @override
  String filteredNewGroups(int count) {
    return 'Düzenlenecek $count yeni grup: önizlemeyi aç';
  }

  @override
  String filteredToCheck(int count) {
    return 'Kontrol edilecek ($count)';
  }

  @override
  String filteredUnclassified(int count) {
    return 'Sınıflandırılmamış ($count)';
  }

  @override
  String filteredExcluded(int count) {
    return 'Hariç tutulan gruplar ($count)';
  }

  @override
  String filteredGroupsCount(int count) {
    return '$count grup';
  }

  @override
  String get filteredValidate => 'Bu düzeni onayla';

  @override
  String get filteredAccept => 'Doğru';

  @override
  String get filteredMove => 'Şuraya taşı…';

  @override
  String get filteredExclude => 'Düzenden hariç tut';

  @override
  String get filteredRestoreGroup => 'Geri al';

  @override
  String get filteredNewCategory => 'Yeni kategori';

  @override
  String get filteredRename => 'Yeniden adlandır';

  @override
  String get filteredMerge => 'Şununla birleştir…';

  @override
  String get sourcesTitle => 'IPTV kaynakları';

  @override
  String get refreshAll => 'Tümünü yenile';

  @override
  String get refresh => 'Yenile';

  @override
  String get editSource => 'Düzenle';

  @override
  String get deleteSource => 'Kaynağı sil';

  @override
  String deleteSourceConfirm(String name) {
    return '“$name” ve tüm kataloğu bu cihazdan silinsin mi?';
  }

  @override
  String get sourceEnabled => 'Etkin';

  @override
  String get makeDefault => 'Varsayılan yap';

  @override
  String get isDefault => 'Varsayılan kaynak';

  @override
  String get kindXtream => 'Xtream Codes';

  @override
  String get kindM3uUrl => 'Çevrimiçi liste';

  @override
  String get kindM3uFile => 'M3U dosyası';

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

    return '$liveString kanal · $moviesString film · $seriesString dizi';
  }

  @override
  String get neverRefreshed => 'Hiç yenilenmedi';

  @override
  String refreshedAt(String date) {
    return 'Yenilendi: $date';
  }

  @override
  String expiresAt(String date) {
    return 'Abonelik bitişi: $date';
  }

  @override
  String maxConnections(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count eşzamanlı yayın',
    );
    return '$_temp0';
  }

  @override
  String get applyAnyway => 'Yine de uygula';

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

    return '“$name”: $addedString eklendi, $updatedString değişti, $missingString kaldırıldı.';
  }

  @override
  String get stageConnecting => 'Sunucuya bağlanıyor…';

  @override
  String get stageLive => 'Kanallar indiriliyor…';

  @override
  String get stageMovies => 'Filmler indiriliyor…';

  @override
  String get stageSeries => 'Diziler indiriliyor…';

  @override
  String get stagePlaylist => 'Liste indiriliyor…';

  @override
  String get stageWriting => 'Katalog kaydediliyor…';

  @override
  String stageWritingCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Kaydediliyor: $countString öğe…';
  }

  @override
  String get stageQueued => 'Bekleniyor…';

  @override
  String get errorNetwork =>
      'Sunucuya ulaşılamıyor. Adresi ve bağlantınızı kontrol edin.';

  @override
  String get errorTimeout => 'Sunucu yanıt vermekte gecikiyor.';

  @override
  String get errorCredentials =>
      'Sunucu kullanıcı adını veya şifreyi reddetti.';

  @override
  String get errorExpired => 'Bu aboneliğin süresi doldu.';

  @override
  String get errorNotFound => 'Bu sunucuda adres bulunamadı.';

  @override
  String get errorNotPlaylist => 'Bu içerik bir M3U listesi değil.';

  @override
  String get errorInvalidData => 'Sunucu okunamayan bir yanıt gönderdi.';

  @override
  String get errorEmpty => 'Kaynak boş: mevcut katalog korunuyor.';

  @override
  String errorSuspicious(String detail) {
    return 'Liste olağandışı küçük ($detail): mevcut katalog korunuyor.';
  }

  @override
  String get errorFileMissing => 'Dosya bulunamadı veya okunamıyor.';

  @override
  String get errorUnknown => 'Yenileme başarısız. Mevcut katalog korunuyor.';

  @override
  String get formNewTitle => 'Yeni kaynak';

  @override
  String get formEditTitle => 'Kaynağı düzenle';

  @override
  String get formName => 'Ad';

  @override
  String get formNameHint => 'Örn.: Salon, Abonelik 1';

  @override
  String get formServer => 'Sunucu adresi';

  @override
  String get formUsername => 'Kullanıcı adı';

  @override
  String get formPassword => 'Şifre';

  @override
  String get formShowPassword => 'Şifreyi göster';

  @override
  String get formPlaylistUrl => 'Liste adresi (M3U veya M3U8)';

  @override
  String get formFile => 'Liste dosyası';

  @override
  String get formChooseFile => 'Dosya seç';

  @override
  String get formNoFile => 'Dosya seçilmedi';

  @override
  String get formFileUnavailable => 'Bu cihazda dosya seçici yok.';

  @override
  String get formRequired => 'Zorunlu alan';

  @override
  String get formInvalidUrl => 'Geçersiz adres';

  @override
  String get formContentTitle => 'İçe aktarılacak içerik';

  @override
  String get formContentHint =>
      'Canlı yayın her zaman aktarılır. Film ve dizi olmadan yükleme çok daha hafiftir.';

  @override
  String get formMovies => 'Filmler';

  @override
  String get formSeries => 'Diziler';

  @override
  String get formContentRemoved =>
      'Aktarılmış öğeler ve favorileri bu cihazdan kaldırılacak.';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeDark => 'Koyu';

  @override
  String get themeLight => 'Açık';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get languageSystem => 'Sistem dili';

  @override
  String get settingsApp => 'Uygulama';

  @override
  String settingsVersion(String version) {
    return 'Sürüm $version';
  }

  @override
  String get settingsPrivacy =>
      'Hesap yok, telemetri yok: kaynaklarınız ve verileriniz bu cihazda kalır.';

  @override
  String get settingsShortcuts =>
      'Ctrl+F: ara · F5: tümünü yenile · Ctrl+1-9: sekme değiştir';

  @override
  String get playerPlay => 'Oynat';

  @override
  String get playerPause => 'Duraklat';

  @override
  String get playerPrevious => 'Önceki';

  @override
  String get playerNext => 'Sonraki';

  @override
  String get playerRefresh => 'Yayını yenile';

  @override
  String get playerFullscreen => 'Tam ekran';

  @override
  String get playerExitFullscreen => 'Tam ekrandan çık';

  @override
  String get playerMute => 'Sesi kapat';

  @override
  String get playerUnmute => 'Sesi aç';

  @override
  String get playerLive => 'CANLI';

  @override
  String playerReconnecting(int attempt, int total) {
    return 'Yeniden bağlanıyor… ($attempt/$total)';
  }

  @override
  String get playerSignalLost => 'Sinyal kesildi…';

  @override
  String get playerFailedTitle => 'Oynatılamıyor';

  @override
  String get playerFailedBody =>
      'Bu yayın yanıt vermiyor. Çevrimdışı olabilir veya aboneliğiniz başka bir cihazda kullanılıyor olabilir.';

  @override
  String get playerEndedTitle => 'Oynatma bitti';

  @override
  String get playerBackToList => 'Listeye dön';

  @override
  String get externalTitle => 'Harici oynatıcı';

  @override
  String get externalOpen => 'Harici oynatıcıda aç';

  @override
  String get externalNone =>
      'Oynatıcı bulunamadı. VLC yüklüyse otomatik kullanılır.';

  @override
  String get externalFailed =>
      'Harici oynatıcı başlatılamadı. Ayarlardan konumunu kontrol edin.';

  @override
  String get externalDefault => 'VLC kullan';

  @override
  String get seriesFailed => 'Bölümler yüklenemedi.';

  @override
  String get seriesEmpty => 'Bölüm yok.';

  @override
  String seriesSeason(int number) {
    return '$number. Sezon';
  }

  @override
  String seriesEpisode(int number) {
    return '$number. Bölüm';
  }

  @override
  String seriesMinutes(int count) {
    return '$count dk';
  }

  @override
  String get navGuide => 'Rehber';

  @override
  String get guideTitle => 'Yayın rehberi';

  @override
  String get guideScope => 'Gösterilen kanallar';

  @override
  String get guideAllChannels => 'Tüm kanallar';

  @override
  String get guideNow => 'Şimdi';

  @override
  String get guideToday => 'Bugün';

  @override
  String get guideYesterday => 'Dün';

  @override
  String get guideTomorrow => 'Yarın';

  @override
  String get guideEarlier => '2 saat önce';

  @override
  String get guideLater => '2 saat sonra';

  @override
  String get guideEmptyTitle => 'Yayın rehberi yok';

  @override
  String get guideEmptyBody =>
      'Kaynaklarınızın rehberini içe aktarın veya ayarlardan bir XMLTV adresi ya da dosyası ekleyin.';

  @override
  String get guideImport => 'Rehberi içe aktar';

  @override
  String guideImporting(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Rehber içe aktarılıyor… $countString program';
  }

  @override
  String guideDone(int programs, int channels) {
    final intl.NumberFormat programsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String programsString = programsNumberFormat.format(programs);
    final intl.NumberFormat channelsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String channelsString = channelsNumberFormat.format(channels);

    return 'Rehber güncellendi: $programsString program, $channelsString kanal eşleşti.';
  }

  @override
  String guideFailed(String names) {
    return 'Rehber kullanılamıyor: $names. Önceki rehber korunuyor.';
  }

  @override
  String guideSourceLine(int count, String date) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString program · $date';
  }

  @override
  String get guideNeverRefreshed => 'Hiç güncellenmedi';

  @override
  String get guideLastFailed => 'Son güncelleme başarısız oldu.';

  @override
  String get guideRefresh => 'Rehberi güncelle';

  @override
  String get guideAddUrl => 'Adres ekle';

  @override
  String get guideAddFile => 'Dosya ekle';

  @override
  String get guideUrlHint => 'XMLTV rehber adresi';

  @override
  String get guideWatchLive => 'Canlı izle';

  @override
  String get guideReplay => 'Tekrar izle';

  @override
  String get guideReplayOff => 'Bu program için tekrar izleme yok.';

  @override
  String get guideComing => 'Yakında';

  @override
  String get guideChannel => 'Kanal yayın akışı';

  @override
  String get guideLink => 'Rehberle eşleştir';

  @override
  String get guideLinkHint => 'Kanal adı veya kimliği';

  @override
  String get guideNoProgram => 'Bu kanal için program yok.';

  @override
  String get guideNoChannels => 'Bu seçimdeki hiçbir kanalın rehberi yok.';

  @override
  String get backupTitle => 'Yedekleme';

  @override
  String get backupExport => 'Yedek oluştur';

  @override
  String get backupImport => 'Yedeği geri yükle';

  @override
  String get backupRestore => 'Geri yükle';

  @override
  String get backupSecrets => 'Parolaları dahil et';

  @override
  String get backupSecretsBody =>
      'Dosya bu durumda parola öbeğinizle şifrelenir. Aksi halde parolalar ve oynatma listelerinin tam adresleri kaydedilmez.';

  @override
  String get backupPassphrase => 'Parola öbeği';

  @override
  String get backupPassphraseAgain => 'Parola öbeğini doğrula';

  @override
  String get backupPassphraseShort => 'En az 8 karakter.';

  @override
  String get backupPassphraseMismatch => 'İki parola öbeği farklı.';

  @override
  String get backupSaved => 'Yedek kaydedildi.';

  @override
  String get backupFailed => 'Bu dosya yazılamadı.';

  @override
  String get backupNotOurs => 'Bu dosya bir Chud IPTV yedeği değil.';

  @override
  String get backupTooNew => 'Bu yedek uygulamanın daha yeni bir sürümünden.';

  @override
  String get backupDamaged => 'Bu yedek hasarlı.';

  @override
  String get backupWrongPassphrase =>
      'Yanlış parola öbeği veya dosya değiştirilmiş.';

  @override
  String get backupConfirmTitle => 'Bu yedek geri yüklensin mi?';

  @override
  String backupConfirmBody(String date, int sources, int lists, int favorites) {
    return '$date tarihli yedek. Kaynak: $sources, liste: $lists, favori: $favorites. Mevcut verileriniz korunur ve tamamlanır; yalnızca ayarlar değiştirilir.';
  }

  @override
  String get backupRestored => 'Geri yükleme tamamlandı.';

  @override
  String backupIncomplete(int count) {
    return 'Geri yükleme tamamlandı. Tamamlanacak kaynak: $count. Parola veya adres dosyada yoktu.';
  }

  @override
  String get autoTitle => 'Otomatik güncelleme';

  @override
  String get autoOff => 'Kapalı';

  @override
  String autoEvery(int hours) {
    return '$hours saatte bir';
  }

  @override
  String get dataTitle => 'Yerel veriler';

  @override
  String cacheLine(String size) {
    return 'Logo önbelleği: $size MB';
  }

  @override
  String get cacheClear => 'Önbelleği temizle';

  @override
  String get cacheCleared => 'Önbellek temizlendi.';

  @override
  String get wipeButton => 'Tüm verileri sil';

  @override
  String get wipeTitle => 'Her şey silinsin mi?';

  @override
  String get wipeBody =>
      'Kaynaklar, favoriler, rehber, indirilenler ve ayarlar bu cihazdan silinecek. Bu işlem geri alınamaz.';

  @override
  String get wipeConfirm => 'Her şeyi sil';

  @override
  String get updateTitle => 'Güncellemeler';

  @override
  String get updateAuto => 'Otomatik denetle';

  @override
  String get updateCheck => 'Güncellemeleri denetle';

  @override
  String get updateChecking => 'Denetleniyor…';

  @override
  String get updateLatest => 'En son sürümü kullanıyorsunuz.';

  @override
  String updateAvailable(String version) {
    return '$version sürümü hazır';
  }

  @override
  String get updateSee => 'Gör';

  @override
  String get updateInstall => 'Güncelle';

  @override
  String updateDownloading(int percent) {
    return 'İndiriliyor… %$percent';
  }

  @override
  String get updateVerifying => 'Dosya doğrulanıyor…';

  @override
  String get updateRestarting => 'Yükleniyor: uygulama yeniden başlayacak.';

  @override
  String get updateConfirmSystem => 'Yüklemeyi sistem penceresinde onaylayın.';

  @override
  String get updateOpened =>
      'İndirme tarayıcınızda açıldı: yükleyin, sonra uygulamayı yeniden başlatın.';

  @override
  String get updateCancelled => 'Güncelleme iptal edildi.';

  @override
  String get updateNoChannel => 'Bu sürüm bir güncelleme kanalına bağlı değil.';

  @override
  String get updateFailedNetwork => 'Güncelleme sunucusuna ulaşılamadı.';

  @override
  String get updateFailedSignature => 'Geçersiz imza: güncelleme reddedildi.';

  @override
  String get updateFailedIntegrity => 'Dosya bozuk: hiçbir şey yüklenmedi.';

  @override
  String get updateFailedInstall => 'Yükleme başarısız oldu.';

  @override
  String updateDone(String version) {
    return '$version sürümüne güncelleme yüklendi.';
  }

  @override
  String updateNotApplied(String version) {
    return '$version sürümüne güncelleme yüklenemedi: önceki sürüm yerinde kalıyor.';
  }

  @override
  String get navDownloads => 'İndirilenler';

  @override
  String get downloadAction => 'İndir';

  @override
  String get downloadSeason => 'Sezonu indir';

  @override
  String downloadAdded(String title) {
    return 'İndirilenlere eklendi: $title';
  }

  @override
  String get downloadPlay => 'Dosyayı oynat';

  @override
  String get downloadEmptyTitle => 'İndirme yok';

  @override
  String get downloadEmptyBody =>
      'Çevrimdışı izlemek için bir filmi sayfasından, bir bölümü dizisinden indirin.';

  @override
  String get downloadQueued => 'Bekliyor';

  @override
  String get downloadPaused => 'Duraklatıldı';

  @override
  String get downloadHeld => 'Oynatmanın bitmesi bekleniyor';

  @override
  String get downloadPause => 'Duraklat';

  @override
  String get downloadResume => 'Sürdür';

  @override
  String get downloadDeleteTitle => 'Bu indirme silinsin mi?';

  @override
  String downloadDeleteBody(String title) {
    return '$title bu cihazdan kaldırılacak.';
  }

  @override
  String get downloadFolder => 'İndirme klasörü';

  @override
  String downloadSizeMb(String size) {
    return '$size MB';
  }

  @override
  String downloadSizeGb(String size) {
    return '$size GB';
  }

  @override
  String get downloadErrorNetwork =>
      'Bağlantı kesildi. Dosya korunuyor: kaldığı yerden devam eder.';

  @override
  String get downloadErrorServer =>
      'Sunucu reddetti. Bağlantınızı başka bir oynatma kullanıyor olabilir.';

  @override
  String get downloadErrorFormat =>
      'Bu içerik parçalar halinde yayınlanıyor ve indirilemez.';

  @override
  String get downloadErrorDisk =>
      'Yazılamadı: disk alanı yetersiz veya klasöre erişilemiyor.';

  @override
  String get downloadErrorSource => 'Bu indirmenin kaynağı artık yok.';

  @override
  String get downloadErrorMissing => 'Dosya taşınmış veya silinmiş.';

  @override
  String get downloadFolderChoose => 'Klasör seç';

  @override
  String get downloadFolderReset => 'Varsayılan klasör';

  @override
  String get downloadFolderApp =>
      'Uygulama klasörü, uygulamayla birlikte silinir';

  @override
  String get downloadFolderHint =>
      'Sonraki indirmeler için geçerlidir. Bitenler yerinde kalır.';

  @override
  String get favChooseBody =>
      'Henüz bir listeniz yok. Bu favoriyi nereye kaydetmek istersiniz?';

  @override
  String get favGlobal => 'Genel favoriler';

  @override
  String get settingsPhoneTitle => 'Telefonda oynatma';

  @override
  String get settingsPip => 'Resim içinde resim';

  @override
  String get settingsPipBody =>
      'Uygulamadan çıktığınızda video küçük bir pencerede oynamaya devam eder. Oynatıcıda bir düğme görünür.';

  @override
  String get settingsRadio => 'Radyo modu';

  @override
  String get settingsRadioBody =>
      'Telefon kilitliyken veya uygulama arka plandayken ses devam eder. Oynatıcıda bir düğme görünür.';

  @override
  String get playerPipOn => 'Resim içinde resim açık';

  @override
  String get playerPipOff => 'Resim içinde resim kapalı';

  @override
  String get playerRadioOn => 'Radyo modu açık';

  @override
  String get playerRadioOff => 'Radyo modu kapalı';

  @override
  String get radioNotificationStop => 'Durdur';
}
