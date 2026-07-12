import 'package:flutter/material.dart';

class SavingsFinanceSystemScreen extends StatelessWidget {
  const SavingsFinanceSystemScreen({super.key});

  static const Color _green = Color(0xFF0B5D3B);
  static const Color _dark = Color(0xFF10231B);
  static const Color _background = Color(0xFFF7F8F5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _dark,
        elevation: 0,
        title: const Text(
          'Tasarruf Finansman Sistemi',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: const [
          _IntroductionCard(),
          SizedBox(height: 16),

          _InformationTile(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Tasarruf Finansmanı Nedir?',
            content:
                'Tasarruf finansmanı; katılımcıların belirli bir plan kapsamında '
                'tasarruf ederek konut, araç veya iş yeri edinmek amacıyla '
                'finansman sağladığı, faizsiz finansman yöntemlerinden biridir.\n\n'
                'Sistem, Bankacılık Düzenleme ve Denetleme Kurumu tarafından '
                'yetkilendirilen tasarruf finansman şirketleri tarafından '
                'yürütülür. Şirketler, katılımcıların tasarruflarını ve '
                'finansman süreçlerini ilgili mevzuat ve sözleşme hükümleri '
                'çerçevesinde yönetir.',
          ),

          _InformationTile(
            icon: Icons.sync_alt_outlined,
            title: 'Sistem Nasıl Çalışır?',
            content:
                'Kullanıcı; finansman tutarı, peşinat, aylık ödeme tutarı ve '
                'ödeme modeline göre bir tasarruf planına katılır.\n\n'
                'Belirlenen plan doğrultusunda düzenli ödemeler yapılır. '
                'Finansman teslimatı; tercih edilen planın türüne, birikim '
                'oranına, ödeme düzenine, sözleşme şartlarına ve ilgili '
                'mevzuata göre gerçekleşir.\n\n'
                'Her şirketin sunduğu planların ayrıntıları farklı olabilir. '
                'Kesin ödeme ve teslimat koşulları, ilgili şirketin resmî '
                'teklifi ve sözleşmesiyle belirlenir.',
          ),

          _InformationTile(
            icon: Icons.casino_outlined,
            title: 'Çekilişli Sistem',
            content:
                'Çekilişli sistemde katılımcıların finansman teslimat sırası, '
                'belirlenen dönemlerde gerçekleştirilen çekilişlerle '
                'belirlenebilir.\n\n'
                'Çekilişte adı belirlenmeyen katılımcı finansman hakkını '
                'kaybetmez. Katılımcı, sözleşmesindeki plan ve geçerli sistem '
                'kuralları doğrultusunda finansman almaya devam eder.\n\n'
                'Çekilişlerin uygulanma şekli ve teslimat koşulları şirketin '
                'sunduğu plan ile sözleşme hükümlerine göre değişebilir.',
          ),

          _InformationTile(
            icon: Icons.event_available_outlined,
            title: 'Çekilişsiz Sistem',
            content:
                'Çekilişsiz sistemlerde tahmini teslimat zamanı; peşinat, '
                'aylık ödeme tutarı, birikim oranı ve seçilen ödeme planına '
                'göre belirlenir.\n\n'
                'Teslimat sırası çekilişe bağlı değildir. Ancak hesaplanan '
                'tarihlerin tahmini olabileceği ve kesin tarihin ilgili '
                'şirketin resmî planı ile sözleşmesinde belirleneceği '
                'unutulmamalıdır.',
          ),

          _InformationTile(
            icon: Icons.receipt_long_outlined,
            title: 'Organizasyon Ücreti',
            content:
                'Tasarruf finansman şirketleri, sistemin kurulması ve '
                'yönetilmesi kapsamında organizasyon ücreti tahsil edebilir.\n\n'
                'Organizasyon ücretinin oranı, tutarı, ödeme şekli ve iade '
                'koşulları şirketlere ve tercih edilen plana göre farklılık '
                'gösterebilir.\n\n'
                'Sözleşme imzalanmadan önce organizasyon ücretinin toplam '
                'tutarı ve hangi koşullarda iade edilip edilemeyeceği dikkatle '
                'incelenmelidir.',
          ),

          _InformationTile(
            icon: Icons.home_work_outlined,
            title: 'Teslimat Süreci',
            content:
                'Teslimat süreci; katılımcının gerekli şartları tamamlaması, '
                'ödeme düzenini koruması ve ilgili sözleşme koşullarını yerine '
                'getirmesiyle ilerler.\n\n'
                'Teslimat öncesinde satın alınacak konut, araç veya iş yeri '
                'için şirket tarafından çeşitli belge ve güvence talepleri '
                'olabilir.\n\n'
                'Teslimat tarihi, finansman tutarı ve diğer resmî koşullar '
                'yalnızca ilgili tasarruf finansman şirketi tarafından '
                'kesinleştirilebilir.',
          ),

          _InformationTile(
            icon: Icons.thumb_up_alt_outlined,
            title: 'Avantajları',
            content:
                'Tasarruf finansman sistemi, faizsiz bir yöntemle konut, araç '
                'veya iş yeri edinmek isteyen kişiler için alternatif bir '
                'finansman modeli sunar.\n\n'
                'Farklı peşinat, taksit ve ödeme artış modellerinin '
                'sunulabilmesi, kullanıcıların kendi bütçelerine uygun bir '
                'plan oluşturmasına yardımcı olabilir.\n\n'
                'Avantajların kişiye ve seçilen plana göre değişebileceği '
                'unutulmamalıdır.',
          ),

          _InformationTile(
            icon: Icons.warning_amber_rounded,
            title: 'Dikkat Edilmesi Gerekenler',
            content:
                'Sisteme katılmadan önce şirketin BDDK tarafından '
                'yetkilendirilmiş olup olmadığı kontrol edilmelidir.\n\n'
                'Organizasyon ücreti, toplam ödeme yükü, taksit artışları, '
                'teslimat şartları, fesih, cayma ve iade koşulları ayrıntılı '
                'şekilde incelenmelidir.\n\n'
                'Sözlü bilgilendirmeler yerine resmî teklif ve sözleşme '
                'hükümleri esas alınmalıdır. Anlaşılmayan maddeler için '
                'sözleşme imzalanmadan önce ilgili şirketten yazılı açıklama '
                'istenmesi faydalı olabilir.',
          ),

          SizedBox(height: 12),
          _FooterNotice(),
        ],
      ),
    );
  }
}

