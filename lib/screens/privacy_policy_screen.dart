import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  static const Color _navy = Color(0xFF0B2239);
  static const Color _petrol = Color(0xFF052F3D);
  static const Color _teal = Color(0xFF087C72);
  static const Color _turquoise = Color(0xFF16C7B0);
  static const Color _background = Color(0xFFF7F9FB);
  static const Color _muted = Color(0xFF748193);
  static const Color _border = Color(0xFFE4EBEE);

  int? _openIndex;

  final List<_PrivacySection> _sections = const [
    _PrivacySection(
      icon: Icons.shield_outlined,
      title: 'Gizlilik Politikamızın Amacı',
      body:
          'Bu Gizlilik Politikası, Tasarruf Planım’ı kullanan kişilerin hangi tür kişisel verilerinin hangi amaçlarla işlenebileceğini, bu verilerin korunmasına ilişkin yaklaşımımızı ve kullanıcıların gizlilik haklarını anlaşılır bir dille açıklamak amacıyla hazırlanmıştır.\n\n'
          'Tasarruf Planım’ın temel yaklaşımı; yalnızca hizmetin sunulması, güvenliğinin sağlanması ve geliştirilmesi için gerekli olan verileri işlemek, gereksiz veri toplamamak ve kullanıcıya verileri üzerinde mümkün olduğunca açık kontrol sağlamaktır.\n\n'
          'Bu metin, Tasarruf Planım’ın genel gizlilik yaklaşımını açıklar. Kişisel verilerin elde edilmesi sırasında yerine getirilmesi gereken KVKK aydınlatma yükümlülüğü ve açık rıza gerektiren özel işlemler, gerekli olduğu ölçüde ayrıca ve ilgili işlem bağlamında sunulabilir.',
    ),
    _PrivacySection(
      icon: Icons.layers_outlined,
      title: 'Kapsam',
      body:
          'Bu politika; Tasarruf Planım mobil uygulaması, uygulama içerisindeki kullanıcı hesapları, FP Engine, kayıtlı planlar, danışma sistemi, doğrulanmış uzman sistemi, şirket bilgi ekranları, bildirim merkezi, geri bildirim alanları ve Tasarruf Planım tarafından sunulan diğer dijital özellikler bakımından uygulanır.\n\n'
          'Bir özellik Tasarruf Planım dışındaki üçüncü taraf bir internet sitesine, uygulamaya veya hizmete yönlendiriyorsa, o hizmetin kendi gizlilik politikası ve kullanım koşulları geçerli olabilir.\n\n'
          'Tasarruf Planım’ın gelecekte yeni özellikler sunması halinde, bu politika yeni veri işleme faaliyetlerini yansıtacak şekilde güncellenebilir.',
    ),
    _PrivacySection(
      icon: Icons.verified_user_outlined,
      title: 'Temel Gizlilik İlkelerimiz',
      body:
          'Tasarruf Planım kişisel verilerin işlenmesinde hukuka ve dürüstlük kurallarına uygunluk, doğruluk ve gerektiğinde güncellik, belirli ve meşru amaçlarla işleme, amaçla bağlantılı ve ölçülü olma ve gerekli süre kadar saklama ilkelerini esas almayı hedefler.\n\n'
          'Veri minimizasyonu Tasarruf Planım’ın önemli ürün ilkelerinden biridir. Bir özelliğin çalışması için gerekli olmayan kişisel verilerin talep edilmemesi ve işlenmemesi hedeflenir.\n\n'
          'Kullanıcı verilerinin ticari değer üretmek amacıyla gereksiz şekilde toplanması Tasarruf Planım’ın ürün yaklaşımıyla bağdaşmaz.',
    ),
    _PrivacySection(
      icon: Icons.person_add_alt_1_outlined,
      title: 'Hesap Oluştururken İşlenebilecek Bilgiler',
      body:
          'Kullanıcı Tasarruf Planım’da hesap oluşturduğunda ad, soyad, e-posta adresi, kullanıcı kimliği ve hesap güvenliğiyle ilişkili teknik bilgiler işlenebilir.\n\n'
          'Parola doğrulama işlemleri Tasarruf Planım’ın kullandığı kimlik doğrulama altyapısı üzerinden yürütülebilir. Tasarruf Planım’ın kullanıcı parolasını okunabilir biçimde saklamaması hedeflenir.\n\n'
          'Hesap bilgileri; kullanıcı hesabının oluşturulması, oturum açılması, hesap güvenliğinin sağlanması, profil bilgilerinin görüntülenmesi ve kullanıcıya hesapla bağlantılı özelliklerin sunulması amacıyla kullanılabilir.',
    ),
    _PrivacySection(
      icon: Icons.badge_outlined,
      title: 'Profil Bilgileri',
      body:
          'Kullanıcı profilinde paylaşılan ad, soyad, e-posta ve benzeri bilgiler hesap yönetimi amacıyla işlenebilir.\n\n'
          'Kullanıcı tarafından güncellenebilen profil bilgilerinin mümkün olduğunca güncel tutulması kullanıcının sorumluluğundadır.\n\n'
          'Tasarruf Planım, profil özelliğinin gerektirmediği kişisel bilgileri zorunlu hale getirmemeyi hedefler.',
    ),
    _PrivacySection(
      icon: Icons.memory_outlined,
      title: 'FP Engine Verileri',
      body:
          'FP Engine kullanılırken kullanıcı tarafından girilen finansman tutarı, peşinat, aylık taksit, ödeme modeli, artış oranı, artış periyodu ve benzeri planlama verileri işlenebilir.\n\n'
          'Bu veriler doğrudan kimlik bilgisi olmak zorunda değildir; ancak bir kullanıcı hesabıyla ilişkilendirilerek kaydedildiğinde kullanıcıyla bağlantılı veri haline gelebilir.\n\n'
          'FP Engine verileri hesaplama işlemini gerçekleştirmek, ödeme planı üretmek, tahmini teslim ve vade sonuçlarını göstermek ve kullanıcının talep ettiği özellikleri sunmak amacıyla kullanılır.',
    ),
    _PrivacySection(
      icon: Icons.history_rounded,
      title: 'Son Hesaplanan Plan',
      body:
          'Tasarruf Planım, kullanıcı deneyimini kolaylaştırmak amacıyla cihaz üzerinde veya uygulamanın uygun veri alanlarında en son hesaplanan plana ilişkin sınırlı bilgileri tutabilir.\n\n'
          'Bu kayıt, kullanıcının ana sayfada son çalıştığı plana hızlı şekilde ulaşmasını sağlamak amacıyla kullanılabilir.\n\n'
          'Son hesaplanan plan ile kullanıcı tarafından özellikle kaydedilen plan birbirinden farklı veri kayıtları olabilir.',
    ),
    _PrivacySection(
      icon: Icons.bookmark_outline_rounded,
      title: 'Kayıtlı Planlar',
      body:
          'Kullanıcı bir planı kaydetmeyi seçtiğinde finansman tutarı, peşinat, taksit, vade, tahmini teslim bilgisi, ödeme modeli ve planın çalışması için gerekli diğer hesaplama verileri kullanıcı hesabıyla ilişkilendirilerek saklanabilir.\n\n'
          'Kayıtlı planların amacı, kullanıcının daha önce oluşturduğu planlara tekrar ulaşabilmesini sağlamaktır.\n\n'
          'Kullanıcı ilgili özellik üzerinden kayıtlı planlarını görüntüleyebilir ve silme işlemi sunulduğu ölçüde bu kayıtları kaldırabilir.',
    ),
    _PrivacySection(
      icon: Icons.picture_as_pdf_outlined,
      title: 'Ödeme Planı ve PDF Verileri',
      body:
          'Tasarruf Planım, kullanıcının hesaplama sonucu oluşan ödeme planını ekranda gösterebilir ve kullanıcı talep ederse PDF benzeri bir çıktı oluşturabilir.\n\n'
          'PDF oluşturma işlemi sırasında plan verileri belgenin hazırlanması için geçici olarak işlenebilir. Kullanıcının cihazına kaydettiği veya başka bir uygulamayla paylaştığı dosyaların daha sonraki kullanımı, cihazın ve seçilen üçüncü taraf uygulamanın kendi koşullarına tabi olabilir.\n\n'
          'Tasarruf Planım, kullanıcı tarafından cihaz dışına aktarılan dosyaların sonradan kimlerle paylaşılacağını kontrol edemez.',
    ),
    _PrivacySection(
      icon: Icons.support_agent_outlined,
      title: 'Danışma Talepleri',
      body:
          'Kullanıcı Tasarruf Planım üzerinden danışma talebi gönderdiğinde ad, soyad, iletişim bilgileri, kullanıcı notu, ilgili plan bilgileri ve talebin yönetilmesi için gerekli diğer bilgiler işlenebilir.\n\n'
          'Bu verilerin amacı kullanıcının talebini uygun uzman veya ilgili süreçle eşleştirmek, talep durumunu yönetmek ve kullanıcı ile uzman arasındaki iletişimi kontrollü biçimde kolaylaştırmaktır.\n\n'
          'Danışma talebinde gereksiz veya özel nitelikli kişisel verilerin paylaşılmaması önerilir.',
    ),
    _PrivacySection(
      icon: Icons.contact_phone_outlined,
      title: 'Danışma Talebi İletişim Bilgileri',
      body:
          'Danışma sürecinde kullanıcının telefon numarası veya e-posta adresi gibi iletişim bilgileri, yalnızca ilgili sürecin gerektirdiği aşamada ve yetkilendirilmiş uzmanla paylaşılabilir.\n\n'
          'Tasarruf Planım, danışma talebi oluşturulduğu anda tüm iletişim bilgilerini herkes tarafından görülebilir hale getirmemeyi hedefler.\n\n'
          'İletişim bilgilerinin erişimi, kullanıcı güvenliği ve danışma sürecinin işleyişi dikkate alınarak sınırlandırılabilir.',
    ),
    _PrivacySection(
      icon: Icons.workspace_premium_outlined,
      title: 'Uzman Hesapları',
      body:
          'Uzman hesabı veya uzman başvurusu kapsamında ad, soyad, e-posta, iletişim bilgileri, çalışılan şirket, şehir, doğrulama durumu ve uzmanlık hesabının yönetilmesi için gerekli bilgiler işlenebilir.\n\n'
          'Uzman doğrulamasının amacı kullanıcıların sektörde çalışan kişilerle daha güvenli bir şekilde iletişim kurabilmesini desteklemektir.\n\n'
          'Doğrulama amacı dışında gerekli olmayan belgelerin veya kişisel verilerin saklanmaması hedeflenir.',
    ),
    _PrivacySection(
      icon: Icons.domain_verification_outlined,
      title: 'Uzman Doğrulama Verileri',
      body:
          'Uzman doğrulaması şirket e-posta alan adı, doğrulama kodu, yönetici incelemesi veya Tasarruf Planım tarafından belirlenen başka güvenli yöntemlerle gerçekleştirilebilir.\n\n'
          'Doğrulama sürecinde işlenen veriler yalnızca uzmanın ilgili kurumla bağlantısının veya başvuru bilgilerinin doğrulanması amacıyla kullanılmalıdır.\n\n'
          'Doğrulama işlemi tamamlandıktan sonra doğrulama amacıyla artık gerekli olmayan verilerin saklanma ihtiyacı ayrıca değerlendirilir.',
    ),
    _PrivacySection(
      icon: Icons.star_outline_rounded,
      title: 'Uzman Performans ve Değerlendirme Bilgileri',
      body:
          'Danışma sistemi kapsamında uzmanla ilgili talep durumu, dönüş bilgisi, kullanıcı değerlendirmesi, kalite puanı veya benzeri performans verileri işlenebilir.\n\n'
          'Bu veriler platform kalitesinin korunması, uzman sisteminin güvenli şekilde yönetilmesi ve kullanıcı deneyiminin geliştirilmesi amacıyla kullanılabilir.\n\n'
          'Değerlendirme sisteminin kişileri haksız şekilde itibarsızlaştıracak biçimde kullanılmaması ve gerekli durumlarda yönetici incelemesine tabi tutulabilmesi hedeflenir.',
    ),
    _PrivacySection(
      icon: Icons.chat_bubble_outline_rounded,
      title: 'Şikayet ve Öneri Verileri',
      body:
          'Kullanıcı Şikayet ve Öneri alanı üzerinden geri bildirim gönderdiğinde mesaj içeriği, hesap bilgileri ve bildirimin yönetilmesi için gerekli teknik bilgiler işlenebilir.\n\n'
          'Bu bilgiler kullanıcının geri bildirimini incelemek, gerektiğinde kullanıcıya dönüş yapmak, teknik veya içerik hatalarını düzeltmek ve Tasarruf Planım’ı geliştirmek amacıyla kullanılabilir.\n\n'
          'Kullanıcının geri bildirim alanına gereksiz kişisel veya özel nitelikli veri yazmaması önerilir.',
    ),
    _PrivacySection(
      icon: Icons.notifications_none_rounded,
      title: 'Bildirim Merkezi',
      body:
          'Tasarruf Planım Bildirim Merkezi, kullanıcıya genel içerik güncellemeleri, hesapla ilgili durumlar veya uygulama içindeki önemli gelişmeleri göstermek amacıyla bildirim kayıtları oluşturabilir.\n\n'
          'Bildirim kayıtları; bildirim türü, oluşturulma zamanı, okunma durumu ve ilgili içeriğe yönlendirme bilgisi gibi teknik verileri içerebilir.\n\n'
          'Bildirim sisteminin kullanıcı davranışlarını gereksiz şekilde profillemek amacıyla kullanılmaması hedeflenir.',
    ),
    _PrivacySection(
      icon: Icons.security_outlined,
      title: 'Teknik ve Güvenlik Verileri',
      body:
          'Uygulamanın güvenli ve kararlı şekilde çalışabilmesi amacıyla oturum bilgileri, kullanıcı kimliği, hata kayıtları, uygulama sürümü, cihaz veya bağlantıyla ilişkili sınırlı teknik veriler işlenebilir.\n\n'
          'Bu veriler güvenlik olaylarının tespit edilmesi, yetkisiz erişimin önlenmesi, hata giderme ve uygulama performansının geliştirilmesi amacıyla kullanılabilir.\n\n'
          'Teknik veri toplama, hizmetin gerektirdiği ölçüyle sınırlı tutulmalıdır.',
    ),
    _PrivacySection(
      icon: Icons.phonelink_lock_outlined,
      title: 'Cihaz İzinleri',
      body:
          'Tasarruf Planım’ın bazı özellikleri cihaz üzerinde belirli izinlere ihtiyaç duyabilir. Böyle bir durumda izin talebi özelliğin ihtiyaç duyduğu anda ve mümkün olduğunca açık bir açıklamayla sunulmalıdır.\n\n'
          'Tasarruf Planım, özelliğin çalışması için gerekli olmayan cihaz izinlerini zorunlu tutmamayı hedefler.\n\n'
          'Kullanıcı cihaz ayarları üzerinden verdiği izinleri işletim sisteminin sunduğu imkanlar çerçevesinde yönetebilir.',
    ),
    _PrivacySection(
      icon: Icons.location_off_outlined,
      title: 'Konum Verileri',
      body:
          'Tasarruf Planım’ın mevcut temel hizmetleri için hassas veya sürekli konum takibi yapılması amaçlanmamaktadır.\n\n'
          'Gelecekte şehir bazlı uzman veya şirket filtreleri gibi bir özellik için konum erişimi gerekirse, kullanıcıdan ilgili özellik bağlamında izin istenmesi ve konum verisinin yalnızca gerekli ölçüde kullanılması hedeflenir.\n\n'
          'Açık bir ihtiyaç olmadan hassas konum verisi toplanmaması Tasarruf Planım’ın veri minimizasyonu yaklaşımının bir parçasıdır.',
    ),
    _PrivacySection(
      icon: Icons.health_and_safety_outlined,
      title: 'Özel Nitelikli Kişisel Veriler',
      body:
          'Tasarruf Planım’ın temel hizmetlerinin sunulması için sağlık bilgisi, biyometrik veri, siyasi düşünce, dinî inanç veya benzeri özel nitelikli kişisel verilerin kullanıcıdan talep edilmesi hedeflenmemektedir.\n\n'
          'Kullanıcıların serbest metin alanlarına veya danışma notlarına bu tür bilgileri yazmaması önerilir.\n\n'
          'İleride özel nitelikli veri işlenmesini gerektiren yeni bir özellik geliştirilirse, bu faaliyet ayrı hukuki değerlendirmeye ve gerekli güvenlik önlemlerine tabi tutulmalıdır.',
    ),
    _PrivacySection(
      icon: Icons.child_care_outlined,
      title: 'Çocuklara İlişkin Veriler',
      body:
          'Tasarruf Planım’ın tasarruf finansmanı karar destek hizmetleri esas olarak kendi adına finansal değerlendirme yapabilecek yetişkin kullanıcılar için tasarlanmıştır.\n\n'
          'Çocuklara ait kişisel verilerin bilinçli ve sistematik şekilde toplanması Tasarruf Planım’ın temel hizmetinin amacı değildir.\n\n'
          'Çocuklara ilişkin bir veri işlendiğinin fark edilmesi halinde, ilgili durum yürürlükteki mevzuat ve hizmet gereklilikleri çerçevesinde ayrıca değerlendirilebilir.',
    ),
    _PrivacySection(
      icon: Icons.rule_folder_outlined,
      title: 'Verileri Hangi Amaçlarla Kullanabiliriz?',
      body:
          'Kişisel veriler; kullanıcı hesabını oluşturmak ve yönetmek, kimlik doğrulamak, FP Engine hesaplamalarını gerçekleştirmek, kayıtlı planları saklamak, danışma taleplerini yönetmek, uzman doğrulaması yapmak, bildirimleri göstermek, geri bildirimleri değerlendirmek, güvenliği sağlamak ve hizmet kalitesini geliştirmek gibi amaçlarla işlenebilir.\n\n'
          'Her veri işleme faaliyetinin belirli, açık ve meşru bir amaca dayanması hedeflenir.\n\n'
          'Bir amaç için toplanan verinin, kullanıcı açısından beklenmeyen ve ilgisiz başka amaçlarla kullanılmaması Tasarruf Planım’ın gizlilik yaklaşımının temel parçasıdır.',
    ),
    _PrivacySection(
      icon: Icons.balance_rounded,
      title: 'Hukuki Sebepler',
      body:
          'Kişisel verilerin işlenmesi, ilgili veri işleme faaliyetinin niteliğine göre 6698 sayılı Kişisel Verilerin Korunması Kanunu’nda öngörülen hukuki sebeplerden uygun olanına dayanmalıdır.\n\n'
          'Bir veri işleme faaliyeti açık rıza gerektiriyorsa, açık rızanın aydınlatma metninden ayrı ve özgür iradeyle verilebilmesi gerekir.\n\n'
          'Açık rıza gerektirmeyen bir işleme faaliyetinin sırf kolaylık sağlamak amacıyla zorunlu açık rızaya bağlanmaması Tasarruf Planım’ın uyum yaklaşımının parçasıdır.',
    ),
    _PrivacySection(
      icon: Icons.fact_check_outlined,
      title: 'Aydınlatma ve Açık Rıza Ayrımı',
      body:
          'Aydınlatma yükümlülüğü ile açık rıza aynı işlem değildir.\n\n'
          'Kullanıcıya kişisel verilerinin kim tarafından, hangi amaçla, hangi yöntem ve hukuki sebeple işlendiği, kimlere aktarılabileceği ve haklarının neler olduğu açık biçimde bildirilmelidir.\n\n'
          'Açık rıza gereken faaliyetlerde ise kullanıcıya ayrıca ve özgür iradesiyle seçim yapabileceği bir onay mekanizması sunulmalıdır.\n\n'
          'Tasarruf Planım, aydınlatma metni ile açık rıza metinlerini gerektiğinde ayrı şekilde sunmayı hedefler.',
    ),
    _PrivacySection(
      icon: Icons.swap_horiz_rounded,
      title: 'Verilerin Aktarılması',
      body:
          'Kişisel veriler, hizmetin sunulması için gerekli olduğu ölçüde yetkilendirilmiş hizmet sağlayıcılar, teknik altyapı sağlayıcıları, ilgili uzmanlar veya hukuken yetkili kurumlarla paylaşılabilir.\n\n'
          'Her aktarımın amacı, kapsamı ve hukuki dayanağı ayrı değerlendirilmelidir.\n\n'
          'Tasarruf Planım kullanıcı verilerini ilgisiz üçüncü kişilere keyfî biçimde aktarmamayı ve veri paylaşımını hizmetin gerektirdiği ölçüyle sınırlandırmayı hedefler.',
    ),
    _PrivacySection(
      icon: Icons.person_pin_circle_outlined,
      title: 'Uzmanlarla Veri Paylaşımı',
      body:
          'Danışma sistemi kapsamında kullanıcı verilerinin yalnızca ilgili talebin yürütülmesi için gerekli olan kısmı yetkilendirilmiş uzmanla paylaşılabilir.\n\n'
          'Uzmanın erişebildiği veriler, danışma sürecinin durumuna göre sınırlandırılabilir.\n\n'
          'Uzmanların Tasarruf Planım üzerinden elde ettiği kullanıcı verilerini danışma amacı dışında kullanmaması, izinsiz olarak üçüncü kişilerle paylaşmaması ve güvenliğini koruması beklenir.',
    ),
    _PrivacySection(
      icon: Icons.business_outlined,
      title: 'Şirketlerle Veri Paylaşımı',
      body:
          'Tasarruf Planım’ın kullanıcı adına otomatik olarak tasarruf finansman şirketine başvuru yapması temel hizmetin parçası değildir.\n\n'
          'Kullanıcının açık şekilde başvuru veya iletişim talebinde bulunacağı gelecekteki özelliklerde, hangi verinin hangi şirkete hangi amaçla aktarılacağı kullanıcıya ayrıca açıklanmalıdır.\n\n'
          'Kullanıcının bilgisi dışında şirketlere pazarlama amacıyla kişisel veri aktarılması Tasarruf Planım’ın gizlilik yaklaşımıyla bağdaşmaz.',
    ),
    _PrivacySection(
      icon: Icons.account_balance_rounded,
      title: 'Kamu Kurumları ve Yasal Talepler',
      body:
          'Tasarruf Planım, yürürlükteki mevzuatın gerektirdiği veya yetkili kamu kurumlarının hukuka uygun talebi bulunduğu durumlarda belirli kişisel verileri paylaşmak zorunda kalabilir.\n\n'
          'Bu tür paylaşımların talebin kapsamıyla sınırlı olması ve yalnızca hukuken gerekli verilerin aktarılması hedeflenir.\n\n'
          'Mevzuatın izin verdiği ölçüde kullanıcı gizliliğinin korunması esastır.',
    ),
    _PrivacySection(
      icon: Icons.cloud_outlined,
      title: 'Bulut ve Teknik Hizmet Sağlayıcıları',
      body:
          'Tasarruf Planım; kimlik doğrulama, veri saklama, uygulama altyapısı, hata izleme veya benzeri teknik hizmetlerde üçüncü taraf teknoloji sağlayıcılarından yararlanabilir.\n\n'
          'Bu sağlayıcılar, sundukları hizmetin niteliğine göre kullanıcı verilerini Tasarruf Planım adına işleyebilir.\n\n'
          'Teknik sağlayıcı seçiminde güvenlik, veri koruma yükümlülükleri ve hizmetin gerektirdiği veri kapsamı dikkate alınmalıdır.',
    ),
    _PrivacySection(
      icon: Icons.public_outlined,
      title: 'Yurt Dışına Veri Aktarımı',
      body:
          'Tasarruf Planım’ın kullandığı bazı teknik altyapı veya bulut hizmetlerinin sunucuları Türkiye dışında bulunabilir ya da hizmet kapsamında yurt dışına veri aktarımı gündeme gelebilir.\n\n'
          'Yurt dışına kişisel veri aktarımı söz konusu olduğunda yürürlükteki KVKK düzenlemeleri ve uygun aktarım mekanizmaları dikkate alınmalıdır.\n\n'
          'Tasarruf Planım, yurt dışına aktarım faaliyetlerini gerekli hukuki ve teknik değerlendirmeler yapılmadan gerçekleştirmemeyi hedefler.',
    ),
    _PrivacySection(
      icon: Icons.schedule_outlined,
      title: 'Veri Saklama Süreleri',
      body:
          'Kişisel veriler, işlendikleri amaç için gerekli olan süre boyunca veya ilgili mevzuatta öngörülen saklama süresi kadar muhafaza edilmelidir.\n\n'
          'Her veri kategorisi için aynı saklama süresi uygulanmak zorunda değildir. Hesap bilgileri, danışma kayıtları, güvenlik kayıtları ve destek talepleri farklı ihtiyaçlara sahip olabilir.\n\n'
          'Saklama ihtiyacı sona erdiğinde verilerin silinmesi, yok edilmesi veya anonim hale getirilmesi ilgili teknik ve hukuki koşullar çerçevesinde değerlendirilir.',
    ),
    _PrivacySection(
      icon: Icons.delete_outline_rounded,
      title: 'Hesap Silme',
      body:
          'Tasarruf Planım kullanıcıya hesabını silme imkanı sunmayı hedefler.\n\n'
          'Hesap silme talebi sonrasında, hesabın aktif kullanım için gerekli verileri silinebilir veya erişilemez hale getirilebilir. Ancak yasal saklama zorunluluğu bulunan, güvenlik veya uyuşmazlık çözümü için belirli süre tutulması gereken kayıtlar ilgili süre boyunca saklanabilir.\n\n'
          'Hesabın silinmesi, kullanıcının cihazına daha önce indirdiği PDF gibi dosyaları otomatik olarak silmez.',
    ),
    _PrivacySection(
      icon: Icons.delete_sweep_outlined,
      title: 'Planların Silinmesi',
      body:
          'Kullanıcı tarafından kaydedilmiş planlar, uygulamanın sunduğu silme özelliği üzerinden kaldırılabilir.\n\n'
          'Plan silme işlemi kullanıcı arayüzünden tamamlandığında, ilgili verinin aktif kullanıcı deneyiminden kaldırılması hedeflenir.\n\n'
          'Teknik yedekler veya güvenlik kopyalarında bulunan verilerin tamamen ortadan kalkması, kullanılan altyapının yedekleme ve imha döngülerine bağlı olarak belirli bir süre alabilir.',
    ),
    _PrivacySection(
      icon: Icons.lock_rounded,
      title: 'Veri Güvenliği',
      body:
          'Tasarruf Planım kişisel verilerin hukuka aykırı işlenmesini veya erişilmesini önlemek ve verilerin güvenli şekilde muhafazasını sağlamak amacıyla uygun teknik ve idari önlemler uygulamayı hedefler.\n\n'
          'Yetkilendirme kuralları, kullanıcı kimlik doğrulaması, rol bazlı erişim, veri erişim kontrolleri ve güvenli yazılım geliştirme uygulamaları bu yaklaşımın parçaları olabilir.\n\n'
          'Hiçbir dijital sistem mutlak güvenlik garantisi sunamaz. Bu nedenle güvenlik önlemlerinin düzenli olarak gözden geçirilmesi ve geliştirilmesi gerekir.',
    ),
    _PrivacySection(
      icon: Icons.password_outlined,
      title: 'Hesap Güvenliği',
      body:
          'Kullanıcı kendi hesabının güvenliğini korumak için güçlü ve benzersiz bir parola kullanmalı, doğrulama kodlarını üçüncü kişilerle paylaşmamalı ve hesabına izinsiz erişim şüphesi olduğunda gerekli güvenlik adımlarını uygulamalıdır.\n\n'
          'Tasarruf Planım hiçbir uzmanın veya çalışan olduğunu iddia eden kişinin kullanıcıdan banka şifresi, kart şifresi veya tek kullanımlık güvenlik kodu istemesini normal bir uygulama olarak kabul etmez.\n\n'
          'Şüpheli durumların Tasarruf Planım’a bildirilmesi güvenliğin geliştirilmesine yardımcı olabilir.',
    ),
    _PrivacySection(
      icon: Icons.warning_amber_rounded,
      title: 'Veri İhlali Durumları',
      body:
          'Kişisel verilerin güvenliğini etkileyen bir olay meydana gelmesi halinde olayın kapsamının belirlenmesi, gerekli teknik tedbirlerin alınması ve yürürlükteki mevzuatın gerektirdiği bildirim süreçlerinin değerlendirilmesi gerekir.\n\n'
          'Tasarruf Planım, olası güvenlik ihlallerini ciddiyetle ele almayı ve gerekli düzeltici önlemleri mümkün olan en kısa sürede uygulamayı hedefler.\n\n'
          'Kullanıcının hesabıyla ilgili şüpheli bir işlem fark etmesi halinde Tasarruf Planım’a bildirimde bulunması önerilir.',
    ),
    _PrivacySection(
      icon: Icons.analytics_outlined,
      title: 'Analitik ve Ürün Geliştirme',
      body:
          'Tasarruf Planım’ın hangi özelliklerinin kullanıldığı, hangi ekranlarda hata oluştuğu veya uygulamanın teknik performansı gibi veriler ürün geliştirme amacıyla analiz edilebilir.\n\n'
          'Analitik faaliyetlerin mümkün olduğunca kullanıcı mahremiyetine saygılı, amaçla sınırlı ve ölçülü biçimde yürütülmesi hedeflenir.\n\n'
          'Kişisel kullanıcı profili oluşturmak veya kullanıcının finansal durumunu gereksiz şekilde sınıflandırmak Tasarruf Planım’ın temel analitik amacı değildir.',
    ),
    _PrivacySection(
      icon: Icons.campaign_outlined,
      title: 'Reklam ve Pazarlama',
      body:
          'Tasarruf Planım gelecekte reklam veya ticari iletişim özellikleri sunarsa, kişisel verilerin pazarlama amacıyla kullanılması ayrı bir değerlendirmeye tabi tutulmalıdır.\n\n'
          'Elektronik ticari ileti, hedefli pazarlama veya benzeri faaliyetlerin ilgili mevzuatın gerektirdiği izin ve bilgilendirme süreçleri olmadan yürütülmemesi hedeflenir.\n\n'
          'FP Engine hesaplama verilerinin kullanıcıyı haberi olmadan belirli bir şirkete pazarlamak amacıyla kullanılmaması Tasarruf Planım’ın bağımsızlık ve gizlilik ilkelerinin bir parçasıdır.',
    ),
    _PrivacySection(
      icon: Icons.cookie_outlined,
      title: 'Çerezler ve Benzeri Teknolojiler',
      body:
          'Tasarruf Planım’ın web tabanlı veya gelecekte sunulabilecek internet hizmetlerinde çerezler, yerel depolama veya benzeri teknolojiler kullanılabilir.\n\n'
          'Bu teknolojilerin zorunlu, analitik veya pazarlama amaçları birbirinden farklı olabilir.\n\n'
          'Zorunlu olmayan çerez veya benzeri teknolojilerin kullanılması halinde, ilgili hizmetin niteliğine göre kullanıcıya ayrıca bilgi verilmesi ve gerekli tercih mekanizmalarının sunulması değerlendirilecektir.',
    ),
    _PrivacySection(
      icon: Icons.fact_check_outlined,
      title: 'Kullanıcının KVKK Kapsamındaki Hakları',
      body:
          'İlgili kişiler, 6698 sayılı Kanunun 11. maddesi kapsamındaki şartlar doğrultusunda kişisel verilerinin işlenip işlenmediğini öğrenme, işlenmişse buna ilişkin bilgi talep etme, işleme amacını ve amaca uygun kullanılıp kullanılmadığını öğrenme, verilerin aktarıldığı kişileri bilme ve Kanunda düzenlenen diğer haklarını kullanabilir.\n\n'
          'Kanuni şartların oluşması halinde kullanıcı, kişisel verilerin düzeltilmesini, silinmesini veya yok edilmesini talep edebilir ve gerçekleştirilen işlemlerin ilgili üçüncü kişilere bildirilmesini isteyebilir.\n\n'
          'Başvuruların kimlik doğrulamasını sağlayacak ve kullanıcı güvenliğini koruyacak uygun yöntemlerle alınması hedeflenir.',
    ),
    _PrivacySection(
      icon: Icons.contact_support_outlined,
      title: 'Başvuru ve İletişim',
      body:
          'Kullanıcılar gizlilik, kişisel veri veya hesap verileriyle ilgili talep ve sorularını info@tasarrufplanim.com adresi üzerinden iletebilir.\n\n'
          'Uygulamanın kullanımı, hesap işlemleri veya teknik destek konularında destek@tasarrufplanim.com adresi kullanılabilir.\n\n'
          'KVKK kapsamındaki resmî başvurular için veri sorumlusunun kimliği, başvuru yöntemi ve gerekli diğer resmî bilgiler, nihai hukuki yapı doğrultusunda ayrıca açık ve güncel şekilde yayımlanacaktır.',
    ),
    _PrivacySection(
      icon: Icons.update_outlined,
      title: 'Gizlilik Politikasındaki Değişiklikler',
      body:
          'Tasarruf Planım’ın hizmet kapsamı, teknik altyapısı veya yasal yükümlülükleri değiştikçe bu Gizlilik Politikası güncellenebilir.\n\n'
          'Önemli değişikliklerde kullanıcıların güncel politika hakkında bilgilendirilmesini sağlayacak uygulama içi yöntemler kullanılabilir.\n\n'
          'Güncel politika uygulama içerisinden erişilebilir şekilde tutulmalıdır.',
    ),
    _PrivacySection(
      icon: Icons.balance_outlined,
      title: 'Gizlilik ve Bağımsızlık İlişkisi',
      body:
          'Tasarruf Planım’ın bağımsızlık ilkesi yalnızca şirket sıralaması veya hesaplama sonuçlarıyla sınırlı değildir.\n\n'
          'Kullanıcı verilerinin belirli şirketlerin satış hedefleri için gizli şekilde kullanılması veya kullanıcıların finansal senaryolarının habersiz biçimde pazarlama profiline dönüştürülmesi Tasarruf Planım’ın bağımsızlık yaklaşımıyla bağdaşmaz.\n\n'
          'Kullanıcının Tasarruf Planım’a duyduğu güvenin korunması, ürünün uzun vadeli değerinin temel unsurlarından biridir.',
    ),
    _PrivacySection(
      icon: Icons.info_outline_rounded,
      title: 'Son Bilgilendirme',
      body:
          'Tasarruf Planım’ın gizlilik yaklaşımının temelinde mümkün olduğunca az veri toplamak, toplanan veriyi açık amaçlarla kullanmak, kullanıcı güvenliğini korumak ve veriler üzerinde kullanıcıya şeffaflık sağlamak vardır.\n\n'
          'Bu politika Tasarruf Planım’ın genel gizlilik çerçevesini açıklar. Belirli veri işleme faaliyetleri için ayrıca KVKK Aydınlatma Metni, açık rıza metni, kullanıcı sözleşmesi veya uzman sözleşmesi sunulabilir.\n\n'
          'Kullanıcı gizliliği Tasarruf Planım açısından yalnızca yasal bir yükümlülük değil, ürün güveninin temel bir parçasıdır.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _navy,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Gizlilik Politikası',
          style: TextStyle(
            color: _navy,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.35,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
          children: [
            const _PrivacyHeroCard(),
            const SizedBox(height: 16),
            const _PrivacyIntroCard(),
            const SizedBox(height: 16),
            const _SectionLabel(),
            const SizedBox(height: 10),
            ...List.generate(_sections.length, (index) {
              final section = _sections[index];
              final isOpen = _openIndex == index;
              return _PrivacyAccordionCard(
                number: index + 1,
                section: section,
                isOpen: isOpen,
                onTap: () {
                  setState(() {
                    _openIndex = isOpen ? null : index;
                  });
                },
              );
            }),
            const SizedBox(height: 8),
            const _PrivacyFooterCard(),
            const SizedBox(height: 12),
            const _PolicyNote(),
          ],
        ),
      ),
    );
  }
}

