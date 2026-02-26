import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  Future<void> _register() async {
    if (_passCtrl.text != _pass2Ctrl.text) {
      setState(() => _error = 'Hasła nie są identyczne');
      return;
    }
    if (_passCtrl.text.length < 6) {
      setState(() => _error = 'Hasło musi mieć min. 6 znaków');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final result = await ApiService.register(
        _emailCtrl.text.trim(),
        _passCtrl.text,
      );
      if (!mounted) return;
      if (result['success'] == true) {
        // Auto-login po rejestracji
        final loginResult = await ApiService.login(
          _emailCtrl.text.trim(),
          _passCtrl.text,
        );
        if (!mounted) return;
        if (loginResult['success'] == true) {
          await AuthService.saveToken(
            loginResult['token'],
            loginResult['user']['email'],
          );
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        }
      } else {
        setState(() => _error = result['error'] ?? 'Błąd rejestracji');
      }
    } catch (e) {
      setState(() => _error = 'Błąd połączenia z serwerem');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0C12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Utwórz konto',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Zarejestruj się i zacznij oglądać',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 36),
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B7A).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFFFF6B7A).withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Color(0xFFFF6B7A), size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(_error!,
                            style: const TextStyle(
                                color: Color(0xFFFF6B7A), fontSize: 13)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined,
                      color: Color(0xFFA2A8B8)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passCtrl,
                obscureText: _obscure,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Hasło',
                  prefixIcon: const Icon(Icons.lock_outline,
                      color: Color(0xFFA2A8B8)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFFA2A8B8),
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _pass2Ctrl,
                obscureText: _obscure,
                style: const TextStyle(color: Colors.white),
                onSubmitted: (_) => _register(),
                decoration: const InputDecoration(
                  labelText: 'Potwierdź hasło',
                  prefixIcon: Icon(Icons.lock_outline,
                      color: Color(0xFFA2A8B8)),
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _loading ? null : _register,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation(Color(0xFF0A0C12)),
                        ),
                      )
                    : const Text('Zarejestruj się'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
