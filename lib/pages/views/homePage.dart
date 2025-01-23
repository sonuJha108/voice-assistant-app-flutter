import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:voice_assistant_app/colorFile/pallete.dart';
import 'package:voice_assistant_app/pages/blogs/featureBox.dart';

import '../../services/opneApi_services.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  // create the final speech to text variable and create the object of the speech class
  final speechToText = SpeechToText();
  String lastWords = '';
  final OpenAIService openAIService = OpenAIService();

  // for ios devices
  final flutterTts = FlutterTts();

  String? generatedContent;
  String? generatedImageUrl;
  String? speech;

  int start = 200;
  int delay = 200;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  // create the future collection to the given sections
  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  Future<void> _startListening() async {
    await speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  Future<void> _stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    // the last words after the finished to speak
    speechToText.stop();

    // for the ios devices
    flutterTts.stop();
  }

  // for ios system devices
  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: BounceInDown(
          child: const Text("Allen"),
        ),
        leading: const Icon(Icons.menu),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // virtual assistant picture
            ZoomIn(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      height: 120,
                      width: 120,
                      margin: EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: Pallete.assistantCircleColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  // Image container in the page
                  Container(
                    height: 123,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage("assets/images/assistant.png"),
                        )),
                  ),
                ],
              ),
            ),

            // chat sections widget is calling
            _chatSection(),

            // if the image is show the url
            if (generatedImageUrl != null)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(generatedImageUrl!),
                ),
              ),

            // small text sections and below the greeting sections
            _smallText(),

            // feature List
            Visibility(
              // hide the 3 box show
              visible: generatedContent == null && generatedImageUrl == null,
              child: Column(
                children: [
                  SlideInLeft(
                    delay: Duration(milliseconds: start),
                    child: const FeatureBox(
                      color: Pallete.firstSuggestionBoxColor,
                      headerText: 'ChatGPT',
                      descriptionText:
                          'A smarter way to stay organized and informed with ChatGPT',
                    ),
                  ),
                  SlideInLeft(
                    // animation after the 400 milli seconds
                    delay: Duration(milliseconds: start + delay),
                    child: const FeatureBox(
                      color: Pallete.secondSuggestionBoxColor,
                      headerText: 'Dall-E',
                      descriptionText:
                          'Get inspired and stay creative with your personal assistant powered by Dall-E',
                    ),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds:  start + 2 * delay),
                    child: const FeatureBox(
                      color: Pallete.thirdSuggestionBoxColor,
                      headerText: 'Smart Voice Assistant',
                      descriptionText:
                          'Get the best of both worlds with voice assistant powered by Dall-E & ChatGPT',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // button and there mic icons
      floatingActionButton: ZoomIn(
        delay: Duration(milliseconds: start + 3* delay),
        child: FloatingActionButton(
          backgroundColor: Pallete.firstSuggestionBoxColor,
          onPressed: () async {
            if (await speechToText.hasPermission && speechToText.isNotListening) {
              await _startListening();
            } else if (speechToText.isListening) {
              await openAIService.isArtPromptAPI(lastWords);
              if (speech!.contains('https:')) {
                generatedImageUrl = speech;
                generatedContent = null;
                setState(() {});
              } else {
                generatedImageUrl = null;
                generatedContent = speech;
                setState(() {});
                await systemSpeak(speech!);
              }
        
              await _stopListening();
            } else {
              initSpeechToText();
            }
          },
          child: Icon(speechToText.isListening ? Icons.stop : Icons.mic),
        ),
      ),
    );
  }

  // chat sections in this widget and main code Here!
  Widget _chatSection() {
    return FadeInRight(
      child: Visibility(
        visible: generatedImageUrl == null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          margin: const EdgeInsets.symmetric(
            horizontal: 40,
          ).copyWith(top: 30),
          decoration: BoxDecoration(
            border: Border.all(color: Pallete.borderColor),
            borderRadius:
                BorderRadius.circular(20).copyWith(topLeft: Radius.zero),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              // if the value is show then the content size is 18 or default value is 25
              generatedContent == null
                  ? "Good Morning, What task can I do for you?"
                  : generatedContent!,
              style: TextStyle(
                color: Pallete.mainFontColor,
                fontSize: generatedContent == null ? 25 : 18,
                fontFamily: "Cera Pro",
              ),
            ),
          ),
        ),
      ),
    );
  }

  // small text widget
  Widget _smallText() {
    return SlideInLeft(
      child: Visibility(
        // hide the value of the small box
        visible: generatedContent == null && generatedImageUrl == null,
        child: Container(
          padding: const EdgeInsets.all(10.0),
          margin: const EdgeInsets.only(top: 10, left: 22),
          alignment: Alignment.centerLeft,
          child: const Text(
            "Here are a few feature!",
            style: TextStyle(
              fontFamily: 'Cera Pro',
              color: Pallete.mainFontColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
