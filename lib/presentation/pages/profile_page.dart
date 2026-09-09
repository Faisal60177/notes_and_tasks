import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/presentation/pages/auth_page.dart';
import 'package:notes_app/presentation/providers/auth_notifier.dart';
import 'package:notes_app/presentation/providers/auth_state.dart';


class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  void _snack(BuildContext context, String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? Colors.green[700] : Colors.red[900],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogCtx).pop(), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red[800]),
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) _snack(context, 'You have been signed out.', success: true);
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: auth.isLoggedIn ? _loggedInView(context, ref, auth) : _loggedOutView(context),
    );
  }

  Widget _loggedInView(BuildContext context, WidgetRef ref, AuthState auth) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: auth.photoUrl.isNotEmpty ? NetworkImage(auth.photoUrl) : null,
          child: auth.photoUrl.isEmpty
              ? Text(auth.displayName.isNotEmpty ? auth.displayName[0].toUpperCase() : '?')
              : null,
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(auth.displayName.isNotEmpty ? auth.displayName : 'User',
              style: Theme.of(context).textTheme.titleLarge),
        ),
        Center(child: Text(auth.email, style: TextStyle(color: Colors.grey.shade600))),
        const SizedBox(height: 24),
        ListTile(
          leading: const Icon(Icons.shield_outlined),
          title: const Text('Signed in via'),
          subtitle: Text([
            if (auth.hasGoogle) 'Google',
            if (auth.hasPassword) 'Email',
          ].join(' + ')),
        ),
        ListTile(
          leading: const Icon(Icons.lock_outline),
          title: Text(auth.hasPassword ? 'Update Password' : 'Add Password Login'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showSetPasswordSheet(context, ref, isUpdate: auth.hasPassword),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () => _confirmSignOut(context, ref),
          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
          icon: const Icon(Icons.logout),
          label: const Text('Sign Out'),
        ),
      ],
    );
  }

  Widget _loggedOutView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('Sign in to sync your notes and tasks across devices.',
                textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthPage()),
                ),
                child: const Text('Sign In / Create Account'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSetPasswordSheet(BuildContext context, WidgetRef ref, {required bool isUpdate}) {
    final passCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(sheetCtx).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isUpdate ? 'Update Password' : 'Add Password Login',
                style: Theme.of(sheetCtx).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: passCtrl, obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmCtrl, obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
            ),
            const SizedBox(height: 20),
            Consumer(builder: (_, ref, __) {
              final loading = ref.watch(authProvider).isLoading;
              return SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: loading
                      ? null
                      : () async {
                    if (passCtrl.text.length < 6) {
                      _snack(context, 'Password must be at least 6 characters.');
                      return;
                    }
                    if (passCtrl.text != confirmCtrl.text) {
                      _snack(context, 'Passwords do not match.');
                      return;
                    }
                    final ok = await ref
                        .read(authProvider.notifier)
                        .addPasswordToAccount(password: passCtrl.text);
                    if (!sheetCtx.mounted) return;
                    Navigator.of(sheetCtx).pop();
                    if (ok) {
                      _snack(context, 'Password saved.', success: true);
                    } else {
                      _snack(context, ref.read(authProvider).errorMessage);
                    }
                  },
                  child: loading
                      ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(isUpdate ? 'Update Password' : 'Set Password'),
                ),
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
