import 'dart:math';

import 'package:campus_connect/Components/message_buggle.dart';
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
  Map<String, dynamic>? _currentSuggestions;
  bool _showSuggestions = false;
  Map<String, String> languageMap = {
    'en': 'English',
    'ta': 'தமிழ்',
    'hi': 'हिंदी',
    'ml': 'മലയാളം',
    'te': 'తెలుగు',
  };

  @override
  void initState() {
    super.initState();
    List<String> welcomeMessages = [
      'How can I help you?',
      'Welcome! How can I assist you today?',
      'Hi there! What can I do for you?',
      'Hello! Need any help?',
      'Greetings! How may I support you?'
    ];
    var random = Random();
    String randomMessage =
        welcomeMessages[random.nextInt(welcomeMessages.length)];

    _messages.add({'message': randomMessage, 'isUser': false});
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
        final hasValue = botResponse['hasValue'];

        setState(() {
          // Remove the loading indicator
          _messages.removeLast();
          // Add the actual bot response
          _messages.add({
            'message': responseText,
            'isUser': false,
          });

          // Update suggestions if available
          if (hasValue) {
            _currentSuggestions = botResponse['reference'];
            _showSuggestions = true;
          }
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
    // Get the bottom padding to account for the navigation bar
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E1E2C), Color(0xFF23233A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return MessageBubble(
                  message: _messages[index]['message'],
                  isUser: _messages[index]['isUser'],
                  isLoading: _messages[index]['isLoading'] ?? false,
                );
              },
            ),
          ),

          // Suggestions section
          if (_showSuggestions && _currentSuggestions != null)
            _buildSuggestionsSection(),

          // Add padding at the bottom to account for the navigation bar
          Padding(
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 16.0,
              bottom: 5 + bottomPadding, // Add extra padding for the navbar
            ),
            child: _buildChatInput(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 8),
            child: Row(
              children: [
                Text(
                  "Suggested Questions",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showSuggestions = false;
                    });
                  },
                  icon: Icon(
                    Icons.close,
                    color: Colors.white.withOpacity(0.6),
                    size: 18,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Container(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _currentSuggestions!.length,
              itemBuilder: (context, index) {
                String key = _currentSuggestions!.keys.elementAt(index);
                String value = _currentSuggestions!.values.elementAt(index);

                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: ElevatedButton(
                    onPressed: () {
                      getChatbotResponse(value);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent.withOpacity(0.2),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: Colors.blueAccent.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Text(
                      key,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white24),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      backgroundColor: const Color(0xFF1E1E2C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Select Language',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ...languageMap.entries.map((entry) {
                              return ListTile(
                                title: Text(
                                  entry.value,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                tileColor: selectedLanguage == entry.key
                                    ? Colors.blueAccent.withOpacity(0.2)
                                    : Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                onTap: () {
                                  setState(() {
                                    selectedLanguage = entry.key;
                                  });
                                  Navigator.pop(context);
                                },
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              icon: Icon(
                Icons.language,
                color: Colors.white.withOpacity(0.8),
                size: 24,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              cursorColor: Colors.blueAccent,
              style: const TextStyle(
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
              ),
              onSubmitted: (text) {
                if (text.isNotEmpty) {
                  getChatbotResponse(text);
                  _messageController.clear();
                }
              },
            ),
          ),
          Material(
            color: Colors.transparent,
            child: IconButton(
              onPressed: () {
                if (_messageController.text.isNotEmpty) {
                  getChatbotResponse(_messageController.text);
                  _messageController.clear();
                }
              },
              icon: const Icon(
                Icons.send_rounded,
                color: Colors.blueAccent,
                size: 24,
              ),
            ),
          ),
        ],
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
