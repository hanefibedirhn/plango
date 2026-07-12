import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const Color _green = Color(0xFF0B5D3B);
  static const Color _background = Color(0xFFF7F8F5);
  static const Color _textDark = Color(0xFF111827);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _border = Color(0xFFE5E7EB);

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
        foregroundColor: _textDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Sıkça Sorulan Sorular',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 32),
          children: [
            const _FaqHeader(),
            const SizedBox(height: 18),
            for (final item in _items)
              _FaqCard(item: item),
          ],
        ),
      ),
    );
  }
}

class _FaqHeader extends StatelessWidget {
  const _FaqHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1EC),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.help_outline_rounded,
            color: FaqScreen._green,
            size: 30,
          ),
          SizedBox(width: 13),
          Expanded(
            child: Text(
              'Tasarruf finansmanı, Plango ve hesap işlemleriyle ilgili '
              'sık sorulan soruların yanıtlarını burada bulabilirsiniz.',
              style: TextStyle(
                color: FaqScreen._textDark,
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqCard extends StatelessWidget {
  const _FaqCard({
    required this.item,
  });

  final _FaqItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: FaqScreen._border,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 5,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            18,
          ),
          iconColor: FaqScreen._green,
          collapsedIconColor: const Color(0xFF9CA3AF),
          title: Text(
            item.question,
            style: const TextStyle(
              color: FaqScreen._textDark,
              fontSize: 14.5,
              height: 1.35,
              fontWeight: FontWeight.w800,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                item.answer,
                style: const TextStyle(
                  color: FaqScreen._textMuted,
                  fontSize: 13.5,
                  height: 1.6,
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

class _FaqItem {
  const _FaqItem({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;
}