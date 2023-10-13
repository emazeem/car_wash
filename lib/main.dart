import 'package:carwash/constants.dart';
import 'package:carwash/screen/Landing.dart';
import 'package:carwash/screen/Splash.dart';
import 'package:carwash/viewmodel/IndexViewModel.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

import 'package:flutter_localization/flutter_localization.dart';
void main() {
  runApp(const MyApp());
}
mixin AppLocale {
  static const String title = 'title';
  static const String thisIs = 'thisIs';

  static const Map<String, dynamic> EN = {
    title: 'Localization',
    thisIs: 'This is %a package, version %a.',
  };
  static const Map<String, dynamic> KM = {
    title: 'ការធ្វើមូលដ្ឋានីយកម្ម',
    thisIs: 'នេះគឺជាកញ្ចប់%a កំណែ%a.',
  };
  static const Map<String, dynamic> JA = {
    title: 'ローカリゼーション',
    thisIs: 'これは%aパッケージ、バージョン%aです。',
  };
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  String? osUserID;

  final FlutterLocalization _localization = FlutterLocalization.instance;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await initOneSignal(context);
    });



    _localization.init(
      mapLocales: [
        const MapLocale(
          'en',
          AppLocale.EN,
          countryCode: 'US',
          fontFamily: 'Font EN',
        ),
        const MapLocale(
          'km',
          AppLocale.KM,
          countryCode: 'KH',
          fontFamily: 'Font KM',
        ),
        const MapLocale(
          'ja',
          AppLocale.JA,
          countryCode: 'JP',
          fontFamily: 'Font JA',
        ),
      ],
      initLanguageCode: 'en',
    );
    _localization.onTranslatedLanguage = _onTranslatedLanguage;


    super.initState();
  }


  void _onTranslatedLanguage(Locale? locale) {
    setState(() {});
  }











  Future<void> initOneSignal(context) async {
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    OneSignal.shared.setAppId(Const.ONE_SIGNAL_APP_ID);
    OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
        print('Accepted permission $accepted');
      },
    );

    final status = await OneSignal.shared.getDeviceState();
    osUserID = status?.userId;
    //await ShPref.storeDeviceId(osUserID);

    await OneSignal.shared.promptUserForPushNotificationPermission(
      fallbackToSettings: true,
    );

    /// Calls when foreground notification arrives.
    OneSignal.shared.setNotificationWillShowInForegroundHandler(
            (handleForegroundNotifications) {});
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<IndexViewModel>(create: (context) {
          return IndexViewModel();
        }),
      ],
      child: MaterialApp(
        supportedLocales: _localization.supportedLocales,
        localizationsDelegates: _localization.localizationsDelegates,
        debugShowCheckedModeBanner: false,
        title: 'Car Wash',
        theme: ThemeData(
          appBarTheme: AppBarTheme(),
          inputDecorationTheme: InputDecorationTheme(
            suffixIconColor: Colors.black54,
            prefixIconColor: Colors.black54,
            iconColor: Colors.grey,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black45),
            ),
            labelStyle: TextStyle(color: Colors.black54),
            hintStyle: TextStyle(
              color: Colors.grey,
            ),
          ),

        ),
        initialRoute: 'splash',
        routes: {
          'splash': (context) => SplashScreen(),
        },
      ),
    );
  }
}


