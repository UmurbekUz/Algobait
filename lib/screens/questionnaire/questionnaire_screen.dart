import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:algobait/screens/portfolio/investment_portfolio_screen.dart';


class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  _QuestionnaireScreenState createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final PageController _pageController = PageController();
  final Map<String, dynamic> _answers = {};
  int _currentPage = 0;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  final List<Map<String, dynamic>> _questions = [
    {
      'title': 'Какой у вас бюджет?',
      'type': 'input',
      'key': 'budget',
    },
    {
      'title': 'Какая ваша инвестиционная цель?',
      'type': 'choice',
      'key': 'investment_goal',
      'options': [
        'Получение максимальной прибыли, готов(а) рисковать, вкладывая в высокодоходные активы.',
        'Желание совместить сохранность капитала с некоторым уровнем прибыли.',
        'Безопасность капитала является моим главным приоритетом, я готов(а) получить меньшую прибыль.',
      ],
    },
    {
      'title': 'На какой период времени Вы инвестируете?',
      'type': 'choice',
      'key': 'investment_period',
      'options': [
        'До 3 месяцев.',
        'От 3 месяцев до 1 года.',
        '1-5 лет.',
        '5-10 лет.',
        '+10 лет.',
      ],
    },
    {
      'title': 'Какую сумму вы готовы инвестировать в рискованные активы (мемкоины) в сравнении с малорискованными активами (BTC, ETH)?',
      'type': 'choice',
      'key': 'risk_appetite_assets',
      'options': [
        'Большую часть своих вложений помтавлю на рискованные активы, не боясь ее потерять.',
        'Распределяю свои инвестиции равномерно между рисковыми и безриковыми активами.',
        'Предпочту большую часть вложений сосредоточить в безрисковых активах.',
      ],
    },
    {
      'title': 'Как вы реагируете на краткосрочные колебания рынка?',
      'type': 'choice',
      'key': 'market_reaction',
      'options': [
        'Игнорирую их и терпеливо жду, рынок восстановится.',
        'Чувствую некоторую тревогу, но не принимаю поспешных решений.',
        'Волнуюсь и реагирую эмоционально, склонен(на) продать активы при падении цены.',
      ],
    },
  ];

  void _nextPage() {
    if (_currentPage < _questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _saveAnswers();
    }
  }

  Future<void> _saveAnswers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("Пользователь не найден.");
      }
      
      // Save answers to Firestore by updating the user's document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'questionnaire_answers': _answers}, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ответы успешно сохранены!')),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const InvestmentPortfolioScreen()),
        );
      }
    } catch (e) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сохранения: ${e.toString()}')),
        );
       }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4B39EF);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (_currentPage > 0) {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _questions.length,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemBuilder: (context, index) {
                final question = _questions[index];
                if (question['type'] == 'input') {
                  return _buildInputQuestion(question, primaryColor);
                }
                return _buildChoiceQuestion(question, primaryColor);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: _isLoading 
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: () {
                bool canProceed = false;
                // For input questions, validate the form.
                if (_questions[_currentPage]['type'] == 'input') {
                  if (_formKey.currentState?.validate() ?? false) {
                    canProceed = true;
                  }
                } else {
                  // For choice questions, just check if an answer is selected.
                  if (_answers[_questions[_currentPage]['key']] != null) {
                    canProceed = true;
                  }
                }

                if (canProceed) {
                  _nextPage();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _currentPage == _questions.length - 1 ? 'Завершить' : 'Следующий вопрос',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }

  Widget _buildInputQuestion(Map<String, dynamic> question, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question['title'],
            style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          TextFormField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (value) {
              setState(() {
                _answers[question['key']] = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Пожалуйста, введите сумму.';
              }
              final n = num.tryParse(value.replaceAll(',', '.'));
              if (n == null) {
                return 'Пожалуйста, введите корректное число.';
              }
              if (n < 10) {
                return 'Минимальный бюджет - \$10.';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Введите сумму в USD',
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: primaryColor, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: primaryColor, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceQuestion(Map<String, dynamic> question, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question['title'],
            style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ...List<Widget>.generate(question['options'].length, (int i) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                  )
                ],
              ),
              child: RadioListTile<int>(
                value: i,
                groupValue: _answers[question['key']],
                onChanged: (int? value) {
                  setState(() {
                    _answers[question['key']] = value;
                  });
                },
                title: Text(question['options'][i]),
                activeColor: primaryColor,
              ),
            );
          }),
        ],
      ),
    );
  }
}
