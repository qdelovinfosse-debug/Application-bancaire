import 'package:flutter/material.dart';
import '../utils/settings_helper.dart';
import '../utils/theme_notifier.dart';
import '../utils/database_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ThemeMode _themeMode;
  late String _currency;
  final _budgetController = TextEditingController();

  final List<String> _currencies = ['€', '\$', '\u00a3', 'CHF', '\u00a5'];

  @override
  void initState() {
    super.initState();
    _themeMode = SettingsHelper.instance.getThemeMode();
    _currency = SettingsHelper.instance.getCurrency();
    final budget = SettingsHelper.instance.getMonthlyBudget();
    _budgetController.text = budget > 0 ? budget.toStringAsFixed(2) : '';
  }

  @override
  void dispose() {
    final budget =
        double.tryParse(_budgetController.text.replaceAll(',', '.')) ?? 0.0;
    SettingsHelper.instance.setMonthlyBudget(budget);
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        elevation: 0,
        title: const Text('Paramètres',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('Apparence', [_buildThemeSelector()]),
          const SizedBox(height: 24),
          _buildSection('Général', [
            _buildCurrencySelector(),
            const Divider(color: Color(0xFF2C2C2E), height: 1, indent: 16),
            _buildBudgetField(),
          ]),
          const SizedBox(height: 24),
          _buildSection('Données', [_buildResetButton()]),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildThemeSelector() {
    final options = [
      (ThemeMode.dark, Icons.dark_mode_rounded, 'Sombre'),
      (ThemeMode.light, Icons.light_mode_rounded, 'Clair'),
      (ThemeMode.system, Icons.brightness_auto_rounded, 'Système'),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.palette_rounded,
                  color: Colors.grey.shade500, size: 20),
              const SizedBox(width: 12),
              Text('Thème',
                  style:
                      TextStyle(color: Colors.grey.shade400, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: options.asMap().entries.map((entry) {
              final index = entry.key;
              final opt = entry.value;
              final isSelected = _themeMode == opt.$1;
              return Expanded(
                child: GestureDetector(
                  onTap: () async {
                    setState(() => _themeMode = opt.$1);
                    await SettingsHelper.instance.setThemeMode(opt.$1);
                    themeNotifier.value = opt.$1;
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blueAccent.withOpacity(0.15)
                          : const Color(0xFF2C2C2E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Colors.blueAccent
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(opt.$2,
                            color: isSelected
                                ? Colors.blueAccent
                                : Colors.grey.shade600,
                            size: 22),
                        const SizedBox(height: 6),
                        Text(
                          opt.$3,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.blueAccent
                                : Colors.grey.shade600,
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencySelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(Icons.currency_exchange_rounded,
              color: Colors.grey.shade500, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Devise',
                style: TextStyle(color: Colors.white, fontSize: 15)),
          ),
          DropdownButton<String>(
            value: _currency,
            dropdownColor: const Color(0xFF2C2C2E),
            underline: const SizedBox(),
            iconEnabledColor: Colors.grey.shade500,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600),
            items: _currencies
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (value) async {
              if (value != null) {
                setState(() => _currency = value);
                await SettingsHelper.instance.setCurrency(value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(Icons.savings_rounded, color: Colors.grey.shade500, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Budget mensuel',
                    style: TextStyle(color: Colors.white, fontSize: 15)),
                const SizedBox(height: 2),
                Text('0 = désactivé',
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
          SizedBox(
            width: 110,
            child: TextField(
              controller: _budgetController,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: TextStyle(color: Colors.grey.shade700),
                suffixText: _currency,
                suffixStyle: TextStyle(color: Colors.grey.shade500),
                border: InputBorder.none,
              ),
              onChanged: (value) {
                final budget =
                    double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
                SettingsHelper.instance.setMonthlyBudget(budget);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton() {
    return InkWell(
      onTap: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1C1C1E),
            title: const Text('Réinitialiser ?'),
            content: const Text(
                'Toutes les dépenses seront supprimées définitivement.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Supprimer',
                    style: TextStyle(color: Color(0xFFFF3B30))),
              ),
            ],
          ),
        );
        if (confirm == true) {
          await DatabaseHelper.instance.deleteAllExpenses();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Toutes les dépenses ont été supprimées')),
            );
          }
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            const Icon(Icons.delete_outline_rounded,
                color: Color(0xFFFF3B30), size: 20),
            const SizedBox(width: 12),
            const Text(
              'Réinitialiser les données',
              style: TextStyle(color: Color(0xFFFF3B30), fontSize: 15),
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded,
                color: Colors.grey.shade700, size: 20),
          ],
        ),
      ),
    );
  }
}
