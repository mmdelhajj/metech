import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Tracks the user's recently viewed product slugs locally so the home screen
/// can show a "Your recently viewed items" row.
///
/// Storage: a JSON-encoded list of product slugs under
/// [_kRecentlyViewedKey] in [SharedPreferences]. The list is bounded to
/// [_maxItems] entries, newest first, with duplicates removed when a slug is
/// re-pushed.
///
/// The product details widget identifies products by slug (see
/// `ProductDetails.slug`), so this helper stores slugs rather than numeric
/// ids — slugs are also what the product details API requires for fetching.
class RecentlyViewedHistory {
  RecentlyViewedHistory._();

  static const String _kRecentlyViewedKey = 'recently_viewed_product_ids';
  static const int _maxItems = 10;

  /// Push [productSlug] onto the front of the history. If the slug is already
  /// present, it is moved to the front (deduped). The list is trimmed to
  /// [_maxItems] entries.
  ///
  /// Empty/blank slugs are ignored so we never persist a useless entry.
  static Future<void> push(String productSlug) async {
    if (productSlug.trim().isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final current = _decode(prefs.getString(_kRecentlyViewedKey));

    current.removeWhere((s) => s == productSlug);
    current.insert(0, productSlug);

    final trimmed = current.length > _maxItems
        ? current.sublist(0, _maxItems)
        : current;

    await prefs.setString(_kRecentlyViewedKey, jsonEncode(trimmed));
  }

  /// Returns the slugs of recently viewed products, newest first. Returns an
  /// empty list when nothing has been viewed yet or the stored value is
  /// malformed.
  static Future<List<String>> read() async {
    final prefs = await SharedPreferences.getInstance();
    return _decode(prefs.getString(_kRecentlyViewedKey));
  }

  static List<String> _decode(String? raw) {
    if (raw == null || raw.isEmpty) return <String>[];
    try {
      final parsed = jsonDecode(raw);
      if (parsed is List) {
        return parsed.map((e) => e.toString()).toList();
      }
    } catch (_) {
      // Corrupt/legacy payload — fall through to empty.
    }
    return <String>[];
  }
}
