import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/apiConnector.dart';
import 'package:frontend/main.dart';

class chat extends StatefulWidget {
  final String code;

  const chat({required this.code});

  State<chat> createState() => _chatState();
}

class _chatState extends State<chat> {

  TextEditingController textControlr = TextEditingController();
  String api_url = "$api_base_url?code=";

  @override
  Widget build (BuildContext context) {
    api_url = "$api_base_url?code=${widget.code}";

    return Scaffold(
        backgroundColor: const Color.fromRGBO(54,57,62,1),
        body: Container(
          margin: const EdgeInsets.all(70),
          alignment: Alignment.center,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(borderRadius: BorderRadius.all(
              Radius.circular(12)),
              color: Color.fromRGBO(66,69,73, 1)
          ),
          child: Column(
            children: [
              Expanded(
                flex: 8,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Messages(),
                )
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.center,
                  child: TextField(
                    controller: textControlr,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                    decoration: InputDecoration(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width-400, maxHeight: 50),
                        icon: const Icon(Icons.send),
                        hintStyle: const TextStyle(color: Colors.white12, fontSize: 16),
                        hintText: "Write what comes to your mind",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)
                        )
                    ),
                    onSubmitted: (text) async {
                      if (await postMessage(api_url, {text: text})) {
                        textControlr.clear();
                        return;
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.red,
                              content: Text("Failed to send Message"),
                            )
                        );
                      }
                    },
                  ),
                )
              )
            ],
          ),
        )
    );
  }
}

class Messages extends StatelessWidget {
  const Messages({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 200, bottom: 200),
          height: 300,
          width: 1200,
          color: Colors.white,
          child: Text("Hallooo"),
        ),
        Container(
          margin: EdgeInsets.only(top: 200, bottom: 200),
          height: 300,
          width: 1200,
          color: Colors.white,
          child: Text("Hallooo"),
        ),Container(
          margin: EdgeInsets.only(top: 200, bottom: 200),
          height: 300,
          width: 1200,
          color: Colors.white,
          child: Text("Hallooo"),
        )
      ],
    );
  }
}