import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  ScrollController _scrollController = ScrollController();
  TextEditingController _textController = TextEditingController();

  List _aiResponse = [];
  final gemini = Gemini.instance;

  List<Content> _aiChat = [];

  bool loadingButton = false;
  @override
  void initState() {
    _scrollController.addListener(
      () {},
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        title: Text('Gemini AI'),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                _aiChat.removeRange(0, _aiChat.length);
                setState(() {});
              },
              icon: Icon(Icons.delete_outlined))
        ],
      ),
      body: _aiChat.isEmpty
          ? Center(
              child: Text('Search something!'),
            )
          : ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.fromLTRB(20, 20, 20, 100),
              itemCount: _aiChat.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: _aiChat[index].role != 'user' ? const EdgeInsets.all(20) : null,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                      color: _aiChat[index].role != 'user' ? Colors.grey[800] : null,
                      borderRadius:
                          BorderRadius.circular(_aiChat[index].role != 'user' ? 30.0 : 0.0)),
                  child: Row(
                    mainAxisAlignment: _aiChat[index].role == 'user'
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      if (_aiChat[index].role == 'user')
                        Expanded(
                            child: Text(
                          _aiChat[index].parts?[0].text ?? '',
                          textAlign:
                              _aiChat[index].role == 'user' ? TextAlign.end : TextAlign.start,
                          style: TextStyle(
                              fontWeight: _aiChat[index].role == 'user' ? FontWeight.w500 : null),
                        ))
                      else
                        Expanded(
                            child: Markdown(
                          data: _aiChat[index].parts?[0].text ?? '',
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                        )),
                    ],
                  ),
                );
              },
            ),
      bottomSheet: Container(
        color: Colors.grey[850],
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: TextFormField(
            controller: _textController,
            decoration: InputDecoration(
                fillColor: Colors.black12,
                filled: true,
                suffixIcon: IconButton(
                    onPressed: () async {
                      _aiChat.add(
                        Content(parts: [Parts(text: _textController.text)], role: 'user'),
                      );
                      loadingButton = true;

                      _textController.clear();
                      setState(() {});

                    await  gemini
                          .chat(_aiChat)
                          .then(
                            (value) {
                              print(value?.output ?? '');
                              _aiChat.add(
                                Content(parts: [Parts(text: value?.output ?? '')], role: 'model'),
                              );
                              loadingButton = false;

                              setState(() {});
                            },
                          )
                          .catchError((e) => log('chat', error: e))
                          .whenComplete(() {
                            _scrollController.animateTo(_scrollController.position.maxScrollExtent,
                                duration: Duration(milliseconds: 400), curve: Curves.easeIn);
                          });
                    },
                    icon: loadingButton
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.grey,
                            ))
                        : Icon(
                            Icons.send_rounded,
                            color: Colors.grey,
                          )),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40), borderSide: BorderSide.none)),
          )),
    );
  }
}
