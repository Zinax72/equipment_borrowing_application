import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../widgets/auth_backdrop.dart';
import '../../widgets/borrowit_logo.dart';
import '../../widgets/glass_panel.dart';

enum AuthMode { signIn, register }

class AuthScreen extends StatefulWidget {
  final AuthMode initialMode;

  const AuthScreen({super.key, this.initialMode = AuthMode.signIn});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _authService = AuthService();

  late AuthMode _mode = widget.initialMode;
  bool _loading = false;
  bool _hidePassword = true;

  bool get _isRegister => _mode == AuthMode.register;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() {
      if (_isRegister) setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _setMode(AuthMode mode) {
    if (mode == _mode || _loading) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _mode = mode;
      _confirmController.clear();
      _formKey = GlobalKey<FormState>();
    });
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() => _loading = true);
    try {
      if (_isRegister) {
        await _authService.register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await _authService.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      if (mounted) _showMessage(AuthService.messageFor(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (!email.contains('@')) {
      _showMessage('Enter your email above first.');
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) _showMessage('Password reset link sent to $email');
    } on FirebaseAuthException catch (e) {
      if (mounted) _showMessage(AuthService.messageFor(e));
    }
  }

  int get _passwordScore {
    final p = _passwordController.text;
    if (p.isEmpty) return 0;
    var score = 0;
    if (p.length >= 8) score++;
    if (RegExp(r'[a-z]').hasMatch(p) && RegExp(r'[A-Z]').hasMatch(p)) score++;
    if (RegExp(r'\d').hasMatch(p)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(p)) score++;
    return score == 0 ? 1 : score;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthBackdropColors.lightCanvas,
      body: Stack(
        children: [
          const Positioned.fill(child: AuthBackdrop(photoFraction: 0.45)),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 28),
                  children: [
                    _topBar(),
                    const SizedBox(height: 26),
                    Row(
                      children: [
                        const BorrowItMark(size: 54),
                        const SizedBox(width: 12),
                        Container(
                          width: 54,
                          height: 54,
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.82),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.gold.withValues(alpha: 0.55),
                            ),
                          ),
                          child: Image.asset(
                            'assets/images/BULSU LOGO.png',
                            cacheWidth: 140,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.school_rounded,
                                  color: AppColors.universityRed,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _header(),
                    const SizedBox(height: 22),
                    _formCard(),
                    const SizedBox(height: 14),
                    _switchPrompt(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar() {
    return Row(
      children: [
        GlassPanel(
          onTap: () => Navigator.of(context).maybePop(),
          borderRadius: 999,
          opacity: 0.80,
          borderColor: Colors.white.withValues(alpha: 0.9),
          child: const SizedBox(
            width: 42,
            height: 42,
            child: Icon(
              Icons.arrow_back_rounded,
              color: AppColors.darkText,
              size: 20,
              semanticLabel: 'Back',
            ),
          ),
        ),
        const Spacer(),
        const BorrowItLogo(compact: true),
      ],
    );
  }

  Widget _header() {
    final title = _isRegister ? 'Create your account' : 'Welcome back';
    final subtitle = _isRegister
        ? 'Register your student account to request campus equipment in batches and track returns.'
        : 'Sign in to manage your Borrowing Basket and follow your active requests.';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.12),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.topLeft,
        children: [...previous, ?current],
      ),
      child: Column(
        key: ValueKey(_mode),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 30,
              height: 1.1,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.0,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14.5,
              height: 1.48,
              color: AppColors.mutedText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _formCard() {
    return GlassPanel(
      padding: const EdgeInsets.all(20),
      borderRadius: 28,
      blur: 24,
      opacity: 0.82,
      borderColor: Colors.white.withValues(alpha: 0.92),
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ModeToggle(mode: _mode, onChanged: _setMode),
              const SizedBox(height: 20),

              _Collapsible(
                visible: _isRegister,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _AuthField(
                    controller: _nameController,
                    label: 'Full name',
                    hint: 'Juan Dela Cruz',
                    icon: Icons.person_outline_rounded,
                    autofillHints: const [AutofillHints.name],
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (!_isRegister) return null;
                      if (value == null || value.trim().isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                ),
              ),

              _AuthField(
                controller: _emailController,
                label: 'Email',
                hint: 'you@example.com',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required';
                  }
                  if (!value.contains('@')) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _AuthField(
                controller: _passwordController,
                label: 'Password',
                hint: _isRegister ? 'At least 6 characters' : 'Enter your password',
                icon: Icons.lock_outline_rounded,
                obscure: _hidePassword,
                autofillHints: [
                  _isRegister
                      ? AutofillHints.newPassword
                      : AutofillHints.password,
                ],
                textInputAction:
                    _isRegister ? TextInputAction.next : TextInputAction.done,
                onSubmitted: _isRegister ? null : (_) => _submit(),
                suffix: IconButton(
                  tooltip: _hidePassword ? 'Show password' : 'Hide password',
                  icon: Icon(
                    _hidePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.mutedText,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _hidePassword = !_hidePassword),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  if (_isRegister && value.length < 6) {
                    return 'At least 6 characters';
                  }
                  return null;
                },
              ),

              _Collapsible(
                visible: !_isRegister,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _loading ? null : _forgotPassword,
                    child: const Text('Forgot password?'),
                  ),
                ),
              ),

              _Collapsible(
                visible: _isRegister,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _StrengthMeter(score: _passwordScore),
                      const SizedBox(height: 14),
                      _AuthField(
                        controller: _confirmController,
                        label: 'Confirm password',
                        hint: 'Re-enter your password',
                        icon: Icons.lock_reset_rounded,
                        obscure: _hidePassword,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        validator: (value) {
                          if (!_isRegister) return null;
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: _isRegister ? 22 : 10),
              GoldButton(
                label: _isRegister ? 'Create account' : 'Sign in',
                icon: Icons.arrow_forward_rounded,
                loading: _loading,
                onPressed: _loading ? null : _submit,
              ),

              _Collapsible(
                visible: _isRegister,
                child: const Padding(
                  padding: EdgeInsets.only(top: 14),
                  child: Text(
                    'For Bulacan State University students.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1.45,
                      color: AppColors.mutedText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _switchPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isRegister ? 'Already have an account?' : 'New to BorrowIT?',
          style: const TextStyle(color: AppColors.mutedText),
        ),
        TextButton(
          onPressed: () =>
              _setMode(_isRegister ? AuthMode.signIn : AuthMode.register),
          child: Text(_isRegister ? 'Sign in' : 'Create an account'),
        ),
      ],
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final AuthMode mode;
  final ValueChanged<AuthMode> onChanged;

  const _ModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isRegister = mode == AuthMode.register;
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.field.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment:
                isRegister ? Alignment.centerRight : Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: const LinearGradient(
                    colors: [AppColors.universityRed, AppColors.maroonRuby],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.universityRed.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              _segment('Sign in', !isRegister, () => onChanged(AuthMode.signIn)),
              _segment(
                'Register',
                isRegister,
                () => onChanged(AuthMode.register),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _segment(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected ? Colors.white : AppColors.mutedText,
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}

class _Collapsible extends StatelessWidget {
  final bool visible;
  final Widget child;

  const _Collapsible({required this.visible, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: visible ? 1 : 0,
          child: visible
              ? child
              : const SizedBox(width: double.infinity, height: 0),
        ),
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscure;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;

  const _AuthField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscure = false,
    this.suffix,
    this.validator,
    this.textInputAction,
    this.autofillHints,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      validator: validator,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      onFieldSubmitted: onSubmitted,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: const TextStyle(
        color: AppColors.darkText,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.universityRed, size: 20),
        suffixIcon: suffix,
      ),
    );
  }
}

class _StrengthMeter extends StatelessWidget {
  final int score;

  const _StrengthMeter({required this.score});

  @override
  Widget build(BuildContext context) {
    const labels = ['', 'Weak', 'Fair', 'Good', 'Strong'];
    const colors = [
      Colors.transparent,
      AppColors.brightRed,
      Color(0xFFD9822B),
      Color(0xFF4C9A2A),
      AppColors.green,
    ];
    final color = colors[score];

    return Row(
      children: [
        for (var i = 1; i <= 4; i++) ...[
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: i <= score
                    ? color
                    : AppColors.darkText.withValues(alpha: 0.10),
              ),
            ),
          ),
          const SizedBox(width: 5),
        ],
        const SizedBox(width: 4),
        SizedBox(
          width: 52,
          child: Text(
            score == 0 ? 'Strength' : labels[score],
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: score == 0 ? AppColors.mutedText : color,
            ),
          ),
        ),
      ],
    );
  }
}
