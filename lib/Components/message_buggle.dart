import 'package:flutter/material.dart';
import 'dart:math' as math;

class MessageBubble extends StatefulWidget {
  final String message;
  final bool isUser;
  final bool isLoading;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.isLoading = false,
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

    // Make the opacity animation go from 0 to 1 (fully visible)
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    // Start the animation immediately
    _animationController.forward();

    // If it's a loading message, set up the repeating animation
    if (widget.isLoading) {
      _animationController.repeat(reverse: false);
    }
  }

  @override
  void didUpdateWidget(MessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle changes in loading state
    if (widget.isLoading && !oldWidget.isLoading) {
      _animationController.repeat(reverse: false);
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _animationController.stop();
      _animationController.value = 1.0; // Ensure full opacity
    }
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
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.blueAccent.withOpacity(0.3)),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.smart_toy_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.isUser ? "You" : "ANJAC Bot",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  if (widget.isUser) ...[
                    const SizedBox(width: 8),
                    Container(
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.blueAccent.withOpacity(0.3)),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
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
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: widget.isUser
                      ? Colors.blueAccent.withOpacity(0.2)
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: widget.isUser
                        ? Colors.blueAccent.withOpacity(0.3)
                        : Colors.white24,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: widget.isLoading
                    ? _buildLoadingAnimation()
                    : Text(
                        widget.message,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingAnimation() {
    return SizedBox(
      height: 24,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildBouncingDot(0),
          const SizedBox(width: 4),
          _buildBouncingDot(160),
          const SizedBox(width: 4),
          _buildBouncingDot(320),
        ],
      ),
    );
  }

  Widget _buildBouncingDot(int delay) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        // Calculate a value between 0 and 1 with delay
        final double t =
            (_animationController.value * 1000 + delay) % 1000 / 1000;

        // Use sine function for smooth bouncing
        final double bounce = math.sin(t * math.pi);

        return Transform.translate(
          // Move the dot up and down
          offset: Offset(0, -bounce * 6),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
