class InventoryItem {
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

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'item_id': itemId,
      'is_equipped': isEquipped ? 1 : 0,
    };
  }

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      itemId: map['item_id'] as int,
      isEquipped: (map['is_equipped'] as int? ?? 0) == 1,
    );
  }

  InventoryItem copyWith({bool? isEquipped}) {
    return InventoryItem(
      id: id,
      userId: userId,
      itemId: itemId,
      isEquipped: isEquipped ?? this.isEquipped,
    );
  }
}
