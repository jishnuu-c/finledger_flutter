class CompanyProfile {
  String companyName;
  String tradeLicenseNo;
  String trn;
  String corporateTaxTrn;
  String address;
  String emirate;
  String country;
  String email;
  String phone;
  String website;
  String currency;
  String? logoUrl;

  CompanyProfile({
    required this.companyName,
    required this.tradeLicenseNo,
    required this.trn,
    required this.corporateTaxTrn,
    required this.address,
    required this.emirate,
    required this.country,
    required this.email,
    required this.phone,
    required this.website,
    required this.currency,
    this.logoUrl,
  });

  factory CompanyProfile.defaultBsb() {
    return CompanyProfile(
      companyName: 'BSB Trading LLC',
      tradeLicenseNo: 'CN-1029384 (Dubai DED)',
      trn: '100234891000003',
      corporateTaxTrn: 'CT-98234710',
      address: 'Building 4, Al Quoz Industrial Area 3, Dubai, UAE',
      emirate: 'Dubai',
      country: 'United Arab Emirates',
      email: 'info@bsbtrading.ae',
      phone: '+971 4 398 7654',
      website: 'https://www.bsbtrading.ae',
      currency: 'AED - United Arab Emirates Dirham',
      logoUrl: 'https://finledger.com/logos/bsb_trading.png',
    );
  }

  Map<String, dynamic> toJson() => {
    'companyName': companyName,
    'tradeLicenseNo': tradeLicenseNo,
    'trn': trn,
    'corporateTaxTrn': corporateTaxTrn,
    'address': address,
    'emirate': emirate,
    'country': country,
    'email': email,
    'phone': phone,
    'website': website,
    'currency': currency,
    'logoUrl': logoUrl,
  };
}

class FiscalYear {
  final int year;
  final String startDate;
  final String endDate;
  final bool isOpen;
  final bool isCurrent;

  const FiscalYear({
    required this.year,
    required this.startDate,
    required this.endDate,
    required this.isOpen,
    required this.isCurrent,
  });
}

class TaxRateConfig {
  final String name;
  final String code;
  final double ratePercent;
  final String type;
  final String description;

  const TaxRateConfig({
    required this.name,
    required this.code,
    required this.ratePercent,
    required this.type,
    required this.description,
  });
}

class CurrencyItem {
  final String code;
  final String name;
  final String symbol;
  final double exchangeRate;
  final bool isBase;

  const CurrencyItem({
    required this.code,
    required this.name,
    required this.symbol,
    required this.exchangeRate,
    required this.isBase,
  });
}

class NumberSeriesItem {
  final String module;
  final String prefix;
  final int nextNumber;
  final int padding;

  const NumberSeriesItem({
    required this.module,
    required this.prefix,
    required this.nextNumber,
    required this.padding,
  });

  String get sample => '$prefix${nextNumber.toString().padLeft(padding, '0')}';
}

class UserRoleItem {
  final String name;
  final String email;
  final String role;
  final String status;

  const UserRoleItem({
    required this.name,
    required this.email,
    required this.role,
    required this.status,
  });
}

class AuditLogItem {
  final String timestamp;
  final String user;
  final String action;
  final String entity;
  final String details;
  final String ipAddress;

  const AuditLogItem({
    required this.timestamp,
    required this.user,
    required this.action,
    required this.entity,
    required this.details,
    required this.ipAddress,
  });
}
