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

  Future<double> getMonthlyExpenses() async {
    final box = await _box;
    final now = DateTime.now();
    return box.values
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold<double>(0.0, (sum, e) => sum + e.montant);
  }

  Future<void> deleteAllExpenses() async {
    final box = await _box;
    await box.clear();
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

  Future<void> initDefaultExpenses() async {
    final box = await _box;
    if (box.isNotEmpty) return;
    final defaults = [
      Expense(
        montant: 87.50,
        categorie: 'Alimentation',
        description: 'Courses Monoprix',
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Expense(
        montant: 55.00,
        categorie: 'Transport',
        description: 'Plein d\'essence',
        date: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Expense(
        montant: 13.99,
        categorie: 'Loisirs',
        description: 'Abonnement Netflix',
        date: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Expense(
        montant: 950.00,
        categorie: 'Logement',
        description: 'Loyer Mars 2026',
        date: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];
    for (final expense in defaults) {
      await createExpense(expense);
    }
  }
}
