import 'package:campus_connect/colors/chat_bot_colors.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatefulWidget {
  final String message;
  final bool isUser;
  const MessageBubble({super.key, required this.message, required this.isUser});

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            widget.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: widget.isUser
                ? const EdgeInsets.only(right: 15, top: 10)
                : const EdgeInsets.only(left: 15, top: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!widget.isUser) ...[
                  Image.asset(
                    "lib/Assets/Images/Chatbot.png",
                    height: 28,
                    width: 28,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.isUser ? "You" : "Ayyan Bot",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.isUser) ...[
                  const SizedBox(width: 8),
                  Image.asset(
                    "lib/Assets/Images/Chatbot.png",
                    height: 28,
                    width: 28,
                  ),
                ],
              ],
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width * 0.3,
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                color: widget.isUser
                    ? chatBotUserMessageColor
                    : chatBotBotMessageColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                widget.message,
                style: const TextStyle(
                    fontSize: 16,
                    color: chatBotMessageTextColor,
                    fontFamily: "NotoSans",
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
