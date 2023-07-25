import 'package:alverse/constants/Colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../service/service.dart';
import '../widgets/suggestionbox.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final speechToText = SpeechToText();
  final flutterTts = FlutterTts();
  String lastWords = '';
  final OpenAIService openAIService = OpenAIService();
  String? generatedContent;
  String? generatedImageUrl;
  int start = 200;
  int delay = 200;

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "ALVERSE",
            style: GoogleFonts.mavenPro(
              fontSize: 25,
              fontWeight: FontWeight.w400,
            ),
          ),
          leading: const Icon(Icons.menu),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // bot pic
              Container(
                height: 130,
                width: 120,
                decoration: const BoxDecoration(
                    color: ColorConstant.whiteColor,
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: AssetImage("assets/sounds/maleavatar.png"))),
              ),
              // Container

              Visibility(
                visible: generatedImageUrl == null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 40).copyWith(
                    top: 30,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: ColorConstant.borderColor,
                    ),
                    borderRadius: BorderRadius.circular(20).copyWith(
                      topLeft: Radius.zero,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      generatedContent == null
                          ? 'Good Morning, what task can I do for you?'
                          : generatedContent!,
                      style: GoogleFonts.mavenPro(
                        color: ColorConstant.mainFontColor,
                        fontSize: generatedContent == null ? 25 : 18,
                      ),
                    ),
                  ),
                ),
              ),

              if (generatedImageUrl != null)
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(generatedImageUrl!),
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(top: 15, left: 22),
                alignment: Alignment.topLeft,
                child: Text(
                  "Here are few features ",
                  style: GoogleFonts.mavenPro(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    wordSpacing: 1,
                    color: ColorConstant.mainFontColor,
                  ),
                ),
              ),
              const Column(
                children: [
                  suggestionbox(
                    color: ColorConstant.firstSuggestionBoxColor,
                    headerText: " ChatGPT",
                    descriptionText:
                        "A smarter way to stay organized with ChatGPT",
                  ),
                  suggestionbox(
                    color: ColorConstant.secondSuggestionBoxColor,
                    headerText: "DALL-E",
                    descriptionText:
                        "Get inspired and stay creative with your personal assistant powered by DALL-E",
                  ),
                  suggestionbox(
                    color: ColorConstant.thirdSuggestionBoxColor,
                    headerText: "Smart Voice Assistant",
                    descriptionText:
                        "Get the best of both worlds with a voice assistant powered by ChatGPT and DALL-E",
                  ),
                ],
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: ColorConstant.firstSuggestionBoxColor,
          // onPressed: ()async{
          //   print("tapped");
          //    final res =    await openAIService.chatGPTAPI("Hello",);
          //   generatedContent = res;
          //   setState(() {
              
          //   });
          // },
          onPressed: () async {
            if (await speechToText.hasPermission &&
                speechToText.isNotListening) {
              await startListening();
            } else if (speechToText.isListening) {
              final speech = await openAIService.chatGPTAPI(lastWords);
                    setState(() {
              generatedContent = speech; 

                    });
              
              await stopListening();
            } else {
              initSpeechToText();
            }
          },
          child: Icon(speechToText.isListening ? Icons.stop : Icons.mic),
        ),
      ),
    );
  }
}
