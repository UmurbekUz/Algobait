import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExchangeInfoScreen extends StatelessWidget {
  final String exchangeName;
  final Widget connectionScreen;

  const ExchangeInfoScreen({
    super.key,
    required this.exchangeName,
    required this.connectionScreen,
  });

  // Map holding the descriptions for each exchange
  static const Map<String, String> _exchangeDescriptions = {
    'Bybit': '''
✅ **Надежность и скорость:** Высокая производительность и стабильность платформы.

📈 **Фьючерсы и опционы:** Широкий выбор деривативных продуктов.

👥 **Копитрейдинг:** Возможность копировать сделки успешных трейдеров.

🔒 **Высокая безопасность:** Современные методы защиты активов и данных.

**Подходит для:** трейдеров любого уровня, особенно для тех, кто интересуется деривативами и копитрейдингом.
''',
    'Bitget': '''
✅ Доступна в 150+ странах (кроме США, Канады, Сингапура)

⚖️ Надёжная биржа с хорошим уровнем защиты аккаунта

📈 Есть фьючерсы и торговые боты

🔒 Поддержка IP-привязки, 2FA и удобный интерфейс

**Подходит для:** начинающих инвесторов и тех, кто хочет торговать с умеренными рисками''',
    'MEXC': '''
🌍 Поддерживается в 170+ странах (кроме США, Канады и ЕС)

📊 Более 3000 криптовалют, в том числе высокорискованные активы

🚀 Можно начать без верификации (но с ограничениями)

⚠️ Нет лицензий, но популярна в Азии и Латинской Америке

 **Подходит для:** пользователей, которые ищут большой выбор монет и готовы к более высоким рискам''',
    'Gate.io': '''
🌐 Поддерживается в 160+ странах (без США и ЕС)

🔐 Высокий уровень безопасности, есть Proof-of-Reserves

🪙 Более 3600 активов

🧾 Требует KYC для полноценного доступа

 **Подходит для:** тех, кто хочет безопасность и широкий выбор монет''',
    'KuCoin': '''
🌍 Работает в 200+ странах (но не в США)

📱 Удобный интерфейс и мобильное приложение

🧠 Хорошая поддержка альткоинов и новых проектов

⚠️ Были юридические сложности, но платформа активна

 **Подходит для:** активных трейдеров, которые хотят торговать популярными и новыми монетами''',
    'HTX': '''
🛡 Один из самых опытных игроков рынка

🌍 Доступна во многих странах с KYC

📊 Поддержка как спота, так и фьючерсов

🔒 Высокая безопасность, хорошая инфраструктура

 **Подходит для:** пользователей, которые ценят стабильность и доверие к бренду''',
  };

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4B39EF);
    // Get the description, or a default message if not found
    final description = _exchangeDescriptions[exchangeName] ?? 'Информация о бирже $exchangeName скоро появится.';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Text(
          'Об бирже $exchangeName',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  description,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.7,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => connectionScreen),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Понятно',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
