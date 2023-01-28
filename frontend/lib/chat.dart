import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/apiConnector.dart';
import 'package:frontend/main.dart';
import 'package:intl/intl.dart';

int messagesToFetch = 100;
late Future<Map<String,dynamic>> messages;

class chat extends StatefulWidget {
  final String code;

  const chat({required this.code});

  State<chat> createState() => _chatState();
}

class _chatState extends State<chat> {

  final TextEditingController _textControlr = TextEditingController();
  String api_get_messages = "${api_base_url}/messages?code=";
  String api_post_messages = "${api_base_url}/message?code=";
  final ScrollController _scrollControlr = ScrollController();

  @override
  Widget build (BuildContext context) {
    api_get_messages = "${api_base_url}/messages?code=${widget.code}";
    api_post_messages = "${api_base_url}/message?code=${widget.code}";

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
                  controller: _scrollControlr,
                  reverse: true,
                  child: Padding(
                    padding: const EdgeInsets.only(top:20),
                    child: Messages(api_url: api_get_messages),
                  ),
                )
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.center,
                  child: TextField(
                    controller: _textControlr,
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
                      if (await postMessage(api_post_messages, {"message": text})) {
                        _textControlr.clear();
                        _scrollControlr.jumpTo(_scrollControlr.position.minScrollExtent);
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
        ),
    );
  }
}

class Messages extends StatefulWidget {
  final String api_url;
  const Messages({super.key, required this.api_url});

  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {

  Widget GetMessageList(dynamic obj) {
    List<Widget> tempList = [];

    if (obj==null) {
      return const Text("Failed to load Messages");
    }

    List<dynamic> list = obj["payload"];

    for (var value in list) {
      tempList.add(Container(
        margin: const EdgeInsets.only(top: 30, bottom: 30, right: 40, left: 40),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(12)
        ),
        child: Row(
          children: [
            Expanded(
              flex: 8,
              child: Text(value["message"], style: const TextStyle(color: Colors.white, fontSize: 15)),
            ),
            Expanded(
              child: Text(DateFormat.Hm().format(DateTime.parse(value["creationtime"])), style: const TextStyle(color: Colors.white, fontSize: 15)),
            )
          ],
        ),
      ));
    }
    return Column(
      children: tempList
    );
  }

  Timer? _everySecond;

  @override
  void initState() {
    super.initState();

    messages = fetchMessages("${widget.api_url}&count=$messagesToFetch");
    _everySecond = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        messages = fetchMessages("${widget.api_url}&count=$messagesToFetch");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: messages,
      builder: (context, snapshot) {
          if (snapshot.hasData) {
            return GetMessageList(snapshot.data);
          } else if (snapshot.hasError) {
            return Text("Error${snapshot.error}");
          }
          return const CircularProgressIndicator();
      },
    );
  }
}