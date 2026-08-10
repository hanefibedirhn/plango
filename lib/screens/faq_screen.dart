import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const Color _green = Color(0xFF087C72);
  static const Color _background = Color(0xFFF7F9FB);
  static const Color _textDark = Color(0xFF0B2239);
  static const Color _textMuted = Color(0xFF748193);
  static const Color _border = Color(0xFFE2EAEE);

  static const List<_FaqItem> _items = [
    _FaqItem(
      question: 'Tasarruf finansmanı nedir?',
      answer:
          'Tasarruf finansmanı; katılımcıların belirli bir plan kapsamında '
          'tasarruf yaparak konut, araç veya iş yeri gibi ihtiyaçları için '
          'finansman elde etmeyi amaçladığı faizsiz bir finansman modelidir. '
          'Resmî uygulama koşulları ve sözleşme hükümleri ilgili tasarruf '
          'finansman şirketi tarafından belirlenir.',
    ),
    _FaqItem(
      question: 'Sistem nasıl çalışır?',
      answer:
          'Kullanıcı; finansman tutarı, peşinat, aylık ödeme ve ödeme modeline '
          'göre bir plan oluşturur. Birikim ve ödeme süreci sözleşmedeki '
          'koşullara göre ilerler. Teslimat zamanı, şirketin uyguladığı plan, '
          'sözleşme şartları ve yürürlükteki kurallara göre değişebilir.',
    ),
    _FaqItem(
      question: 'Çekilişli sistem nedir?',
      answer:
          'Çekilişli sistemde teslim sırası, ilgili planın kuralları '
          'çerçevesinde yapılan çekilişlerle belirlenebilir. Çekilişte adı '
          'çıkmayan katılımcılar finansman hakkını kaybetmez; hakları plan ve '
          'uygulanabilir kurallar doğrultusunda devam eder.',
    ),
    _FaqItem(
      question: 'Çekilişsiz sistem nedir?',
      answer:
          'Çekilişsiz sistemde teslimat, çekilişe bağlı olmadan; peşinat, '
          'aylık ödeme, vade ve sözleşme koşullarına göre belirlenen plan '
          'üzerinden ilerler.',
    ),
    _FaqItem(
      question: 'Organizasyon ücreti nedir?',
      answer:
          'Organizasyon ücreti; şirketin sistemin kurulması, yönetilmesi ve '
          'hizmetlerin sunulması karşılığında talep ettiği bedeldir. Tutarı, '
          'ödeme şekli ve iade koşulları şirket ve sözleşmeye göre değişebilir.',
    ),
    _FaqItem(
      question: 'Teslimat tarihi nasıl belirlenir?',
      answer:
          'Teslimat tarihi; finansman tutarı, peşinat, aylık ödeme, ödeme '
          'modeli, sözleşme koşulları ve ilgili şirketin uygulamalarına göre '
          'belirlenir. Plango tarafından gösterilen süreler yalnızca tahmini '
          've bilgilendirme amaçlıdır.',
    ),
    _FaqItem(
      question: 'En erken teslimat süresi nedir?',
      answer:
          'En erken teslimat süresi, yürürlükteki düzenlemeler ve şirket '
          'uygulamalarına göre belirlenir. Güncel ve bağlayıcı bilgi için '
          'ilgili şirketin sözleşmesi ve resmî açıklamaları esas alınmalıdır.',
    ),
    _FaqItem(
      question: 'Asgari birikim oranı nedir?',
      answer:
          'Asgari birikim oranı, teslimat öncesinde tamamlanması gereken '
          'birikim seviyesini ifade eder. Oranlar yürürlükteki mevzuat, plan '
          'türü ve şirket uygulamalarına göre değişebilir.',
    ),
    _FaqItem(
      question: 'Taksitler zamanla artabilir mi?',
      answer:
          'Evet. Sabit ödeme planlarının yanında aylık, 3 ayda bir, 6 ayda '
          'bir veya 12 ayda bir artışlı modeller bulunabilir. Artış oranı ve '
          'periyodu seçilen planın koşullarına bağlıdır.',
    ),
    _FaqItem(
      question: 'Taksitler daha sonra düşebilir mi?',
      answer:
          'Artışlı ödeme modellerinde temel beklenti taksitlerin belirlenen '
          'artış yapısına göre ilerlemesidir. Plango hesaplamalarında taksit '
          'düşüşü varsayılmaz. Resmî ödeme planı ilgili şirket tarafından '
          'belirlenir.',
    ),
    _FaqItem(
      question: 'Son taksit neden farklı olabilir?',
      answer:
          'Toplam kalan borcun kapanması için son taksit diğer taksitlerden '
          'farklı hesaplanabilir. Bu durum ödeme planının toplam tutarı tam '
          'olarak tamamlaması amacıyla oluşur.',
    ),
    _FaqItem(
      question: 'Erken ödeme veya erken kapama yapılabilir mi?',
      answer:
          'Erken ödeme ve erken kapama koşulları şirketin sözleşmesine göre '
          'değişir. Bu işlemlerin teslimat tarihine, kalan borca veya diğer '
          'haklara etkisi için ilgili şirketten yazılı bilgi alınmalıdır.',
    ),
    _FaqItem(
      question: 'Cayma hakkı var mı?',
      answer:
          'Cayma ve fesih hakları; yürürlükteki mevzuat, sözleşme tarihi ve '
          'sözleşme hükümlerine göre değerlendirilir. Süreler ve iade '
          'koşulları için sözleşmenin ilgili maddeleri incelenmelidir.',
    ),
    _FaqItem(
      question: 'Şirketler arasında teslimat süresi neden değişebilir?',
      answer:
          'Şirketlerin hesaplama yöntemleri, kampanyaları, plan kuralları ve '
          'operasyon süreçleri farklı olabilir. Bu nedenle aynı bilgilerle '
          'oluşturulan planlarda şirketler arasında süre farkı görülebilir.',
    ),
    _FaqItem(
      question: 'FP Engine sonuçları kesin midir?',
      answer:
          'Hayır. FP Engine, kullanıcının girdiği verilere göre bilgilendirme '
          'amaçlı tahmini sonuç üretir. Resmî plan, sözleşme, ödeme takvimi ve '
          'teslim tarihi ilgili tasarruf finansman şirketi tarafından belirlenir.',
    ),
    _FaqItem(
      question: 'Plango herhangi bir şirketi temsil ediyor mu?',
      answer:
          'Hayır. Plango bağımsız bir karar destek platformudur. Herhangi bir '
          'tasarruf finansman şirketi adına sözleşme düzenlemez, satış yapmaz '
          've bağlayıcı teslimat taahhüdünde bulunmaz.',
    ),
    _FaqItem(
      question: 'Plango üzerinden sözleşme yapılabilir mi?',
      answer:
          'Hayır. Plango hesaplama, karşılaştırma, bilgilendirme ve kullanıcıyı '
          'uzmanlarla buluşturma amacı taşır. Resmî sözleşme işlemleri ilgili '
          'şirket üzerinden gerçekleştirilir.',
    ),
    _FaqItem(
      question: 'Uzmanlar nasıl seçilir?',
      answer:
          'Uzmanlar başvuru ve değerlendirme süreçlerinden geçer. Kullanıcıya '
          'gösterilen uzman profilleri, Plango içindeki yetki ve profil '
          'durumuna göre listelenir.',
    ),
    _FaqItem(
      question: 'Danışma talebi nasıl oluşturulur?',
      answer:
          'Kullanıcı bir uzman seçerek finansman ihtiyacı, ödeme bilgileri ve '
          'varsa notunu içeren danışma talebi oluşturabilir. Telefon bilgisi '
          'danışma talebi sırasında zorunlu tutulabilir.',
    ),
    _FaqItem(
      question: 'Danışma talebimin durumunu nereden görürüm?',
      answer:
          'Hesabım bölümündeki Danışma Taleplerim ekranından talebin bekleme, '
          'kabul, yanıt veya tamamlanma durumunu takip edebilirsiniz.',
    ),
    _FaqItem(
      question: 'Planlarımı kaydedebilir miyim?',
      answer:
          'Evet. Hesaplama sonucunda oluşturduğunuz planları hesabınıza '
          'kaydedebilir ve Kayıtlı Planlarım bölümünden daha sonra yeniden '
          'görüntüleyebilirsiniz.',
    ),
    _FaqItem(
      question: 'Telefon numaram neden isteniyor?',
      answer:
          'Telefon numarası, danışma talebinin seçtiğiniz uzmana iletilmesi '
          've iletişim kurulabilmesi amacıyla istenebilir. Kullanıcının '
          'profilinde kayıtlı değilse danışma sırasında eklenebilir.',
    ),
    _FaqItem(
      question: 'Şifremi unuttum, ne yapmalıyım?',
      answer:
          'Giriş ekranındaki Şifremi Unuttum seçeneğini kullanarak kayıtlı '
          'e-posta adresinize şifre yenileme bağlantısı gönderebilirsiniz.',
    ),
    _FaqItem(
      question: 'Hesabımı silebilir miyim?',
      answer:
          'Evet. Profil Bilgilerim ekranından mevcut şifrenizi doğrulayarak '
          'hesabınızı kalıcı olarak silebilirsiniz. Bu işlem geri alınamaz.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: const Color(0xFF0B2239),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 4,
        title: const Text(
          'Sıkça Sorulan Sorular',
          style: TextStyle(
            color: Color(0xFF0B2239),
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.35,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            const _FaqHeroCard(),
            const SizedBox(height: 18),
            const _SectionTitle(),
            const SizedBox(height: 10),
            for (int index = 0; index < _items.length; index++)
              _PremiumFaqCard(
                item: _items[index],
                index: index,
              ),
            const SizedBox(height: 8),
            const _FooterInfoCard(),
          ],
        ),
      ),
    );
  }
}

