import 'package:flutter/material.dart';
import 'package:leakuku/core/theme/app_colors.dart';
import 'package:leakuku/data/models/stock_item_model.dart';

class StockItemListTile extends StatelessWidget {
  final StockItemModel item;
  final VoidCallback onTap;

  const StockItemListTile({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatQuantity(item.quantity)} ${item.unit}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: item.isLowStock
                      ? AppColors.warningAmber.withValues(alpha: 0.16)
                      : AppColors.leakukuGreen.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.isLowStock ? 'Low Stock' : 'In Stock',
                  style: TextStyle(
                    color: item.isLowStock
                        ? AppColors.warningAmber
                        : AppColors.leakukuGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: AppColors.softGray),
            ],
          ),
        ),
      ),
    );
  }

  String _formatQuantity(double quantity) {
    if (quantity == quantity.roundToDouble()) {
      return quantity.toStringAsFixed(0);
    }
    return quantity.toStringAsFixed(1);
  }
}
