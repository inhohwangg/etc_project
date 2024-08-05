import 'dart:developer';

import 'package:Youtube_Stop/util/g_print.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class TranslationPage extends StatefulWidget {
  @override
  _TranslationPageState createState() => _TranslationPageState();
}

class _TranslationPageState extends State<TranslationPage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press the button and start speaking';
  String _translatedText = '';
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      _translateText();
    }
  }

 void _translateText() async {
    final gemini = Gemini.instance;
    final response = await gemini.text("너는 $_selectedLanguage 의 전문가로써 내가 한국어로 말하면 $_selectedLanguage로 답변해줘: $_text");
    setState(() {
      _translatedText = response?.output ?? 'Translation error';
    });
    printYellow(_translatedText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Translator')),
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: [
                    Text('한국어'),
                    Text(_text),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    DropdownButton<String>(
                      value: _selectedLanguage,
                      items: <String>['en', 'es', 'mn', 'ja']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedLanguage = newValue!;
                        });
                      },
                    ),
                    Text(_translatedText),
                  ],
                ),
              ),
            ],
          ),
          FloatingActionButton(
            onPressed: _listen,
            child: Icon(_isListening ? Icons.mic : Icons.mic_none),
            backgroundColor: Colors.red,
          ),
        ],
      ),
    );
  }
}