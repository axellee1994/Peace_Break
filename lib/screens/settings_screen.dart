import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingsTile(
            icon: Icons.lock,
            title: 'Change Password',
            onTap: () => _showChangePassword(context),
          ),
          _SettingsTile(
            icon: Icons.person,
            title: 'Change Username',
            onTap: () => _showChangeUsername(context),
          ),
          const Divider(height: 32),
          _SettingsTile(
            icon: Icons.delete_sweep,
            title: 'Delete Game Progress',
            color: Colors.orange,
            onTap: () => _confirmAction(
              context,
              title: 'Delete Progress',
              message:
                  'This will reset your score, coins, stages, and inventory. Are you sure?',
              onConfirm: () async {
                await context.read<AuthProvider>().resetProgress();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
          ),
          _SettingsTile(
            icon: Icons.delete_forever,
            title: 'Delete Account',
            color: Colors.red,
            onTap: () => _confirmAction(
              context,
              title: 'Delete Account',
              message:
                  'This will permanently delete your account and all data. Are you sure?',
              onConfirm: () async {
                await context.read<AuthProvider>().deleteAccount();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePassword(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? error;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Change Password'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: currentCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: 'Current Password',
                      border: OutlineInputBorder()),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: newCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: 'New Password',
                      border: OutlineInputBorder()),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Required' : null,
                ),
                if (error != null) ...[
                  const SizedBox(height: 8),
                  Text(error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final err = await context
                    .read<AuthProvider>()
                    .changePassword(currentCtrl.text, newCtrl.text);
                if (err != null) {
                  setState(() => error = err);
                } else {
                  Navigator.pop(ctx);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Password changed successfully!')),
                    );
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangeUsername(BuildContext context) {
    final ctrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? error;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Change Username'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: ctrl,
                  decoration: const InputDecoration(
                      labelText: 'New Username (3–10 alphanumeric)',
                      border: OutlineInputBorder()),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Required' : null,
                ),
                if (error != null) ...[
                  const SizedBox(height: 8),
                  Text(error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final err = await context
                    .read<AuthProvider>()
                    .changeUsername(ctrl.text);
                if (err != null) {
                  setState(() => error = err);
                } else {
                  Navigator.pop(ctx);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Username changed! Please log in again.')),
                    );
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmAction(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirm',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.onSurface;
    return Card(
      child: ListTile(
        leading: Icon(icon, color: c),
        title: Text(title, style: TextStyle(color: c)),
        trailing: Icon(Icons.chevron_right, color: c),
        onTap: onTap,
      ),
    );
  }
}
