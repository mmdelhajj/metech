import 'dart:async';

import 'package:active_ecommerce_cms_demo_app/data_model/flash_deal_response.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_cms_demo_app/l10n/app_localizations.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/presenter/home_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// Otto-style flash-deal promo carousel (redesign brief, Muhammad 2026-06-02).
///
/// Each card is one admin-managed Flash Deal. Everything shown is driven by
/// the Active eCommerce admin — title, end date (countdown), per-deal
/// background_color, and the products (whose discount feeds the badge). The
/// only hard-coded value is the fallback accent (the MeTech logo blue) used
/// when the admin leaves background_color blank.
///
/// Layout per card (matches the Otto reference):
///   • white surface, rounded, soft shadow, reduced height
///   • discount % badge (blue block, white text) — top-left
///   • deal title — top-right
///   • countdown — bottom-left (live HH:MM:SS when < 1 day, else expiry date)
///   • "Shop More ›" button (blue block) — bottom-right
///   • card narrower than the screen so the next deal peeks in (carousel)
class FlashDealBanner extends StatelessWidget {
  final HomePresenter? homeData;

  const FlashDealBanner({super.key, this.homeData});

  @override
  Widget build(BuildContext context) {
    if (homeData == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final List<FlashDealResponseDatum> deals = homeData!.flashDealList
        .where(
          (d) =>
              d.date != null &&
              DateTime.fromMillisecondsSinceEpoch(
                d.date! * 1000,
              ).isAfter(now),
        )
        .toList();

    if (deals.isEmpty) {
      // Still loading the first payload → shimmer; otherwise hide silently.
      if (homeData!.isFlashDealInitial) {
        return Padding(
          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
          child: ShimmerHelper().buildBasicShimmer(height: 120.h, radius: 14.r),
        );
      }
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 0, 12.h),
      child: SizedBox(
        height: 120.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: deals.length,
          padding: EdgeInsets.only(right: 16.w),
          separatorBuilder: (_, __) => SizedBox(width: 10.w),
          itemBuilder: (_, i) => _DealCard(deal: deals[i]),
        ),
      ),
    );
  }
}

class _DealCard extends StatefulWidget {
  final FlashDealResponseDatum deal;

  const _DealCard({required this.deal});

  @override
  State<_DealCard> createState() => _DealCardState();
}

class _DealCardState extends State<_DealCard> {
  Timer? _ticker;
  int? _discountPercent; // null = no discount → badge hidden

  @override
  void initState() {
    super.initState();

    // A live 1-second ticker only when the deal ends within 24h — otherwise we
    // show a static expiry date and don't need to rebuild every second.
    final remaining = _remaining();
    if (remaining != null &&
        remaining > Duration.zero &&
        remaining < const Duration(days: 1)) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }

    _discountPercent = _maxPercentDiscount();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  /// Biggest percent discount across the deal's products (already in the home
  /// payload — no extra request). Returns null when none, so the badge hides.
  int? _maxPercentDiscount() {
    final products = widget.deal.products?.products ?? const [];
    int best = 0;
    for (final p in products) {
      if (p.discountType == 'percent' && p.discount != null) {
        final v = p.discount!.round();
        if (v > best) best = v;
      }
    }
    return best > 0 ? best : null;
  }

  Duration? _remaining() {
    if (widget.deal.date == null) return null;
    final end = DateTime.fromMillisecondsSinceEpoch(widget.deal.date! * 1000);
    return end.difference(DateTime.now());
  }

  /// Admin background_color ("#0091e0" / "0091e0") → Color, else logo blue.
  Color get _accent {
    final raw = widget.deal.backgroundColor?.trim();
    if (raw != null && raw.isNotEmpty) {
      var hex = raw.replaceAll('#', '');
      if (hex.length == 3) {
        hex = hex.split('').map((c) => '$c$c').join();
      }
      if (hex.length == 6) {
        final v = int.tryParse(hex, radix: 16);
        if (v != null) return Color(0xFF000000 | v);
      }
    }
    return MyTheme.logo_blue;
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// < 1 day → live "HH:MM:SS"; ≥ 1 day → "DD Mon YYYY" expiry date.
  String _countdownLabel() {
    final r = _remaining();
    if (r == null || r <= Duration.zero) return '--:--:--';
    if (r < const Duration(days: 1)) {
      String two(int n) => n.toString().padLeft(2, '0');
      return '${two(r.inHours)}:${two(r.inMinutes % 60)}:${two(r.inSeconds % 60)}';
    }
    final end = DateTime.fromMillisecondsSinceEpoch(widget.deal.date! * 1000);
    return '${end.day} ${_months[end.month - 1]} ${end.year}';
  }

  void _open() {
    if (widget.deal.slug != null) {
      GoRouter.of(context).push('/flash-deal/${widget.deal.slug}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accent;
    final cardWidth = MediaQuery.of(context).size.width * 0.8;

    return GestureDetector(
      onTap: _open,
      child: Container(
        width: cardWidth,
        decoration: BoxDecoration(
          color: MyTheme.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: MyTheme.blackColour.withValues(alpha: 0.10),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: discount badge + title ──────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_discountPercent != null) ...[
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      '$_discountPercent%\nOFF',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        height: 1.1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                ],
                Expanded(
                  child: Text(
                    widget.deal.title ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: MyTheme.dark_font_grey,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // ── Bottom row: countdown (left) + Shop More button (right) ───
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 14.sp, color: accent),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          _countdownLabel(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: accent,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.shop_more_ucf,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      const Icon(Icons.arrow_forward_ios,
                          size: 10, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