class _PrivacyHeroCard extends StatelessWidget {
  const _PrivacyHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _PrivacyPolicyScreenState._navy,
            _PrivacyPolicyScreenState._petrol,
            Color(0xFF0C6268),
            _PrivacyPolicyScreenState._teal,
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x260B2239),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: _PrivacyPolicyScreenState._turquoise.withOpacity(.16),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: const Color(0xFF55E2D0).withOpacity(.28),
              ),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Color(0xFF55E2D0),
              size: 29,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gizlilik Politikası',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Kişisel verilerin hangi amaçlarla işlenebileceğini, '
                  'nasıl korunduğunu ve kullanıcıların gizlilik haklarını '
                  'açık ve anlaşılır şekilde açıklıyoruz.',
                  style: TextStyle(
                    color: Color(0xFFD9E7E9),
                    fontSize: 12.4,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
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

class _PrivacyIntroCard extends StatelessWidget {
  const _PrivacyIntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7F5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD5ECE8)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            color: _PrivacyPolicyScreenState._teal,
            size: 21,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tasarruf Planım’ın yaklaşımı; hizmet için gerekli olan veriyi işlemek, '
              'gereksiz veri toplamamak, veriyi amacı dışında kullanmamak ve '
              'kullanıcı güvenliğini ürünün temel parçası olarak ele almaktır.',
              style: TextStyle(
                color: Color(0xFF48636B),
                fontSize: 12,
                height: 1.52,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(
          Icons.privacy_tip_outlined,
          color: _PrivacyPolicyScreenState._teal,
          size: 18,
        ),
        SizedBox(width: 7),
        Text(
          'Gizlilik ve Veri Koruma',
          style: TextStyle(
            color: _PrivacyPolicyScreenState._navy,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

class _PrivacyAccordionCard extends StatelessWidget {
  const _PrivacyAccordionCard({
    required this.number,
    required this.section,
    required this.isOpen,
    required this.onTap,
  });

  final int number;
  final _PrivacySection section;
  final bool isOpen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOpen
              ? _PrivacyPolicyScreenState._teal.withOpacity(.30)
              : _PrivacyPolicyScreenState._border,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B2239).withOpacity(isOpen ? .055 : .028),
            blurRadius: isOpen ? 16 : 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _PrivacyPolicyScreenState._teal.withOpacity(.14),
                            _PrivacyPolicyScreenState._turquoise.withOpacity(.10),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        section.icon,
                        color: _PrivacyPolicyScreenState._teal,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '$number. ${section.title}',
                        style: const TextStyle(
                          color: _PrivacyPolicyScreenState._navy,
                          fontSize: 13.8,
                          height: 1.28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: isOpen ? .5 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF8D9AA5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeInOutCubic,
            alignment: Alignment.topCenter,
            child: isOpen
                ? Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(13, 0, 13, 13),
                    padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7FBFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE6EEF1)),
                    ),
                    child: Text(
                      section.body,
                      style: const TextStyle(
                        color: _PrivacyPolicyScreenState._muted,
                        fontSize: 12.8,
                        height: 1.63,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _PrivacyFooterCard extends StatelessWidget {
  const _PrivacyFooterCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
      decoration: BoxDecoration(
        color: _PrivacyPolicyScreenState._navy,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.privacy_tip_outlined,
            color: Color(0xFF55E2D0),
            size: 21,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Kullanıcı gizliliği Tasarruf Planım açısından yalnızca yasal bir '
              'yükümlülük değil; bağımsızlık, güven ve ürün kalitesinin '
              'temel parçalarından biridir.',
              style: TextStyle(
                color: Color(0xFFD9E7E9),
                fontSize: 11.5,
                height: 1.52,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicyNote extends StatelessWidget {
  const _PolicyNote();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Text(
        'Not: Veri sorumlusunun kesin unvanı ve KVKK kapsamında gerekli resmî başvuru bilgileri, '
        'yayından önce nihai hukuki yapı doğrultusunda bu politika ve Aydınlatma Metni '
        'içerisinde tamamlanmalıdır.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF8A96A3),
          fontSize: 10.5,
          height: 1.45,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _PrivacySection {
  const _PrivacySection({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}
