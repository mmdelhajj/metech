import 'package:active_ecommerce_cms_demo_app/helpers/system_config.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/screens/product/product_details/product_details.dart';
import 'package:active_ecommerce_cms_demo_app/ui_elements/discount_badge.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MiniProductCard extends StatefulWidget {
  final int? id;
  final String slug;
  final String? image;
  final String? name;
  final String? mainPrice;
  final String? strokedPrice;
  final bool? hasDiscount;
  final bool? isWholesale;
  final dynamic discount;
  const MiniProductCard({
    super.key,
    this.id,
    required this.slug,
    this.image,
    this.name,
    this.mainPrice,
    this.strokedPrice,
    this.hasDiscount,
    this.isWholesale = false,
    this.discount,
  });

  @override
  State<MiniProductCard> createState() => _MiniProductCardState();
}

class _MiniProductCardState extends State<MiniProductCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return ProductDetails(slug: widget.slug);
            },
          ),
        );
      },
      child: SizedBox(
       // color: Colors.red,
        width: 135.w,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: (widget.image == null || widget.image!.isEmpty)
                              ? Image.asset(
                                  'assets/placeholder.png',
                                  fit: BoxFit.cover,
                                )
                              : CachedNetworkImage(
                                  imageUrl: widget.image!,
                                  fit: BoxFit.cover,
                                  memCacheWidth: 360,
                                  fadeInDuration:
                                      const Duration(milliseconds: 120),
                                  placeholder: (context, url) => Container(
                                    color: const Color(0xFFEFEFEF),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Image.asset(
                                    'assets/placeholder.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),
                      if (_hasRealDiscount())
                        Positioned(
                          top: 6,
                          left: 6,
                          child: DiscountBadge(label: _discountLabel()),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(8.w, 10.h, 8.w, 4.h),
                  child: Text(
                    widget.name!,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: MyTheme.productNameStyle(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 0),
                  child: Text(
                    SystemConfig.systemCurrency != null
                        ? widget.mainPrice!.replaceAll(
                            SystemConfig.systemCurrency!.code!,
                            SystemConfig.systemCurrency!.symbol!,
                          )
                        : widget.mainPrice!,
                    maxLines: 1,
                    style: MyTheme.priceText(color: MyTheme.price_color),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _hasRealDiscount() {
    final discountStr = widget.discount?.toString().trim() ?? '';
    final digits = RegExp(r'\d+\.?\d*').firstMatch(discountStr)?.group(0);
    final discountValue = double.tryParse(digits ?? '') ?? 0;
    if (discountValue > 0) return true;
    if (widget.hasDiscount == true &&
        widget.strokedPrice != null &&
        widget.mainPrice != null &&
        widget.strokedPrice!.trim().isNotEmpty &&
        widget.strokedPrice != widget.mainPrice) {
      return true;
    }
    return false;
  }

  String _discountLabel() {
    final discountStr = widget.discount?.toString().trim() ?? '';
    final digits = RegExp(r'\d+\.?\d*').firstMatch(discountStr)?.group(0);
    if (digits != null && digits.isNotEmpty) {
      return '$digits% OFF';
    }
    return 'SALE';
  }
}
