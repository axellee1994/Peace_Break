import '../database/orm.dart';

class InventoryItem implements Model {
  @override
  final int? id;
  final int userId;
  final int itemId;
  final bool isEquipped;

  const InventoryItem({
    this.id,
    required this.userId,
    required this.itemId,
    this.isEquipped = false,
  });

  @override
  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'user_id': userId,
        'item_id': itemId,
        'is_equipped': isEquipped ? 1 : 0,
      };

  factory InventoryItem.fromMap(Map<String, dynamic> m) => InventoryItem(
        id: m['id'] as int?,
        userId: m['user_id'] as int,
        itemId: m['item_id'] as int,
        isEquipped: (m['is_equipped'] as int? ?? 0) == 1,
      );

  InventoryItem copyWith({bool? isEquipped}) => InventoryItem(
        id: id,
        userId: userId,
        itemId: itemId,
        isEquipped: isEquipped ?? this.isEquipped,
      );
}
