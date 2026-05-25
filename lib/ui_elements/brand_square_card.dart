import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/screens/brand_products.dart';
import 'package:active_ecommerce_cms_demo_app/custom/box_decorations.dart';

class BrandSquareCard extends StatefulWidget {
  final int? id;
  final String slug;
  final String? image;
  final String? name;

  const BrandSquareCard({
    super.key,
    this.id,
    this.image,
    required this.slug,
    this.name,
  });

  @override
  State<BrandSquareCard> createState() => _BrandSquareCardState();
}

class _BrandSquareCardState extends State<BrandSquareCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return BrandProducts(slug: widget.slug);
            },
          ),
        );
      },
      child: Container(
        decoration: BoxDecorations.buildBoxDecoration_1(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Flexible(
              flex: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16),
                  bottom: Radius.zero,
                ),
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
                        errorWidget: (context, url, error) => Image.asset(
                          'assets/placeholder.png',
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
            SizedBox(
              height: 40,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  widget.name!,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(
                    color: MyTheme.font_grey,
                    fontSize: 14,
                    height: 1.6,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
