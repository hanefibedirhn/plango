import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../engine/fp_engine.dart';
import '../models/calculation_plan.dart';

class PlangoPdfService {
  PlangoPdfService._();

  // ===========================================================================
  // FORMATS
  // ===========================================================================

  static final NumberFormat _moneyFormat = NumberFormat(
    '#,##0.##',
    'tr_TR',
  );

  static final DateFormat _longDateFormat = DateFormat(
    'd MMMM yyyy',
    'tr_TR',
  );

  // ===========================================================================
  // PLANGO DESIGN SYSTEM
  // ===========================================================================

  static const PdfColor _navy = PdfColor.fromInt(0xFF0B2239);
  static const PdfColor _petrol = PdfColor.fromInt(0xFF052F3D);
  static const PdfColor _deepPetrol = PdfColor.fromInt(0xFF032632);
  static const PdfColor _teal = PdfColor.fromInt(0xFF087C72);
  static const PdfColor _turquoise = PdfColor.fromInt(0xFF16C7B0);

  static const PdfColor _background = PdfColor.fromInt(0xFFF7F9FB);
  static const PdfColor _white = PdfColors.white;
  static const PdfColor _text = PdfColor.fromInt(0xFF10283A);
  static const PdfColor _muted = PdfColor.fromInt(0xFF748193);
  static const PdfColor _line = PdfColor.fromInt(0xFFE2E8EC);

  static const PdfColor _softTeal = PdfColor.fromInt(0xFFEAF8F5);
  static const PdfColor _deliveryBackground =
      PdfColor.fromInt(0xFFE4FAF6);
  static const PdfColor _financeBackground =
      PdfColor.fromInt(0xFFF1F6F9);
  static const PdfColor _lastBackground =
      PdfColor.fromInt(0xFFF2F4F6);

  // ===========================================================================
  // PUBLIC API
  // ===========================================================================

