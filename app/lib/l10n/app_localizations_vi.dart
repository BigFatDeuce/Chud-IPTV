// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get navLive => 'Trực tiếp';

  @override
  String get navFavorites => 'Yêu thích';

  @override
  String get navMovies => 'Phim';

  @override
  String get navSeries => 'Phim bộ';

  @override
  String get navSources => 'Nguồn';

  @override
  String get navSettings => 'Cài đặt';

  @override
  String get navMore => 'Thêm';

  @override
  String get commonCancel => 'Hủy';

  @override
  String get commonSave => 'Lưu';

  @override
  String get commonDelete => 'Xóa';

  @override
  String get commonClose => 'Đóng';

  @override
  String get commonRetry => 'Thử lại';

  @override
  String get welcomeTitle => 'Chào mừng';

  @override
  String get welcomeBody =>
      'Thêm một nguồn để bắt đầu: tài khoản Xtream Codes hoặc danh sách phát M3U. Ứng dụng không cung cấp kênh và mọi dữ liệu đều nằm trên thiết bị này.';

  @override
  String get addSource => 'Thêm nguồn';

  @override
  String get allSources => 'Tất cả nguồn';

  @override
  String get allCategories => 'Tất cả';

  @override
  String get noCategoryName => 'Chưa phân loại';

  @override
  String get filterCategories => 'Lọc danh mục';

  @override
  String get emptyList => 'Không có gì để hiển thị.';

  @override
  String get emptyWhileImporting =>
      'Đang nhập, danh mục sẽ hiện ngay khi sẵn sàng.';

  @override
  String itemCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString mục',
      zero: 'Không có mục nào',
    );
    return '$_temp0';
  }

  @override
  String get viewCompact => 'Danh sách gọn';

  @override
  String get viewDetailed => 'Danh sách chi tiết';

  @override
  String get viewGrid => 'Lưới';

  @override
  String get searchHint => 'Tìm kiếm';

  @override
  String noResults(String query) {
    return 'Không có kết quả cho “$query”.';
  }

  @override
  String get sortLabel => 'Sắp xếp';

  @override
  String get sortSource => 'Thứ tự của nguồn';

  @override
  String get sortNameAsc => 'Tên (A → Z)';

  @override
  String get sortNameDesc => 'Tên (Z → A)';

  @override
  String get sortRecent => 'Mới thêm';

  @override
  String get sortRating => 'Đánh giá cao nhất';

  @override
  String get filterLabel => 'Bộ lọc';

  @override
  String get filterCountry => 'Quốc gia hoặc ngôn ngữ';

  @override
  String get filterAllCountries => 'Tất cả quốc gia';

  @override
  String get itemSource => 'Nguồn';

  @override
  String get itemCategory => 'Danh mục';

  @override
  String get itemCountry => 'Quốc gia hoặc ngôn ngữ';

  @override
  String get itemFormat => 'Định dạng';

  @override
  String get itemRating => 'Đánh giá';

  @override
  String get favAdd => 'Thêm vào yêu thích';

  @override
  String get favRemove => 'Bỏ khỏi yêu thích';

  @override
  String get favPickLists => 'Danh sách yêu thích';

  @override
  String get favNewList => 'Danh sách mới';

  @override
  String get favDefaultName => 'Yêu thích';

  @override
  String get favListName => 'Tên danh sách';

  @override
  String get favListIcon => 'Biểu tượng';

  @override
  String get favRename => 'Sửa danh sách';

  @override
  String get favDeleteList => 'Xóa danh sách';

  @override
  String favDeleteConfirm(String name) {
    return 'Xóa danh sách “$name”? Các kênh vẫn còn trong danh mục.';
  }

  @override
  String get favEmptyLists =>
      'Tạo danh sách của bạn: thể thao, tin tức, trẻ em… Một kênh có thể nằm trong nhiều danh sách.';

  @override
  String get favEmptyList =>
      'Danh sách trống. Thêm kênh bằng biểu tượng ngôi sao.';

  @override
  String get favManage => 'Quản lý danh sách';

  @override
  String get favMoveUp => 'Chuyển lên';

  @override
  String get favMoveDown => 'Chuyển xuống';

  @override
  String favListLine(String name, int count) {
    return '$name ($count)';
  }

  @override
  String get filteredIntro =>
      'FILTERED tự động gom các nhóm từ nguồn của bạn theo quốc gia, khu vực và chủ đề. Tab Trực tiếp và danh sách phát không thay đổi.';

  @override
  String get filteredNoGroups =>
      'Chưa có nhóm để phân tích. Hãy làm mới một nguồn.';

  @override
  String get filteredAnalyze => 'Tự động sắp xếp';

  @override
  String get filteredManage => 'Phân loại';

  @override
  String get filteredReanalyze => 'Phân tích lại và chỉnh sửa';

  @override
  String get filteredRestore => 'Khôi phục phân loại tự động';

  @override
  String get filteredRestoreConfirm =>
      'Các chỉnh sửa thủ công sẽ bị xóa. Bạn sẽ xem trước khi xác nhận.';

  @override
  String get filteredPreviewTitle => 'Xem trước phân loại';

  @override
  String filteredSummary(int groups, int nodes) {
    final intl.NumberFormat groupsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String groupsString = groupsNumberFormat.format(groups);
    final intl.NumberFormat nodesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String nodesString = nodesNumberFormat.format(nodes);

    return '$groupsString nhóm trong $nodesString danh mục';
  }

  @override
  String filteredDelta(int added, int removed) {
    return 'Từ lần phân tích trước: $added mới, $removed đã mất';
  }

  @override
  String filteredNewGroups(int count) {
    return '$count nhóm mới cần sắp xếp: mở xem trước';
  }

  @override
  String filteredToCheck(int count) {
    return 'Cần kiểm tra ($count)';
  }

  @override
  String filteredUnclassified(int count) {
    return 'Chưa phân loại ($count)';
  }

  @override
  String filteredExcluded(int count) {
    return 'Nhóm đã loại trừ ($count)';
  }

  @override
  String filteredGroupsCount(int count) {
    return '$count nhóm';
  }

  @override
  String get filteredValidate => 'Xác nhận phân loại này';

  @override
  String get filteredAccept => 'Đúng rồi';

  @override
  String get filteredMove => 'Xếp vào…';

  @override
  String get filteredExclude => 'Loại khỏi phân loại';

  @override
  String get filteredRestoreGroup => 'Đưa trở lại';

  @override
  String get filteredNewCategory => 'Danh mục mới';

  @override
  String get filteredRename => 'Đổi tên';

  @override
  String get filteredMerge => 'Gộp vào…';

  @override
  String get sourcesTitle => 'Nguồn IPTV';

  @override
  String get refreshAll => 'Làm mới tất cả';

  @override
  String get refresh => 'Làm mới';

  @override
  String get editSource => 'Sửa';

  @override
  String get deleteSource => 'Xóa nguồn';

  @override
  String deleteSourceConfirm(String name) {
    return 'Xóa “$name” và toàn bộ danh mục khỏi thiết bị này?';
  }

  @override
  String get sourceEnabled => 'Đang bật';

  @override
  String get makeDefault => 'Đặt làm mặc định';

  @override
  String get isDefault => 'Nguồn mặc định';

  @override
  String get kindXtream => 'Xtream Codes';

  @override
  String get kindM3uUrl => 'Danh sách trực tuyến';

  @override
  String get kindM3uFile => 'Tệp M3U';

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

    return '$liveString kênh · $moviesString phim · $seriesString phim bộ';
  }

  @override
  String get neverRefreshed => 'Chưa làm mới';

  @override
  String refreshedAt(String date) {
    return 'Đã làm mới $date';
  }

  @override
  String expiresAt(String date) {
    return 'Gói có hiệu lực đến $date';
  }

  @override
  String maxConnections(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count luồng đồng thời',
    );
    return '$_temp0';
  }

  @override
  String get applyAnyway => 'Vẫn áp dụng';

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

    return '“$name”: thêm $addedString, đổi $updatedString, mất $missingString.';
  }

  @override
  String get stageConnecting => 'Đang kết nối máy chủ…';

  @override
  String get stageLive => 'Đang tải kênh…';

  @override
  String get stageMovies => 'Đang tải phim…';

  @override
  String get stageSeries => 'Đang tải phim bộ…';

  @override
  String get stagePlaylist => 'Đang tải danh sách phát…';

  @override
  String get stageWriting => 'Đang lưu danh mục…';

  @override
  String stageWritingCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Đang lưu: $countString mục…';
  }

  @override
  String get stageQueued => 'Đang chờ…';

  @override
  String get errorNetwork =>
      'Không kết nối được máy chủ. Hãy kiểm tra địa chỉ và mạng.';

  @override
  String get errorTimeout => 'Máy chủ phản hồi quá lâu.';

  @override
  String get errorCredentials => 'Máy chủ từ chối tên đăng nhập hoặc mật khẩu.';

  @override
  String get errorExpired => 'Gói đăng ký này đã hết hạn.';

  @override
  String get errorNotFound => 'Không tìm thấy địa chỉ trên máy chủ này.';

  @override
  String get errorNotPlaylist => 'Nội dung này không phải danh sách M3U.';

  @override
  String get errorInvalidData => 'Máy chủ trả về dữ liệu không đọc được.';

  @override
  String get errorEmpty => 'Nguồn trống: danh mục hiện tại được giữ nguyên.';

  @override
  String errorSuspicious(String detail) {
    return 'Danh sách nhỏ bất thường ($detail): danh mục hiện tại được giữ nguyên.';
  }

  @override
  String get errorFileMissing => 'Không tìm thấy hoặc không đọc được tệp.';

  @override
  String get errorUnknown =>
      'Làm mới thất bại. Danh mục hiện tại được giữ nguyên.';

  @override
  String get formNewTitle => 'Nguồn mới';

  @override
  String get formEditTitle => 'Sửa nguồn';

  @override
  String get formName => 'Tên';

  @override
  String get formNameHint => 'VD: Phòng khách, Gói 1';

  @override
  String get formServer => 'Địa chỉ máy chủ';

  @override
  String get formUsername => 'Tên đăng nhập';

  @override
  String get formPassword => 'Mật khẩu';

  @override
  String get formShowPassword => 'Hiện mật khẩu';

  @override
  String get formPlaylistUrl => 'Địa chỉ danh sách (M3U hoặc M3U8)';

  @override
  String get formFile => 'Tệp danh sách phát';

  @override
  String get formChooseFile => 'Chọn tệp';

  @override
  String get formNoFile => 'Chưa chọn tệp';

  @override
  String get formFileUnavailable => 'Thiết bị này không có trình chọn tệp.';

  @override
  String get formRequired => 'Bắt buộc';

  @override
  String get formInvalidUrl => 'Địa chỉ không hợp lệ';

  @override
  String get formContentTitle => 'Nội dung cần nhập';

  @override
  String get formContentHint =>
      'Kênh trực tiếp luôn được nhập. Không có phim và phim bộ sẽ tải nhẹ hơn nhiều.';

  @override
  String get formMovies => 'Phim';

  @override
  String get formSeries => 'Phim bộ';

  @override
  String get formContentRemoved =>
      'Các mục đã nhập và mục yêu thích của chúng sẽ bị xóa khỏi thiết bị.';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get settingsTheme => 'Giao diện';

  @override
  String get themeSystem => 'Hệ thống';

  @override
  String get themeDark => 'Tối';

  @override
  String get themeLight => 'Sáng';

  @override
  String get settingsLanguage => 'Ngôn ngữ';

  @override
  String get languageSystem => 'Ngôn ngữ hệ thống';

  @override
  String get settingsApp => 'Ứng dụng';

  @override
  String settingsVersion(String version) {
    return 'Phiên bản $version';
  }

  @override
  String get settingsPrivacy =>
      'Không cần tài khoản, không theo dõi: nguồn và dữ liệu nằm trên thiết bị này.';

  @override
  String get settingsShortcuts =>
      'Ctrl+F: tìm kiếm · F5: làm mới tất cả · Ctrl+1–9: đổi tab';

  @override
  String get playerPlay => 'Phát';

  @override
  String get playerPause => 'Tạm dừng';

  @override
  String get playerPrevious => 'Trước';

  @override
  String get playerNext => 'Tiếp';

  @override
  String get playerRefresh => 'Tải lại luồng';

  @override
  String get playerFullscreen => 'Toàn màn hình';

  @override
  String get playerExitFullscreen => 'Thoát toàn màn hình';

  @override
  String get playerMute => 'Tắt tiếng';

  @override
  String get playerUnmute => 'Bật tiếng';

  @override
  String get playerLive => 'TRỰC TIẾP';

  @override
  String playerReconnecting(int attempt, int total) {
    return 'Đang kết nối lại… ($attempt/$total)';
  }

  @override
  String get playerSignalLost => 'Mất tín hiệu…';

  @override
  String get playerFailedTitle => 'Không thể phát';

  @override
  String get playerFailedBody =>
      'Luồng này không phản hồi. Có thể đang ngoại tuyến hoặc gói của bạn đang phát trên thiết bị khác.';

  @override
  String get playerEndedTitle => 'Đã phát xong';

  @override
  String get playerBackToList => 'Quay lại danh sách';

  @override
  String get externalTitle => 'Trình phát ngoài';

  @override
  String get externalOpen => 'Mở bằng trình phát ngoài';

  @override
  String get externalNone =>
      'Không tìm thấy trình phát. VLC sẽ tự được dùng nếu đã cài.';

  @override
  String get externalFailed =>
      'Không mở được trình phát ngoài. Hãy kiểm tra vị trí trong cài đặt.';

  @override
  String get externalDefault => 'Dùng VLC';

  @override
  String get seriesFailed => 'Không tải được các tập.';

  @override
  String get seriesEmpty => 'Không có tập nào.';

  @override
  String seriesSeason(int number) {
    return 'Mùa $number';
  }

  @override
  String seriesEpisode(int number) {
    return 'Tập $number';
  }

  @override
  String seriesMinutes(int count) {
    return '$count phút';
  }

  @override
  String get navGuide => 'Lịch phát sóng';

  @override
  String get guideTitle => 'Lịch phát sóng';

  @override
  String get guideScope => 'Kênh hiển thị';

  @override
  String get guideAllChannels => 'Tất cả kênh';

  @override
  String get guideNow => 'Bây giờ';

  @override
  String get guideToday => 'Hôm nay';

  @override
  String get guideYesterday => 'Hôm qua';

  @override
  String get guideTomorrow => 'Ngày mai';

  @override
  String get guideEarlier => 'Sớm hơn 2 giờ';

  @override
  String get guideLater => 'Muộn hơn 2 giờ';

  @override
  String get guideEmptyTitle => 'Chưa có lịch phát sóng';

  @override
  String get guideEmptyBody =>
      'Nhập lịch phát sóng từ các nguồn của bạn, hoặc thêm địa chỉ hay tệp XMLTV trong phần cài đặt.';

  @override
  String get guideImport => 'Nhập lịch phát sóng';

  @override
  String guideImporting(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Đang nhập lịch… $countString chương trình';
  }

  @override
  String guideDone(int programs, int channels) {
    final intl.NumberFormat programsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String programsString = programsNumberFormat.format(programs);
    final intl.NumberFormat channelsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String channelsString = channelsNumberFormat.format(channels);

    return 'Đã cập nhật lịch: $programsString chương trình, $channelsString kênh được ghép.';
  }

  @override
  String guideFailed(String names) {
    return 'Không lấy được lịch: $names. Lịch cũ vẫn được giữ.';
  }

  @override
  String guideSourceLine(int count, String date) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString chương trình · $date';
  }

  @override
  String get guideNeverRefreshed => 'Chưa cập nhật lần nào';

  @override
  String get guideLastFailed => 'Lần cập nhật gần nhất không thành công.';

  @override
  String get guideRefresh => 'Cập nhật lịch';

  @override
  String get guideAddUrl => 'Thêm địa chỉ';

  @override
  String get guideAddFile => 'Thêm tệp';

  @override
  String get guideUrlHint => 'Địa chỉ lịch XMLTV';

  @override
  String get guideWatchLive => 'Xem trực tiếp';

  @override
  String get guideReplay => 'Xem lại';

  @override
  String get guideReplayOff => 'Không xem lại được chương trình này.';

  @override
  String get guideComing => 'Sắp phát';

  @override
  String get guideChannel => 'Lịch của kênh';

  @override
  String get guideLink => 'Ghép với lịch';

  @override
  String get guideLinkHint => 'Tên hoặc mã kênh';

  @override
  String get guideNoProgram => 'Kênh này chưa có chương trình.';

  @override
  String get guideNoChannels => 'Không kênh nào trong lựa chọn này có lịch.';

  @override
  String get backupTitle => 'Sao lưu';

  @override
  String get backupExport => 'Tạo bản sao lưu';

  @override
  String get backupImport => 'Khôi phục bản sao lưu';

  @override
  String get backupRestore => 'Khôi phục';

  @override
  String get backupSecrets => 'Bao gồm mật khẩu';

  @override
  String get backupSecretsBody =>
      'Khi đó tệp được mã hóa bằng cụm mật khẩu của bạn. Nếu không, mật khẩu và địa chỉ đầy đủ của danh sách phát sẽ không được lưu.';

  @override
  String get backupPassphrase => 'Cụm mật khẩu';

  @override
  String get backupPassphraseAgain => 'Xác nhận cụm mật khẩu';

  @override
  String get backupPassphraseShort => 'Ít nhất 8 ký tự.';

  @override
  String get backupPassphraseMismatch => 'Hai cụm mật khẩu không khớp.';

  @override
  String get backupSaved => 'Đã lưu bản sao lưu.';

  @override
  String get backupFailed => 'Không thể ghi tệp này.';

  @override
  String get backupNotOurs => 'Tệp này không phải bản sao lưu Chud IPTV.';

  @override
  String get backupTooNew =>
      'Bản sao lưu này đến từ phiên bản ứng dụng mới hơn.';

  @override
  String get backupDamaged => 'Bản sao lưu này bị hỏng.';

  @override
  String get backupWrongPassphrase => 'Sai cụm mật khẩu, hoặc tệp đã bị sửa.';

  @override
  String get backupConfirmTitle => 'Khôi phục bản sao lưu này?';

  @override
  String backupConfirmBody(String date, int sources, int lists, int favorites) {
    return 'Bản sao lưu ngày $date. Nguồn: $sources, danh sách: $lists, yêu thích: $favorites. Dữ liệu hiện tại được giữ và bổ sung; chỉ phần cài đặt bị thay thế.';
  }

  @override
  String get backupRestored => 'Đã khôi phục xong.';

  @override
  String backupIncomplete(int count) {
    return 'Đã khôi phục xong. Nguồn cần bổ sung: $count. Mật khẩu hoặc địa chỉ không có trong tệp.';
  }

  @override
  String get autoTitle => 'Tự động cập nhật';

  @override
  String get autoOff => 'Tắt';

  @override
  String autoEvery(int hours) {
    return 'Mỗi $hours giờ';
  }

  @override
  String get dataTitle => 'Dữ liệu cục bộ';

  @override
  String cacheLine(String size) {
    return 'Bộ nhớ đệm logo: $size MB';
  }

  @override
  String get cacheClear => 'Xóa bộ nhớ đệm';

  @override
  String get cacheCleared => 'Đã xóa bộ nhớ đệm.';

  @override
  String get wipeButton => 'Xóa toàn bộ dữ liệu';

  @override
  String get wipeTitle => 'Xóa tất cả?';

  @override
  String get wipeBody =>
      'Nguồn, mục yêu thích, lịch phát sóng, tệp tải xuống và cài đặt sẽ bị xóa khỏi thiết bị này. Không thể hoàn tác.';

  @override
  String get wipeConfirm => 'Xóa tất cả';

  @override
  String get updateTitle => 'Cập nhật';

  @override
  String get updateAuto => 'Tự động kiểm tra';

  @override
  String get updateCheck => 'Kiểm tra cập nhật';

  @override
  String get updateChecking => 'Đang kiểm tra…';

  @override
  String get updateLatest => 'Bạn đang dùng phiên bản mới nhất.';

  @override
  String updateAvailable(String version) {
    return 'Đã có phiên bản $version';
  }

  @override
  String get updateSee => 'Xem';

  @override
  String get updateInstall => 'Cập nhật';

  @override
  String updateDownloading(int percent) {
    return 'Đang tải… $percent%';
  }

  @override
  String get updateVerifying => 'Đang xác minh tệp…';

  @override
  String get updateRestarting => 'Đang cài đặt: ứng dụng sẽ khởi động lại.';

  @override
  String get updateConfirmSystem => 'Xác nhận cài đặt trong cửa sổ hệ thống.';

  @override
  String get updateOpened =>
      'Tệp tải đã mở trong trình duyệt: hãy cài đặt rồi khởi động lại ứng dụng.';

  @override
  String get updateCancelled => 'Đã hủy cập nhật.';

  @override
  String get updateNoChannel => 'Bản này chưa liên kết với kênh cập nhật nào.';

  @override
  String get updateFailedNetwork => 'Không kết nối được máy chủ cập nhật.';

  @override
  String get updateFailedSignature =>
      'Chữ ký không hợp lệ: đã từ chối cập nhật.';

  @override
  String get updateFailedIntegrity => 'Tệp bị hỏng: chưa cài đặt gì.';

  @override
  String get updateFailedInstall => 'Cài đặt không thành công.';

  @override
  String updateDone(String version) {
    return 'Đã cài bản cập nhật $version.';
  }

  @override
  String updateNotApplied(String version) {
    return 'Không cài được bản cập nhật $version: phiên bản cũ vẫn được giữ.';
  }

  @override
  String get navDownloads => 'Tải xuống';

  @override
  String get downloadAction => 'Tải xuống';

  @override
  String get downloadSeason => 'Tải cả mùa';

  @override
  String downloadAdded(String title) {
    return 'Đã thêm vào tải xuống: $title';
  }

  @override
  String get downloadPlay => 'Phát tệp';

  @override
  String get downloadEmptyTitle => 'Chưa có tệp tải xuống';

  @override
  String get downloadEmptyBody =>
      'Tải phim từ trang của phim, hoặc tải tập từ phim bộ, để xem khi không có mạng.';

  @override
  String get downloadQueued => 'Đang chờ';

  @override
  String get downloadPaused => 'Đã tạm dừng';

  @override
  String get downloadHeld => 'Đang chờ phát xong';

  @override
  String get downloadPause => 'Tạm dừng';

  @override
  String get downloadResume => 'Tiếp tục';

  @override
  String get downloadDeleteTitle => 'Xóa tệp tải xuống này?';

  @override
  String downloadDeleteBody(String title) {
    return '$title sẽ bị xóa khỏi thiết bị này.';
  }

  @override
  String get downloadFolder => 'Thư mục tải xuống';

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
      'Mất kết nối. Tệp vẫn được giữ: sẽ tải tiếp từ chỗ đã dừng.';

  @override
  String get downloadErrorServer =>
      'Máy chủ từ chối. Có thể một luồng phát khác đang dùng kết nối của bạn.';

  @override
  String get downloadErrorFormat =>
      'Nội dung này phát theo từng đoạn nên không tải xuống được.';

  @override
  String get downloadErrorDisk =>
      'Không ghi được: thiếu dung lượng hoặc không truy cập được thư mục.';

  @override
  String get downloadErrorSource =>
      'Nguồn của tệp tải xuống này không còn nữa.';

  @override
  String get downloadErrorMissing => 'Tệp đã bị di chuyển hoặc xóa.';

  @override
  String get downloadFolderChoose => 'Chọn thư mục';

  @override
  String get downloadFolderReset => 'Thư mục mặc định';

  @override
  String get downloadFolderApp => 'Thư mục của ứng dụng, bị xóa cùng ứng dụng';

  @override
  String get downloadFolderHint =>
      'Áp dụng cho các lần tải sau. Tệp đã tải xong vẫn ở nguyên chỗ cũ.';

  @override
  String get favChooseBody =>
      'Bạn chưa có danh sách nào. Bạn muốn lưu mục yêu thích này ở đâu?';

  @override
  String get favGlobal => 'Mục yêu thích chung';

  @override
  String get settingsPhoneTitle => 'Phát trên điện thoại';

  @override
  String get settingsPip => 'Hình trong hình';

  @override
  String get settingsPipBody =>
      'Video tiếp tục phát trong cửa sổ nhỏ khi bạn rời ứng dụng. Một nút sẽ xuất hiện trong trình phát.';

  @override
  String get settingsRadio => 'Chế độ radio';

  @override
  String get settingsRadioBody =>
      'Âm thanh vẫn phát khi điện thoại khóa hoặc ứng dụng chạy nền. Một nút sẽ xuất hiện trong trình phát.';

  @override
  String get playerPipOn => 'Đã bật hình trong hình';

  @override
  String get playerPipOff => 'Đã tắt hình trong hình';

  @override
  String get playerRadioOn => 'Đã bật chế độ radio';

  @override
  String get playerRadioOff => 'Đã tắt chế độ radio';

  @override
  String get radioNotificationStop => 'Dừng';
}
