import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../database/app_database.dart';
import '../models/inventory_item.dart';
import '../models/shop_item.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<({InventoryItem inv, ShopItem item})> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;
    final db = AppDatabase();
    final invItems = await db.inventory.forUser(user.id!);
    final allShop = await db.shopItems.findAll();
    final shopMap = {for (final s in allShop) s.id!: s};

    final entries = invItems
        .where((i) => shopMap.containsKey(i.itemId))
        .map((i) => (inv: i, item: shopMap[i.itemId]!))
        .toList();

    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  Future<void> _toggleEquip(InventoryItem inv, ShopItem item) async {
    final user = context.read<AuthProvider>().currentUser!;
    final db = AppDatabase();
    if (inv.isEquipped) {
      await db.inventory.unequip(user.id!, inv.itemId);
    } else {
      await db.inventory.equipExclusive(user.id!, inv.itemId, db.rawDb);
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? const Center(
                  child: Text('No items yet. Visit the Shop!',
                      style: TextStyle(fontSize: 16)))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _entries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final e = _entries[i];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              e.item.type == 'paddle_skin'
                                  ? Colors.blue
                                  : Colors.orange,
                          child: Icon(
                            e.item.type == 'paddle_skin'
                                ? Icons.horizontal_rule
                                : Icons.circle,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(e.item.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                        subtitle: Text(e.item.description),
                        trailing: e.inv.isEquipped
                            ? ElevatedButton.icon(
                                onPressed: () =>
                                    _toggleEquip(e.inv, e.item),
                                icon: const Icon(Icons.check, size: 16),
                                label: const Text('Equipped'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: cs.primary,
                                  foregroundColor: cs.onPrimary,
                                ),
                              )
                            : OutlinedButton(
                                onPressed: () =>
                                    _toggleEquip(e.inv, e.item),
                                child: const Text('Equip'),
                              ),
                      ),
                    );
                  },
                ),
    );
  }
}
