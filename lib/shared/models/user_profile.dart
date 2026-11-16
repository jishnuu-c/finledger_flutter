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
      name: json['legalName'] as String? ?? json['name'] as String? ?? 'BSB Trading LLC',
      trn: json['trn'] as String? ?? '100234891000003',
      currency: json['baseCurrency'] as String? ?? json['currency'] as String? ?? 'AED',
      country: json['countryCode'] as String? ?? json['country'] as String? ?? 'United Arab Emirates',
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
    // Support root user map, nested 'user' map (from AuthResponse/MeResponse), or mixed payload
    final userMap = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : json;

    final companyJson = json['company'] is Map<String, dynamic>
        ? json['company'] as Map<String, dynamic>
        : (userMap['company'] is Map<String, dynamic>
            ? userMap['company'] as Map<String, dynamic>
            : <String, dynamic>{});

    // Derive display role from 'role' string or 'roles' array (e.g. ["ADMIN"])
    String roleStr = 'System User';
    if (userMap['role'] is String && (userMap['role'] as String).trim().isNotEmpty) {
      roleStr = userMap['role'] as String;
    } else if (userMap['roles'] is List && (userMap['roles'] as List).isNotEmpty) {
      final firstRole = (userMap['roles'] as List).first.toString().replaceAll('ROLE_', '');
      switch (firstRole.toUpperCase()) {
        case 'ADMIN':
          roleStr = 'System Administrator';
          break;
        case 'CONTROLLER':
          roleStr = 'Financial Controller';
          break;
        case 'ACCOUNTANT':
          roleStr = 'Senior Accountant';
          break;
        case 'SALES_REP':
          roleStr = 'Sales Representative';
          break;
        case 'WAREHOUSE_MANAGER':
        case 'STOREKEEPER':
          roleStr = 'Warehouse Manager';
          break;
        default:
          roleStr = firstRole;
      }
    }

    // Extract permissions from root level (AuthResponse) or user map
    final rawPerms = json['permissions'] ?? userMap['permissions'];
    final permsList = (rawPerms as List?)?.map((e) => e.toString()).toList() ?? [];

    return UserProfile(
      id: userMap['id']?.toString() ?? '',
      email: userMap['email'] as String? ?? '',
      fullName: userMap['fullName'] as String? ?? 'System User',
      role: roleStr,
      avatarUrl: userMap['avatarUrl'] as String?,
      permissions: permsList,
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
