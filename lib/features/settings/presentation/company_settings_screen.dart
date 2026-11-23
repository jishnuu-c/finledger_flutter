import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/language_switcher.dart';
import '../../../core/localization/locale_provider.dart';
import '../data/models/settings_models.dart';
import '../data/services/settings_service.dart';

class CompanySettingsScreen extends StatefulWidget {
  final SettingsService? settingsService;
  final String initialTab;

  const CompanySettingsScreen({
    super.key,
    this.settingsService,
    this.initialTab = 'profile',
  });

  @override
  State<CompanySettingsScreen> createState() => _CompanySettingsScreenState();
}

class _CompanySettingsScreenState extends State<CompanySettingsScreen> {
  late SettingsService _service;
  late String _activeTab;
  CompanyProfile? _profile;
  CompanyProfile? get currentProfile => _profile;
  bool _isLoading = true;

  // Controllers for Profile Form
  late TextEditingController _nameController;
  late TextEditingController _tradeLicenseController;
  late TextEditingController _trnController;
  late TextEditingController _corporateTaxTrnController;
  late TextEditingController _addressController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _websiteController;
  String _selectedEmirate = 'Dubai';
  String _selectedCurrency = 'AED - United Arab Emirates Dirham';
  String? _logoUrl;

  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> _getTabs(BuildContext context) => [
    {'id': 'profile', 'label': context.l10n.companyProfile, 'icon': Icons.business_outlined},
    {'id': 'language', 'label': context.l10n.languageAndRegion, 'icon': Icons.translate_rounded},
    {'id': 'fiscal_years', 'label': context.l10n.fiscalYears, 'icon': Icons.calendar_month_outlined},
    {'id': 'tax_rates', 'label': context.l10n.taxRates, 'icon': Icons.percent_outlined},
    {'id': 'currencies', 'label': context.l10n.currencies, 'icon': Icons.monetization_on_outlined},
    {'id': 'number_series', 'label': context.l10n.numberSeries, 'icon': Icons.pin_outlined},
    {'id': 'users_roles', 'label': context.l10n.usersAndRoles, 'icon': Icons.people_alt_outlined},
    {'id': 'audit_log', 'label': context.l10n.auditLog, 'icon': Icons.history_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _service = widget.settingsService ?? SettingsService();
    _activeTab = widget.initialTab;
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final p = await _service.getCompanyProfile();
    setState(() {
      _profile = p;
      _nameController = TextEditingController(text: p.companyName);
      _tradeLicenseController = TextEditingController(text: p.tradeLicenseNo);
      _trnController = TextEditingController(text: p.trn);
      _corporateTaxTrnController = TextEditingController(text: p.corporateTaxTrn);
      _addressController = TextEditingController(text: p.address);
      _emailController = TextEditingController(text: p.email);
      _phoneController = TextEditingController(text: p.phone);
      _websiteController = TextEditingController(text: p.website);
      _selectedEmirate = p.emirate;
      _selectedCurrency = p.currency;
      _logoUrl = p.logoUrl;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    if (!_isLoading) {
      _nameController.dispose();
      _tradeLicenseController.dispose();
      _trnController.dispose();
      _corporateTaxTrnController.dispose();
      _addressController.dispose();
      _emailController.dispose();
      _phoneController.dispose();
      _websiteController.dispose();
    }
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      final updated = CompanyProfile(
        companyName: _nameController.text.trim(),
        tradeLicenseNo: _tradeLicenseController.text.trim(),
        trn: _trnController.text.trim(),
        corporateTaxTrn: _corporateTaxTrnController.text.trim(),
        address: _addressController.text.trim(),
        emirate: _selectedEmirate,
        country: 'United Arab Emirates',
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        website: _websiteController.text.trim(),
        currency: _selectedCurrency,
        logoUrl: _logoUrl,
      );

      await _service.updateCompanyProfile(updated);
      setState(() => _profile = updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.companyProfileUpdated),
            backgroundColor: const Color(0xFF16A34A),
          ),
        );
      }
    }
  }

  void _handleUploadLogo() {
    setState(() {
      _logoUrl = 'https://finledger.com/logos/bsb_custom_${DateTime.now().millisecondsSinceEpoch}.png';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.companyLogoUploaded),
        backgroundColor: const Color(0xFF16A34A),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleRemoveLogo() {
    setState(() {
      _logoUrl = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.companyLogoRemoved),
        backgroundColor: const Color(0xFF64748B),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final tabs = _getTabs(context);
    final activeTabObj = tabs.firstWhere(
      (t) => t['id'] == _activeTab,
      orElse: () => tabs.first,
    );

    final isMobile = MediaQuery.of(context).size.width < 768;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 28,
        vertical: isMobile ? 16 : 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Breadcrumb
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {},
                        child: Text(context.l10n.settings, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                      ),
                      const SizedBox(width: 4),
                      const Text('/', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      const SizedBox(width: 4),
                      Text(
                        activeTabObj['label'] as String,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF2563EB), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.l10n.companyAndSystemSettings,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              if (_activeTab == 'profile')
                ElevatedButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.save_outlined, size: 16, color: Colors.white),
                  label: Text(context.l10n.saveChanges, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    minimumSize: const Size(0, 40),
                    elevation: 0,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 22),

          // Split View: Vertical Sub-Navigation Tabs + Content Area
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 850;
              if (isDesktop) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 230,
                      child: _buildVerticalSubNav(context),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildActiveTabContent(),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: tabs.map((tab) {
                          final isSelected = tab['id'] == _activeTab;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              onTap: () => setState(() => _activeTab = tab['id'] as String),
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                height: 36,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      tab['icon'] as IconData,
                                      size: 15,
                                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      tab['label'] as String,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        color: isSelected ? Colors.white : const Color(0xFF334155),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildActiveTabContent(),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalSubNav(BuildContext context) {
    final tabs = _getTabs(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: tabs.map((tab) {
          final isSelected = tab['id'] == _activeTab;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: InkWell(
              onTap: () => setState(() => _activeTab = tab['id'] as String),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: isSelected
                      ? const Border(left: BorderSide(color: Color(0xFF2563EB), width: 3))
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      tab['icon'] as IconData,
                      size: 18,
                      color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tab['label'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? const Color(0xFF1E40AF) : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActiveTabContent() {
    switch (_activeTab) {
      case 'profile':
        return _buildCompanyProfileTab();
      case 'language':
        return LanguageSwitcher.settingsCard();
      case 'fiscal_years':
        return _buildFiscalYearsTab();
      case 'tax_rates':
        return _buildTaxRatesTab();
      case 'currencies':
        return _buildCurrenciesTab();
      case 'number_series':
        return _buildNumberSeriesTab();
      case 'users_roles':
        return _buildUsersAndRolesTab();
      case 'audit_log':
        return _buildAuditLogTab();
      default:
        return _buildCompanyProfileTab();
    }
  }

  Widget _buildCompanyProfileTab() {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.companyProfileTitle,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.companyProfileSubtitle,
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 20),

            // Logo Upload Area
            _buildLogoUploadArea(),
            const SizedBox(height: 24),
            const Divider(height: 1),
            const SizedBox(height: 24),

            // Responsive Two-Column Form
            LayoutBuilder(
              builder: (context, constraints) {
                final isStacked = constraints.maxWidth < 650;
                final leftColumn = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel(context.l10n.companyLegalName),
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(fontSize: 13),
                      decoration: _buildInputDecoration(prefixIcon: Icons.business_outlined),
                      validator: (v) => (v == null || v.trim().isEmpty) ? context.l10n.validationRequired : null,
                    ),
                    const SizedBox(height: 16),

                    _buildFieldLabel(context.l10n.taxRegistrationNumberTrn),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _trnController,
                            style: const TextStyle(fontSize: 13),
                            decoration: _buildInputDecoration(prefixIcon: Icons.confirmation_number_outlined),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return context.l10n.validationRequired;
                              if (v.trim().length != 15) return context.l10n.validationTrn15Digits;
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.verified, size: 14, color: Color(0xFF166534)),
                              const SizedBox(width: 4),
                              Text(
                                context.l10n.ftaActive,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildFieldLabel(context.l10n.tradeLicenseCommercialReg),
                    TextFormField(
                      controller: _tradeLicenseController,
                      style: const TextStyle(fontSize: 13),
                      decoration: _buildInputDecoration(prefixIcon: Icons.description_outlined),
                    ),
                    const SizedBox(height: 16),

                    _buildFieldLabel(context.l10n.corporateTaxTrn),
                    TextFormField(
                      controller: _corporateTaxTrnController,
                      style: const TextStyle(fontSize: 13),
                      decoration: _buildInputDecoration(prefixIcon: Icons.account_balance_outlined),
                    ),
                    const SizedBox(height: 16),

                    _buildFieldLabel(context.l10n.registeredAddress),
                    TextFormField(
                      controller: _addressController,
                      style: const TextStyle(fontSize: 13),
                      maxLines: 2,
                      decoration: _buildInputDecoration(prefixIcon: Icons.place_outlined),
                      validator: (v) => (v == null || v.trim().isEmpty) ? context.l10n.validationRequired : null,
                    ),
                  ],
                );

                final rightColumn = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel(context.l10n.emirateLabel),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedEmirate,
                      isExpanded: true,
                      decoration: _buildInputDecoration(prefixIcon: Icons.location_city_outlined),
                      items: [
                        DropdownMenuItem(value: 'Dubai', child: Text(context.l10n.emirateDubai)),
                        DropdownMenuItem(value: 'Abu Dhabi', child: Text(context.l10n.emirateAbuDhabi)),
                        DropdownMenuItem(value: 'Sharjah', child: Text(context.l10n.emirateSharjah)),
                        DropdownMenuItem(value: 'Ajman', child: Text(context.l10n.emirateAjman)),
                        DropdownMenuItem(value: 'Ras Al Khaimah', child: Text(context.l10n.emirateRasAlKhaimah)),
                        DropdownMenuItem(value: 'Fujairah', child: Text(context.l10n.emirateFujairah)),
                        DropdownMenuItem(value: 'Umm Al Quwain', child: Text(context.l10n.emirateUmmAlQuwain)),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedEmirate = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildFieldLabel(context.l10n.primaryEmailLabel),
                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(fontSize: 13),
                      decoration: _buildInputDecoration(prefixIcon: Icons.email_outlined),
                      validator: (v) => (v == null || !v.contains('@')) ? context.l10n.validEmailRequired : null,
                    ),
                    const SizedBox(height: 16),

                    _buildFieldLabel(context.l10n.phoneNumberLabel),
                    TextFormField(
                      controller: _phoneController,
                      style: const TextStyle(fontSize: 13),
                      decoration: _buildInputDecoration(prefixIcon: Icons.phone_outlined),
                    ),
                    const SizedBox(height: 16),

                    _buildFieldLabel(context.l10n.websiteLabel),
                    TextFormField(
                      controller: _websiteController,
                      style: const TextStyle(fontSize: 13),
                      decoration: _buildInputDecoration(prefixIcon: Icons.language_outlined),
                    ),
                    const SizedBox(height: 16),

                    _buildFieldLabel(context.l10n.functionalBaseCurrency),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCurrency,
                      isExpanded: true,
                      decoration: _buildInputDecoration(prefixIcon: Icons.payments_outlined),
                      items: [
                        DropdownMenuItem(
                          value: 'AED - United Arab Emirates Dirham',
                          child: Text(context.l10n.currencyAedFull),
                        ),
                        DropdownMenuItem(
                          value: 'USD - US Dollar',
                          child: Text(context.l10n.currencyUsdFull),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCurrency = val);
                      },
                    ),
                  ],
                );

                if (isStacked) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      leftColumn,
                      const SizedBox(height: 16),
                      rightColumn,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: leftColumn),
                    const SizedBox(width: 24),
                    Expanded(child: rightColumn),
                  ],
                );
              },
            ),
            const SizedBox(height: 28),

            Wrap(
              alignment: WrapAlignment.end,
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: _loadProfile,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    minimumSize: const Size(0, 38),
                  ),
                  child: Text(context.l10n.reset, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    minimumSize: const Size(0, 38),
                    elevation: 0,
                  ),
                  child: Text(context.l10n.saveChanges, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoUploadArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 450;
        final logoBox = Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF0F1B33),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Center(
            child: _logoUrl != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'BSB',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        width: 30,
                        height: 3,
                        color: const Color(0xFF38BDF8),
                      ),
                    ],
                  )
                : const Icon(Icons.business, color: Colors.white, size: 32),
          ),
        );

        final logoInfo = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.companyLogo,
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 2),
            Text(
              context.l10n.companyLogoHint,
              style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _handleUploadLogo,
                  icon: const Icon(Icons.cloud_upload_outlined, size: 14),
                  label: Text(context.l10n.uploadNewLogo, style: const TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                  ),
                ),
                if (_logoUrl != null)
                  TextButton(
                    onPressed: _handleRemoveLogo,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      minimumSize: Size.zero,
                    ),
                    child: Text(context.l10n.removeLogo, style: const TextStyle(fontSize: 12)),
                  ),
              ],
            ),
          ],
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              logoBox,
              const SizedBox(height: 12),
              logoInfo,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            logoBox,
            const SizedBox(width: 20),
            Expanded(child: logoInfo),
          ],
        );
      },
    );
  }

  InputDecoration _buildInputDecoration({String? hintText, IconData? prefixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 16, color: AppColors.textMuted) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFFDC2626)),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildFiscalYearsTab() {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final years = _service.getFiscalYears();
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.fiscalYearsAndLocking, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(context.l10n.fiscalYearsSubtitle, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Lock Books Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_outline, color: Color(0xFFB45309), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.booksLockedPriorTo,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                      ),
                      Text(
                        context.l10n.booksLockedDesc,
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF92400E)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Responsive Table or Mobile Cards
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 500) {
                return Column(
                  children: [
                    for (final y in years)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('FY ${y.year}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                                  const SizedBox(height: 4),
                                  Text('${y.startDate} to ${y.endDate}', style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: y.isOpen ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                y.isOpen ? context.l10n.statusOpen : context.l10n.statusClosed,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: y.isOpen ? const Color(0xFF166534) : const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              }
              final effectiveWidth = constraints.maxWidth > 500 ? constraints.maxWidth : 500.0;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: effectiveWidth,
                  child: Table(
                    border: TableBorder.all(color: AppColors.border),
                    columnWidths: const {
                      0: FlexColumnWidth(1.2),
                      1: FlexColumnWidth(1.5),
                      2: FlexColumnWidth(1.5),
                      3: FlexColumnWidth(1.2),
                    },
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
                        children: [
                          Padding(padding: const EdgeInsets.all(10), child: Text(context.l10n.fiscalYear, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          Padding(padding: const EdgeInsets.all(10), child: Text(context.l10n.startDate, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          Padding(padding: const EdgeInsets.all(10), child: Text(context.l10n.endDate, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          Padding(padding: const EdgeInsets.all(10), child: Text(context.l10n.status, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        ],
                      ),
                      for (final y in years)
                        TableRow(
                          children: [
                            Padding(padding: const EdgeInsets.all(10), child: Text('FY ${y.year}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5))),
                            Padding(padding: const EdgeInsets.all(10), child: Text(y.startDate, style: const TextStyle(fontSize: 12.5))),
                            Padding(padding: const EdgeInsets.all(10), child: Text(y.endDate, style: const TextStyle(fontSize: 12.5))),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: y.isOpen ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      y.isOpen ? context.l10n.openCurrentStatus : context.l10n.statusClosed,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: y.isOpen ? const Color(0xFF166534) : const Color(0xFF475569),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTaxRatesTab() {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final rates = _service.getTaxRates();
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.uaeVatRatesRegs, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(context.l10n.uaeVatSubtitle, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 500;
              return Column(
                children: [
                  for (final rate in rates)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${rate.ratePercent.toStringAsFixed(0)}%',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        rate.name,
                                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    if (isNarrow)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          rate.code,
                                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(rate.description, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          if (!isNarrow) ...[
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(rate.code, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCurrenciesTab() {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final currencies = _service.getCurrencies();
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;
              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.currenciesAndRates, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.currenciesSubtitle,
                      style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.l10n.ratesSynced),
                            backgroundColor: const Color(0xFF16A34A),
                          ),
                        );
                      },
                      icon: const Icon(Icons.sync, size: 14),
                      label: Text(context.l10n.updateRates),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 38),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        elevation: 0,
                      ),
                    ),
                  ],
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.l10n.currenciesAndRates, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(context.l10n.currenciesSubtitle, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.l10n.ratesSynced),
                          backgroundColor: const Color(0xFF16A34A),
                        ),
                      );
                    },
                    icon: const Icon(Icons.sync, size: 14),
                    label: Text(context.l10n.updateRates),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 38),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      elevation: 0,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Responsive Currency Cards for mobile, Table for desktop
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 550) {
                return Column(
                  children: [
                    for (final c in currencies)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: c.isBase ? const Color(0xFFDBEAFE) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  c.symbol,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: c.isBase ? const Color(0xFF1E40AF) : const Color(0xFF334155),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c.code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                                  const SizedBox(height: 2),
                                  Text(
                                    c.name,
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  c.exchangeRate.toStringAsFixed(4),
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 3),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: c.isBase ? const Color(0xFFDBEAFE) : const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    c.isBase ? context.l10n.baseCurrency : context.l10n.statusActive,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: c.isBase ? const Color(0xFF1E40AF) : const Color(0xFF166534),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              }
              final effectiveWidth = constraints.maxWidth;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: effectiveWidth,
                  child: Table(
                    border: TableBorder.all(color: AppColors.border),
                    columnWidths: const {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(1.5),
                      3: FlexColumnWidth(1.2),
                    },
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
                        children: [
                          Padding(padding: const EdgeInsets.all(10), child: Text(context.l10n.colCurrency, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          Padding(padding: const EdgeInsets.all(10), child: Text(context.l10n.colCurrencyName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          Padding(padding: const EdgeInsets.all(10), child: Text(context.l10n.rateToAed, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          Padding(padding: const EdgeInsets.all(10), child: Text(context.l10n.status, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        ],
                      ),
                      for (final c in currencies)
                        TableRow(
                          children: [
                            Padding(padding: const EdgeInsets.all(10), child: Text(c.code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                            Padding(padding: const EdgeInsets.all(10), child: Text(c.name, style: const TextStyle(fontSize: 12.5))),
                            Padding(padding: const EdgeInsets.all(10), child: Text(c.exchangeRate.toStringAsFixed(4), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600))),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: c.isBase ? const Color(0xFFDBEAFE) : const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      c.isBase ? context.l10n.baseCurrency : context.l10n.activeRate,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: c.isBase ? const Color(0xFF1E40AF) : const Color(0xFF166534),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNumberSeriesTab() {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final series = _service.getNumberSeries();
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.docNumberSeries, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(context.l10n.docNumberSeriesSubtitle, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Responsive Cards for mobile, Table for desktop
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 550) {
                return Column(
                  children: [
                    for (final s in series)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s.module, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  const SizedBox(height: 4),
                                  Text('Prefix: ${s.prefix} • Next: ${s.nextNumber}', style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(s.sample, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 11.5)),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              }
              final effectiveWidth = constraints.maxWidth;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: effectiveWidth,
                  child: Table(
                    border: TableBorder.all(color: AppColors.border),
                    columnWidths: const {
                      0: FlexColumnWidth(1.6),
                      1: FlexColumnWidth(1.4),
                      2: FlexColumnWidth(1.2),
                      3: FlexColumnWidth(1.8),
                    },
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
                        children: [
                          Padding(padding: const EdgeInsets.all(10), child: Text(context.l10n.docType, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          Padding(padding: const EdgeInsets.all(10), child: Text(context.l10n.prefix, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          Padding(padding: const EdgeInsets.all(10), child: Text(context.l10n.nextSequential, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          Padding(padding: const EdgeInsets.all(10), child: Text(context.l10n.sampleDocNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        ],
                      ),
                      for (final s in series)
                        TableRow(
                          children: [
                            Padding(padding: const EdgeInsets.all(10), child: Text(s.module, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5))),
                            Padding(padding: const EdgeInsets.all(10), child: Text(s.prefix, style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5))),
                            Padding(padding: const EdgeInsets.all(10), child: Text(s.nextNumber.toString(), style: const TextStyle(fontSize: 12.5))),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(s.sample, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 11.5)),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showInviteUserDialog() {
    final emailController = TextEditingController();
    final nameController = TextEditingController();
    String selectedRole = 'Accountant';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.white,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.person_add_outlined, size: 20, color: Color(0xFF2563EB)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          context.l10n.inviteTeamMember,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18, color: AppColors.textSecondary),
                        onPressed: () => Navigator.pop(ctx),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildFieldLabel(context.l10n.fullName),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(fontSize: 13),
                    decoration: _buildInputDecoration(hintText: 'John Doe', prefixIcon: Icons.badge_outlined),
                  ),
                  const SizedBox(height: 14),
                  _buildFieldLabel(context.l10n.emailAddress),
                  TextField(
                    controller: emailController,
                    style: const TextStyle(fontSize: 13),
                    decoration: _buildInputDecoration(hintText: 'user@company.com', prefixIcon: Icons.email_outlined),
                  ),
                  const SizedBox(height: 14),
                  _buildFieldLabel(context.l10n.roleDirective),
                  DropdownButtonFormField<String>(
                    initialValue: selectedRole,
                    isExpanded: true,
                    style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                    decoration: _buildInputDecoration(prefixIcon: Icons.shield_outlined),
                    items: const [
                      DropdownMenuItem(value: 'Accountant', child: Text('Accountant')),
                      DropdownMenuItem(value: 'Sales Representative', child: Text('Sales Representative')),
                      DropdownMenuItem(value: 'Warehouse Manager', child: Text('Warehouse Manager')),
                      DropdownMenuItem(value: 'Controller', child: Text('Controller')),
                    ],
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedRole = val);
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(80, 38),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          side: const BorderSide(color: AppColors.border),
                        ),
                        child: Text(context.l10n.cancel, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${context.l10n.invitationSent} ${emailController.text} ${context.l10n.asRole} $selectedRole.'),
                              backgroundColor: AppColors.paid,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(100, 38),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          elevation: 0,
                        ),
                        child: Text(context.l10n.sendInvite, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUsersAndRolesTab() {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final users = _service.getUsersAndRoles();
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;
              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.usersAndPermissions, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.usersAndPermissionsSubtitle,
                      style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _showInviteUserDialog,
                      icon: const Icon(Icons.person_add_outlined, size: 14),
                      label: Text(context.l10n.inviteUserBtn),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 38),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        elevation: 0,
                      ),
                    ),
                  ],
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.l10n.usersAndPermissions, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(context.l10n.usersAndPermissionsSubtitle, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _showInviteUserDialog,
                    icon: const Icon(Icons.person_add_outlined, size: 14),
                    label: Text(context.l10n.inviteUserBtn),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 38),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      elevation: 0,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Responsive User Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 520;
              return Column(
                children: [
                  for (final u in users)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: isNarrow
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: const Color(0xFFEFF6FF),
                                  child: Text(
                                    u.name.isNotEmpty ? u.name[0] : 'U',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB), fontSize: 14),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              u.name,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFDCFCE7),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(context.l10n.statusActive, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(u.email, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          u.role,
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: const Color(0xFFEFF6FF),
                                  child: Text(
                                    u.name.isNotEmpty ? u.name[0] : 'U',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB), fontSize: 14),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(u.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                                      Text(u.email, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(u.role, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                                ),
                                const SizedBox(width: 12),
                                Text(context.l10n.statusActive, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
                              ],
                            ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAuditLogTab() {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final logs = _service.getAuditLogs();
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.securityAuditTrail, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(context.l10n.securityAuditSubtitle, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Responsive Cards for mobile, Table for desktop
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 650) {
                return Column(
                  children: [
                    for (final log in logs)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(log.action, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2563EB))),
                                Text(log.timestamp, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(log.details, style: const TextStyle(fontSize: 12)),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('By: ${log.user}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                                Text(log.ipAddress, style: const TextStyle(fontSize: 10.5, fontFamily: 'monospace', color: AppColors.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              }
              final effectiveWidth = constraints.maxWidth > 650 ? constraints.maxWidth : 650.0;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: effectiveWidth,
                  child: Table(
                    border: TableBorder.all(color: AppColors.border),
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
                        children: [
                          Padding(padding: const EdgeInsets.all(10), child: Text(context.l10n.colTimestamp, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          Padding(padding: const EdgeInsets.all(10), child: Text(context.l10n.colUser, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          Padding(padding: const EdgeInsets.all(10), child: Text(context.l10n.colAction, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          Padding(padding: const EdgeInsets.all(10), child: Text(context.l10n.colDetails, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          Padding(padding: const EdgeInsets.all(10), child: Text(context.l10n.colIpAddress, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        ],
                      ),
                      for (final log in logs)
                        TableRow(
                          children: [
                            Padding(padding: const EdgeInsets.all(10), child: Text(log.timestamp, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary))),
                            Padding(padding: const EdgeInsets.all(10), child: Text(log.user, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
                            Padding(padding: const EdgeInsets.all(10), child: Text(log.action, style: const TextStyle(fontSize: 12, color: Color(0xFF2563EB), fontWeight: FontWeight.w600))),
                            Padding(padding: const EdgeInsets.all(10), child: Text(log.details, style: const TextStyle(fontSize: 12))),
                            Padding(padding: const EdgeInsets.all(10), child: Text(log.ipAddress, style: const TextStyle(fontSize: 11.5, fontFamily: 'monospace'))),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
