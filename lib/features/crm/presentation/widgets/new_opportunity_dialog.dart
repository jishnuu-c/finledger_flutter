import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/crm_models.dart';

class NewOpportunityDialog extends StatefulWidget {
  final List<String> stages;

  const NewOpportunityDialog({
    super.key,
    required this.stages,
  });

  @override
  State<NewOpportunityDialog> createState() => _NewOpportunityDialogState();
}

class _NewOpportunityDialogState extends State<NewOpportunityDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _customerController = TextEditingController();
  final _valueController = TextEditingController(text: '75000');
  final _closeDateController = TextEditingController(text: '15-Dec');

  String _stage = 'New';
  String _owner = 'Raj';
  int _probability = 30;

  @override
  void initState() {
    super.initState();
    if (widget.stages.isNotEmpty && !widget.stages.contains(_stage)) {
      _stage = widget.stages.first;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _customerController.dispose();
    _valueController.dispose();
    _closeDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 32,
        vertical: isMobile ? 16 : 24,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 500, maxHeight: screenHeight * 0.9),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Create New Opportunity',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                // Deal Title
                const Text('Deal / Opportunity Title *', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _titleController,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a deal title' : null,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Commercial Air Purifier Rollout',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 12),

                // Organization / Customer
                const Text('Prospect / Customer Name *', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _customerController,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter customer name' : null,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Al Futtaim Group',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 12),

                // Expected Value & Probability
                if (isMobile) ...[
                  const Text('Expected Value (AED) *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: _valueController,
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || double.tryParse(v) == null) ? 'Invalid amount' : null,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Win Probability: $_probability%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  Slider(
                    value: _probability.toDouble(),
                    min: 10,
                    max: 100,
                    divisions: 9,
                    label: '$_probability%',
                    onChanged: (v) => setState(() => _probability = v.round()),
                  ),
                  const SizedBox(height: 12),
                  const Text('Initial Stage', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _stage,
                    items: widget.stages
                        .where((s) => s != 'Won' && s != 'Lost')
                        .map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _stage = v);
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Sales Owner', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _owner,
                    items: const [
                      DropdownMenuItem(value: 'Raj', child: Text('Raj')),
                      DropdownMenuItem(value: 'Sara', child: Text('Sara')),
                      DropdownMenuItem(value: 'Ahmed', child: Text('Ahmed')),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _owner = v);
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Expected Value (AED) *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            TextFormField(
                              controller: _valueController,
                              keyboardType: TextInputType.number,
                              validator: (v) => (v == null || double.tryParse(v) == null) ? 'Invalid amount' : null,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Win Probability: $_probability%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            Slider(
                              value: _probability.toDouble(),
                              min: 10,
                              max: 100,
                              divisions: 9,
                              label: '$_probability%',
                              onChanged: (v) => setState(() => _probability = v.round()),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Stage & Owner
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Initial Stage', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: _stage,
                              items: widget.stages
                                  .where((s) => s != 'Won' && s != 'Lost')
                                  .map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis)))
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) setState(() => _stage = v);
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Sales Owner', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: _owner,
                              items: const [
                                DropdownMenuItem(value: 'Raj', child: Text('Raj')),
                                DropdownMenuItem(value: 'Sara', child: Text('Sara')),
                                DropdownMenuItem(value: 'Ahmed', child: Text('Ahmed')),
                              ],
                              onChanged: (v) {
                                if (v != null) setState(() => _owner = v);
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),

                // Close Date
                const Text('Expected Close (e.g. 15-Dec)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _closeDateController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 24),

                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final opp = Opportunity(
                            id: 0,
                            opportunityNo: '',
                            title: _titleController.text.trim(),
                            customerName: _customerController.text.trim(),
                            stage: _stage,
                            stageId: 1,
                            expectedValue: double.parse(_valueController.text.trim()),
                            probabilityPct: _probability,
                            expectedCloseDate: _closeDateController.text.trim(),
                            ownerName: _owner,
                          );
                          Navigator.of(context).pop(opp);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text('Create Deal'),
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
}
