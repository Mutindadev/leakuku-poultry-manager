import 'package:hive/hive.dart';
import 'package:leakuku/data/models/breed_model.dart';
import 'package:leakuku/data/models/financial_transaction_model.dart';
import 'package:leakuku/data/models/stock_history_model.dart';
import 'package:leakuku/data/models/stock_item_model.dart';
import 'package:leakuku/data/models/vaccine_model.dart';
import 'package:leakuku/data/models/weekly_plan_model.dart';
import 'package:leakuku/features/flock/data/models/flock_model.dart';
import 'package:leakuku/features/user/data/models/user.dart';

void registerAdapters() {
  Hive.registerAdapter(FinancialTransactionModelAdapter());
  Hive.registerAdapter(VaccineModelAdapter());
  Hive.registerAdapter(WeeklyPlanModelAdapter());
  Hive.registerAdapter(FlockModelAdapter());
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(BreedModelAdapter());
  Hive.registerAdapter(StockItemModelAdapter());
  Hive.registerAdapter(StockHistoryModelAdapter());
}
