import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../engine/fp_engine.dart';
import '../models/calculation_plan.dart';

class PlangoPdfService {
  PlangoPdfService._();

  static final NumberFormat _moneyFormat = NumberFormat(
    '#,##0.##',
    'tr_TR',
  );

  static final DateFormat _dateFormat = DateFormat(
    'd MMMM yyyy',
    'tr_TR',
  );

  static const PdfColor _darkGreen = PdfColor.fromInt(0xFF003F32);
  static const PdfColor _green = PdfColor.fromInt(0xFF0B5D3B);
  static const PdfColor _gold = PdfColor.fromInt(0xFFD6A84F);
  static const PdfColor _lightGold = PdfColor.fromInt(0xFFFFF6E3);
  static const PdfColor _blue = PdfColor.fromInt(0xFF3278C8);
  static const PdfColor _lightBlue = PdfColor.fromInt(0xFFEAF3FF);
  static const PdfColor _lightGreen = PdfColor.fromInt(0xFFEAF6ED);
  static const PdfColor _softGray = PdfColor.fromInt(0xFFF4F5F1);
  static const PdfColor _line = PdfColor.fromInt(0xFFE4E7E2);
  static const PdfColor _text = PdfColor.fromInt(0xFF10231B);

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

  static String _periodName(
    PaymentPlanItem item,
    FpResult result,
  ) {
    if (item.isDeliveryMonth) {
      return 'Tahmini Teslim';
    }

    if (item.isLastMonth) {
      return 'Son Taksit';
    }

    if (item.month < result.estimatedDelivery) {
      return 'Tasarruf Dönemi';
    }

    return 'Finansman Dönemi';
  }

  static PdfColor _periodColor(
    PaymentPlanItem item,
    FpResult result,
  ) {
    if (item.isDeliveryMonth) {
      return _gold;
    }

    if (item.isLastMonth) {
      return _text;
    }

    if (item.month < result.estimatedDelivery) {
      return _green;
    }

    return _blue;
  }

