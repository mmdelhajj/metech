import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:active_ecommerce_cms_demo_app/l10n/app_localizations.dart';

import '../my_theme.dart';

/// Description widget with the three behaviours Muhammad asked for:
///
///   * No description (null or whitespace) → renders nothing at all (no
///     "No Description" empty state, no orphaned "View More" button).
///   * Short description (fits within ~50% of the viewport height) → shows
///     the full text, no button.
///   * Long description → caps the visible area at 50% viewport, shows a
///     "View more / Show less" toggle that the user can expand.
///
/// Overflow detection runs once after the first layout via a hidden offstage
/// measure pass — we render the Html at natural width with no height bound,
/// read its `RenderBox.size.height`, then decide whether to clamp + show the
/// toggle. No measurement work happens on subsequent rebuilds.
class SmartHtmlDescription extends StatefulWidget {
  final String? html;

  /// Fraction of the screen height to use as the collapsed cap. Defaults to
  /// 0.5 — Muhammad's "maximum 50% length of the single screen".
  final double maxFraction;

  const SmartHtmlDescription({
    super.key,
    required this.html,
    this.maxFraction = 0.5,
  });

  @override
  State<SmartHtmlDescription> createState() => _SmartHtmlDescriptionState();
}

class _SmartHtmlDescriptionState extends State<SmartHtmlDescription> {
  final _measureKey = GlobalKey();
  double? _measuredHeight;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  void _measure() {
    final ctx = _measureKey.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    if (!mounted) return;
    setState(() => _measuredHeight = box.size.height);
  }

  @override
  Widget build(BuildContext context) {
    final raw = widget.html?.trim() ?? '';
    if (raw.isEmpty) return const SizedBox.shrink();

    final threshold = MediaQuery.of(context).size.height * widget.maxFraction;
    final knownHeight = _measuredHeight;
    final overflows = knownHeight != null && knownHeight > threshold;
    final clampNow = overflows && !_expanded;

    final desc = Html(data: raw);

    // While we don't yet know the natural height, render once offstage to
    // measure. After we know it, drop the offstage pass entirely.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (knownHeight == null)
          Offstage(
            offstage: true,
            child: Container(key: _measureKey, child: desc),
          ),
        ClipRect(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: clampNow ? threshold : double.infinity,
              ),
              child: desc,
            ),
          ),
        ),
        if (overflows)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => setState(() => _expanded = !_expanded),
              child: Text(
                _expanded
                    ? AppLocalizations.of(context)!.show_less_ucf
                    : AppLocalizations.of(context)!.view_more,
                style: TextStyle(
                  color: MyTheme.font_grey,
                  fontSize: 11,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
