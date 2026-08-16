import 'package:flutter/material.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  static const Color _navy = Color(0xFF0B2239);
  static const Color _petrol = Color(0xFF052F3D);
  static const Color _teal = Color(0xFF087C72);
  static const Color _turquoise = Color(0xFF16C7B0);
  static const Color _background = Color(0xFFF7F9FB);
  static const Color _muted = Color(0xFF748193);
  static const Color _border = Color(0xFFE4EBEE);

  int? _openIndex;

  final List<_AboutSection> _sections = const [
    _AboutSection(
      icon: Icons.explore_outlined,
      title: 'Tasarruf Planım Nedir?',
      body:
          'Tasarruf Planım; tasarruf finansmanı sistemini araştıran, farklı ödeme senaryolarını değerlendirmek isteyen ve karar sürecinde daha fazla bilgiye ihtiyaç duyan kullanıcılar için geliştirilmiş bağımsız bir dijital karar destek platformudur.\n\n'
          'Platformun temel amacı, tasarruf finansmanı alanındaki karmaşık bilgileri daha anlaşılır hale getirmek; kullanıcıların finansman tutarı, peşinat, aylık ödeme, teslim süresi, vade ve ödeme modeli gibi başlıklarda kendi senaryolarını oluşturabilmesini sağlamaktır.\n\n'
          'Tasarruf Planım herhangi bir tasarruf finansman şirketinin resmî uygulaması değildir. Herhangi bir şirket adına sözleşme düzenlemez, ödeme tahsil etmez, finansman sağlamaz ve kullanıcı adına karar vermez.\n\n'
          'Tasarruf Planım’ın rolü; bilgi sunmak, hesaplama yapmak, seçenekleri görünür hale getirmek ve kullanıcının kendi kararını daha bilinçli şekilde verebilmesine destek olmaktır.',
    ),
    _AboutSection(
      icon: Icons.lightbulb_outline_rounded,
      title: 'Tasarruf Planım Neden Geliştirildi?',
      body:
          'Tasarruf finansmanı sistemi; ev, araç ve benzeri finansman ihtiyaçlarını faizsiz modeller üzerinden planlamak isteyen kullanıcılar için önemli bir alternatif haline gelmiştir.\n\n'
          'Ancak kullanıcı açısından sistem her zaman kolay anlaşılır değildir. Finansman tutarı, peşinat, aylık taksit, teslim süresi, toplam vade, organizasyon ücreti, artışlı ödeme modelleri, şirket uygulamaları ve mevzuat gibi çok sayıda değişken aynı anda değerlendirilmek zorundadır.\n\n'
          'Kullanıcı çoğu zaman yalnızca “Ne kadar öderim?” sorusuna değil; “Ne zaman teslim alırım?”, “Peşinatı artırırsam ne değişir?”, “Taksiti yükseltirsem vade ne kadar kısalır?”, “Artışlı plan benim için nasıl sonuç verir?” gibi sorulara da cevap arar.\n\n'
          'Tasarruf Planım bu ihtiyacı karşılamak için geliştirildi. Amaç; kullanıcının farklı senaryoları tekrar tekrar hesaplayabileceği, sistemin mantığını daha kolay anlayabileceği ve resmî karar vermeden önce kendi alternatiflerini değerlendirebileceği bağımsız bir dijital alan oluşturmaktır.',
    ),
    _AboutSection(
      icon: Icons.troubleshoot_outlined,
      title: 'Çözmek İstediğimiz Problem',
      body:
          'Tasarruf finansmanı sektöründe bilgi çoğu zaman farklı şirket ekranlarında, satış görüşmelerinde, sözleşme metinlerinde, kampanya duyurularında ve mevzuat kaynaklarında dağınık şekilde bulunur.\n\n'
          'Bu da kullanıcıların aynı anda birden fazla kaynağı takip etmesini, farklı hesaplama yöntemlerini anlamasını ve kendi mali durumuna göre karşılaştırma yapmasını zorlaştırabilir.\n\n'
          'Tasarruf Planım; bilgiye erişim, hesaplama ve değerlendirme süreçlerini tek bir dijital deneyim içinde bir araya getirmeyi hedefler.\n\n'
          'Buradaki amaç sektörü veya şirketleri tek bir kalıba sokmak değil; kullanıcıya kendi kararını verebilmesi için daha anlaşılır bir çerçeve sunmaktır.',
    ),
    _AboutSection(
      icon: Icons.flag_outlined,
      title: 'Misyonumuz',
      body:
          'Tasarruf Planım’ın misyonu; tasarruf finansmanı sistemine ilişkin hesaplama, bilgilendirme ve değerlendirme süreçlerini sadeleştirerek kullanıcıların daha bilinçli karar verebilmesine destek olmaktır.\n\n'
          'Tasarruf Planım, kullanıcıya nihai karar sunmaz. Kullanıcı adına şirket seçmez. Kullanıcı adına plan belirlemez.\n\n'
          'Bunun yerine; kullanıcının kendi verileriyle hesaplama yapabilmesini, farklı senaryoları görebilmesini, sektörel bilgileri okuyabilmesini ve resmî karar öncesinde daha güçlü bir değerlendirme zemini oluşturabilmesini sağlar.\n\n'
          'Misyonumuzun merkezinde kullanıcıyı yönlendirmek değil, kullanıcıyı güçlendirmek vardır.',
    ),
    _AboutSection(
      icon: Icons.public_rounded,
      title: 'Vizyonumuz',
      body:
          'Tasarruf Planım’ın vizyonu; tasarruf finansmanı alanında kullanıcıların hesaplama yapabildiği, sistemi anlayabildiği, güncel gelişmeleri takip edebildiği, şirket bilgilerine erişebildiği ve uygun olduğunda doğrulanmış sektör uzmanlarıyla iletişim kurabildiği kapsamlı bir karar destek platformu olmaktır.\n\n'
          'Tasarruf Planım, sektördeki şirketlerin veya uzmanların yerine geçmeyi değil; kullanıcı ile bilgi arasında daha sade, anlaşılır ve tarafsız bir köprü kurmayı hedefler.\n\n'
          'Uzun vadede hedefimiz, tasarruf finansmanı karar sürecinin kullanıcı açısından daha şeffaf, daha erişilebilir ve daha anlaşılır hale gelmesine katkı sunmaktır.',
    ),
    _AboutSection(
      icon: Icons.balance_outlined,
      title: 'Bağımsızlık İlkemiz',
      body:
          'Bağımsızlık, Tasarruf Planım’ın temel ürün ilkelerinden biridir.\n\n'
          'Tasarruf Planım herhangi bir tasarruf finansman şirketine bağlı olarak faaliyet göstermez. Hesaplama sonuçları belirli bir şirketi öne çıkarmak, belirli bir kampanyayı avantajlı göstermek veya kullanıcıyı belirli bir kuruluşa yönlendirmek amacıyla hazırlanmaz.\n\n'
          'Bir şirketin Tasarruf Planım’da yer alması, o şirketin Tasarruf Planım tarafından tavsiye edildiği anlamına gelmez. Benzer şekilde bir uzmanın Tasarruf Planım’da doğrulanmış olması da o uzmanın diğer uzmanlardan daha iyi olduğu anlamına gelmez.\n\n'
          'Tasarruf Planım’ın bağımsızlık anlayışı; hesaplama, bilgilendirme, şirket görünürlüğü, uzman sistemi ve içerik yayınlama süreçlerinin tamamında kullanıcıya açık ve dürüst bir karar destek deneyimi sunmayı hedefler.',
    ),
    _AboutSection(
      icon: Icons.compare_arrows_rounded,
      title: 'Tarafsızlık İlkemiz',
      body:
          'Tasarruf Planım, tasarruf finansman şirketleri, uzmanlar, ödeme modelleri ve kampanyalar arasında taraflı bir değerlendirme yapmayı amaçlamaz.\n\n'
          'Platformda yer alan bilgilerin mümkün olduğunca nesnel, doğrulanabilir ve açıklayıcı biçimde sunulması hedeflenir.\n\n'
          'Tasarruf Planım’ın amacı “en iyi şirketi” veya “en iyi planı” ilan etmek değildir. Çünkü kullanıcıların mali durumları, ihtiyaçları, hedefleri ve öncelikleri birbirinden farklıdır.\n\n'
          'Bir seçenek bir kullanıcı için uygunken başka bir kullanıcı için uygun olmayabilir. Bu nedenle Tasarruf Planım, mutlak sıralama yapmak yerine kullanıcıya kendi koşullarına göre değerlendirme yapabileceği bir yapı sunmayı tercih eder.',
    ),
    _AboutSection(
      icon: Icons.visibility_outlined,
      title: 'Şeffaflık Anlayışımız',
      body:
          'Tasarruf Planım, kullanıcıya sunduğu hesaplama ve bilgilendirme araçlarının niteliğini açık biçimde belirtmeyi temel bir sorumluluk olarak görür.\n\n'
          'FP Engine sonuçlarının tahmini olduğu, resmî teklif veya sözleşme niteliğinde olmadığı ve resmî süreçlerin ilgili şirket tarafından yürütüldüğü açıkça ifade edilir.\n\n'
          'Benzer şekilde şirket bilgileri, uzman profilleri ve bilgilendirici içerikler kullanıcıya olduğu gibi sunulmaya çalışılır; mümkün olduğunca yorum ile resmî bilgi birbirinden ayrılır.\n\n'
          'Şeffaflık yaklaşımımızın amacı, kullanıcının neye baktığını ve gördüğü bilginin ne anlama geldiğini net şekilde anlayabilmesini sağlamaktır.',
    ),
    _AboutSection(
      icon: Icons.memory_outlined,
      title: 'FP Engine Teknolojisi',
      body:
          'FP Engine, Tasarruf Planım içerisinde kullanılan bağımsız hesaplama motorudur.\n\n'
          'Kullanıcı tarafından girilen finansman tutarı, peşinat, aylık ödeme, ödeme modeli, artış oranı, artış periyodu ve benzeri parametreleri kullanarak tahmini ödeme planları ve teslim süresi analizleri oluşturur.\n\n'
          'FP Engine’in temel amacı şirket adına resmî teklif üretmek değil; kullanıcının farklı senaryoların muhtemel etkilerini görmesine yardımcı olacak standartlaştırılmış bir karar destek yaklaşımı sunmaktır.\n\n'
          'Kullanıcı aynı finansman tutarını farklı peşinat, taksit ve artış modelleriyle tekrar tekrar hesaplayabilir. Böylece tek bir planı görmek yerine alternatifler arasındaki farkları değerlendirebilir.\n\n'
          'FP Engine sonuçları tahmini ve bilgilendirme amaçlıdır. Resmî plan, sözleşme ve teslim tarihi ilgili tasarruf finansman şirketi tarafından belirlenir.',
    ),
    _AboutSection(
      icon: Icons.person_search_outlined,
      title: 'Kullanıcıya Sağladığımız Değer',
      body:
          'Tasarruf Planım’ın kullanıcıya sunduğu temel değer, karar sürecini daha anlaşılır hale getirmektir.\n\n'
          'Kullanıcı; farklı finansman senaryolarını tek tek hesaplayabilir, tahmini teslim süresini görebilir, ödeme planını inceleyebilir, planını kaydedebilir ve ihtiyaç duyduğu bilgileri tekrar görüntüleyebilir.\n\n'
          'Bu yapı, kullanıcının yalnızca satış görüşmesi sırasında duyduğu bilgilerle hareket etmek yerine kendi hesabını yapabilmesine destek olur.\n\n'
          'Tasarruf Planım’ın amacı kullanıcıyı bir seçeneğe yönlendirmek değil; kullanıcının seçenekleri daha bilinçli biçimde değerlendirebilmesine yardımcı olmaktır.',
    ),
    _AboutSection(
      icon: Icons.account_balance_outlined,
      title: 'Tasarruf Finansmanı Bilgilendirmesi',
      body:
          'Tasarruf Planım yalnızca hesaplama aracı değildir.\n\n'
          'Tasarruf finansman sistemi hakkında temel kavramlar, sistemin çalışma mantığı, ödeme modelleri, teslim süreci, organizasyon ücreti, sözleşme ve kullanıcıların dikkat etmesi gereken başlıklar hakkında bilgilendirici içerikler sunmayı hedefler.\n\n'
          'Bu içeriklerin amacı kullanıcıların sistemle ilk kez karşılaştığında temel kavramları anlayabilmesini sağlamaktır.\n\n'
          'Resmî ve bağlayıcı bilgiler için yürürlükteki mevzuat, yetkili kurumlar ve ilgili tasarruf finansman şirketlerinin resmî açıklamaları esas alınmalıdır.',
    ),
    _AboutSection(
      icon: Icons.apartment_outlined,
      title: 'Şirket Bilgileri Yaklaşımımız',
      body:
          'Tasarruf Planım’da tasarruf finansman şirketlerine ilişkin bilgilendirici profiller yer alabilir.\n\n'
          'Bu profillerin amacı kullanıcıya şirketler hakkında temel ve doğrulanabilir bilgileri daha kolay erişilebilir biçimde sunmaktır.\n\n'
          'Tasarruf Planım bir şirketi diğerinden üstün göstermeyi amaçlamaz. Şirket profillerinde yer alan bilgiler mümkün olduğunca nesnel bir çerçevede sunulmaya çalışılır.\n\n'
          'Şirketlerin kampanyaları, ürün koşulları ve uygulamaları zaman içinde değişebileceğinden kullanıcıların nihai karar öncesinde ilgili şirketin resmî kanallarını kontrol etmesi önemlidir.',
    ),
    _AboutSection(
      icon: Icons.verified_user_outlined,
      title: 'Doğrulanmış Uzman Sistemi',
      body:
          'Tasarruf Planım’da yer alan uzman profilleri, platform tarafından belirlenen doğrulama ve onay süreçlerinden geçmiş sektör profesyonellerinden oluşabilir.\n\n'
          'Bu sistemin amacı kullanıcıların tasarruf finansmanı alanında çalışan uzmanlara daha düzenli ve güvenli bir şekilde ulaşabilmesini kolaylaştırmaktır.\n\n'
          'Doğrulanmış uzman ifadesi, ilgili kişinin Tasarruf Planım doğrulama kriterlerini tamamladığını gösterir; devlet tarafından verilmiş bağımsız bir mesleki yeterlilik belgesi veya Tasarruf Planım tarafından verilmiş performans garantisi anlamına gelmez.\n\n'
          'Uzmanlar tarafından sunulan bilgiler ilgili uzmanın kendi mesleki sorumluluğu kapsamındadır.',
    ),
    _AboutSection(
      icon: Icons.support_agent_outlined,
      title: 'Danışma Deneyimi',
      body:
          'Tasarruf Planım’ın danışma sistemi, kullanıcıların tasarruf finansmanı hakkında soru sormak veya bilgi almak üzere uygun uzmanlarla iletişim kurmasını kolaylaştırmayı amaçlar.\n\n'
          'Danışma talebi finansman başvurusu, sözleşme, ön onay veya satın alma işlemi değildir.\n\n'
          'Tasarruf Planım’ın rolü kullanıcı ile uzman arasındaki iletişimi kolaylaştırmaktır. Kullanıcı ile uzman veya uzman tarafından temsil edilen şirket arasında kurulabilecek ticari ilişkinin tarafı Tasarruf Planım değildir.\n\n'
          'Danışma deneyiminin temelinde saygı, doğru bilgi, kullanıcı güvenliği ve şeffaf iletişim ilkeleri bulunur.',
    ),
    _AboutSection(
      icon: Icons.shield_outlined,
      title: 'Kullanıcı Güvenliği',
      body:
          'Tasarruf Planım, kullanıcıların güvenli bir dijital deneyim yaşamasını önemli bir ürün sorumluluğu olarak görür.\n\n'
          'Kullanıcı hesapları, uzman doğrulama süreçleri, veri erişim kuralları ve uygulama içi yetkilendirmeler bu yaklaşımın parçalarıdır.\n\n'
          'Bununla birlikte dijital güvenlik yalnızca teknik önlemlerden oluşmaz. Kullanıcıların parola, doğrulama kodu, banka şifresi veya benzeri hassas bilgileri üçüncü kişilerle paylaşmaması gerekir.\n\n'
          'Tasarruf Planım, kullanıcıların önemli finansal veya sözleşmesel işlemlerde ilgili kişi ve kuruluşların kimliğini resmî kanallardan doğrulamasını önerir.',
    ),
    _AboutSection(
      icon: Icons.lock_outline_rounded,
      title: 'Veri ve Gizlilik Yaklaşımımız',
      body:
          'Tasarruf Planım, kullanıcı verilerinin yalnızca hizmetin sunulması ve geliştirilmesi için gerekli olduğu ölçüde işlenmesini hedefler.\n\n'
          'Kullanıcının hesap bilgileri, kayıtlı planları veya uygulama içi işlemleri; ilgili özelliklerin çalışabilmesi amacıyla saklanabilir.\n\n'
          'Kişisel verilerin korunması, erişim yetkilerinin sınırlandırılması ve kullanıcıların hesaplarını yönetebilmesi Tasarruf Planım’ın ürün yaklaşımının önemli parçalarıdır.\n\n'
          'Veri işleme ve kullanıcı haklarına ilişkin detaylar Gizlilik Politikası ve ilgili yasal metinlerde açıklanır.',
    ),
    _AboutSection(
      icon: Icons.hub_outlined,
      title: 'Sektöre Bakışımız',
      body:
          'Tasarruf Planım tasarruf finansmanı sektörüne karşı veya sektörün yerine konumlanan bir yapı değildir.\n\n'
          'Amacımız, sektörde faaliyet gösteren şirketler ile kullanıcılar arasındaki bilgi akışını daha anlaşılır hale getiren bağımsız bir dijital katman oluşturmaktır.\n\n'
          'Tasarruf finansman şirketlerinin kendi ürünleri, operasyonları ve sözleşme süreçleri bulunur. Tasarruf Planım bu süreçlerin yerine geçmez.\n\n'
          'Tasarruf Planım’ın hedefi, kullanıcıların sektörü daha iyi anlayabilmesine ve resmî karar öncesinde daha fazla bilgiyle hareket edebilmesine katkı sağlamaktır.',
    ),
    _AboutSection(
      icon: Icons.handshake_outlined,
      title: 'Sektöre Saygılı Yaklaşım',
      body:
          'Tasarruf Planım’ın bağımsızlığı, şirketlere veya sektör profesyonellerine karşı olumsuz bir yaklaşım anlamına gelmez.\n\n'
          'Platform, sektörde faaliyet gösteren kuruluşlara ve uzmanlara tarafsız, saygılı ve doğrulanabilir bilgi temelli bir çerçevede yaklaşmayı hedefler.\n\n'
          'Yanlış veya doğrulanamayan iddialarla şirketleri ya da uzmanları itibarsızlaştırmak Tasarruf Planım’ın yaklaşımıyla bağdaşmaz.\n\n'
          'Aynı şekilde kullanıcıların da doğru, anlaşılır ve güncel bilgiye ulaşabilmesi önemlidir. Tasarruf Planım bu iki yaklaşım arasında dengeli bir bilgi ortamı kurmayı amaçlar.',
    ),
    _AboutSection(
      icon: Icons.autorenew_rounded,
      title: 'Sürekli Gelişim Anlayışımız',
      body:
          'Tasarruf Planım tamamlanmış ve değişmeyecek bir ürün olarak görülmez.\n\n'
          'Tasarruf finansmanı sektörü, mevzuat, kullanıcı alışkanlıkları ve dijital ürün standartları zaman içinde değişir. Tasarruf Planım da bu değişimlere uyum sağlayacak şekilde gelişmeyi hedefler.\n\n'
          'Kullanıcı geri bildirimleri, teknik performans, yeni mevzuat, sektör uygulamaları ve ürün kullanım verileri geliştirme sürecinde dikkate alınabilir.\n\n'
          'Sürekli gelişim yaklaşımımızın temel amacı daha fazla özellik eklemek değil; kullanıcı için gerçekten değer üreten özellikleri daha iyi hale getirmektir.',
    ),
    _AboutSection(
      icon: Icons.design_services_outlined,
      title: 'Ürün Tasarım Anlayışımız',
      body:
          'Tasarruf Planım’ın tasarım yaklaşımı; sadelik, güven, okunabilirlik ve işlevsellik üzerine kuruludur.\n\n'
          'Kullanıcıya gereksiz bilgi yüklemek yerine ihtiyaç duyduğu bilgiyi doğru zamanda ve anlaşılır biçimde sunmak hedeflenir.\n\n'
          'Hesaplama ekranları, ödeme planları, bilgi sayfaları ve profil alanları aynı tasarım dili içerisinde oluşturulur.\n\n'
          'Amaç yalnızca güzel görünen bir uygulama üretmek değil; kullanıcıyı yormayan, yönünü kaybettirmeyen ve karar sürecini kolaylaştıran bir deneyim oluşturmaktır.',
    ),
    _AboutSection(
      icon: Icons.rocket_launch_outlined,
      title: 'Gelecek Hedeflerimiz',
      body:
          'Tasarruf Planım’ın uzun vadeli hedefi, tasarruf finansmanı alanında kapsamlı ve güvenilir bir dijital karar destek ekosistemi oluşturmaktır.\n\n'
          'Gelecekte hesaplama altyapısının geliştirilmesi, daha fazla bilgilendirici içerik, daha güçlü şirket veri yapıları, kullanıcı deneyimini destekleyen yeni karşılaştırma araçları ve uzman sisteminin geliştirilmesi değerlendirilebilir.\n\n'
          'Ancak her yeni özellik aynı temel ilkelere bağlı kalmalıdır: bağımsızlık, tarafsızlık, şeffaflık, kullanıcı güvenliği ve kararın kullanıcıya ait olması.\n\n'
          'Tasarruf Planım’ın büyümesi, bu ilkelerden uzaklaşmak değil; bu ilkeleri daha geniş bir kullanıcı kitlesine taşıyabilmek anlamına gelmelidir.',
    ),
    _AboutSection(
      icon: Icons.block_outlined,
      title: 'Tasarruf Planım’ın Yapmadıkları',
      body:
          'Tasarruf Planım’ın ne yaptığını anlatmak kadar ne yapmadığını açıkça belirtmek de önemlidir.\n\n'
          'Tasarruf Planım finansman sağlamaz.\n\n'
          'Tasarruf Planım şirket adına sözleşme düzenlemez.\n\n'
          'Tasarruf Planım kullanıcıdan tasarruf finansmanı taksiti veya organizasyon ücreti tahsil etmez.\n\n'
          'Tasarruf Planım kesin teslim tarihi taahhüdünde bulunmaz.\n\n'
          'Tasarruf Planım kullanıcı adına şirket seçmez.\n\n'
          'Tasarruf Planım herhangi bir şirketi veya uzmanı mutlak şekilde tavsiye etmez.\n\n'
          'Tasarruf Planım resmî hukuki, yatırım veya finansal danışmanlık hizmeti sunmaz.\n\n'
          'Bu sınırlar, Tasarruf Planım’ın bağımsız karar destek platformu niteliğinin temel parçasıdır.',
    ),
    _AboutSection(
      icon: Icons.volunteer_activism_outlined,
      title: 'Kullanıcıya Verdiğimiz Söz',
      body:
          'Tasarruf Planım’ın kullanıcıya verdiği temel söz şudur: Kullanıcıya mümkün olduğunca anlaşılır, tarafsız ve şeffaf bir karar destek deneyimi sunmak.\n\n'
          'Hesaplama sonuçlarının niteliğini gizlememek, resmî süreç ile tahmini hesaplama arasındaki farkı açıkça belirtmek, şirket veya uzmanları kullanıcıya zorla yönlendirmemek ve kullanıcı güvenliğini ürün kararlarının merkezinde tutmak bu sözün parçalarıdır.\n\n'
          'Tasarruf Planım’ın başarısı yalnızca kaç kişinin uygulamayı kullandığıyla değil, kullanıcıların karar sürecinde ne kadar fayda sağladığıyla ölçülmelidir.',
    ),
    _AboutSection(
      icon: Icons.favorite_border_rounded,
      title: 'Son Söz',
      body:
          'Tasarruf Planım; kullanıcıların tasarruf finansmanı sürecini daha anlaşılır şekilde değerlendirebilmesi için geliştirilmiş bağımsız bir karar destek platformudur.\n\n'
          'Bilgi sunar, hesaplama yapar, farklı senaryoları görünür hale getirir ve kullanıcıların kendi karar süreçlerini daha bilinçli yönetmesine yardımcı olur.\n\n'
          'Resmî süreç, sözleşme, ödeme planı ve teslim şartları her zaman kullanıcı ile ilgili tasarruf finansman şirketi arasında yürütülür.\n\n'
          'Tasarruf Planım’ın amacı karar vermek değildir.\n\n'
          'Tasarruf Planım’ın amacı, kullanıcının kararını daha bilinçli verebilmesine yardımcı olmaktır.',
    ),
    _AboutSection(
      icon: Icons.mail_outline_rounded,
      title: 'İletişim',
      body:
          'Tasarruf Planım hakkında genel bilgi, kurumsal iletişim ve içeriklere ilişkin soru veya talepler için info@tasarrufplanim.com adresini kullanabilirsiniz.\n\n'
          'Uygulamanın kullanımı, hesap işlemleri, giriş sorunları veya teknik destek talepleri için destek@tasarrufplanim.com adresi kullanılabilir.\n\n'
          'Gizlilik ve kişisel verilerle ilgili genel talepler info@tasarrufplanim.com üzerinden iletilebilir; KVKK kapsamındaki resmî başvuru usulleri ilgili Aydınlatma Metni ve Gizlilik Politikası kapsamında ayrıca belirtilir.',
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
          'Hakkımızda',
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
            const _AboutHeroCard(),
            const SizedBox(height: 16),
            const _AboutIntroCard(),
            const SizedBox(height: 16),
            const _SectionLabel(),
            const SizedBox(height: 10),
            ...List.generate(_sections.length, (index) {
              final section = _sections[index];
              final isOpen = _openIndex == index;
              return _AboutAccordionCard(
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
            const _AboutFooterCard(),
          ],
        ),
      ),
    );
  }
}

