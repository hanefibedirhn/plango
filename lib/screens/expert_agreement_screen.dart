import 'package:flutter/material.dart';

class ExpertAgreementScreen extends StatefulWidget {
  const ExpertAgreementScreen({super.key});

  @override
  State<ExpertAgreementScreen> createState() =>
      _ExpertAgreementScreenState();
}

class _ExpertAgreementScreenState extends State<ExpertAgreementScreen> {
  static const Color _navy = Color(0xFF0B2239);
  static const Color _petrol = Color(0xFF052F3D);
  static const Color _teal = Color(0xFF087C72);
  static const Color _turquoise = Color(0xFF16C7B0);
  static const Color _background = Color(0xFFF7F9FB);
  static const Color _muted = Color(0xFF748193);
  static const Color _border = Color(0xFFE4EBEE);

  int? _openIndex;

  final List<_ExpertAgreementSection> _sections = const [
    _ExpertAgreementSection(
      icon: Icons.handshake_outlined,
      title: 'Taraflar',
      body:
          'İşbu Uzman Sözleşmesi, Tasarruf Planım dijital platformunda uzman olarak başvuru yapan ve uzman hesabı kullanmaya hak kazanan gerçek kişi ile Tasarruf Planım hizmetinin sağlayıcısı arasında elektronik ortamda kurulur.\n\n'
          'Bu sözleşmede “Uzman”, Tasarruf Planım’ın uzman başvuru ve doğrulama süreçlerini tamamlayan ve uzman rolü verilen kişiyi; “Tasarruf Planım” ise tasarruf finansmanı alanında hesaplama, bilgilendirme, danışma yönlendirmesi ve karar destek hizmetleri sunan dijital platformu ifade eder.\n\n'
          'Tasarruf Planım ile uzman başvurusu, doğrulama ve sözleşmeye ilişkin genel iletişim için info@tasarrufplanim.com; uzman hesabı, giriş, hesap güvenliği ve teknik destek talepleri için destek@tasarrufplanim.com adresleri kullanılabilir. Varsa ticari unvan, resmî adres ve diğer zorunlu bilgiler hukuki yapının kesinleşmesiyle ayrıca güncel şekilde yayımlanır.',
    ),
    _ExpertAgreementSection(
      icon: Icons.description_outlined,
      title: 'Sözleşmenin Konusu',
      body:
          'Bu sözleşmenin konusu; uzman başvurusu, uzman doğrulaması, uzman hesabının kullanımı, danışma taleplerinin otomatik atanması, kullanıcılarla iletişim, uzman yükümlülükleri ve Tasarruf Planım uzman sisteminin kullanım esaslarının belirlenmesidir.\n\n'
          'Sözleşme, uzman ile kullanıcının veya uzman tarafından temsil edilen tasarruf finansman şirketinin arasında kurulabilecek bağımsız ticari ilişkinin şartlarını düzenlemez.\n\n'
          'Tasarruf Planım, uzman ile kullanıcı arasındaki iletişimi kolaylaştıran ve danışma taleplerinin platform üzerinden yönetilmesini sağlayan bağımsız dijital aracı konumundadır.',
    ),
    _ExpertAgreementSection(
      icon: Icons.menu_book_outlined,
      title: 'Tanımlar',
      body:
          'Uzman Başvurusu: Kullanıcının Tasarruf Planım’da uzman rolü elde etmek amacıyla gerçekleştirdiği başvuru sürecidir.\n\n'
          'Doğrulanmış Uzman: Tasarruf Planım’ın belirlediği doğrulama kriterlerini karşılayan ve uzman hesabı onaylanan kişidir.\n\n'
          'Danışma Talebi: Kullanıcının tasarruf finansmanı hakkında bilgi almak amacıyla Tasarruf Planım üzerinden oluşturduğu talep kaydıdır.\n\n'
          'Otomatik Uzman Ataması: Kullanıcının belirli bir uzmanı seçmediği, uygunluk ve sistem kurallarına göre danışma talebinin Tasarruf Planım tarafından uygun uzmana yönlendirildiği atama yöntemidir.\n\n'
          'Uzman Paneli: Uzmanın kendisine atanan talepleri ve uzman işlemlerini yönettiği uygulama alanıdır.',
    ),
    _ExpertAgreementSection(
      icon: Icons.person_add_alt_1_outlined,
      title: 'Uzman Başvurusunun Niteliği',
      body:
          'Uzman başvurusu, Tasarruf Planım’da uzman hesabı kullanabilmek amacıyla yapılan platform içi başvurudur.\n\n'
          'Başvuru yapılması uzman statüsünün otomatik olarak kazanıldığı anlamına gelmez.\n\n'
          'Tasarruf Planım, uzman başvurusunu doğrulama, güvenlik, uygunluk ve platform standartları bakımından inceleyebilir ve başvuruyu onaylayabilir veya reddedebilir.',
    ),
    _ExpertAgreementSection(
      icon: Icons.fact_check_outlined,
      title: 'Uzman Başvurusunda Doğru Bilgi Verme',
      body:
          'Uzman; adı, soyadı, iletişim bilgileri, çalıştığı kurum, şehir ve başvuru kapsamında verdiği diğer bilgilerin doğru, güncel ve kendisine ait olduğunu beyan eder.\n\n'
          'Yanlış, yanıltıcı veya başkasına ait bilgiyle yapılan başvurular reddedilebilir.\n\n'
          'Uzmanlık statüsü kazanıldıktan sonra ilgili bilgilerde önemli bir değişiklik olması halinde uzmanın bu bilgileri güncellemesi veya Tasarruf Planım’a bildirmesi beklenir.',
    ),
    _ExpertAgreementSection(
      icon: Icons.verified_user_outlined,
      title: 'Uzman Doğrulama Yöntemleri',
      body:
          'Tasarruf Planım, uzman başvurularında şirket e-posta alan adı üzerinden doğrulama, doğrulama kodu, yönetici incelemesi veya platform tarafından uygun görülen diğer yöntemleri kullanabilir.\n\n'
          'Doğrulama süreci, uzmanın beyan ettiği kurum bağlantısını veya uzmanlık statüsünü makul ölçüde doğrulamayı amaçlar.\n\n'
          'Tasarruf Planım, doğrulama yöntemlerini güvenlik ihtiyaçları ve sektör koşullarına göre güncelleyebilir.',
    ),
    _ExpertAgreementSection(
      icon: Icons.domain_verification_outlined,
      title: 'Doğrulamanın Sınırı',
      body:
          'Tasarruf Planım’da doğrulanmış uzman olarak görünmek, uzmanın tüm beyanlarının veya gelecekteki davranışlarının Tasarruf Planım tarafından garanti edildiği anlamına gelmez.\n\n'
          'Doğrulama, Tasarruf Planım’ın belirlediği kriterlerin yerine getirildiğini gösterir.\n\n'
          'Bu statü; kamu kurumu tarafından verilmiş mesleki ruhsat, devlet garantisi veya bağımsız yeterlilik belgesi anlamına gelmez.',
    ),
    _ExpertAgreementSection(
      icon: Icons.workspace_premium_outlined,
      title: 'Uzman Rolünün Verilmesi',
      body:
          'Başvurusu onaylanan kullanıcıya sistem üzerinde uzman rolü tanımlanabilir.\n\n'
          'Uzman rolü, Tasarruf Planım’ın normal kullanıcı özelliklerinin yanı sıra uzman paneline ve danışma talebi yönetimiyle ilgili yetkili alanlara erişim sağlayabilir.\n\n'
          'Uzman rolü yalnızca ilgili kişiye aittir ve üçüncü kişilere devredilemez.',
    ),
    _ExpertAgreementSection(
      icon: Icons.person_outline_rounded,
      title: 'Uzman Hesabının Kişisel Kullanımı',
      body:
          'Uzman hesabı kişiseldir.\n\n'
          'Hesabın başka kişilerle paylaşılması, devredilmesi, kiralanması veya başka bir kişi tarafından uzman adına kullanılması yasaktır.\n\n'
          'Uzman, hesabı üzerinden gerçekleştirilen işlemlerin güvenliğini sağlamakla yükümlüdür.',
    ),
    _ExpertAgreementSection(
      icon: Icons.lock_outline_rounded,
      title: 'Hesap Güvenliği',
      body:
          'Uzman, parolasını ve doğrulama bilgilerini korumalıdır.\n\n'
          'Şirket e-posta hesabı, doğrulama kodu veya Tasarruf Planım giriş bilgileri üçüncü kişilerle paylaşılmamalıdır.\n\n'
          'Hesap güvenliğinin ihlal edildiği şüphesinde uzman gerekli güvenlik adımlarını uygulamalı ve mümkün olan en kısa sürede Tasarruf Planım’a bildirimde bulunmalıdır.',
    ),
    _ExpertAgreementSection(
      icon: Icons.alt_route_outlined,
      title: 'Otomatik Uzman Atama Sistemi',
      body:
          'Tasarruf Planım’ın danışma sisteminde kullanıcı belirli bir uzmanı seçmek zorunda değildir.\n\n'
          'Kullanıcı tarafından oluşturulan danışma talebi, platformun güncel atama kuralları çerçevesinde uygun uzmana otomatik olarak yönlendirilebilir.\n\n'
          'Atama; uzman uygunluğu, talep durumu, şirket bağlantısı, operasyonel sıra veya Tasarruf Planım tarafından belirlenen diğer sistemsel kriterler dikkate alınarak gerçekleştirilebilir.',
    ),
    _ExpertAgreementSection(
      icon: Icons.task_alt_outlined,
      title: 'Atanan Talebin Kabulü',
      body:
          'Uzman, kendisine yönlendirilen danışma talebini uzman paneli üzerinden değerlendirebilir.\n\n'
          'Talebin kabul edilmesi, uzmanın ilgili kullanıcıyla danışma sürecini yürütmeyi üstlendiğini gösterir.\n\n'
          'Uzman, kabul ettiği talepleri makul süre içinde ele almak ve kullanıcıyı gereksiz şekilde bekletmemek için özen göstermelidir.',
    ),
    _ExpertAgreementSection(
      icon: Icons.cancel_outlined,
      title: 'Atanan Talebin Reddedilmesi',
      body:
          'Uzman, uygun olmadığı veya talebi sağlıklı biçimde yürütemeyeceği durumlarda kendisine yönlendirilen danışma talebini reddedebilir.\n\n'
          'Red işlemi varsa sistemde sunulan uygun neden seçenekleri veya açıklama alanları kullanılarak yapılmalıdır.\n\n'
          'Uzmanın sürekli veya sistematik biçimde gerekçesiz red vermesi, uzman performansı ve atama uygunluğu bakımından değerlendirilebilir.',
    ),
    _ExpertAgreementSection(
      icon: Icons.sync_alt_outlined,
      title: 'Talebin Yeniden Atanması',
      body:
          'Bir uzman tarafından kabul edilmeyen veya belirli süre içinde işleme alınmayan danışma talebi, sistemin güncel kurallarına göre başka bir uygun uzmana yönlendirilebilir.\n\n'
          'Bu mekanizmanın amacı, kullanıcının tek bir uzmana bağımlı kalmasını önlemek ve danışma taleplerinin makul sürede yanıtlanmasını sağlamaktır.\n\n'
          'Uzman, belirli bir danışma talebinin kendisine kalıcı olarak ait olduğunu ileri süremez.',
    ),
    _ExpertAgreementSection(
      icon: Icons.rule_folder_outlined,
      title: 'Talep Durumlarının Doğru Yönetimi',
      body:
          'Uzman, bekleyen, kabul edilen, reddedilen, iletişime geçilen, tamamlanan veya süresi dolan taleplerin durumlarını gerçek sürece uygun biçimde güncellemelidir.\n\n'
          'Gerçekte iletişime geçilmemiş bir talebi “iletişime geçildi” olarak işaretlemek veya tamamlanmamış bir görüşmeyi tamamlanmış göstermek yasaktır.\n\n'
          'Talep durumlarının doğruluğu, kullanıcı deneyimi ve platform güvenilirliği açısından temel bir yükümlülüktür.',
    ),
    _ExpertAgreementSection(
      icon: Icons.phone_in_talk_outlined,
      title: 'Kullanıcıyla İlk İletişim',
      body:
          'Uzman, danışma talebi kapsamında kullanıcıyla ilk iletişimde kendisini ve çalıştığı kurumu açık biçimde tanıtmalıdır.\n\n'
          'Uzman, kullanıcının Tasarruf Planım üzerinden bir danışma talebi oluşturduğunu belirtmeli ve iletişimin amacını net şekilde açıklamalıdır.\n\n'
          'Kullanıcı üzerinde baskı kuran, yanıltıcı veya agresif satış dili kullanılamaz.',
    ),
    _ExpertAgreementSection(
      icon: Icons.contact_phone_outlined,
      title: 'İletişim Bilgilerine Erişim',
      body:
          'Kullanıcının telefon veya e-posta gibi iletişim bilgileri yalnızca ilgili danışma sürecinin gerektirdiği aşamada ve yetkilendirme kuralları çerçevesinde uzmana açılabilir.\n\n'
          'Uzman bu bilgileri yalnızca danışma talebinin yürütülmesi amacıyla kullanabilir.\n\n'
          'Kullanıcının iletişim bilgileri başka uzmanlara, şirket çalışanlarına veya üçüncü kişilere yetkisiz şekilde aktarılamaz.',
    ),
    _ExpertAgreementSection(
      icon: Icons.workspace_premium_outlined,
      title: 'Mesleki Özen Yükümlülüğü',
      body:
          'Uzman, kullanıcıya bilgi verirken mesleki özen göstermelidir.\n\n'
          'Bilmediği veya doğrulayamadığı bir konuyu kesin bilgi gibi sunmamalıdır.\n\n'
          'Mevzuat, kampanya, teslim koşulu veya şirket uygulaması gibi değişebilecek konularda mümkün olduğunca güncel ve doğrulanabilir bilgi kullanılmalıdır.',
    ),
    _ExpertAgreementSection(
      icon: Icons.verified_outlined,
      title: 'Doğru ve Dürüst Bilgilendirme',
      body:
          'Uzman, kullanıcıya verdiği bilgilerin yanıltıcı olmamasını sağlamakla yükümlüdür.\n\n'
          'Finansman, teslim, ödeme, organizasyon ücreti, kampanya veya sözleşme koşulları hakkında gerçek dışı vaat verilemez.\n\n'
          'Kullanıcıya şirketin resmî olarak vermediği bir garanti veya kesin teslim taahhüdü sunulamaz.',
    ),
    _ExpertAgreementSection(
      icon: Icons.warning_amber_rounded,
      title: 'Kesin Sonuç veya Garanti Yasağı',
      body:
          'Uzman, kullanıcının kesin olarak finansman alacağını, kesin tarihte teslim yapılacağını veya belirli bir planın mutlaka onaylanacağını garanti edemez.\n\n'
          'Resmî süreçler ilgili tasarruf finansman şirketinin sözleşme, operasyon ve mevzuat kuralları çerçevesinde yürütülür.\n\n'
          'Uzman, kişisel yorum ile resmî şirket bilgisini birbirinden ayırmalıdır.',
    ),
    _ExpertAgreementSection(
      icon: Icons.calculate_outlined,
      title: 'FP Engine Sonuçları Hakkında İletişim',
      body:
          'Uzman, kullanıcının Tasarruf Planım FP Engine üzerinden oluşturduğu tahmini hesaplamaları görebildiği veya bu hesaplamalar hakkında görüşme yaptığı durumlarda, sonuçların bilgilendirme amaçlı olduğunu dikkate almalıdır.\n\n'
          'FP Engine sonucu şirketin resmî teklifine dönüştürülemez veya kullanıcıya resmî şirket sonucu gibi sunulamaz.\n\n'
          'Uzman, şirketin güncel ve bağlayıcı teklifini kendi resmî süreçleri üzerinden ayrıca açıklamalıdır.',
    ),
    _ExpertAgreementSection(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Kullanıcı Plan Bilgilerinin Kullanımı',
      body:
          'Danışma talebiyle paylaşılan finansman tutarı, peşinat, taksit, vade veya benzeri plan bilgileri yalnızca ilgili danışma sürecinin yürütülmesi amacıyla kullanılabilir.\n\n'
          'Uzman bu verileri kullanıcıdan habersiz şekilde başka satış listelerine, kişisel veri tabanlarına veya farklı ticari amaçlara aktaramaz.\n\n'
          'Plan verileri, kullanıcıya daha uygun ve doğru bilgi sunulması amacıyla değerlendirilmelidir.',
    ),
    _ExpertAgreementSection(
      icon: Icons.forum_outlined,
      title: 'Kullanıcıya Saygılı İletişim',
      body:
          'Uzman kullanıcıyla iletişiminde saygılı, açık ve profesyonel olmalıdır.\n\n'
          'Hakaret, tehdit, küçümseme, baskı veya ayrımcı dil kullanılamaz.\n\n'
          'Kullanıcının danışma sürecini sonlandırma isteğine saygı gösterilmelidir.',
    ),
    _ExpertAgreementSection(
      icon: Icons.do_not_disturb_alt_outlined,
      title: 'Israrlı İletişim Yasağı',
      body:
          'Kullanıcı açıkça iletişim kurulmasını istemediğini belirttiğinde uzman, danışma sürecinin gerektirmediği ısrarlı arama veya mesajlaşmayı sürdürmemelidir.\n\n'
          'Tekrarlanan, rahatsız edici veya baskı oluşturan iletişim Tasarruf Planım uzman standartlarına aykırıdır.\n\n'
          'Kullanıcının iletişim tercihleri ilgili mevzuat ve kullanıcı iradesi çerçevesinde dikkate alınmalıdır.',
    ),
    _ExpertAgreementSection(
      icon: Icons.campaign_outlined,
      title: 'Ticari İletişim Sınırları',
      body:
          'Danışma talebi, uzmana sınırsız ticari iletişim hakkı vermez.\n\n'
          'Uzman, elektronik ticari ileti ve pazarlama faaliyetlerinde yürürlükteki mevzuata uygun davranmakla sorumludur.\n\n'
          'Tasarruf Planım üzerinden edinilen kullanıcı iletişim bilgileri, danışma amacı dışında bağımsız pazarlama listelerine eklenemez.',
    ),
    _ExpertAgreementSection(
      icon: Icons.open_in_new_off_outlined,
      title: 'Kullanıcıyı Tasarruf Planım Dışına Zorla Yönlendirme',
      body:
          'Uzman, danışma sürecinin doğal devamı dışında kullanıcıyı Tasarruf Planım dışındaki kişisel veya yetkisiz kanallara yönlendirmek için baskı kuramaz.\n\n'
          'Resmî şirket sürecinin gerektirdiği yönlendirmeler açık biçimde ve kullanıcıya doğru bilgi verilerek yapılabilir.\n\n'
          'Tasarruf Planım’ın danışma sistemini bilinçli şekilde etkisiz hale getirmeyi amaçlayan davranışlar platform kurallarına aykırıdır.',
    ),
    _ExpertAgreementSection(
      icon: Icons.money_off_csred_outlined,
      title: 'Kullanıcıdan Para Talep Etmeme',
      body:
          'Uzman, Tasarruf Planım danışma hizmetinin kullanılması karşılığında kullanıcıdan Tasarruf Planım adına ücret talep edemez.\n\n'
          'Tasarruf Planım adına ödeme, komisyon, ön ödeme veya benzeri tahsilat yapılamaz.\n\n'
          'Tasarruf finansman şirketiyle yapılacak resmî ödemeler yalnızca ilgili şirketin yetkili ve resmî ödeme kanalları üzerinden yürütülmelidir.',
    ),
    _ExpertAgreementSection(
      icon: Icons.no_accounts_outlined,
      title: 'Yetkisiz Belge Talebi Yasağı',
      body:
          'Uzman, danışma sürecinin amacıyla ilgisi olmayan kimlik belgesi, banka şifresi, kart şifresi, doğrulama kodu veya benzeri hassas bilgileri kullanıcıdan talep etmemelidir.\n\n'
          'Resmî şirket işlemleri için belge gerekmesi halinde kullanıcı, ilgili şirketin resmî süreçleri hakkında bilgilendirilmelidir.\n\n'
          'Tasarruf Planım üzerinden hassas güvenlik bilgisi toplanması uzman tarafından talep edilemez.',
    ),
    _ExpertAgreementSection(
      icon: Icons.privacy_tip_outlined,
      title: 'Kişisel Verilerin Gizliliği',
      body:
          'Uzman, danışma sürecinde eriştiği kişisel verileri gizli tutmakla yükümlüdür.\n\n'
          'Kullanıcının adı, iletişim bilgisi, plan bilgileri ve diğer kişisel verileri yalnızca yetkili kullanım amacı kapsamında işlenebilir.\n\n'
          'Uzman, kullanıcı verilerini yetkisiz kişilerle paylaşamaz.',
    ),
    _ExpertAgreementSection(
      icon: Icons.policy_outlined,
      title: 'KVKK Yükümlülükleri',
      body:
          'Uzman, Tasarruf Planım üzerinden eriştiği kişisel veriler bakımından kendisine düşen veri koruma yükümlülüklerine uygun davranmalıdır.\n\n'
          'Kullanıcı verilerinin danışma amacı dışında kopyalanması, aktarılması veya farklı veri tabanlarına eklenmesi yasaktır.\n\n'
          'Uzmanın kendi çalıştığı kurum adına ayrıca veri işleme yapması gereken durumlarda, ilgili şirketin hukuki ve kurumsal süreçleri ayrıca uygulanır.',
    ),
    _ExpertAgreementSection(
      icon: Icons.lock_person_outlined,
      title: 'Gizli Bilgiler',
      body:
          'Uzman, Tasarruf Planım’ın kamuya açık olmayan sistem bilgilerini, kullanıcı verilerini, danışma kayıtlarını ve uzman paneline özgü operasyonel bilgileri gizli tutmalıdır.\n\n'
          'Bu bilgiler rakip platformlara, yetkisiz kişilere veya kamuya açık kanallara izinsiz olarak aktarılamaz.\n\n'
          'Gizlilik yükümlülüğü uzman hesabı sona erdikten sonra da niteliği gereği devam edebilir.',
    ),
    _ExpertAgreementSection(
      icon: Icons.star_outline_rounded,
      title: 'Kullanıcı Değerlendirmeleri',
      body:
          'Kullanıcılar danışma deneyimi sonrasında uzmanın dönüş yapıp yapmadığı, iletişim kalitesi veya benzeri konularda değerlendirme verebilir.\n\n'
          'Uzman, kullanıcı değerlendirmelerini manipüle edemez, kullanıcıya belirli puan vermesi için baskı yapamaz.\n\n'
          'Değerlendirmeler platform kalitesinin korunması amacıyla kullanılabilir.',
    ),
    _ExpertAgreementSection(
      icon: Icons.analytics_outlined,
      title: 'Uzman Performans Verileri',
      body:
          'Tasarruf Planım; kabul edilen, reddedilen, cevaplanan, tamamlanan ve süresi dolan talepler gibi uzman performans verilerini sistemin sağlıklı çalışması amacıyla değerlendirebilir.\n\n'
          'Bu veriler otomatik atama mantığının iyileştirilmesi, kullanıcı deneyiminin korunması ve uzman hesabının uygunluğunun değerlendirilmesinde kullanılabilir.\n\n'
          'Performans değerlendirmeleri tek başına cezalandırma amacıyla değil, platform kalitesini koruma amacıyla kullanılmalıdır.',
    ),
    _ExpertAgreementSection(
      icon: Icons.gpp_bad_outlined,
      title: 'Atama Sistemini Manipüle Etmeme',
      body:
          'Uzman, otomatik atama sistemini manipüle edecek yöntemler kullanamaz.\n\n'
          'Sahte talepler oluşturmak, başka hesaplarla talep üretmek, atama sırasını yapay şekilde değiştirmek veya sistem açıklarını kullanmak yasaktır.\n\n'
          'Bu tür davranışlar uzman hesabının askıya alınmasına veya sonlandırılmasına neden olabilir.',
    ),
    _ExpertAgreementSection(
      icon: Icons.person_off_outlined,
      title: 'Sahte Kullanıcı veya Talep Oluşturma Yasağı',
      body:
          'Uzman kendi performansını artırmak, sistemde görünürlük kazanmak veya atama algoritmasını etkilemek amacıyla sahte kullanıcı hesapları veya danışma talepleri oluşturamaz.\n\n'
          'Üçüncü kişilere bu amaçla hesap veya talep oluşturtmak da aynı kapsamda değerlendirilir.\n\n'
          'Tasarruf Planım şüpheli talepleri güvenlik amacıyla inceleyebilir.',
    ),
    _ExpertAgreementSection(
      icon: Icons.record_voice_over_outlined,
      title: 'Rakip Uzmanları veya Şirketleri Kötüleme Yasağı',
      body:
          'Uzman, kullanıcıyı etkilemek amacıyla diğer uzmanlar veya tasarruf finansman şirketleri hakkında doğrulanmamış, yanıltıcı veya itibar zedeleyici beyanda bulunmamalıdır.\n\n'
          'Objektif ve doğrulanabilir karşılaştırmalar yapılabilir; ancak kötüleme veya manipülasyon amaçlı iletişim kabul edilmez.\n\n'
          'Tasarruf Planım’ın tarafsızlık yaklaşımına aykırı davranışlar uzman uygunluğu bakımından değerlendirilebilir.',
    ),
    _ExpertAgreementSection(
      icon: Icons.balance_outlined,
      title: 'Tasarruf Planım’ın Bağımsızlığına Saygı',
      body:
          'Uzman, Tasarruf Planım’ın herhangi bir tasarruf finansman şirketinin resmî uygulaması olmadığını kabul eder.\n\n'
          'Uzman kendisini Tasarruf Planım çalışanı, Tasarruf Planım adına satış yetkilisi veya Tasarruf Planım’ın resmî temsilcisi gibi tanıtamaz.\n\n'
          'Uzman, Tasarruf Planım ile kendi çalıştığı şirket arasındaki ilişkiyi kullanıcıya yanlış veya yanıltıcı biçimde aktaramaz.',
    ),
    _ExpertAgreementSection(
      icon: Icons.copyright_outlined,
      title: 'Tasarruf Planım Adı ve Markasının Kullanımı',
      body:
          'Uzman, Tasarruf Planım adını veya görsel kimliğini yalnızca platformun izin verdiği ölçüde kullanabilir.\n\n'
          'Tasarruf Planım logosu, adı veya ekran görüntüleri kullanılarak izinsiz reklam, kampanya veya ortaklık algısı oluşturulamaz.\n\n'
          'Uzmanın Tasarruf Planım’da doğrulanmış olması, Tasarruf Planım adına konuşma yetkisi vermez.',
    ),
    _ExpertAgreementSection(
      icon: Icons.badge_outlined,
      title: 'Uzman Profil Bilgileri',
      body:
          'Uzman profilinde yer alan ad, çalışılan şirket, şehir ve doğrulama durumu gibi bilgiler doğru ve güncel tutulmalıdır.\n\n'
          'Kurum değişikliği veya uzmanlık statüsünü etkileyen önemli değişiklikler Tasarruf Planım’a bildirilmelidir.\n\n'
          'Yanlış veya güncelliğini yitirmiş kurum bilgisinin bilinçli şekilde kullanılmaya devam edilmesi uzman doğrulamasının yeniden incelenmesine neden olabilir.',
    ),
    _ExpertAgreementSection(
      icon: Icons.business_center_outlined,
      title: 'Kurum Değişikliği',
      body:
          'Uzmanın çalıştığı tasarruf finansman şirketinin değişmesi halinde uzman doğrulaması yeniden değerlendirilebilir.\n\n'
          'Eski şirket bilgisiyle kullanıcılarla iletişim kurulamaz.\n\n'
          'Yeni kurum bağlantısının doğrulanması için Tasarruf Planım ek doğrulama isteyebilir.',
    ),
    _ExpertAgreementSection(
      icon: Icons.pause_circle_outline_rounded,
      title: 'Uzman Statüsünün Geçici Askıya Alınması',
      body:
          'Güvenlik şüphesi, kullanıcı şikayeti, yanlış kurum bilgisi, sistematik talep ihlali veya sözleşmeye aykırılık halinde uzman statüsü geçici olarak askıya alınabilir.\n\n'
          'Askıya alma süresince uzmana yeni danışma talebi atanmayabilir ve uzman panelindeki bazı işlevler sınırlandırılabilir.\n\n'
          'Gerekli inceleme tamamlandıktan sonra uzman statüsü yeniden aktif hale getirilebilir veya sonlandırılabilir.',
    ),
    _ExpertAgreementSection(
      icon: Icons.cancel_presentation_outlined,
      title: 'Uzman Statüsünün Sonlandırılması',
      body:
          'Ağır veya tekrarlanan sözleşme ihlali, kullanıcı verilerinin kötüye kullanılması, sahte belge veya bilgi sunulması, güvenlik ihlali veya yanıltıcı ticari davranış halinde uzman statüsü sonlandırılabilir.\n\n'
          'Uzman statüsünün sona ermesi, kullanıcının normal Tasarruf Planım hesabının her durumda otomatik olarak silineceği anlamına gelmez.\n\n'
          'Olayın niteliğine göre normal kullanıcı hesabı ayrıca değerlendirilebilir.',
    ),
    _ExpertAgreementSection(
      icon: Icons.logout_outlined,
      title: 'Uzmanın Kendi Talebiyle Ayrılması',
      body:
          'Uzman, Tasarruf Planım tarafından sunulan uygun kanal üzerinden uzman statüsünden ayrılma talebinde bulunabilir.\n\n'
          'Ayrılma talebi sırasında açık danışma talepleri varsa bu taleplerin kullanıcı mağduriyeti yaratmayacak şekilde yeniden atanması veya kapatılması sağlanabilir.\n\n'
          'Uzmanın ayrılması, gizlilik ve kişisel veri yükümlülüklerini geriye dönük olarak ortadan kaldırmaz.',
    ),
    _ExpertAgreementSection(
      icon: Icons.check_circle_outline_rounded,
      title: 'Danışma Talebinin Tamamlanması',
      body:
          'Uzman, danışma süreci gerçekten tamamlandığında talebi tamamlandı olarak işaretlemelidir.\n\n'
          'Kullanıcıyla hiçbir temas kurulmadan talebin tamamlanmış gösterilmesi yasaktır.\n\n'
          'Tamamlama durumu, platformun hizmet kalitesi ve atama sistemi bakımından veri olarak kullanılabilir.',
    ),
    _ExpertAgreementSection(
      icon: Icons.timer_off_outlined,
      title: 'Süresi Dolan Talepler',
      body:
          'Belirli süre içinde işleme alınmayan veya sonuçlandırılmayan talepler sistem tarafından süresi dolmuş olarak işaretlenebilir.\n\n'
          'Süresi dolan talepler başka bir uzmana atanabilir veya sistem kurallarına göre kapatılabilir.\n\n'
          'Uzman, süresi dolmuş bir talep üzerinde yetkisiz işlem yapmamalıdır.',
    ),
    _ExpertAgreementSection(
      icon: Icons.report_problem_outlined,
      title: 'Kullanıcı Şikayetlerinin İncelenmesi',
      body:
          'Uzman hakkında kullanıcı şikayeti oluşması halinde Tasarruf Planım ilgili talep ve sistem kayıtlarını inceleyebilir.\n\n'
          'Uzmandan açıklama veya ek bilgi istenebilir.\n\n'
          'İnceleme süreci, kullanıcı güvenliği ve uzmanın adil değerlendirilmesi ilkeleri birlikte gözetilerek yürütülmelidir.',
    ),
    _ExpertAgreementSection(
      icon: Icons.question_answer_outlined,
      title: 'Uzmanın Savunma ve Açıklama Hakkı',
      body:
          'Uzman hesabını etkileyebilecek ciddi bir değerlendirmede, olayın niteliği uygun olduğu ölçüde uzmana açıklama yapma imkanı verilebilir.\n\n'
          'Uzmanın sunduğu açıklamalar ve sistem kayıtları birlikte değerlendirilebilir.\n\n'
          'Acil güvenlik risklerinde Tasarruf Planım öncelikle geçici koruma tedbiri uygulayabilir.',
    ),
    _ExpertAgreementSection(
      icon: Icons.route_outlined,
      title: 'Tasarruf Planım’ın Uzman Atama Yetkisi',
      body:
          'Danışma taleplerinin hangi uzmana, hangi sırada ve hangi kriterlerle atanacağı Tasarruf Planım’ın güncel sistem kurallarına göre belirlenir.\n\n'
          'Uzman belirli sayıda talep, belirli kullanıcı veya belirli bir atama sırası üzerinde kazanılmış hak iddia edemez.\n\n'
          'Atama sistemi kullanıcı deneyimini, adaleti, uygunluğu ve operasyonel sürekliliği geliştirmek amacıyla güncellenebilir.',
    ),
    _ExpertAgreementSection(
      icon: Icons.inbox_outlined,
      title: 'Talep Garantisi Olmaması',
      body:
          'Uzman hesabının onaylanması belirli sayıda danışma talebi alınacağını garanti etmez.\n\n'
          'Talep sayısı kullanıcı talebi, şirket bağlantısı, şehir, uygunluk, sistem sırası ve diğer operasyonel koşullara bağlı olabilir.\n\n'
          'Tasarruf Planım uzmanlara satış, müşteri veya gelir garantisi vermez.',
    ),
    _ExpertAgreementSection(
      icon: Icons.link_off_outlined,
      title: 'Tasarruf Planım’ın Ticari İlişkinin Tarafı Olmaması',
      body:
          'Uzman ile kullanıcı arasında tasarruf finansman şirketi kapsamında sözleşme kurulması halinde bu ilişkinin tarafı Tasarruf Planım değildir.\n\n'
          'Tasarruf Planım kullanıcıdan şirket adına ödeme almaz ve uzman adına satış sözleşmesi düzenlemez.\n\n'
          'Şirket sözleşmeleri ve tahsilat süreçleri ilgili şirketin kendi resmî kanalları üzerinden yürütülmelidir.',
    ),
    _ExpertAgreementSection(
      icon: Icons.payments_outlined,
      title: 'Ücret ve Komisyon',
      body:
          'Tasarruf Planım’ın uzmanlara yönelik mevcut veya gelecekteki ücret, üyelik veya komisyon modeli ayrıca belirlenebilir.\n\n'
          'İşbu sözleşmenin kabulü, henüz açıklanmamış bir ücret veya komisyonun uzman tarafından peşinen kabul edildiği anlamına gelmez.\n\n'
          'Ücretli bir uzman özelliği sunulması halinde temel ticari şartlar ayrıca bildirilmelidir.',
    ),
    _ExpertAgreementSection(
      icon: Icons.build_outlined,
      title: 'Teknik Kesintiler',
      body:
          'Uzman paneli veya danışma sistemi bakım, güncelleme veya teknik arıza nedeniyle geçici olarak kullanılamayabilir.\n\n'
          'Uzman, sistemin her an kesintisiz çalışacağına ilişkin garanti bulunmadığını kabul eder.\n\n'
          'Tasarruf Planım teknik sorunları makul sürede gidermek için gerekli çabayı göstermeyi hedefler.',
    ),
    _ExpertAgreementSection(
      icon: Icons.system_update_alt_outlined,
      title: 'Sistem Güncellemeleri',
      body:
          'Tasarruf Planım uzman panelinin yapısını, talep durumlarını, atama mantığını veya doğrulama süreçlerini kullanıcı güvenliği ve hizmet kalitesi amacıyla güncelleyebilir.\n\n'
          'Esaslı değişikliklerin uzman hak ve yükümlülüklerini etkilediği durumlarda gerekli bilgilendirme yapılmalıdır.\n\n'
          'Güncel sistem kurallarına uyum uzman hesabının devamı bakımından önemlidir.',
    ),
    _ExpertAgreementSection(
      icon: Icons.code_outlined,
      title: 'Fikri Mülkiyet Hakları',
      body:
          'Tasarruf Planım yazılımı, tasarım sistemi, uzman paneli, özgün içerikler ve diğer platform unsurları üzerindeki haklar ilgili hak sahiplerine aittir.\n\n'
          'Uzman hesabı, bu unsurlar üzerinde mülkiyet veya sınırsız kullanım hakkı sağlamaz.\n\n'
          'Tasarruf Planım’ın teknik veya görsel unsurları izinsiz kopyalanamaz veya başka bir hizmette kullanılamaz.',
    ),
    _ExpertAgreementSection(
      icon: Icons.shield_outlined,
      title: 'Kişisel Veriler ve Gizlilik Politikası',
      body:
          'Uzmanın kendi kişisel verilerinin Tasarruf Planım tarafından işlenmesine ilişkin ayrıntılar Gizlilik Politikası ve ilgili KVKK Aydınlatma Metninde açıklanır.\n\n'
          'İşbu Uzman Sözleşmesinin kabulü, açık rıza gereken tüm veri işleme faaliyetlerine otomatik olarak rıza verildiği anlamına gelmez.\n\n'
          'Gerekli durumlarda açık rıza süreçleri ayrıca yürütülür.',
    ),
    _ExpertAgreementSection(
      icon: Icons.history_toggle_off_outlined,
      title: 'Sözleşme Sürümü ve Kabul Kaydı',
      body:
          'Tasarruf Planım, uzmanın hangi Uzman Sözleşmesi sürümünü hangi tarihte kabul ettiğini teknik olarak kaydedebilir.\n\n'
          'Bu kayıt uzman hesabı yönetimi, uyuşmazlıkların değerlendirilmesi ve yasal yükümlülüklerin yerine getirilmesi amacıyla kullanılabilir.\n\n'
          'Sözleşmenin esaslı biçimde değişmesi halinde yeniden kabul istenebilir.',
    ),
    _ExpertAgreementSection(
      icon: Icons.touch_app_outlined,
      title: 'Elektronik Kabul',
      body:
          'Uzman başvuru veya uzman hesabı aktivasyon sürecinde işbu sözleşmeye erişebilmeli ve kabulünü açık bir kullanıcı işlemiyle belirtmelidir.\n\n'
          'Sözleşme kabul kutusunun kullanıcı tarafından aktif şekilde işaretlenmesi hedeflenir.\n\n'
          'Sözleşmeyi kabul etmeyen kişiye uzman rolü verilmeyebilir.',
    ),
    _ExpertAgreementSection(
      icon: Icons.update_outlined,
      title: 'Sözleşme Değişiklikleri',
      body:
          'Tasarruf Planım, mevzuat, uzman sistemi veya operasyonel ihtiyaçlar doğrultusunda işbu sözleşmeyi güncelleyebilir.\n\n'
          'Uzmanın hak ve yükümlülüklerini esaslı biçimde etkileyen değişikliklerde güncel metin uzmana sunulmalı ve gerektiğinde yeniden kabul alınmalıdır.\n\n'
          'Güncel sözleşme uygulama içerisinden erişilebilir tutulmalıdır.',
    ),
    _ExpertAgreementSection(
      icon: Icons.balance_rounded,
      title: 'Sorumluluk',
      body:
          'Uzman kendi beyan, iletişim ve eylemlerinden sorumludur.\n\n'
          'Tasarruf Planım, uzman tarafından verilen yanlış veya yetkisiz şirket taahhütlerinin tarafı değildir.\n\n'
          'Bununla birlikte işbu sözleşmedeki hiçbir hüküm, Tasarruf Planım’ın kendi kusurundan veya emredici mevzuattan doğan sorumluluğunu ortadan kaldıracak şekilde yorumlanamaz.',
    ),
    _ExpertAgreementSection(
      icon: Icons.gavel_outlined,
      title: 'Tüketici ve Kullanıcı Haklarına Saygı',
      body:
          'Uzman, kullanıcıların tüketici mevzuatı ve diğer emredici düzenlemelerden doğan haklarına saygı göstermelidir.\n\n'
          'Kullanıcıyı yasal haklarından vazgeçmeye zorlayan veya yanıltan beyanlarda bulunulamaz.\n\n'
          'Uzman, kendi şirketinin resmî süreçlerinde de yürürlükteki tüketici düzenlemelerine uygun hareket etmekle yükümlüdür.',
    ),
    _ExpertAgreementSection(
      icon: Icons.account_balance_outlined,
      title: 'Uyuşmazlıkların Çözümü',
      body:
          'Uzman ile Tasarruf Planım arasında işbu sözleşmeden kaynaklanan bir uyuşmazlık oluşması halinde öncelikle Tasarruf Planım’ın ilan ettiği iletişim kanalları üzerinden çözüm aranabilir.\n\n'
          'Tarafların kanunen yetkili yargı mercilerine ve diğer başvuru yollarına ilişkin hakları saklıdır.\n\n'
          'Yetki ve görev konularında yürürlükteki emredici hukuk kuralları uygulanır.',
    ),
    _ExpertAgreementSection(
      icon: Icons.balance_outlined,
      title: 'Uygulanacak Hukuk',
      body:
          'İşbu sözleşme Türkiye Cumhuriyeti hukukunun ilgili hükümleri çerçevesinde değerlendirilir.\n\n'
          'Kişisel verilerin korunması, elektronik iletişim, tüketici hukuku ve ilgili sektörel düzenlemeler gerektiği ölçüde ayrıca uygulanır.\n\n'
          'Emredici mevzuat hükümleri saklıdır.',
    ),
    _ExpertAgreementSection(
      icon: Icons.rule_outlined,
      title: 'Kısmi Geçersizlik',
      body:
          'Sözleşmenin herhangi bir hükmünün geçersiz veya uygulanamaz hale gelmesi, diğer hükümlerin geçerliliğini kendiliğinden ortadan kaldırmaz.\n\n'
          'Geçersiz hüküm, mümkün olduğu ölçüde yürürlükteki mevzuat ve sözleşmenin genel amacıyla uyumlu biçimde değerlendirilir.\n\n'
          'Tarafların emredici hukuk kurallarından doğan hakları saklıdır.',
    ),
    _ExpertAgreementSection(
      icon: Icons.mail_outline_rounded,
      title: 'İletişim',
      body:
          'Uzman, uzman başvurusu, doğrulama ve sözleşmeyle ilgili genel taleplerini info@tasarrufplanim.com adresi üzerinden iletebilir.\n\n'
          'Uzman hesabı, giriş, hesap güvenliği veya teknik sorunlara ilişkin destek talepleri destek@tasarrufplanim.com adresi üzerinden iletilebilir.\n\n'
          'Kişisel verilere ilişkin başvurular ilgili KVKK metinlerinde belirtilen kanallardan yürütülür.',
    ),
    _ExpertAgreementSection(
      icon: Icons.play_circle_outline_rounded,
      title: 'Yürürlük',
      body:
          'İşbu Uzman Sözleşmesi, uzman adayının elektronik ortamda sözleşmeyi kabul etmesi ve uzman rolünün Tasarruf Planım tarafından onaylanmasıyla ilgili hükümler bakımından yürürlüğe girer.\n\n'
          'Uzman statüsü devam ettiği sürece güncel sözleşme hükümleri uygulanır.\n\n'
          'Esaslı bir değişiklikte yeniden kabul gerekebilir.',
    ),
    _ExpertAgreementSection(
      icon: Icons.verified_user_outlined,
      title: 'Son Hüküm',
      body:
          'Uzman, Tasarruf Planım uzman sisteminin kullanıcıya baskı kurmak veya otomatik atama mekanizmasını satış amacıyla manipüle etmek için değil, tasarruf finansmanı hakkında güvenli ve profesyonel iletişim sağlamak amacıyla oluşturulduğunu kabul eder.\n\n'
          'Uzmanın temel yükümlülüğü; doğru bilgi vermek, kullanıcı verilerini korumak, kullanıcıya saygılı davranmak ve Tasarruf Planım’ın bağımsızlık ile tarafsızlık yaklaşımına uygun hareket etmektir.\n\n'
          'İşbu sözleşme, uzman ile kullanıcının veya uzman tarafından temsil edilen tasarruf finansman şirketinin arasında kurulabilecek bağımsız sözleşmenin yerine geçmez.',
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
          'Uzman Sözleşmesi',
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
            const _ExpertAgreementHeroCard(),
            const SizedBox(height: 16),
            const _ExpertAgreementIntroCard(),
            const SizedBox(height: 16),
            const _SectionLabel(),
            const SizedBox(height: 10),
            ...List.generate(_sections.length, (index) {
              final section = _sections[index];
              final isOpen = _openIndex == index;
              return _ExpertAgreementAccordionCard(
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
            const _ExpertAgreementFooterCard(),
            const SizedBox(height: 12),
            const _LaunchNote(),
          ],
        ),
      ),
    );
  }
}

