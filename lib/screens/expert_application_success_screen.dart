import 'package:flutter/material.dart';

class ExpertApplicationSuccessScreen extends StatelessWidget {
  const ExpertApplicationSuccessScreen({
    super.key,
  });

  static const Color _navy = Color(0xFF0B2239);
  static const Color _petrol = Color(0xFF052F3D);
  static const Color _teal = Color(0xFF087C72);
  static const Color _background = Color(0xFFF7F9FB);
  static const Color _textDark = _navy;
  static const Color _textMuted = Color(0xFF748193);
  static const Color _softTeal = Color(0xFFE8F7F5);
  static const Color _border = Color(0xFFE4EBEE);

  void _returnToAccount(BuildContext context) {
    Navigator.of(context).popUntil(
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: _background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 30, 22, 30),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 520),
                padding: const EdgeInsets.fromLTRB(22, 30, 22, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: _border),
                  boxShadow: [
                    BoxShadow(
                      color: _petrol.withValues(alpha: 0.06),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 78,
                      height: 78,
                      decoration: BoxDecoration(
                        color: _softTeal,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.check_circle_outline_rounded,
                        color: _teal,
                        size: 43,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Başvurunuz Alındı',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _textDark,
                        fontSize: 23,
                        height: 1.2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Uzman başvurunuz başarıyla oluşturuldu.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _textDark,
                        fontSize: 14.5,
                        height: 1.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Şirket, şube, pozisyon ve kurumsal e-posta '
                      'bilgileriniz Tasarruf Planım yönetimi tarafından '
                      'incelenecektir. Başvuru sonucunuz uygulama '
                      'içerisinden size bildirilecektir.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _textMuted,
                        fontSize: 13.5,
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: _softTeal,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _teal.withValues(alpha: 0.10),
                        ),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.hourglass_top_rounded,
                            color: _teal,
                            size: 22,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Başvuru Durumu',
                                  style: TextStyle(
                                    color: _textDark,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'İnceleniyor',
                                  style: TextStyle(
                                    color: _teal,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.notifications_none_rounded,
                          color: _textMuted,
                          size: 19,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Başvurunuz onaylandığında, reddedildiğinde '
                            'veya ek bilgi gerektiğinde bildirim '
                            'alacaksınız.',
                            style: TextStyle(
                              color: _textMuted,
                              fontSize: 12.5,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    FilledButton(
                      onPressed: () => _returnToAccount(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: _teal,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      child: const Text('Hesabım Ekranına Dön'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
