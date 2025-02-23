import 'package:campus_connect/colors/chat_bot_colors.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatefulWidget {
  final String message;
  final bool isUser;
  final bool isLoading; // New: To detect if it's a loading message

  const MessageBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.isLoading = false, // Default is false
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _opacityAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: Align(
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
                    Container(
                      height: 40,
                      width: 40,
                      child: Image.asset("lib/Assets/Images/Chatbot.png"),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    widget.isUser ? "You" : "Ayyan Bot",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.isUser) ...[
                    const SizedBox(width: 12),
                    Container(
                      height: 40,
                      width: 40,
                      child: Image.asset("lib/Assets/Images/Boy.png"),
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
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                  color: widget.isUser
                      ? chatBotUserMessageColor
                      : chatBotBotMessageColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: widget.isLoading
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildLoadingDot(),
                          const SizedBox(width: 4),
                          _buildLoadingDot(delay: 200),
                          const SizedBox(width: 4),
                          _buildLoadingDot(delay: 400),
                        ],
                      )
                    : Text(
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
      ),
    );
  }

  Widget _buildLoadingDot({int delay = 0}) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