class _IntroductionCard extends StatelessWidget {
  const _IntroductionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1EC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.menu_book_outlined,
            color: SavingsFinanceSystemScreen._green,
            size: 28,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tasarruf finansman sisteminin temel çalışma yapısını '
              'öğrenmek için başlıklara dokunabilirsiniz.',
              style: TextStyle(
                fontSize: 15,
                height: 1.45,
                fontWeight: FontWeight.w600,
                color: SavingsFinanceSystemScreen._dark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InformationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _InformationTile({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: Colors.black.withValues(alpha: 0.06),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        iconColor: SavingsFinanceSystemScreen._green,
        collapsedIconColor: SavingsFinanceSystemScreen._green,
        tilePadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F1EC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: SavingsFinanceSystemScreen._green,
            size: 23,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: SavingsFinanceSystemScreen._dark,
          ),
        ),
        children: [
          const Divider(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 15,
                height: 1.55,
                color: Color(0xFF39433F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterNotice extends StatelessWidget {
  const _FooterNotice();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        'Bu sayfadaki bilgiler genel bilgilendirme amacı taşır. '
        'Kesin plan, ödeme, sözleşme ve teslimat koşulları ilgili '
        'tasarruf finansman şirketi tarafından belirlenir.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          height: 1.45,
          color: Colors.black54,
        ),
      ),
    );
  }
}