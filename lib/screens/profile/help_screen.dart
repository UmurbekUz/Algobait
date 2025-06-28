import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      "sender": "A",
      "text": "Здравствуйте! Чем мы можем вам помочь?",
    },
    {
      "sender": "user",
      "text": "Здравствуйте! У меня произошла проблема.",
    },
    {
      "sender": "A",
      "text": "В вашей ситуации нужно сделать...",
    }
  ];

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4B39EF);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'ALGOBAIT помощь',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUserMessage = message['sender'] == 'user';
                return _buildMessageBubble(
                  message['text']!,
                  isUserMessage,
                  primaryColor,
                );
              },
            ),
          ),
          _buildMessageInput(primaryColor),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser, Color primaryColor) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isUser ? primaryColor : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            color: isUser ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Сообщение...',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: primaryColor),
            onPressed: () {
              // TODO: Implement send message logic
            },
          ),
        ],
      ),
    );
  }
}
