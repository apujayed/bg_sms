import 'dart:async';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter/material.dart';
import 'package:sms/sms.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  runApp(const MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );
  service.startService();
}

bool onIosBackground(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  print('FLUTTER BACKGROUND FETCH');

  return true;
}

void onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  // For flutter prior to version 3.0.0
  // We have to register the plugin manually

  // SharedPreferences preferences = await SharedPreferences.getInstance();
  // await preferences.setString("hello", "world");
  // SmsReceiver receiver = new SmsReceiver();
  // receiver.onSmsReceived.listen((SmsMessage msg) => print(msg.body));
  Timer.periodic(Duration(seconds: 2), (timer) {
   SmsReceiver receiver = new SmsReceiver();
   receiver.onSmsReceived.listen((SmsMessage msg) => print(msg.body));
  });
  // if (service is AndroidServiceInstance) {
  //   service.on('setAsForeground').listen((event) {
  //     service.setAsForegroundService();
  //   });

  //   service.on('setAsBackground').listen((event) {
  //     service.setAsBackgroundService();
  //   });
  // }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: SmsGet());
  }
}

class SmsGet extends StatefulWidget {
  const SmsGet({Key? key}) : super(key: key);

  @override
  State<SmsGet> createState() => _SmsGetState();
}

class _SmsGetState extends State<SmsGet> {
  var sms = [];
  @override
  void initState() {
    super.initState();
    startService();
  }

  startService() {
    SmsReceiver receiver = SmsReceiver();
    receiver.onSmsReceived!.listen((SmsMessage msg) {
      print('Sms received: ${msg.body}');

   
    });
  }

  // sendSmsToServer(String num, amount) async {
  //   var urlx = 'http://server.fahimtraders.com/smssend';
  //   var url = Uri.parse(urlx);

  //   var response = await http.post(
  //     url,
  //     body: {"number": num, "amount": amount},
  //   );
  //   print(response.body);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text('Sms Service', style: TextStyle(fontSize: 30))),
    );
  }
}
