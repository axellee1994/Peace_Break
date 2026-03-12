import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../database/app_database.dart';
import '../models/shop_item.dart';
import '../models/inventory_item.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  List<ShopItem> _items = [];
  Set<int> _owned = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return;
    final db = AppDatabase();
    final items = await db.shopItems.findAll(orderBy: 'id ASC');
    final inv = await db.inventory.forUser(user.id!);
    final ownedIds = inv.map((i) => i.itemId).toSet();
    setState(() {
      _items = items;
      _owned = ownedIds;
      _loading = false;
    });
  }

  Future<void> _buy(ShopItem item) async {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser!;
    if (user.coins < item.price) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough coins!')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Purchase'),
        content: Text('Buy "${item.name}" for ${item.price} coins?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Buy')),
        ],
      ),
    );
    if (confirm != true) return;

    final db = AppDatabase();
    if (item.type == 'life') {
      await db.users.updateFields(user.id!, {
        'max_lives': user.maxLives + 1,
        'coins': user.coins - item.price,
      });
    } else {
      await db.users.updateFields(user.id!, {'coins': user.coins - item.price});
      await db.inventory.insert(
          InventoryItem(userId: user.id!, itemId: item.id!));
    }

    await auth.refreshUser();
    await _load();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${item.name}" purchased!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber),
                const SizedBox(width: 4),
                Text('${user?.coins ?? 0}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final item = _items[i];
                final owned = _owned.contains(item.id);
                final isLife = item.type == 'life';
                final canBuy = !owned || isLife;

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _typeColor(item.type, cs),
                      child: Icon(_typeIcon(item.type), color: Colors.white),
                    ),
                    title: Text(item.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(item.description),
                    trailing: canBuy
                        ? ElevatedButton(
                            onPressed: () => _buy(item),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cs.primary,
                              foregroundColor: cs.onPrimary,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.monetization_on,
                                    size: 14, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text('${item.price}'),
                              ],
                            ),
                          )
                        : Chip(
                            label: const Text('Owned'),
                            backgroundColor: cs.secondaryContainer,
                          ),
                  ),
                );
              },
            ),
    );
  }

  Color _typeColor(String type, ColorScheme cs) {
    switch (type) {
      case 'life':
        return Colors.red;
      case 'paddle_skin':
        return Colors.blue;
      case 'ball_skin':
        return Colors.orange;
      default:
        return cs.primary;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'life':
        return Icons.favorite;
      case 'paddle_skin':
        return Icons.horizontal_rule;
      case 'ball_skin':
        return Icons.circle;
      default:
        return Icons.shopping_bag;
    }
  }
}
