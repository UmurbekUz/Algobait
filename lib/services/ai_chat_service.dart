import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AIChatService {
  // User needs to add this key to their .env file
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  final String _model = 'gemini-1.5-flash-latest';

  Future<String> getResponse(List<Map<String, String>> messages, {String? systemPrompt}) async {
    if (_apiKey.isEmpty) {
      return 'Ошибка: Ключ Google AI API не найден. Пожалуйста, добавьте GEMINI_API_KEY в ваш .env файл.';
    }

    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey');

    // Transform messages to Gemini's format
    final List<Map<String, dynamic>> geminiContents = messages
        .map((msg) {
          // Gemini uses 'model' for the assistant's role
          final role = msg['role'] == 'assistant' ? 'model' : 'user';
          return {
            'role': role,
            'parts': [{'text': msg['content']}]
          };
        })
        .toList();
    
    // Gemini API requires that the history alternates between user and model.
    // The first message in HelpScreen is from the assistant, which is invalid.
    // We will remove it for the API call.
    if (geminiContents.isNotEmpty && geminiContents.first['role'] == 'model') {
      geminiContents.removeAt(0);
    }
    
    if (geminiContents.isEmpty) {
      return 'Ошибка: Нет сообщений для отправки.';
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': geminiContents,
          if (systemPrompt != null)
            'system_instruction': {
              'parts': [{'text': systemPrompt}]
            }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data.containsKey('candidates') && data['candidates'].isNotEmpty) {
            return data['candidates'][0]['content']['parts'][0]['text'].trim();
        } else {
            return 'Извините, AI не смог сгенерировать ответ. Возможно, ваш запрос нарушил правила безопасности.';
        }
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error']?['message'] ?? 'Неизвестная ошибка Google AI API.';
        print('Google AI API Error: ${response.statusCode}');
        print('Error Body: ${response.body}');
        return 'Извините, произошла ошибка при подключении к AI. Ошибка: $errorMessage';
      }
    } catch (e) {
      print('Network Error: $e');
      return 'Извините, произошла сетевая ошибка. Пожалуйста, проверьте ваше интернет-соединение и попробуйте снова.';
    }
  }
}
