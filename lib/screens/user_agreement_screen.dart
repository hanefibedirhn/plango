import 'package:flutter/material.dart';

class UserAgreementScreen extends StatefulWidget {
  const UserAgreementScreen({super.key});

  @override
  State<UserAgreementScreen> createState() => _UserAgreementScreenState();
}

class _UserAgreementScreenState extends State<UserAgreementScreen> {
  static const Color _navy = Color(0xFF0B2239);
  static const Color _petrol = Color(0xFF052F3D);
  static const Color _teal = Color(0xFF087C72);
  static const Color _turquoise = Color(0xFF16C7B0);
  static const Color _background = Color(0xFFF7F9FB);
  static const Color _muted = Color(0xFF748193);
  static const Color _border = Color(0xFFE4EBEE);

  int? _openIndex;

  final List<_AgreementSection> _sections = const [
    _AgreementSection(
      icon: Icons.handshake_outlined,
      title: 'Taraflar',
      body:
          'İşbu Kullanıcı Sözleşmesi, Plango dijital platformunu kullanan gerçek kişi kullanıcı ile Plango hizmetinin veri sorumlusu ve/veya hizmet sağlayıcısı sıfatıyla faaliyet gösterecek gerçek veya tüzel kişi arasında, kullanıcının üyelik işlemini tamamlaması ve sözleşmeyi elektronik ortamda kabul etmesiyle kurulur.\n\n'
          'Plango’nun nihai ticari unvanı, merkez adresi, iletişim kanalları ve varsa MERSİS/vergi bilgileri yayına çıkmadan önce sözleşmenin bu bölümüne açık biçimde eklenmelidir.\n\n'
          'Bu sözleşmede “Kullanıcı”, Plango’da hesap oluşturan veya üyelik kapsamında sunulan hizmetlerden yararlanan kişiyi; “Plango” ise uygulama, hesaplama altyapısı ve ilgili dijital hizmetlerin bütününü ifade eder.',
    ),
    _AgreementSection(
      icon: Icons.description_outlined,
      title: 'Sözleşmenin Konusu',
      body:
          'Bu sözleşmenin konusu, kullanıcının Plango’ya üye olması ve Plango tarafından sunulan dijital özelliklerden yararlanmasına ilişkin temel kullanım şartlarının, tarafların hak ve yükümlülüklerinin ve üyelik ilişkisinin çerçevesinin belirlenmesidir.\n\n'
          'Sözleşme; Plango hesabının kullanımı, FP Engine, kayıtlı planlar, ödeme planı çıktıları, danışma sistemi, doğrulanmış uzmanlarla iletişim, bildirimler ve üyelik kapsamında sunulan diğer işlevler bakımından uygulanır.\n\n'
          'Plango’nun herhangi bir tasarruf finansman şirketiyle kullanıcı arasında imzalanan sözleşmenin tarafı olmadığı ve bu sözleşmenin bir tasarruf finansmanı sözleşmesi niteliği taşımadığı taraflarca kabul edilir.',
    ),
    _AgreementSection(
      icon: Icons.menu_book_outlined,
      title: 'Tanımlar',
      body:
          'FP Engine: Kullanıcının girdiği finansman ve ödeme parametrelerini kullanarak tahmini planlama sonuçları oluşturan Plango hesaplama motorudur.\n\n'
          'Kayıtlı Plan: Kullanıcının daha sonra görüntülemek amacıyla hesabına kaydettiği tahmini hesaplama kaydıdır.\n\n'
          'Danışma Talebi: Kullanıcının tasarruf finansmanı hakkında bilgi almak amacıyla Plango üzerinden uygun bir doğrulanmış uzmanla iletişim kurulmasını talep ettiği uygulama içi süreçtir.\n\n'
          'Doğrulanmış Uzman: Plango tarafından belirlenen doğrulama kriterlerinden geçen sektör profesyonelidir.\n\n'
          'İçerik: Plango içerisinde yayımlanan metin, haber, bilgi, şirket profili, açıklama, grafik, hesaplama sonucu ve benzeri dijital unsurlardır.',
    ),
    _AgreementSection(
      icon: Icons.person_add_alt_1_outlined,
      title: 'Üyeliğin Başlatılması',
      body:
          'Kullanıcı, üyelik formunda talep edilen zorunlu bilgileri doğru ve güncel biçimde girerek ve işbu Kullanıcı Sözleşmesini kabul ederek üyelik başvurusunu tamamlar.\n\n'
          'Plango, teknik güvenlik, kötüye kullanımın önlenmesi veya hesap doğrulaması amacıyla e-posta doğrulaması ve benzeri güvenlik adımları uygulayabilir.\n\n'
          'Üyelik, kullanıcının Plango üzerindeki her özelliği sınırsız veya süresiz kullanma hakkı kazandığı anlamına gelmez. Özelliklerin kapsamı uygulamanın güncel sürümüne göre değişebilir.',
    ),
    _AgreementSection(
      icon: Icons.how_to_reg_outlined,
      title: 'Üyelik İçin Temel Şartlar',
      body:
          'Kullanıcı, üyelik oluştururken kendi adına işlem yaptığını, verdiği bilgilerin doğru olduğunu ve hesabı hukuka uygun amaçlarla kullanacağını beyan eder.\n\n'
          'Başka kişilerin kimlik veya iletişim bilgileriyle izinsiz hesap oluşturulamaz.\n\n'
          'Plango’nun hizmetleri, niteliği gereği kendi adına finansal değerlendirme ve sözleşme işlemleri yapabilecek kullanıcılar için tasarlanmıştır. Kullanıcının hukuki işlem ehliyetine ilişkin zorunlu hükümler saklıdır.',
    ),
    _AgreementSection(
      icon: Icons.fact_check_outlined,
      title: 'Hesap Bilgilerinin Doğruluğu',
      body:
          'Kullanıcı, üyelik ve profil alanlarında sağladığı bilgilerin doğru, güncel ve kendisine ait olmasından sorumludur.\n\n'
          'Yanlış veya başkasına ait bilgilerle oluşturulan hesaplar; güvenlik, hukuki yükümlülük veya diğer kullanıcıların korunması amacıyla incelenebilir, sınırlandırılabilir ya da gerekli şartlarda kapatılabilir.\n\n'
          'Kullanıcı, değişen profil bilgilerini uygulamanın sunduğu imkanlar ölçüsünde güncellemelidir.',
    ),
    _AgreementSection(
      icon: Icons.lock_outline_rounded,
      title: 'Hesap Güvenliği',
      body:
          'Kullanıcı kendi hesabının, parolasının ve doğrulama araçlarının güvenliğini korumakla yükümlüdür.\n\n'
          'Parola, tek kullanımlık doğrulama kodu, e-posta erişimi ve benzeri güvenlik bilgileri üçüncü kişilerle paylaşılmamalıdır.\n\n'
          'Hesabın izinsiz kullanıldığından şüphe edilmesi halinde kullanıcı, mümkün olan en kısa sürede parolasını değiştirmeli ve Plango’nun ilan ettiği destek kanalı üzerinden bildirimde bulunmalıdır.',
    ),
    _AgreementSection(
      icon: Icons.person_outline_rounded,
      title: 'Hesabın Kişisel Kullanımı',
      body:
          'Kullanıcı hesabı kişiseldir. Hesabın başka kişilere kiralanması, devredilmesi, satılması veya sistematik olarak ortak kullanılması yasaktır.\n\n'
          'Kullanıcı, kendi hesabı üzerinden gerçekleştirilen işlemlerin kendi kontrolünde olmasını sağlamakla yükümlüdür.\n\n'
          'Yetkisiz hesap paylaşımının güvenlik riski doğurduğu durumlarda Plango gerekli teknik tedbirleri uygulayabilir.',
    ),
    _AgreementSection(
      icon: Icons.explore_outlined,
      title: 'Plango Hizmetinin Niteliği',
      body:
          'Plango, tasarruf finansmanı alanında bilgilendirme, hesaplama ve karar destek amacıyla sunulan bağımsız bir dijital platformdur.\n\n'
          'Plango finansman sağlamaz, tasarruf finansmanı sözleşmesi düzenlemez, kullanıcı adına finansman başvurusu yapmaz ve tasarruf finansman şirketi adına bağlayıcı teklif oluşturmaz.\n\n'
          'Plango’nun sunduğu dijital araçlar, kullanıcının kendi değerlendirmesini yapmasına yardımcı olmak amacıyla kullanılır.',
    ),
    _AgreementSection(
      icon: Icons.memory_outlined,
      title: 'FP Engine Kullanımı',
      body:
          'Kullanıcı, FP Engine’e girdiği finansman tutarı, peşinat, aylık ödeme, ödeme modeli ve diğer parametrelerin doğruluğundan sorumludur.\n\n'
          'FP Engine, kullanıcı girdilerine ve Plango tarafından tanımlanan hesaplama kurallarına göre tahmini sonuçlar oluşturur.\n\n'
          'Kullanıcı, FP Engine’i kişisel planlama ve bilgilendirme amacıyla kullanabilir. Hesaplama sonuçlarının üçüncü kişilere resmî teklif veya şirket taahhüdü gibi sunulması yasaktır.',
    ),
    _AgreementSection(
      icon: Icons.calculate_outlined,
      title: 'FP Engine Sonuçlarının Sözleşmesel Niteliği',
      body:
          'FP Engine tarafından oluşturulan sonuçlar; tasarruf finansman şirketleri adına verilmiş resmî teklif, finansman onayı, ödeme taahhüdü veya kesin teslim tarihi değildir.\n\n'
          'Kullanıcı, resmî bir tasarruf finansmanı işlemi gerçekleştirmeden önce ilgili şirketten güncel ve bağlayıcı bilgi almakla sorumludur.\n\n'
          'Bu hüküm, kullanıcının yürürlükteki mevzuattan doğan vazgeçilmez haklarını ortadan kaldırmaz.',
    ),
    _AgreementSection(
      icon: Icons.event_available_outlined,
      title: 'Tahmini Teslim ve Vade Bilgileri',
      body:
          'Plango’da gösterilen tahmini teslim süresi, tahmini teslim tarihi ve toplam vade sonuçları kullanıcı girdilerine dayalı karar destek verileridir.\n\n'
          'Gerçek teslim ve ödeme koşulları ilgili tasarruf finansman şirketinin sözleşmesi, güncel uygulamaları ve yürürlükteki düzenlemeler kapsamında belirlenir.\n\n'
          'Kullanıcı, tahmini sonuçları kesin şirket taahhüdü olarak yorumlamamalıdır.',
    ),
    _AgreementSection(
      icon: Icons.bookmark_outline_rounded,
      title: 'Kayıtlı Planlar',
      body:
          'Kullanıcı, Plango’nun sunduğu özellik kapsamında oluşturduğu tahmini planları hesabına kaydedebilir.\n\n'
          'Kayıtlı plan, kullanıcının kendi hesaplama geçmişinin bir parçasıdır ve ilgili planın herhangi bir şirket tarafından kabul edildiği anlamına gelmez.\n\n'
          'Kullanıcı, uygulamanın sunduğu imkanlar dahilinde kayıtlı planlarını görüntüleyebilir ve silebilir.',
    ),
    _AgreementSection(
      icon: Icons.history_rounded,
      title: 'Son Hesaplanan Plan',
      body:
          'Plango, kullanıcı deneyimini kolaylaştırmak amacıyla son hesaplanan plana ilişkin bilgileri geçici veya kalıcı olmayan bir kullanıcı deneyimi kaydı olarak gösterebilir.\n\n'
          'Son hesaplanan plan, kullanıcının özellikle “Planı Kaydet” işlemiyle oluşturduğu kayıtlı plandan farklı olabilir.\n\n'
          'Bu alanın amacı kullanıcının son çalıştığı senaryoya hızlı biçimde dönebilmesini sağlamaktır.',
    ),
    _AgreementSection(
      icon: Icons.table_chart_outlined,
      title: 'Ödeme Planı Görünümü',
      body:
          'Ödeme planı ekranı, FP Engine sonucunu daha anlaşılır biçimde göstermek amacıyla oluşturulan yardımcı bir görünümdür.\n\n'
          'Taksit tarihleri, toplam birikim, tahmini teslim ayı ve benzeri alanlar hesaplama mantığına dayalıdır.\n\n'
          'Bu ekran ilgili şirketin resmî muhasebe kaydı veya sözleşme eki değildir.',
    ),
    _AgreementSection(
      icon: Icons.picture_as_pdf_outlined,
      title: 'PDF ve Dışa Aktarılan Belgeler',
      body:
          'Kullanıcı, Plango tarafından sunulması halinde planını PDF veya benzeri belge formatında dışa aktarabilir.\n\n'
          'Bu belgeler Plango hesaplamasının kullanıcı tarafından saklanabilen bir çıktısıdır; resmî tasarruf finansmanı teklifi veya sözleşme değildir.\n\n'
          'Kullanıcı, dışa aktardığı belgelerin kendi cihazında saklanmasından ve üçüncü kişilerle paylaşılması halinde bu paylaşımın sonuçlarından sorumludur.',
    ),
    _AgreementSection(
      icon: Icons.support_agent_outlined,
      title: 'Danışma Sisteminin Amacı',
      body:
          'Danışma sistemi, kullanıcının tasarruf finansmanı hakkında bilgi almak amacıyla doğrulanmış sektör uzmanlarıyla iletişim kurmasını kolaylaştırır.\n\n'
          'Danışma talebi oluşturulması, bir tasarruf finansman şirketine resmî başvuru yapılması veya sözleşme kurulması anlamına gelmez.\n\n'
          'Plango, kullanıcı ile uzman arasındaki iletişimi kolaylaştıran platform rolündedir.',
    ),
    _AgreementSection(
      icon: Icons.contact_support_outlined,
      title: 'Danışma Talebi Oluşturma',
      body:
          'Kullanıcı danışma talebi oluştururken yalnızca talebin değerlendirilmesi için gerekli ve doğru bilgileri vermelidir.\n\n'
          'Kullanıcı notlarında ilgisiz kişisel veriler, üçüncü kişilere ait bilgiler veya hukuka aykırı içerikler paylaşılmamalıdır.\n\n'
          'Danışma talebi, sistemin güncel atama veya uzman eşleştirme mantığına göre uygun uzmana yönlendirilebilir.',
    ),
    _AgreementSection(
      icon: Icons.record_voice_over_outlined,
      title: 'Uzmanlarla İletişim',
      body:
          'Kullanıcı, uzmanla iletişiminde saygılı, hukuka uygun ve dürüst davranmalıdır.\n\n'
          'Uzmanın Plango’da doğrulanmış olması, ilgili uzmanın her beyanının Plango tarafından garanti edildiği anlamına gelmez.\n\n'
          'Kullanıcı, mali yükümlülük veya sözleşme sonucu doğurabilecek önemli bilgileri ilgili şirketin resmî belgelerinden ayrıca doğrulamalıdır.',
    ),
    _AgreementSection(
      icon: Icons.workspace_premium_outlined,
      title: 'Uzmanların Bağımsız Mesleki Beyanları',
      body:
          'Uzmanların kullanıcıyla paylaştığı yorumlar, açıklamalar ve değerlendirmeler ilgili uzmanın kendi mesleki sorumluluğu kapsamında olabilir.\n\n'
          'Plango, uzmanların her iletişimini önceden inceleyen veya onaylayan bir taraf değildir.\n\n'
          'Plango’nun uzman sistemi; kullanıcıların doğrulanmış sektör profesyonellerine ulaşmasını kolaylaştırmak amacıyla sunulur.',
    ),
    _AgreementSection(
      icon: Icons.apartment_outlined,
      title: 'Şirket Bilgileri',
      body:
          'Plango’da tasarruf finansman şirketlerine ilişkin bilgilendirici profiller ve kamuya açık bilgiler sunulabilir.\n\n'
          'Kullanıcı, şirket bilgilerini genel araştırma amacıyla kullanabilir; ancak güncel ücret, kampanya, teslim koşulu veya sözleşme hükümleri için ilgili şirketin resmî kaynaklarını kontrol etmelidir.\n\n'
          'Plango üzerinde bir şirketin bulunması, o şirketin tavsiye edildiği veya diğer şirketlerden üstün olduğu anlamına gelmez.',
    ),
    _AgreementSection(
      icon: Icons.notifications_none_rounded,
      title: 'Bildirim Merkezi',
      body:
          'Plango, üyelik kapsamında uygulama içi bildirimler gösterebilir.\n\n'
          'Bildirimler genel içerik güncellemeleri, kullanıcı hesabı veya uygulamanın işleyişiyle ilgili uygun bilgilendirmeleri içerebilir.\n\n'
          'Ticari elektronik ileti niteliği taşıyan mesajlar bakımından yürürlükteki zorunlu mevzuat hükümleri ayrıca uygulanır.',
    ),
    _AgreementSection(
      icon: Icons.chat_bubble_outline_rounded,
      title: 'Şikayet ve Öneri Sistemi',
      body:
          'Kullanıcı Plango deneyimi, içerikler, teknik sorunlar veya uzman sistemi hakkında geri bildirimde bulunabilir.\n\n'
          'Geri bildirimler hakaret, tehdit, kişisel saldırı, üçüncü kişilerin kişisel verilerini hukuka aykırı biçimde açıklama veya yanıltıcı bilgi yayma amacıyla kullanılamaz.\n\n'
          'Plango, doğrulanabilir geri bildirimleri hizmet kalitesini geliştirmek amacıyla değerlendirebilir.',
    ),
    _AgreementSection(
      icon: Icons.rule_outlined,
      title: 'Kullanıcının Genel Yükümlülükleri',
      body:
          'Kullanıcı Plango’yu yürürlükteki mevzuata, işbu sözleşmeye ve dürüstlük kurallarına uygun biçimde kullanmalıdır.\n\n'
          'Kullanıcı, sistemin çalışmasını bozacak girişimlerde bulunmamalı; diğer kullanıcıların, uzmanların veya üçüncü kişilerin haklarını ihlal etmemelidir.\n\n'
          'Kullanıcı, uygulamada gördüğü tahmini sonuçları yanıltıcı biçimde resmî belge veya şirket taahhüdü gibi sunmamalıdır.',
    ),
    _AgreementSection(
      icon: Icons.block_outlined,
      title: 'Yasaklanan Kullanımlar',
      body:
          'Plango üzerinde hukuka aykırı içerik paylaşmak, sahte hesap oluşturmak, başka kişilerin hesaplarına izinsiz erişmeye çalışmak, güvenlik önlemlerini aşmak veya hizmeti kötüye kullanmak yasaktır.\n\n'
          'Otomatik sistemlerle uygulamanın olağan kullanımını bozacak yoğun istek göndermek, veri toplamak veya güvenlik açıklarını istismar etmek yasaktır.\n\n'
          'Plango içeriğini üçüncü kişileri yanıltmak, dolandırıcılık yapmak veya yetkisiz ticari faaliyet yürütmek amacıyla kullanmak yasaktır.',
    ),
    _AgreementSection(
      icon: Icons.security_outlined,
      title: 'Kötüye Kullanımın Önlenmesi',
      body:
          'Plango, kullanıcıların ve platformun güvenliğini korumak amacıyla şüpheli kullanım davranışlarını inceleyebilir ve gerekli teknik tedbirleri uygulayabilir.\n\n'
          'Açık kötüye kullanım, güvenlik ihlali veya hukuka aykırı faaliyet şüphesinde erişim geçici olarak sınırlandırılabilir.\n\n'
          'Bu tedbirler uygulanırken olayın niteliği, ölçülülük ve yürürlükteki zorunlu hükümler dikkate alınır.',
    ),
    _AgreementSection(
      icon: Icons.copyright_outlined,
      title: 'Fikri Mülkiyet Hakları',
      body:
          'Plango adı, uygulama tasarımı, özgün metinler, yazılım bileşenleri, FP Engine yapısı ve Plango’ya ait diğer özgün unsurlar üzerindeki haklar ilgili hak sahiplerine aittir.\n\n'
          'Kullanıcıya üyelik verilmesi bu unsurların mülkiyetinin devredildiği anlamına gelmez.\n\n'
          'Kullanıcı, yalnızca uygulamanın normal kullanım amacı kapsamında kişisel ve sınırlı kullanım hakkına sahiptir.',
    ),
    _AgreementSection(
      icon: Icons.business_center_outlined,
      title: 'Şirket Marka ve Logoları',
      body:
          'Plango’da yer alan üçüncü taraf şirketlerin marka, logo ve ticaret unvanları ilgili hak sahiplerine aittir.\n\n'
          'Bu unsurların bilgilendirme amacıyla gösterilmesi, ilgili şirket ile Plango arasında ortaklık veya temsil ilişkisi bulunduğu anlamına gelmez.\n\n'
          'Kullanıcı, üçüncü taraf marka ve logolarını hukuka aykırı biçimde çoğaltmamalı veya kullanmamalıdır.',
    ),
    _AgreementSection(
      icon: Icons.privacy_tip_outlined,
      title: 'Kişisel Veriler ve Gizlilik',
      body:
          'Üyelik kapsamında kişisel verilerin işlenmesine ilişkin ayrıntılar Plango Gizlilik Politikası ve ilgili KVKK Aydınlatma Metninde açıklanır.\n\n'
          'Kullanıcı Sözleşmesinin kabulü, açık rıza gerektiren her türlü veri işleme faaliyetine otomatik olarak açık rıza verildiği anlamına gelmez.\n\n'
          'Açık rıza gereken durumlarda ilgili onayın ayrı ve özgür iradeyle alınması esastır.',
    ),
    _AgreementSection(
      icon: Icons.fact_check_outlined,
      title: 'Aydınlatma Metni ile İlişki',
      body:
          'KVKK Aydınlatma Metni, kullanıcıya kişisel verilerin işlenmesi hakkında bilgi vermek amacıyla sunulur ve işbu Kullanıcı Sözleşmesinden ayrı bir hukuki işleve sahiptir.\n\n'
          'Kullanıcının üyelik oluştururken Aydınlatma Metnine erişebilmesi sağlanmalıdır.\n\n'
          'Aydınlatmanın yapılmış olması için kullanıcıdan “rıza” alınması yerine, aydınlatma yükümlülüğünün kendi kurallarına uygun şekilde yerine getirilmesi esastır.',
    ),
    _AgreementSection(
      icon: Icons.check_circle_outline_rounded,
      title: 'Açık Rıza Gerektiren İşlemler',
      body:
          'Plango’nun belirli bir veri işleme faaliyeti için açık rızaya ihtiyaç duyması halinde, bu rıza işbu sözleşmenin genel kabul kutusuna gizlenmemelidir.\n\n'
          'Açık rıza belirli bir konuya ilişkin, bilgilendirmeye dayanan ve özgür iradeyle açıklanan ayrı bir kullanıcı tercihi olarak alınmalıdır.\n\n'
          'Kullanıcının hizmetten yararlanmasıyla doğrudan ilgili olmayan bir veri işleme amacına rıza vermesi, üyeliğin zorunlu şartı haline getirilmemelidir.',
    ),
    _AgreementSection(
      icon: Icons.extension_outlined,
      title: 'Üçüncü Taraf Hizmetler',
      body:
          'Plango; kimlik doğrulama, bulut veri saklama, dosya oluşturma veya teknik altyapı gibi alanlarda üçüncü taraf hizmetlerden yararlanabilir.\n\n'
          'Üçüncü taraf hizmetler kendi teknik ve hukuki koşullarına sahip olabilir.\n\n'
          'Kullanıcının Plango dışındaki bağımsız bir web sitesine veya hizmete yönlendirilmesi halinde ilgili üçüncü tarafın kendi şartları uygulanabilir.',
    ),
    _AgreementSection(
      icon: Icons.open_in_new_outlined,
      title: 'Harici Bağlantılar',
      body:
          'Plango, şirketlerin, kamu kurumlarının veya bilgilendirici kaynakların internet sayfalarına bağlantılar sunabilir.\n\n'
          'Harici bağlantının sunulması, bağlantı verilen sitenin tüm içeriklerinin Plango tarafından onaylandığı veya garanti edildiği anlamına gelmez.\n\n'
          'Kullanıcı üçüncü taraf siteye geçtiğinde ilgili sitenin gizlilik ve kullanım koşullarını ayrıca incelemelidir.',
    ),
    _AgreementSection(
      icon: Icons.auto_awesome_outlined,
      title: 'Hizmetin Geliştirilmesi',
      body:
          'Plango, kullanıcı deneyimini, güvenliği ve hizmet kalitesini geliştirmek amacıyla uygulama özelliklerinde değişiklik yapabilir.\n\n'
          'Yeni özellikler eklenebilir, mevcut özelliklerin çalışma biçimi değiştirilebilir veya artık gerekli olmayan özellikler kaldırılabilir.\n\n'
          'Esaslı değişikliklerin kullanıcı haklarını etkilediği durumlarda gerekli bilgilendirme süreçleri uygulanmalıdır.',
    ),
    _AgreementSection(
      icon: Icons.build_outlined,
      title: 'Bakım ve Teknik Kesintiler',
      body:
          'Plango; bakım, güncelleme, güvenlik çalışmaları, internet altyapısı veya üçüncü taraf servislerden kaynaklanan nedenlerle geçici olarak erişilemeyebilir.\n\n'
          'Plango hizmetin her an kesintisiz çalışacağını garanti etmez.\n\n'
          'Planlı veya beklenmeyen teknik kesintiler, kullanıcı ile tasarruf finansman şirketi arasındaki bağımsız sözleşme ilişkisini etkilemez.',
    ),
    _AgreementSection(
      icon: Icons.system_update_alt_outlined,
      title: 'Sürüm ve Uyumluluk',
      body:
          'Plango’nun bazı özellikleri uygulamanın güncel sürümünü gerektirebilir.\n\n'
          'Eski sürümlerde güvenlik, performans veya özellik uyumsuzlukları oluşabilir.\n\n'
          'Kullanıcının güvenli ve sağlıklı kullanım için uygulamanın güncel sürümünü kullanması önerilir.',
    ),
    _AgreementSection(
      icon: Icons.pause_circle_outline_rounded,
      title: 'Hesabın Geçici Olarak Sınırlandırılması',
      body:
          'Güvenlik riski, yetkisiz erişim şüphesi, sistematik kötüye kullanım veya diğer kullanıcıların güvenliğini etkileyen durumlarda hesap geçici olarak sınırlandırılabilir.\n\n'
          'Mümkün ve uygun olduğu durumlarda kullanıcıya sınırlandırmanın nedeni ve hesabını yeniden güvenli hale getirmek için gerekli adımlar hakkında bilgi verilebilir.\n\n'
          'Zorunlu tüketici ve kullanıcı hakları saklıdır.',
    ),
    _AgreementSection(
      icon: Icons.person_off_outlined,
      title: 'Hesabın Sonlandırılması',
      body:
          'Kullanıcı, uygulamanın sunduğu hesap silme özelliği veya ilan edilen uygun kanal üzerinden üyeliğini sonlandırabilir.\n\n'
          'Ağır veya tekrarlanan sözleşme ihlali, sahte hesap, hukuka aykırı kullanım veya ciddi güvenlik ihlali durumunda Plango üyeliği sona erdirebilir.\n\n'
          'Hesabın kapatılması halinde kişisel verilerin akıbeti Gizlilik Politikası ve ilgili veri koruma düzenlemeleri çerçevesinde ele alınır.',
    ),
    _AgreementSection(
      icon: Icons.logout_rounded,
      title: 'Kullanıcının Üyelikten Ayrılması',
      body:
          'Kullanıcının Plango üyeliğini sonlandırması, tasarruf finansman şirketleriyle yapmış olduğu bağımsız sözleşmeleri sona erdirmez.\n\n'
          'Kullanıcı, üyelikten ayrılmadan önce ihtiyaç duyduğu kayıtlı plan veya dışa aktarılabilir belgeleri uygulamanın sunduğu ölçüde saklayabilir.\n\n'
          'Üyelik sona erdikten sonra hesaba bağlı bazı uygulama özelliklerine erişim mümkün olmayabilir.',
    ),
    _AgreementSection(
      icon: Icons.payments_outlined,
      title: 'Ücretsiz ve Ücretli Özellikler',
      body:
          'Plango’nun mevcut veya gelecekteki bazı özellikleri ücretsiz, bazı özellikleri ise ileride ücretli olarak sunulabilir.\n\n'
          'Yeni bir ücretli hizmet sunulması halinde kullanıcı, ücret ve temel koşullar hakkında ödeme öncesinde bilgilendirilmelidir.\n\n'
          'İşbu sözleşmenin kabulü, gelecekte oluşturulabilecek ücretli bir hizmetin bedelinin kullanıcı tarafından peşinen kabul edildiği anlamına gelmez.',
    ),
    _AgreementSection(
      icon: Icons.shield_outlined,
      title: 'Plango’nun Sorumluluk Alanı',
      body:
          'Plango kendi dijital hizmetinin yürütülmesi, hesaplama altyapısının işletilmesi ve kendi kontrolündeki kullanıcı deneyimi bakımından sorumluluk taşır.\n\n'
          'Tasarruf finansman şirketlerinin sözleşmeleri, teslim süreçleri, tahsilatları, şirket çalışanlarının bağımsız beyanları ve şirketlerin kendi operasyonları Plango’nun doğrudan kontrolünde değildir.\n\n'
          'Bu hüküm, Plango’nun kendi kusurundan veya emredici hukuk hükümlerinden doğan sorumluluğunu ortadan kaldıracak şekilde yorumlanamaz.',
    ),
    _AgreementSection(
      icon: Icons.warning_amber_rounded,
      title: 'Sorumluluğun Sınırları',
      body:
          'Plango’nun tahmini hesaplama sonuçları, kullanıcı girdilerine ve uygulanan modele bağlıdır.\n\n'
          'Kullanıcının yanlış veri girmesi, tahmini sonucu resmî teklif gibi yorumlaması veya üçüncü tarafın bağımsız işlemine dayanarak karar vermesi nedeniyle ortaya çıkabilecek sonuçlar somut olayın niteliğine göre değerlendirilir.\n\n'
          'Bu sözleşmedeki hiçbir hüküm, tüketici hukukundan veya diğer emredici mevzuattan doğan vazgeçilmez hakları ortadan kaldırmaz ya da hukuken geçerli olmayacak bir sorumsuzluk kaydı oluşturmaz.',
    ),
    _AgreementSection(
      icon: Icons.thunderstorm_outlined,
      title: 'Mücbir Sebep ve Kontrol Dışı Olaylar',
      body:
          'Doğal afet, savaş, yaygın iletişim kesintisi, kamu otoritesi kararı, büyük ölçekli siber saldırı, altyapı arızası ve tarafların makul kontrolü dışında gelişen benzeri olaylar hizmetin geçici olarak aksamasına neden olabilir.\n\n'
          'Bu durumlarda Plango, hizmeti makul sürede yeniden sağlamak için gerekli teknik çabayı göstermeyi hedefler.\n\n'
          'Emredici mevzuattan doğan hak ve sorumluluklar saklıdır.',
    ),
    _AgreementSection(
      icon: Icons.update_outlined,
      title: 'Sözleşme ve Politika Güncellemeleri',
      body:
          'Plango’nun hizmet kapsamı, mevzuat veya teknik altyapı değiştikçe bu sözleşme güncellenebilir.\n\n'
          'Kullanıcının hak ve yükümlülüklerini esaslı biçimde etkileyen değişikliklerde, güncel metnin kullanıcıya sunulması ve gerektiğinde yeniden kabul alınması değerlendirilir.\n\n'
          'Sadece bilgilendirme niteliğindeki küçük yazım veya açıklama değişiklikleri aynı kapsamda olmayabilir.',
    ),
    _AgreementSection(
      icon: Icons.history_toggle_off_outlined,
      title: 'Sözleşme Sürümü ve Kabul Kaydı',
      body:
          'Plango, kullanıcının hangi sözleşme sürümünü hangi tarihte kabul ettiğini teknik olarak kaydedebilir.\n\n'
          'Bu kayıt, sözleşme yönetimi, kullanıcı taleplerinin yanıtlanması ve hukuki yükümlülüklerin yerine getirilmesi amacıyla kullanılabilir.\n\n'
          'Sözleşme sürümü ve kabul kaydının kişisel veri niteliğindeki kısımları Gizlilik Politikası ve KVKK düzenlemeleri kapsamında ele alınır.',
    ),
    _AgreementSection(
      icon: Icons.touch_app_outlined,
      title: 'Elektronik Ortamda Kabul',
      body:
          'Kullanıcı, üyelik ekranında işbu sözleşmeye erişebilmeli ve sözleşmeyi kabul ettiğini ayrı ve açık bir kullanıcı işlemiyle belirtmelidir.\n\n'
          'Sözleşme bağlantısının erişilebilir olması ve kabul kutusunun kullanıcı tarafından aktif biçimde işaretlenmesi hedeflenir.\n\n'
          'Kullanıcının sözleşmeyi kabul etmeden üyelik işlemini tamamlamaması sağlanabilir.',
    ),
    _AgreementSection(
      icon: Icons.balance_rounded,
      title: 'Tüketici Haklarının Saklılığı',
      body:
          'Kullanıcının tüketici sıfatını taşıdığı durumlarda 6502 sayılı Tüketicinin Korunması Hakkında Kanun ve ilgili emredici düzenlemelerden doğan hakları saklıdır.\n\n'
          'İşbu sözleşme, kullanıcının kanundan doğan başvuru, uyuşmazlık çözümü veya diğer vazgeçilmez haklarını ortadan kaldıracak şekilde yorumlanamaz.\n\n'
          'Sözleşmede emredici mevzuata aykırı olduğu tespit edilen bir hüküm bulunması halinde, ilgili zorunlu düzenleme uygulanır.',
    ),
    _AgreementSection(
      icon: Icons.account_balance_rounded,
      title: 'Uyuşmazlıkların Çözümü',
      body:
          'Taraflar, uyuşmazlık halinde öncelikle Plango’nun ilan ettiği iletişim kanalı üzerinden çözüm arayabilir.\n\n'
          'Kullanıcının tüketici sıfatını taşıdığı durumlarda, yürürlükteki mevzuat uyarınca görevli ve yetkili Tüketici Hakem Heyetleri, Tüketici Mahkemeleri ve diğer yetkili mercilere başvuru hakları saklıdır.\n\n'
          'Bu sözleşme, kanunen yetkili mercileri ortadan kaldıran veya tüketiciyi zorunlu biçimde hakkından vazgeçiren bir yetki şartı olarak yorumlanamaz.',
    ),
    _AgreementSection(
      icon: Icons.gavel_outlined,
      title: 'Uygulanacak Hukuk',
      body:
          'İşbu sözleşme, Türkiye Cumhuriyeti hukukunun emredici hükümleri başta olmak üzere yürürlükteki ilgili mevzuat çerçevesinde değerlendirilir.\n\n'
          'Tüketici, kişisel veri ve elektronik hizmetlere ilişkin özel düzenlemeler uygulanması gerektiğinde ilgili özel hükümler öncelikle dikkate alınır.\n\n'
          'Tarafların kanunen sahip olduğu vazgeçilmez haklar saklıdır.',
    ),
    _AgreementSection(
      icon: Icons.rule_folder_outlined,
      title: 'Kısmi Geçersizlik',
      body:
          'Sözleşmenin herhangi bir hükmünün yürürlükteki mevzuat nedeniyle geçersiz veya uygulanamaz hale gelmesi, diğer hükümlerin kendiliğinden geçersiz olması sonucunu doğurmaz.\n\n'
          'Geçersiz hüküm, mümkün olduğu ölçüde ilgili emredici düzenleme ve sözleşmenin genel amacıyla uyumlu şekilde değerlendirilir.\n\n'
          'Kullanıcının kanundan doğan hakları her durumda saklıdır.',
    ),
    _AgreementSection(
      icon: Icons.mail_outline_rounded,
      title: 'İletişim',
      body:
          'Kullanıcı, üyelik ve sözleşmeye ilişkin soru veya taleplerini Plango tarafından uygulama içinde veya resmî kanallarda ilan edilen iletişim adresleri üzerinden iletebilir.\n\n'
          'Plango’nun nihai ticari unvanı, e-posta adresi ve resmî bildirim kanalları yayına çıkmadan önce bu sözleşmede açık biçimde yer almalıdır.\n\n'
          'Kişisel verilere ilişkin başvurular ise ilgili KVKK Aydınlatma Metni ve Gizlilik Politikası kapsamında belirtilen kanallardan yürütülür.',
    ),
    _AgreementSection(
      icon: Icons.play_circle_outline_rounded,
      title: 'Yürürlük',
      body:
          'İşbu Kullanıcı Sözleşmesi, kullanıcının elektronik ortamda sözleşmeye erişerek kabul işlemini tamamladığı tarihte yürürlüğe girer.\n\n'
          'Üyelik ilişkisi devam ettiği sürece sözleşmenin güncel ve kullanıcı bakımından geçerli hükümleri uygulanır.\n\n'
          'Yeniden kabul gerektiren esaslı bir sözleşme değişikliği yapılması halinde kullanıcıdan güncel sürüm için ayrıca onay istenebilir.',
    ),
    _AgreementSection(
      icon: Icons.verified_outlined,
      title: 'Son Hüküm',
      body:
          'Kullanıcı, işbu sözleşmenin Plango üyeliğinin kullanım şartlarını düzenlediğini; tasarruf finansman şirketleriyle kuracağı bağımsız sözleşme ilişkilerinin bu sözleşmenin konusu olmadığını kabul eder.\n\n'
          'Plango’nun amacı kullanıcı adına finansal karar vermek değil; kullanıcıya kendi kararını destekleyen dijital araçlar ve bilgi sunmaktır.\n\n'
          'Kullanıcı, üyelik işlemini tamamlamadan önce sözleşmeye erişme ve sözleşme hükümlerini inceleme imkanına sahip olmalıdır.',
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
          'Kullanıcı Sözleşmesi',
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
            const _AgreementHeroCard(),
            const SizedBox(height: 16),
            const _AgreementIntroCard(),
            const SizedBox(height: 16),
            const _SectionLabel(),
            const SizedBox(height: 10),
            ...List.generate(_sections.length, (index) {
              final section = _sections[index];
              final isOpen = _openIndex == index;
              return _AgreementAccordionCard(
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
            const _AgreementFooterCard(),
            const SizedBox(height: 12),
            const _LaunchNote(),
          ],
        ),
      ),
    );
  }
}

