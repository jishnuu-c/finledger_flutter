import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/api/dio_client.dart';
import '../data/models/account_model.dart';
import '../data/models/journal_entry_model.dart';
import '../data/services/accounting_service.dart';

class NewJournalEntryScreen extends StatefulWidget {
  const NewJournalEntryScreen({super.key});

  @override
  State<NewJournalEntryScreen> createState() => _NewJournalEntryScreenState();
}

class _LineFormState {
  int lineNo;
  int? accountId;
  String accountCode;
  String accountName;
  TextEditingController descriptionController;
  TextEditingController costCenterController;
  TextEditingController debitController;
  TextEditingController creditController;

  _LineFormState({
    required this.lineNo,
    this.accountId,
    this.accountCode = '',
    this.accountName = '',
    String description = '',
    String costCenter = '',
    double debit = 0.0,
    double credit = 0.0,
  }) : descriptionController = TextEditingController(text: description),
       costCenterController = TextEditingController(text: costCenter),
       debitController = TextEditingController(
         text: debit > 0 ? debit.toStringAsFixed(2) : '',
       ),
       creditController = TextEditingController(
         text: credit > 0 ? credit.toStringAsFixed(2) : '',
       );

  double get debit =>
      double.tryParse(debitController.text.replaceAll(',', '')) ?? 0.0;
  double get credit =>
      double.tryParse(creditController.text.replaceAll(',', '')) ?? 0.0;

  void dispose() {
    descriptionController.dispose();
    costCenterController.dispose();
    debitController.dispose();
    creditController.dispose();
  }
}

class _NewJournalEntryScreenState extends State<NewJournalEntryScreen> {
  late final AccountingService _accountingService;
  final _formKey = GlobalKey<FormState>();

  late String _entryNo;
  DateTime _entryDate = DateTime.now();
  final TextEditingController _referenceController = TextEditingController(
    text: 'Accrual – Oct rent',
  );
  final TextEditingController _narrationController = TextEditingController(
    text: 'Monthly accrual of warehouse rent for October 2026',
  );
  String _selectedCurrency = 'AED';

