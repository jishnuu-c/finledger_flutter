import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
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

  final List<Map<String, dynamic>> _tabs = [
    {'id': 'profile', 'label': 'Company Profile', 'icon': Icons.business_outlined},
    {'id': 'fiscal_years', 'label': 'Fiscal Years', 'icon': Icons.calendar_month_outlined},
    {'id': 'tax_rates', 'label': 'Tax Rates', 'icon': Icons.percent_outlined},
    {'id': 'currencies', 'label': 'Currencies', 'icon': Icons.monetization_on_outlined},
    {'id': 'number_series', 'label': 'Number Series', 'icon': Icons.pin_outlined},
    {'id': 'users_roles', 'label': 'Users & Roles', 'icon': Icons.people_alt_outlined},
    {'id': 'audit_log', 'label': 'Audit Log', 'icon': Icons.history_outlined},
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
          const SnackBar(
            content: Text('Company profile updated successfully'),
            backgroundColor: Color(0xFF16A34A),
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
      const SnackBar(
        content: Text('Company logo uploaded successfully'),
        backgroundColor: Color(0xFF16A34A),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleRemoveLogo() {
    setState(() {
      _logoUrl = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Company logo removed'),
        backgroundColor: Color(0xFF64748B),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final activeTabObj = _tabs.firstWhere(
      (t) => t['id'] == _activeTab,
      orElse: () => _tabs.first,
    );

    final isMobile = MediaQuery.of(context).size.width < 768;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
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
                      const Text('Settings', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 4),
                      const Text('/', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      const SizedBox(width: 4),
                      Text(
                        activeTabObj['label'] as String,
                        style: TextStyle(fontSize: 12, color: Colors.blue.shade700, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Company & System Settings',
                    style: TextStyle(
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
                  icon: const Icon(Icons.save_outlined, size: 16),
                  label: const Text('Save Changes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

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
                      child: _buildVerticalSubNav(),
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
                        children: _tabs.map((tab) {
                          final isSelected = tab['id'] == _activeTab;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(tab['label'] as String),
                              selected: isSelected,
                              onSelected: (_) => setState(() => _activeTab = tab['id'] as String),
                              selectedColor: const Color(0xFF2563EB),
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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

  Widget _buildVerticalSubNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: _tabs.map((tab) {
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
            const Text(
              'Company Profile & Legal Entity',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Primary trading entity information for official invoice headers, receipts, and UAE tax reports',
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
                    _buildFieldLabel('Company Legal Name *'),
                    TextFormField(
                      controller: _nameController,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildFieldLabel('Tax Registration Number (TRN) *'),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _trnController,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Required';
                              if (v.trim().length != 15) return 'UAE TRN must be 15 digits';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.verified, size: 14, color: Color(0xFF166534)),
                              SizedBox(width: 4),
                              Text(
                                'FTA Active',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildFieldLabel('Trade License / Commercial Reg *'),
                    TextFormField(controller: _tradeLicenseController),
                    const SizedBox(height: 16),

                    _buildFieldLabel('Corporate Tax TRN'),
                    TextFormField(controller: _corporateTaxTrnController),
                    const SizedBox(height: 16),

                    _buildFieldLabel('Registered Address *'),
                    TextFormField(
                      controller: _addressController,
                      maxLines: 2,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                  ],
                );

                final rightColumn = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Emirate *'),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedEmirate,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'Dubai', child: Text('Dubai')),
                        DropdownMenuItem(value: 'Abu Dhabi', child: Text('Abu Dhabi')),
                        DropdownMenuItem(value: 'Sharjah', child: Text('Sharjah')),
                        DropdownMenuItem(value: 'Ajman', child: Text('Ajman')),
                        DropdownMenuItem(value: 'Ras Al Khaimah', child: Text('Ras Al Khaimah')),
                        DropdownMenuItem(value: 'Fujairah', child: Text('Fujairah')),
                        DropdownMenuItem(value: 'Umm Al Quwain', child: Text('Umm Al Quwain')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedEmirate = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildFieldLabel('Primary Email *'),
                    TextFormField(
                      controller: _emailController,
                      validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildFieldLabel('Phone Number *'),
                    TextFormField(controller: _phoneController),
                    const SizedBox(height: 16),

                    _buildFieldLabel('Website'),
                    TextFormField(controller: _websiteController),
                    const SizedBox(height: 16),

                    _buildFieldLabel('Functional Base Currency *'),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCurrency,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(
                          value: 'AED - United Arab Emirates Dirham',
                          child: Text('AED - United Arab Emirates Dirham'),
                        ),
                        DropdownMenuItem(
                          value: 'USD - US Dollar',
                          child: Text('USD - US Dollar'),
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
                  child: const Text('Reset'),
                ),
                ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Save Changes'),
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
            const Text(
              'Company Logo',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 2),
            const Text(
              'Displayed on printed tax invoices, quotations, customer receipts, and financial reports. Recommended size: 300x100px. PNG, JPG or SVG format.',
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
                  label: const Text('Upload New Logo', style: TextStyle(fontSize: 12)),
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
                    child: const Text('Remove Logo', style: TextStyle(fontSize: 12)),
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
          const Text('Fiscal Years & Period Locking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Configure accounting financial periods and book closure cutoffs', style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
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
            child: const Row(
              children: [
                Icon(Icons.lock_outline, color: Color(0xFFB45309), size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Books Locked Prior to: 31-Dec-2025',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                      ),
                      Text(
                        'General Ledger journal vouchers and invoices dated on or prior to this date cannot be modified or deleted without financial controller clearance.',
                        style: TextStyle(fontSize: 11.5, color: Color(0xFF92400E)),
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
                                y.isOpen ? 'Open' : 'Closed',
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
                      const TableRow(
                        decoration: BoxDecoration(color: Color(0xFFF8FAFC)),
                        children: [
                          Padding(padding: EdgeInsets.all(10), child: Text('Fiscal Year', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          Padding(padding: EdgeInsets.all(10), child: Text('Start Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          Padding(padding: EdgeInsets.all(10), child: Text('End Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          Padding(padding: EdgeInsets.all(10), child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
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
                                      y.isOpen ? 'Open (Current)' : 'Closed',
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
          const Text('UAE FTA VAT Rates & Regulations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Federal Tax Authority (FTA) statutory rates for VAT 201 return reporting', style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
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
                    const Text('Currencies & Exchange Rates', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text(
                      'Multi-currency conversion rates with AED functional base currency',
                      style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Central Bank of the UAE exchange rates synced'),
                            backgroundColor: Color(0xFF16A34A),
                          ),
                        );
                      },
                      icon: const Icon(Icons.sync, size: 14),
                      label: const Text('Update Rates'),
                    ),
                  ],
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Currencies & Exchange Rates', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Multi-currency conversion rates with AED functional base currency', style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Central Bank of the UAE exchange rates synced'),
                          backgroundColor: Color(0xFF16A34A),
                        ),
                      );
                    },
                    icon: const Icon(Icons.sync, size: 14),
                    label: const Text('Update Rates'),
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
                                    c.isBase ? 'Base' : 'Active',
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
                      const TableRow(
                        decoration: BoxDecoration(color: Color(0xFFF8FAFC)),
                        children: [
                          Padding(padding: EdgeInsets.all(10), child: Text('Currency', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          Padding(padding: EdgeInsets.all(10), child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          Padding(padding: EdgeInsets.all(10), child: Text('Rate (to 1.00 AED)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          Padding(padding: EdgeInsets.all(10), child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
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
                                      c.isBase ? 'Base Currency' : 'Active Rate',
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
          const Text('Document Number Series', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Sequential numbering patterns and prefixes across all modules', style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
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
                      const TableRow(
                        decoration: BoxDecoration(color: Color(0xFFF8FAFC)),
                        children: [
                          Padding(padding: EdgeInsets.all(10), child: Text('Document Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          Padding(padding: EdgeInsets.all(10), child: Text('Prefix', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          Padding(padding: EdgeInsets.all(10), child: Text('Next Sequential', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          Padding(padding: EdgeInsets.all(10), child: Text('Sample Document Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
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
                    const Text('Users & Role-Based Permissions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text(
                      'Manage authorized users, segregation of duties, and module rights',
                      style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.person_add_outlined, size: 14),
                      label: const Text('+ Invite User'),
                    ),
                  ],
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Users & Role-Based Permissions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Manage authorized users, segregation of duties, and module rights', style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.person_add_outlined, size: 14),
                    label: const Text('+ Invite User'),
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
                                            child: const Text('Active', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
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
                                const Text('Active', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
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
          const Text('Security & Audit Log Trail', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Immutable chronological trace of user operations and system posts', style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
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
                      const TableRow(
                        decoration: BoxDecoration(color: Color(0xFFF8FAFC)),
                        children: [
                          Padding(padding: EdgeInsets.all(10), child: Text('Timestamp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          Padding(padding: EdgeInsets.all(10), child: Text('User', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          Padding(padding: EdgeInsets.all(10), child: Text('Action', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          Padding(padding: EdgeInsets.all(10), child: Text('Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          Padding(padding: EdgeInsets.all(10), child: Text('IP Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
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
