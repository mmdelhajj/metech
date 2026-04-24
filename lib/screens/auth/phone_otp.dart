import 'dart:async';

import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/system_config.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/auth_repository.dart';
import 'package:flutter/material.dart';

class PhoneOtp extends StatefulWidget {
  final String? initialPhone;
  const PhoneOtp({super.key, this.initialPhone});

  @override
  State<PhoneOtp> createState() => _PhoneOtpState();
}

class _PhoneOtpState extends State<PhoneOtp> {
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _codeCtrl = TextEditingController();
  bool _codeSent = false;
  bool _busy = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    if (widget.initialPhone != null) _phoneCtrl.text = widget.initialPhone!;
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _phoneCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  void _startResendCooldown() {
    setState(() => _resendCooldown = 30);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_resendCooldown <= 1) {
        t.cancel();
        setState(() => _resendCooldown = 0);
      } else {
        setState(() => _resendCooldown--);
      }
    });
  }

  Future<void> _sendCode() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty) {
      ToastComponent.showDialog("Please enter your phone number");
      return;
    }
    setState(() => _busy = true);
    final res = await AuthRepository().verifyPhone(phone: phone);
    if (!mounted) return;
    setState(() => _busy = false);

    ToastComponent.showDialog(res["message"]?.toString() ?? "");
    if (res["result"] == true && res["step"] == "code_sent") {
      setState(() => _codeSent = true);
      _startResendCooldown();
    }
  }

  Future<void> _confirmCode() async {
    final phone = _phoneCtrl.text.trim();
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) {
      ToastComponent.showDialog("Please enter the verification code");
      return;
    }
    setState(() => _busy = true);
    final res = await AuthRepository().verifyPhone(
      phone: phone,
      verificationCode: code,
    );
    if (!mounted) return;
    setState(() => _busy = false);

    ToastComponent.showDialog(res["message"]?.toString() ?? "");
    if (res["result"] == true && res["step"] == "verified") {
      user_phone.$ = phone;
      user_phone.save();
      // Update in-memory user so the checkout pre-check doesn't re-prompt.
      SystemConfig.systemUser?.phoneVerified = true;
      SystemConfig.systemUser?.phone = phone;
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: MyTheme.dark_grey),
        title: Text(
          "Phone Verification",
          style: TextStyle(fontSize: 16, color: MyTheme.accent_color),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              _codeSent
                  ? "Enter the 6-digit code we sent to ${_phoneCtrl.text}"
                  : "Enter your phone number. We'll send you a verification code by SMS.",
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              enabled: !_codeSent,
              decoration: const InputDecoration(
                labelText: "Phone number (with country code, e.g. +9613...)",
                border: OutlineInputBorder(),
              ),
            ),
            if (_codeSent) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _codeCtrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: "Verification code",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _busy ? null : (_codeSent ? _confirmCode : _sendCode),
              style: ElevatedButton.styleFrom(
                backgroundColor: MyTheme.accent_color,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _busy
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _codeSent ? "Verify code" : "Send code",
                      style: const TextStyle(color: Colors.white),
                    ),
            ),
            if (_codeSent) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: (_busy || _resendCooldown > 0)
                    ? null
                    : _sendCode,
                child: Text(
                  _resendCooldown > 0
                      ? "Resend code in ${_resendCooldown}s"
                      : "Resend code",
                ),
              ),
              TextButton(
                onPressed: _busy
                    ? null
                    : () {
                        _cooldownTimer?.cancel();
                        setState(() {
                          _codeSent = false;
                          _codeCtrl.clear();
                          _resendCooldown = 0;
                        });
                      },
                child: const Text("Change phone number"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
