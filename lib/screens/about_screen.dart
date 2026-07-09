import 'package:flutter/material.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  int? openIndex;

  static const Color primaryGreen = Color(0xFF0F7A4F);
  static const Color darkGreen = Color(0xFF064E3B);
  static const Color softGreen = Color(0xFFEAF7F1);
  static const Color pageBg = Color(0xFFF7F9F8);

  final sections = const [
    AboutSection(
      icon: Icons.explore_outlined,
      title: 'Plango Nedir?',
      content:
          'Plango, Türkiye’deki tasarruf finansmanı sistemini daha anlaşılır, erişilebilir ve takip edilebilir hale getirmek amacıyla geliştirilen bağımsız bir tasarruf finansmanı karar destek platformudur.\n\n'
          'Plango; kullanıcıların finansman tutarı, peşinat, taksit, vade ve ödeme modeli gibi bilgileri girerek farklı planlama senaryoları oluşturmasına yardımcı olur. Uygulama, kullanıcıya hesaplama yapma, tahmini sonuçları görme, sistem hakkında bilgi edinme ve doğrulanmış sektör uzmanlarıyla iletişim kurma imkânı sunar.\n\n'
          'Plango herhangi bir tasarruf finansman şirketinin yerine geçmez, şirketler adına işlem yapmaz ve kullanıcı adına karar vermez. Plango’nun temel amacı; kullanıcıların tasarruf finansmanı sürecini daha bilinçli şekilde değerlendirebilmesine destek olmaktır.',
    ),
    AboutSection(
      icon: Icons.lightbulb_outline,
      title: 'Neden Plango Geliştirildi?',
      content:
          'Tasarruf finansmanı sistemi; ev, araç ve çatılı iş yeri gibi ihtiyaçlara ulaşmak isteyen kullanıcılar için önemli bir finansman modeli haline gelmiştir. Ancak bu sistemde finansman tutarı, peşinat, aylık ödeme, teslimat süresi, vade, mevzuat ve farklı ödeme modelleri gibi birçok değişken bulunmaktadır.\n\n'
          'Bu değişkenler, kullanıcıların planlarını kendi başına değerlendirmesini zaman zaman zorlaştırabilir. Kullanıcılar çoğu zaman “Ne kadar peşinat verirsem teslimatım nasıl etkilenir?”, “Aylık taksitim değişirse vadem ne olur?”, “Artışlı ödeme modeli bana nasıl bir tablo çıkarır?” gibi sorulara hızlı ve anlaşılır yanıtlar arar.\n\n'
          'Plango, bu ihtiyaca destek olmak için geliştirilmiştir. Amaç; kullanıcıların diledikleri senaryoları kolayca hesaplayabileceği, tasarruf finansmanı sistemini daha net anlayabileceği ve sektörel gelişmeleri takip edebileceği bağımsız bir dijital alan oluşturmaktır.',
    ),
    AboutSection(
      icon: Icons.flag_outlined,
      title: 'Misyonumuz',
      content:
          'Plango’nun misyonu; tasarruf finansmanı sistemine ilişkin hesaplama, bilgilendirme ve yönlendirme süreçlerini daha anlaşılır hale getirerek kullanıcıların bilinçli karar verebilmesine destek olmaktır.\n\n'
          'Plango, kullanıcıya nihai karar sunmaz; karar sürecinde ihtiyaç duyabileceği bilgileri, tahmini analizleri ve yardımcı araçları sağlar.',
    ),
    AboutSection(
      icon: Icons.public,
      title: 'Vizyonumuz',
      content:
          'Plango’nun vizyonu; tasarruf finansmanı alanında kullanıcıların hesaplama yapabildiği, sistemi anlayabildiği, güncel gelişmeleri takip edebildiği ve doğrulanmış sektör uzmanlarıyla iletişim kurabildiği kapsamlı bir karar destek platformu olmaktır.\n\n'
          'Plango, sektördeki şirketlerin veya uzmanların yerine geçmeyi değil; kullanıcı ile bilgi arasında daha sade, anlaşılır ve tarafsız bir köprü kurmayı hedefler.',
    ),
    AboutSection(
      icon: Icons.balance_outlined,
      title: 'İlkelerimiz',
      content:
          'Bağımsızlık\nPlango, herhangi bir tasarruf finansman şirketinin resmî uygulaması değildir.\n\n'
          'Tarafsızlık\nPlango, herhangi bir şirketi, uzmanı veya ödeme modelini diğerlerinden üstün göstermeyi amaçlamaz.\n\n'
          'Bilgilendirme Odaklılık\nPlango’nun temel görevi, kullanıcıların tasarruf finansmanı sistemini daha kolay anlamasına yardımcı olmaktır.\n\n'
          'Karar Kullanıcıya Aittir\nPlango, kullanıcı adına karar vermez. Nihai karar her zaman kullanıcıya aittir.\n\n'
          'Şeffaflık\nPlango, sunduğu hesaplama ve bilgilendirme araçlarının tahmini ve destekleyici nitelikte olduğunu açıkça belirtir.\n\n'
          'Sektöre Saygılı Yaklaşım\nPlango, tasarruf finansmanı ekosisteminde faaliyet gösteren şirketlere ve sektör profesyonellerine tarafsız bir çerçevede yaklaşır.\n\n'
          'Sürekli Gelişim\nPlango, kullanıcı ihtiyaçlarına, mevzuat değişikliklerine ve sektörel gelişmelere göre kendini geliştirmeyi hedefler.',
    ),
    AboutSection(
      icon: Icons.memory_outlined,
      title: 'FP Engine Nedir?',
      content:
          'FP Engine, Plango içerisinde kullanılan bağımsız hesaplama motorudur.\n\n'
          'Kullanıcı tarafından girilen finansman tutarı, peşinat, taksit, ödeme modeli ve benzeri bilgiler doğrultusunda tahmini vade ve teslimat analizleri oluşturur.\n\n'
          'FP Engine sonuçları, yalnızca bilgilendirme ve karar destek amacı taşır. Bu sonuçlar kesin teslim tarihi, resmî ödeme planı veya şirket onayı anlamına gelmez.\n\n'
          'Resmî sözleşme koşulları, ödeme planları, teslimat tarihleri ve diğer süreçler ilgili tasarruf finansman şirketi tarafından belirlenir.',
    ),
    AboutSection(
      icon: Icons.verified_user_outlined,
      title: 'Doğrulanmış Uzman Sistemi',
      content:
          'Plango’da yer alan uzman profilleri, doğrulama sürecini tamamlamış sektör profesyonellerinden oluşur.\n\n'
          'Bu sistemin amacı, kullanıcıların tasarruf finansmanı alanında çalışan uzmanlara daha kolay ulaşabilmesini sağlamaktır. Bir uzmanın Plango’da yer alması, diğer uzmanlar hakkında olumlu veya olumsuz bir değerlendirme anlamına gelmez.\n\n'
          'Plango, uzman profillerini kullanıcıya bilgi ve iletişim kolaylığı sağlamak amacıyla listeler. Uzmanlar tarafından sunulan bilgiler, ilgili uzmanın kendi mesleki değerlendirmesi kapsamındadır.',
    ),
    AboutSection(
      icon: Icons.assignment_outlined,
      title: 'Plango’nun Kapsamı',
      content:
          'Plango’nun sunduğu hizmetler:\n\n'
          '• Tasarruf finansmanı planı hesaplama\n'
          '• Tahmini vade ve teslimat analizi\n'
          '• Farklı ödeme modelleriyle senaryo oluşturma\n'
          '• Tasarruf finansmanı sistemi hakkında bilgilendirme\n'
          '• Güncel mevzuat ve sektör gelişmelerini takip etmeyi kolaylaştırma\n'
          '• Lisanslı tasarruf finansman şirketleri hakkında bilgilendirici içerikler sunma\n'
          '• Doğrulanmış sektör uzmanı profillerini listeleme\n'
          '• Kullanıcının karar sürecine destek olacak yardımcı araçlar sunma\n\n'
          'Plango aşağıdaki işlemleri gerçekleştirmez:\n\n'
          '• Finansman sağlamaz.\n'
          '• Sözleşme düzenlemez.\n'
          '• Ödeme tahsil etmez.\n'
          '• Teslimat tarihi belirlemez.\n'
          '• Herhangi bir şirket adına işlem yapmaz.\n'
          '• Kullanıcı adına başvuru veya sözleşme süreci yürütmez.\n'
          '• Hukuki, finansal veya yatırım danışmanlığı hizmeti vermez.\n'
          '• Herhangi bir şirketi veya uzmanı tavsiye etmez.',
    ),
    AboutSection(
      icon: Icons.campaign_outlined,
      title: 'Güncel Bilgilendirme',
      content:
          'Tasarruf finansman sistemi, mevzuat ve sektör uygulamaları zaman içinde değişebilir. Plango, kullanıcıların bu gelişmeleri daha kolay takip edebilmesine yardımcı olmayı amaçlar.\n\n'
          'Platformda yer alan bilgilendirmeler, kullanıcıların sektörel gelişmeler hakkında genel fikir edinmesi için hazırlanır. Resmî ve bağlayıcı bilgiler için ilgili kurumların, mevzuat kaynaklarının ve tasarruf finansman şirketlerinin açıklamaları esas alınmalıdır.',
    ),
    AboutSection(
      icon: Icons.favorite_border,
      title: 'Son Söz',
      content:
          'Plango, kullanıcıların tasarruf finansmanı sürecini daha anlaşılır şekilde değerlendirebilmesi için geliştirilmiş bağımsız bir karar destek platformudur.\n\n'
          'Plango bilgi sunar, hesaplama yapar ve kullanıcıların farklı senaryoları görmesine yardımcı olur. Nihai karar, resmî süreç ve sözleşme koşulları her zaman kullanıcı ile ilgili tasarruf finansman şirketi arasında yürütülür.\n\n'
          'Plango’nun amacı, karar vermek değil; kullanıcıların karar sürecini daha bilinçli şekilde yönetmesine destek olmaktır.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        title: const Text('Hakkımızda'),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _AboutHeroCard(),
          const SizedBox(height: 16),
          const _IntroBox(),
          const SizedBox(height: 16),
          ...List.generate(sections.length, (index) {
            final section = sections[index];
            final isOpen = openIndex == index;

            return _AccordionCard(
              section: section,
              isOpen: isOpen,
              onTap: () {
                setState(() {
                  openIndex = isOpen ? null : index;
                });
              },
            );
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class AboutSection {
  final IconData icon;
  final String title;
  final String content;

  const AboutSection({
    required this.icon,
    required this.title,
    required this.content,
  });
}

class _AboutHeroCard extends StatelessWidget {
  const _AboutHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            _AboutScreenState.darkGreen,
            _AboutScreenState.primaryGreen,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: _AboutScreenState.primaryGreen.withOpacity(0.25),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PLANGO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Bağımsız Tasarruf Finansmanı\nKarar Destek Platformu',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 18),
          Text(
            'Bilgi sunar. Hesaplama yapar. Karar sürecine destek olur.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _IntroBox extends StatelessWidget {
  const _IntroBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _AboutScreenState.softGreen,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _AboutScreenState.primaryGreen.withOpacity(0.18),
        ),
      ),
      child: const Text(
        'Plango; kullanıcıların tasarruf finansmanı sürecini daha anlaşılır şekilde değerlendirebilmesi için geliştirilmiş bağımsız bir karar destek platformudur.',
        style: TextStyle(
          fontSize: 14.5,
          height: 1.5,
          color: Color(0xFF064E3B),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AccordionCard extends StatelessWidget {
  final AboutSection section;
  final bool isOpen;
  final VoidCallback onTap;

  const _AccordionCard({
    required this.section,
    required this.isOpen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOpen
              ? _AboutScreenState.primaryGreen.withOpacity(0.35)
              : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isOpen ? 0.06 : 0.035),
            blurRadius: isOpen ? 18 : 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _AboutScreenState.softGreen,
                    foregroundColor: _AboutScreenState.primaryGreen,
                    child: Icon(section.icon, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      section.title,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 220),
                    turns: isOpen ? 0.5 : 0,
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: _AboutScreenState.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 3,
                    width: 44,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: _AboutScreenState.primaryGreen,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  Text(
                    section.content,
                    style: const TextStyle(
                      fontSize: 14.5,
                      height: 1.58,
                      color: Color(0xFF374151),
                    ),
                  ),
                ],
              ),
            ),
            crossFadeState:
                isOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }
}