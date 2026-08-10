import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../services/auth_service.dart';
import 'user_login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    this.initialFullName,
    this.initialPhone,
    this.completeAnonymousAccount = false,
  });

  final String? initialFullName;
  final String? initialPhone;
  final bool completeAnonymousAccount;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const Color _background = Color(0xFFF7F9FB);
  static const Color _navy = Color(0xFF0B2239);
  static const Color _petrol = Color(0xFF052F3D);
  static const Color _teal = Color(0xFF087C72);
  static const Color _softTeal = Color(0xFFEAF8F5);
  static const Color _border = Color(0xFFE4EAF0);
  static const Color _textDark = Color(0xFF172B35);
  static const Color _textMuted = Color(0xFF748193);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordAgainController =
      TextEditingController();

  final AuthService _authService = AuthService();
  final UserRepository _userRepository = UserRepository();

  bool _passwordVisible = false;
  bool _passwordAgainVisible = false;
  bool _membershipAccepted = false;
  bool _clarificationAcknowledged = false;
  bool _privacyAccepted = false;
  bool _isSubmitting = false;

  User? _authenticatedUserPendingProfile;
  bool _shouldRollbackNewAccount = false;

  @override
  void initState() {
    super.initState();

    final String fullName = widget.initialFullName?.trim() ?? '';

    if (fullName.isNotEmpty) {
      final List<String> parts = fullName
          .split(RegExp(r'\s+'))
          .where((part) => part.isNotEmpty)
          .toList();

      if (parts.isNotEmpty) {
        _nameController.text = parts.first;

        if (parts.length > 1) {
          _surnameController.text = parts.sublist(1).join(' ');
        }
      }
    }

    _phoneController.text = widget.initialPhone?.trim() ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _passwordAgainController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value, String fieldName) {
    if ((value ?? '').trim().isEmpty) {
      return '$fieldName alanını doldurunuz.';
    }

    return null;
  }

  String? _emailValidator(String? value) {
    final String email = (value ?? '').trim();

    if (email.isEmpty) {
      return 'E-posta adresinizi giriniz.';
    }

    final RegExp emailPattern = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );

    if (!emailPattern.hasMatch(email)) {
      return 'Geçerli bir e-posta adresi giriniz.';
    }

    return null;
  }

  String? _phoneValidator(String? value) {
    final String phone =
        (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');

    if (phone.isEmpty) {
      return 'Telefon numaranızı giriniz.';
    }

    if (phone.length != 10 && phone.length != 11) {
      return 'Geçerli bir telefon numarası giriniz.';
    }

    return null;
  }

    String? _passwordValidator(String? value) {
    final String password = value ?? '';

    if (password.isEmpty) {
      return 'Şifrenizi giriniz.';
    }

    if (password.length < 8) {
      return 'Şifre en az 8 karakter olmalıdır.';
    }

    return null;
  }

  String? _passwordAgainValidator(String? value) {
    if ((value ?? '').isEmpty) {
      return 'Şifrenizi tekrar giriniz.';
    }

    if (value != _passwordController.text) {
      return 'Girdiğiniz şifreler eşleşmiyor.';
    }

    return null;
  }

  Future<void> _openLegalDocument({
    required String title,
    required String confirmationText,
    required String documentText,
    required void Function() onConfirmed,
  }) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _LegalDocumentDialog(
        title: title,
        confirmationText: confirmationText,
        documentText: documentText,
      ),
    );

    if (confirmed == true && mounted) {
      setState(onConfirmed);
    }
  }

  Future<void> _createAccount() async {
    FocusScope.of(context).unfocus();

    final bool isFormValid =
        _formKey.currentState?.validate() ?? false;

    if (!isFormValid) {
      return;
    }

    if (!_membershipAccepted ||
        !_clarificationAcknowledged ||
        !_privacyAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Devam etmek için gerekli metinleri inceleyiniz.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final String name = _nameController.text.trim();
    final String surname = _surnameController.text.trim();
    final String email =
        _emailController.text.trim().toLowerCase();
    final String phone = _phoneController.text
        .replaceAll(RegExp(r'[^0-9]'), '');
    final String password = _passwordController.text;

    try {
      User firebaseUser;

      if (_authenticatedUserPendingProfile != null) {
        firebaseUser = _authenticatedUserPendingProfile!;
      } else {
        final bool wasAnonymous =
            _authService.hasAnonymousUser;

        final UserCredential credential =
            await _authService
                .registerOrLinkWithEmailAndPassword(
          email: email,
          password: password,
        );

        final User? credentialUser = credential.user;

        if (credentialUser == null) {
          throw const AuthServiceException(
            code: 'user-not-created',
            message: 'Kullanıcı hesabı oluşturulamadı.',
          );
        }

        firebaseUser = credentialUser;
        _authenticatedUserPendingProfile = firebaseUser;
        _shouldRollbackNewAccount = !wasAnonymous;
      }

      final AppUser appUser = AppUser(
        uid: firebaseUser.uid,
        name: name,
        surname: surname,
        email: email,
        roles: const ['user'],
        expertStatus: 'none',
        phone: phone,
        createdAt: DateTime.now(),
      );

      await _userRepository.createUserProfile(appUser);

      _authenticatedUserPendingProfile = null;
      _shouldRollbackNewAccount = false;

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.completeAnonymousAccount
                ? 'Hesabınız tamamlandı. Danışma talebiniz korunuyor.'
                : 'Plango hesabınız başarıyla oluşturuldu.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, true);
        } on AuthServiceException catch (error) {
      if (_shouldRollbackNewAccount) {
        await _authService.rollbackNewlyCreatedUser();
        _authenticatedUserPendingProfile = null;
        _shouldRollbackNewAccount = false;
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (_shouldRollbackNewAccount) {
        await _authService.rollbackNewlyCreatedUser();
        _authenticatedUserPendingProfile = null;
        _shouldRollbackNewAccount = false;
      }

      if (!mounted) {
        return;
      }

      final String message =
          _authenticatedUserPendingProfile != null
              ? 'Hesabınız Firebase tarafında oluşturuldu ancak profil '
                  'kaydedilemedi. Bilgilerinizi kontrol edip tekrar deneyiniz.'
              : 'Hesap oluşturulurken beklenmeyen bir hata oluştu.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }


  String get _membershipAgreementText => '''PLANGO KULLANICI SÖZLEŞMESİ

1. Taraflar
İşbu Kullanıcı Sözleşmesi, Plango dijital platformunu kullanan gerçek kişi kullanıcı ile Plango hizmetinin veri sorumlusu ve/veya hizmet sağlayıcısı sıfatıyla faaliyet gösterecek gerçek veya tüzel kişi arasında, kullanıcının üyelik işlemini tamamlaması ve sözleşmeyi elektronik ortamda kabul etmesiyle kurulur.

Plango’nun nihai ticari unvanı, merkez adresi, iletişim kanalları ve varsa MERSİS/vergi bilgileri yayına çıkmadan önce sözleşmenin bu bölümüne açık biçimde eklenmelidir.

Bu sözleşmede “Kullanıcı”, Plango’da hesap oluşturan veya üyelik kapsamında sunulan hizmetlerden yararlanan kişiyi; “Plango” ise uygulama, hesaplama altyapısı ve ilgili dijital hizmetlerin bütününü ifade eder.

2. Sözleşmenin Konusu
Bu sözleşmenin konusu, kullanıcının Plango’ya üye olması ve Plango tarafından sunulan dijital özelliklerden yararlanmasına ilişkin temel kullanım şartlarının, tarafların hak ve yükümlülüklerinin ve üyelik ilişkisinin çerçevesinin belirlenmesidir.

Sözleşme; Plango hesabının kullanımı, FP Engine, kayıtlı planlar, ödeme planı çıktıları, danışma sistemi, doğrulanmış uzmanlarla iletişim, bildirimler ve üyelik kapsamında sunulan diğer işlevler bakımından uygulanır.

Plango’nun herhangi bir tasarruf finansman şirketiyle kullanıcı arasında imzalanan sözleşmenin tarafı olmadığı ve bu sözleşmenin bir tasarruf finansmanı sözleşmesi niteliği taşımadığı taraflarca kabul edilir.

3. Tanımlar
FP Engine: Kullanıcının girdiği finansman ve ödeme parametrelerini kullanarak tahmini planlama sonuçları oluşturan Plango hesaplama motorudur.

Kayıtlı Plan: Kullanıcının daha sonra görüntülemek amacıyla hesabına kaydettiği tahmini hesaplama kaydıdır.

Danışma Talebi: Kullanıcının tasarruf finansmanı hakkında bilgi almak amacıyla Plango üzerinden uygun bir doğrulanmış uzmanla iletişim kurulmasını talep ettiği uygulama içi süreçtir.

Doğrulanmış Uzman: Plango tarafından belirlenen doğrulama kriterlerinden geçen sektör profesyonelidir.

İçerik: Plango içerisinde yayımlanan metin, haber, bilgi, şirket profili, açıklama, grafik, hesaplama sonucu ve benzeri dijital unsurlardır.

4. Üyeliğin Başlatılması
Kullanıcı, üyelik formunda talep edilen zorunlu bilgileri doğru ve güncel biçimde girerek ve işbu Kullanıcı Sözleşmesini kabul ederek üyelik başvurusunu tamamlar.

Plango, teknik güvenlik, kötüye kullanımın önlenmesi veya hesap doğrulaması amacıyla e-posta doğrulaması ve benzeri güvenlik adımları uygulayabilir.

Üyelik, kullanıcının Plango üzerindeki her özelliği sınırsız veya süresiz kullanma hakkı kazandığı anlamına gelmez. Özelliklerin kapsamı uygulamanın güncel sürümüne göre değişebilir.

5. Üyelik İçin Temel Şartlar
Kullanıcı, üyelik oluştururken kendi adına işlem yaptığını, verdiği bilgilerin doğru olduğunu ve hesabı hukuka uygun amaçlarla kullanacağını beyan eder.

Başka kişilerin kimlik veya iletişim bilgileriyle izinsiz hesap oluşturulamaz.

Plango’nun hizmetleri, niteliği gereği kendi adına finansal değerlendirme ve sözleşme işlemleri yapabilecek kullanıcılar için tasarlanmıştır. Kullanıcının hukuki işlem ehliyetine ilişkin zorunlu hükümler saklıdır.

6. Hesap Bilgilerinin Doğruluğu
Kullanıcı, üyelik ve profil alanlarında sağladığı bilgilerin doğru, güncel ve kendisine ait olmasından sorumludur.

Yanlış veya başkasına ait bilgilerle oluşturulan hesaplar; güvenlik, hukuki yükümlülük veya diğer kullanıcıların korunması amacıyla incelenebilir, sınırlandırılabilir ya da gerekli şartlarda kapatılabilir.

Kullanıcı, değişen profil bilgilerini uygulamanın sunduğu imkanlar ölçüsünde güncellemelidir.

7. Hesap Güvenliği
Kullanıcı kendi hesabının, parolasının ve doğrulama araçlarının güvenliğini korumakla yükümlüdür.

Parola, tek kullanımlık doğrulama kodu, e-posta erişimi ve benzeri güvenlik bilgileri üçüncü kişilerle paylaşılmamalıdır.

Hesabın izinsiz kullanıldığından şüphe edilmesi halinde kullanıcı, mümkün olan en kısa sürede parolasını değiştirmeli ve Plango’nun ilan ettiği destek kanalı üzerinden bildirimde bulunmalıdır.

8. Hesabın Kişisel Kullanımı
Kullanıcı hesabı kişiseldir. Hesabın başka kişilere kiralanması, devredilmesi, satılması veya sistematik olarak ortak kullanılması yasaktır.

Kullanıcı, kendi hesabı üzerinden gerçekleştirilen işlemlerin kendi kontrolünde olmasını sağlamakla yükümlüdür.

Yetkisiz hesap paylaşımının güvenlik riski doğurduğu durumlarda Plango gerekli teknik tedbirleri uygulayabilir.

9. Plango Hizmetinin Niteliği
Plango, tasarruf finansmanı alanında bilgilendirme, hesaplama ve karar destek amacıyla sunulan bağımsız bir dijital platformdur.

Plango finansman sağlamaz, tasarruf finansmanı sözleşmesi düzenlemez, kullanıcı adına finansman başvurusu yapmaz ve tasarruf finansman şirketi adına bağlayıcı teklif oluşturmaz.

Plango’nun sunduğu dijital araçlar, kullanıcının kendi değerlendirmesini yapmasına yardımcı olmak amacıyla kullanılır.

10. FP Engine Kullanımı
Kullanıcı, FP Engine’e girdiği finansman tutarı, peşinat, aylık ödeme, ödeme modeli ve diğer parametrelerin doğruluğundan sorumludur.

FP Engine, kullanıcı girdilerine ve Plango tarafından tanımlanan hesaplama kurallarına göre tahmini sonuçlar oluşturur.

Kullanıcı, FP Engine’i kişisel planlama ve bilgilendirme amacıyla kullanabilir. Hesaplama sonuçlarının üçüncü kişilere resmî teklif veya şirket taahhüdü gibi sunulması yasaktır.

11. FP Engine Sonuçlarının Sözleşmesel Niteliği
FP Engine tarafından oluşturulan sonuçlar; tasarruf finansman şirketleri adına verilmiş resmî teklif, finansman onayı, ödeme taahhüdü veya kesin teslim tarihi değildir.

Kullanıcı, resmî bir tasarruf finansmanı işlemi gerçekleştirmeden önce ilgili şirketten güncel ve bağlayıcı bilgi almakla sorumludur.

Bu hüküm, kullanıcının yürürlükteki mevzuattan doğan vazgeçilmez haklarını ortadan kaldırmaz.

12. Tahmini Teslim ve Vade Bilgileri
Plango’da gösterilen tahmini teslim süresi, tahmini teslim tarihi ve toplam vade sonuçları kullanıcı girdilerine dayalı karar destek verileridir.

Gerçek teslim ve ödeme koşulları ilgili tasarruf finansman şirketinin sözleşmesi, güncel uygulamaları ve yürürlükteki düzenlemeler kapsamında belirlenir.

Kullanıcı, tahmini sonuçları kesin şirket taahhüdü olarak yorumlamamalıdır.

13. Kayıtlı Planlar
Kullanıcı, Plango’nun sunduğu özellik kapsamında oluşturduğu tahmini planları hesabına kaydedebilir.

Kayıtlı plan, kullanıcının kendi hesaplama geçmişinin bir parçasıdır ve ilgili planın herhangi bir şirket tarafından kabul edildiği anlamına gelmez.

Kullanıcı, uygulamanın sunduğu imkanlar dahilinde kayıtlı planlarını görüntüleyebilir ve silebilir.

14. Son Hesaplanan Plan
Plango, kullanıcı deneyimini kolaylaştırmak amacıyla son hesaplanan plana ilişkin bilgileri geçici veya kalıcı olmayan bir kullanıcı deneyimi kaydı olarak gösterebilir.

Son hesaplanan plan, kullanıcının özellikle “Planı Kaydet” işlemiyle oluşturduğu kayıtlı plandan farklı olabilir.

Bu alanın amacı kullanıcının son çalıştığı senaryoya hızlı biçimde dönebilmesini sağlamaktır.

15. Ödeme Planı Görünümü
Ödeme planı ekranı, FP Engine sonucunu daha anlaşılır biçimde göstermek amacıyla oluşturulan yardımcı bir görünümdür.

Taksit tarihleri, toplam birikim, tahmini teslim ayı ve benzeri alanlar hesaplama mantığına dayalıdır.

Bu ekran ilgili şirketin resmî muhasebe kaydı veya sözleşme eki değildir.

16. PDF ve Dışa Aktarılan Belgeler
Kullanıcı, Plango tarafından sunulması halinde planını PDF veya benzeri belge formatında dışa aktarabilir.

Bu belgeler Plango hesaplamasının kullanıcı tarafından saklanabilen bir çıktısıdır; resmî tasarruf finansmanı teklifi veya sözleşme değildir.

Kullanıcı, dışa aktardığı belgelerin kendi cihazında saklanmasından ve üçüncü kişilerle paylaşılması halinde bu paylaşımın sonuçlarından sorumludur.

17. Danışma Sisteminin Amacı
Danışma sistemi, kullanıcının tasarruf finansmanı hakkında bilgi almak amacıyla doğrulanmış sektör uzmanlarıyla iletişim kurmasını kolaylaştırır.

Danışma talebi oluşturulması, bir tasarruf finansman şirketine resmî başvuru yapılması veya sözleşme kurulması anlamına gelmez.

Plango, kullanıcı ile uzman arasındaki iletişimi kolaylaştıran platform rolündedir.

18. Danışma Talebi Oluşturma
Kullanıcı danışma talebi oluştururken yalnızca talebin değerlendirilmesi için gerekli ve doğru bilgileri vermelidir.

Kullanıcı notlarında ilgisiz kişisel veriler, üçüncü kişilere ait bilgiler veya hukuka aykırı içerikler paylaşılmamalıdır.

Danışma talebi, sistemin güncel atama veya uzman eşleştirme mantığına göre uygun uzmana yönlendirilebilir.

19. Uzmanlarla İletişim
Kullanıcı, uzmanla iletişiminde saygılı, hukuka uygun ve dürüst davranmalıdır.

Uzmanın Plango’da doğrulanmış olması, ilgili uzmanın her beyanının Plango tarafından garanti edildiği anlamına gelmez.

Kullanıcı, mali yükümlülük veya sözleşme sonucu doğurabilecek önemli bilgileri ilgili şirketin resmî belgelerinden ayrıca doğrulamalıdır.

20. Uzmanların Bağımsız Mesleki Beyanları
Uzmanların kullanıcıyla paylaştığı yorumlar, açıklamalar ve değerlendirmeler ilgili uzmanın kendi mesleki sorumluluğu kapsamında olabilir.

Plango, uzmanların her iletişimini önceden inceleyen veya onaylayan bir taraf değildir.

Plango’nun uzman sistemi; kullanıcıların doğrulanmış sektör profesyonellerine ulaşmasını kolaylaştırmak amacıyla sunulur.

21. Şirket Bilgileri
Plango’da tasarruf finansman şirketlerine ilişkin bilgilendirici profiller ve kamuya açık bilgiler sunulabilir.

Kullanıcı, şirket bilgilerini genel araştırma amacıyla kullanabilir; ancak güncel ücret, kampanya, teslim koşulu veya sözleşme hükümleri için ilgili şirketin resmî kaynaklarını kontrol etmelidir.

Plango üzerinde bir şirketin bulunması, o şirketin tavsiye edildiği veya diğer şirketlerden üstün olduğu anlamına gelmez.

22. Bildirim Merkezi
Plango, üyelik kapsamında uygulama içi bildirimler gösterebilir.

Bildirimler genel içerik güncellemeleri, kullanıcı hesabı veya uygulamanın işleyişiyle ilgili uygun bilgilendirmeleri içerebilir.

Ticari elektronik ileti niteliği taşıyan mesajlar bakımından yürürlükteki zorunlu mevzuat hükümleri ayrıca uygulanır.

23. Şikayet ve Öneri Sistemi
Kullanıcı Plango deneyimi, içerikler, teknik sorunlar veya uzman sistemi hakkında geri bildirimde bulunabilir.

Geri bildirimler hakaret, tehdit, kişisel saldırı, üçüncü kişilerin kişisel verilerini hukuka aykırı biçimde açıklama veya yanıltıcı bilgi yayma amacıyla kullanılamaz.

Plango, doğrulanabilir geri bildirimleri hizmet kalitesini geliştirmek amacıyla değerlendirebilir.

24. Kullanıcının Genel Yükümlülükleri
Kullanıcı Plango’yu yürürlükteki mevzuata, işbu sözleşmeye ve dürüstlük kurallarına uygun biçimde kullanmalıdır.

Kullanıcı, sistemin çalışmasını bozacak girişimlerde bulunmamalı; diğer kullanıcıların, uzmanların veya üçüncü kişilerin haklarını ihlal etmemelidir.

Kullanıcı, uygulamada gördüğü tahmini sonuçları yanıltıcı biçimde resmî belge veya şirket taahhüdü gibi sunmamalıdır.

25. Yasaklanan Kullanımlar
Plango üzerinde hukuka aykırı içerik paylaşmak, sahte hesap oluşturmak, başka kişilerin hesaplarına izinsiz erişmeye çalışmak, güvenlik önlemlerini aşmak veya hizmeti kötüye kullanmak yasaktır.

Otomatik sistemlerle uygulamanın olağan kullanımını bozacak yoğun istek göndermek, veri toplamak veya güvenlik açıklarını istismar etmek yasaktır.

Plango içeriğini üçüncü kişileri yanıltmak, dolandırıcılık yapmak veya yetkisiz ticari faaliyet yürütmek amacıyla kullanmak yasaktır.

26. Kötüye Kullanımın Önlenmesi
Plango, kullanıcıların ve platformun güvenliğini korumak amacıyla şüpheli kullanım davranışlarını inceleyebilir ve gerekli teknik tedbirleri uygulayabilir.

Açık kötüye kullanım, güvenlik ihlali veya hukuka aykırı faaliyet şüphesinde erişim geçici olarak sınırlandırılabilir.

Bu tedbirler uygulanırken olayın niteliği, ölçülülük ve yürürlükteki zorunlu hükümler dikkate alınır.

27. Fikri Mülkiyet Hakları
Plango adı, uygulama tasarımı, özgün metinler, yazılım bileşenleri, FP Engine yapısı ve Plango’ya ait diğer özgün unsurlar üzerindeki haklar ilgili hak sahiplerine aittir.

Kullanıcıya üyelik verilmesi bu unsurların mülkiyetinin devredildiği anlamına gelmez.

Kullanıcı, yalnızca uygulamanın normal kullanım amacı kapsamında kişisel ve sınırlı kullanım hakkına sahiptir.

28. Şirket Marka ve Logoları
Plango’da yer alan üçüncü taraf şirketlerin marka, logo ve ticaret unvanları ilgili hak sahiplerine aittir.

Bu unsurların bilgilendirme amacıyla gösterilmesi, ilgili şirket ile Plango arasında ortaklık veya temsil ilişkisi bulunduğu anlamına gelmez.

Kullanıcı, üçüncü taraf marka ve logolarını hukuka aykırı biçimde çoğaltmamalı veya kullanmamalıdır.

29. Kişisel Veriler ve Gizlilik
Üyelik kapsamında kişisel verilerin işlenmesine ilişkin ayrıntılar Plango Gizlilik Politikası ve ilgili KVKK Aydınlatma Metninde açıklanır.

Kullanıcı Sözleşmesinin kabulü, açık rıza gerektiren her türlü veri işleme faaliyetine otomatik olarak açık rıza verildiği anlamına gelmez.

Açık rıza gereken durumlarda ilgili onayın ayrı ve özgür iradeyle alınması esastır.

30. Aydınlatma Metni ile İlişki
KVKK Aydınlatma Metni, kullanıcıya kişisel verilerin işlenmesi hakkında bilgi vermek amacıyla sunulur ve işbu Kullanıcı Sözleşmesinden ayrı bir hukuki işleve sahiptir.

Kullanıcının üyelik oluştururken Aydınlatma Metnine erişebilmesi sağlanmalıdır.

Aydınlatmanın yapılmış olması için kullanıcıdan “rıza” alınması yerine, aydınlatma yükümlülüğünün kendi kurallarına uygun şekilde yerine getirilmesi esastır.

31. Açık Rıza Gerektiren İşlemler
Plango’nun belirli bir veri işleme faaliyeti için açık rızaya ihtiyaç duyması halinde, bu rıza işbu sözleşmenin genel kabul kutusuna gizlenmemelidir.

Açık rıza belirli bir konuya ilişkin, bilgilendirmeye dayanan ve özgür iradeyle açıklanan ayrı bir kullanıcı tercihi olarak alınmalıdır.

Kullanıcının hizmetten yararlanmasıyla doğrudan ilgili olmayan bir veri işleme amacına rıza vermesi, üyeliğin zorunlu şartı haline getirilmemelidir.

32. Üçüncü Taraf Hizmetler
Plango; kimlik doğrulama, bulut veri saklama, dosya oluşturma veya teknik altyapı gibi alanlarda üçüncü taraf hizmetlerden yararlanabilir.

Üçüncü taraf hizmetler kendi teknik ve hukuki koşullarına sahip olabilir.

Kullanıcının Plango dışındaki bağımsız bir web sitesine veya hizmete yönlendirilmesi halinde ilgili üçüncü tarafın kendi şartları uygulanabilir.

33. Harici Bağlantılar
Plango, şirketlerin, kamu kurumlarının veya bilgilendirici kaynakların internet sayfalarına bağlantılar sunabilir.

Harici bağlantının sunulması, bağlantı verilen sitenin tüm içeriklerinin Plango tarafından onaylandığı veya garanti edildiği anlamına gelmez.

Kullanıcı üçüncü taraf siteye geçtiğinde ilgili sitenin gizlilik ve kullanım koşullarını ayrıca incelemelidir.

34. Hizmetin Geliştirilmesi
Plango, kullanıcı deneyimini, güvenliği ve hizmet kalitesini geliştirmek amacıyla uygulama özelliklerinde değişiklik yapabilir.

Yeni özellikler eklenebilir, mevcut özelliklerin çalışma biçimi değiştirilebilir veya artık gerekli olmayan özellikler kaldırılabilir.

Esaslı değişikliklerin kullanıcı haklarını etkilediği durumlarda gerekli bilgilendirme süreçleri uygulanmalıdır.

35. Bakım ve Teknik Kesintiler
Plango; bakım, güncelleme, güvenlik çalışmaları, internet altyapısı veya üçüncü taraf servislerden kaynaklanan nedenlerle geçici olarak erişilemeyebilir.

Plango hizmetin her an kesintisiz çalışacağını garanti etmez.

Planlı veya beklenmeyen teknik kesintiler, kullanıcı ile tasarruf finansman şirketi arasındaki bağımsız sözleşme ilişkisini etkilemez.

36. Sürüm ve Uyumluluk
Plango’nun bazı özellikleri uygulamanın güncel sürümünü gerektirebilir.

Eski sürümlerde güvenlik, performans veya özellik uyumsuzlukları oluşabilir.

Kullanıcının güvenli ve sağlıklı kullanım için uygulamanın güncel sürümünü kullanması önerilir.

37. Hesabın Geçici Olarak Sınırlandırılması
Güvenlik riski, yetkisiz erişim şüphesi, sistematik kötüye kullanım veya diğer kullanıcıların güvenliğini etkileyen durumlarda hesap geçici olarak sınırlandırılabilir.

Mümkün ve uygun olduğu durumlarda kullanıcıya sınırlandırmanın nedeni ve hesabını yeniden güvenli hale getirmek için gerekli adımlar hakkında bilgi verilebilir.

Zorunlu tüketici ve kullanıcı hakları saklıdır.

38. Hesabın Sonlandırılması
Kullanıcı, uygulamanın sunduğu hesap silme özelliği veya ilan edilen uygun kanal üzerinden üyeliğini sonlandırabilir.

Ağır veya tekrarlanan sözleşme ihlali, sahte hesap, hukuka aykırı kullanım veya ciddi güvenlik ihlali durumunda Plango üyeliği sona erdirebilir.

Hesabın kapatılması halinde kişisel verilerin akıbeti Gizlilik Politikası ve ilgili veri koruma düzenlemeleri çerçevesinde ele alınır.

39. Kullanıcının Üyelikten Ayrılması
Kullanıcının Plango üyeliğini sonlandırması, tasarruf finansman şirketleriyle yapmış olduğu bağımsız sözleşmeleri sona erdirmez.

Kullanıcı, üyelikten ayrılmadan önce ihtiyaç duyduğu kayıtlı plan veya dışa aktarılabilir belgeleri uygulamanın sunduğu ölçüde saklayabilir.

Üyelik sona erdikten sonra hesaba bağlı bazı uygulama özelliklerine erişim mümkün olmayabilir.

40. Ücretsiz ve Ücretli Özellikler
Plango’nun mevcut veya gelecekteki bazı özellikleri ücretsiz, bazı özellikleri ise ileride ücretli olarak sunulabilir.

Yeni bir ücretli hizmet sunulması halinde kullanıcı, ücret ve temel koşullar hakkında ödeme öncesinde bilgilendirilmelidir.

İşbu sözleşmenin kabulü, gelecekte oluşturulabilecek ücretli bir hizmetin bedelinin kullanıcı tarafından peşinen kabul edildiği anlamına gelmez.

41. Plango’nun Sorumluluk Alanı
Plango kendi dijital hizmetinin yürütülmesi, hesaplama altyapısının işletilmesi ve kendi kontrolündeki kullanıcı deneyimi bakımından sorumluluk taşır.

Tasarruf finansman şirketlerinin sözleşmeleri, teslim süreçleri, tahsilatları, şirket çalışanlarının bağımsız beyanları ve şirketlerin kendi operasyonları Plango’nun doğrudan kontrolünde değildir.

Bu hüküm, Plango’nun kendi kusurundan veya emredici hukuk hükümlerinden doğan sorumluluğunu ortadan kaldıracak şekilde yorumlanamaz.

42. Sorumluluğun Sınırları
Plango’nun tahmini hesaplama sonuçları, kullanıcı girdilerine ve uygulanan modele bağlıdır.

Kullanıcının yanlış veri girmesi, tahmini sonucu resmî teklif gibi yorumlaması veya üçüncü tarafın bağımsız işlemine dayanarak karar vermesi nedeniyle ortaya çıkabilecek sonuçlar somut olayın niteliğine göre değerlendirilir.

Bu sözleşmedeki hiçbir hüküm, tüketici hukukundan veya diğer emredici mevzuattan doğan vazgeçilmez hakları ortadan kaldırmaz ya da hukuken geçerli olmayacak bir sorumsuzluk kaydı oluşturmaz.

43. Mücbir Sebep ve Kontrol Dışı Olaylar
Doğal afet, savaş, yaygın iletişim kesintisi, kamu otoritesi kararı, büyük ölçekli siber saldırı, altyapı arızası ve tarafların makul kontrolü dışında gelişen benzeri olaylar hizmetin geçici olarak aksamasına neden olabilir.

Bu durumlarda Plango, hizmeti makul sürede yeniden sağlamak için gerekli teknik çabayı göstermeyi hedefler.

Emredici mevzuattan doğan hak ve sorumluluklar saklıdır.

44. Sözleşme ve Politika Güncellemeleri
Plango’nun hizmet kapsamı, mevzuat veya teknik altyapı değiştikçe bu sözleşme güncellenebilir.

Kullanıcının hak ve yükümlülüklerini esaslı biçimde etkileyen değişikliklerde, güncel metnin kullanıcıya sunulması ve gerektiğinde yeniden kabul alınması değerlendirilir.

Sadece bilgilendirme niteliğindeki küçük yazım veya açıklama değişiklikleri aynı kapsamda olmayabilir.

45. Sözleşme Sürümü ve Kabul Kaydı
Plango, kullanıcının hangi sözleşme sürümünü hangi tarihte kabul ettiğini teknik olarak kaydedebilir.

Bu kayıt, sözleşme yönetimi, kullanıcı taleplerinin yanıtlanması ve hukuki yükümlülüklerin yerine getirilmesi amacıyla kullanılabilir.

Sözleşme sürümü ve kabul kaydının kişisel veri niteliğindeki kısımları Gizlilik Politikası ve KVKK düzenlemeleri kapsamında ele alınır.

46. Elektronik Ortamda Kabul
Kullanıcı, üyelik ekranında işbu sözleşmeye erişebilmeli ve sözleşmeyi kabul ettiğini ayrı ve açık bir kullanıcı işlemiyle belirtmelidir.

Sözleşme bağlantısının erişilebilir olması ve kabul kutusunun kullanıcı tarafından aktif biçimde işaretlenmesi hedeflenir.

Kullanıcının sözleşmeyi kabul etmeden üyelik işlemini tamamlamaması sağlanabilir.

47. Tüketici Haklarının Saklılığı
Kullanıcının tüketici sıfatını taşıdığı durumlarda 6502 sayılı Tüketicinin Korunması Hakkında Kanun ve ilgili emredici düzenlemelerden doğan hakları saklıdır.

İşbu sözleşme, kullanıcının kanundan doğan başvuru, uyuşmazlık çözümü veya diğer vazgeçilmez haklarını ortadan kaldıracak şekilde yorumlanamaz.

Sözleşmede emredici mevzuata aykırı olduğu tespit edilen bir hüküm bulunması halinde, ilgili zorunlu düzenleme uygulanır.

48. Uyuşmazlıkların Çözümü
Taraflar, uyuşmazlık halinde öncelikle Plango’nun ilan ettiği iletişim kanalı üzerinden çözüm arayabilir.

Kullanıcının tüketici sıfatını taşıdığı durumlarda, yürürlükteki mevzuat uyarınca görevli ve yetkili Tüketici Hakem Heyetleri, Tüketici Mahkemeleri ve diğer yetkili mercilere başvuru hakları saklıdır.

Bu sözleşme, kanunen yetkili mercileri ortadan kaldıran veya tüketiciyi zorunlu biçimde hakkından vazgeçiren bir yetki şartı olarak yorumlanamaz.

49. Uygulanacak Hukuk
İşbu sözleşme, Türkiye Cumhuriyeti hukukunun emredici hükümleri başta olmak üzere yürürlükteki ilgili mevzuat çerçevesinde değerlendirilir.

Tüketici, kişisel veri ve elektronik hizmetlere ilişkin özel düzenlemeler uygulanması gerektiğinde ilgili özel hükümler öncelikle dikkate alınır.

Tarafların kanunen sahip olduğu vazgeçilmez haklar saklıdır.

50. Kısmi Geçersizlik
Sözleşmenin herhangi bir hükmünün yürürlükteki mevzuat nedeniyle geçersiz veya uygulanamaz hale gelmesi, diğer hükümlerin kendiliğinden geçersiz olması sonucunu doğurmaz.

Geçersiz hüküm, mümkün olduğu ölçüde ilgili emredici düzenleme ve sözleşmenin genel amacıyla uyumlu şekilde değerlendirilir.

Kullanıcının kanundan doğan hakları her durumda saklıdır.

51. İletişim
Kullanıcı, üyelik ve sözleşmeye ilişkin soru veya taleplerini Plango tarafından uygulama içinde veya resmî kanallarda ilan edilen iletişim adresleri üzerinden iletebilir.

Plango’nun nihai ticari unvanı, e-posta adresi ve resmî bildirim kanalları yayına çıkmadan önce bu sözleşmede açık biçimde yer almalıdır.

Kişisel verilere ilişkin başvurular ise ilgili KVKK Aydınlatma Metni ve Gizlilik Politikası kapsamında belirtilen kanallardan yürütülür.

52. Yürürlük
İşbu Kullanıcı Sözleşmesi, kullanıcının elektronik ortamda sözleşmeye erişerek kabul işlemini tamamladığı tarihte yürürlüğe girer.

Üyelik ilişkisi devam ettiği sürece sözleşmenin güncel ve kullanıcı bakımından geçerli hükümleri uygulanır.

Yeniden kabul gerektiren esaslı bir sözleşme değişikliği yapılması halinde kullanıcıdan güncel sürüm için ayrıca onay istenebilir.

53. Son Hüküm
Kullanıcı, işbu sözleşmenin Plango üyeliğinin kullanım şartlarını düzenlediğini; tasarruf finansman şirketleriyle kuracağı bağımsız sözleşme ilişkilerinin bu sözleşmenin konusu olmadığını kabul eder.

Plango’nun amacı kullanıcı adına finansal karar vermek değil; kullanıcıya kendi kararını destekleyen dijital araçlar ve bilgi sunmaktır.

Kullanıcı, üyelik işlemini tamamlamadan önce sözleşmeye erişme ve sözleşme hükümlerini inceleme imkanına sahip olmalıdır.''';

  String get _clarificationText => '''
PLANGO AYDINLATMA METNİ

1. Amaç
Plango; hesap oluşturma, profil yönetimi, kayıtlı planlar ve danışma süreçlerinin yürütülmesi için gerekli kişisel verileri işler.

2. İşlenen Veriler
Ad, soyad, e-posta, telefon, kullanıcı adı, hesap bilgileri, kayıtlı plan verileri ve danışma taleplerine ilişkin bilgiler işlenebilir.

3. İşleme Amaçları
Veriler; kimlik doğrulama, kullanıcı profilinin yönetimi, kayıtlı planların saklanması, danışma süreçlerinin yürütülmesi, güvenlik ve hizmet kalitesinin sağlanması amaçlarıyla kullanılabilir.

4. Danışma Taleplerinde Paylaşım
Kullanıcının danışma talebi oluşturması halinde, talebin yürütülmesi için gerekli iletişim ve plan bilgileri yalnızca kullanıcının seçtiği doğrulanmış uzmanla paylaşılabilir.

5. Saklama ve Güvenlik
Veriler, hizmetin gerektirdiği süre boyunca ve yürürlükteki yükümlülükler çerçevesinde saklanır. Yetkisiz erişime karşı makul teknik ve idari tedbirler uygulanır.

6. Haklar
Kullanıcı, yürürlükteki kişisel verilerin korunması mevzuatı kapsamında verileriyle ilgili yasal haklarını kullanabilir.

7. İletişim
Kişisel verilerle ilgili talepler, Plango tarafından ilan edilen resmi iletişim kanalları üzerinden iletilebilir.
''';

  String get _privacyPolicyText => '''PLANGO GİZLİLİK POLİTİKASI

1. Gizlilik Politikamızın Amacı
Bu Gizlilik Politikası, Plango’yu kullanan kişilerin hangi tür kişisel verilerinin hangi amaçlarla işlenebileceğini, bu verilerin korunmasına ilişkin yaklaşımımızı ve kullanıcıların gizlilik haklarını anlaşılır bir dille açıklamak amacıyla hazırlanmıştır.

Plango’nun temel yaklaşımı; yalnızca hizmetin sunulması, güvenliğinin sağlanması ve geliştirilmesi için gerekli olan verileri işlemek, gereksiz veri toplamamak ve kullanıcıya verileri üzerinde mümkün olduğunca açık kontrol sağlamaktır.

Bu metin, Plango’nun genel gizlilik yaklaşımını açıklar. Kişisel verilerin elde edilmesi sırasında yerine getirilmesi gereken KVKK aydınlatma yükümlülüğü ve açık rıza gerektiren özel işlemler, gerekli olduğu ölçüde ayrıca ve ilgili işlem bağlamında sunulabilir.

2. Kapsam
Bu politika; Plango mobil uygulaması, uygulama içerisindeki kullanıcı hesapları, FP Engine, kayıtlı planlar, danışma sistemi, doğrulanmış uzman sistemi, şirket bilgi ekranları, bildirim merkezi, geri bildirim alanları ve Plango tarafından sunulan diğer dijital özellikler bakımından uygulanır.

Bir özellik Plango dışındaki üçüncü taraf bir internet sitesine, uygulamaya veya hizmete yönlendiriyorsa, o hizmetin kendi gizlilik politikası ve kullanım koşulları geçerli olabilir.

Plango’nun gelecekte yeni özellikler sunması halinde, bu politika yeni veri işleme faaliyetlerini yansıtacak şekilde güncellenebilir.

3. Temel Gizlilik İlkelerimiz
Plango kişisel verilerin işlenmesinde hukuka ve dürüstlük kurallarına uygunluk, doğruluk ve gerektiğinde güncellik, belirli ve meşru amaçlarla işleme, amaçla bağlantılı ve ölçülü olma ve gerekli süre kadar saklama ilkelerini esas almayı hedefler.

Veri minimizasyonu Plango’nun önemli ürün ilkelerinden biridir. Bir özelliğin çalışması için gerekli olmayan kişisel verilerin talep edilmemesi ve işlenmemesi hedeflenir.

Kullanıcı verilerinin ticari değer üretmek amacıyla gereksiz şekilde toplanması Plango’nun ürün yaklaşımıyla bağdaşmaz.

4. Hesap Oluştururken İşlenebilecek Bilgiler
Kullanıcı Plango’da hesap oluşturduğunda ad, soyad, e-posta adresi, kullanıcı kimliği ve hesap güvenliğiyle ilişkili teknik bilgiler işlenebilir.

Parola doğrulama işlemleri Plango’nun kullandığı kimlik doğrulama altyapısı üzerinden yürütülebilir. Plango’nun kullanıcı parolasını okunabilir biçimde saklamaması hedeflenir.

Hesap bilgileri; kullanıcı hesabının oluşturulması, oturum açılması, hesap güvenliğinin sağlanması, profil bilgilerinin görüntülenmesi ve kullanıcıya hesapla bağlantılı özelliklerin sunulması amacıyla kullanılabilir.

5. Profil Bilgileri
Kullanıcı profilinde paylaşılan ad, soyad, e-posta ve benzeri bilgiler hesap yönetimi amacıyla işlenebilir.

Kullanıcı tarafından güncellenebilen profil bilgilerinin mümkün olduğunca güncel tutulması kullanıcının sorumluluğundadır.

Plango, profil özelliğinin gerektirmediği kişisel bilgileri zorunlu hale getirmemeyi hedefler.

6. FP Engine Verileri
FP Engine kullanılırken kullanıcı tarafından girilen finansman tutarı, peşinat, aylık taksit, ödeme modeli, artış oranı, artış periyodu ve benzeri planlama verileri işlenebilir.

Bu veriler doğrudan kimlik bilgisi olmak zorunda değildir; ancak bir kullanıcı hesabıyla ilişkilendirilerek kaydedildiğinde kullanıcıyla bağlantılı veri haline gelebilir.

FP Engine verileri hesaplama işlemini gerçekleştirmek, ödeme planı üretmek, tahmini teslim ve vade sonuçlarını göstermek ve kullanıcının talep ettiği özellikleri sunmak amacıyla kullanılır.

7. Son Hesaplanan Plan
Plango, kullanıcı deneyimini kolaylaştırmak amacıyla cihaz üzerinde veya uygulamanın uygun veri alanlarında en son hesaplanan plana ilişkin sınırlı bilgileri tutabilir.

Bu kayıt, kullanıcının ana sayfada son çalıştığı plana hızlı şekilde ulaşmasını sağlamak amacıyla kullanılabilir.

Son hesaplanan plan ile kullanıcı tarafından özellikle kaydedilen plan birbirinden farklı veri kayıtları olabilir.

8. Kayıtlı Planlar
Kullanıcı bir planı kaydetmeyi seçtiğinde finansman tutarı, peşinat, taksit, vade, tahmini teslim bilgisi, ödeme modeli ve planın çalışması için gerekli diğer hesaplama verileri kullanıcı hesabıyla ilişkilendirilerek saklanabilir.

Kayıtlı planların amacı, kullanıcının daha önce oluşturduğu planlara tekrar ulaşabilmesini sağlamaktır.

Kullanıcı ilgili özellik üzerinden kayıtlı planlarını görüntüleyebilir ve silme işlemi sunulduğu ölçüde bu kayıtları kaldırabilir.

9. Ödeme Planı ve PDF Verileri
Plango, kullanıcının hesaplama sonucu oluşan ödeme planını ekranda gösterebilir ve kullanıcı talep ederse PDF benzeri bir çıktı oluşturabilir.

PDF oluşturma işlemi sırasında plan verileri belgenin hazırlanması için geçici olarak işlenebilir. Kullanıcının cihazına kaydettiği veya başka bir uygulamayla paylaştığı dosyaların daha sonraki kullanımı, cihazın ve seçilen üçüncü taraf uygulamanın kendi koşullarına tabi olabilir.

Plango, kullanıcı tarafından cihaz dışına aktarılan dosyaların sonradan kimlerle paylaşılacağını kontrol edemez.

10. Danışma Talepleri
Kullanıcı Plango üzerinden danışma talebi gönderdiğinde ad, soyad, iletişim bilgileri, kullanıcı notu, ilgili plan bilgileri ve talebin yönetilmesi için gerekli diğer bilgiler işlenebilir.

Bu verilerin amacı kullanıcının talebini uygun uzman veya ilgili süreçle eşleştirmek, talep durumunu yönetmek ve kullanıcı ile uzman arasındaki iletişimi kontrollü biçimde kolaylaştırmaktır.

Danışma talebinde gereksiz veya özel nitelikli kişisel verilerin paylaşılmaması önerilir.

11. Danışma Talebi İletişim Bilgileri
Danışma sürecinde kullanıcının telefon numarası veya e-posta adresi gibi iletişim bilgileri, yalnızca ilgili sürecin gerektirdiği aşamada ve yetkilendirilmiş uzmanla paylaşılabilir.

Plango, danışma talebi oluşturulduğu anda tüm iletişim bilgilerini herkes tarafından görülebilir hale getirmemeyi hedefler.

İletişim bilgilerinin erişimi, kullanıcı güvenliği ve danışma sürecinin işleyişi dikkate alınarak sınırlandırılabilir.

12. Uzman Hesapları
Uzman hesabı veya uzman başvurusu kapsamında ad, soyad, e-posta, iletişim bilgileri, çalışılan şirket, şehir, doğrulama durumu ve uzmanlık hesabının yönetilmesi için gerekli bilgiler işlenebilir.

Uzman doğrulamasının amacı kullanıcıların sektörde çalışan kişilerle daha güvenli bir şekilde iletişim kurabilmesini desteklemektir.

Doğrulama amacı dışında gerekli olmayan belgelerin veya kişisel verilerin saklanmaması hedeflenir.

13. Uzman Doğrulama Verileri
Uzman doğrulaması şirket e-posta alan adı, doğrulama kodu, yönetici incelemesi veya Plango tarafından belirlenen başka güvenli yöntemlerle gerçekleştirilebilir.

Doğrulama sürecinde işlenen veriler yalnızca uzmanın ilgili kurumla bağlantısının veya başvuru bilgilerinin doğrulanması amacıyla kullanılmalıdır.

Doğrulama işlemi tamamlandıktan sonra doğrulama amacıyla artık gerekli olmayan verilerin saklanma ihtiyacı ayrıca değerlendirilir.

14. Uzman Performans ve Değerlendirme Bilgileri
Danışma sistemi kapsamında uzmanla ilgili talep durumu, dönüş bilgisi, kullanıcı değerlendirmesi, kalite puanı veya benzeri performans verileri işlenebilir.

Bu veriler platform kalitesinin korunması, uzman sisteminin güvenli şekilde yönetilmesi ve kullanıcı deneyiminin geliştirilmesi amacıyla kullanılabilir.

Değerlendirme sisteminin kişileri haksız şekilde itibarsızlaştıracak biçimde kullanılmaması ve gerekli durumlarda yönetici incelemesine tabi tutulabilmesi hedeflenir.

15. Şikayet ve Öneri Verileri
Kullanıcı Şikayet ve Öneri alanı üzerinden geri bildirim gönderdiğinde mesaj içeriği, hesap bilgileri ve bildirimin yönetilmesi için gerekli teknik bilgiler işlenebilir.

Bu bilgiler kullanıcının geri bildirimini incelemek, gerektiğinde kullanıcıya dönüş yapmak, teknik veya içerik hatalarını düzeltmek ve Plango’yu geliştirmek amacıyla kullanılabilir.

Kullanıcının geri bildirim alanına gereksiz kişisel veya özel nitelikli veri yazmaması önerilir.

16. Bildirim Merkezi
Plango Bildirim Merkezi, kullanıcıya genel içerik güncellemeleri, hesapla ilgili durumlar veya uygulama içindeki önemli gelişmeleri göstermek amacıyla bildirim kayıtları oluşturabilir.

Bildirim kayıtları; bildirim türü, oluşturulma zamanı, okunma durumu ve ilgili içeriğe yönlendirme bilgisi gibi teknik verileri içerebilir.

Bildirim sisteminin kullanıcı davranışlarını gereksiz şekilde profillemek amacıyla kullanılmaması hedeflenir.

17. Teknik ve Güvenlik Verileri
Uygulamanın güvenli ve kararlı şekilde çalışabilmesi amacıyla oturum bilgileri, kullanıcı kimliği, hata kayıtları, uygulama sürümü, cihaz veya bağlantıyla ilişkili sınırlı teknik veriler işlenebilir.

Bu veriler güvenlik olaylarının tespit edilmesi, yetkisiz erişimin önlenmesi, hata giderme ve uygulama performansının geliştirilmesi amacıyla kullanılabilir.

Teknik veri toplama, hizmetin gerektirdiği ölçüyle sınırlı tutulmalıdır.

18. Cihaz İzinleri
Plango’nun bazı özellikleri cihaz üzerinde belirli izinlere ihtiyaç duyabilir. Böyle bir durumda izin talebi özelliğin ihtiyaç duyduğu anda ve mümkün olduğunca açık bir açıklamayla sunulmalıdır.

Plango, özelliğin çalışması için gerekli olmayan cihaz izinlerini zorunlu tutmamayı hedefler.

Kullanıcı cihaz ayarları üzerinden verdiği izinleri işletim sisteminin sunduğu imkanlar çerçevesinde yönetebilir.

19. Konum Verileri
Plango’nun mevcut temel hizmetleri için hassas veya sürekli konum takibi yapılması amaçlanmamaktadır.

Gelecekte şehir bazlı uzman veya şirket filtreleri gibi bir özellik için konum erişimi gerekirse, kullanıcıdan ilgili özellik bağlamında izin istenmesi ve konum verisinin yalnızca gerekli ölçüde kullanılması hedeflenir.

Açık bir ihtiyaç olmadan hassas konum verisi toplanmaması Plango’nun veri minimizasyonu yaklaşımının bir parçasıdır.

20. Özel Nitelikli Kişisel Veriler
Plango’nun temel hizmetlerinin sunulması için sağlık bilgisi, biyometrik veri, siyasi düşünce, dinî inanç veya benzeri özel nitelikli kişisel verilerin kullanıcıdan talep edilmesi hedeflenmemektedir.

Kullanıcıların serbest metin alanlarına veya danışma notlarına bu tür bilgileri yazmaması önerilir.

İleride özel nitelikli veri işlenmesini gerektiren yeni bir özellik geliştirilirse, bu faaliyet ayrı hukuki değerlendirmeye ve gerekli güvenlik önlemlerine tabi tutulmalıdır.

21. Çocuklara İlişkin Veriler
Plango’nun tasarruf finansmanı karar destek hizmetleri esas olarak kendi adına finansal değerlendirme yapabilecek yetişkin kullanıcılar için tasarlanmıştır.

Çocuklara ait kişisel verilerin bilinçli ve sistematik şekilde toplanması Plango’nun temel hizmetinin amacı değildir.

Çocuklara ilişkin bir veri işlendiğinin fark edilmesi halinde, ilgili durum yürürlükteki mevzuat ve hizmet gereklilikleri çerçevesinde ayrıca değerlendirilebilir.

22. Verileri Hangi Amaçlarla Kullanabiliriz?
Kişisel veriler; kullanıcı hesabını oluşturmak ve yönetmek, kimlik doğrulamak, FP Engine hesaplamalarını gerçekleştirmek, kayıtlı planları saklamak, danışma taleplerini yönetmek, uzman doğrulaması yapmak, bildirimleri göstermek, geri bildirimleri değerlendirmek, güvenliği sağlamak ve hizmet kalitesini geliştirmek gibi amaçlarla işlenebilir.

Her veri işleme faaliyetinin belirli, açık ve meşru bir amaca dayanması hedeflenir.

Bir amaç için toplanan verinin, kullanıcı açısından beklenmeyen ve ilgisiz başka amaçlarla kullanılmaması Plango’nun gizlilik yaklaşımının temel parçasıdır.

23. Hukuki Sebepler
Kişisel verilerin işlenmesi, ilgili veri işleme faaliyetinin niteliğine göre 6698 sayılı Kişisel Verilerin Korunması Kanunu’nda öngörülen hukuki sebeplerden uygun olanına dayanmalıdır.

Bir veri işleme faaliyeti açık rıza gerektiriyorsa, açık rızanın aydınlatma metninden ayrı ve özgür iradeyle verilebilmesi gerekir.

Açık rıza gerektirmeyen bir işleme faaliyetinin sırf kolaylık sağlamak amacıyla zorunlu açık rızaya bağlanmaması Plango’nun uyum yaklaşımının parçasıdır.

24. Aydınlatma ve Açık Rıza Ayrımı
Aydınlatma yükümlülüğü ile açık rıza aynı işlem değildir.

Kullanıcıya kişisel verilerinin kim tarafından, hangi amaçla, hangi yöntem ve hukuki sebeple işlendiği, kimlere aktarılabileceği ve haklarının neler olduğu açık biçimde bildirilmelidir.

Açık rıza gereken faaliyetlerde ise kullanıcıya ayrıca ve özgür iradesiyle seçim yapabileceği bir onay mekanizması sunulmalıdır.

Plango, aydınlatma metni ile açık rıza metinlerini gerektiğinde ayrı şekilde sunmayı hedefler.

25. Verilerin Aktarılması
Kişisel veriler, hizmetin sunulması için gerekli olduğu ölçüde yetkilendirilmiş hizmet sağlayıcılar, teknik altyapı sağlayıcıları, ilgili uzmanlar veya hukuken yetkili kurumlarla paylaşılabilir.

Her aktarımın amacı, kapsamı ve hukuki dayanağı ayrı değerlendirilmelidir.

Plango kullanıcı verilerini ilgisiz üçüncü kişilere keyfî biçimde aktarmamayı ve veri paylaşımını hizmetin gerektirdiği ölçüyle sınırlandırmayı hedefler.

26. Uzmanlarla Veri Paylaşımı
Danışma sistemi kapsamında kullanıcı verilerinin yalnızca ilgili talebin yürütülmesi için gerekli olan kısmı yetkilendirilmiş uzmanla paylaşılabilir.

Uzmanın erişebildiği veriler, danışma sürecinin durumuna göre sınırlandırılabilir.

Uzmanların Plango üzerinden elde ettiği kullanıcı verilerini danışma amacı dışında kullanmaması, izinsiz olarak üçüncü kişilerle paylaşmaması ve güvenliğini koruması beklenir.

27. Şirketlerle Veri Paylaşımı
Plango’nun kullanıcı adına otomatik olarak tasarruf finansman şirketine başvuru yapması temel hizmetin parçası değildir.

Kullanıcının açık şekilde başvuru veya iletişim talebinde bulunacağı gelecekteki özelliklerde, hangi verinin hangi şirkete hangi amaçla aktarılacağı kullanıcıya ayrıca açıklanmalıdır.

Kullanıcının bilgisi dışında şirketlere pazarlama amacıyla kişisel veri aktarılması Plango’nun gizlilik yaklaşımıyla bağdaşmaz.

28. Kamu Kurumları ve Yasal Talepler
Plango, yürürlükteki mevzuatın gerektirdiği veya yetkili kamu kurumlarının hukuka uygun talebi bulunduğu durumlarda belirli kişisel verileri paylaşmak zorunda kalabilir.

Bu tür paylaşımların talebin kapsamıyla sınırlı olması ve yalnızca hukuken gerekli verilerin aktarılması hedeflenir.

Mevzuatın izin verdiği ölçüde kullanıcı gizliliğinin korunması esastır.

29. Bulut ve Teknik Hizmet Sağlayıcıları
Plango; kimlik doğrulama, veri saklama, uygulama altyapısı, hata izleme veya benzeri teknik hizmetlerde üçüncü taraf teknoloji sağlayıcılarından yararlanabilir.

Bu sağlayıcılar, sundukları hizmetin niteliğine göre kullanıcı verilerini Plango adına işleyebilir.

Teknik sağlayıcı seçiminde güvenlik, veri koruma yükümlülükleri ve hizmetin gerektirdiği veri kapsamı dikkate alınmalıdır.

30. Yurt Dışına Veri Aktarımı
Plango’nun kullandığı bazı teknik altyapı veya bulut hizmetlerinin sunucuları Türkiye dışında bulunabilir ya da hizmet kapsamında yurt dışına veri aktarımı gündeme gelebilir.

Yurt dışına kişisel veri aktarımı söz konusu olduğunda yürürlükteki KVKK düzenlemeleri ve uygun aktarım mekanizmaları dikkate alınmalıdır.

Plango, yurt dışına aktarım faaliyetlerini gerekli hukuki ve teknik değerlendirmeler yapılmadan gerçekleştirmemeyi hedefler.

31. Veri Saklama Süreleri
Kişisel veriler, işlendikleri amaç için gerekli olan süre boyunca veya ilgili mevzuatta öngörülen saklama süresi kadar muhafaza edilmelidir.

Her veri kategorisi için aynı saklama süresi uygulanmak zorunda değildir. Hesap bilgileri, danışma kayıtları, güvenlik kayıtları ve destek talepleri farklı ihtiyaçlara sahip olabilir.

Saklama ihtiyacı sona erdiğinde verilerin silinmesi, yok edilmesi veya anonim hale getirilmesi ilgili teknik ve hukuki koşullar çerçevesinde değerlendirilir.

32. Hesap Silme
Plango kullanıcıya hesabını silme imkanı sunmayı hedefler.

Hesap silme talebi sonrasında, hesabın aktif kullanım için gerekli verileri silinebilir veya erişilemez hale getirilebilir. Ancak yasal saklama zorunluluğu bulunan, güvenlik veya uyuşmazlık çözümü için belirli süre tutulması gereken kayıtlar ilgili süre boyunca saklanabilir.

Hesabın silinmesi, kullanıcının cihazına daha önce indirdiği PDF gibi dosyaları otomatik olarak silmez.

33. Planların Silinmesi
Kullanıcı tarafından kaydedilmiş planlar, uygulamanın sunduğu silme özelliği üzerinden kaldırılabilir.

Plan silme işlemi kullanıcı arayüzünden tamamlandığında, ilgili verinin aktif kullanıcı deneyiminden kaldırılması hedeflenir.

Teknik yedekler veya güvenlik kopyalarında bulunan verilerin tamamen ortadan kalkması, kullanılan altyapının yedekleme ve imha döngülerine bağlı olarak belirli bir süre alabilir.

34. Veri Güvenliği
Plango kişisel verilerin hukuka aykırı işlenmesini veya erişilmesini önlemek ve verilerin güvenli şekilde muhafazasını sağlamak amacıyla uygun teknik ve idari önlemler uygulamayı hedefler.

Yetkilendirme kuralları, kullanıcı kimlik doğrulaması, rol bazlı erişim, veri erişim kontrolleri ve güvenli yazılım geliştirme uygulamaları bu yaklaşımın parçaları olabilir.

Hiçbir dijital sistem mutlak güvenlik garantisi sunamaz. Bu nedenle güvenlik önlemlerinin düzenli olarak gözden geçirilmesi ve geliştirilmesi gerekir.

35. Hesap Güvenliği
Kullanıcı kendi hesabının güvenliğini korumak için güçlü ve benzersiz bir parola kullanmalı, doğrulama kodlarını üçüncü kişilerle paylaşmamalı ve hesabına izinsiz erişim şüphesi olduğunda gerekli güvenlik adımlarını uygulamalıdır.

Plango hiçbir uzmanın veya çalışan olduğunu iddia eden kişinin kullanıcıdan banka şifresi, kart şifresi veya tek kullanımlık güvenlik kodu istemesini normal bir uygulama olarak kabul etmez.

Şüpheli durumların Plango’ya bildirilmesi güvenliğin geliştirilmesine yardımcı olabilir.

36. Veri İhlali Durumları
Kişisel verilerin güvenliğini etkileyen bir olay meydana gelmesi halinde olayın kapsamının belirlenmesi, gerekli teknik tedbirlerin alınması ve yürürlükteki mevzuatın gerektirdiği bildirim süreçlerinin değerlendirilmesi gerekir.

Plango, olası güvenlik ihlallerini ciddiyetle ele almayı ve gerekli düzeltici önlemleri mümkün olan en kısa sürede uygulamayı hedefler.

Kullanıcının hesabıyla ilgili şüpheli bir işlem fark etmesi halinde Plango’ya bildirimde bulunması önerilir.

37. Analitik ve Ürün Geliştirme
Plango’nun hangi özelliklerinin kullanıldığı, hangi ekranlarda hata oluştuğu veya uygulamanın teknik performansı gibi veriler ürün geliştirme amacıyla analiz edilebilir.

Analitik faaliyetlerin mümkün olduğunca kullanıcı mahremiyetine saygılı, amaçla sınırlı ve ölçülü biçimde yürütülmesi hedeflenir.

Kişisel kullanıcı profili oluşturmak veya kullanıcının finansal durumunu gereksiz şekilde sınıflandırmak Plango’nun temel analitik amacı değildir.

38. Reklam ve Pazarlama
Plango gelecekte reklam veya ticari iletişim özellikleri sunarsa, kişisel verilerin pazarlama amacıyla kullanılması ayrı bir değerlendirmeye tabi tutulmalıdır.

Elektronik ticari ileti, hedefli pazarlama veya benzeri faaliyetlerin ilgili mevzuatın gerektirdiği izin ve bilgilendirme süreçleri olmadan yürütülmemesi hedeflenir.

FP Engine hesaplama verilerinin kullanıcıyı haberi olmadan belirli bir şirkete pazarlamak amacıyla kullanılmaması Plango’nun bağımsızlık ve gizlilik ilkelerinin bir parçasıdır.

39. Çerezler ve Benzeri Teknolojiler
Plango’nun web tabanlı veya gelecekte sunulabilecek internet hizmetlerinde çerezler, yerel depolama veya benzeri teknolojiler kullanılabilir.

Bu teknolojilerin zorunlu, analitik veya pazarlama amaçları birbirinden farklı olabilir.

Zorunlu olmayan çerez veya benzeri teknolojilerin kullanılması halinde, ilgili hizmetin niteliğine göre kullanıcıya ayrıca bilgi verilmesi ve gerekli tercih mekanizmalarının sunulması değerlendirilecektir.

40. Kullanıcının KVKK Kapsamındaki Hakları
İlgili kişiler, 6698 sayılı Kanunun 11. maddesi kapsamındaki şartlar doğrultusunda kişisel verilerinin işlenip işlenmediğini öğrenme, işlenmişse buna ilişkin bilgi talep etme, işleme amacını ve amaca uygun kullanılıp kullanılmadığını öğrenme, verilerin aktarıldığı kişileri bilme ve Kanunda düzenlenen diğer haklarını kullanabilir.

Kanuni şartların oluşması halinde kullanıcı, kişisel verilerin düzeltilmesini, silinmesini veya yok edilmesini talep edebilir ve gerçekleştirilen işlemlerin ilgili üçüncü kişilere bildirilmesini isteyebilir.

Başvuruların kimlik doğrulamasını sağlayacak ve kullanıcı güvenliğini koruyacak uygun yöntemlerle alınması hedeflenir.

41. Başvuru ve İletişim
Kullanıcılar gizlilik, kişisel veri veya hesap verileriyle ilgili talep ve sorularını Plango tarafından ilan edilen iletişim kanalları üzerinden iletebilir.

KVKK kapsamındaki resmî başvurular için veri sorumlusunun kimliği, başvuru yöntemi ve iletişim bilgileri ayrıca açık ve güncel şekilde yayımlanmalıdır.

Plango’nun tüzel kişilik, veri sorumlusu ve resmî iletişim bilgileri kesinleştiğinde bu alanların politika ve aydınlatma metinlerinde açıkça belirtilmesi gerekir.

42. Gizlilik Politikasındaki Değişiklikler
Plango’nun hizmet kapsamı, teknik altyapısı veya yasal yükümlülükleri değiştikçe bu Gizlilik Politikası güncellenebilir.

Önemli değişikliklerde kullanıcıların güncel politika hakkında bilgilendirilmesini sağlayacak uygulama içi yöntemler kullanılabilir.

Güncel politika uygulama içerisinden erişilebilir şekilde tutulmalıdır.

43. Gizlilik ve Bağımsızlık İlişkisi
Plango’nun bağımsızlık ilkesi yalnızca şirket sıralaması veya hesaplama sonuçlarıyla sınırlı değildir.

Kullanıcı verilerinin belirli şirketlerin satış hedefleri için gizli şekilde kullanılması veya kullanıcıların finansal senaryolarının habersiz biçimde pazarlama profiline dönüştürülmesi Plango’nun bağımsızlık yaklaşımıyla bağdaşmaz.

Kullanıcının Plango’ya duyduğu güvenin korunması, ürünün uzun vadeli değerinin temel unsurlarından biridir.

44. Son Bilgilendirme
Plango’nun gizlilik yaklaşımının temelinde mümkün olduğunca az veri toplamak, toplanan veriyi açık amaçlarla kullanmak, kullanıcı güvenliğini korumak ve veriler üzerinde kullanıcıya şeffaflık sağlamak vardır.

Bu politika Plango’nun genel gizlilik çerçevesini açıklar. Belirli veri işleme faaliyetleri için ayrıca KVKK Aydınlatma Metni, açık rıza metni, kullanıcı sözleşmesi veya uzman sözleşmesi sunulabilir.

Kullanıcı gizliliği Plango açısından yalnızca yasal bir yükümlülük değil, ürün güveninin temel bir parçasıdır.''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: _background,
        foregroundColor: _navy,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          widget.completeAnonymousAccount
              ? 'Hesabınızı Tamamlayın'
              : 'Hesap Oluştur',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _RegisterHeader(
                  completeAnonymousAccount:
                      widget.completeAnonymousAccount,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: _border,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _navy.withValues(alpha: 0.035),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _nameController,
                                enabled: !_isSubmitting,
                                textCapitalization:
                                    TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [
                                  AutofillHints.givenName,
                                ],
                                decoration: _inputDecoration(
                                  label: 'Ad',
                                  icon: Icons.person_outline_rounded,
                                ),
                                validator: (value) {
                                  return _requiredValidator(value, 'Ad');
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _surnameController,
                                enabled: !_isSubmitting,
                                textCapitalization:
                                    TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [
                                  AutofillHints.familyName,
                                ],
                                decoration: _inputDecoration(
                                  label: 'Soyad',
                                  icon: Icons.badge_outlined,
                                ),
                                validator: (value) {
                                  return _requiredValidator(
                                    value,
                                    'Soyad',
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          enabled: !_isSubmitting,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [
                            AutofillHints.email,
                          ],
                          decoration: _inputDecoration(
                            label: 'E-posta',
                            hint: 'ornek@eposta.com',
                            icon: Icons.mail_outline_rounded,
                          ),
                          validator: _emailValidator,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          enabled: !_isSubmitting,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [
                            AutofillHints.telephoneNumber,
                          ],
                          decoration: _inputDecoration(
                            label: 'Telefon',
                            hint: '05XX XXX XX XX',
                            icon: Icons.phone_outlined,
                          ),
                          validator: _phoneValidator,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          enabled: !_isSubmitting,
                          obscureText: !_passwordVisible,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [
                            AutofillHints.newPassword,
                          ],
                          decoration: _inputDecoration(
                            label: 'Şifre',
                            hint: 'En az 8 karakter',
                            icon: Icons.lock_outline_rounded,
                            suffixIcon: IconButton(
                              tooltip: _passwordVisible
                                  ? 'Şifreyi gizle'
                                  : 'Şifreyi göster',
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: _textMuted,
                              ),
                            ),
                          ),
                          validator: _passwordValidator,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordAgainController,
                          enabled: !_isSubmitting,
                          obscureText: !_passwordAgainVisible,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [
                            AutofillHints.newPassword,
                          ],
                          decoration: _inputDecoration(
                            label: 'Şifre Tekrar',
                            hint: 'Şifrenizi tekrar girin',
                            icon: Icons.lock_reset_rounded,
                            suffixIcon: IconButton(
                              tooltip: _passwordAgainVisible
                                  ? 'Şifreyi gizle'
                                  : 'Şifreyi göster',
                              onPressed: () {
                                setState(() {
                                  _passwordAgainVisible =
                                      !_passwordAgainVisible;
                                });
                              },
                              icon: Icon(
                                _passwordAgainVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: _textMuted,
                              ),
                            ),
                          ),
                          validator: _passwordAgainValidator,
                          onFieldSubmitted: (_) {
                            if (!_isSubmitting) {
                              _createAccount();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _LegalConfirmationTile(
                  isChecked: _membershipAccepted,
                  textBeforeLink: '',
                  linkText: 'Üyelik Sözleşmesi',
                  textAfterLink: '\'ni kabul ediyorum.',
                  onTapLink: () {
                    _openLegalDocument(
                      title: 'Üyelik Sözleşmesi',
                      confirmationText:
                          'Okudum, anladım ve kabul ediyorum',
                      documentText: _membershipAgreementText,
                       onConfirmed: () {
                        _membershipAccepted = true;
                      },
                    );
                  },
                  onChanged: (_) {
                    if (!_membershipAccepted) {
                      _openLegalDocument(
                        title: 'Üyelik Sözleşmesi',
                        confirmationText:
                            'Okudum, anladım ve kabul ediyorum',
                        documentText: _membershipAgreementText,
                       onConfirmed: () {
                          _membershipAccepted = true;
                        },
                      );
                    } else {
                      setState(() {
                        _membershipAccepted = false;
                      });
                    }
                  },
                ),
                _LegalConfirmationTile(
                  isChecked: _clarificationAcknowledged,
                  textBeforeLink: '',
                  linkText: 'Aydınlatma Metni',
                  textAfterLink: ' hakkında bilgilendirildim.',
                  onTapLink: () {
                    _openLegalDocument(
                      title: 'Aydınlatma Metni',
                      confirmationText: 'Bilgilendirildim',
                      documentText: _clarificationText,
                       onConfirmed: () {
                        _clarificationAcknowledged = true;
                      },
                    );
                  },
                  onChanged: (_) {
                    if (!_clarificationAcknowledged) {
                      _openLegalDocument(
                        title: 'Aydınlatma Metni',
                        confirmationText: 'Bilgilendirildim',
                        documentText: _clarificationText,
                       onConfirmed: () {
                          _clarificationAcknowledged = true;
                        },
                      );
                    } else {
                      setState(() {
                        _clarificationAcknowledged = false;
                      });
                    }
                  },
                ),
                _LegalConfirmationTile(
                  isChecked: _privacyAccepted,
                  textBeforeLink: '',
                  linkText: 'Gizlilik Politikası',
                  textAfterLink: '\'nı okudum ve anladım.',
                  onTapLink: () {
                    _openLegalDocument(
                      title: 'Gizlilik Politikası',
                      confirmationText: 'Okudum ve anladım',
                      documentText: _privacyPolicyText,
                       onConfirmed: () {
                        _privacyAccepted = true;
                      },
                    );
                  },
                  onChanged: (_) {
                    if (!_privacyAccepted) {
                      _openLegalDocument(
                        title: 'Gizlilik Politikası',
                        confirmationText: 'Okudum ve anladım',
                        documentText: _privacyPolicyText,
                       onConfirmed: () {
                          _privacyAccepted = true;
                        },
                      );
                    } else {
                      setState(() {
                        _privacyAccepted = false;
                      });
                    }
                  },
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed:
                      _isSubmitting ? null : _createAccount,
                  style: FilledButton.styleFrom(
                    backgroundColor: _teal,
                    disabledBackgroundColor:
                        _teal.withValues(alpha: 0.55),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(58),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 23,
                          height: 23,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          widget.completeAnonymousAccount
                              ? 'Hesabımı Tamamla'
                              : 'Hesap Oluştur',
                        ),
                ),
                if (!widget.completeAnonymousAccount) ...[
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Zaten hesabınız var mı?',
                        style: TextStyle(
                          color: _textMuted,
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const UserLoginScreen(),
                            ),
                            (route) => route.isFirst,
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: _teal,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        child: const Text('Giriş Yap'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: _teal,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: _background,
      labelStyle: const TextStyle(
        color: _textMuted,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: TextStyle(
        color: _textMuted.withValues(alpha: 0.75),
        fontSize: 13.5,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: _border,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: _border,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: _teal,
          width: 1.7,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Color(0xFFB42318),
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Color(0xFFB42318),
          width: 1.6,
        ),
      ),
    );
  }
}

class _RegisterHeader extends StatelessWidget {
  const _RegisterHeader({
    required this.completeAnonymousAccount,
  });

  final bool completeAnonymousAccount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _RegisterIcon(),
        const SizedBox(height: 16),
        Text(
          completeAnonymousAccount
              ? 'Hesabınızı Tamamlayın'
              : 'Plango Hesabınızı Oluşturun',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _RegisterScreenState._textDark,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          completeAnonymousAccount
              ? 'Danışma talebiniz aynı hesapta korunacak ve '
                  'durumunu uygulama üzerinden takip edebileceksiniz.'
              : 'Planlarınızı kaydedin ve danışma taleplerinizi '
                  'kolayca takip edin.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _RegisterScreenState._textMuted,
            fontSize: 14.5,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _RegisterIcon extends StatelessWidget {
  const _RegisterIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: _RegisterScreenState._softTeal,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _RegisterScreenState._teal.withValues(alpha: 0.16),
        ),
      ),
      child: const Icon(
        Icons.person_add_alt_1_outlined,
        color: _RegisterScreenState._teal,
        size: 31,
      ),
    );
  }
}

class _LegalConfirmationTile extends StatelessWidget {
  final bool isChecked;
  final String textBeforeLink;
  final String linkText;
  final String textAfterLink;
  final VoidCallback onTapLink;
  final ValueChanged<bool?> onChanged;

  const _LegalConfirmationTile({
    required this.isChecked,
    required this.textBeforeLink,
    required this.linkText,
    required this.textAfterLink,
    required this.onTapLink,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!isChecked),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: isChecked,
              onChanged: onChanged,
              activeColor: _RegisterScreenState._teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(width: 3),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: _RegisterScreenState._textDark,
                      fontSize: 13.5,
                      height: 1.45,
                    ),
                    children: [
                      TextSpan(text: textBeforeLink),
                      TextSpan(
                        text: linkText,
                        style: const TextStyle(
                          color: _RegisterScreenState._teal,
                          fontWeight: FontWeight.w900,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = onTapLink,
                      ),
                      TextSpan(text: textAfterLink),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class _LegalDocumentText extends StatelessWidget {
  const _LegalDocumentText({
    required this.text,
  });

  final String text;

  bool _isHeading(String line) {
    final String value = line.trim();

    if (value.isEmpty) {
      return false;
    }

    // Belge ana başlığı.
    if (value.startsWith('PLANGO ')) {
      return true;
    }

    // 1. Başlık, 2. Başlık, 10. Başlık vb.
    return RegExp(r'^\d+\.\s+\S').hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    final List<String> lines = text.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final String line in lines) ...[
          if (line.trim().isEmpty)
            const SizedBox(height: 10)
          else
            Text(
              line,
              style: TextStyle(
                color: _RegisterScreenState._textDark,
                fontSize: line.startsWith('PLANGO ') ? 16 : 14.5,
                height: 1.6,
                fontWeight: _isHeading(line)
                    ? FontWeight.w800
                    : FontWeight.w400,
              ),
            ),
        ],
      ],
    );
  }
}

class _LegalDocumentDialog extends StatefulWidget {
  const _LegalDocumentDialog({
    required this.title,
    required this.confirmationText,
    required this.documentText,
  });

  final String title;
  final String confirmationText;
  final String documentText;

  @override
  State<_LegalDocumentDialog> createState() =>
      _LegalDocumentDialogState();
}

class _LegalDocumentDialogState extends State<_LegalDocumentDialog> {
  final ScrollController _scrollController = ScrollController();
  bool _reachedBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_checkScrollPosition);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkScrollPosition();
    });
  }

  void _checkScrollPosition() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final reachedBottom = position.maxScrollExtent <= 0 ||
        position.pixels >= position.maxScrollExtent - 12;

    if (reachedBottom != _reachedBottom && mounted) {
      setState(() => _reachedBottom = reachedBottom);
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_checkScrollPosition)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 22,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 760,
          maxHeight: size.height * 0.88,
        ),
        child: Material(
          color: _RegisterScreenState._background,
          borderRadius: BorderRadius.circular(24),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(18, 16, 12, 14),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: _RegisterScreenState._border,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: _RegisterScreenState._softTeal,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.description_outlined,
                        color: _RegisterScreenState._teal,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              color: _RegisterScreenState._navy,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Belgeyi sonuna kadar inceleyin.',
                            style: TextStyle(
                              color: _RegisterScreenState._textMuted,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Kapat',
                      onPressed: () => Navigator.pop(context, false),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: const Color(0xFFF1F4F7),
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Center(
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 680),
                        padding: const EdgeInsets.fromLTRB(26, 30, 26, 34),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 18,
                              offset: const Offset(0, 7),
                            ),
                          ],
                        ),
                        child: _LegalDocumentText(
                          text: widget.documentText,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: _RegisterScreenState._border,
                    ),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _reachedBottom
                        ? () => Navigator.pop(context, true)
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: _RegisterScreenState._teal,
                      disabledBackgroundColor: const Color(0xFFB8C5CB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    child: Text(
                      _reachedBottom
                          ? widget.confirmationText
                          : 'Belgeyi sonuna kadar inceleyin',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
