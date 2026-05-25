import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../custom/box_decorations.dart';
import '../../data_model/product_details_response.dart';
import '../../helpers/recently_viewed_history.dart';
import '../../helpers/shared_value_helper.dart';
import '../../my_theme.dart';
import '../../repositories/product_repository.dart';
import '../product/product_details/product_details.dart';

/// Horizontal scroll row of products the user has recently opened.
///
/// Reads slugs from [RecentlyViewedHistory], fetches each product's details
/// through [ProductRepository.getProductDetails], and renders cards in the
/// order they were last viewed. Hides itself entirely (returns
/// [SizedBox.shrink]) when there's nothing to show or the fetch fails — we
/// don't want an empty "Your recently viewed items" header sitting on the
/// home screen.
class RecentlyViewedRow extends StatefulWidget {
  const RecentlyViewedRow({super.key});

  @override
  State<RecentlyViewedRow> createState() => _RecentlyViewedRowState();
}

/// Pairs a fetched product with the slug we originally stored. The slug is
/// what the product details screen needs for navigation, and `DetailedProduct`
/// doesn't expose it directly — so we carry it alongside.
class _RecentlyViewedItem {
  final String slug;
  final DetailedProduct product;
  const _RecentlyViewedItem(this.slug, this.product);
}

class _RecentlyViewedRowState extends State<RecentlyViewedRow> {
  /// Successfully fetched products, in display order (newest first).
  final List<_RecentlyViewedItem> _items = [];

  /// True until the first fetch attempt finishes. While true we render
  /// nothing — the section appears once we know we actually have items.
  bool _loading = true;

  /// True if anything went wrong loading history or fetching products.
  /// On error we collapse the row to keep the home screen clean.
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final slugs = await RecentlyViewedHistory.read();
      if (slugs.isEmpty) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      // Fetch all details in parallel; preserve the original slug order so
      // the most-recently-viewed product appears first.
      final repo = ProductRepository();
      final results = await Future.wait(
        slugs.map((slug) async {
          try {
            final res = await repo.getProductDetails(
              slug: slug,
              userId: user_id.$,
            );
            final list = res.detailedProducts;
            if (list != null && list.isNotEmpty) {
              return _RecentlyViewedItem(slug, list.first);
            }
          } catch (_) {/* swallow per-item errors */}
          return null;
        }),
      );

      final fetched = <_RecentlyViewedItem>[];
      for (final item in results) {
        if (item != null) fetched.add(item);
      }

      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(fetched);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hide the section entirely when we have nothing useful to show. This
    // covers: still loading on first paint, empty history, fetch error, and
    // history present but every fetch returned null.
    if (_loading || _failed || _items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: MyTheme.mainColor,
      padding: EdgeInsets.fromLTRB(0, 12.h, 0, 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Your recently viewed items',
                    style: MyTheme.homeText_heding(),
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 2.h,
                    ),
                    child: Text(
                      'See all',
                      style: TextStyle(
                        color: MyTheme.accent_color,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 180,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              scrollDirection: Axis.horizontal,
              itemCount: _items.length,
              separatorBuilder: (_, __) => SizedBox(width: 10.w),
              itemBuilder: (context, index) {
                final item = _items[index];
                return _RecentlyViewedCard(
                  slug: item.slug,
                  product: item.product,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact 140-wide card: image (top ~60%), 2-line title, bold price, and
/// optional struck-through original price when the product is discounted.
class _RecentlyViewedCard extends StatelessWidget {
  final String slug;
  final DetailedProduct product;

  const _RecentlyViewedCard({required this.slug, required this.product});

  @override
  Widget build(BuildContext context) {
    // 180 total height, image takes ~60% (108) and leaves room for title +
    // price beneath it. The wishlist heart is a no-op for now per spec.
    const double cardHeight = 180;
    const double imageHeight = cardHeight * 0.60; // 108

    final hasDiscount = product.hasDiscount == true &&
        (product.strokedPrice?.isNotEmpty ?? false);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetails(slug: slug),
          ),
        );
      },
      child: Container(
        width: 140,
        decoration: BoxDecorations.buildBoxDecoration_1(radius: 8.0),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: imageHeight,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CachedNetworkImage(
                      imageUrl: product.thumbnailImage ?? '',
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Image.asset(
                        'assets/placeholder_rectangle.png',
                        fit: BoxFit.cover,
                      ),
                      errorWidget: (_, __, ___) => Image.asset(
                        'assets/placeholder_rectangle.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: InkWell(
                      onTap: () {},
                      customBorder: const CircleBorder(),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: MyTheme.white.withValues(alpha: 0.85),
                        ),
                        child: Icon(
                          Icons.favorite_border,
                          size: 16,
                          color: MyTheme.font_grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: MyTheme.dark_font_grey,
                        fontSize: 12.sp,
                        height: 1.2,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Flexible(
                          child: Text(
                            product.mainPrice ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: MyTheme.price_color,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (hasDiscount) ...[
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              product.strokedPrice ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: MyTheme.font_grey,
                                fontSize: 11.sp,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
