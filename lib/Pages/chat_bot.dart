import 'package:campus_connect/Components/message_buggle.dart';
import 'package:campus_connect/colors/chat_bot_colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatBot extends StatefulWidget {
  const ChatBot({super.key});

  @override
  State<ChatBot> createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  String selectedLanguage = 'en';
  Map<String, String> languageMap = {
    'en': 'English',
    'ta': 'தமிழ்',
    'hi': 'हिंदी',
    'ml': 'മലയാളം',
    'te': 'తెలుగు',
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _messages.add({'message': 'How can I help you?', 'isUser': false});
  }

  Future<void> getChatbotResponse(String userInput) async {
    setState(() {
      // Show user's message immediately
      _messages.add({'message': userInput, 'isUser': true});

      // Show loading message for bot
      _messages
          .add({'message': 'loading...', 'isUser': false, 'isLoading': true});
    });

    _scrollToBottom();

    try {
      final response = await http.get(
        Uri.parse('https://chat-bot-backend-sooty.vercel.app/chatbot').replace(
          queryParameters: {
            'user_input': userInput,
            'lang': selectedLanguage,
          },
        ),
      );

      if (response.statusCode == 200) {
        final jsonString = utf8.decode(response.bodyBytes);
        final botResponse = json.decode(jsonString);
        final responseText = botResponse['answer'] ?? 'No response available';

        setState(() {
          // Remove the loading indicator
          _messages.removeLast();
          // Add the actual bot response
          _messages.add({'message': responseText, 'isUser': false});
        });
      }
    } catch (e) {
      setState(() {
        _messages.removeLast();
        _messages.add({
          'message': 'Sorry, there was an error processing your request.',
          'isUser': false
        });
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    String backgroundImagePath = screenWidth > 600 ? "lib/Assets/Image/chatbotbg.jpg" : "lib/Assets/Image/chat_bg.jpg";
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset(
          "lib/Assets/Images/Chatbot.png",
          height: 40,
          width: 40,
        ),
        backgroundColor: chatBotAppBarColor,
        title: const Text(
          "Ayyan Bot",
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontFamily: "Inter",
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.5,
                child: Image.asset(
                  backgroundImagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(10),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return MessageBubble(
                        message: _messages[index]['message'],
                        isUser: _messages[index]['isUser'],
                      );
                    },
                  ),
                ),
                Container(
                  height: 70, // Fixed height
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: chatBotAppBarColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      FloatingActionButton(
                        elevation: 0,
                        heroTag: "langButton",
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Select Language'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: languageMap.entries.map((entry) {
                                      return ListTile(
                                        title: Text(entry.value),
                                        onTap: () {
                                          setState(() {
                                            selectedLanguage = entry.key;
                                          });
                                          Navigator.pop(context);
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        backgroundColor: chatBotAppBarColor,
                        child: SizedBox(
                      height: 40,
                      width: 40,
                      child: Image.asset("lib/Assets/Images/Language.png"),
                    ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          constraints: const BoxConstraints(
                            maxHeight: 50, // Constrain TextField height
                          ),
                          child: TextField(
                            controller: _messageController,
                            cursorWidth: 3,
                            cursorColor: Colors.white,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(
                              hintStyle: TextStyle(color: Colors.white),
                              hintText: 'Type a message',
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FloatingActionButton(
                        elevation: 0,
                        heroTag: "sendButton",
                        onPressed: () {
                          if (_messageController.text.isNotEmpty) {
                            getChatbotResponse(_messageController.text);
                            _messageController.clear();
                          }
                        },
                        backgroundColor: chatBotAppBarColor,
                        child: const Icon(
                          Icons.send,
                          size: 35,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
