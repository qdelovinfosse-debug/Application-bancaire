import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 0)
class Expense extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  late double montant;

  @HiveField(2)
  late String categorie;

  @HiveField(3)
  late String description;

  @HiveField(4)
  late DateTime date;

  Expense({
    this.id,
    required this.montant,
    required this.categorie,
    required this.description,
    required this.date,
  });
}
