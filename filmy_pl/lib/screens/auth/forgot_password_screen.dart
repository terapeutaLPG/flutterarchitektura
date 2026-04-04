import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();

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
        title: const Text('Reset hasla',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: const SafeArea(
        child: SizedBox.expand(),
      ),
    );
  }
}
