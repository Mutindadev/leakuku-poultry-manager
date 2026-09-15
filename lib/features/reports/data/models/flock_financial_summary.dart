class FlockFinancialSummary {
  final String flockLabel;
  final double revenue;
  final double expenses;

  const FlockFinancialSummary({
    required this.flockLabel,
    required this.revenue,
    required this.expenses,
  });

  double get estimatedProfit => revenue - expenses;
}
