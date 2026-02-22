// Vietnamese banks list with BIN codes for VietQR
class VietBank {
  final String name;
  final String shortName;
  final String bin;
  final String? logo;

  const VietBank({
    required this.name,
    required this.shortName,
    required this.bin,
    this.logo,
  });

  @override
  String toString() => shortName;
}

class VietBanks {
  static const List<VietBank> banks = [
    VietBank(
      name: 'Ngân hàng TMCP Quân đội',
      shortName: 'MB Bank',
      bin: '970422',
    ),
    VietBank(
      name: 'Ngân hàng TMCP Kỹ thương Việt Nam',
      shortName: 'Techcombank',
      bin: '970407',
    ),
    VietBank(
      name: 'Ngân hàng TMCP Ngoại thương Việt Nam',
      shortName: 'Vietcombank',
      bin: '970436',
    ),
    VietBank(
      name: 'Ngân hàng TMCP Đầu tư và Phát triển Việt Nam',
      shortName: 'BIDV',
      bin: '970418',
    ),
    VietBank(
      name: 'Ngân hàng TMCP Công Thương Việt Nam',
      shortName: 'VietinBank',
      bin: '970415',
    ),
    VietBank(name: 'Ngân hàng TMCP Á Châu', shortName: 'ACB', bin: '970416'),
    VietBank(
      name: 'Ngân hàng TMCP Việt Nam Thịnh Vượng',
      shortName: 'VPBank',
      bin: '970432',
    ),
    VietBank(
      name: 'Ngân hàng TMCP Tiên Phong',
      shortName: 'TPBank',
      bin: '970423',
    ),
    VietBank(
      name: 'Ngân hàng TMCP Sài Gòn Thương Tín',
      shortName: 'Sacombank',
      bin: '970403',
    ),
    VietBank(
      name: 'Ngân hàng TMCP Quốc tế Việt Nam',
      shortName: 'VIB',
      bin: '970441',
    ),
    VietBank(
      name: 'Ngân hàng TMCP Hàng Hải Việt Nam',
      shortName: 'MSB',
      bin: '970426',
    ),
    VietBank(
      name: 'Ngân hàng TMCP Sài Gòn - Hà Nội',
      shortName: 'SHB',
      bin: '970443',
    ),
    VietBank(
      name: 'Ngân hàng TMCP Phát triển TP.HCM',
      shortName: 'HDBank',
      bin: '970437',
    ),
    VietBank(
      name: 'Ngân hàng TMCP Bưu điện Liên Việt',
      shortName: 'LienVietPostBank',
      bin: '970449',
    ),
    VietBank(
      name: 'Ngân hàng TMCP Đông Á',
      shortName: 'DongA Bank',
      bin: '970406',
    ),
    VietBank(
      name: 'Ngân hàng TMCP Xuất Nhập khẩu Việt Nam',
      shortName: 'Eximbank',
      bin: '970431',
    ),
    VietBank(
      name: 'Ngân hàng Nông nghiệp và Phát triển Nông thôn Việt Nam',
      shortName: 'Agribank',
      bin: '970405',
    ),
    VietBank(name: 'Ngân hàng TMCP Sài Gòn', shortName: 'SCB', bin: '970429'),
    VietBank(
      name: 'Ngân hàng TMCP Phương Đông',
      shortName: 'OCB',
      bin: '970448',
    ),
    VietBank(
      name: 'Ngân hàng TMCP Nam Á',
      shortName: 'Nam A Bank',
      bin: '970428',
    ),
    VietBank(
      name: 'Ngân hàng TMCP Bắc Á',
      shortName: 'Bac A Bank',
      bin: '970409',
    ),
    VietBank(
      name: 'Ngân hàng TMCP An Bình',
      shortName: 'ABBANK',
      bin: '970425',
    ),
    VietBank(
      name: 'Ngân hàng TMCP Việt Á',
      shortName: 'VietABank',
      bin: '970427',
    ),
    VietBank(
      name: 'Ngân hàng TMCP Bản Việt',
      shortName: 'Viet Capital Bank',
      bin: '970454',
    ),
    VietBank(
      name: 'Ngân hàng TMCP Kiên Long',
      shortName: 'Kienlongbank',
      bin: '970452',
    ),
    VietBank(
      name: 'Ngân hàng TMCP Đông Nam Á',
      shortName: 'SeABank',
      bin: '970440',
    ),
    VietBank(name: 'Ngân hàng TMCP Quốc Dân', shortName: 'NCB', bin: '970419'),
    VietBank(
      name: 'Ngân hàng TMCP Việt Nam Thương Tín',
      shortName: 'Vietbank',
      bin: '970433',
    ),
    VietBank(
      name: 'Ngân hàng TMCP Sài Gòn Công Thương',
      shortName: 'Saigonbank',
      bin: '970400',
    ),
    VietBank(
      name: 'Ngân hàng TMCP Xăng dầu Petrolimex',
      shortName: 'PGBank',
      bin: '970430',
    ),
    VietBank(
      name: 'Ngân hàng Chính sách Xã hội',
      shortName: 'VBSP',
      bin: '970402',
    ),
    VietBank(
      name: 'Ngân hàng Phát triển Việt Nam',
      shortName: 'VDB',
      bin: '970404',
    ),
    VietBank(name: 'Ngân hàng Xây dựng', shortName: 'CB', bin: '970444'),
    VietBank(
      name: 'Ngân hàng Đại chúng Việt Nam',
      shortName: 'PVcomBank',
      bin: '970412',
    ),
    VietBank(
      name: 'Ngân hàng TNHH MTV Woori Việt Nam',
      shortName: 'Woori Bank',
      bin: '970457',
    ),
    VietBank(
      name: 'Ngân hàng Liên doanh Việt - Nga',
      shortName: 'VRB',
      bin: '970421',
    ),
    VietBank(
      name: 'Ngân hàng TNHH MTV CIMB Việt Nam',
      shortName: 'CIMB',
      bin: '422589',
    ),
    VietBank(
      name: 'Ngân hàng TNHH MTV Hong Leong Việt Nam',
      shortName: 'HLBVN',
      bin: '970442',
    ),
    VietBank(
      name: 'Ngân hàng TNHH MTV Shinhan Việt Nam',
      shortName: 'Shinhan Bank',
      bin: '970424',
    ),
    VietBank(
      name: 'Ngân hàng TNHH MTV Public Việt Nam',
      shortName: 'PBVN',
      bin: '970439',
    ),
    VietBank(
      name: 'Ngân hàng TNHH MTV UOB Việt Nam',
      shortName: 'UOB',
      bin: '970458',
    ),
    VietBank(
      name: 'Ngân hàng TNHH MTV Standard Chartered Việt Nam',
      shortName: 'Standard Chartered',
      bin: '970410',
    ),
    VietBank(name: 'Ngân hàng TNHH Indovina', shortName: 'IVB', bin: '970434'),
    VietBank(
      name: 'Ngân hàng số CAKE by VPBank',
      shortName: 'CAKE',
      bin: '546034',
    ),
    VietBank(
      name: 'Ngân hàng số Ubank by VPBank',
      shortName: 'Ubank',
      bin: '546035',
    ),
    VietBank(name: 'Ví điện tử MoMo', shortName: 'MoMo', bin: '970456'),
    VietBank(name: 'Ví điện tử ZaloPay', shortName: 'ZaloPay', bin: '970451'),
    VietBank(name: 'Ví điện tử VNPay', shortName: 'VNPay', bin: '970453'),
  ];

  static VietBank? findByBin(String bin) {
    try {
      return banks.firstWhere((bank) => bank.bin == bin);
    } catch (_) {
      return null;
    }
  }

  static VietBank? findByShortName(String shortName) {
    try {
      return banks.firstWhere((bank) => bank.shortName == shortName);
    } catch (_) {
      return null;
    }
  }
}