class _AboutHeroCard extends StatelessWidget {
  const _AboutHeroCard();

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
            _AboutScreenState._navy,
            _AboutScreenState._petrol,
            Color(0xFF0C6268),
            _AboutScreenState._teal,
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
              color: _AboutScreenState._turquoise.withOpacity(.16),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: const Color(0xFF55E2D0).withOpacity(.28),
              ),
            ),
            child: const Icon(
              Icons.explore_outlined,
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
                  'TASARRUF PLANIM',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Bağımsız Tasarruf Finansmanı\nKarar Destek Platformu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.5,
                    height: 1.28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Bilgi sunar. Hesaplama yapar. Karar sürecine destek olur.',
                  style: TextStyle(
                    color: Color(0xFFD9E7E9),
                    fontSize: 12,
                    height: 1.45,
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

class _AboutIntroCard extends StatelessWidget {
  const _AboutIntroCard();

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
            Icons.verified_user_outlined,
            color: _AboutScreenState._teal,
            size: 21,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tasarruf Planım; kullanıcıların tasarruf finansmanı sürecini daha anlaşılır '
              'şekilde değerlendirebilmesi için geliştirilmiş bağımsız, tarafsız '
              've bilgilendirme odaklı bir karar destek platformudur.',
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
          Icons.menu_book_outlined,
          color: _AboutScreenState._teal,
          size: 18,
        ),
        SizedBox(width: 7),
        Text(
          'Tasarruf Planım’ı Yakından Tanıyın',
          style: TextStyle(
            color: _AboutScreenState._navy,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

class _AboutAccordionCard extends StatelessWidget {
  const _AboutAccordionCard({
    required this.number,
    required this.section,
    required this.isOpen,
    required this.onTap,
  });

  final int number;
  final _AboutSection section;
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
              ? _AboutScreenState._teal.withOpacity(.30)
              : _AboutScreenState._border,
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
                            _AboutScreenState._teal.withOpacity(.14),
                            _AboutScreenState._turquoise.withOpacity(.10),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        section.icon,
                        color: _AboutScreenState._teal,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '$number. ${section.title}',
                        style: const TextStyle(
                          color: _AboutScreenState._navy,
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
                      border: Border.all(
                        color: const Color(0xFFE6EEF1),
                      ),
                    ),
                    child: Text(
                      section.body,
                      style: const TextStyle(
                        color: _AboutScreenState._muted,
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

class _AboutFooterCard extends StatelessWidget {
  const _AboutFooterCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
      decoration: BoxDecoration(
        color: _AboutScreenState._navy,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            color: Color(0xFF55E2D0),
            size: 21,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tasarruf Planım’ın amacı karar vermek değil; kullanıcıların kendi karar '
              'süreçlerini daha bilinçli, anlaşılır ve şeffaf şekilde yönetmesine '
              'destek olmaktır.',
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

class _AboutSection {
  const _AboutSection({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}
