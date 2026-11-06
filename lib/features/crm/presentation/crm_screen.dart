import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CrmScreen extends StatelessWidget {
  const CrmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Controls
          _buildHeader(context, isMobile),
          const SizedBox(height: 20),

          // KPI Strip
          _buildKpiStrip(),
          const SizedBox(height: 24),

          // Kanban Board Stages
          _buildKanbanBoard(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sales Pipeline & CRM',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Lead-to-Cash progression: Opportunity stages, deal values, and weighted forecasts',
            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.file_upload_outlined, size: 16),
                label: const Text('Import Leads'),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 16),
                label: const Text('+ New Opportunity'),
              ),
            ],
          ),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sales Pipeline & CRM',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Lead-to-Cash progression: Opportunity stages, deal values, and weighted forecasts',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.file_upload_outlined, size: 16),
              label: const Text('Import Leads'),
            ),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 16),
              label: const Text('+ New Opportunity'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiStrip() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 650),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _CrmKpiItem(title: 'OPEN PIPELINE', value: 'AED 640,000', subtitle: '18 active deals'),
              _CrmDivider(),
              _CrmKpiItem(title: 'WEIGHTED FORECAST', value: 'AED 412,500', subtitle: 'Probability-adjusted'),
              _CrmDivider(),
              _CrmKpiItem(title: 'WON THIS QUARTER', value: 'AED 895,000', subtitle: '12 closed deals'),
              _CrmDivider(),
              _CrmKpiItem(title: 'WIN RATE', value: '64.8%', subtitle: '+5.2% vs last quarter'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKanbanBoard(BuildContext context) {
    final columns = [
      {
        'title': 'New Leads',
        'count': '4',
        'total': 'AED 110,000',
        'deals': [
          {'name': 'Fleet GPS Telematics Contract', 'client': 'Emirates Post Group', 'val': 'AED 65,000', 'owner': 'Tariq M.', 'date': '15-Nov-2026'},
          {'name': 'ERP Integration Consultation', 'client': 'Danube Building Materials', 'val': 'AED 45,000', 'owner': 'Sara K.', 'date': '20-Nov-2026'},
        ],
      },
      {
        'title': 'Qualified / Scoping',
        'count': '3',
        'total': 'AED 195,000',
        'deals': [
          {'name': 'Warehouse Steel Racking Supply', 'client': 'Al Shaya Logistics', 'val': 'AED 120,000', 'owner': 'Ahmed H.', 'date': '28-Nov-2026'},
          {'name': 'Annual Spares & Consumables', 'client': 'Damas Jewellery LLC', 'val': 'AED 75,000', 'owner': 'Tariq M.', 'date': '05-Dec-2026'},
        ],
      },
      {
        'title': 'Quotation Sent',
        'count': '4',
        'total': 'AED 240,000',
        'deals': [
          {'name': 'Heavy Diesel Generators (x2)', 'client': 'Arabian Construction Co', 'val': 'AED 180,000', 'owner': 'Ahmed H.', 'date': '10-Nov-2026'},
          {'name': 'HVAC Filter Replacements', 'client': 'Rotana Hotel Group', 'val': 'AED 60,000', 'owner': 'Sara K.', 'date': '18-Nov-2026'},
        ],
      },
      {
        'title': 'Negotiation',
        'count': '2',
        'total': 'AED 95,000',
        'deals': [
          {'name': 'Facility Security Access System', 'client': 'Sobha Realty', 'val': 'AED 95,000', 'owner': 'Tariq M.', 'date': '08-Nov-2026'},
        ],
      },
      {
        'title': 'Won / Converted',
        'count': '5',
        'total': 'AED 385,000',
        'deals': [
          {'name': 'Industrial Solar Inverters', 'client': 'Emaar Properties PJSC', 'val': 'AED 220,000', 'owner': 'Ahmed H.', 'date': '26-Oct-2026'},
          {'name': 'Bulk Office IT Hardware', 'client': 'Gulf Finance House', 'val': 'AED 165,000', 'owner': 'Sara K.', 'date': '24-Oct-2026'},
        ],
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: columns.map((col) {
          final deals = col['deals'] as List<Map<String, String>>;
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Column Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        col['title'] as String,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        col['count'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  col['total'] as String,
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                // Deal Cards
                for (final d in deals)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d['name']!,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          d['client']!,
                          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                d['val']!,
                                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 12.5),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              d['date']!,
                              style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 8,
                              backgroundColor: AppColors.primarySurface,
                              child: Text('U', style: TextStyle(fontSize: 8, color: AppColors.primary)),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                d['owner']!,
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CrmKpiItem extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _CrmKpiItem({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _CrmDivider extends StatelessWidget {
  const _CrmDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      width: 1,
      color: AppColors.border,
    );
  }
}
