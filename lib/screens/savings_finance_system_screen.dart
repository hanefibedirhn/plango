import 'package:flutter/material.dart';

import 'calculator_screen.dart';

class SavingsFinanceSystemScreen extends StatelessWidget {
  const SavingsFinanceSystemScreen({super.key});

  static const Color _navy = Color(0xFF102E3A);
  static const Color _darkNavy = Color(0xFF0A2029);
  static const Color _teal = Color(0xFF009688);
  static const Color _lightTeal = Color(0xFFE8F5F2);
  static const Color _background = Color(0xFFF5F7F7);
  static const Color _textDark = Color(0xFF18312F);
  static const Color _textSoft = Color(0xFF64716F);

  void _openCalculator(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CalculatorScreen(),
      ),
    );
  }

  void _openExpertSupport(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const CalculatorScreen(),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _textDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        title: const Text(
          'Tasarruf Finansman Sistemi',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: _textDark,
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
        children: [
          _HeroCard(
            onCreatePlanPressed: () => _openCalculator(context),
          ),
          const SizedBox(height: 16),

          const _IntroductionCard(),
          const SizedBox(height: 24),

          const _SectionHeader(
            eyebrow: 'SİSTEMİN İŞLEYİŞİ',
            title: 'Adım adım nasıl çalışır?',
            description:
                'Tasarruf planının başlangıcından teslimata kadar temel süreci incele.',
          ),
          const SizedBox(height: 14),

          const _ProcessCard(),
          const SizedBox(height: 26),

          const _SectionHeader(
            eyebrow: 'BİLGİ REHBERİ',
            title: 'Merak ettiğin başlığı seç',
            description:
                'Detayları görmek için aşağıdaki kartlara dokunabilirsin.',
          ),
          const SizedBox(height: 14),

          const _InformationTile(
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

          const _InformationTile(
            icon: Icons.sync_alt_rounded,
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

          const _InformationTile(
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

          const _InformationTile(
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

          const SizedBox(height: 4),

          const _HighlightNotice(
            icon: Icons.lightbulb_outline_rounded,
            title: 'Bilmen Faydalı',
            text:
                'Her tasarruf finansman şirketi farklı ödeme ve teslimat '
                'planları sunabilir. Karar vermeden önce resmî teklifleri ve '
                'sözleşme koşullarını birlikte incelemelisin.',
          ),

          const SizedBox(height: 16),

          const _InformationTile(
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

          const _InformationTile(
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

          const _InformationTile(
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

          const _InformationTile(
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

          const SizedBox(height: 8),

          const _ImportantNotice(),
          const SizedBox(height: 22),

          _ExpertSupportCard(
            onPressed: () => _openExpertSupport(context),
          ),

          const SizedBox(height: 18),

          const _FooterNotice(),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final VoidCallback onCreatePlanPressed;

  const _HeroCard({
    required this.onCreatePlanPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 220,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            SavingsFinanceSystemScreen._darkNavy,
            SavingsFinanceSystemScreen._navy,
            Color(0xFF126B67),
          ],
          stops: [0.0, 0.58, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: SavingsFinanceSystemScreen._navy.withOpacity(0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -38,
            top: -45,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.055),
              ),
            ),
          ),
          Positioned(
            right: 22,
            bottom: 14,
            child: Opacity(
              opacity: 0.24,
              child: Image.asset(
                'assets/images/home_hero_house_car.png',
                width: 150,
                height: 118,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) {
                  return const Icon(
                    Icons.home_work_outlined,
                    color: Colors.white,
                    size: 96,
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 265,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.18),
                      ),
                    ),
                    child: const Text(
                      'TASARRUF FİNANSMANI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sistemi kolayca keşfet.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      height: 1.12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    'Faizsiz finansman modelinin temel çalışma yapısını '
                    'adım adım öğren.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.82),
                      fontSize: 13.5,
                      height: 1.42,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: onCreatePlanPressed,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor:
                            SavingsFinanceSystemScreen._teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Plan Oluştur',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: SavingsFinanceSystemScreen._lightTeal,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: SavingsFinanceSystemScreen._teal.withOpacity(0.10),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SmallIconBox(
            icon: Icons.menu_book_outlined,
          ),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bu rehber nasıl kullanılır?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: SavingsFinanceSystemScreen._textDark,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Başlıklara dokunarak tasarruf finansman sisteminin '
                  'temel kavramlarını ve çalışma şeklini öğrenebilirsin.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: SavingsFinanceSystemScreen._textSoft,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String description;

  const _SectionHeader({
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: const TextStyle(
              color: SavingsFinanceSystemScreen._teal,
              fontSize: 10.5,
              letterSpacing: 1.15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              color: SavingsFinanceSystemScreen._textDark,
              fontSize: 20,
              height: 1.2,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              color: SavingsFinanceSystemScreen._textSoft,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProcessCard extends StatelessWidget {
  const _ProcessCard();

  static const List<_ProcessItem> _items = [
    _ProcessItem(
      icon: Icons.tune_rounded,
      title: 'Planını seç',
      description: 'Bütçene uygun ödeme modelini belirle.',
    ),
    _ProcessItem(
      icon: Icons.description_outlined,
      title: 'Sözleşmeni incele',
      description: 'Plan ve teslimat koşullarını kontrol et.',
    ),
    _ProcessItem(
      icon: Icons.savings_outlined,
      title: 'Tasarruf süreci',
      description: 'Ödemelerini seçtiğin plana göre sürdür.',
    ),
    _ProcessItem(
      icon: Icons.home_work_outlined,
      title: 'Teslimat',
      description: 'Gerekli koşullar tamamlandığında finansmanı al.',
    ),
    _ProcessItem(
      icon: Icons.calendar_month_outlined,
      title: 'Ödemeye devam et',
      description: 'Kalan plan ödemelerini düzenli şekilde tamamla.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        17,
        18,
        17,
        18,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.black.withOpacity(0.045),
        ),
        boxShadow: [
          BoxShadow(
            color: SavingsFinanceSystemScreen._navy.withOpacity(0.045),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: List.generate(
          _items.length,
          (index) {
            final item = _items[index];
            final isLast = index == _items.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: SavingsFinanceSystemScreen._lightTeal,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        item.icon,
                        color: SavingsFinanceSystemScreen._teal,
                        size: 21,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 37,
                        margin: const EdgeInsets.symmetric(
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: SavingsFinanceSystemScreen._teal
                              .withOpacity(0.16),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 2,
                      bottom: isLast ? 0 : 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            color:
                                SavingsFinanceSystemScreen._textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.description,
                          style: const TextStyle(
                            color:
                                SavingsFinanceSystemScreen._textSoft,
                            fontSize: 12.5,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProcessItem {
  final IconData icon;
  final String title;
  final String description;

  const _ProcessItem({
    required this.icon,
    required this.title,
    required this.description,
  });
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
      margin: const EdgeInsets.only(
        bottom: 11,
      ),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.black.withOpacity(0.045),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor:
              SavingsFinanceSystemScreen._teal.withOpacity(0.04),
          highlightColor:
              SavingsFinanceSystemScreen._teal.withOpacity(0.03),
        ),
        child: ExpansionTile(
          iconColor: SavingsFinanceSystemScreen._teal,
          collapsedIconColor: SavingsFinanceSystemScreen._teal,
          tilePadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 5,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            17,
            0,
            17,
            18,
          ),
          leading: Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: SavingsFinanceSystemScreen._lightTeal,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: SavingsFinanceSystemScreen._teal,
              size: 22,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 14.5,
              height: 1.2,
              fontWeight: FontWeight.w800,
              color: SavingsFinanceSystemScreen._textDark,
            ),
          ),
          children: [
            Container(
              height: 1,
              margin: const EdgeInsets.only(
                top: 2,
                bottom: 15,
              ),
              color: Colors.black.withOpacity(0.055),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                content,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.58,
                  color: Color(0xFF52615E),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HighlightNotice extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _HighlightNotice({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7F6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: SavingsFinanceSystemScreen._teal.withOpacity(0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SmallIconBox(
            icon: icon,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: SavingsFinanceSystemScreen._textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  text,
                  style: const TextStyle(
                    color: SavingsFinanceSystemScreen._textSoft,
                    fontSize: 12.8,
                    height: 1.48,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImportantNotice extends StatelessWidget {
  const _ImportantNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE3A72F).withOpacity(0.20),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SmallIconBox(
            icon: Icons.warning_amber_rounded,
            backgroundColor: Color(0xFFFFEEC8),
            iconColor: Color(0xFFA96A00),
          ),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Önemli bilgilendirme',
                  style: TextStyle(
                    color: SavingsFinanceSystemScreen._textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Plango tarafından sunulan hesaplamalar tahmini ve '
                  'bilgilendirme amaçlıdır. Kesin plan, ödeme ve teslimat '
                  'koşulları ilgili şirketin resmî teklifi ve sözleşmesiyle '
                  'belirlenir.',
                  style: TextStyle(
                    color: SavingsFinanceSystemScreen._textSoft,
                    fontSize: 12.8,
                    height: 1.48,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpertSupportCard extends StatelessWidget {
  final VoidCallback onPressed;

  const _ExpertSupportCard({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            SavingsFinanceSystemScreen._navy,
            Color(0xFF125752),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: SavingsFinanceSystemScreen._navy.withOpacity(0.14),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.11),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.12),
                  ),
                ),
                child: const Text(
                  'UZMAN DESTEĞİ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    letterSpacing: 1.05,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Sorularına uzman desteğiyle cevap bul.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              height: 1.2,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Tasarruf finansman sistemi, ödeme planları ve teslimat '
            'süreci hakkında merak ettiğin tüm konuları doğrulanmış '
            'uzmanlara danışabilirsin.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.76),
              fontSize: 12.5,
              height: 1.42,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: SavingsFinanceSystemScreen._teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Uzmana Sor',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(width: 7),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallIconBox extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  const _SmallIconBox({
    required this.icon,
    this.backgroundColor = Colors.white,
    this.iconColor = SavingsFinanceSystemScreen._teal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 41,
      height: 41,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 21,
      ),
    );
  }
}

class _FooterNotice extends StatelessWidget {
  const _FooterNotice();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 7,
      ),
      child: Text(
        'Bu sayfadaki bilgiler genel bilgilendirme amacı taşır. '
        'Kesin plan, ödeme, sözleşme ve teslimat koşulları ilgili '
        'tasarruf finansman şirketi tarafından belirlenir.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11.5,
          height: 1.48,
          color: Color(0xFF87918F),
        ),
      ),
    );
  }
}