  List<Account> _postingAccounts = [];
  final List<_LineFormState> _lines = [];
  bool _isLoading = true;
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    final dioClient = context.read<DioClient>();
    _accountingService = AccountingService(dioClient: dioClient);
    _entryNo = _accountingService.getNextEntryNumber();
    _loadAccountsAndInitLines();
  }

  Future<void> _loadAccountsAndInitLines() async {
    setState(() => _isLoading = true);
    final accounts = await _accountingService.getPostingAccounts();

    if (mounted) {
      setState(() {
        _postingAccounts = accounts;
        _isLoading = false;

        // Initialize 2 default lines matching Figure 14:
        // Line 1: 5210 - Rent Expense, Debit 25000.00
        // Line 2: 2300 - Accrued Expenses, Credit 25000.00
        final rentAcc = accounts.firstWhere(
          (a) => a.code == '5210',
          orElse: () => accounts.isNotEmpty
              ? accounts.first
              : const Account(
                  id: 15,
                  code: '5210',
                  name: 'Rent Expense',
                  accountType: AccountType.expense,
                  isGroup: false,
                  currentBalance: 0,
                ),
        );
        final accruedAcc = accounts.firstWhere(
          (a) => a.code == '2300',
          orElse: () => accounts.length > 1 ? accounts[1] : rentAcc,
        );

        _lines.clear();
        _lines.add(
          _LineFormState(
            lineNo: 1,
            accountId: rentAcc.id,
            accountCode: rentAcc.code,
            accountName: rentAcc.name,
            description: 'Warehouse rent Oct',
            costCenter: 'Dubai WH',
            debit: 25000.00,
            credit: 0.0,
          ),
        );
        _lines.add(
          _LineFormState(
            lineNo: 2,
            accountId: accruedAcc.id,
            accountCode: accruedAcc.code,
            accountName: accruedAcc.name,
            description: 'Accrued rent',
            costCenter: 'Dubai WH',
            debit: 0.0,
            credit: 25000.00,
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _narrationController.dispose();
    for (final l in _lines) {
      l.dispose();
    }
    super.dispose();
  }

  double get _totalDebit => _lines.fold<double>(0.0, (sum, l) => sum + l.debit);
  double get _totalCredit =>
      _lines.fold<double>(0.0, (sum, l) => sum + l.credit);
  bool get _isBalanced =>
      (_totalDebit - _totalCredit).abs() < 0.001 && _totalDebit > 0;
  bool get _canPost => _isBalanced && _lines.length >= 2;

  void _addLine() {
    setState(() {
      final defaultAcc = _postingAccounts.isNotEmpty
          ? _postingAccounts.first
          : null;
      _lines.add(
        _LineFormState(
          lineNo: _lines.length + 1,
          accountId: defaultAcc?.id,
          accountCode: defaultAcc?.code ?? '',
          accountName: defaultAcc?.name ?? '',
        ),
      );
    });
  }

  void _removeLine(int index) {
    if (_lines.length <= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'A double-entry journal entry requires a minimum of 2 lines.',
          ),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      final removed = _lines.removeAt(index);
      removed.dispose();
      for (int i = 0; i < _lines.length; i++) {
        _lines[i].lineNo = i + 1;
      }
    });
  }

  Future<void> _handlePostEntry() async {
    if (!_canPost) return;

    setState(() => _isPosting = true);

    try {
      final dateFormat = DateFormat('dd-MMM-yyyy');
      final linesData = _lines.map((l) {
        return JournalLine(
          lineNo: l.lineNo,
          accountId: l.accountId ?? 0,
          accountCode: l.accountCode,
          accountName: l.accountName,
          description: l.descriptionController.text.trim(),
          costCenter: l.costCenterController.text.trim(),
          debit: l.debit,
          credit: l.credit,
        );
      }).toList();

      final entry = await _accountingService.postJournalEntry(
        entryDate: dateFormat.format(_entryDate),
        reference: _referenceController.text.trim(),
        narration: _narrationController.text.trim(),
        currencyCode: _selectedCurrency,
        lines: linesData,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Journal Entry ${entry.entryNo} posted successfully! Total: AED ${_totalDebit.toStringAsFixed(2)}',
            ),
            backgroundColor: AppColors.paid,
          ),
        );
        context.go('/accounting/journals');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post entry: $e'),
            backgroundColor: AppColors.overdue,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  Future<void> _handleSaveDraft() async {
    setState(() => _isPosting = true);

    try {
      final dateFormat = DateFormat('dd-MMM-yyyy');
      final linesData = _lines.map((l) {
        return JournalLine(
          lineNo: l.lineNo,
          accountId: l.accountId ?? 0,
          accountCode: l.accountCode,
          accountName: l.accountName,
          description: l.descriptionController.text.trim(),
          costCenter: l.costCenterController.text.trim(),
          debit: l.debit,
          credit: l.credit,
        );
      }).toList();

      final entry = await _accountingService.createJournalDraft(
        entryDate: dateFormat.format(_entryDate),
        reference: _referenceController.text.trim(),
        narration: _narrationController.text.trim(),
        currencyCode: _selectedCurrency,
        lines: linesData,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Draft Journal Entry ${entry.entryNo} saved successfully.',
            ),
            backgroundColor: AppColors.primary,
          ),
        );
        context.go('/accounting/journals');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save draft: $e'),
            backgroundColor: AppColors.overdue,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final currencyFormatter = NumberFormat('#,##0.00', 'en_US');

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumbs & Header matching Figure 14
            _buildHeader(),
            const SizedBox(height: 18),

            // Top Card: Header Fields (Entry No, Date, Reference, Currency, Narration)
            _buildHeaderCard(),
            const SizedBox(height: 20),

            // Lines Grid Card matching Figure 14
            _buildLinesGridCard(currencyFormatter),
            const SizedBox(height: 20),

            // Bottom Actions & Balance Status Indicator matching Figure 14
            _buildBottomBar(currencyFormatter),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: const [
            Text(
              'Accounting',
              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
            SizedBox(width: 4),
            Text('/', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
            SizedBox(width: 4),
            Text(
              'Journal Entries',
              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
            SizedBox(width: 4),
            Text('/', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
            SizedBox(width: 4),
            Text(
              'New',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF475569),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'New Journal Entry',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCard() {
    final dateFormat = DateFormat('dd-MMM-yyyy');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Entry No, Date, Reference, Currency
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              final isMedium = constraints.maxWidth >= 550;
              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: _buildEntryNoField()),
                    const SizedBox(width: 14),
                    Expanded(child: _buildDateField(dateFormat)),
                    const SizedBox(width: 14),
                    Expanded(child: _buildReferenceField()),
                    const SizedBox(width: 14),
                    Expanded(child: _buildCurrencyField()),
                  ],
                );
              } else if (isMedium) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildEntryNoField()),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDateField(dateFormat)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildReferenceField()),
                        const SizedBox(width: 12),
                        Expanded(child: _buildCurrencyField()),
                      ],
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildEntryNoField(),
                    const SizedBox(height: 12),
                    _buildDateField(dateFormat),
                    const SizedBox(height: 12),
                    _buildReferenceField(),
                    const SizedBox(height: 12),
                    _buildCurrencyField(),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 16),

          // Row 2: Narration
          const Text(
            'Narration',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _narrationController,
            maxLines: 2,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText:
                  'Enter complete business description for general ledger auditing...',
              fillColor: const Color(0xFFF8FAFC),
              filled: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryNoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Entry No.',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: Text(
            '$_entryNo (auto)',
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(DateFormat dateFormat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date *',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _entryDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (picked != null) setState(() => _entryDate = picked);
          },
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateFormat.format(_entryDate),
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: Color(0xFF64748B),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReferenceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reference',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 38,
          child: TextFormField(
            controller: _referenceController,
            style: const TextStyle(fontSize: 12.5),
            decoration: InputDecoration(
              hintText: 'e.g. Accrual - Oct rent',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 0,
              ),
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Currency',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCurrency,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w500,
              ),
              isExpanded: true,
              icon: const Icon(
                Icons.arrow_drop_down,
                size: 18,
                color: Color(0xFF64748B),
              ),
              items: [
                'AED',
                'USD',
                'EUR',
                'GBP',
              ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCurrency = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLinesGridCard(NumberFormat currencyFormatter) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final effectiveWidth = constraints.maxWidth > 780
              ? constraints.maxWidth
              : 780.0;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: effectiveWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(9),
                      ),
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(
                          width: 32,
                          child: Text(
                            '#',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Account *',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Cost Center',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        SizedBox(
                          width: 110,
                          child: Text(
                            'Debit',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        SizedBox(
                          width: 110,
                          child: Text(
                            'Credit',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                        SizedBox(width: 38),
                      ],
                    ),
                  ),

                  // Lines List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _lines.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    itemBuilder: (context, index) {
                      final line = _lines[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            // Line number
                            SizedBox(
                              width: 32,
                              child: Text(
                                '${line.lineNo}',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),

                            // Account picker (excluding group accounts)
                            Expanded(
                              flex: 3,
                              child: Container(
                                height: 36,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(0xFFCBD5E1),
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: line.accountId,
                                    isExpanded: true,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: Color(0xFF0F172A),
                                    ),
                                    hint: const Text(
                                      'Select Account',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.arrow_drop_down,
                                      size: 18,
                                      color: Color(0xFF64748B),
                                    ),
                                    items: _postingAccounts.map((a) {
                                      return DropdownMenuItem<int>(
                                        value: a.id,
                                        child: Text(
                                          '${a.code} – ${a.name}',
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        final selected = _postingAccounts
                                            .firstWhere((a) => a.id == val);
                                        setState(() {
                                          line.accountId = selected.id;
                                          line.accountCode = selected.code;
                                          line.accountName = selected.name;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Description Memo
                            Expanded(
                              flex: 3,
                              child: SizedBox(
                                height: 36,
                                child: TextFormField(
                                  controller: line.descriptionController,
                                  style: const TextStyle(fontSize: 12.5),
                                  decoration: InputDecoration(
                                    hintText: 'Memo description',
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 0,
                                    ),
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFCBD5E1),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFCBD5E1),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Cost Center
                            Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: 36,
                                child: TextFormField(
                                  controller: line.costCenterController,
                                  style: const TextStyle(fontSize: 12.5),
                                  decoration: InputDecoration(
                                    hintText: 'e.g. Dubai WH',
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 0,
                                    ),
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFCBD5E1),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFCBD5E1),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Debit Input
                            SizedBox(
                              width: 110,
                              height: 36,
                              child: TextFormField(
                                controller: line.debitController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  hintText: '0.00',
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 0,
                                  ),
                                  fillColor: line.credit > 0
                                      ? const Color(0xFFF1F5F9)
                                      : Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFCBD5E1),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFCBD5E1),
                                    ),
                                  ),
                                ),
                                onChanged: (val) {
                                  // Validation rule: Debit or Credit, not both
                                  if (val.trim().isNotEmpty &&
                                      double.tryParse(val) != null &&
                                      double.parse(val) > 0) {
                                    if (line.creditController.text.isNotEmpty) {
                                      line.creditController.clear();
                                    }
                                  }
                                  setState(() {});
                                },
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Credit Input
                            SizedBox(
                              width: 110,
                              height: 36,
                              child: TextFormField(
                                controller: line.creditController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  hintText: '0.00',
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 0,
                                  ),
                                  fillColor: line.debit > 0
                                      ? const Color(0xFFF1F5F9)
                                      : Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFCBD5E1),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFCBD5E1),
                                    ),
                                  ),
                                ),
                                onChanged: (val) {
                                  // Validation rule: Debit or Credit, not both
                                  if (val.trim().isNotEmpty &&
                                      double.tryParse(val) != null &&
                                      double.parse(val) > 0) {
                                    if (line.debitController.text.isNotEmpty) {
                                      line.debitController.clear();
                                    }
                                  }
                                  setState(() {});
                                },
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Delete line action
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                size: 16,
                                color: Color(0xFFEF4444),
                              ),
                              tooltip: 'Remove line',
                              onPressed: () => _removeLine(index),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Add Line Action Link matching Figure 14
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: InkWell(
                      onTap: _addLine,
                      borderRadius: BorderRadius.circular(4),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, size: 16, color: Color(0xFF2563EB)),
                            SizedBox(width: 4),
                            Text(
                              '+ Add line',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Divider(height: 1, color: Color(0xFFE2E8F0)),

                  // Totals Row matching Figure 14
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    color: const Color(0xFFF8FAFC),
                    child: Row(
                      children: [
                        const Spacer(),
                        const Text(
                          'Totals',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 40),
                        SizedBox(
                          width: 110,
                          child: Text(
                            currencyFormatter.format(_totalDebit),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 110,
                          child: Text(
                            currencyFormatter.format(_totalCredit),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        const SizedBox(width: 38),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomBar(NumberFormat currencyFormatter) {
    final diff = (_totalDebit - _totalCredit).abs();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Balance Status Badge matching Figure 14
            if (_isBalanced)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7), // Light green
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, size: 15, color: Color(0xFF16A34A)),
                      SizedBox(width: 6),
                      Text(
                        '✓ Balanced — Debits equal Credits',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (_totalDebit > 0 || _totalCredit > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2), // Light red
                  borderRadius: BorderRadius.circular(20),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.close,
                        size: 15,
                        color: Color(0xFFDC2626),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Out of balance by AED ${currencyFormatter.format(diff)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Enter Debit and Credit amounts',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () => context.go('/accounting/journals'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF334155),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: _isPosting ? null : _handleSaveDraft,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF334155),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  child: const Text(
                    'Save as Draft',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: (_canPost && !_isPosting)
                      ? _handlePostEntry
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D4ED8),
                    disabledBackgroundColor: const Color(0xFF93C5FD),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                  ),
                  child: _isPosting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Post Entry',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
