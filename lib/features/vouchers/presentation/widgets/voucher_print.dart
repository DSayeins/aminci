import 'dart:io';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:aminci/core/models/profile.dart';
import 'package:aminci/core/models/voucher.dart';

const int _voucherColumns = 3;
const int _voucherRowsPerPage = 10;
const int _vouchersPerPage = _voucherColumns * _voucherRowsPerPage;
const double _cardRowHeight = 68;
const double _cardRowSpacing = 6;
const double _cardColumnSpacing = 8;

/// Construit le PDF des [vouchers] du profil [profile], paginé à
/// [_voucherRowsPerPage] lignes ([_voucherColumns] colonnes) par page.
///
/// La grille est construite manuellement (Row/Column, hauteur de ligne fixe)
/// plutôt qu'avec `pw.GridView` : ce widget est un `SpanningWidget` censé
/// s'étendre sur plusieurs pages via `MultiPage`, mais son calcul de taille
/// lors du tout premier layout se base sur la hauteur totale disponible
/// divisée par le nombre **total** de lignes de tout le contenu (pas
/// seulement celles de la page courante) — les lignes deviennent alors
/// minuscules et le document explose en dizaines de pages.
pw.Document _buildVouchersDocument(List<Voucher> vouchers, HotspotProfile profile) {
  final doc = pw.Document();
  final batchCode = DateFormat('yyMMdd').format(DateTime.now());

  for (var start = 0; start < vouchers.length; start += _vouchersPerPage) {
    final end = (start + _vouchersPerPage).clamp(0, vouchers.length);
    final pageVouchers = vouchers.sublist(start, end);

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Vouchers - ${profile.mikrotikName}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
            ),
            pw.SizedBox(height: 10),
            _voucherGrid(pageVouchers, batchCode, start),
          ],
        ),
      ),
    );
  }

  return doc;
}

/// Grille manuelle : une ligne fixe (`_cardRowHeight`) de [_voucherColumns]
/// cartes par `Row`, les lignes empilées dans une `Column`.
pw.Widget _voucherGrid(List<Voucher> pageVouchers, String batchCode, int startIndex) {
  final rows = <pw.Widget>[];

  for (var i = 0; i < pageVouchers.length; i += _voucherColumns) {
    if (rows.isNotEmpty) rows.add(_horizontalCutLine());

    final cells = <pw.Widget>[];
    for (var col = 0; col < _voucherColumns; col++) {
      if (col > 0) cells.add(_verticalCutLine());
      final itemIndex = i + col;
      cells.add(
        pw.Expanded(
          child: itemIndex < pageVouchers.length
              ? _voucherCard(pageVouchers[itemIndex], batchCode, startIndex + itemIndex + 1)
              : pw.SizedBox(),
        ),
      );
    }

    rows.add(
      pw.SizedBox(
        height: _cardRowHeight,
        child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: cells),
      ),
    );
  }

  return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: rows);
}

/// Ligne de découpe pointillée verticale, entre deux colonnes de la grille.
pw.Widget _verticalCutLine() => pw.Container(
  width: _cardColumnSpacing,
  decoration: const pw.BoxDecoration(
    border: pw.Border(left: pw.BorderSide(color: PdfColors.grey400, width: 0.75, style: pw.BorderStyle.dashed)),
  ),
);

/// Ligne de découpe pointillée horizontale, entre deux lignes de la grille.
pw.Widget _horizontalCutLine() => pw.Container(
  height: _cardRowSpacing,
  decoration: const pw.BoxDecoration(
    border: pw.Border(top: pw.BorderSide(color: PdfColors.grey400, width: 0.75, style: pw.BorderStyle.dashed)),
  ),
);

/// Génère une fiche imprimable des [vouchers] du profil [profile], sous forme
/// de cartes (une par voucher, avec QR code), et ouvre la boîte de dialogue
/// d'impression du système. Appel manuel (ex: depuis la sélection multiple).
Future<void> printVouchers(List<Voucher> vouchers, HotspotProfile profile) async {
  final doc = _buildVouchersDocument(vouchers, profile);
  await Printing.layoutPdf(onLayout: (_) => doc.save());
}

/// Sauvegarde le PDF des [vouchers] fraîchement générés dans le dossier
/// Documents (nom de fichier = profil + date du jour) puis lance directement
/// l'impression. Appelé automatiquement à la fin d'une génération.
Future<void> saveAndPrintGeneratedVouchers(List<Voucher> vouchers, HotspotProfile profile) async {
  final doc = _buildVouchersDocument(vouchers, profile);
  final bytes = await doc.save();

  final userProfile = Platform.environment['USERPROFILE'];
  final dir = Directory('${userProfile ?? '.'}/Documents/Aminci');
  if (!dir.existsSync()) dir.createSync(recursive: true);

  final safeProfileName = profile.mikrotikName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final file = File('${dir.path}/${safeProfileName}_$date.pdf');
  await file.writeAsBytes(bytes);

  await Printing.layoutPdf(onLayout: (_) => bytes);
}

pw.Widget _voucherCard(Voucher voucher, String batchCode, int index) {
  return pw.Column(
    children: [
      pw.Expanded(
        child: pw.ClipRRect(
          horizontalRadius: 8,
          verticalRadius: 8,
          child: pw.Container(
            decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300, width: 0.75)),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Container(width: 3, color: PdfColors.green700),
                pw.Expanded(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Row(
                                    children: [
                                      pw.Container(
                                        width: 5,
                                        height: 5,
                                        decoration: const pw.BoxDecoration(
                                          shape: pw.BoxShape.circle,
                                          color: PdfColors.green700,
                                        ),
                                      ),
                                      pw.SizedBox(width: 3),
                                      pw.Text('Aminci', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                                    ],
                                  ),
                                  pw.Text(batchCode, style: const pw.TextStyle(color: PdfColors.grey500, fontSize: 6.5)),
                                ],
                              ),
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    'User: ${voucher.code}',
                                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5),
                                  ),
                                  pw.Text(
                                    'Pass: ${voucher.password}',
                                    style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 8.5),
                                  ),
                                ],
                              ),
                              pw.Text(
                                'Durée: ${voucher.limitUptime ?? "illimité"}   Data: ${voucher.limitBytesFmt}',
                                style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 6.5),
                              ),
                            ],
                          ),
                        ),
                        pw.SizedBox(width: 6),
                        pw.BarcodeWidget(
                          barcode: pw.Barcode.qrCode(),
                          data: '${voucher.code}:${voucher.password}',
                          width: 44,
                          height: 44,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      pw.SizedBox(height: 1),
      pw.Text('[$index]', style: const pw.TextStyle(color: PdfColors.grey400, fontSize: 6)),
    ],
  );
}
