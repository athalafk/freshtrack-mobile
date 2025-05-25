class TransactionModel {
  final String date;
  final String type;
  final String item;
  final String stock;
  final String actor;

  TransactionModel({
    required this.date,
    required this.type,
    required this.item,
    required this.stock,
    required this.actor,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      date: json['date'],
      type: json['type'],
      item: json['item'],
      stock: json['stock'].toString(),
      actor: json['actor'],
    );
  }
}