class _ExpertAgreementHeroCard extends StatelessWidget {
  const _ExpertAgreementHeroCard();

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
            _ExpertAgreementScreenState._navy,
            _ExpertAgreementScreenState._petrol,
            Color(0xFF0C6268),
            _ExpertAgreementScreenState._teal,
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
              color: _ExpertAgreementScreenState._turquoise.withOpacity(.16),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: const Color(0xFF55E2D0).withOpacity(.28),
              ),
            ),
            child: const Icon(
              Icons.workspace_premium_outlined,
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
                  'Uzman Sözleşmesi',
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
                  'Uzman başvurusu, doğrulama, otomatik talep ataması ve '
                  'kullanıcılarla profesyonel iletişim için temel kurallar.',
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

class _ExpertAgreementIntroCard extends StatelessWidget {
  const _ExpertAgreementIntroCard();

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
            color: _ExpertAgreementScreenState._teal,
            size: 21,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tasarruf Planım’da kullanıcılar belirli bir uzman seçmez. Danışma '
              'talepleri uygun uzmanlara sistem kuralları doğrultusunda '
              'otomatik olarak atanır. Uzmanın temel yükümlülüğü doğru, '
              'güvenli ve profesyonel iletişim yürütmektir.',
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
          color: _ExpertAgreementScreenState._teal,
          size: 18,
        ),
        SizedBox(width: 7),
        Text(
          'Uzmanlık Kuralları ve Yükümlülükler',
          style: TextStyle(
            color: _ExpertAgreementScreenState._navy,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

class _ExpertAgreementAccordionCard extends StatelessWidget {
  const _ExpertAgreementAccordionCard({
    required this.number,
    required this.section,
    required this.isOpen,
    required this.onTap,
  });

  final int number;
  final _ExpertAgreementSection section;
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
              ? _ExpertAgreementScreenState._teal.withOpacity(.30)
              : _ExpertAgreementScreenState._border,
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
                            _ExpertAgreementScreenState._teal.withOpacity(.14),
                            _ExpertAgreementScreenState._turquoise.withOpacity(.10),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        section.icon,
                        color: _ExpertAgreementScreenState._teal,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '$number. ${section.title}',
                        style: const TextStyle(
                          color: _ExpertAgreementScreenState._navy,
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
                        color: _ExpertAgreementScreenState._muted,
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

class _ExpertAgreementFooterCard extends StatelessWidget {
  const _ExpertAgreementFooterCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
      decoration: BoxDecoration(
        color: _ExpertAgreementScreenState._navy,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.workspace_premium_outlined,
            color: Color(0xFF55E2D0),
            size: 21,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Uzman statüsünün temeli satış baskısı değil; doğru bilgi, '
              'kullanıcı güvenliği, mesleki özen ve Tasarruf Planım’ın bağımsızlık '
              'ilkelerine uygun iletişimdir.',
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
        'Yayın öncesi: Tasarruf Planım’ın nihai ticari unvanı, resmî adresi, '
        'sözleşme sürümü ve uzman doğrulama süreçlerinin son operasyonel '
        'hali bu metinle karşılaştırılmalı; metin hukuk uzmanı tarafından '
        'son kez kontrol edilmelidir.',
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

class _ExpertAgreementSection {
  const _ExpertAgreementSection({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;}
