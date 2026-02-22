import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLanguage { en, vi }

final languageProvider = StateProvider<AppLanguage>((ref) => AppLanguage.vi);

// Tile values provider - stores selected denominations for tiles (multi-select)
// EN values: 1, 2, 5, 10, 20, 50, 100 (dollars)
// VN values: 10000, 20000, 50000, 100000, 200000, 500000 (VND)
final tileValuesProvider = StateProvider<Set<int>>((ref) {
  final lang = ref.watch(languageProvider);
  // Default: select middle values
  return lang == AppLanguage.en ? {5, 10, 20} : {50000, 100000, 200000};
});

class AppLocalizations {
  final AppLanguage _lang;

  AppLocalizations(this._lang);

  static AppLocalizations of(WidgetRef ref) {
    return AppLocalizations(ref.watch(languageProvider));
  }

  String get appTitle => _t('appTitle');
  String get dreamVacation => _t('dreamVacation');
  String get noGoalsYet => _t('noGoalsYet');
  String get totalSaved => _t('totalSaved');
  String get createNewGoal => _t('createNewGoal');
  String get goalName => _t('goalName');
  String get goalNameHint => _t('goalNameHint');
  String get numberOfTiles => _t('numberOfTiles');
  String get bankId => _t('bankId');
  String get bankIdHint => _t('bankIdHint');
  String get accountNumber => _t('accountNumber');
  String get accountNumberHint => _t('accountNumberHint');
  String get accountHolder => _t('accountHolder');
  String get accountHolderHint => _t('accountHolderHint');
  String get cancel => _t('cancel');
  String get create => _t('create');
  String get settings => _t('settings');
  String get statistics => _t('statistics');
  String get grid => _t('grid');
  String get stats => _t('stats');
  String get language => _t('language');
  String get notifications => _t('notifications');
  String get dailyReminder => _t('dailyReminder');
  String get reminderTime => _t('reminderTime');
  String get data => _t('data');
  String get exportData => _t('exportData');
  String get importData => _t('importData');
  String get resetAllData => _t('resetAllData');
  String get about => _t('about');
  String get version => _t('version');
  String get madeWithFlutter => _t('madeWithFlutter');
  String get copyright => _t('copyright');
  String get alreadySaved => _t('alreadySaved');
  String get confirmSaving => _t('confirmSaving');
  String get youSaved => _t('youSaved');
  String get undoMarkUnpaid => _t('undoMarkUnpaid');
  String get openBankApp => _t('openBankApp');
  String get iHaveTransferred => _t('iHaveTransferred');
  String achieved(int percent) =>
      _t('achieved').replaceAll('{percent}', '$percent');
  String get savingStreak => _t('savingStreak');
  String get dayStreak => _t('dayStreak');
  String get thisMonth => _t('thisMonth');
  String get goalsDone => _t('goalsDone');
  String get goalsOverview => _t('goalsOverview');
  String get completed => _t('completed');
  String percentComplete(int percent) =>
      _t('percentComplete').replaceAll('{percent}', '$percent');
  String get resetConfirmTitle => _t('resetConfirmTitle');
  String get resetConfirmMessage => _t('resetConfirmMessage');
  String get reset => _t('reset');
  String get bankInfoRequired => _t('bankInfoRequired');
  String get bankName => _t('bankName');
  String get selectBank => _t('selectBank');
  String get bankInfoForVietQR => _t('bankInfoForVietQR');
  String get errorLoadingData => _t('errorLoadingData');
  String get errorLoadingGoals => _t('errorLoadingGoals');
  String get goal => _t('goal');
  String get bankInfoNotConfigured => _t('bankInfoNotConfigured');
  String get addBankInfoMessage => _t('addBankInfoMessage');
  String get markAsPaidManually => _t('markAsPaidManually');
  String get noGoalsMessage => _t('noGoalsMessage');
  String get deleteGoal => _t('deleteGoal');
  String get deleteGoalConfirm => _t('deleteGoalConfirm');
  String get delete => _t('delete');
  String get targetAmount => _t('targetAmount');
  String get notificationTitle => _t('notificationTitle');
  String get notificationBody => _t('notificationBody');
  String get targetAmountHint => _t('targetAmountHint');
  String get bankInfo => _t('bankInfo');
  String get tileValues => _t('tileValues');
  String get selectTileValue => _t('selectTileValue');
  String get currency => _t('currency');

  AppLanguage get currentLanguage => _lang;

