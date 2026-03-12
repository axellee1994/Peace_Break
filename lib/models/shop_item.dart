class ShopItem {
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

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'type': type,
      'price': price,
      'description': description,
    };
  }

  factory ShopItem.fromMap(Map<String, dynamic> map) {
    return ShopItem(
      id: map['id'] as int?,
      name: map['name'] as String,
      type: map['type'] as String,
      price: map['price'] as int,
      description: map['description'] as String,
    );
  }
}
