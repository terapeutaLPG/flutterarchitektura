import 'package:filmy_pl/services/api_service.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  String? _message;
  bool _sent = false;
  Future<void> _send() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final result = await ApiService.forgotPassword(_emailCtrl.text.trim());
      setState(() {
        _sent = true;
        _message = result['message'] ?? result['error'] ?? 'Wyslano';
      });
    } catch (e) {
      setState(() => _message = 'Blad polaczenia z serwerem');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0C12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0C12),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Reset hasla',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Center(
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFF39D3FF).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF39D3FF).withOpacity(0.4),
                    ),
                  ),
                  child: const Icon(
                    Icons.lock_reset_rounded,
                    color: Color(0xFF39D3FF),
                    size: 38,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Nie pamietasz hasla?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Podaj swoj email, wyslemy link do resetu',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 40),
              if (_message != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _sent
                        ? const Color(0xFF39D3FF).withOpacity(0.15)
                        : const Color(0xFFFF6B7A).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _sent
                          ? const Color(0xFF39D3FF).withOpacity(0.4)
                          : const Color(0xFFFF6B7A).withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _sent
                            ? Icons.check_circle_outline
                            : Icons.error_outline,
                        color: _sent
                            ? const Color(0xFF39D3FF)
                            : const Color(0xFFFF6B7A),
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(_message!,
                            style: TextStyle(
                                color: _sent
                                    ? const Color(0xFF39D3FF)
                                    : const Color(0xFFFF6B7A),
                                fontSize: 13)),
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
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: Color(0xFFA2A8B8),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _loading ? null : _send,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation(Color(0xFF0A0C12))),
                      )
                    : const Text('Wyslij link'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
