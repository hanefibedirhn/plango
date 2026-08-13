import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../engine/fp_engine.dart';
import '../models/calculation_plan.dart';

/// Tasarruf Planım PDF rapor servisi.
///
/// Not: Class adı mevcut payment_plan_screen.dart bağlantısını kırmamak için
/// şimdilik PlangoPdfService olarak korunmuştur. PDF içinde kullanıcıya görünen
/// tüm marka alanları "Tasarruf Planım" olarak güncellenmiştir.
class PlangoPdfService {
  PlangoPdfService._();

  static final NumberFormat _moneyFormat = NumberFormat('#,##0.##', 'tr_TR');
  static final DateFormat _longDateFormat = DateFormat('d MMMM yyyy', 'tr_TR');

  // Tasarruf Planım Design System
  static const PdfColor _navy = PdfColor.fromInt(0xFF0B2239);
  static const PdfColor _petrol = PdfColor.fromInt(0xFF052F3D);
  static const PdfColor _teal = PdfColor.fromInt(0xFF087C72);
  static const PdfColor _turquoise = PdfColor.fromInt(0xFF16C7B0);

  static const PdfColor _background = PdfColor.fromInt(0xFFF7F9FB);
  static const PdfColor _white = PdfColors.white;
  static const PdfColor _text = PdfColor.fromInt(0xFF10283A);
  static const PdfColor _muted = PdfColor.fromInt(0xFF748193);
  static const PdfColor _line = PdfColor.fromInt(0xFFE2E8EC);
  static const PdfColor _softTeal = PdfColor.fromInt(0xFFEAF8F5);
  static const PdfColor _deliveryBackground = PdfColor.fromInt(0xFFE4FAF6);
  static const PdfColor _lastBackground = PdfColor.fromInt(0xFFF2F4F6);

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
      filename: 'Tasarruf_Planim_Finansal_Plan_Raporu_$planNumber.pdf',
    );
  }

  static Future<Uint8List> build({
    required CalculationPlan plan,
    required FpResult result,
    required String customerName,
    required DateTime createdAt,
    required String planNumber,
  }) async {
    final ByteData logoData = await rootBundle.load(
      'assets/images/tasarruf_planim_home_logo.png',
    );
    final pw.MemoryImage brandLogo = pw.MemoryImage(
      logoData.buffer.asUint8List(),
    );

    final pw.Document document = pw.Document(
      title: 'Tasarruf Planım Finansal Plan Raporu',
      author: 'Tasarruf Planım',
      creator: 'Tasarruf Planım FP Engine',
      subject: 'Tahmini tasarruf finansmanı ödeme planı',
    );

    final pw.Font regularFont = await PdfGoogleFonts.manropeRegular();
    final pw.Font mediumFont = await PdfGoogleFonts.manropeMedium();
    final pw.Font semiBoldFont = await PdfGoogleFonts.manropeSemiBold();
    final pw.Font boldFont = await PdfGoogleFonts.manropeBold();
    final pw.Font extraBoldFont = await PdfGoogleFonts.manropeExtraBold();

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

    // 1. SAYFA — sade plan özeti
    document.addPage(
      pw.Page(
        pageTheme: _pageTheme(theme),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              _buildCoverHeader(
                brandLogo: brandLogo,
                createdAt: createdAt,
                planNumber: planNumber,
                boldFont: boldFont,
                extraBoldFont: extraBoldFont,
              ),
              pw.SizedBox(height: 28),
              _buildGreeting(
                customerName: customerName,
                mediumFont: mediumFont,
                extraBoldFont: extraBoldFont,
              ),
              pw.SizedBox(height: 22),
              _buildMainSummary(
                plan: plan,
                result: result,
                mediumFont: mediumFont,
                boldFont: boldFont,
              ),
              pw.SizedBox(height: 18),
              _buildDeliveryHighlight(
                result: result,
                deliveryDate: deliveryDate,
                deliverySaving: deliverySaving,
                mediumFont: mediumFont,
                boldFont: boldFont,
                extraBoldFont: extraBoldFont,
              ),
              pw.SizedBox(height: 16),
              _buildOrganizationFee(
                mediumFont: mediumFont,
                boldFont: boldFont,
              ),
              pw.Spacer(),
              _buildCoverLegalNote(mediumFont: mediumFont),
              pw.SizedBox(height: 12),
              _buildCoverFooter(
                planNumber: planNumber,
                boldFont: boldFont,
              ),
            ],
          );
        },
      ),
    );

    // 2. SAYFA VE DEVAMI — ödeme planı
    document.addPage(
      pw.MultiPage(
        pageTheme: _pageTheme(theme),
        header: (pw.Context context) => _buildStandardHeader(
          brandLogo: brandLogo,
          planNumber: planNumber,
          boldFont: boldFont,
          extraBoldFont: extraBoldFont,
        ),
        footer: (pw.Context context) => _buildStandardFooter(
          context: context,
          boldFont: boldFont,
        ),
        build: (pw.Context context) => [
          _buildPaymentPlanIntro(
            result: result,
            mediumFont: mediumFont,
            boldFont: boldFont,
            extraBoldFont: extraBoldFont,
          ),
          pw.SizedBox(height: 14),
          _buildPaymentTable(
            result: result,
            mediumFont: mediumFont,
            semiBoldFont: semiBoldFont,
            boldFont: boldFont,
          ),
          pw.SizedBox(height: 16),
          _buildPaymentNotes(
            plan: plan,
            mediumFont: mediumFont,
            boldFont: boldFont,
          ),
          pw.SizedBox(height: 10),
          _buildDisclaimer(mediumFont: mediumFont),
        ],
      ),
    );

    return document.save();
  }

  static pw.PageTheme _pageTheme(pw.ThemeData theme) {
    return pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(30, 28, 30, 28),
      theme: theme,
      buildBackground: (pw.Context context) => pw.FullPage(
        ignoreMargins: true,
        child: pw.Container(color: _background),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BRAND / HEADER / FOOTER
  // ---------------------------------------------------------------------------

  static pw.Widget _buildCoverHeader({
    required pw.MemoryImage brandLogo,
    required DateTime createdAt,
    required String planNumber,
    required pw.Font boldFont,
    required pw.Font extraBoldFont,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: _line, width: 0.7),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Expanded(
            child: pw.Container(
              height: 44,
              alignment: pw.Alignment.centerLeft,
              child: pw.Image(
                brandLogo,
                fit: pw.BoxFit.contain,
                alignment: pw.Alignment.centerLeft,
              ),
            ),
          ),
          pw.SizedBox(width: 20),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              _lightMetaText(
                'Rapor Tarihi',
                _longDateFormat.format(createdAt),
                boldFont,
              ),
              pw.SizedBox(height: 5),
              _lightMetaText('Plan No', planNumber, boldFont),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _lightMetaText(
    String label,
    String value,
    pw.Font boldFont,
  ) {
    return pw.Row(
      children: [
        pw.Text(
          '$label  ',
          style: const pw.TextStyle(
            color: _muted,
            fontSize: 6.3,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            color: _navy,
            fontSize: 6.8,
            font: boldFont,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildStandardHeader({
    required pw.MemoryImage brandLogo,
    required String planNumber,
    required pw.Font boldFont,
    required pw.Font extraBoldFont,
  }) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: _line, width: 0.7),
        ),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Container(
              height: 30,
              alignment: pw.Alignment.centerLeft,
              child: pw.Image(
                brandLogo,
                fit: pw.BoxFit.contain,
                alignment: pw.Alignment.centerLeft,
              ),
            ),
          ),
          pw.Text(
            'Plan No: $planNumber',
            style: pw.TextStyle(
              color: _muted,
              fontSize: 7,
              font: boldFont,
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
      margin: const pw.EdgeInsets.only(top: 12),
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: _line, width: 0.65),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Tasarruf Planım • Bağımsız Tasarruf Finansmanı Karar Destek Platformu',
            style: const pw.TextStyle(color: _muted, fontSize: 6.2),
          ),
          pw.Text(
            'Sayfa ${context.pageNumber} / ${context.pagesCount}',
            style: pw.TextStyle(color: _teal, fontSize: 6.5, font: boldFont),
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
          top: pw.BorderSide(color: _line, width: 0.65),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Tasarruf Planım • Bağımsız Tasarruf Finansmanı Karar Destek Platformu',
            style: const pw.TextStyle(color: _muted, fontSize: 6.2),
          ),
          pw.Text(
            planNumber,
            style: pw.TextStyle(color: _teal, fontSize: 6.5, font: boldFont),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PAGE 1
  // ---------------------------------------------------------------------------

  static pw.Widget _buildGreeting({
    required String customerName,
    required pw.Font mediumFont,
    required pw.Font extraBoldFont,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Merhaba, $customerName',
          style: pw.TextStyle(
            color: _navy,
            fontSize: 20,
            font: extraBoldFont,
            letterSpacing: -0.2,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          'Planınızın temel bilgileri ve tahmini teslim sonucu aşağıda yer almaktadır.',
          style: pw.TextStyle(color: _muted, fontSize: 8.3, font: mediumFont),
        ),
      ],
    );
  }

  static pw.Widget _buildMainSummary({
    required CalculationPlan plan,
    required FpResult result,
    required pw.Font mediumFont,
    required pw.Font boldFont,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: _white,
        borderRadius: pw.BorderRadius.circular(14),
        border: pw.Border.all(color: _line, width: 0.7),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            children: [
              pw.Expanded(
                child: _summaryItem(
                  'Finansman Tutarı',
                  _money(plan.financeAmount),
                  mediumFont,
                  boldFont,
                ),
              ),
              _verticalDivider(),
              pw.Expanded(
                child: _summaryItem(
                  'Peşinat',
                  _money(plan.downPayment),
                  mediumFont,
                  boldFont,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 14),
          pw.Container(height: 0.6, color: _line),
          pw.SizedBox(height: 14),
          pw.Row(
            children: [
              pw.Expanded(
                child: _summaryItem(
                  'Başlangıç Taksiti',
                  _money(plan.monthlyInstallment),
                  mediumFont,
                  boldFont,
                ),
              ),
              _verticalDivider(),
              pw.Expanded(
                child: _summaryItem(
                  'Toplam Vade',
                  '${result.estimatedTerm} Ay',
                  mediumFont,
                  boldFont,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 14),
          pw.Container(height: 0.6, color: _line),
          pw.SizedBox(height: 14),
          _summaryItem(
            'Ödeme Modeli',
            plan.increaseModel,
            mediumFont,
            boldFont,
          ),
        ],
      ),
    );
  }

  static pw.Widget _summaryItem(
    String label,
    String value,
    pw.Font mediumFont,
    pw.Font boldFont,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(color: _muted, fontSize: 6.8, font: mediumFont),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            maxLines: 2,
            style: pw.TextStyle(
              color: _navy,
              fontSize: value.length > 22 ? 9 : 10.5,
              font: boldFont,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _verticalDivider() {
    return pw.Container(width: 0.6, height: 38, color: _line);
  }

  static pw.Widget _buildDeliveryHighlight({
    required FpResult result,
    required String deliveryDate,
    required double deliverySaving,
    required pw.Font mediumFont,
    required pw.Font boldFont,
    required pw.Font extraBoldFont,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.fromLTRB(18, 17, 18, 17),
      decoration: pw.BoxDecoration(
        color: _petrol,
        borderRadius: pw.BorderRadius.circular(15),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'TAHMİNİ TESLİM',
                  style: pw.TextStyle(
                    color: _turquoise,
                    fontSize: 7,
                    font: boldFont,
                    letterSpacing: 0.6,
                  ),
                ),
                pw.SizedBox(height: 7),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      '${result.estimatedDelivery}.',
                      style: pw.TextStyle(
                        color: _white,
                        fontSize: 30,
                        font: extraBoldFont,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 4, left: 4),
                      child: pw.Text(
                        'AY',
                        style: pw.TextStyle(
                          color: _turquoise,
                          fontSize: 9,
                          font: boldFont,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  deliveryDate,
                  style: pw.TextStyle(
                    color: PdfColor.fromInt(0xFFD5E1E4),
                    fontSize: 8,
                    font: mediumFont,
                  ),
                ),
              ],
            ),
          ),
          pw.Container(
            width: 0.7,
            height: 58,
            color: PdfColor.fromInt(0xFF315660),
          ),
          pw.SizedBox(width: 18),
          pw.SizedBox(
            width: 175,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Teslimata Kadar Birikim',
                  style: pw.TextStyle(
                    color: PdfColor.fromInt(0xFFAFC2C7),
                    fontSize: 6.7,
                    font: mediumFont,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  _money(deliverySaving),
                  style: pw.TextStyle(
                    color: _white,
                    fontSize: 12,
                    font: boldFont,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Tahmini sonuç',
                  style: pw.TextStyle(
                    color: _turquoise,
                    fontSize: 6.4,
                    font: boldFont,
                  ),
                ),
              ],
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
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: _softTeal,
        borderRadius: pw.BorderRadius.circular(11),
        border: pw.Border.all(
          color: const PdfColor.fromInt(0xFFBDE8E1),
          width: 0.65,
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 26,
            height: 26,
            decoration: pw.BoxDecoration(
              color: _teal,
              borderRadius: pw.BorderRadius.circular(7),
            ),
            child: pw.Center(
              child: pw.Text(
                '%',
                style: pw.TextStyle(color: _white, fontSize: 10, font: boldFont),
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
                  style: pw.TextStyle(color: _navy, fontSize: 8, font: boldFont),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  'Kesin oran ve tutar; ilgili tasarruf finansman şirketi, kampanya '
                  've sözleşme koşullarına göre belirlenir.',
                  style: pw.TextStyle(
                    color: _muted,
                    fontSize: 7,
                    font: mediumFont,
                    lineSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCoverLegalNote({required pw.Font mediumFont}) {
    return pw.Text(
      'Bu rapordaki hesaplamalar tahmini ve bilgilendirme amaçlıdır. '
      'Resmî plan, kesin teslim tarihi ve sözleşme koşulları ilgili '
      'tasarruf finansman şirketi tarafından belirlenir.',
      textAlign: pw.TextAlign.center,
      style: pw.TextStyle(
        color: _muted,
        fontSize: 6.5,
        font: mediumFont,
        lineSpacing: 1.5,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PAYMENT PLAN
  // ---------------------------------------------------------------------------

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
                'ÖDEME PLANI',
                style: pw.TextStyle(
                  color: _teal,
                  fontSize: 7.2,
                  font: boldFont,
                  letterSpacing: 0.7,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Aylık Ödeme Takvimi',
                style: pw.TextStyle(
                  color: _navy,
                  fontSize: 19,
                  font: extraBoldFont,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Taksit tarihleri, taksit tutarları ve toplam birikim.',
                style: pw.TextStyle(
                  color: _muted,
                  fontSize: 7.5,
                  font: mediumFont,
                ),
              ),
            ],
          ),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: pw.BoxDecoration(
            color: _softTeal,
            borderRadius: pw.BorderRadius.circular(14),
          ),
          child: pw.Text(
            '${result.estimatedTerm} AY',
            style: pw.TextStyle(color: _teal, fontSize: 7, font: boldFont),
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
        top: const pw.BorderSide(color: _line, width: 0.65),
        bottom: const pw.BorderSide(color: _line, width: 0.65),
        left: const pw.BorderSide(color: _line, width: 0.65),
        right: const pw.BorderSide(color: _line, width: 0.65),
        horizontalInside: const pw.BorderSide(color: _line, width: 0.4),
      ),
      columnWidths: const {
        0: pw.FlexColumnWidth(0.48),
        1: pw.FlexColumnWidth(1.55),
        2: pw.FlexColumnWidth(1.30),
        3: pw.FlexColumnWidth(1.45),
        4: pw.FlexColumnWidth(1.35),
      },
      children: [
        pw.TableRow(
          repeat: true,
          decoration: const pw.BoxDecoration(color: _petrol),
          children: [
            _tableHeaderCell('Ay', boldFont),
            _tableHeaderCell('Taksit Tarihi', boldFont),
            _tableHeaderCell('Taksit Tutarı', boldFont),
            _tableHeaderCell('Toplam Birikim', boldFont),
            _tableHeaderCell('Dönem', boldFont),
          ],
        ),
        ...result.paymentPlan.map((PaymentPlanItem item) {
          final bool delivery = item.isDeliveryMonth;
          final bool last = item.isLastMonth;

          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: delivery
                  ? _deliveryBackground
                  : last
                      ? _lastBackground
                      : _white,
            ),
            children: [
              _tableBodyCell(
                '${item.month}',
                font: boldFont,
                color: delivery ? _teal : _text,
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
                color: delivery ? _teal : _text,
                align: pw.TextAlign.right,
              ),
              _periodCell(
                item: item,
                result: result,
                boldFont: boldFont,
              ),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _tableHeaderCell(String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5.4),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(color: _white, fontSize: 6.6, font: font),
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
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4.6),
      child: pw.Text(
        text,
        maxLines: 1,
        textAlign: align,
        style: pw.TextStyle(color: color, fontSize: 6.35, font: font),
      ),
    );
  }

  static pw.Widget _periodCell({
    required PaymentPlanItem item,
    required FpResult result,
    required pw.Font boldFont,
  }) {
    final bool special = item.isDeliveryMonth || item.isLastMonth;
    final PdfColor color = item.isDeliveryMonth
        ? _teal
        : item.isLastMonth
            ? _petrol
            : _muted;

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4.2),
      child: pw.Text(
        _periodName(item, result),
        maxLines: 1,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          color: color,
          fontSize: special ? 6.3 : 6.1,
          font: boldFont,
        ),
      ),
    );
  }

  static String _periodName(PaymentPlanItem item, FpResult result) {
    if (item.isDeliveryMonth) return 'Teslim Ayı';
    if (item.isLastMonth) return 'Son Taksit';
    if (item.month < result.estimatedDelivery) return 'Tasarruf';
    return 'Finansman';
  }

  static pw.Widget _buildPaymentNotes({
    required CalculationPlan plan,
    required pw.Font mediumFont,
    required pw.Font boldFont,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(11),
      decoration: pw.BoxDecoration(
        color: _white,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: _line, width: 0.65),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Plan Bilgileri',
            style: pw.TextStyle(color: _navy, fontSize: 8, font: boldFont),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            '• Ödeme modeli: ${plan.increaseModel}\n'
            '• Taksit tarihleri hesaplama tarihine göre oluşturulmuştur.\n'
            '• Kesin plan, ödeme ve teslim koşulları ilgili kuruluş tarafından belirlenir.',
            style: pw.TextStyle(
              color: _muted,
              fontSize: 6.8,
              font: mediumFont,
              lineSpacing: 1.8,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildDisclaimer({required pw.Font mediumFont}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: _lastBackground,
        borderRadius: pw.BorderRadius.circular(9),
        border: pw.Border.all(color: _line, width: 0.6),
      ),
      child: pw.Text(
        'Bu ödeme planı, kullanıcı tarafından girilen bilgiler doğrultusunda '
        'Tasarruf Planım FP Engine tarafından bilgilendirme amacıyla oluşturulmuştur. '
        'Hesaplama sonuçları tahminidir. Resmî ödeme planı, kesin teslim tarihi, '
        'organizasyon ücreti, kampanya ve sözleşme koşulları ilgili tasarruf '
        'finansman şirketi tarafından belirlenir.',
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          color: _muted,
          fontSize: 6.5,
          font: mediumFont,
          lineSpacing: 1.6,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  static String _money(double value) {
    return '${_moneyFormat.format(value)} ₺';
  }

  static PaymentPlanItem? _deliveryItem(FpResult result) {
    for (final PaymentPlanItem item in result.paymentPlan) {
      if (item.isDeliveryMonth) return item;
    }
    return null;
  }
}
