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
  DateTime dateTime;

  @HiveField(5)
  String note;

  TransactionModel({
    required this.tId,
    required this.category,
    required this.amount,
    required this.dateTime,
    required this.type,
    this.note = '',
  });

  TransactionModel copyWith({
    String? tId,
    CategoryModel? category,
    TransactionType? type,
    double? amount,
    DateTime? dateTime,
    String? note,
  }) {
    return TransactionModel(
      tId: tId ?? this.tId,
      category: category ?? this.category,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      dateTime: dateTime ?? this.dateTime,
      note: note ?? this.note,
    );
  }
}