  bool get isVietnamese => _lang == AppLanguage.vi;

  String formatCurrency(int amount) {
    if (_lang == AppLanguage.vi) {
      if (amount >= 1000) {
        return '${(amount / 1000).toStringAsFixed(0)}k';
      }
      return '${amount}đ';
    }
    return '\$$amount';
  }

  String formatCurrencyFull(double amount) {
    if (_lang == AppLanguage.vi) {
      if (amount >= 1000) {
        return '${(amount / 1000).toStringAsFixed(0)}k';
      }
      return '${amount.toStringAsFixed(0)}đ';
    }
    return '\$${amount.toStringAsFixed(0)}';
  }

  String _t(String key) {
    return _localizedStrings[_lang]?[key] ??
        _localizedStrings[AppLanguage.en]![key] ??
        key;
  }

  static const Map<AppLanguage, Map<String, String>> _localizedStrings = {
    AppLanguage.en: {
      'appTitle': 'Digital Saving Box',
      'dreamVacation': 'Dream Vacation',
      'noGoalsYet': 'No Goals Yet',
      'totalSaved': 'Total Saved',
      'createNewGoal': 'Create New Goal',
      'goalName': 'Goal Name',
      'goalNameHint': 'e.g., New iPhone',
      'numberOfTiles': 'Number of Tiles',
      'bankId': 'Bank ID (BIN)',
      'bankIdHint': 'e.g., 970422 (MB Bank)',
      'accountNumber': 'Account Number',
      'accountNumberHint': 'Your bank account number',
      'accountHolder': 'Account Holder Name',
      'accountHolderHint': 'Name on your bank account',
      'cancel': 'Cancel',
      'create': 'Create',
      'settings': 'Settings',
      'statistics': 'Statistics',
      'grid': 'Grid',
      'stats': 'Stats',
      'language': 'Language',
      'notifications': 'Notifications',
      'dailyReminder': 'Daily Reminder',
      'reminderTime': 'Reminder Time',
      'data': 'Data',
      'exportData': 'Export Data',
      'importData': 'Import Data',
      'resetAllData': 'Reset All Data',
      'about': 'About',
      'version': 'Version',
      'madeWithFlutter': 'Made with Flutter',
      'copyright': '© 2025 Digital Saving Box\nAll rights reserved',
      'alreadySaved': 'Already Saved!',
      'confirmSaving': 'Confirm Saving',
      'youSaved': 'You saved',
      'undoMarkUnpaid': 'Undo / Mark Unpaid',
      'openBankApp': 'Open Bank App',
      'iHaveTransferred': 'I have transferred',
      'achieved': '{percent}% achieved',
      'savingStreak': 'Saving Streak',
      'dayStreak': 'Day Streak',
      'thisMonth': 'This Month',
      'goalsDone': 'Goals Done',
      'goalsOverview': 'Goals Overview',
      'completed': 'Completed!',
      'percentComplete': '{percent}% complete',
      'resetConfirmTitle': 'Reset All Data?',
      'resetConfirmMessage':
          'This will delete all your savings data and cannot be undone.',
      'reset': 'Reset',
      'bankInfoRequired': 'Bank info required for QR code',
      'bankName': 'Bank Name',
      'selectBank': 'Select Bank',
      'bankInfoForVietQR': 'Bank Info (for VietQR)',
      'errorLoadingData': 'Error loading data',
      'errorLoadingGoals': 'Error loading goals',
      'goal': 'Goal',
      'bankInfoNotConfigured': 'Bank info not configured',
      'addBankInfoMessage':
          'Please add bank information to your goal to generate QR code.',
      'markAsPaidManually': 'Mark as Paid Manually',
      'noGoalsMessage': 'No goals yet. Create one to start saving!',
      'deleteGoal': 'Delete Goal',
      'deleteGoalConfirm':
          'Are you sure you want to delete this goal? This action cannot be undone.',
      'delete': 'Delete',
      'targetAmount': 'Target Amount',
      'targetAmountHint': 'e.g., 5000',
      'bankInfo': 'Bank Info',
      'tileValues': 'Tile Values',
      'selectTileValue': 'Select tile value',
      'currency': 'USD',
      'notificationTitle': 'Digital Saving Box',
      'notificationBody':
          'Hey! Looks like you haven\'t fed the piggy today! Don\'t forget to feed it so it grows big and strong! 🐷',
    },
    AppLanguage.vi: {
      'appTitle': 'Hộp tiết kiệm',
      'dreamVacation': 'Kỳ nghỉ mơ ước',
      'noGoalsYet': 'Chưa có mục tiêu',
      'totalSaved': 'Tổng tiết kiệm',
      'createNewGoal': 'Tạo mục tiêu mới',
      'goalName': 'Tên mục tiêu',
      'goalNameHint': 'VD: iPhone mới',
      'numberOfTiles': 'Số lượng ô',
      'bankId': 'Mã ngân hàng (BIN)',
      'bankIdHint': 'VD: 970422 (MB Bank)',
      'accountNumber': 'Số tài khoản',
      'accountNumberHint': 'Số tài khoản ngân hàng',
      'accountHolder': 'Tên chủ tài khoản',
      'accountHolderHint': 'Tên trên tài khoản',
      'cancel': 'Hủy',
      'create': 'Tạo',
      'settings': 'Cài đặt',
      'statistics': 'Thống kê',
      'grid': 'Lưới',
      'stats': 'Thống kê',
      'language': 'Ngôn ngữ',
      'notifications': 'Thông báo',
      'dailyReminder': 'Nhắc nhở hàng ngày',
      'reminderTime': 'Thời gian nhắc',
      'data': 'Dữ liệu',
      'exportData': 'Xuất dữ liệu',
      'importData': 'Nhập dữ liệu',
      'resetAllData': 'Xóa toàn bộ dữ liệu',
      'about': 'Giới thiệu',
      'version': 'Phiên bản',
      'madeWithFlutter': 'Được tạo với Flutter',
      'copyright': '© 2025 Hộp tiết kiệm\nBảo lưu mọi quyền',
      'alreadySaved': 'Đã tiết kiệm!',
      'confirmSaving': 'Xác nhận tiết kiệm',
      'youSaved': 'Bạn đã tiết kiệm',
      'undoMarkUnpaid': 'Hoàn tác / Đánh dấu chưa trả',
      'openBankApp': 'Mở app ngân hàng',
      'iHaveTransferred': 'Tôi đã chuyển tiền',
      'achieved': 'Đạt {percent}%',
      'savingStreak': 'Chuỗi tiết kiệm',
      'dayStreak': 'Ngày liên tục',
      'thisMonth': 'Tháng này',
      'goalsDone': 'Mục tiêu đạt',
      'goalsOverview': 'Tổng quan mục tiêu',
      'completed': 'Hoàn thành!',
      'percentComplete': 'Hoàn thành {percent}%',
      'resetConfirmTitle': 'Xóa toàn bộ dữ liệu?',
      'resetConfirmMessage':
          'Thao tác này sẽ xóa toàn bộ dữ liệu tiết kiệm và không thể hoàn tác.',
      'reset': 'Xóa',
      'bankInfoRequired': 'Cần thông tin ngân hàng để tạo mã QR',
      'bankName': 'Tên ngân hàng',
      'selectBank': 'Chọn ngân hàng',
      'bankInfoForVietQR': 'Thông tin ngân hàng (VietQR)',
      'errorLoadingData': 'Lỗi tải dữ liệu',
      'errorLoadingGoals': 'Lỗi tải mục tiêu',
      'goal': 'Mục tiêu',
      'bankInfoNotConfigured': 'Chưa cấu hình ngân hàng',
      'addBankInfoMessage': 'Vui lòng thêm thông tin ngân hàng để tạo mã QR.',
      'markAsPaidManually': 'Đánh dấu đã thanh toán',
      'noGoalsMessage': 'Chưa có mục tiêu. Tạo mới để bắt đầu tiết kiệm!',
      'deleteGoal': 'Xóa mục tiêu',
      'deleteGoalConfirm':
          'Bạn có chắc chắn muốn xóa mục tiêu này? Hành động này không thể hoàn tác.',
      'delete': 'Xóa',
      'targetAmount': 'Số tiền mục tiêu',
      'targetAmountHint': 'VD: 5000',
      'bankInfo': 'Thông tin NH',
      'tileValues': 'Giá trị ô',
      'selectTileValue': 'Chọn giá trị ô tiết kiệm',
      'currency': 'VND',
      'notificationTitle': 'Digital Saving Box',
      'notificationBody':
          'Hôm nay hình như bạn chưa cho heo con ăn đấy! Đừng quên cho heo con ăn để nó lớn nhanh nhé! 🐷',
    },
  };
}
