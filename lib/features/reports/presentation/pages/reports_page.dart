import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:leakuku/core/theme/app_colors.dart';
import 'package:leakuku/features/reports/data/models/report_export_payload.dart';
import 'package:leakuku/features/reports/presentation/pages/business_analytics_page.dart';
import 'package:leakuku/features/reports/presentation/pages/feed_analytics_page.dart';
import 'package:leakuku/features/reports/presentation/pages/health_analytics_page.dart';
import 'package:leakuku/features/reports/presentation/pages/performance_page.dart';
import 'package:leakuku/features/reports/presentation/pages/read_only_report_page.dart';
import 'package:leakuku/features/reports/presentation/pages/sumamry_detail_page.dart';
import 'package:leakuku/features/reports/presentation/widgets/business/report_card.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart' as pdf_core;
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  final ReportFilter _selectedFilter = ReportFilter.thisMonth;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReportNavigationCard(
            title: 'Farm Summary',
            description:
                'Quick financial and production snapshot for your selected period.',
            icon: FontAwesomeIcons.seedling,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      FarmSummaryDetailPage(filter: _selectedFilter),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          ReportNavigationCard(
            title: 'Flock Performance',
            description:
                'Growth trends, production quality, and performance comparisons.',
            icon: FontAwesomeIcons.chartLine,
            onTap: () => _openReportPage(
              context,
              title: 'Flock Performance',
            ),
          ),
          const SizedBox(height: 10),
          ReportNavigationCard(
            title: 'Feed Analytics',
            description:
                'Feed consumption efficiency and stock movement insights.',
            icon: FontAwesomeIcons.bowlFood,
            onTap: () => _openReportPage(
              context,
              title: 'Feed Analytics',
            ),
          ),
          const SizedBox(height: 10),
          ReportNavigationCard(
            title: 'Health Analytics',
            description:
                'Mortality, vaccination, and flock health outcome patterns.',
            icon: FontAwesomeIcons.heartPulse,
            onTap: () => _openReportPage(
              context,
              title: 'Health Analytics',
            ),
          ),
          const SizedBox(height: 10),
          ReportNavigationCard(
            title: 'Business Analytics',
            description:
                'Operational performance and profitability reporting tools.',
            icon: FontAwesomeIcons.sackDollar,
            onTap: () => _openReportPage(
              context,
              title: 'Business Analytics',
            ),
          ),
        ],
      ),
    );
  }

  void _openReportPage(BuildContext context, {required String title}) {
    if (title == 'Flock Performance') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PerformancePage(initialFilter: _selectedFilter),
        ),
      );
      return;
    }

    if (title == 'Feed Analytics') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => FeedAnalyticsPage(initialFilter: _selectedFilter),
        ),
      );
      return;
    }

    if (title == 'Health Analytics') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => HealthAnalyticsPage(initialFilter: _selectedFilter),
        ),
      );
      return;
    }

    if (title == 'Business Analytics') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BusinessAnalyticsPage(initialFilter: _selectedFilter),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReadOnlyReportPage(title: title),
      ),
    );
  }
}

enum ReportFilter {
  today,
  thisWeek,
  thisMonth,
  thisYear,
  custom,
}

extension ReportFilterX on ReportFilter {
  String get label {
    switch (this) {
      case ReportFilter.today:
        return 'Today';
      case ReportFilter.thisWeek:
        return 'This Week';
      case ReportFilter.thisMonth:
        return 'This Month';
      case ReportFilter.thisYear:
        return 'This Year';
      case ReportFilter.custom:
        return 'Custom';
    }
  }
}

const List<ReportFilter> _visibleReportFilters = <ReportFilter>[
  ReportFilter.today,
  ReportFilter.thisWeek,
  ReportFilter.thisMonth,
  ReportFilter.thisYear,
];

Widget buildPeriodFilter(
  BuildContext context, {
  required ReportFilter selectedFilter,
  required ValueChanged<ReportFilter> onChanged,
}) {
  return Card(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _visibleReportFilters.map((filter) {
          return ChoiceChip(
            label: Text(filter.label),
            selected: selectedFilter == filter,
            onSelected: (_) => onChanged(filter),
          );
        }).toList(),
      ),
    ),
  );
}

Widget buildStatusBadge(String status) {
  final color = _statusColor(status);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      status,
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

Widget buildEmptyState(BuildContext context, String message) {
  return Card(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[700],
            ),
      ),
    ),
  );
}

