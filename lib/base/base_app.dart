import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gemini_app/api/api.dart';
import 'package:gemini_app/model/chat_model.dart';
import 'package:gemini_app/widgets/field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:typewritertext/typewritertext.dart';

// ignore: must_be_immutable
class GeminiAiCompanion extends StatefulWidget {
  const GeminiAiCompanion({super.key});

  @override
  State<GeminiAiCompanion> createState() => _GeminiAiCompanionState();
}

class _GeminiAiCompanionState extends State<GeminiAiCompanion> {
  final TextEditingController textEditingController = TextEditingController();

  XFile? image;
  Future<XFile?> pickImages(
      {ImageSource? imgSource = ImageSource.gallery}) async {
    debugPrint("start");
    final picker = ImagePicker();
    try {
      // final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: imgSource!);

      if (pickedImage != null) {
        return pickedImage;
      } else {
        return null;
      }
    } catch (e) {
      // log("Image picking issue ${e.toString()}");
    }
    return null;
  }

  List<ChatModel> messages = [];
  bool isLoading = false;
  void sendMessage() async {
    final String text = textEditingController.text.trim();
    setState(() {
      isLoading = true;
    });

    if (image == null) {
      ChatModel chatModel = ChatModel(message: text, isAi: false, path: null);

      setState(() {
        messages.add(chatModel);
      });
      textEditingController.clear();

      final response = await DioClient.i.post('chatWithGeminiWithoutChat',
          data: json.encode({
            "message": text,
          }));

      ChatModel responseChat = ChatModel.fromJson(response['data']);
      setState(() {
        messages.add(responseChat);
        isLoading = false;
      });
      debugPrint(response.toString());
    } else {
      File imageFile = File(image!.path);
      ChatModel chatModel =
          ChatModel(message: text, isAi: false, path: imageFile.path);

      setState(() {
        messages.add(chatModel);
      });

      final response = await DioClient.i
          .uploadWithFields('chatWithGemini', imageFile, fields: {
        "message": text,
      });
      ChatModel responseChat = ChatModel.fromJson(response['data']);
      setState(() {
        messages.add(responseChat);
        isLoading = false;
      });
      textEditingController.clear();
      image = null;
      debugPrint(response.toString());
    }
    setState(() {
      isLoading = false;
    });
  }

  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((s) {});
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
                  controller: scrollController,
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
                            child: Column(
                              children: [
                                Padding(
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
                                              const Duration(milliseconds: 20),
                                          builder: (context, value) {
                                          return Text(
                                            value,
                                            style: GoogleFonts.montserrat(
                                                color: Colors.white),
                                          );
                                        }),
                                ),
                                if (messages[index].path != null)
                                  SizedBox(
                                    height: 180,
                                    child: Image.file(
                                      File(
                                        messages[index].path!,
                                      ),
                                    ),
                                  ),
                                const SizedBox(
                                  height: 5,
                                ),
                              ],
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
                    child: SizedBox(
                      child: customTextField(
                        height: (image == null ? 50 : 240),
                        hintText: "Ask your AI companion now.",
                        controller: textEditingController,
                        child: (image != null
                            ? SizedBox(
                                height: 180,
                                child: Stack(
                                  fit: StackFit.passthrough,
                                  children: [
                                    Image.file(File(image!.path)),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          image = null;
                                          setState(() {});
                                        },
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ))
                            : const SizedBox.shrink()),
                      ),
                    ),
                  ),
                  GestureDetector(
                      onTap: () async {
                        image = await pickImages();
                        setState(() {});
                      },
                      child: const Icon(
                        Icons.image,
                        size: 31,
                        color: Colors.blueGrey,
                      )),
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
