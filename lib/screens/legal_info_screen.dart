import 'package:flutter/material.dart';

class AppColors {
  static const green = Color(0xFF0B5D3B);
  static const dark = Color(0xFF10231B);
  static const gold = Color(0xFFD6A84F);
  static const bg = Color(0xFFF7F8F5);
}

class LegalInfoScreen extends StatelessWidget {
  const LegalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: const Text('Yasal Bilgilendirme'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          LegalHeader(),
          SizedBox(height: 16),
          LegalItem(
            title: '1. Plango’nun Amacı',
            text:
                'Plango; kullanıcıların tasarruf finansman planlarını oluşturmasına, karşılaştırmasına, sektör hakkında bilgi edinmesine ve doğrulanmış uzmanlarla iletişime geçmesine yardımcı olan bağımsız bir karar destek platformudur.',
          ),
          LegalItem(
            title: '2. FP Engine Hesaplama Motoru',
            text:
                'FP Engine Hesaplama Motoru tarafından oluşturulan sonuçlar, kullanıcı tarafından girilen verilere göre oluşturulan bağımsız ve bilgilendirme amaçlı tahmini analizlerdir.',
          ),
          LegalItem(
            title: '3. Tahmini Teslim Süresi',
            text:
                'Uygulamada gösterilen tahmini teslim süresi resmî teslim tarihi değildir. Nihai teslim bilgileri ilgili tasarruf finansman kuruluşu tarafından belirlenir.',
          ),
          LegalItem(
            title: '4. Sözleşme',
            text:
                'Plango hiçbir kullanıcı adına sözleşme oluşturmaz ve hiçbir sözleşmenin tarafı değildir.',
          ),
          LegalItem(
            title: '5. Ödeme',
            text:
                'Plango hiçbir şekilde ödeme kabul etmez ve kullanıcı adına ödeme işlemi gerçekleştirmez.',
          ),
          LegalItem(
            title: '6. Bağımsızlık',
            text:
                'Plango hiçbir tasarruf finansman şirketinin resmî uygulaması değildir ve herhangi bir şirket adına işlem yapmaz.',
          ),
          LegalItem(
            title: '7. Uzmanlar',
            text:
                'Plango’da yer alan doğrulanmış uzmanlar, çalıştıkları kurum bilgileri doğrulanan kullanıcılardır. Kullanıcı ile uzman arasında kurulacak ticari ilişkinin tarafı Plango değildir.',
          ),
          LegalItem(
            title: '8. Nihai Planlama',
            text:
                'Nihai planlama, sözleşme şartları ve teslim bilgileri ilgili tasarruf finansman kuruluşu tarafından belirlenir.',
          ),
          LegalItem(
            title: '9. Kullanıcı Sorumluluğu',
            text:
                'Kullanıcı tarafından girilen bilgilerin doğruluğu kullanıcının sorumluluğundadır.',
          ),
          LegalItem(
            title: '10. Marka Hakları',
            text:
                'Uygulamada adı geçen tasarruf finansman kuruluşlarına ait marka adları ilgili hak sahiplerine aittir. Plango bağımsız bir platformdur.',
          ),
          LegalItem(
            title: '11. Son Uyarı',
            text:
                'Resmî karar vermeden önce ilgili tasarruf finansman kuruluşundan güncel bilgi almanız tavsiye edilir.',
          ),
        ],
      ),
    );
  }
}

class LegalHeader extends StatelessWidget {
  const LegalHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Text(
        'Plango, Türkiye’nin ilk bağımsız tasarruf finansmanı karar destek platformudur.',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w900,
          height: 1.35,
        ),
      ),
    );
  }
}

class LegalItem extends StatelessWidget {
  final String title;
  final String text;

  const LegalItem({
    super.key,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}