Widget metricText(String label, String value, {bool isEmpty = false}) {
  return Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.softGray,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      const SizedBox(width: 10),
      Text(
        value,
        style: TextStyle(
          color: isEmpty ? Colors.grey[600] : AppColors.earthCharcoal,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

String formatAge(int ageDays) {
  if (ageDays < 0) {
    return 'Not recorded yet';
  }
  final weeks = ageDays ~/ 7;
  final days = ageDays % 7;
  return '${weeks}w ${days}d';
}

Color _statusColor(String status) {
  switch (status) {
    case 'Excellent':
      return AppColors.leakukuGreen;
    case 'Good':
      return const Color(0xFF1E88E5);
    case 'Needs Attention':
      return AppColors.errorRed;
    default:
      return Colors.grey;
  }
}

String formatMoney(double value) {
  final formatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: 'KES ',
    decimalDigits: 2,
  );
  return formatter.format(value);
}

enum _ReportExportAction { pdf, excel, share }

Widget buildReportExportAction(
  BuildContext context, {
  required bool enabled,
  required Future<void> Function(_ReportExportAction action) onActionSelected,
}) {
  if (!enabled) {
    return const IconButton(
      onPressed: null,
      icon: Icon(Icons.download_outlined),
      tooltip: 'There is no data available for the selected period.',
    );
  }

  return PopupMenuButton<_ReportExportAction>(
    tooltip: 'Export',
    icon: const Icon(Icons.download_outlined),
    onSelected: (action) async {
      await onActionSelected(action);
    },
    itemBuilder: (context) => const [
      PopupMenuItem(
        value: _ReportExportAction.pdf,
        child: Text('Export PDF'),
      ),
      PopupMenuItem(
        value: _ReportExportAction.excel,
        child: Text('Export Excel'),
      ),
      PopupMenuItem(
        value: _ReportExportAction.share,
        child: Text('Share'),
      ),
    ],
  );
}

Future<void> handleExportAction(
  BuildContext context,
  _ReportExportAction action,
  ReportExportPayload payload,
) async {
  if (payload.rows.length <= 1) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('There is no data available for the selected period.'),
      ),
    );
    return;
  }

  try {
    if (action == _ReportExportAction.pdf) {
      final file = await _generatePdfFile(payload);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF exported: ${file.path}')),
      );
      return;
    }

    if (action == _ReportExportAction.excel) {
      final file = await _generateExcelFile(payload);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Excel exported: ${file.path}')),
      );
      return;
    }

    final file = await _generatePdfFile(payload);
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: '${payload.reportTitle} (${payload.periodLabel})',
      text: 'Leakuku Report: ${payload.reportTitle} (${payload.periodLabel})',
    );
  } catch (error) {
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Export failed: $error')),
    );
  }
}

Future<File> _generatePdfFile(ReportExportPayload payload) async {
  final doc = pw.Document();
  final generatedAt = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

  final headers = payload.rows.first;
  final dataRows = payload.rows.skip(1).toList();

  doc.addPage(
    pw.MultiPage(
      build: (context) => [
        pw.Text(
          payload.reportTitle,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text('Reporting Period: ${payload.periodLabel}'),
        pw.Text('Generated: $generatedAt'),
        pw.SizedBox(height: 12),
        pw.TableHelper.fromTextArray(
          headers: headers,
          data: dataRows,
          cellAlignment: pw.Alignment.centerLeft,
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          headerDecoration: const pw.BoxDecoration(
            color: pdf_core.PdfColor.fromInt(0xFFEFEFEF),
          ),
        ),
      ],
    ),
  );

  final dir = await getTemporaryDirectory();
  final fileName =
      _exportFileName(payload.reportTitle, payload.periodLabel, 'pdf');
  final file = File('${dir.path}/$fileName');
  await file.writeAsBytes(await doc.save(), flush: true);
  return file;
}

Future<File> _generateExcelFile(ReportExportPayload payload) async {
  final workbook = Excel.createExcel();
  final sheet = workbook['Report'];

  for (final row in payload.rows) {
    sheet.appendRow(row);
  }

  final bytes = workbook.encode();
  if (bytes == null) {
    throw Exception('Unable to encode Excel file.');
  }

  final dir = await getTemporaryDirectory();
  final fileName =
      _exportFileName(payload.reportTitle, payload.periodLabel, 'xlsx');
  final file = File('${dir.path}/$fileName');
  await file.writeAsBytes(bytes, flush: true);
  return file;
}

String _exportFileName(
    String reportTitle, String periodLabel, String extension) {
  final slugTitle =
      reportTitle.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  final slugPeriod =
      periodLabel.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  return '${slugTitle}_${slugPeriod}_$timestamp.$extension';
}
