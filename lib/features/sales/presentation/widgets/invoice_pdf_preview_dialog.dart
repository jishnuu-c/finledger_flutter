import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/sales_models.dart';

class InvoicePdfPreviewDialog extends StatelessWidget {
  final Invoice invoice;

  const InvoicePdfPreviewDialog({
    super.key,
    required this.invoice,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,##0.00', 'en_US');
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 680;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 32,
        vertical: isMobile ? 16 : 24,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 720, maxHeight: screenHeight * 0.9),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header actions: Title & Print / Close
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.picture_as_pdf_outlined, color: Color(0xFF2563EB), size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Tax Invoice PDF Preview',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Download / Print PDF',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Downloading ${invoice.invoiceNo}.pdf...'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    icon: const Icon(Icons.download_rounded, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const Divider(height: 24, color: AppColors.border),

              // Simulated A4 Tax Invoice Paper Container
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(isMobile ? 12 : 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Company & Document Header
                        if (isMobile) ...[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'BSB Trading LLC',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F1B33)),
                              ),
                              const SizedBox(height: 2),
                              const Text('TRN: 100345678900003', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                              const Text('Al Quoz Industrial Area 3, Dubai, UAE', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              const Text('Email: finance@bsbtrading.ae | Tel: +971 4 345 6789', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFBFDBFE)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'TAX INVOICE',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF2563EB),
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text('Invoice No: ${invoice.invoiceNo}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    Text('Date: ${invoice.invoiceDate}', style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                                    Text('Due Date: ${invoice.dueDate}', style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'BSB Trading LLC',
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F1B33)),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text('TRN: 100345678900003', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                  const Text('Al Quoz Industrial Area 3, Dubai, UAE', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                                  const Text('Email: finance@bsbtrading.ae | Tel: +971 4 345 6789', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'TAX INVOICE',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF2563EB),
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Invoice No: ${invoice.invoiceNo}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text('Date: ${invoice.invoiceDate}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  Text('Due Date: ${invoice.dueDate}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                ],
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 24),
                        const Divider(color: AppColors.borderSubtle),
                        const SizedBox(height: 12),

                        // Bill To Customer Section
                        if (isMobile) ...[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('BILL TO:', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                              const SizedBox(height: 4),
                              Text(invoice.customerName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                              if (invoice.customerTrn != null)
                                Text('TRN: ${invoice.customerTrn}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              if (invoice.customerAddress != null)
                                Text(invoice.customerAddress!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              const SizedBox(height: 12),
                              const Text('PAYMENT TERMS:', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                              const SizedBox(height: 4),
                              Text(invoice.paymentTerms, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              Text('Currency: ${invoice.currencyCode}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                        ] else ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('BILL TO:', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                                  const SizedBox(height: 4),
                                  Text(invoice.customerName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                                  if (invoice.customerTrn != null)
                                    Text('TRN: ${invoice.customerTrn}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  if (invoice.customerAddress != null)
                                    Text(invoice.customerAddress!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('PAYMENT TERMS:', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                                  const SizedBox(height: 4),
                                  Text(invoice.paymentTerms, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                  Text('Currency: ${invoice.currencyCode}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                ],
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 24),

                        // Lines Table
                        LayoutBuilder(
                          builder: (context, constraints) {
                            const minTableWidth = 560.0;
                            final effectiveWidth = constraints.maxWidth < minTableWidth
                                ? minTableWidth
                                : constraints.maxWidth;

                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: effectiveWidth,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.border),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Column(
                                    children: [
                                      // Table Header
                                      Container(
                                        color: const Color(0xFFF8FAFC),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        child: const Row(
                                          children: [
                                            Expanded(flex: 3, child: Text('Item / Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5))),
                                            Expanded(flex: 1, child: Text('Qty', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5))),
                                            Expanded(flex: 2, child: Text('Unit Price', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5))),
                                            Expanded(flex: 1, child: Text('Disc %', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5))),
                                            Expanded(flex: 1, child: Text('Tax', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5))),
                                            Expanded(flex: 2, child: Text('Amount (AED)', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5))),
                                          ],
                                        ),
                                      ),
                                      const Divider(height: 1, color: AppColors.border),

                                      // Table Rows
                                      for (final line in invoice.lines)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(line.description, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                                    Text(line.itemCode, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                                                  ],
                                                ),
                                              ),
                                              Expanded(flex: 1, child: Text(line.quantity.toStringAsFixed(0), textAlign: TextAlign.right, style: const TextStyle(fontSize: 12))),
                                              Expanded(flex: 2, child: Text(currencyFormatter.format(line.unitPrice), textAlign: TextAlign.right, style: const TextStyle(fontSize: 12))),
                                              Expanded(flex: 1, child: Text('${line.discountPct.toStringAsFixed(0)}%', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12))),
                                              Expanded(flex: 1, child: Text('${line.taxRatePct.toStringAsFixed(0)}%', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12))),
                                              Expanded(flex: 2, child: Text(currencyFormatter.format(line.lineTotal), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // Totals Summary & Notes
                        if (isMobile) ...[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.borderSubtle),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Notes & Bank Details:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                                    const SizedBox(height: 4),
                                    Text(
                                      invoice.notes ?? 'Thank you for your business. Bank: Emirates NBD, IBAN AE07 0260 ...',
                                      style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Column(
                                children: [
                                  _buildPdfTotalRow('Subtotal', currencyFormatter.format(invoice.subtotal)),
                                  _buildPdfTotalRow('Discount', currencyFormatter.format(invoice.discountTotal)),
                                  _buildPdfTotalRow('VAT (5%)', currencyFormatter.format(invoice.taxTotal)),
                                  const Divider(height: 12, color: AppColors.border),
                                  _buildPdfTotalRow('Total (AED)', currencyFormatter.format(invoice.total), isBold: true),
                                ],
                              ),
                            ],
                          ),
                        ] else ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 5,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.borderSubtle),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Notes & Bank Details:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                                      const SizedBox(height: 4),
                                      Text(
                                        invoice.notes ?? 'Thank you for your business. Bank: Emirates NBD, IBAN AE07 0260 ...',
                                        style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                flex: 4,
                                child: Column(
                                  children: [
                                    _buildPdfTotalRow('Subtotal', currencyFormatter.format(invoice.subtotal)),
                                    _buildPdfTotalRow('Discount', currencyFormatter.format(invoice.discountTotal)),
                                    _buildPdfTotalRow('VAT (5%)', currencyFormatter.format(invoice.taxTotal)),
                                    const Divider(height: 12, color: AppColors.border),
                                    _buildPdfTotalRow('Total (AED)', currencyFormatter.format(invoice.total), isBold: true),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Close Action
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close Preview'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPdfTotalRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isBold ? 13 : 12,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: isBold ? AppColors.textPrimary : AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 14 : 12.5,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
              color: isBold ? const Color(0xFF2563EB) : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
