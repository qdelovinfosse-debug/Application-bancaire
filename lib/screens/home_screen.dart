import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../utils/database_helper.dart';
import '../utils/constants.dart';
import '../utils/settings_helper.dart';
import 'add_expense_screen.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Expense> expenses = [];
  double totalExpenses = 0.0;
  double monthlyExpenses = 0.0;
  double _monthlyBudget = 0.0;
  String _currency = '€';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initAndLoad();
  }

  Future<void> _initAndLoad() async {
    await DatabaseHelper.instance.initDefaultExpenses();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    setState(() => isLoading = true);
    final data = await DatabaseHelper.instance.getAllExpenses();
    final total = await DatabaseHelper.instance.getTotalExpenses();
    final monthly = await DatabaseHelper.instance.getMonthlyExpenses();
    setState(() {
      expenses = data;
      totalExpenses = total;
      monthlyExpenses = monthly;
      _currency = SettingsHelper.instance.getCurrency();
      _monthlyBudget = SettingsHelper.instance.getMonthlyBudget();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        elevation: 0,
        title: const Text('Mes Dépenses',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StatisticsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SettingsScreen()),
              );
              _loadExpenses();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              _buildTotalCard(),
              _buildBudgetCard(),
              Expanded(
                  child: expenses.isEmpty ? _buildEmptyState() : _buildExpenseList()),
            ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddExpenseScreen()));
          _loadExpenses();
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTotalCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total dépensé',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  '${totalExpenses.toStringAsFixed(2)} $_currency',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.account_balance_wallet_rounded,
                color: Colors.blueAccent, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard() {
    if (_monthlyBudget <= 0) return const SizedBox.shrink();
    final progress = (monthlyExpenses / _monthlyBudget).clamp(0.0, 1.0);
    final isOver = monthlyExpenses > _monthlyBudget;
    final color = isOver ? const Color(0xFFFF3B30) : Colors.blueAccent;
    final month = DateFormat('MMMM', 'fr_FR').format(DateTime.now());
    final monthLabel = month[0].toUpperCase() + month.substring(1);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Budget $monthLabel',
                  style: TextStyle(
                      color: Colors.grey.shade500, fontSize: 13)),
              Text(
                isOver
                    ? 'Dépassé !'
                    : '${(progress * 100).toStringAsFixed(0)} %',
                style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFF2C2C2E),
              color: color,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${monthlyExpenses.toStringAsFixed(2)} $_currency / ${_monthlyBudget.toStringAsFixed(2)} $_currency',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_rounded, size: 64, color: Colors.grey.shade700),
          const SizedBox(height: 16),
          Text('Aucune dépense',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade500)),
          const SizedBox(height: 6),
          Text('Appuyez sur + pour commencer',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _buildExpenseList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return Dismissible(
          key: ValueKey(expense.id),
          direction: DismissDirection.horizontal,
          background: _swipeBackground(
            alignment: Alignment.centerLeft,
            color: const Color(0xFFFF3B30),
            icon: Icons.delete_outline_rounded,
            label: 'Supprimer',
          ),
          secondaryBackground: _swipeBackground(
            alignment: Alignment.centerRight,
            color: const Color(0xFF0A84FF),
            icon: Icons.edit_outlined,
            label: 'Modifier',
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              return await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: const Color(0xFF1C1C1E),
                      title: const Text('Supprimer ?'),
                      content: const Text(
                          'Cette dépense sera définitivement supprimée.'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Annuler')),
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Supprimer',
                                style:
                                    TextStyle(color: Color(0xFFFF3B30)))),
                      ],
                    ),
                  ) ??
                  false;
            } else {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AddExpenseScreen(expense: expense)));
              _loadExpenses();
              return false;
            }
          },
          onDismissed: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              await DatabaseHelper.instance.deleteExpense(expense.id!);
              _loadExpenses();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Dépense supprimée')));
              }
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (AppConstants.categoryColors[expense.categorie] ?? Colors.grey)
                        .withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    AppConstants.categoryIcons[expense.categorie] ?? Icons.more_horiz,
                    color: AppConstants.categoryColors[expense.categorie] ?? Colors.grey,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          expense.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15)),
                      const SizedBox(height: 3),
                      Text(
                          '${expense.categorie} · ${DateFormat('dd/MM/yy').format(expense.date)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '-${expense.montant.toStringAsFixed(2)} $_currency',
                  style: const TextStyle(
                      color: Color(0xFFFF3B30),
                      fontWeight: FontWeight.w700,
                      fontSize: 15),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _swipeBackground({
    required Alignment alignment,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(16)),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
