import 'user.dart';
import 'item.dart';

class Invoice {
  final int id;
  final User user;
  final List<Item> items;
  final double totalAmount;
  final String purchaseDate;

  Invoice({
    required this.id,
    required this.user,
    required this.items,
    required this.totalAmount,
    required this.purchaseDate,
  });

  // factory constructor
  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] ?? 0, // Fallback to 0 if null
      user: User.fromJson(json['user']),
      items: (json['items'] as List)
          .map((item) => Item.fromJson(item['item']))
          .toList(),
      totalAmount: json['totalAmount'].toDouble(),
      purchaseDate: json['purchaseDate'],
    );
  }
}