class _FaqHeroCard extends StatelessWidget {
  const _FaqHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0B2239),
            Color(0xFF0C5262),
            Color(0xFF087C72),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x240B2239),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -16,
            top: -18,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            right: 28,
            bottom: -38,
            child: Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF16C7B0).withOpacity(0.10),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF16C7B0).withOpacity(0.16),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFF54E2D0).withOpacity(0.30),
                  ),
                ),
                child: const Icon(
                  Icons.help_outline_rounded,
                  color: Color(0xFF54E2D0),
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sıkça Sorulan Sorular',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        height: 1.1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.35,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tasarruf finansmanı, Plango ve hesap işlemleriyle ilgili '
                      'sık sorulan soruların yanıtlarını burada bulabilirsiniz.',
                      style: TextStyle(
                        color: Color(0xFFD8E7E8),
                        fontSize: 12.5,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(
          Icons.auto_awesome_rounded,
          color: Color(0xFF087C72),
          size: 18,
        ),
        SizedBox(width: 7),
        Text(
          'Merak Edilenler',
          style: TextStyle(
            color: Color(0xFF0B2239),
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

class _PremiumFaqCard extends StatelessWidget {
  const _PremiumFaqCard({
    required this.item,
    required this.index,
  });

  final _FaqItem item;
  final int index;

  static IconData _iconFor(int index) {
    const icons = <IconData>[
      Icons.account_balance_outlined,
      Icons.schema_outlined,
      Icons.casino_outlined,
      Icons.route_outlined,
      Icons.receipt_long_outlined,
      Icons.event_available_outlined,
      Icons.schedule_outlined,
      Icons.account_balance_outlined,
      Icons.trending_up_rounded,
      Icons.trending_flat_rounded,
      Icons.calculate_outlined,
      Icons.payments_outlined,
      Icons.gavel_outlined,
      Icons.compare_arrows_rounded,
      Icons.memory_outlined,
      Icons.verified_user_outlined,
      Icons.description_outlined,
      Icons.workspace_premium_outlined,
      Icons.support_agent_outlined,
      Icons.fact_check_outlined,
      Icons.bookmark_outline_rounded,
      Icons.phone_outlined,
      Icons.lock_reset_outlined,
      Icons.delete_outline_rounded,
    ];
    return icons[index % icons.length];
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0B2239);
    const teal = Color(0xFF087C72);
    const turquoise = Color(0xFF16C7B0);
    const border = Color(0xFFE2EAEE);
    const muted = Color(0xFF6F7D8A);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0B2239),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: turquoise.withOpacity(0.05),
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.fromLTRB(12, 5, 12, 5),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          backgroundColor: const Color(0xFFF7FBFC),
          collapsedBackgroundColor: Colors.white,
          iconColor: teal,
          collapsedIconColor: const Color(0xFF91A0AA),
          shape: const Border(),
          collapsedShape: const Border(),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  teal.withOpacity(0.13),
                  turquoise.withOpacity(0.10),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _iconFor(index),
              color: teal,
              size: 20,
            ),
          ),
          title: Text(
            item.question,
            style: const TextStyle(
              color: navy,
              fontSize: 14,
              height: 1.3,
              fontWeight: FontWeight.w800,
            ),
          ),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFE6EEF1),
                ),
              ),
              child: Text(
                item.answer,
                style: const TextStyle(
                  color: muted,
                  fontSize: 13,
                  height: 1.58,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterInfoCard extends StatelessWidget {
  const _FooterInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 13, 15, 13),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7F5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD5ECE8),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF087C72),
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Resmî plan, sözleşme ve teslim bilgileri ilgili tasarruf finansman '
              'şirketi tarafından belirlenir.',
              style: TextStyle(
                color: Color(0xFF48636B),
                fontSize: 11.5,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqItem {
  const _FaqItem({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;
}
