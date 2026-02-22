import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final paymentServiceProvider = Provider<PaymentService>(
  (ref) => PaymentService(),
);

class PaymentService {
  String generateVietQR({
    required int amount,
    required String memo,
    String? bankId,
    String? accountNo,
    String? accountName,
  }) {
    // If no bank info provided, return empty URL
    if (bankId == null ||
        bankId.isEmpty ||
        accountNo == null ||
        accountNo.isEmpty) {
      return '';
    }

    const template = 'qr_only';

    // Format amount and encode memo
    final encodedMemo = Uri.encodeComponent(memo);
    final encodedName = accountName != null
        ? Uri.encodeComponent(accountName)
        : '';

    // Using VietQR Quick Link
    // Format: https://img.vietqr.io/image/{bankId}-{accountNo}-{template}.png?amount={amount}&addInfo={memo}&accountName={name}
    var url =
        'https://img.vietqr.io/image/$bankId-$accountNo-$template.png?amount=$amount&addInfo=$encodedMemo';
    if (encodedName.isNotEmpty) {
      url += '&accountName=$encodedName';
    }
    return url;
  }

  Future<void> launchBankApp() async {
    // List of common banking app deep links in Vietnam
    // Note: These deep links are unofficial and subject to change by banks
    final List<String> deepLinks = [
      'vietcombankmobile://',
      'bidvsmartbanking://',
      'mbbank://',
      'techcombankmobile://',
      'acbapp://',
      'vpbankneo://',
      'tpb://', // TPBank
    ];

    bool launched = false;
    for (final link in deepLinks) {
      final uri = Uri.parse(link);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        launched = true;
        break;
      }
    }

    if (!launched) {
      // If no specific app found, maybe user is on desktop or no supported app
      // Nothing to do, or show error in UI.
      // Since this returns void, UI should handle "manual switch".
    }
  }
}
