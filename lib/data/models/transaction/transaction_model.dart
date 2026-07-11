import 'package:hive_flutter/hive_flutter.dart';
import 'package:money_tracker_app/data/models/category/category_model.dart';
import 'package:money_tracker_app/data/models/enum/enum.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 1)
class TransactionModel extends HiveObject {
  @HiveField(0)
  String tId;

  @HiveField(1)
  CategoryModel category;

  @HiveField(2)
  TransactionType type;

  @HiveField(3)
  double amount;

  @HiveField(4)
  String date;

  @HiveField(5)
  String time;

  TransactionModel({
    required this.tId,
    required this.category,
    required this.amount,
    required this.date,
    required this.type,
    required this.time,
  });
}
