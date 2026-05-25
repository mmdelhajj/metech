import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Legal / informational footer rendered at the bottom of the home screen.
///
/// German market requires AGB and Impressum links to be reachable from every
/// commercial site. The remaining three (Datenschutz, Widerrufsrecht, Kontakt)
/// are conventional companions. Each entry opens the corresponding CMS page
/// via the device's external browser using [url_launcher] — the URLs are
/// placeholders that the shop owner will fill in under Active eCommerce CMS
/// admin → Pages.
///
/// Centralise the URL map at the top so changing endpoints is a one-line edit.
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  /// Label → URL. Order here drives the order shown in the UI.
  static const Map<String, String> _links = {
    'AGB': 'https://metech.com.lb/agb',
    'Impressum': 'https://metech.com.lb/impressum',
    'Datenschutz': 'https://metech.com.lb/datenschutz',
    'Widerrufsrecht': 'https://metech.com.lb/widerrufsrecht',
    'Kontakt': 'https://metech.com.lb/kontakt',
  };

  static const Color _textColor = Color(0xFF6B7280);
  static const Color _dividerColor = Color(0xFFE5E7EB);
  static const double _fontSize = 12.0;

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    // External browser keeps the in-app navigation stack clean and matches
    // the pattern used elsewhere in this codebase (see auth/login.dart).
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _buildLink(String label, String url) {
    return InkWell(
      onTap: () => _openLink(url),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: _fontSize,
            color: _textColor,
            decoration: TextDecoration.underline,
            decorationColor: _textColor,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final linkWidgets = _links.entries
        .map((e) => _buildLink(e.key, e.value))
        .toList(growable: false);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Divider(height: 1, thickness: 1, color: _dividerColor),
          const SizedBox(height: 16),
          // Wrap handles both wide (single row) and narrow (multi-row) layouts
          // without needing an explicit breakpoint.
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4.0,
            runSpacing: 4.0,
            children: linkWidgets,
          ),
          const SizedBox(height: 12),
          const Text(
            '© 2026 MeTech Store. Alle Rechte vorbehalten.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _fontSize,
              color: _textColor,
            ),
          ),
        ],
      ),
    );
  }
}