  static PdfColor _periodBackground(
    PaymentPlanItem item,
    FpResult result,
  ) {
    if (item.isDeliveryMonth) {
      return _lightGold;
    }

    if (item.isLastMonth) {
      return _softGray;
    }

    if (item.month < result.estimatedDelivery) {
      return _lightGreen;
    }

    return _lightBlue;
  }

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
      filename: 'Plango_Odeme_Plani_$planNumber.pdf',
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
      title: 'Plango Ödeme Planı',
      author: 'Plango FP Engine',
      creator: 'Plango',
      subject: 'Tahmini tasarruf finansmanı ödeme planı',
    );

    // Türkçe karakterleri destekleyen fontlar.
    // Üretim sürümünde bunları uygulama asset'i olarak eklemek daha güvenlidir.
    final pw.Font regularFont =
        await PdfGoogleFonts.notoSansRegular();
    final pw.Font mediumFont =
        await PdfGoogleFonts.notoSansMedium();
    final pw.Font boldFont =
        await PdfGoogleFonts.notoSansBold();

    final pw.ThemeData theme = pw.ThemeData.withFont(
      base: regularFont,
      bold: boldFont,
      italic: regularFont,
      boldItalic: boldFont,
    );

    final PaymentPlanItem? deliveryItem = _deliveryItem(result);

    final String deliveryDate = deliveryItem == null
        ? '-'
        : _dateFormat.format(deliveryItem.paymentDate);

    final double deliverySaving =
        deliveryItem?.totalSaving ?? plan.downPayment;

    document.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(
            28,
            28,
            28,
            34,
          ),
          theme: theme,
          buildBackground: (pw.Context context) {
            return pw.FullPage(
              ignoreMargins: true,
              child: pw.Container(
                decoration: const pw.BoxDecoration(
                  color: PdfColors.white,
                ),
              ),
            );
          },
        ),
        header: (pw.Context context) {
          if (context.pageNumber == 1) {
            return pw.SizedBox();
          }

          return pw.Container(
            padding: const pw.EdgeInsets.only(
              bottom: 10,
            ),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(
                  color: _line,
                  width: 0.8,
                ),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment:
                  pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'PLANGO • FP Engine',
                  style: pw.TextStyle(
                    color: _darkGreen,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                pw.Text(
                  'Plan No: $planNumber',
                  style: pw.TextStyle(
                    color: PdfColors.grey700,
                    fontSize: 8.5,
                  ),
                ),
              ],
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.only(
              top: 10,
            ),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(
                  color: _line,
                  width: 0.8,
                ),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment:
                  pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'PLANGO • Bağımsız Tasarruf Finansmanı Karar Destek Platformu',
                  style: pw.TextStyle(
                    color: PdfColors.grey700,
                    fontSize: 7.5,
                  ),
                ),
                pw.Text(
                  'Sayfa ${context.pageNumber} / ${context.pagesCount}',
                  style: pw.TextStyle(
                    color: _darkGreen,
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
        build: (pw.Context context) {
          return [
            _buildHeroHeader(
              createdAt: createdAt,
              planNumber: planNumber,
              boldFont: boldFont,
            ),
            pw.SizedBox(height: 22),
            _buildWelcome(
              customerName: customerName,
              mediumFont: mediumFont,
            ),
            pw.SizedBox(height: 18),
            _buildSummaryArea(
              plan: plan,
              result: result,
              deliveryDate: deliveryDate,
              deliverySaving: deliverySaving,
              mediumFont: mediumFont,
              boldFont: boldFont,
            ),
            pw.SizedBox(height: 18),
            _buildOrganizationInfo(),
            pw.SizedBox(height: 22),
            _buildSectionTitle(
              iconText: '▣',
              title: 'ÖDEME PLANI',
              boldFont: boldFont,
            ),
            pw.SizedBox(height: 10),
            _buildPaymentTable(
              result: result,
              mediumFont: mediumFont,
              boldFont: boldFont,
            ),
            pw.SizedBox(height: 18),
            _buildDisclaimer(),
          ];
        },
      ),
    );

    return document.save();
  }

  static pw.Widget _buildHeroHeader({
    required DateTime createdAt,
    required String planNumber,
    required pw.Font boldFont,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(22),
      decoration: pw.BoxDecoration(
        color: _darkGreen,
        borderRadius: pw.BorderRadius.circular(18),
        border: pw.Border.all(
          color: _gold,
          width: 1,
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 6,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Container(
                      width: 42,
                      height: 42,
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        border: pw.Border.all(
                          color: _gold,
                          width: 2,
                        ),
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          'PL',
                          style: pw.TextStyle(
                            color: _gold,
                            fontSize: 22,
                            font: boldFont,
                          ),
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Column(
                      crossAxisAlignment:
                          pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'PLANGO',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 25,
                            font: boldFont,
                            letterSpacing: 2.1,
                          ),
                        ),
                        pw.Text(
                          'FP Engine',
                          style: pw.TextStyle(
                            color: _gold,
                            fontSize: 13,
                            font: boldFont,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 14),
                pw.Text(
                  'Bağımsız Tasarruf Finansmanı\nKarar Destek Platformu',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 10.5,
                    lineSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          pw.Expanded(
            flex: 4,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _headerMeta(
                  label: 'Oluşturulma Tarihi',
                  value: _dateFormat.format(createdAt),
                ),
                pw.SizedBox(height: 13),
                _headerMeta(
                  label: 'Plan No',
                  value: planNumber,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _headerMeta({
    required String label,
    required String value,
  }) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 25,
          height: 25,
          decoration: pw.BoxDecoration(
            color: _gold,
            borderRadius: pw.BorderRadius.circular(7),
          ),
          child: pw.Center(
            child: pw.Text(
              '•',
              style: pw.TextStyle(
                color: _darkGreen,
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
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
                label,
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 8.5,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                value,
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildWelcome({
    required String customerName,
    required pw.Font mediumFont,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(
        left: 14,
      ),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          left: pw.BorderSide(
            color: _gold,
            width: 2,
          ),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Merhaba, $customerName',
            style: pw.TextStyle(
              color: _darkGreen,
              fontSize: 22,
              font: mediumFont,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'Size özel oluşturulan tahmini ödeme planı aşağıda yer almaktadır.',
            style: pw.TextStyle(
              color: PdfColors.grey700,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryArea({
    required CalculationPlan plan,
    required FpResult result,
    required String deliveryDate,
    required double deliverySaving,
    required pw.Font mediumFont,
    required pw.Font boldFont,
  }) {
    return pw.Row(
  crossAxisAlignment: pw.CrossAxisAlignment.start,
  children: [
        pw.Expanded(
          flex: 7,
          child: pw.Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _summaryCard(
                title: 'Finansman Tutarı',
                value: _money(plan.financeAmount),
                width: 142,
                mediumFont: mediumFont,
              ),
              _summaryCard(
                title: 'Peşinat',
                value: _money(plan.downPayment),
                width: 142,
                mediumFont: mediumFont,
              ),
              _summaryCard(
                title: 'Başlangıç Taksiti',
                value: _money(plan.monthlyInstallment),
                width: 142,
                mediumFont: mediumFont,
              ),
              _summaryCard(
                title: 'Artış Modeli',
                value: plan.increaseModel,
                width: 142,
                mediumFont: mediumFont,
              ),
              _summaryCard(
                title: 'Tahmini Teslim Tarihi',
                value: deliveryDate,
                width: 142,
                mediumFont: mediumFont,
              ),
              _summaryCard(
                title: 'Toplam Vade',
                value: '${result.estimatedTerm} Ay',
                width: 142,
                mediumFont: mediumFont,
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 12),
        pw.Expanded(
          flex: 3,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: _darkGreen,
              borderRadius: pw.BorderRadius.circular(15),
              border: pw.Border.all(
                color: _gold,
                width: 1.1,
              ),
            ),
            child: pw.Column(
              mainAxisAlignment:
                  pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'TAHMİNİ TESLİM',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 10,
                    font: boldFont,
                  ),
                ),
                pw.SizedBox(height: 7),
                pw.Text(
                  '${result.estimatedDelivery}',
                  style: pw.TextStyle(
                    color: _gold,
                    fontSize: 40,
                    font: boldFont,
                  ),
                ),
                pw.Text(
                  'AY',
                  style: pw.TextStyle(
                    color: _gold,
                    fontSize: 15,
                    font: boldFont,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Container(
                  height: 1,
                  color: _gold,
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  deliveryDate,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 8.5,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 9),
                pw.Text(
                  'Teslimata Kadar\nTahmini Birikim',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 8.5,
                    lineSpacing: 2,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  _money(deliverySaving),
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 14,
                    font: boldFont,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _summaryCard({
    required String title,
    required String value,
    required double width,
    required pw.Font mediumFont,
  }) {
    return pw.Container(
      width: width,
      constraints: const pw.BoxConstraints(
        minHeight: 72,
      ),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(11),
        border: pw.Border.all(
          color: _line,
          width: 0.8,
        ),
      ),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Container(
            width: 25,
            height: 25,
            decoration: const pw.BoxDecoration(
              color: _lightGreen,
              shape: pw.BoxShape.circle,
            ),
            child: pw.Center(
              child: pw.Text(
                '•',
                style: pw.TextStyle(
                  color: _darkGreen,
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            title,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              color: _darkGreen,
              fontSize: 7.6,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            value,
            textAlign: pw.TextAlign.center,
            maxLines: 2,
            style: pw.TextStyle(
              color: _text,
              fontSize: 9.5,
              font: mediumFont,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildOrganizationInfo() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: _lightGold,
        borderRadius: pw.BorderRadius.circular(11),
        border: pw.Border.all(
          color: _gold,
          width: 0.8,
        ),
      ),
      child: pw.Row(
        children: [
          pw.Container(
            width: 30,
            height: 30,
            decoration: const pw.BoxDecoration(
              color: _gold,
              shape: pw.BoxShape.circle,
            ),
            child: pw.Center(
              child: pw.Text(
                '%',
                style: pw.TextStyle(
                  color: _darkGreen,
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
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
                    color: _darkGreen,
                    fontSize: 9.5,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  'İlgili tasarruf finansman şirketi, kampanya ve sözleşme koşullarına göre belirlenir.',
                  style: pw.TextStyle(
                    color: PdfColors.grey800,
                    fontSize: 8.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSectionTitle({
    required String iconText,
    required String title,
    required pw.Font boldFont,
  }) {
    return pw.Row(
      children: [
        pw.Container(
          width: 26,
          height: 26,
          decoration: pw.BoxDecoration(
            color: _lightGreen,
            borderRadius: pw.BorderRadius.circular(7),
          ),
          child: pw.Center(
            child: pw.Text(
              iconText,
              style: pw.TextStyle(
                color: _darkGreen,
                fontSize: 12,
                font: boldFont,
              ),
            ),
          ),
        ),
        pw.SizedBox(width: 9),
        pw.Text(
          title,
          style: pw.TextStyle(
            color: _darkGreen,
            fontSize: 15,
            font: boldFont,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildPaymentTable({
    required FpResult result,
    required pw.Font mediumFont,
    required pw.Font boldFont,
  }) {
    return pw.Table(
      border: pw.TableBorder.all(
        color: _line,
        width: 0.6,
      ),
      columnWidths: const {
        0: pw.FlexColumnWidth(0.65),
        1: pw.FlexColumnWidth(1.65),
        2: pw.FlexColumnWidth(1.25),
        3: pw.FlexColumnWidth(1.45),
        4: pw.FlexColumnWidth(1.45),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: _darkGreen,
          ),
          children: [
            _headerCell('Ay', boldFont),
            _headerCell('Taksit Tarihi', boldFont),
            _headerCell('Taksit Tutarı', boldFont),
            _headerCell('Toplam Birikim', boldFont),
            _headerCell('Dönem', boldFont),
          ],
        ),
        ...result.paymentPlan.map((PaymentPlanItem item) {
          final PdfColor accent =
              _periodColor(item, result);
          final PdfColor background =
              _periodBackground(item, result);

          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: background,
            ),
            children: [
              _bodyCell(
                '${item.month}',
                color: accent,
                font: boldFont,
                align: pw.TextAlign.center,
              ),
              _bodyCell(
                _dateFormat.format(item.paymentDate),
                font: mediumFont,
                align: pw.TextAlign.center,
              ),
              _bodyCell(
                _money(item.installment),
                font: boldFont,
                align: pw.TextAlign.right,
              ),
              _bodyCell(
                _money(item.totalSaving),
                color: item.isDeliveryMonth
                    ? _darkGreen
                    : _text,
                font: boldFont,
                align: pw.TextAlign.right,
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 4,
                  ),
                  decoration: pw.BoxDecoration(
                    color: accent,
                    borderRadius: pw.BorderRadius.circular(9),
                  ),
                  child: pw.Text(
                    _periodName(item, result),
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 6.8,
                      font: boldFont,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _headerCell(
    String text,
    pw.Font font,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 7,
      ),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontSize: 7.5,
          font: font,
        ),
      ),
    );
  }

  static pw.Widget _bodyCell(
    String text, {
    PdfColor color = _text,
    required pw.Font font,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 7,
      ),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          color: color,
          fontSize: 7.2,
          font: font,
        ),
      ),
    );
  }

  static pw.Widget _buildDisclaimer() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: _softGray,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(
          color: _line,
          width: 0.8,
        ),
      ),
      child: pw.Text(
        'Bu ödeme planı, kullanıcı tarafından girilen bilgiler doğrultusunda '
        'Plango FP Engine tarafından bilgilendirme amacıyla oluşturulmuştur. '
        'Resmî ödeme planı, teslim tarihi, organizasyon ücreti ve sözleşme '
        'koşulları ilgili tasarruf finansman şirketi tarafından belirlenir.',
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          color: PdfColors.grey800,
          fontSize: 7.8,
          lineSpacing: 2,
        ),
      ),
    );
  }
}