class _AgreementHeroCard extends StatelessWidget {
  const _AgreementHeroCard();

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
            _UserAgreementScreenState._navy,
            _UserAgreementScreenState._petrol,
            Color(0xFF0C6268),
            _UserAgreementScreenState._teal,
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
              color: _UserAgreementScreenState._turquoise.withOpacity(.16),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: const Color(0xFF55E2D0).withOpacity(.28),
              ),
            ),
            child: const Icon(
              Icons.assignment_turned_in_outlined,
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
                  'Kullanıcı Sözleşmesi',
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
                  'Plango üyeliğinin kullanım şartları ile kullanıcı ve '
                  'platform arasındaki temel hak ve yükümlülükler.',
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

class _AgreementIntroCard extends StatelessWidget {
  const _AgreementIntroCard();

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
            Icons.info_outline_rounded,
            color: _UserAgreementScreenState._teal,
            size: 21,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Bu sözleşme Plango üyeliğinin kurallarını düzenler. '
              'KVKK Aydınlatma Metni, Gizlilik Politikası ve gerektiğinde '
              'açık rıza süreçleri kendi hukuki amaçları doğrultusunda ayrıca sunulur.',
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
          Icons.article_outlined,
          color: _UserAgreementScreenState._teal,
          size: 18,
        ),
        SizedBox(width: 7),
        Text(
          'Sözleşme Maddeleri',
          style: TextStyle(
            color: _UserAgreementScreenState._navy,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

class _AgreementAccordionCard extends StatelessWidget {
  const _AgreementAccordionCard({
    required this.number,
    required this.section,
    required this.isOpen,
    required this.onTap,
  });

  final int number;
  final _AgreementSection section;
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
              ? _UserAgreementScreenState._teal.withOpacity(.30)
              : _UserAgreementScreenState._border,
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
                            _UserAgreementScreenState._teal.withOpacity(.14),
                            _UserAgreementScreenState._turquoise.withOpacity(.10),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        section.icon,
                        color: _UserAgreementScreenState._teal,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '$number. ${section.title}',
                        style: const TextStyle(
                          color: _UserAgreementScreenState._navy,
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
                        color: _UserAgreementScreenState._muted,
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

class _AgreementFooterCard extends StatelessWidget {
  const _AgreementFooterCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
      decoration: BoxDecoration(
        color: _UserAgreementScreenState._navy,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_user_outlined,
            color: Color(0xFF55E2D0),
            size: 21,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Kullanıcının tüketici mevzuatı, kişisel verilerin korunması '
              've diğer emredici düzenlemelerden doğan vazgeçilmez hakları saklıdır.',
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

class _LaunchNote extends StatelessWidget {
  const _LaunchNote();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Text(
        'Yayın öncesi: Plango’nun nihai ticari unvanı, resmî adresi, '
        'iletişim bilgileri ve sözleşme sürüm numarası bu metinde '
        'tamamlanmalı ve metin hukuk uzmanı tarafından son kez kontrol edilmelidir.',
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

class _AgreementSection {
  const _AgreementSection({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}
