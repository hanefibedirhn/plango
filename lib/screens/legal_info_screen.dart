import 'package:flutter/material.dart';

class LegalInformationScreen extends StatefulWidget {
  const LegalInformationScreen({super.key});

  @override
  State<LegalInformationScreen> createState() =>
      _LegalInformationScreenState();
}

class _LegalInformationScreenState extends State<LegalInformationScreen> {
  static const Color _navy = Color(0xFF0B2239);
  static const Color _petrol = Color(0xFF052F3D);
  static const Color _teal = Color(0xFF087C72);
  static const Color _turquoise = Color(0xFF16C7B0);
  static const Color _background = Color(0xFFF7F9FB);
  static const Color _muted = Color(0xFF748193);
  static const Color _border = Color(0xFFE4EBEE);

  int? _openIndex;

  final List<_LegalSection> _sections = const [
    _LegalSection(
      icon: Icons.account_balance_outlined,
      title: 'Plango’nun Hukuki Konumu',
      body:
          'Plango; tasarruf finansmanı alanında kullanıcıların bilgiye daha kolay ulaşmasına, kendi ödeme senaryolarını oluşturmasına, tahmini sonuçları değerlendirmesine ve karar sürecini daha bilinçli yönetmesine yardımcı olmak amacıyla geliştirilmiş bağımsız bir dijital karar destek platformudur.\n\n'
          'Plango herhangi bir tasarruf finansman şirketinin iştiraki, şubesi, acentesi, temsilcisi, bayisi veya resmî satış kanalı değildir. Plango adına yapılan hiçbir açıklama, aksi açıkça ve yazılı olarak belirtilmedikçe herhangi bir tasarruf finansman şirketi adına yapılmış açıklama olarak değerlendirilemez.\n\n'
          'Bir şirketin, markanın, uzmanın, kampanyanın veya sektörel içeriğin Plango’da görüntülenmesi; Plango ile ilgili kişi veya kuruluş arasında ortaklık, temsilcilik, acentelik, sponsorluk, garanti ilişkisi ya da münhasır ticari ilişki bulunduğu anlamına gelmez.\n\n'
          'Plango’nun temel rolü; kullanıcı adına karar vermek değil, kullanıcının karar verebilmesi için anlaşılır bilgi, tahmini hesaplama ve yardımcı dijital araçlar sunmaktır.',
    ),
    _LegalSection(
      icon: Icons.gavel_outlined,
      title: 'Yasal Düzenleme ve Sektörel Çerçeve',
      body:
          'Türkiye’de tasarruf finansman şirketleri, ilgili mevzuat çerçevesinde faaliyet gösteren finansal kuruluşlardır. Tasarruf finansman şirketlerinin kuruluş ve faaliyetleri 6361 sayılı Finansal Kiralama, Faktoring, Finansman ve Tasarruf Finansman Şirketleri Kanunu ile ilgili ikincil düzenlemeler kapsamında ele alınmaktadır ve sektör Bankacılık Düzenleme ve Denetleme Kurumunun düzenleme ve denetim alanındadır.\n\n'
          'Plango bir düzenleyici kurum değildir. Plango tarafından sunulan açıklamalar mevzuatın resmî metninin yerine geçmez ve herhangi bir düzenleyici kurum adına yapılmış açıklama sayılmaz.\n\n'
          'Mevzuatın, kurul kararlarının ve ikincil düzenlemelerin zaman içinde değişebilmesi nedeniyle kullanıcıların bağlayıcı hukuki bilgi için yürürlükteki mevzuatı ve yetkili kamu kurumlarının güncel açıklamalarını esas alması gerekir.',
    ),
    _LegalSection(
      icon: Icons.explore_outlined,
      title: 'Platformun Amacı',
      body:
          'Plango’nun amacı, tasarruf finansmanı sistemini kullanıcı açısından daha anlaşılır, erişilebilir ve değerlendirilebilir hale getirmektir.\n\n'
          'Platform; kullanıcıların farklı finansman tutarı, peşinat, aylık ödeme, artış modeli ve vade senaryolarını görmesine; tasarruf finansmanı hakkında bilgilendirici içeriklere ulaşmasına; şirketlere ilişkin kamuya açık bilgileri incelemesine ve uygun durumlarda doğrulanmış uzmanlarla iletişim kurmasına yardımcı olabilir.\n\n'
          'Plango herhangi bir kullanıcıya “bu planı seç”, “bu şirkete başvur” veya “bu uzmanla çalış” şeklinde bağlayıcı yönlendirme yapmayı amaçlamaz. Kullanıcının koşulları, ödeme gücü, hedefleri ve tercihleri kişiseldir. Nihai değerlendirme ve karar kullanıcıya aittir.',
    ),
    _LegalSection(
      icon: Icons.balance_outlined,
      title: 'Bağımsızlık İlkesi',
      body:
          'Bağımsızlık, Plango’nun temel ürün ilkelerinden biridir.\n\n'
          'Plango’nun hesaplama motoru, kullanıcı tarafından girilen veriler üzerinden çalışır. Hesaplama sonucunun belirli bir şirketi öne çıkarmak, kullanıcıyı belirli bir şirkete yönlendirmek veya herhangi bir kuruluş lehine sonuç üretmek amacıyla değiştirilmemesi esastır.\n\n'
          'Plango üzerinde şirketlere ilişkin içerik bulunması, ilgili şirketin Plango tarafından tavsiye edildiği anlamına gelmez. Aynı şekilde bir şirket hakkında daha fazla veya daha az içerik bulunması da kalite, güvenilirlik veya tercih sıralaması olarak yorumlanmamalıdır.\n\n'
          'Plango’nun bağımsızlık ilkesi; hesaplama, bilgilendirme, şirket görünürlüğü, uzman sistemi ve içerik yayınlama süreçlerinin tamamında kullanıcıya açık ve dürüst bir karar destek deneyimi sunmayı hedefler.',
    ),
    _LegalSection(
      icon: Icons.compare_arrows_rounded,
      title: 'Tarafsızlık İlkesi',
      body:
          'Plango; tasarruf finansman şirketleri, uzmanlar, ödeme modelleri ve kampanyalar arasında taraflı bir değerlendirme yapmayı amaçlamaz.\n\n'
          'Platformda yer alan bilgiler mümkün olduğunca nesnel, doğrulanabilir ve açıklayıcı biçimde sunulmaya çalışılır. Plango, kullanıcıların kendi ihtiyaçlarına göre değerlendirme yapabilmesi için seçenekleri anlamlandırmayı kolaylaştırmayı hedefler.\n\n'
          'Herhangi bir şirketin, uzmanın veya ödeme modelinin Plango’da görünmesi; diğerlerinden üstün, daha güvenilir, daha avantajlı veya kullanıcı için kesin olarak daha uygun olduğu anlamına gelmez.\n\n'
          'Ticari iş birlikleri veya sponsorluklar ileride söz konusu olursa, kullanıcı algısını etkileyebilecek nitelikteki ticari içeriklerin mümkün olduğunca açık şekilde ayırt edilmesi Plango’nun şeffaflık yaklaşımının bir parçasıdır.',
    ),
    _LegalSection(
      icon: Icons.memory_outlined,
      title: 'FP Engine Nedir?',
      body:
          'FP Engine, Plango içerisinde kullanılan bağımsız hesaplama motorudur.\n\n'
          'Motor; kullanıcı tarafından girilen finansman tutarı, peşinat, başlangıç taksiti, ödeme modeli, artış oranı, artış periyodu ve benzeri parametreleri kullanarak tahmini bir ödeme planı oluşturur.\n\n'
          'FP Engine’in amacı resmî şirket planını taklit ederek şirket adına teklif üretmek değil; kullanıcının farklı senaryoların muhtemel etkilerini görmesine yardımcı olacak standartlaştırılmış bir hesaplama yaklaşımı sunmaktır.\n\n'
          'Bu nedenle FP Engine sonucu ile herhangi bir şirketin CRM, teklif ekranı, kampanya hesabı veya resmî ödeme planı arasında farklılık görülebilir.',
    ),
    _LegalSection(
      icon: Icons.calculate_outlined,
      title: 'FP Engine Sonuçlarının Niteliği',
      body:
          'FP Engine tarafından oluşturulan finansman planları, tahmini teslim süreleri, toplam vade, ödeme takvimi ve diğer sonuçlar yalnızca bilgilendirme ve karar destek amacı taşır.\n\n'
          'Bu sonuçlar resmî teklif, sözleşme, sözleşme eki, ödeme taahhüdü, kredi tahsisi, finansman onayı, kesin teslim tarihi veya herhangi bir şirket tarafından verilmiş bağlayıcı beyan niteliğinde değildir.\n\n'
          'Kullanıcının uygulamada gördüğü sonuçlar; sisteme girdiği verilere ve Plango’nun hesaplama kurallarına göre üretilir. Kullanıcı verilerinin değişmesi, hesaplama modelinin güncellenmesi veya mevzuatın değişmesi halinde sonuçlar da değişebilir.',
    ),
    _LegalSection(
      icon: Icons.schedule_outlined,
      title: 'Tahmini Teslim Süresi',
      body:
          'Plango’da gösterilen “tahmini teslim süresi” kullanıcı tarafından girilen bilgiler ve FP Engine hesaplama yaklaşımı esas alınarak oluşturulan bir tahmindir.\n\n'
          'Tahmini teslim süresi, kullanıcıya farklı ödeme senaryolarının teslim zamanlaması üzerindeki olası etkisini göstermek amacıyla sunulur.\n\n'
          'Gerçek teslim süresi; ilgili tasarruf finansman şirketinin sözleşme şartlarına, güncel uygulamalarına, plan türüne, mevzuata, ödeme performansına, kampanya şartlarına ve operasyonel süreçlerine bağlı olabilir.\n\n'
          'Bu nedenle tahmini teslim süresi kesin hak doğuran bir tarih olarak değerlendirilmemelidir.',
    ),
    _LegalSection(
      icon: Icons.event_available_outlined,
      title: 'Tahmini Teslim Tarihi',
      body:
          'Plango ödeme planlarında gösterilebilen takvim tarihleri, hesaplama tarihinden ve tahmini teslim ayından hareketle oluşturulan yardımcı tarihlerdir.\n\n'
          'Bu tarihler ilgili şirket tarafından verilmiş kesin teslim tarihi değildir.\n\n'
          'Bir tasarruf finansman şirketinin resmî sözleşmesinde belirtilen teslim koşulları ile Plango’nun tahmini tarihi arasında farklılık olması halinde, kullanıcı ile şirket arasındaki resmî sözleşme ve yürürlükteki mevzuat esas alınır.',
    ),
    _LegalSection(
      icon: Icons.request_quote_outlined,
      title: 'Resmî Teklif ve Plango Hesaplaması Arasındaki Fark',
      body:
          'Plango hesaplaması kullanıcıya bir senaryo sunar; resmî teklif ise ilgili şirket tarafından kendi güncel ürün, kampanya, sözleşme ve operasyon kuralları çerçevesinde hazırlanır.\n\n'
          'Plango’da görülen finansman tutarı, teslim süresi, vade veya ödeme planı; ilgili şirketin aynı değerleri kullanıcıya kabul edeceği anlamına gelmez.\n\n'
          'Resmî işlem yapmak isteyen kullanıcının ilgili tasarruf finansman şirketinden güncel teklif alması ve teklif detaylarını yazılı olarak incelemesi gerekir.',
    ),
    _LegalSection(
      icon: Icons.description_outlined,
      title: 'Sözleşmelerin Önceliği',
      body:
          'Tasarruf finansmanı ilişkisinin bağlayıcı şartları kullanıcı ile ilgili tasarruf finansman şirketi arasında imzalanan sözleşme ve yürürlükteki mevzuat çerçevesinde belirlenir.\n\n'
          'Plango’da yer alan açıklama, hesaplama, içerik veya örnekler ilgili sözleşmenin hükümlerini değiştirmez.\n\n'
          'Kullanıcı; finansman tutarı, organizasyon ücreti, ödeme yükümlülüğü, teslim şartları, teminatlar, cayma ve fesih hükümleri, iade koşulları ve benzeri konularda resmî sözleşme metnini dikkatle incelemelidir.\n\n'
          'Plango ekranında bulunan bir bilgi ile şirketin geçerli sözleşmesi arasında fark bulunması halinde resmî sözleşme ve ilgili mevzuat dikkate alınmalıdır.',
    ),
    _LegalSection(
      icon: Icons.receipt_long_outlined,
      title: 'Organizasyon Ücreti ve Diğer Bedeller',
      body:
          'Plango, ilgili şirketlerin organizasyon ücreti veya başka ücretlerini şirket adına belirlemez.\n\n'
          'Ücret tutarları, ödeme şekilleri, kampanyalar, indirimler, iade koşulları ve benzeri ticari unsurlar zaman içinde değişebilir.\n\n'
          'Plango’da ücretlere ilişkin bir bilgi veya örnek yer alması halinde bu bilgi genel bilgilendirme amacı taşır. Güncel ve bağlayıcı ücret bilgisi ilgili şirketten ve resmî sözleşme belgelerinden doğrulanmalıdır.',
    ),
    _LegalSection(
      icon: Icons.payments_outlined,
      title: 'Ödeme ve Tahsilat',
      body:
          'Plango tasarruf finansmanı sözleşmesi kapsamında kullanıcıdan taksit, organizasyon ücreti, peşinat veya başka bir ödeme tahsil etmez.\n\n'
          'Plango kullanıcı adına ilgili şirkete ödeme yapmaz ve şirket adına ödeme kabul etmez.\n\n'
          'Tasarruf finansmanı sözleşmesine ilişkin tüm ödeme ve tahsilat işlemleri kullanıcı ile ilgili tasarruf finansman kuruluşu arasında yürütülmelidir.\n\n'
          'Kullanıcıların ödeme yapmadan önce hesap bilgilerini ve ödeme kanalını ilgili şirketin resmî kanallarından doğrulaması önemlidir.',
    ),
    _LegalSection(
      icon: Icons.apartment_outlined,
      title: 'Şirket Bilgileri',
      body:
          'Plango’da tasarruf finansman şirketlerine ilişkin unvan, iletişim bilgileri, internet sitesi, lisans durumu, açıklama, kampanya veya benzeri bilgiler yer alabilir.\n\n'
          'Bu bilgiler mümkün olduğunca resmî, kamuya açık veya doğrulanabilir kaynaklardan derlenmeye çalışılır.\n\n'
          'Ancak şirketlerin ürünleri, kampanyaları, ücretleri, teslim yöntemleri, organizasyon yapıları veya iletişim bilgileri zaman içinde değişebilir.\n\n'
          'Kullanıcılar nihai karar öncesinde ilgili şirketin güncel bilgilerini resmî kanallarından doğrulamalıdır.',
    ),
    _LegalSection(
      icon: Icons.verified_outlined,
      title: 'Lisans ve Yetkilendirme Bilgileri',
      body:
          'Bir tasarruf finansman şirketinin faaliyet izni veya yetkilendirme durumuna ilişkin bilgi sunulması halinde Plango, mümkün olduğunca yetkili kurumların güncel kayıtlarını esas almayı hedefler.\n\n'
          'Bununla birlikte Plango resmî sicil veya düzenleyici kurum değildir.\n\n'
          'Faaliyet izni, lisans veya kuruluş statüsü hakkında bağlayıcı bilgi gerektiğinde Bankacılık Düzenleme ve Denetleme Kurumunun güncel listeleri ve resmî kararları esas alınmalıdır.',
    ),
    _LegalSection(
      icon: Icons.workspace_premium_outlined,
      title: 'Doğrulanmış Uzman Sistemi',
      body:
          'Plango’da yer alan uzman profilleri, platform tarafından belirlenen doğrulama ve onay süreçlerinden geçmiş sektör profesyonellerini ifade eder.\n\n'
          '“Doğrulanmış uzman” ibaresi, ilgili kişinin Plango tarafından belirlenen doğrulama kriterlerinden geçtiğini gösterir; devlet tarafından verilmiş bir mesleki yeterlilik belgesi, bağımsız lisans veya Plango tarafından verilen performans garantisi anlamına gelmez.\n\n'
          'Bir uzmanın Plango’da yer alması, o uzmanın diğer uzmanlardan daha iyi olduğu veya kullanıcı için kesin olarak uygun olduğu anlamına gelmez.',
    ),
    _LegalSection(
      icon: Icons.record_voice_over_outlined,
      title: 'Uzman Görüşlerinin Niteliği',
      body:
          'Uzmanların kullanıcılarla paylaştığı açıklamalar, yorumlar, öneriler ve şirket bilgileri ilgili uzmanın kendi mesleki değerlendirmesi kapsamında olabilir.\n\n'
          'Plango, uzmanların her görüşünü önceden onayladığını veya garanti ettiğini kabul etmez.\n\n'
          'Kullanıcıların uzmanlardan aldıkları önemli bilgileri resmî şirket belgeleri ve sözleşmeler üzerinden doğrulaması önerilir.\n\n'
          'Kullanıcı ile uzman veya uzman tarafından temsil edilen şirket arasında kurulabilecek ticari ilişkinin tarafı Plango değildir.',
    ),
    _LegalSection(
      icon: Icons.support_agent_outlined,
      title: 'Danışma Talebi',
      body:
          'Plango’nun danışma özelliği, kullanıcının tasarruf finansmanı hakkında bilgi almak üzere uygun bir uzmanla iletişim kurmasını kolaylaştırmayı amaçlar.\n\n'
          'Danışma talebi göndermek finansman başvurusu, ön onay, sözleşme veya satın alma işlemi değildir.\n\n'
          'Danışma talebinin kabul edilmesi de kullanıcının herhangi bir finansman hakkı kazandığı veya bir şirket tarafından onaylandığı anlamına gelmez.',
    ),
    _LegalSection(
      icon: Icons.security_outlined,
      title: 'Kişisel İletişim ve Kullanıcı Güvenliği',
      body:
          'Kullanıcıların uzmanlarla veya şirketlerle iletişim sırasında kişisel ve finansal bilgilerini paylaşırken dikkatli olması gerekir.\n\n'
          'Plango üzerinden iletişim kurulmuş olması, kullanıcının kimlik belgesi, parola, doğrulama kodu, banka şifresi veya benzeri hassas güvenlik bilgilerini paylaşması gerektiği anlamına gelmez.\n\n'
          'Plango, kullanıcıların şüpheli taleplerde ilgili kişi veya şirketin kimliğini resmî kanallardan doğrulamasını önerir.',
    ),
    _LegalSection(
      icon: Icons.edit_note_outlined,
      title: 'Kullanıcı Tarafından Girilen Veriler',
      body:
          'FP Engine ve diğer planlama araçlarının ürettiği sonuçlar, kullanıcı tarafından girilen bilgilere bağlıdır.\n\n'
          'Yanlış, eksik, güncel olmayan veya hatalı girilmiş finansman tutarı, peşinat, taksit veya diğer değerler tahmini sonuçların da hatalı veya yanıltıcı olmasına neden olabilir.\n\n'
          'Kullanıcı uygulamaya girdiği verilerin doğruluğunu kontrol etmekten sorumludur.',
    ),
    _LegalSection(
      icon: Icons.bookmark_outline_rounded,
      title: 'Kayıtlı Planlar',
      body:
          'Kullanıcıların Plango’da kaydettiği planlar, daha sonra görüntülenmek üzere saklanan hesaplama kayıtlarıdır.\n\n'
          'Kayıtlı bir planın bulunması, ilgili şirket tarafından planın kabul edildiği veya fiyat, teslim tarihi ya da ödeme koşullarının garanti edildiği anlamına gelmez.\n\n'
          'Kayıtlı planlar, kullanıcının kendi değerlendirme ve karşılaştırma sürecinde yardımcı kayıt niteliğindedir.',
    ),
    _LegalSection(
      icon: Icons.picture_as_pdf_outlined,
      title: 'PDF ve Dışa Aktarılan Planlar',
      body:
          'Plango tarafından oluşturulan PDF veya benzeri plan çıktıları kullanıcıya hesaplama sonuçlarını düzenli biçimde sunmak amacıyla hazırlanır.\n\n'
          'Bu belgeler resmî teklif, sözleşme, şirket belgesi, fatura, ödeme emri veya finansman taahhüdü değildir.\n\n'
          'PDF içerisinde yer alan tahmini değerler, belgenin oluşturulduğu andaki kullanıcı girdileri ve FP Engine hesaplamasına dayanır.',
    ),
    _LegalSection(
      icon: Icons.compare_outlined,
      title: 'Karşılaştırma ve Değerlendirme İçerikleri',
      body:
          'Plango’da farklı seçenekleri anlamayı kolaylaştıran karşılaştırmalı içerikler yer alabilir.\n\n'
          'Bu tür karşılaştırmalar, kullanıcının kendi araştırmasını desteklemek amacıyla sunulur ve evrensel bir “en iyi şirket”, “en iyi plan” veya “en iyi uzman” sonucu oluşturmayı amaçlamaz.\n\n'
          'Bir seçenek bir kullanıcı için uygunken başka bir kullanıcı için uygun olmayabilir. Nihai seçim kişisel ihtiyaç ve koşullara göre yapılmalıdır.',
    ),
    _LegalSection(
      icon: Icons.article_outlined,
      title: 'Öne Çıkanlar, Haberler ve Bilgilendirici İçerikler',
      body:
          'Plango içerisinde mevzuat, sektör, şirketler veya tasarruf finansmanı hakkında bilgilendirici içerikler yayımlanabilir.\n\n'
          'Bu içerikler yayımlandıkları tarihte mevcut olan bilgilere göre hazırlanabilir ve daha sonra güncelliğini yitirebilir.\n\n'
          'İçeriklerin amacı genel bilgi sağlamaktır. Resmî veya bağlayıcı bilgi için yetkili kurumların ve ilgili kuruluşların güncel açıklamalarına başvurulmalıdır.',
    ),
    _LegalSection(
      icon: Icons.campaign_outlined,
      title: 'Reklam, Sponsorluk ve Ticari İçerik',
      body:
          'Plango ileride reklam, sponsorluk veya ticari iş birliği içeren içerikler sunabilir.\n\n'
          'Böyle bir durumda kullanıcı algısını etkileyebilecek ticari içeriklerin mümkün olduğunca açık biçimde ayırt edilmesi hedeflenir.\n\n'
          'Ticari iş birliğinin bulunması, FP Engine hesaplama sonucunun veya Plango’nun bağımsız karar destek mantığının ilgili şirket lehine değiştirilmesi gerektiği anlamına gelmez.',
    ),
    _LegalSection(
      icon: Icons.balance_rounded,
      title: 'Hukuki Danışmanlık Değildir',
      body:
          'Plango’da sunulan bilgiler genel bilgilendirme amaçlıdır ve kişiye özel hukuki danışmanlık hizmeti değildir.\n\n'
          'Bir kullanıcının sözleşmesi, cayma veya fesih hakkı, icra süreci, uyuşmazlığı veya başka bir hukuki durumu somut olayın özelliklerine göre farklı değerlendirilebilir.\n\n'
          'Kullanıcı özel hukuki durumunda bağlayıcı görüşe ihtiyaç duyuyorsa yetkili bir hukuk profesyonelinden destek almalıdır.',
    ),
    _LegalSection(
      icon: Icons.query_stats_outlined,
      title: 'Finansal veya Yatırım Danışmanlığı Değildir',
      body:
          'Plango’nun hesaplama ve bilgilendirme araçları kişiye özel yatırım danışmanlığı, portföy yönetimi veya finansal danışmanlık hizmeti olarak sunulmaz.\n\n'
          'Plango kullanıcıya belirli bir yatırım aracını satın alma, satma veya elde tutma önerisi sunmayı amaçlamaz.\n\n'
          'Tasarruf finansmanı planına katılma kararı kullanıcı tarafından kendi mali durumu ve ihtiyaçları değerlendirilerek verilmelidir.',
    ),
    _LegalSection(
      icon: Icons.person_outline_rounded,
      title: 'Kullanıcının Karar Sorumluluğu',
      body:
          'Plango kullanıcı adına finansal veya hukuki karar vermez.\n\n'
          'Kullanıcının bir şirkete başvurması, sözleşme imzalaması, plan seçmesi, ödeme yapması veya başka bir işlem gerçekleştirmesi kendi iradesiyle verdiği karardır.\n\n'
          'Plango’nun amacı bu kararın daha fazla bilgiyle ve daha anlaşılır bir değerlendirme ortamında verilmesine yardımcı olmaktır.',
    ),
    _LegalSection(
      icon: Icons.update_outlined,
      title: 'Bilgilerin Güncelliği',
      body:
          'Tasarruf finansmanı mevzuatı, şirket uygulamaları, kampanyalar, ürün koşulları ve sektör standartları zaman içerisinde değişebilir.\n\n'
          'Plango içeriklerini ve hesaplama kurallarını güncel gelişmelere göre geliştirmeyi hedefler; ancak tüm bilgilerin her an eksiksiz ve güncel olduğu garanti edilemez.\n\n'
          'Kullanıcıların önemli kararlar öncesinde bilgileri resmî kaynaklardan kontrol etmesi gerekir.',
    ),
    _LegalSection(
      icon: Icons.cloud_off_outlined,
      title: 'Teknik Kesintiler ve Sistem Erişimi',
      body:
          'Plango internet bağlantısı, üçüncü taraf servisler, bakım çalışmaları, yazılım güncellemeleri veya teknik arızalar nedeniyle geçici olarak kullanılamayabilir.\n\n'
          'Plango hizmetlerin kesintisiz veya hatasız olacağını mutlak şekilde garanti etmez.\n\n'
          'Teknik sorunlar nedeniyle bir planın geçici olarak görüntülenememesi, ilgili kullanıcının şirketle yaptığı resmî sözleşmeyi veya haklarını değiştirmez.',
    ),
    _LegalSection(
      icon: Icons.open_in_new_outlined,
      title: 'Üçüncü Taraf Bağlantılar',
      body:
          'Plango, kullanıcıyı şirketlerin, kamu kurumlarının veya diğer üçüncü tarafların internet sayfalarına yönlendiren bağlantılar içerebilir.\n\n'
          'Üçüncü taraf sitelerin içerikleri, güvenlik uygulamaları, gizlilik politikaları ve hizmetleri Plango’nun kontrolü dışında olabilir.\n\n'
          'Kullanıcı üçüncü taraf bir siteye geçtiğinde ilgili sitenin kendi koşul ve politikalarının geçerli olabileceğini bilmelidir.',
    ),
    _LegalSection(
      icon: Icons.copyright_outlined,
      title: 'Marka, Logo ve Ticaret Unvanları',
      body:
          'Plango’da adı geçen şirketlerin marka adları, logoları, ticaret unvanları ve diğer fikri mülkiyet unsurları ilgili hak sahiplerine aittir.\n\n'
          'Bu unsurların platformda bilgilendirme amacıyla kullanılması, ilgili kuruluşun Plango’yu onayladığı, desteklediği veya Plango ile ortaklık yaptığı anlamına gelmez.\n\n'
          'Plango’ya ait isim, logo, özgün tasarım, yazılım, FP Engine yapısı ve özgün içerikler üzerindeki haklar ilgili hak sahiplerine aittir.',
    ),
    _LegalSection(
      icon: Icons.block_outlined,
      title: 'Kötüye Kullanım ve Yanıltıcı Kullanım',
      body:
          'Plango tarafından üretilen hesaplama, ekran görüntüsü veya PDF çıktısının değiştirilerek resmî şirket teklifi, garanti belgesi veya kesin teslim taahhüdü gibi gösterilmesi Plango’nun kullanım amacıyla bağdaşmaz.\n\n'
          'Kullanıcılar ve uzmanlar, Plango içeriklerini üçüncü kişileri yanıltacak biçimde kullanmamalıdır.\n\n'
          'Platformun güvenliğini, diğer kullanıcıları veya Plango’nun bağımsızlığını tehdit eden kötüye kullanım durumlarında ilgili hesaplar hakkında gerekli teknik veya idari önlemler alınabilir.',
    ),
    _LegalSection(
      icon: Icons.report_problem_outlined,
      title: 'Hata ve Eksiklik Bildirimi',
      body:
          'Plango’da yer alan bir bilgi, şirket profili, içerik, hesaplama açıklaması veya başka bir verinin hatalı, eksik ya da güncelliğini yitirmiş olduğunu düşünüyorsanız uygulamadaki Şikayet ve Öneri kanalı üzerinden bildirimde bulunabilirsiniz.\n\n'
          'Plango, doğrulanabilir geri bildirimleri inceleyerek gerekli gördüğü düzeltme ve güncellemeleri yapmayı hedefler.\n\n'
          'Hata bildirimi mekanizması, platformun şeffaflık ve sürekli gelişim yaklaşımının bir parçasıdır.',
    ),
    _LegalSection(
      icon: Icons.policy_outlined,
      title: 'Yasal Metinlerin Güncellenmesi',
      body:
          'Plango’nun işlevleri, mevzuat, teknik altyapı veya hizmet kapsamı zaman içinde değişebilir.\n\n'
          'Bu nedenle Yasal Bilgilendirme metni ve diğer kurumsal metinler gerektiğinde güncellenebilir.\n\n'
          'Önemli değişikliklerde kullanıcıların güncel metni inceleyebilmesini sağlayacak uygulama içi yöntemler kullanılabilir.\n\n'
          'Bir sözleşmenin ayrıca kullanıcı onayı gerektirdiği durumlar, ilgili sözleşmenin kendi kabul süreci kapsamında ele alınır.',
    ),
    _LegalSection(
      icon: Icons.info_outline_rounded,
      title: 'Son Bilgilendirme',
      body:
          'Plango bilgi sunar, hesaplama yapar ve kullanıcının seçenekleri daha anlaşılır biçimde değerlendirmesine yardımcı olur.\n\n'
          'Plango’nun sunduğu tahmini hesaplamalar resmî şirket planlarının veya sözleşmelerinin yerine geçmez.\n\n'
          'Resmî finansman planı, organizasyon ücreti, ödeme yükümlülüğü, teslim koşulları, teslim tarihi ve diğer bağlayıcı hükümler ilgili tasarruf finansman şirketi ile kullanıcı arasındaki resmî süreçte belirlenir.\n\n'
          'Nihai karar vermeden önce ilgili şirketin güncel teklifinin, sözleşme hükümlerinin ve yürürlükteki mevzuatın incelenmesi önerilir.',
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
          'Yasal Bilgilendirme',
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
            const _LegalHeroCard(),
            const SizedBox(height: 16),
            const _LegalIntroCard(),
            const SizedBox(height: 16),
            const _SectionLabel(),
            const SizedBox(height: 10),
            ...List.generate(_sections.length, (index) {
              final section = _sections[index];
              final isOpen = _openIndex == index;
              return _LegalAccordionCard(
                number: index + 1,
                section: section,
                isOpen: isOpen,
                onTap: () => setState(() => _openIndex = isOpen ? null : index),
              );
            }),
            const SizedBox(height: 6),
            const _LegalFooterCard(),
            const SizedBox(height: 12),
            const _DocumentNotice(),
          ],
        ),
      ),
    );
  }
}

