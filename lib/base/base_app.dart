import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gemini_app/api/api.dart';
import 'package:gemini_app/model/chat_model.dart';
import 'package:gemini_app/widgets/field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:typewritertext/typewritertext.dart';
import 'package:typing_animation/typing_animation.dart';

// ignore: must_be_immutable
class GeminiAiCompanion extends StatefulWidget {
  const GeminiAiCompanion({super.key});

  @override
  State<GeminiAiCompanion> createState() => _GeminiAiCompanionState();
}

class _GeminiAiCompanionState extends State<GeminiAiCompanion> {
  final TextEditingController textEditingController = TextEditingController();

  List<ChatModel> messages = [];
  bool isLoading = false;
  void sendMessage() async {
    final String text = textEditingController.text.trim();
    setState(() {
      isLoading = true;
    });
    ChatModel chatModel = ChatModel(message: text, isAi: false);

    setState(() {
      messages.add(chatModel);
    });
    textEditingController.clear();

    final response = await DioClient.i.post('chatWithGemini',
        data: json.encode({
          "message": text,
        }));

    ChatModel responseChat = ChatModel.fromJson(response['data']);
    setState(() {
      messages.add(responseChat);
      isLoading = false;
    });
    debugPrint(response.toString());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.blueGrey,
          selectionColor: Colors.blueGrey.withOpacity(.1),
          selectionHandleColor: Colors.blueGrey,
        ),
        fontFamily: GoogleFonts.montserrat().fontFamily,
      ),
      home: Scaffold(
        resizeToAvoidBottomInset: true, // Ensure this is set to true
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text(
            "Your AI for everyday use.",
            style: GoogleFonts.montserrat(color: Colors.black),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return Align(
                      alignment: messages[index].isAi
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 4),
                        child: Container(
                          // height: 50,
                          width: 220,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: messages[index].isAi
                                  ? const Color(0xFF607D8B)
                                  : const Color(0xFF42A5F5)),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: !messages[index].isAi
                                  ? Text(
                                      messages[index].message,
                                      style: GoogleFonts.montserrat(
                                          color: Colors.white),
                                    )
                                  : TypeWriterText.builder(
                                      messages[index].message,
                                      duration:
                                          const Duration(milliseconds: 50),
                                      builder: (context, value) {
                                      return Text(
                                        value,
                                        style: GoogleFonts.montserrat(
                                            color: Colors.white),
                                      );
                                    }),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: customTextField(
                        hintText: "Ask your AI companion now.",
                        controller: textEditingController,
                      ),
                    ),
                  ),
                  GestureDetector(
                      onTap: sendMessage,
                      child: !isLoading
                          ? const Icon(
                              Icons.send,
                              size: 31,
                              color: Colors.blueGrey,
                            )
                          : const CupertinoActivityIndicator(
                              radius: 14,
                            )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
