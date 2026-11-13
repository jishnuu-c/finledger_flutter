enum AccountType {
  asset('ASSET', 'Asset'),
  liability('LIABILITY', 'Liability'),
  equity('EQUITY', 'Equity'),
  income('INCOME', 'Income'),
  expense('EXPENSE', 'Expense');

  final String code;
  final String label;
  const AccountType(this.code, this.label);

  static AccountType fromString(String val) {
    return AccountType.values.firstWhere(
      (e) => e.code.toUpperCase() == val.toUpperCase() || e.name.toUpperCase() == val.toUpperCase(),
      orElse: () => AccountType.asset,
    );
  }
}

class Account {
  final int id;
  final int companyId;
  final String code;
  final String name;
  final AccountType accountType;
  final String? subType;
  final int? parentId;
  final String? parentCode;
  final bool isGroup;
  final String normalBalance; // 'DEBIT' or 'CREDIT'
  final String currencyCode;
  final double openingBalance;
  final double currentBalance;
  final bool isSystem;
  final bool isActive;
  final int level;
  final List<Account> children;

  const Account({
    required this.id,
    this.companyId = 1,
    required this.code,
    required this.name,
    required this.accountType,
    this.subType,
    this.parentId,
    this.parentCode,
    required this.isGroup,
    this.normalBalance = 'DEBIT',
    this.currencyCode = 'AED',
    this.openingBalance = 0.0,
    required this.currentBalance,
    this.isSystem = false,
    this.isActive = true,
    this.level = 0,
    this.children = const [],
  });

  factory Account.fromJson(Map<String, dynamic> json, {int level = 0}) {
    final rawChildren = json['children'] as List? ?? [];
    return Account(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      companyId: json['companyId'] as int? ?? 1,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      accountType: AccountType.fromString(json['accountType'] as String? ?? 'ASSET'),
      subType: json['subType'] as String?,
      parentId: json['parentId'] as int?,
      parentCode: json['parentCode'] as String?,
      isGroup: json['isGroup'] == true || json['isGroup'] == 1,
      normalBalance: json['normalBalance'] as String? ?? 'DEBIT',
      currencyCode: json['currencyCode'] as String? ?? 'AED',
      openingBalance: (json['openingBalance'] as num?)?.toDouble() ?? 0.0,
      currentBalance: ((json['currentBalance'] ?? json['balance']) as num?)?.toDouble() ?? 0.0,
      isSystem: json['isSystem'] == true || json['isSystem'] == 1,
      isActive: json['isActive'] != false && json['isActive'] != 0,
      level: json['level'] as int? ?? level,
      children: rawChildren.map((c) => Account.fromJson(c as Map<String, dynamic>, level: level + 1)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'companyId': companyId,
    'code': code,
    'name': name,
    'accountType': accountType.code,
    'subType': subType,
    'parentId': parentId,
    'parentCode': parentCode,
    'isGroup': isGroup,
    'normalBalance': normalBalance,
    'currencyCode': currencyCode,
    'openingBalance': openingBalance,
    'currentBalance': currentBalance,
    'isSystem': isSystem,
    'isActive': isActive,
    'level': level,
  };

  Account copyWith({
    int? id,
    int? companyId,
    String? code,
    String? name,
    AccountType? accountType,
    String? subType,
    int? parentId,
    String? parentCode,
    bool? isGroup,
    String? normalBalance,
    String? currencyCode,
    double? openingBalance,
    double? currentBalance,
    bool? isSystem,
    bool? isActive,
    int? level,
    List<Account>? children,
  }) {
    return Account(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      code: code ?? this.code,
      name: name ?? this.name,
      accountType: accountType ?? this.accountType,
      subType: subType ?? this.subType,
      parentId: parentId ?? this.parentId,
      parentCode: parentCode ?? this.parentCode,
      isGroup: isGroup ?? this.isGroup,
      normalBalance: normalBalance ?? this.normalBalance,
      currencyCode: currencyCode ?? this.currencyCode,
      openingBalance: openingBalance ?? this.openingBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      isSystem: isSystem ?? this.isSystem,
      isActive: isActive ?? this.isActive,
      level: level ?? this.level,
      children: children ?? this.children,
    );
  }
}