class _LegalHeroCard extends StatelessWidget {
  const _LegalHeroCard();

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
            _LegalInformationScreenState._navy,
            _LegalInformationScreenState._petrol,
            Color(0xFF0C6268),
            _LegalInformationScreenState._teal,
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
      child: Stack(
        children: [
          Positioned(
            right: -24,
            top: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(.055),
              ),
            ),
          ),
          Positioned(
            right: 24,
            bottom: -52,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _LegalInformationScreenState._turquoise.withOpacity(.10),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _LegalInformationScreenState._turquoise.withOpacity(.16),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF55E2D0).withOpacity(.28),
                  ),
                ),
                child: const Icon(
                  Icons.gavel_rounded,
                  color: Color(0xFF55E2D0),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Yasal Bilgilendirme',
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
                      'Plango’nun konumu, bağımsızlık ilkesi, FP Engine, şirket ve '
                      'uzman içerikleri ile kullanıcıların dikkat etmesi gereken '
                      'temel esaslar hakkında kapsamlı açıklamalar.',
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
        ],
      ),
    );
  }
}

class _LegalIntroCard extends StatelessWidget {
  const _LegalIntroCard();

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
            color: _LegalInformationScreenState._teal,
            size: 21,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Plango bağımsız ve tarafsız bir karar destek platformudur. '
              'Uygulamada sunulan hesaplamalar, tahminler ve bilgilendirmeler '
              'resmî teklif, sözleşme, finansman onayı veya teslim taahhüdü değildir.',
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
        Icon(Icons.menu_book_outlined, color: _LegalInformationScreenState._teal, size: 18),
        SizedBox(width: 7),
        Text(
          'Ayrıntılı Bilgilendirme',
          style: TextStyle(
            color: _LegalInformationScreenState._navy,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

class _LegalAccordionCard extends StatelessWidget {
  const _LegalAccordionCard({
    required this.number,
    required this.section,
    required this.isOpen,
    required this.onTap,
  });

  final int number;
  final _LegalSection section;
  final bool isOpen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOpen
              ? _LegalInformationScreenState._teal.withOpacity(.30)
              : _LegalInformationScreenState._border,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B2239).withOpacity(isOpen ? .065 : .032),
            blurRadius: isOpen ? 18 : 11,
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
                            _LegalInformationScreenState._teal.withOpacity(.14),
                            _LegalInformationScreenState._turquoise.withOpacity(.10),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        section.icon,
                        color: _LegalInformationScreenState._teal,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '$number. ${section.title}',
                        style: const TextStyle(
                          color: _LegalInformationScreenState._navy,
                          fontSize: 13.8,
                          height: 1.28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: isOpen ? .5 : 0,
                      duration: const Duration(milliseconds: 220),
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
                        color: _LegalInformationScreenState._muted,
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

class _LegalFooterCard extends StatelessWidget {
  const _LegalFooterCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
      decoration: BoxDecoration(
        color: _LegalInformationScreenState._navy,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFF55E2D0), size: 21),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Nihai karar vermeden önce ilgili tasarruf finansman kuruluşunun '
              'güncel teklifini, sözleşme hükümlerini ve yürürlükteki resmî '
              'düzenlemeleri incelemeniz önerilir.',
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

class _DocumentNotice extends StatelessWidget {
  const _DocumentNotice();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        child: Text(
          'Bu ekran genel bilgilendirme amacıyla hazırlanmıştır. '
          'Kişiye özel hukuki veya finansal danışmanlık hizmeti değildir.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF8A96A3),
            fontSize: 10.5,
            height: 1.45,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _LegalSection {
  const _LegalSection({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}
