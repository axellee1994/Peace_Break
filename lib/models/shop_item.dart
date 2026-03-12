import '../database/orm.dart';

class ShopItem implements Model {
  @override
  final int? id;
  final String name;
  final String type;
  final int price;
  final String description;

  const ShopItem({
    this.id,
    required this.name,
    required this.type,
    required this.price,
    required this.description,
  });

  @override
  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'type': type,
        'price': price,
        'description': description,
      };

  factory ShopItem.fromMap(Map<String, dynamic> m) => ShopItem(
        id: m['id'] as int?,
        name: m['name'] as String,
        type: m['type'] as String,
        price: m['price'] as int,
        description: m['description'] as String,
      );
}
