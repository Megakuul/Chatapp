import 'package:flutter/material.dart';
import 'package:frontend/apiConnector.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import 'chat.dart';

void main() {
  runApp(const MyApp());
}

const String api_base_url = String.fromEnvironment("API_URL", defaultValue: "https://chatapi.megakuul.ch");

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: mainPage(),
    );
  }
}

class mainPage extends StatefulWidget {

  @override
  State<mainPage> createState() => _mainPageState();
}

class _mainPageState extends State<mainPage> {

  TextEditingController pinControlr = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(54,57,62,1),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(100),
          alignment: Alignment.center,
          height: 400,
          width: 500,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            color: Color.fromRGBO(66,69,73, 1)
          ),
          child: PinCodeTextField(
            controller: pinControlr,
            appContext: context,
            textStyle: const TextStyle(color: Colors.white),
            length: 5,
            cursorColor: Colors.white,
            animationType: AnimationType.fade,
            animationDuration: const Duration(milliseconds: 30),
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(5),
              fieldHeight: 50,
              fieldWidth: 40,
              selectedColor: Colors.white,
              activeColor: Colors.green,
            ),
            onCompleted: (text) {
              pinControlr.clear();
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                createSession("$api_base_url/createsession", text);
                return chat(code: text);
              }));
            },
            onChanged: (text) {}
          ),
        )
      ),
    );
  }
}


