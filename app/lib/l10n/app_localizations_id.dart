// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get navLive => 'Langsung';

  @override
  String get navFavorites => 'Favorit';

  @override
  String get navMovies => 'Film';

  @override
  String get navSeries => 'Serial';

  @override
  String get navSources => 'Sumber';

  @override
  String get navSettings => 'Pengaturan';

  @override
  String get navMore => 'Lainnya';

  @override
  String get commonCancel => 'Batal';

  @override
  String get commonSave => 'Simpan';

  @override
  String get commonDelete => 'Hapus';

  @override
  String get commonClose => 'Tutup';

  @override
  String get commonRetry => 'Coba lagi';

  @override
  String get welcomeTitle => 'Selamat datang';

  @override
  String get welcomeBody =>
      'Tambahkan sumber untuk memulai: akun Xtream Codes atau daftar putar M3U. Aplikasi ini tidak menyediakan saluran dan semua data tetap di perangkat ini.';

  @override
  String get addSource => 'Tambah sumber';

  @override
  String get allSources => 'Semua sumber';

  @override
  String get allCategories => 'Semua';

  @override
  String get noCategoryName => 'Tanpa kategori';

  @override
  String get filterCategories => 'Saring kategori';

  @override
  String get emptyList => 'Tidak ada yang ditampilkan.';

  @override
  String get emptyWhileImporting =>
      'Sedang mengimpor, katalog akan muncul setelah siap.';

  @override
  String itemCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString item',
      zero: 'Tidak ada item',
    );
    return '$_temp0';
  }

  @override
  String get viewCompact => 'Daftar ringkas';

  @override
  String get viewDetailed => 'Daftar rinci';

  @override
  String get viewGrid => 'Kisi';

  @override
  String get searchHint => 'Cari';

  @override
  String noResults(String query) {
    return 'Tidak ada hasil untuk “$query”.';
  }

  @override
  String get sortLabel => 'Urutkan';

  @override
  String get sortSource => 'Urutan sumber';

  @override
  String get sortNameAsc => 'Nama (A → Z)';

  @override
  String get sortNameDesc => 'Nama (Z → A)';

  @override
  String get sortRecent => 'Baru ditambahkan';

  @override
  String get sortRating => 'Nilai tertinggi';

  @override
  String get filterLabel => 'Filter';

  @override
  String get filterCountry => 'Negara atau bahasa';

  @override
  String get filterAllCountries => 'Semua negara';

  @override
  String get itemSource => 'Sumber';

  @override
  String get itemCategory => 'Kategori';

  @override
  String get itemCountry => 'Negara atau bahasa';

  @override
  String get itemFormat => 'Format';

  @override
  String get itemRating => 'Nilai';

  @override
  String get favAdd => 'Tambah ke favorit';

  @override
  String get favRemove => 'Hapus dari favorit';

  @override
  String get favPickLists => 'Daftar favorit';

  @override
  String get favNewList => 'Daftar baru';

  @override
  String get favDefaultName => 'Favorit';

  @override
  String get favListName => 'Nama daftar';

  @override
  String get favListIcon => 'Ikon';

  @override
  String get favRename => 'Ubah daftar';

  @override
  String get favDeleteList => 'Hapus daftar';

  @override
  String favDeleteConfirm(String name) {
    return 'Hapus daftar “$name”? Saluran tetap ada di katalog.';
  }

  @override
  String get favEmptyLists =>
      'Buat daftar Anda: olahraga, berita, anak… Satu saluran bisa ada di beberapa daftar.';

  @override
  String get favEmptyList =>
      'Daftar ini kosong. Tambahkan saluran dengan bintang.';

  @override
  String get favManage => 'Kelola daftar';

  @override
  String get favMoveUp => 'Naikkan';

  @override
  String get favMoveDown => 'Turunkan';

  @override
  String favListLine(String name, int count) {
    return '$name ($count)';
  }

  @override
  String get filteredIntro =>
      'FILTERED otomatis mengelompokkan grup sumber Anda menurut negara, wilayah, dan tema. Tab Langsung dan daftar putar Anda tidak berubah.';

  @override
  String get filteredNoGroups =>
      'Belum ada grup untuk dianalisis. Segarkan sumber.';

  @override
  String get filteredAnalyze => 'Atur otomatis';

  @override
  String get filteredManage => 'Pengaturan grup';

  @override
  String get filteredReanalyze => 'Analisis ulang dan koreksi';

  @override
  String get filteredRestore => 'Pulihkan pengaturan otomatis';

  @override
  String get filteredRestoreConfirm =>
      'Koreksi manual Anda akan dilupakan. Anda akan melihat pratinjau sebelum mengonfirmasi.';

  @override
  String get filteredPreviewTitle => 'Pratinjau pengaturan';

  @override
  String filteredSummary(int groups, int nodes) {
    final intl.NumberFormat groupsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String groupsString = groupsNumberFormat.format(groups);
    final intl.NumberFormat nodesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String nodesString = nodesNumberFormat.format(nodes);

    return '$groupsString grup dalam $nodesString kategori';
  }

  @override
  String filteredDelta(int added, int removed) {
    return 'Sejak analisis terakhir: $added baru, $removed hilang';
  }

  @override
  String filteredNewGroups(int count) {
    return '$count grup baru untuk diatur: buka pratinjau';
  }

  @override
  String filteredToCheck(int count) {
    return 'Perlu diperiksa ($count)';
  }

  @override
  String filteredUnclassified(int count) {
    return 'Belum diatur ($count)';
  }

  @override
  String filteredExcluded(int count) {
    return 'Grup dikecualikan ($count)';
  }

  @override
  String filteredGroupsCount(int count) {
    return '$count grup';
  }

  @override
  String get filteredValidate => 'Konfirmasi pengaturan ini';

  @override
  String get filteredAccept => 'Sudah benar';

  @override
  String get filteredMove => 'Pindahkan ke…';

  @override
  String get filteredExclude => 'Kecualikan dari pengaturan';

  @override
  String get filteredRestoreGroup => 'Kembalikan';

  @override
  String get filteredNewCategory => 'Kategori baru';

  @override
  String get filteredRename => 'Ubah nama';

  @override
  String get filteredMerge => 'Gabungkan ke…';

  @override
  String get sourcesTitle => 'Sumber IPTV';

  @override
  String get refreshAll => 'Segarkan semua';

  @override
  String get refresh => 'Segarkan';

  @override
  String get editSource => 'Ubah';

  @override
  String get deleteSource => 'Hapus sumber';

  @override
  String deleteSourceConfirm(String name) {
    return 'Hapus “$name” dan seluruh katalognya dari perangkat ini?';
  }

  @override
  String get sourceEnabled => 'Aktif';

  @override
  String get makeDefault => 'Jadikan default';

  @override
  String get isDefault => 'Sumber default';

  @override
  String get kindXtream => 'Xtream Codes';

  @override
  String get kindM3uUrl => 'Daftar putar daring';

  @override
  String get kindM3uFile => 'Berkas M3U';

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

    return '$liveString saluran · $moviesString film · $seriesString serial';
  }

  @override
  String get neverRefreshed => 'Belum pernah disegarkan';

  @override
  String refreshedAt(String date) {
    return 'Disegarkan $date';
  }

  @override
  String expiresAt(String date) {
    return 'Langganan berlaku hingga $date';
  }

  @override
  String maxConnections(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pemutaran serentak',
    );
    return '$_temp0';
  }

  @override
  String get applyAnyway => 'Tetap terapkan';

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

    return '“$name”: $addedString ditambah, $updatedString diubah, $missingString hilang.';
  }

  @override
  String get stageConnecting => 'Menghubungkan ke server…';

  @override
  String get stageLive => 'Mengunduh saluran…';

  @override
  String get stageMovies => 'Mengunduh film…';

  @override
  String get stageSeries => 'Mengunduh serial…';

  @override
  String get stagePlaylist => 'Mengunduh daftar putar…';

  @override
  String get stageWriting => 'Menyimpan katalog…';

  @override
  String stageWritingCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Menyimpan: $countString item…';
  }

  @override
  String get stageQueued => 'Menunggu…';

  @override
  String get errorNetwork =>
      'Server tidak dapat dijangkau. Periksa alamat dan koneksi Anda.';

  @override
  String get errorTimeout => 'Server terlalu lama merespons.';

  @override
  String get errorCredentials =>
      'Server menolak nama pengguna atau kata sandi.';

  @override
  String get errorExpired => 'Langganan ini telah berakhir.';

  @override
  String get errorNotFound => 'Alamat tidak ditemukan di server ini.';

  @override
  String get errorNotPlaylist => 'Konten ini bukan daftar putar M3U.';

  @override
  String get errorInvalidData => 'Server mengirim respons yang tidak terbaca.';

  @override
  String get errorEmpty => 'Sumber kosong: katalog saat ini dipertahankan.';

  @override
  String errorSuspicious(String detail) {
    return 'Daftar terlalu kecil ($detail): katalog saat ini dipertahankan.';
  }

  @override
  String get errorFileMissing => 'Berkas tidak ditemukan atau tidak terbaca.';

  @override
  String get errorUnknown =>
      'Gagal menyegarkan. Katalog saat ini dipertahankan.';

  @override
  String get formNewTitle => 'Sumber baru';

  @override
  String get formEditTitle => 'Ubah sumber';

  @override
  String get formName => 'Nama';

  @override
  String get formNameHint => 'Mis.: Ruang tamu, Langganan 1';

  @override
  String get formServer => 'Alamat server';

  @override
  String get formUsername => 'Nama pengguna';

  @override
  String get formPassword => 'Kata sandi';

  @override
  String get formShowPassword => 'Tampilkan kata sandi';

  @override
  String get formPlaylistUrl => 'Alamat daftar putar (M3U atau M3U8)';

  @override
  String get formFile => 'Berkas daftar putar';

  @override
  String get formChooseFile => 'Pilih berkas';

  @override
  String get formNoFile => 'Belum ada berkas';

  @override
  String get formFileUnavailable =>
      'Tidak ada pemilih berkas di perangkat ini.';

  @override
  String get formRequired => 'Wajib diisi';

  @override
  String get formInvalidUrl => 'Alamat tidak valid';

  @override
  String get formContentTitle => 'Konten yang diimpor';

  @override
  String get formContentHint =>
      'Siaran langsung selalu diimpor. Tanpa film dan serial, pemuatan jauh lebih ringan.';

  @override
  String get formMovies => 'Film';

  @override
  String get formSeries => 'Serial';

  @override
  String get formContentRemoved =>
      'Item yang sudah diimpor dan favoritnya akan dihapus dari perangkat ini.';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeDark => 'Gelap';

  @override
  String get themeLight => 'Terang';

  @override
  String get settingsLanguage => 'Bahasa';

  @override
  String get languageSystem => 'Bahasa sistem';

  @override
  String get settingsApp => 'Aplikasi';

  @override
  String settingsVersion(String version) {
    return 'Versi $version';
  }

  @override
  String get settingsPrivacy =>
      'Tanpa akun, tanpa telemetri: sumber dan data Anda tetap di perangkat ini.';

  @override
  String get settingsShortcuts =>
      'Ctrl+F: cari · F5: segarkan semua · Ctrl+1–9: ganti tab';

  @override
  String get playerPlay => 'Putar';

  @override
  String get playerPause => 'Jeda';

  @override
  String get playerPrevious => 'Sebelumnya';

  @override
  String get playerNext => 'Berikutnya';

  @override
  String get playerRefresh => 'Muat ulang siaran';

  @override
  String get playerFullscreen => 'Layar penuh';

  @override
  String get playerExitFullscreen => 'Keluar dari layar penuh';

  @override
  String get playerMute => 'Bisukan';

  @override
  String get playerUnmute => 'Bunyikan';

  @override
  String get playerLive => 'LANGSUNG';

  @override
  String playerReconnecting(int attempt, int total) {
    return 'Menghubungkan ulang… ($attempt/$total)';
  }

  @override
  String get playerSignalLost => 'Sinyal hilang…';

  @override
  String get playerFailedTitle => 'Tidak dapat diputar';

  @override
  String get playerFailedBody =>
      'Siaran ini tidak merespons. Mungkin sedang offline, atau langganan Anda sedang dipakai di perangkat lain.';

  @override
  String get playerEndedTitle => 'Pemutaran selesai';

  @override
  String get playerBackToList => 'Kembali ke daftar';

  @override
  String get externalTitle => 'Pemutar eksternal';

  @override
  String get externalOpen => 'Buka di pemutar eksternal';

  @override
  String get externalNone =>
      'Pemutar tidak ditemukan. VLC dipakai otomatis jika terpasang.';

  @override
  String get externalFailed =>
      'Pemutar eksternal gagal dijalankan. Periksa lokasinya di pengaturan.';

  @override
  String get externalDefault => 'Gunakan VLC';

  @override
  String get seriesFailed => 'Gagal memuat episode.';

  @override
  String get seriesEmpty => 'Tidak ada episode.';

  @override
  String seriesSeason(int number) {
    return 'Musim $number';
  }

  @override
  String seriesEpisode(int number) {
    return 'Episode $number';
  }

  @override
  String seriesMinutes(int count) {
    return '$count mnt';
  }

  @override
  String get navGuide => 'Panduan';

  @override
  String get guideTitle => 'Panduan TV';

  @override
  String get guideScope => 'Saluran yang ditampilkan';

  @override
  String get guideAllChannels => 'Semua saluran';

  @override
  String get guideNow => 'Sekarang';

  @override
  String get guideToday => 'Hari ini';

  @override
  String get guideYesterday => 'Kemarin';

  @override
  String get guideTomorrow => 'Besok';

  @override
  String get guideEarlier => '2 jam lebih awal';

  @override
  String get guideLater => '2 jam kemudian';

  @override
  String get guideEmptyTitle => 'Belum ada panduan TV';

  @override
  String get guideEmptyBody =>
      'Impor panduan dari sumber Anda, atau tambahkan alamat atau berkas XMLTV di pengaturan.';

  @override
  String get guideImport => 'Impor panduan';

  @override
  String guideImporting(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Mengimpor panduan… $countString acara';
  }

  @override
  String guideDone(int programs, int channels) {
    final intl.NumberFormat programsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String programsString = programsNumberFormat.format(programs);
    final intl.NumberFormat channelsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String channelsString = channelsNumberFormat.format(channels);

    return 'Panduan diperbarui: $programsString acara, $channelsString saluran dicocokkan.';
  }

  @override
  String guideFailed(String names) {
    return 'Panduan tidak tersedia: $names. Panduan sebelumnya tetap disimpan.';
  }

  @override
  String guideSourceLine(int count, String date) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString acara · $date';
  }

  @override
  String get guideNeverRefreshed => 'Belum pernah diperbarui';

  @override
  String get guideLastFailed => 'Pembaruan terakhir gagal.';

  @override
  String get guideRefresh => 'Perbarui panduan';

  @override
  String get guideAddUrl => 'Tambahkan alamat';

  @override
  String get guideAddFile => 'Tambahkan berkas';

  @override
  String get guideUrlHint => 'Alamat panduan XMLTV';

  @override
  String get guideWatchLive => 'Tonton langsung';

  @override
  String get guideReplay => 'Tonton ulang';

  @override
  String get guideReplayOff => 'Tayangan ulang tidak tersedia untuk acara ini.';

  @override
  String get guideComing => 'Akan datang';

  @override
  String get guideChannel => 'Jadwal saluran';

  @override
  String get guideLink => 'Cocokkan ke panduan';

  @override
  String get guideLinkHint => 'Nama atau ID saluran';

  @override
  String get guideNoProgram => 'Tidak ada acara untuk saluran ini.';

  @override
  String get guideNoChannels =>
      'Tidak ada saluran dalam pilihan ini yang memiliki panduan.';

  @override
  String get backupTitle => 'Cadangan';

  @override
  String get backupExport => 'Buat cadangan';

  @override
  String get backupImport => 'Pulihkan cadangan';

  @override
  String get backupRestore => 'Pulihkan';

  @override
  String get backupSecrets => 'Sertakan kata sandi';

  @override
  String get backupSecretsBody =>
      'Berkas lalu dienkripsi dengan frasa sandi Anda. Jika tidak, kata sandi dan alamat lengkap daftar putar tidak disimpan.';

  @override
  String get backupPassphrase => 'Frasa sandi';

  @override
  String get backupPassphraseAgain => 'Konfirmasi frasa sandi';

  @override
  String get backupPassphraseShort => 'Minimal 8 karakter.';

  @override
  String get backupPassphraseMismatch => 'Kedua frasa sandi berbeda.';

  @override
  String get backupSaved => 'Cadangan disimpan.';

  @override
  String get backupFailed => 'Tidak dapat menulis berkas ini.';

  @override
  String get backupNotOurs => 'Berkas ini bukan cadangan Chud IPTV.';

  @override
  String get backupTooNew =>
      'Cadangan ini berasal dari versi aplikasi yang lebih baru.';

  @override
  String get backupDamaged => 'Cadangan ini rusak.';

  @override
  String get backupWrongPassphrase =>
      'Frasa sandi salah, atau berkas telah diubah.';

  @override
  String get backupConfirmTitle => 'Pulihkan cadangan ini?';

  @override
  String backupConfirmBody(String date, int sources, int lists, int favorites) {
    return 'Cadangan $date. Sumber: $sources, daftar: $lists, favorit: $favorites. Data Anda saat ini tetap disimpan dan dilengkapi; hanya pengaturan yang diganti.';
  }

  @override
  String get backupRestored => 'Pemulihan selesai.';

  @override
  String backupIncomplete(int count) {
    return 'Pemulihan selesai. Sumber yang perlu dilengkapi: $count. Kata sandi atau alamatnya tidak ada di berkas.';
  }

  @override
  String get autoTitle => 'Pembaruan otomatis';

  @override
  String get autoOff => 'Mati';

  @override
  String autoEvery(int hours) {
    return 'Setiap $hours jam';
  }

  @override
  String get dataTitle => 'Data lokal';

  @override
  String cacheLine(String size) {
    return 'Cache logo: $size MB';
  }

  @override
  String get cacheClear => 'Kosongkan cache';

  @override
  String get cacheCleared => 'Cache dikosongkan.';

  @override
  String get wipeButton => 'Hapus semua data';

  @override
  String get wipeTitle => 'Hapus semuanya?';

  @override
  String get wipeBody =>
      'Sumber, favorit, panduan, unduhan, dan pengaturan akan dihapus dari perangkat ini. Tindakan ini tidak dapat dibatalkan.';

  @override
  String get wipeConfirm => 'Hapus semua';

  @override
  String get updateTitle => 'Pembaruan';

  @override
  String get updateAuto => 'Periksa otomatis';

  @override
  String get updateCheck => 'Periksa pembaruan';

  @override
  String get updateChecking => 'Memeriksa…';

  @override
  String get updateLatest => 'Anda memakai versi terbaru.';

  @override
  String updateAvailable(String version) {
    return 'Versi $version tersedia';
  }

  @override
  String get updateSee => 'Lihat';

  @override
  String get updateInstall => 'Perbarui';

  @override
  String updateDownloading(int percent) {
    return 'Mengunduh… $percent%';
  }

  @override
  String get updateVerifying => 'Memverifikasi berkas…';

  @override
  String get updateRestarting => 'Memasang: aplikasi akan dimulai ulang.';

  @override
  String get updateConfirmSystem =>
      'Konfirmasikan pemasangan di jendela sistem.';

  @override
  String get updateOpened =>
      'Unduhan terbuka di peramban: pasang, lalu mulai ulang aplikasi.';

  @override
  String get updateCancelled => 'Pembaruan dibatalkan.';

  @override
  String get updateNoChannel =>
      'Versi ini tidak terhubung ke saluran pembaruan.';

  @override
  String get updateFailedNetwork => 'Server pembaruan tidak dapat dijangkau.';

  @override
  String get updateFailedSignature =>
      'Tanda tangan tidak valid: pembaruan ditolak.';

  @override
  String get updateFailedIntegrity => 'Berkas rusak: tidak ada yang dipasang.';

  @override
  String get updateFailedInstall => 'Pemasangan gagal.';

  @override
  String updateDone(String version) {
    return 'Pembaruan ke versi $version terpasang.';
  }

  @override
  String updateNotApplied(String version) {
    return 'Pembaruan ke versi $version tidak dapat dipasang: versi sebelumnya tetap digunakan.';
  }

  @override
  String get navDownloads => 'Unduhan';

  @override
  String get downloadAction => 'Unduh';

  @override
  String get downloadSeason => 'Unduh musim ini';

  @override
  String downloadAdded(String title) {
    return 'Ditambahkan ke unduhan: $title';
  }

  @override
  String get downloadPlay => 'Putar berkas';

  @override
  String get downloadEmptyTitle => 'Belum ada unduhan';

  @override
  String get downloadEmptyBody =>
      'Unduh film dari halamannya, atau episode dari serialnya, untuk menontonnya tanpa koneksi.';

  @override
  String get downloadQueued => 'Menunggu';

  @override
  String get downloadPaused => 'Dijeda';

  @override
  String get downloadHeld => 'Menunggu pemutaran selesai';

  @override
  String get downloadPause => 'Jeda';

  @override
  String get downloadResume => 'Lanjutkan';

  @override
  String get downloadDeleteTitle => 'Hapus unduhan ini?';

  @override
  String downloadDeleteBody(String title) {
    return '$title akan dihapus dari perangkat ini.';
  }

  @override
  String get downloadFolder => 'Folder unduhan';

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
      'Koneksi terputus. Berkas tetap disimpan: unduhan berlanjut dari titik terakhir.';

  @override
  String get downloadErrorServer =>
      'Server menolak. Mungkin pemutaran lain sedang memakai koneksi Anda.';

  @override
  String get downloadErrorFormat =>
      'Konten ini disiarkan per segmen dan tidak dapat diunduh.';

  @override
  String get downloadErrorDisk =>
      'Tidak dapat menulis: ruang kurang atau folder tidak dapat diakses.';

  @override
  String get downloadErrorSource => 'Sumber unduhan ini sudah tidak ada.';

  @override
  String get downloadErrorMissing => 'Berkas telah dipindahkan atau dihapus.';

  @override
  String get downloadFolderChoose => 'Pilih folder';

  @override
  String get downloadFolderReset => 'Folder bawaan';

  @override
  String get downloadFolderApp => 'Folder aplikasi, terhapus bersama aplikasi';

  @override
  String get downloadFolderHint =>
      'Berlaku untuk unduhan berikutnya. Yang sudah selesai tetap di tempatnya.';

  @override
  String get favChooseBody =>
      'Anda belum punya daftar. Di mana favorit ini ingin disimpan?';

  @override
  String get favGlobal => 'Favorit umum';

  @override
  String get settingsPhoneTitle => 'Pemutaran di ponsel';

  @override
  String get settingsPip => 'Gambar dalam gambar';

  @override
  String get settingsPipBody =>
      'Video tetap diputar di jendela kecil saat Anda keluar dari aplikasi. Tombol akan muncul di pemutar.';

  @override
  String get settingsRadio => 'Mode radio';

  @override
  String get settingsRadioBody =>
      'Suara tetap diputar saat ponsel terkunci atau aplikasi di latar belakang. Tombol akan muncul di pemutar.';

  @override
  String get playerPipOn => 'Gambar dalam gambar aktif';

  @override
  String get playerPipOff => 'Gambar dalam gambar nonaktif';

  @override
  String get playerRadioOn => 'Mode radio aktif';

  @override
  String get playerRadioOff => 'Mode radio nonaktif';

  @override
  String get radioNotificationStop => 'Hentikan';
}
