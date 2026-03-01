import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static const String _boxName = 'expenses';

  DatabaseHelper._init();

  Future<Box<Expense>> get _box async => Hive.box<Expense>(_boxName);

  Future<int> createExpense(Expense expense) async {
    final box = await _box;
    final id = DateTime.now().millisecondsSinceEpoch;
    expense.id = id;
    await box.put(id, expense);
    return id;
  }

  Future<List<Expense>> getAllExpenses() async {
    final box = await _box;
    final expenses = box.values.toList();
    expenses.sort((a, b) => b.date.compareTo(a.date));
    return expenses;
  }

  Future<void> updateExpense(Expense expense) async {
    await expense.save();
  }

  Future<void> deleteExpense(int id) async {
    final box = await _box;
    await box.delete(id);
  }

  Future<double> getTotalExpenses() async {
    final box = await _box;
    if (box.isEmpty) return 0.0;
    return box.values.fold<double>(0.0, (sum, e) => sum + e.montant);
  }

  Future<Map<String, double>> getExpensesByCategory() async {
    final box = await _box;
    final Map<String, double> categoryTotals = {};
    for (final expense in box.values) {
      categoryTotals[expense.categorie] =
          (categoryTotals[expense.categorie] ?? 0.0) + expense.montant;
    }
    return categoryTotals;
  }
}
