class Company {
  final String id;
  final String name;
  final String trn;
  final String currency;
  final String country;

  const Company({
    required this.id,
    required this.name,
    required this.trn,
    this.currency = 'AED',
    this.country = 'United Arab Emirates',
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'BSB Trading LLC',
      trn: json['trn'] as String? ?? '100234891000003',
      currency: json['currency'] as String? ?? 'AED',
      country: json['country'] as String? ?? 'United Arab Emirates',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'trn': trn,
    'currency': currency,
    'country': country,
  };
}

class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final String? avatarUrl;
  final List<String> permissions;
  final Company company;

  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.avatarUrl,
    required this.permissions,
    required this.company,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final companyJson = json['company'] is Map<String, dynamic>
        ? json['company'] as Map<String, dynamic>
        : <String, dynamic>{};

    return UserProfile(
      id: json['id']?.toString() ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? 'Ahmed Jaber Al Hamri',
      role: json['role'] as String? ?? 'Financial Controller',
      avatarUrl: json['avatarUrl'] as String?,
      permissions: (json['permissions'] as List?)?.map((e) => e.toString()).toList() ?? [],
      company: Company.fromJson(companyJson),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'fullName': fullName,
    'role': role,
    'avatarUrl': avatarUrl,
    'permissions': permissions,
    'company': company.toJson(),
  };

  static UserProfile defaultMock() {
    return const UserProfile(
      id: 'USR-001',
      email: 'ahmed.alhamri@bsbtrading.ae',
      fullName: 'Ahmed Jaber Al Hamri',
      role: 'Financial Controller',
      permissions: [
        'DASHBOARD_VIEW',
        'LEAD_VIEW',
        'OPPORTUNITY_VIEW',
        'INVOICE_VIEW',
        'INVOICE_CREATE',
        'BILL_VIEW',
        'ITEM_VIEW',
        'EXPENSE_VIEW',
        'ACCOUNT_VIEW',
        'JOURNAL_VIEW',
        'BANK_RECONCILE',
        'REPORT_VIEW',
        'SETTINGS_EDIT',
      ],
      company: Company(
        id: 'CMP-101',
        name: 'BSB Trading LLC',
        trn: '100234891000003',
        currency: 'AED',
        country: 'United Arab Emirates',
      ),
    );
  }
}
