import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_notifier.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> with SingleTickerProviderStateMixin {
  late TabController _tab;

  final _signInForm = GlobalKey<FormState>();
  final _signUpForm = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailInCtrl = TextEditingController();
  final _passInCtrl = TextEditingController();
  final _emailUpCtrl = TextEditingController();
  final _passUpCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _showPassIn = false;
  bool _showPassUp = false;
  bool _showConfirm = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() {
      if (_tab.indexIsChanging) {
        ref.read(authProvider.notifier).clearError();
      }
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    _nameCtrl.dispose();
    _emailInCtrl.dispose();
    _passInCtrl.dispose();
    _emailUpCtrl.dispose();
    _passUpCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg, {bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? Colors.green[700] : Colors.red[900],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: Duration(seconds: success ? 2 : 4),
      ),
    );
  }

  Future<void> _doSignIn() async {
    if (!_signInForm.currentState!.validate()) return;
    final ok = await ref.read(authProvider.notifier).signInWithEmail(
      email: _emailInCtrl.text,
      password: _passInCtrl.text,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
      _snack('Welcome back!', success: true);
    } else {
      final err = ref.read(authProvider).errorMessage;
      _snack(err.isNotEmpty ? err : 'Sign in failed. Please try again.');
    }
  }

  Future<void> _doSignUp() async {
    if (!_signUpForm.currentState!.validate()) return;
    final ok = await ref.read(authProvider.notifier).signUpWithEmail(
      name: _nameCtrl.text,
      email: _emailUpCtrl.text,
      password: _passUpCtrl.text,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
      _snack('Account created!', success: true);
    } else {
      final err = ref.read(authProvider).errorMessage;
      _snack(err.isNotEmpty ? err : 'Sign up failed. Please try again.');
    }
  }

  Future<void> _doGoogle() async {
    final ok = await ref.read(authProvider.notifier).signInWithGoogle();
    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pop();
      _snack('Signed in with Google', success: true);
      return;
    }

    final authState = ref.read(authProvider);
    if (authState.needsGoogleLinkPassword) {
      // নতুন — password verify করে Google link করার dialog
      _showLinkPasswordDialog(authState.pendingGoogleEmail ?? '');
    } else if (authState.errorMessage.isNotEmpty) {
      _snack(authState.errorMessage);
    }
  }


  void _showLinkPasswordDialog(String email) {
    final passCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Link Google Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('An account with "$email" already exists using a password. '
                'Enter that password to link Google sign-in.'),
            const SizedBox(height: 16),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(authProvider.notifier).cancelGoogleLink();
              Navigator.of(dialogCtx).pop();
            },
            child: const Text('Cancel'),
          ),
          Consumer(builder: (_, ref, __) {
            final loading = ref.watch(authProvider).isLoading;
            return FilledButton(
              onPressed: loading
                  ? null
                  : () async {
                final ok = await ref
                    .read(authProvider.notifier)
                    .completeGoogleLinkWithPassword(email: email, password: passCtrl.text);
                if (!dialogCtx.mounted) return;
                Navigator.of(dialogCtx).pop();
                if (!mounted) return;
                if (ok) {
                  Navigator.of(context).pop();
                  _snack('Google account linked!', success: true);
                } else {
                  _snack(ref.read(authProvider).errorMessage);
                }
              },
              child: loading
                  ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Link & Sign In'),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [Tab(text: 'Sign In'), Tab(text: 'Sign Up')],
        ),
      ),
      body: TabBarView(controller: _tab, children: [_signInView(), _signUpView()]),
    );
  }

  Widget _signInView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Form(
        key: _signInForm,
        child: Column(
          children: [
            _field(controller: _emailInCtrl, label: 'Email Address', icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress, validator: _validateEmail),
            const SizedBox(height: 16),
            _field(
              controller: _passInCtrl, label: 'Password', icon: Icons.lock_outline,
              obscure: !_showPassIn,
              suffix: IconButton(
                icon: Icon(_showPassIn ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _showPassIn = !_showPassIn),
              ),
              validator: (v) => (v == null || v.length < 6) ? 'Min 6 characters' : null,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: _showForgot, child: const Text('Forgot password?')),
            ),
            const SizedBox(height: 8),
            Consumer(builder: (_, ref, __) {
              final loading = ref.watch(authProvider).isLoading;
              return _primaryBtn(label: 'Sign In', loading: loading, onTap: _doSignIn);
            }),
            const SizedBox(height: 24),
            _divider(),
            const SizedBox(height: 24),
            _googleBtn(),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _tab.animateTo(1),
              child: const Text("Don't have an account? Sign Up"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _signUpView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Form(
        key: _signUpForm,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'You can use the same email for both Google and email/password. '
                    'They will be linked to one account.',
                style: TextStyle(fontSize: 12),
              ),
            ),
            _field(controller: _nameCtrl, label: 'Full Name', icon: Icons.person_outline,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Name required' : null),
            const SizedBox(height: 16),
            _field(controller: _emailUpCtrl, label: 'Email Address', icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress, validator: _validateEmail),
            const SizedBox(height: 16),
            _field(
              controller: _passUpCtrl, label: 'Password', icon: Icons.lock_outline,
              obscure: !_showPassUp,
              suffix: IconButton(
                icon: Icon(_showPassUp ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _showPassUp = !_showPassUp),
              ),
              validator: (v) => (v == null || v.length < 6) ? 'Min 6 characters' : null,
            ),
            const SizedBox(height: 16),
            _field(
              controller: _confirmCtrl, label: 'Confirm Password', icon: Icons.lock_outline,
              obscure: !_showConfirm,
              suffix: IconButton(
                icon: Icon(_showConfirm ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _showConfirm = !_showConfirm),
              ),
              validator: (v) => v != _passUpCtrl.text ? 'Passwords do not match' : null,
            ),
            const SizedBox(height: 24),
            Consumer(builder: (_, ref, __) {
              final loading = ref.watch(authProvider).isLoading;
              return _primaryBtn(label: 'Create Account', loading: loading, onTap: _doSignUp);
            }),
            const SizedBox(height: 24),
            _divider(),
            const SizedBox(height: 24),
            _googleBtn(),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _tab.animateTo(0),
              child: const Text('Already have an account? Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  void _showForgot() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your email and we will send a reset link.'),
            const SizedBox(height: 16),
            _field(controller: ctrl, label: 'Email Address', icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogCtx).pop(), child: const Text('Cancel')),
          Consumer(builder: (_, ref, __) {
            final loading = ref.watch(authProvider).isLoading;
            return FilledButton(
              onPressed: loading
                  ? null
                  : () async {
                if (ctrl.text.trim().isEmpty) return;
                final ok = await ref
                    .read(authProvider.notifier)
                    .sendPasswordReset(ctrl.text);
                if (!dialogCtx.mounted) return;
                Navigator.of(dialogCtx).pop();
                _snack(
                  ok ? 'Reset email sent! Check your inbox.'
                      : ref.read(authProvider).errorMessage,
                  success: ok,
                );
              },
              child: loading
                  ? const SizedBox(width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Send Link'),
            );
          }),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: suffix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _primaryBtn({required String label, required bool loading, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity, height: 54,
      child: FilledButton(
        onPressed: loading ? null : onTap,
        child: loading
            ? const SizedBox(width: 22, height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
            : Text(label),
      ),
    );
  }

  Widget _divider() {
    return const Row(children: [
      Expanded(child: Divider()),
      Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('or continue with')),
      Expanded(child: Divider()),
    ]);
  }

  Widget _googleBtn() {
    return Consumer(builder: (_, ref, __) {
      final loading = ref.watch(authProvider).isLoading;
      return SizedBox(
        width: double.infinity, height: 54,
        child: OutlinedButton(
          onPressed: loading ? null : _doGoogle,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                width: 22, height: 22,
                errorBuilder: (_, __, ___) => const CircleAvatar(
                  radius: 11,
                  child: Text('G', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
              const SizedBox(width: 12),
              const Text('Continue with Google'),
            ],
          ),
        ),
      );
    });
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email required';
    final regex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!regex.hasMatch(v.trim())) return 'Invalid email address';
    return null;
  }
}