  static Future<void> saveToDevice({
    required CalculationPlan plan,
    required FpResult result,
    required String customerName,
    required DateTime createdAt,
    required String planNumber,
  }) async {
    final Uint8List bytes = await build(
      plan: plan,
      result: result,
      customerName: customerName,
      createdAt: createdAt,
      planNumber: planNumber,
    );

    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Plango_Finansal_Plan_Raporu_$planNumber.pdf',
    );
  }

  static Future<Uint8List> build({
    required CalculationPlan plan,
    required FpResult result,
    required String customerName,
    required DateTime createdAt,
    required String planNumber,
  }) async {
    final pw.Document document = pw.Document(
      title: 'Plango Finansal Plan Raporu',
      author: 'Plango FP Engine',
      creator: 'Plango',
      subject: 'Tahmini tasarruf finansmanı ödeme planı',
    );

    // Manrope: başlıklarda güçlü, rakamlarda temiz ve modern.
    final pw.Font regularFont =
        await PdfGoogleFonts.manropeRegular();
    final pw.Font mediumFont =
        await PdfGoogleFonts.manropeMedium();
    final pw.Font semiBoldFont =
        await PdfGoogleFonts.manropeSemiBold();
    final pw.Font boldFont =
        await PdfGoogleFonts.manropeBold();
    final pw.Font extraBoldFont =
        await PdfGoogleFonts.manropeExtraBold();

    final pw.ThemeData theme = pw.ThemeData.withFont(
      base: regularFont,
      bold: boldFont,
      italic: regularFont,
      boldItalic: boldFont,
    );

    final PaymentPlanItem? deliveryItem = _deliveryItem(result);

    final String deliveryDate = deliveryItem == null
        ? '-'
        : _longDateFormat.format(deliveryItem.paymentDate);

    final double deliverySaving =
        deliveryItem?.totalSaving ?? plan.downPayment;

    final double totalInstallments = result.paymentPlan.fold<double>(
      0,
      (double total, PaymentPlanItem item) {
        return total + item.installment;
      },
    );

    final double totalPayment =
        plan.downPayment + totalInstallments;

    final pw.MemoryImage heroImage = await _loadHeroImage();

    // -------------------------------------------------------------------------
    // SAYFA 1: Kapak + plan özeti. Ödeme tablosu bu sayfaya asla girmez.
    // -------------------------------------------------------------------------

    document.addPage(
      pw.Page(
        pageTheme: _pageTheme(theme),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              _buildCoverHero(
                createdAt: createdAt,
                planNumber: planNumber,
                heroImage: heroImage,
                mediumFont: mediumFont,
                semiBoldFont: semiBoldFont,
                boldFont: boldFont,
                extraBoldFont: extraBoldFont,
              ),
              pw.SizedBox(height: 20),
              _buildGreeting(
                customerName: customerName,
                mediumFont: mediumFont,
                extraBoldFont: extraBoldFont,
              ),
              pw.SizedBox(height: 17),
              _buildCoverSummary(
                plan: plan,
                result: result,
                deliveryDate: deliveryDate,
                deliverySaving: deliverySaving,
                mediumFont: mediumFont,
                semiBoldFont: semiBoldFont,
                boldFont: boldFont,
                extraBoldFont: extraBoldFont,
              ),
              pw.SizedBox(height: 14),
              _buildOrganizationFee(
                mediumFont: mediumFont,
                boldFont: boldFont,
              ),
              pw.Spacer(),
              _buildCoverFooter(
                planNumber: planNumber,
                boldFont: boldFont,
              ),
            ],
          );
        },
      ),
    );

    // -------------------------------------------------------------------------
    // SAYFA 2 VE DEVAMI: Ödeme planı tablosu.
    // MultiPage uzun vadelerde otomatik devam eder.
    // -------------------------------------------------------------------------

    document.addPage(
      pw.MultiPage(
        pageTheme: _pageTheme(theme),
        header: (pw.Context context) {
          return _buildStandardHeader(
            planNumber: planNumber,
            boldFont: boldFont,
            extraBoldFont: extraBoldFont,
          );
        },
        footer: (pw.Context context) {
          return _buildStandardFooter(
            context: context,
            boldFont: boldFont,
          );
        },
        build: (pw.Context context) {
          return [
            _buildPaymentPlanIntro(
              result: result,
              mediumFont: mediumFont,
              boldFont: boldFont,
              extraBoldFont: extraBoldFont,
            ),
            pw.SizedBox(height: 15),
            _buildPaymentTable(
              result: result,
              mediumFont: mediumFont,
              semiBoldFont: semiBoldFont,
              boldFont: boldFont,
            ),
            pw.SizedBox(height: 18),
            _buildPaymentNotes(
              plan: plan,
              mediumFont: mediumFont,
              boldFont: boldFont,
            ),
          ];
        },
      ),
    );

    // -------------------------------------------------------------------------
    // SON SAYFA: Plan özeti + FP Engine analizi.
    // -------------------------------------------------------------------------

    document.addPage(
      pw.Page(
        pageTheme: _pageTheme(theme),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              _buildStandardHeader(
                planNumber: planNumber,
                boldFont: boldFont,
                extraBoldFont: extraBoldFont,
              ),
              pw.SizedBox(height: 18),
              _buildFinalHero(
                customerName: customerName,
                planNumber: planNumber,
                mediumFont: mediumFont,
                boldFont: boldFont,
                extraBoldFont: extraBoldFont,
              ),
              pw.SizedBox(height: 17),
              _buildFinalMetrics(
                plan: plan,
                result: result,
                deliveryDate: deliveryDate,
                deliverySaving: deliverySaving,
                totalInstallments: totalInstallments,
                totalPayment: totalPayment,
                mediumFont: mediumFont,
                boldFont: boldFont,
              ),
              pw.SizedBox(height: 16),
              _buildEngineAnalysis(
                plan: plan,
                result: result,
                deliveryDate: deliveryDate,
                totalPayment: totalPayment,
                mediumFont: mediumFont,
                boldFont: boldFont,
                extraBoldFont: extraBoldFont,
              ),
              pw.SizedBox(height: 14),
              _buildClosingBanner(
                createdAt: createdAt,
                mediumFont: mediumFont,
                boldFont: boldFont,
              ),
              pw.SizedBox(height: 12),
              _buildDisclaimer(
                mediumFont: mediumFont,
              ),
              pw.Spacer(),
              _buildStandardFooter(
                context: context,
                boldFont: boldFont,
              ),
            ],
          );
        },
      ),
    );

    return document.save();
  }

  // ===========================================================================
  // PAGE CONFIGURATION
  // ===========================================================================

  static pw.PageTheme _pageTheme(pw.ThemeData theme) {
    return pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(
        28,
        26,
        28,
        28,
      ),
      theme: theme,
      buildBackground: (pw.Context context) {
        return pw.FullPage(
          ignoreMargins: true,
          child: pw.Container(
            color: _background,
          ),
        );
      },
    );
  }

  static Future<pw.MemoryImage> _loadHeroImage() async {
    const String assetPath = 'assets/images/plango_pdf_hero.png';

    try {
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();

      if (bytes.isEmpty) {
        throw FlutterError(
          'Plango PDF hero görseli boş: $assetPath',
        );
      }

      return pw.MemoryImage(bytes);
    } catch (error) {
      throw FlutterError(
        'Plango PDF hero görseli yüklenemedi.\n'
        'Beklenen dosya: $assetPath\n'
        'pubspec.yaml içinde assets/images/ tanımlı olmalıdır.\n'
        'Asıl hata: $error',
      );
    }
  }

  // ===========================================================================
  // COMMON BRAND COMPONENTS
  // ===========================================================================

  static pw.Widget _buildLogo({
    required double size,
    required pw.Font extraBoldFont,
    bool dark = false,
  }) {
    return pw.Container(
      width: size,
      height: size,
      decoration: pw.BoxDecoration(
        color: dark ? _petrol : _teal,
        borderRadius: pw.BorderRadius.circular(size * 0.27),
      ),
      child: pw.Stack(
        children: [
          pw.Positioned(
            left: size * 0.18,
            top: size * 0.05,
            child: pw.Text(
              'P',
              style: pw.TextStyle(
                color: _white,
                fontSize: size * 0.62,
                font: extraBoldFont,
              ),
            ),
          ),
          pw.Positioned(
            left: size * 0.39,
            bottom: size * 0.10,
            child: pw.Container(
              width: size * 0.08,
              height: size * 0.41,
              decoration: pw.BoxDecoration(
                color: _turquoise,
                borderRadius: pw.BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildStandardHeader({
    required String planNumber,
    required pw.Font boldFont,
    required pw.Font extraBoldFont,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: _line,
            width: 0.65,
          ),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(
            children: [
              _buildLogo(
                size: 28,
                extraBoldFont: extraBoldFont,
              ),
              pw.SizedBox(width: 9),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'PLANGO',
                    style: pw.TextStyle(
                      color: _navy,
                      fontSize: 12.5,
                      font: extraBoldFont,
                      letterSpacing: 1,
                    ),
                  ),
                  pw.Text(
                    'Planla • Karşılaştır • Karar Ver',
                    style: pw.TextStyle(
                      color: _teal,
                      fontSize: 5.9,
                      font: boldFont,
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.Text(
            'Plan No: $planNumber',
            style: const pw.TextStyle(
              color: _muted,
              fontSize: 7.5,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildStandardFooter({
    required pw.Context context,
    required pw.Font boldFont,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 9),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(
            color: _line,
            width: 0.65,
          ),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'PLANGO • Bağımsız Tasarruf Finansmanı Karar Destek Platformu',
            style: const pw.TextStyle(
              color: _muted,
              fontSize: 6.6,
            ),
          ),
          pw.Text(
            'Sayfa ${context.pageNumber} / ${context.pagesCount}',
            style: pw.TextStyle(
              color: _teal,
              fontSize: 7,
              font: boldFont,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // PAGE 1 - COVER
  // ===========================================================================

  static pw.Widget _buildCoverHero({
    required DateTime createdAt,
    required String planNumber,
    required pw.MemoryImage heroImage,
    required pw.Font mediumFont,
    required pw.Font semiBoldFont,
    required pw.Font boldFont,
    required pw.Font extraBoldFont,
  }) {
    return pw.Container(
      height: 192,
      decoration: pw.BoxDecoration(
        color: _deepPetrol,
        borderRadius: pw.BorderRadius.circular(20),
      ),
      child: pw.Stack(
        children: [
          pw.Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: pw.SizedBox(
                width: 250,
                child: pw.ClipRRect(
                  horizontalRadius: 20,
                  verticalRadius: 20,
                  child: pw.Opacity(
                    opacity: 0.72,
                    child: pw.Image(
                      heroImage,
                      fit: pw.BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          pw.Positioned.fill(
              child: pw.Container(
                decoration: pw.BoxDecoration(
                  borderRadius: pw.BorderRadius.circular(20),
                  gradient: const pw.LinearGradient(
                    begin: pw.Alignment.centerLeft,
                    end: pw.Alignment.centerRight,
                    colors: [
                      _deepPetrol,
                      PdfColor.fromInt(0xF2052F3D),
                      PdfColor.fromInt(0x62052F3D),
                    ],
                    stops: [0, 0.56, 1],
                  ),
                ),
              ),
            ),
          pw.Positioned.fill(
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        child: pw.Row(
                          children: [
                            _buildLogo(
                              size: 42,
                              extraBoldFont: extraBoldFont,
                            ),
                            pw.SizedBox(width: 11),
                            pw.Column(
                              crossAxisAlignment:
                                  pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'PLANGO',
                                  style: pw.TextStyle(
                                    color: _white,
                                    fontSize: 21,
                                    font: extraBoldFont,
                                    letterSpacing: 1.6,
                                  ),
                                ),
                                pw.SizedBox(height: 2),
                                pw.Text(
                                  'Planla • Karşılaştır • Karar Ver',
                                  style: pw.TextStyle(
                                    color: _turquoise,
                                    fontSize: 7.5,
                                    font: semiBoldFont,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(
                        width: 145,
                        child: pw.Column(
                          children: [
                            _coverMeta(
                              label: 'Rapor Tarihi',
                              value: _longDateFormat.format(createdAt),
                              mediumFont: mediumFont,
                              boldFont: boldFont,
                            ),
                            pw.SizedBox(height: 6),
                            _coverMeta(
                              label: 'Plan No',
                              value: planNumber,
                              mediumFont: mediumFont,
                              boldFont: boldFont,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  pw.Spacer(),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromInt(0x3300D7C2),
                      borderRadius: pw.BorderRadius.circular(20),
                      border: pw.Border.all(
                        color: _turquoise,
                        width: 0.55,
                      ),
                    ),
                    child: pw.Text(
                      'FP ENGINE',
                      style: pw.TextStyle(
                        color: _turquoise,
                        fontSize: 6.7,
                        font: boldFont,
                        letterSpacing: 0.65,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'FİNANSAL PLAN\nRAPORU',
                    style: pw.TextStyle(
                      color: _white,
                      fontSize: 25,
                      lineSpacing: 0,
                      font: extraBoldFont,
                      letterSpacing: -0.2,
                    ),
                  ),
                  pw.SizedBox(height: 7),
                  pw.Text(
                    'FP Engine tarafından oluşturulan\nkişisel ödeme planı',
                    style: pw.TextStyle(
                      color: PdfColor.fromInt(0xFFD0DDE0),
                      fontSize: 8.2,
                      lineSpacing: 2,
                      font: mediumFont,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _coverMeta({
    required String label,
    required String value,
    required pw.Font mediumFont,
    required pw.Font boldFont,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0x5A164858),
        borderRadius: pw.BorderRadius.circular(9),
        border: pw.Border.all(
          color: PdfColor.fromInt(0x665B8490),
          width: 0.5,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              color: PdfColor.fromInt(0xFFAABFC5),
              fontSize: 6.3,
              font: mediumFont,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            value,
            maxLines: 1,
            style: pw.TextStyle(
              color: _white,
              fontSize: 7.7,
              font: boldFont,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildGreeting({
    required String customerName,
    required pw.Font mediumFont,
    required pw.Font extraBoldFont,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(left: 13),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          left: pw.BorderSide(
            color: _turquoise,
            width: 2.2,
          ),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Merhaba, $customerName',
            style: pw.TextStyle(
              color: _navy,
              fontSize: 20,
              font: extraBoldFont,
              letterSpacing: -0.15,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Size özel oluşturulan tahmini ödeme planının '
            'temel bilgileri aşağıda yer almaktadır.',
            style: pw.TextStyle(
              color: _muted,
              fontSize: 8.4,
              font: mediumFont,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCoverSummary({
    required CalculationPlan plan,
    required FpResult result,
    required String deliveryDate,
    required double deliverySaving,
    required pw.Font mediumFont,
    required pw.Font semiBoldFont,
    required pw.Font boldFont,
    required pw.Font extraBoldFont,
  }) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 68,
          child: pw.Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _summaryCard(
                title: 'Finansman Tutarı',
                value: _money(plan.financeAmount),
                width: 144,
                icon: '₺',
                mediumFont: mediumFont,
                boldFont: boldFont,
              ),
              _summaryCard(
                title: 'Peşinat',
                value: _money(plan.downPayment),
                width: 144,
                icon: 'P',
                mediumFont: mediumFont,
                boldFont: boldFont,
              ),
              _summaryCard(
                title: 'Başlangıç Taksiti',
                value: _money(plan.monthlyInstallment),
                width: 144,
                icon: 'T',
                mediumFont: mediumFont,
                boldFont: boldFont,
              ),
              _summaryCard(
                title: 'Ödeme Modeli',
                value: plan.increaseModel,
                width: 144,
                icon: '%',
                mediumFont: mediumFont,
                boldFont: boldFont,
              ),
              _summaryCard(
                title: 'Tahmini Teslim Tarihi',
                value: deliveryDate,
                width: 144,
                icon: 'D',
                highlight: true,
                mediumFont: mediumFont,
                boldFont: boldFont,
              ),
              _summaryCard(
                title: 'Toplam Vade',
                value: '${result.estimatedTerm} Ay',
                width: 144,
                icon: 'V',
                mediumFont: mediumFont,
                boldFont: boldFont,
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 11),
        pw.Expanded(
          flex: 32,
          child: _deliveryCard(
            result: result,
            deliveryDate: deliveryDate,
            deliverySaving: deliverySaving,
            semiBoldFont: semiBoldFont,
            boldFont: boldFont,
            extraBoldFont: extraBoldFont,
          ),
        ),
      ],
    );
  }

  static pw.Widget _summaryCard({
    required String title,
    required String value,
    required String icon,
    required double width,
    required pw.Font mediumFont,
    required pw.Font boldFont,
    bool highlight = false,
  }) {
    return pw.Container(
      width: width,
      height: 71,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: highlight ? _deliveryBackground : _white,
        borderRadius: pw.BorderRadius.circular(11),
        border: pw.Border.all(
          color: highlight ? _turquoise : _line,
          width: 0.7,
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Container(
            width: 25,
            height: 25,
            decoration: pw.BoxDecoration(
              color: highlight
                  ? PdfColor.fromInt(0x3316C7B0)
                  : _softTeal,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Center(
              child: pw.Text(
                icon,
                style: pw.TextStyle(
                  color: _teal,
                  fontSize: 9,
                  font: boldFont,
                ),
              ),
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Expanded(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    color: _muted,
                    fontSize: 6.5,
                    font: mediumFont,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  value,
                  maxLines: 2,
                  style: pw.TextStyle(
                    color: highlight ? _teal : _navy,
                    fontSize: value.length > 18 ? 8 : 9.4,
                    font: boldFont,
                    lineSpacing: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _deliveryCard({
    required FpResult result,
    required String deliveryDate,
    required double deliverySaving,
    required pw.Font semiBoldFont,
    required pw.Font boldFont,
    required pw.Font extraBoldFont,
  }) {
    return pw.Container(
      height: 229,
      padding: const pw.EdgeInsets.fromLTRB(13, 14, 13, 13),
      decoration: pw.BoxDecoration(
        color: _petrol,
        borderRadius: pw.BorderRadius.circular(15),
      ),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF0A5559),
              borderRadius: pw.BorderRadius.circular(20),
            ),
            child: pw.Text(
              'TAHMİNİ TESLİM',
              style: pw.TextStyle(
                color: _turquoise,
                fontSize: 6.8,
                font: boldFont,
                letterSpacing: 0.5,
              ),
            ),
          ),
          pw.SizedBox(height: 11),
          pw.Text(
            '${result.estimatedDelivery}',
            style: pw.TextStyle(
              color: _white,
              fontSize: 40,
              font: extraBoldFont,
            ),
          ),
          pw.Text(
            'AY',
            style: pw.TextStyle(
              color: _turquoise,
              fontSize: 11,
              font: boldFont,
              letterSpacing: 0.8,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            height: 0.65,
            color: PdfColor.fromInt(0xFF37606A),
          ),
          pw.SizedBox(height: 9),
          pw.Text(
            deliveryDate,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              color: _white,
              fontSize: 8.2,
              font: semiBoldFont,
            ),
          ),
          pw.SizedBox(height: 9),
          pw.Text(
            'Teslimata Kadar Birikim',
            style: const pw.TextStyle(
              color: PdfColor.fromInt(0xFFAEC3C8),
              fontSize: 6.5,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            _money(deliverySaving),
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              color: _white,
              fontSize: 10.5,
              font: boldFont,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildOrganizationFee({
    required pw.Font mediumFont,
    required pw.Font boldFont,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(11),
      decoration: pw.BoxDecoration(
        color: _softTeal,
        borderRadius: pw.BorderRadius.circular(11),
        border: pw.Border.all(
          color: PdfColor.fromInt(0xFFBDE8E1),
          width: 0.7,
        ),
      ),
      child: pw.Row(
        children: [
          pw.Container(
            width: 31,
            height: 31,
            decoration: pw.BoxDecoration(
              color: _turquoise,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Center(
              child: pw.Text(
                '%',
                style: pw.TextStyle(
                  color: _petrol,
                  fontSize: 12,
                  font: boldFont,
                ),
              ),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Organizasyon Ücreti',
                  style: pw.TextStyle(
                    color: _navy,
                    fontSize: 8.5,
                    font: boldFont,
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  'Kesin oran ve tutar; ilgili tasarruf finansman şirketi, '
                  'kampanya ve sözleşme koşullarına göre belirlenir.',
                  style: pw.TextStyle(
                    color: _muted,
                    fontSize: 7.2,
                    font: mediumFont,
                    lineSpacing: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCoverFooter({
    required String planNumber,
    required pw.Font boldFont,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 9),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(
            color: _line,
            width: 0.65,
          ),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'PLANGO • Bağımsız Tasarruf Finansmanı Karar Destek Platformu',
            style: const pw.TextStyle(
              color: _muted,
              fontSize: 6.6,
            ),
          ),
          pw.Text(
            planNumber,
            style: pw.TextStyle(
              color: _teal,
              fontSize: 6.8,
              font: boldFont,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // PAYMENT PLAN PAGES
  // ===========================================================================

  static pw.Widget _buildPaymentPlanIntro({
    required FpResult result,
    required pw.Font mediumFont,
    required pw.Font boldFont,
    required pw.Font extraBoldFont,
  }) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'TÜM VADE',
                style: pw.TextStyle(
                  color: _teal,
                  fontSize: 8,
                  font: boldFont,
                  letterSpacing: 0.75,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Ödeme Planı',
                style: pw.TextStyle(
                  color: _navy,
                  fontSize: 21,
                  font: extraBoldFont,
                  letterSpacing: -0.3,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'FP Engine tarafından oluşturulan aylık ödeme ve '
                'birikim planı.',
                style: pw.TextStyle(
                  color: _muted,
                  fontSize: 8,
                  font: mediumFont,
                ),
              ),
            ],
          ),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 6,
          ),
          decoration: pw.BoxDecoration(
            color: _softTeal,
            borderRadius: pw.BorderRadius.circular(18),
          ),
          child: pw.Text(
            '${result.estimatedTerm} AY',
            style: pw.TextStyle(
              color: _teal,
              fontSize: 7.3,
              font: boldFont,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildPaymentTable({
    required FpResult result,
    required pw.Font mediumFont,
    required pw.Font semiBoldFont,
    required pw.Font boldFont,
  }) {
    return pw.Table(
      border: pw.TableBorder(
        top: const pw.BorderSide(
          color: _line,
          width: 0.65,
        ),
        bottom: const pw.BorderSide(
          color: _line,
          width: 0.65,
        ),
        left: const pw.BorderSide(
          color: _line,
          width: 0.65,
        ),
        right: const pw.BorderSide(
          color: _line,
          width: 0.65,
        ),
        horizontalInside: const pw.BorderSide(
          color: _line,
          width: 0.42,
        ),
      ),
      columnWidths: const {
        0: pw.FlexColumnWidth(0.52),
        1: pw.FlexColumnWidth(1.62),
        2: pw.FlexColumnWidth(1.34),
        3: pw.FlexColumnWidth(1.48),
        4: pw.FlexColumnWidth(1.48),
      },
      children: [
        pw.TableRow(
          repeat: true,
          decoration: const pw.BoxDecoration(
            color: _petrol,
          ),
          children: [
            _tableHeaderCell('Ay', boldFont),
            _tableHeaderCell('Taksit Tarihi', boldFont),
            _tableHeaderCell('Taksit Tutarı', boldFont),
            _tableHeaderCell('Toplam Birikim', boldFont),
            _tableHeaderCell('Dönem', boldFont),
          ],
        ),
        ...result.paymentPlan.map((PaymentPlanItem item) {
          final PdfColor foreground =
              _periodForeground(item, result);
          final PdfColor background =
              _periodBackground(item, result);

          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: background,
            ),
            children: [
              _tableBodyCell(
                '${item.month}',
                font: boldFont,
                color: foreground,
                align: pw.TextAlign.center,
              ),
              _tableBodyCell(
                _longDateFormat.format(item.paymentDate),
                font: mediumFont,
                align: pw.TextAlign.center,
              ),
              _tableBodyCell(
                _money(item.installment),
                font: semiBoldFont,
                align: pw.TextAlign.right,
              ),
              _tableBodyCell(
                _money(item.totalSaving),
                font: boldFont,
                color: item.isDeliveryMonth ? _teal : _text,
                align: pw.TextAlign.right,
              ),
              _periodCell(
                item: item,
                result: result,
                foreground: foreground,
                boldFont: boldFont,
              ),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _tableHeaderCell(
    String text,
    pw.Font font,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 8,
      ),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          color: _white,
          fontSize: 7,
          font: font,
        ),
      ),
    );
  }

  static pw.Widget _tableBodyCell(
    String text, {
    required pw.Font font,
    PdfColor color = _text,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 7,
      ),
      child: pw.Text(
        text,
        maxLines: 1,
        textAlign: align,
        style: pw.TextStyle(
          color: color,
          fontSize: 6.8,
          font: font,
        ),
      ),
    );
  }

  static pw.Widget _periodCell({
    required PaymentPlanItem item,
    required FpResult result,
    required PdfColor foreground,
    required pw.Font boldFont,
  }) {
    final bool isSpecial =
        item.isDeliveryMonth || item.isLastMonth;

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 6,
      ),
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 4,
        ),
        decoration: pw.BoxDecoration(
          color: isSpecial ? foreground : _white,
          borderRadius: pw.BorderRadius.circular(10),
          border: pw.Border.all(
            color: foreground,
            width: 0.55,
          ),
        ),
        child: pw.Text(
          _periodName(item, result),
          maxLines: 1,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            color: isSpecial ? _white : foreground,
            fontSize: 6.2,
            font: boldFont,
          ),
        ),
      ),
    );
  }

  static PdfColor _periodForeground(
    PaymentPlanItem item,
    FpResult result,
  ) {
    if (item.isDeliveryMonth) {
      return _teal;
    }

    if (item.isLastMonth) {
      return _petrol;
    }

    if (item.month < result.estimatedDelivery) {
      return _teal;
    }

    return _navy;
  }

  static PdfColor _periodBackground(
    PaymentPlanItem item,
    FpResult result,
  ) {
    if (item.isDeliveryMonth) {
      return _deliveryBackground;
    }

    if (item.isLastMonth) {
      return _lastBackground;
    }

    if (item.month < result.estimatedDelivery) {
      return _softTeal;
    }

    return _financeBackground;
  }

  static String _periodName(
    PaymentPlanItem item,
    FpResult result,
  ) {
    if (item.isDeliveryMonth) {
      return 'Teslim Ayı';
    }

    if (item.isLastMonth) {
      return 'Son Taksit';
    }

    if (item.month < result.estimatedDelivery) {
      return 'Tasarruf Dönemi';
    }

    return 'Finansman Dönemi';
  }

  static pw.Widget _buildPaymentNotes({
    required CalculationPlan plan,
    required pw.Font mediumFont,
    required pw.Font boldFont,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: _softTeal,
        borderRadius: pw.BorderRadius.circular(11),
        border: pw.Border.all(
          color: PdfColor.fromInt(0xFFBFE8E1),
          width: 0.65,
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 28,
            height: 28,
            decoration: pw.BoxDecoration(
              color: _turquoise,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Center(
              child: pw.Text(
                'i',
                style: pw.TextStyle(
                  color: _petrol,
                  fontSize: 11,
                  font: boldFont,
                ),
              ),
            ),
          ),
          pw.SizedBox(width: 9),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Plan Notları',
                  style: pw.TextStyle(
                    color: _navy,
                    fontSize: 8.5,
                    font: boldFont,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  '• Ödeme modeli: ${plan.increaseModel}\n'
                  '• Taksit tarihleri hesaplama tarihine göre oluşturulmuştur.\n'
                  '• Kesin plan ve teslim koşulları ilgili kuruluş tarafından belirlenir.',
                  style: pw.TextStyle(
                    color: _muted,
                    fontSize: 7.2,
                    font: mediumFont,
                    lineSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // FINAL SUMMARY PAGE
  // ===========================================================================

  static pw.Widget _buildFinalHero({
    required String customerName,
    required String planNumber,
    required pw.Font mediumFont,
    required pw.Font boldFont,
    required pw.Font extraBoldFont,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(18),
      decoration: pw.BoxDecoration(
        color: _petrol,
        borderRadius: pw.BorderRadius.circular(18),
      ),
      child: pw.Row(
        children: [
          _buildLogo(
            size: 44,
            extraBoldFont: extraBoldFont,
          ),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Plan Özeti',
                  style: pw.TextStyle(
                    color: _white,
                    fontSize: 25,
                    font: extraBoldFont,
                    letterSpacing: -0.3,
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  '$customerName için FP Engine tarafından oluşturulan '
                  'planın genel değerlendirmesi.',
                  style: pw.TextStyle(
                    color: PdfColor.fromInt(0xFFB8CCD1),
                    fontSize: 7.8,
                    font: mediumFont,
                    lineSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF0B5258),
              borderRadius: pw.BorderRadius.circular(14),
            ),
            child: pw.Text(
              planNumber,
              style: pw.TextStyle(
                color: _turquoise,
                fontSize: 6.6,
                font: boldFont,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFinalMetrics({
    required CalculationPlan plan,
    required FpResult result,
    required String deliveryDate,
    required double deliverySaving,
    required double totalInstallments,
    required double totalPayment,
    required pw.Font mediumFont,
    required pw.Font boldFont,
  }) {
    final List<_MetricData> metrics = [
      _MetricData(
        label: 'Finansman Tutarı',
        value: _money(plan.financeAmount),
      ),
      _MetricData(
        label: 'Peşinat',
        value: _money(plan.downPayment),
      ),
      _MetricData(
        label: 'Toplam Taksit',
        value: _money(totalInstallments),
      ),
      _MetricData(
        label: 'Toplam Ödeme',
        value: _money(totalPayment),
      ),
      _MetricData(
        label: 'Tahmini Teslim',
        value: '${result.estimatedDelivery}. Ay',
        highlight: true,
      ),
      _MetricData(
        label: 'Teslim Tarihi',
        value: deliveryDate,
        highlight: true,
      ),
      _MetricData(
        label: 'Teslimata Kadar Birikim',
        value: _money(deliverySaving),
      ),
      _MetricData(
        label: 'Toplam Vade',
        value: '${result.estimatedTerm} Ay',
      ),
    ];

    return pw.Wrap(
      spacing: 9,
      runSpacing: 9,
      children: metrics.map<pw.Widget>((_MetricData metric) {
        return pw.Container(
          width: 123,
          height: 73,
          padding: const pw.EdgeInsets.all(11),
          decoration: pw.BoxDecoration(
            color: metric.highlight
                ? _deliveryBackground
                : _white,
            borderRadius: pw.BorderRadius.circular(12),
            border: pw.Border.all(
              color: metric.highlight
                  ? _turquoise
                  : _line,
              width: 0.7,
            ),
          ),
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                metric.label,
                style: pw.TextStyle(
                  color: _muted,
                  fontSize: 6.8,
                  font: mediumFont,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                metric.value,
                maxLines: 2,
                style: pw.TextStyle(
                  color: metric.highlight ? _teal : _navy,
                  fontSize: metric.value.length > 18 ? 8.2 : 9.6,
                  font: boldFont,
                  lineSpacing: 1.3,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  static pw.Widget _buildEngineAnalysis({
    required CalculationPlan plan,
    required FpResult result,
    required String deliveryDate,
    required double totalPayment,
    required pw.Font mediumFont,
    required pw.Font boldFont,
    required pw.Font extraBoldFont,
  }) {
    final List<String> items = [
      'Planın tahmini teslim süresi '
          '${result.estimatedDelivery} aydır.',
      'Plan toplam ${result.estimatedTerm} ayda tamamlanmaktadır.',
      'Ödeme modeli "${plan.increaseModel}" olarak hesaplanmıştır.',
      'Tahmini teslim tarihi $deliveryDate olarak oluşturulmuştur.',
      'Peşinat dahil toplam ödeme ${_money(totalPayment)} seviyesindedir.',
      'Hesaplama kullanıcı tarafından girilen bilgiler doğrultusunda hazırlanmıştır.',
    ];

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: _white,
        borderRadius: pw.BorderRadius.circular(15),
        border: pw.Border.all(
          color: _line,
          width: 0.7,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(
                width: 34,
                height: 34,
                decoration: pw.BoxDecoration(
                  color: _softTeal,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Center(
                  child: pw.Text(
                    '✓',
                    style: pw.TextStyle(
                      color: _teal,
                      fontSize: 14,
                      font: extraBoldFont,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'FP Engine Analizi',
                    style: pw.TextStyle(
                      color: _navy,
                      fontSize: 13,
                      font: extraBoldFont,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Planın öne çıkan noktaları',
                    style: pw.TextStyle(
                      color: _muted,
                      fontSize: 7,
                      font: mediumFont,
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          ...items.map((String item) {
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 7),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    margin: const pw.EdgeInsets.only(top: 3),
                    width: 5,
                    height: 5,
                    decoration: const pw.BoxDecoration(
                      color: _turquoise,
                      shape: pw.BoxShape.circle,
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Expanded(
                    child: pw.Text(
                      item,
                      style: pw.TextStyle(
                        color: _text,
                        fontSize: 7.8,
                        font: mediumFont,
                        lineSpacing: 1.8,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  static pw.Widget _buildClosingBanner({
    required DateTime createdAt,
    required pw.Font mediumFont,
    required pw.Font boldFont,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(13),
      decoration: pw.BoxDecoration(
        color: _softTeal,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(
          color: PdfColor.fromInt(0xFFBDE7E0),
          width: 0.65,
        ),
      ),
      child: pw.Row(
        children: [
          pw.Container(
            width: 34,
            height: 34,
            decoration: pw.BoxDecoration(
              color: _teal,
              borderRadius: pw.BorderRadius.circular(9),
            ),
            child: pw.Center(
              child: pw.Text(
                'P',
                style: pw.TextStyle(
                  color: _white,
                  fontSize: 18,
                  font: boldFont,
                ),
              ),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Planla, karşılaştır, karar ver.',
                  style: pw.TextStyle(
                    color: _navy,
                    fontSize: 10.5,
                    font: boldFont,
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  'Bu rapor ${_longDateFormat.format(createdAt)} tarihinde '
                  'Plango FP Engine tarafından oluşturulmuştur.',
                  style: pw.TextStyle(
                    color: _muted,
                    fontSize: 7.1,
                    font: mediumFont,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildDisclaimer({
    required pw.Font mediumFont,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: _lastBackground,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(
          color: _line,
          width: 0.65,
        ),
      ),
      child: pw.Text(
        'Bu ödeme planı, kullanıcı tarafından girilen bilgiler doğrultusunda '
        'Plango FP Engine tarafından bilgilendirme amacıyla oluşturulmuştur. '
        'Resmî ödeme planı, kesin teslim tarihi, organizasyon ücreti, kampanya '
        've sözleşme koşulları ilgili tasarruf finansman şirketi tarafından '
        'belirlenir.',
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          color: _muted,
          fontSize: 6.8,
          font: mediumFont,
          lineSpacing: 1.8,
        ),
      ),
    );
  }

  // ===========================================================================
  // DATA HELPERS
  // ===========================================================================

  static String _money(double value) {
    return '${_moneyFormat.format(value)} ₺';
  }

  static PaymentPlanItem? _deliveryItem(FpResult result) {
    for (final PaymentPlanItem item in result.paymentPlan) {
      if (item.isDeliveryMonth) {
        return item;
      }
    }

    return null;
  }
}

class _MetricData {
  const _MetricData({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;
}
