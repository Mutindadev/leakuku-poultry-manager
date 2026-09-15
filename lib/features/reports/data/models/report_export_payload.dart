class ReportExportPayload {
  final String reportTitle;
  final String periodLabel;
  final List<List<String>> rows;

  const ReportExportPayload({
    required this.reportTitle,
    required this.periodLabel,
    required this.rows,
  });
}
