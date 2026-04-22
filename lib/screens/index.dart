import 'package:active_ecommerce_cms_demo_app/helpers/addons_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/auth_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/business_setting_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/system_config.dart';
import 'package:active_ecommerce_cms_demo_app/presenter/currency_presenter.dart';
import 'package:active_ecommerce_cms_demo_app/providers/locale_provider.dart';
import 'package:active_ecommerce_cms_demo_app/screens/main.dart';
import 'package:active_ecommerce_cms_demo_app/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Index extends StatefulWidget {
  final bool? goBack;
  const Index({super.key, this.goBack = true});
  @override
  State<Index> createState() => _IndexState();
}

class _IndexState extends State<Index> {
  Future<String?> getSharedValueHelperData(BuildContext context) async {
    access_token.load().whenComplete(() {
      AuthHelper().fetchAndSet();
    });
    AddonsHelper().setAddonsData();
    BusinessSettingHelper().setBusinessSettingData();
    await app_language.load();
    await app_mobile_language.load();
    await app_language_rtl.load();
    await system_currency.load();
    if (!context.mounted) return app_mobile_language.$;
    Provider.of<CurrencyPresenter>(context, listen: false).fetchListData();

    return app_mobile_language.$;
  }

  @override
  @override
  void initState() {
    super.initState();
    _initData();
  }

  String? _errorMessage;

  Future<void> _initData() async {
    try {
      await getSharedValueHelperData(context);
      if (!mounted) return;
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      SystemConfig.isShownSplashScreed = true;

      Provider.of<LocaleProvider>(
        context,
        listen: false,
      ).setLocale(app_mobile_language.$!);

      setState(() {});
    } catch (e, stack) {
      _errorMessage = "INIT ERROR:\n$e\n\n${stack.toString().split('\n').take(5).join('\n')}";
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemConfig.context ??= context;
    if (_errorMessage != null) {
      return MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.red,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: SelectableText(
                _errorMessage!,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ),
      );
    }
    return Scaffold(
      body: SystemConfig.isShownSplashScreed
          ? Main(goBack: widget.goBack ?? true)
          : SplashScreen(),
    );
  }
}
