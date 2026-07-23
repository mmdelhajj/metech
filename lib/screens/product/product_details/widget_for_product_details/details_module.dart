// Otto-style structured "Details" module for the product page.
//
// Renders three default-collapsed sub-sections:
//   - FARBE & MATERIAL
//   - TECHNISCHE DATEN
//   - Wichtige Informationen
//
// In Phase 1 the data comes from whatever the existing product model already
// exposes (colors, brand, choice_options, etc.). Once the regulatory columns
// land on the products table (Phase 2 migration) the matching fields can be
// added to the data model and surfaced here without changing the widget API.

import 'package:active_ecommerce_cms_demo_app/data_model/product_details_response.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DetailsModule extends StatelessWidget {
  final DetailedProduct product;

  const DetailsModule({super.key, required this.product});

  // ---- Field extraction helpers ----------------------------------------------

  /// Pull colour names. The `colors` field is a `List<dynamic>` that the
  /// existing model fills with the raw colour hex/name strings coming from
  /// the API. We render whichever non-empty entries exist.
  List<String> _colorValues() {
    final cs = product.colors;
    if (cs == null) return const [];
    return cs
        .map((c) => c?.toString().trim() ?? '')
        .where((c) => c.isNotEmpty)
        .toList();
  }

  /// Pick choice-options that look like they belong in FARBE & MATERIAL.
  /// We match on the localized title (case-insensitive).
  List<ChoiceOption> _choiceOptionsMatching(List<String> needles) {
    final co = product.choiceOptions;
    if (co == null) return const [];
    return co.where((opt) {
      final title = (opt.title ?? '').toLowerCase();
      return needles.any((n) => title.contains(n));
    }).toList();
  }

  /// Everything in choice_options that didn't already get consumed by the
  /// colour / material section. These go under TECHNISCHE DATEN.
  List<ChoiceOption> _remainingChoiceOptions(List<ChoiceOption> consumed) {
    final co = product.choiceOptions;
    if (co == null) return const [];
    final consumedTitles = consumed.map((c) => c.title).toSet();
    return co.where((opt) => !consumedTitles.contains(opt.title)).toList();
  }

  String _joinOptions(ChoiceOption opt) {
    final opts = opt.options ?? const [];
    return opts.where((o) => o.trim().isNotEmpty).join(', ');
  }

  static const _farbeMaterialNeedles = <String>[
    'farbe',
    'color',
    'colour',
    'material',
    'stoff',
  ];

  // ---- Section builders ------------------------------------------------------

  List<_KV> _farbeMaterialRows() {
    final rows = <_KV>[];

    final colors = _colorValues();
    if (colors.isNotEmpty) {
      rows.add(_KV('Color', colors.join(', ')));
    }

    final matched = _choiceOptionsMatching(_farbeMaterialNeedles);
    for (final opt in matched) {
      final value = _joinOptions(opt);
      if (value.isNotEmpty) {
        rows.add(_KV(opt.title ?? '', value));
      }
    }

    return rows;
  }

  List<_KV> _technischeDatenRows(List<ChoiceOption> alreadyConsumed) {
    // Field order requested by customer Zilin (2026-07-20):
    //   1. Article Features  2. Brand  3. Unit  4. OE/OEM Reference No.  5. Condition
    final rows = <_KV>[];

    // 1. Article Features
    final features = product.articleFeatures;
    if (features != null && features.trim().isNotEmpty) {
      rows.add(_KV('Article Features', features.trim()));
    }

    // 2. Brand
    final brandName = product.brand?.name;
    if (brandName != null && brandName.trim().isNotEmpty) {
      rows.add(_KV('Brand', brandName.trim()));
    }

    // 3. Unit
    final unit = product.unit;
    if (unit != null && unit.trim().isNotEmpty) {
      rows.add(_KV('Unit', unit.trim()));
    }

    // 4. OE / OEM reference number(s) — backed by products.oe_number.
    final oe = product.oeNumber;
    if (oe != null && oe.trim().isNotEmpty) {
      rows.add(_KV('OE/OEM Reference Number(s)', oe.trim()));
    }

    // 5. Condition
    final condition = product.condition;
    if (condition != null && condition.trim().isNotEmpty) {
      rows.add(_KV('Condition', condition.trim()));
    }

    // Any remaining choice options that weren't colour/material.
    for (final opt in _remainingChoiceOptions(alreadyConsumed)) {
      final value = _joinOptions(opt);
      if (value.isNotEmpty) {
        rows.add(_KV(opt.title ?? '', value));
      }
    }

    return rows;
  }

  List<_KV> _wichtigeInformationenRows() {
    // Phase 1: the existing model doesn't carry Entsorgungshinweis /
    // Produktsicherheit yet. The section is intentionally returned empty
    // and the parent will skip rendering it. Once the backend columns are
    // added (Phase 2) we just append rows here.
    return const <_KV>[];
  }

  // ---- UI --------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final farbeMaterial = _farbeMaterialRows();
    final consumed = _choiceOptionsMatching(_farbeMaterialNeedles);
    final technische = _technischeDatenRows(consumed);
    final wichtige = _wichtigeInformationenRows();

    final sections = <Widget>[];
    if (farbeMaterial.isNotEmpty) {
      sections.add(_buildSection(context, 'Color & Material', farbeMaterial));
    }
    if (technische.isNotEmpty) {
      sections.add(_buildSection(context, 'Product Specifications', technische));
    }
    if (wichtige.isNotEmpty) {
      sections.add(
        _buildSection(context, 'Important Information', wichtige),
      );
    }

    if (sections.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(top: 10.h),
      decoration: BoxDecoration(
        color: MyTheme.white,
        boxShadow: [
          BoxShadow(
            color: MyTheme.blackColour.withValues(alpha: 0.08),
            spreadRadius: 0,
            blurRadius: 16.r,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sections,
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<_KV> rows) {
    return Theme(
      // ExpansionTile pulls divider colours from the ambient theme; strip them
      // so the section blends with the surrounding card.
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16.w),
        childrenPadding: EdgeInsets.zero,
        initiallyExpanded: true,
        title: Text(
          title,
          style: TextStyle(
            color: MyTheme.dark_font_grey,
            fontFamily: 'Public Sans',
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            if (i == 0) _rowDivider(),
            _buildKeyValueRow(rows[i]),
            _rowDivider(),
          ],
        ],
      ),
    );
  }

  Widget _rowDivider() {
    // Theme-aware divider — swaps light/dark by reading MyTheme.font_grey
    // which `applyMode(Brightness.dark)` flips to a lighter grey.
    return Divider(
      height: 1,
      color: MyTheme.font_grey.withValues(alpha: 0.2),
    );
  }

  Widget _buildKeyValueRow(_KV row) {
    // Otto-style two-column row (Muhammad 2026-05-20):
    //   - left column: BOLD label using theme foreground
    //   - right column: normal-weight value (slightly muted)
    //   - thin theme-aware divider above + below each row
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140.w,
            child: Text(
              row.label,
              style: TextStyle(
                color: MyTheme.dark_font_grey,
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              row.value,
              style: TextStyle(
                color: MyTheme.font_grey,
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KV {
  final String label;
  final String value;
  const _KV(this.label, this.value);
}
