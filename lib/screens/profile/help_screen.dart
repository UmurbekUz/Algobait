import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/ai_chat_service.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AIChatService _chatService = AIChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<Map<String, String>> _messages = [
    {'role': 'assistant', 'content': 'Здравствуйте! Я ваш AI-помощник. Чем могу помочь по приложению Algobait?'},
  ];

  bool _isTyping = false;
  bool _isLoading = true;
  String? _systemPrompt;

  @override
  void initState() {
    super.initState();
    _loadPortfolioData();
  }

  Future<void> _loadPortfolioData() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

      String assetsInfo = "У пользователя пока нет активов.";
      String totalValueInfo = "Общий баланс пользователя: 0.00 USD.";

      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data() as Map<String, dynamic>;
        final portfolioData = data['purchased_portfolio'] as Map<String, dynamic>? ?? {};
        final totalValue = (data['total_investment_value'] ?? 0.0).toDouble();

        totalValueInfo = "Общий баланс пользователя: ${totalValue.toStringAsFixed(2)} USD.";

        if (portfolioData.isNotEmpty) {
          final assetList = portfolioData.entries.map((e) => "- ${e.key}: ${e.value['percentage'].toStringAsFixed(2)}%").join('\n');
          assetsInfo = "Текущие активы пользователя:\n$assetList";
        }
      }

      setState(() {
        _systemPrompt = """
        Ты — AI-помощник в приложении 'Algobait'.
        Твоя задача — помогать пользователям, отвечая на их вопросы об приложении, инвестициях, криптовалютах и их собственном портфеле.
        
        Информация о приложении:
        - Название: Algobait
        - Цель: Помочь пользователям понять и начать инвестировать в криптовалюты.
        - Функции: Создание инвестиционного портфеля на основе риск-профиля, отслеживание активов, AI-чат для поддержки.

        Текущая информация о портфеле пользователя:
        $totalValueInfo
        $assetsInfo

        Правила общения:
        1. Всегда отвечай на языке, на котором задан вопрос.
        2. Будь вежливым, кратким и ясным.
        3. Используй предоставленную информацию о портфеле для ответов на вопросы о балансе, активах и т.д.
        4. Не придумывай информацию. Если чего-то не знаешь, скажи, что у тебя нет этой информации.
        5. Не давай прямых финансовых советов о покупке или продаже.
        """;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading portfolio data: $e");
      setState(() {
        _isLoading = false;
        // Even if there's an error, set a basic prompt
        _systemPrompt = "Ты — AI-помощник в приложении 'Algobait'. Помогай пользователям с вопросами о приложении.";
      });
    }
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final userMessage = {'role': 'user', 'content': text};
    if (!mounted) return;
    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
    });
    _controller.clear();
    _scrollToBottom();

    final response = await _chatService.getResponse(
      List.from(_messages),
      systemPrompt: _systemPrompt,
    );

    if (!mounted) return;
    final aiMessage = {'role': 'assistant', 'content': response};
    setState(() {
      _messages.add(aiMessage);
      _isTyping = false;
    });
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
    const primaryColor = Color(0xFF4B39EF);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Text('Поддержка', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_isTyping && index == _messages.length) {
                        return _buildTypingIndicator(primaryColor);
                      }
                      final message = _messages[index];
                      return _buildMessageBubble(message, primaryColor);
                    },
                  ),
          ),
          _buildMessageInput(primaryColor),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, String> message, Color primaryColor) {
    final isUser = message['role'] == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: isUser ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
        ),
        child: Text(
          message['content']!,
          style: GoogleFonts.outfit(color: isUser ? Colors.white : Colors.black87, fontSize: 16),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: isUser ? 0.2 : -0.2, curve: Curves.easeOut);
  }

  Widget _buildTypingIndicator(Color primaryColor) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10, width: 10, child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor)),
            const SizedBox(width: 10),
            Text('AI печатает...', style: GoogleFonts.outfit(color: Colors.grey)),
          ],
        ),
      ),
    ).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 1500.ms, color: primaryColor.withOpacity(0.2));
  }

  Widget _buildMessageInput(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10)],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _sendMessage(),
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: _isLoading ? 'Загрузка данных...' : 'Введите ваш вопрос...',
                  hintStyle: GoogleFonts.outfit(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                ),
                enabled: !_isLoading,
              ),
            ),
            IconButton(
              icon: Icon(Icons.send_rounded, color: primaryColor, size: 28),
              onPressed: _isLoading ? null : _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
