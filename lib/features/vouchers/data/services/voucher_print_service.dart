import 'dart:math';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:aminci/core/models/voucher.dart';

/// Génère un PDF de tickets hotspot et ouvre la boîte de dialogue d'impression.
///
/// Mise en page : 3 colonnes × 10 lignes = 30 tickets par page A4 portrait.
class VoucherPrintService {
  const VoucherPrintService();

  static const _cols = 3;
  static const _rows = 10;
  static const _perPage = _cols * _rows;

  // Palette
  static const _white = PdfColors.white;
  static const _green = PdfColor(0.231, 0.427, 0.067); // green600
  static const _dark = PdfColor(0.173, 0.173, 0.165); // gray900
  static const _mid = PdfColor(0.373, 0.369, 0.353); // gray600
  static const _grey = PdfColor(0.533, 0.529, 0.502); // gray400
  static const _bgQr = PdfColor(0.961, 0.961, 0.953); // gray50

  Future<void> print(List<Voucher> vouchers) async {
    if (vouchers.isEmpty) return;

    final doc = pw.Document();
    final mono = pw.Font.courier();
    final monoBold = pw.Font.courierBold();
    final sans = pw.Font.helvetica();
    final sansBold = pw.Font.helveticaBold();

    for (var start = 0; start < vouchers.length; start += _perPage) {
      final chunk = vouchers.sublist(start, min(start + _perPage, vouchers.length));

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(12),
          build: (_) {
            final rowWidgets = <pw.Widget>[];
            for (var r = 0; r < _rows; r++) {
              final cells = <pw.Widget>[];
              for (var c = 0; c < _cols; c++) {
                final idx = r * _cols + c;
                cells.add(
                  pw.Expanded(
                    child: idx < chunk.length
                        ? _ticket(chunk[idx], mono, monoBold, sans, sansBold, start + idx + 1)
                        : pw.SizedBox(),
                  ),
                );
              }
              rowWidgets.add(pw.Expanded(child: pw.Row(children: cells)));
            }
            return pw.Column(children: rowWidgets);
          },
        ),
      );
    }

    await Printing.layoutPdf(onLayout: (_) async => doc.save());
  }

  pw.Widget _ticket(Voucher v, pw.Font mono, pw.Font monoBold, pw.Font sans, pw.Font sansBold, int number) {
    final hasUptime = v.limitUptime != null && v.limitUptime!.isNotEmpty;
    final hasData = v.limitBytesTotal > 0;
    final hasPrice = v.price > 0;
    final qrData = 'User: ${v.code}\nPass: ${v.password}';

    return pw.Container(
      margin: const pw.EdgeInsets.all(2),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _dark, width: 1.2),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
      ),
      child: pw.ClipRRect(
        horizontalRadius: 2,
        verticalRadius: 2,
        child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          // ── Colonne prix (fond vert foncé, texte blanc rotaté) ────────────
          pw.Container(
            width: hasPrice ? 16 : 6,
            color: _green,
            child: hasPrice
                ? pw.Center(
                    child: pw.Transform.rotate(
                      angle: pi / 2,
                      child: pw.Text(
                        'CFA ${v.price.toStringAsFixed(0)}',
                        style: pw.TextStyle(fontSize: 6.5, color: _white, font: sansBold, letterSpacing: 0.5),
                      ),
                    ),
                  )
                : pw.SizedBox(),
          ),

          // ── Contenu principal ─────────────────────────────────────────────
          pw.Expanded(
            child: pw.Padding(
              padding: const pw.EdgeInsets.fromLTRB(7, 5, 6, 5),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  // En-tête : nom du projet + profil
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Container(
                            width: 4,
                            height: 4,
                            decoration: const pw.BoxDecoration(color: _green, shape: pw.BoxShape.circle),
                          ),
                          pw.SizedBox(width: 4),
                          pw.Text(
                            'Aminci',
                            style: pw.TextStyle(fontSize: 8, color: _green, font: sansBold),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 1),
                      pw.Text(
                        v.profileName,
                        style: pw.TextStyle(fontSize: 6, color: _grey, font: sans),
                      ),
                    ],
                  ),

                  // Identifiants
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _credLine('User', v.code, mono, monoBold),
                      pw.SizedBox(height: 1),
                      _credLine('Pass', v.password, mono, monoBold),
                    ],
                  ),

                  // Limites
                  if (hasUptime || hasData)
                    pw.Text(
                      [if (hasUptime) 'Durée: ${v.limitUptime}', if (hasData) 'Data: ${v.limitBytesFmt}'].join('  '),
                      style: pw.TextStyle(fontSize: 6, color: _grey, font: sans),
                    )
                  else
                    pw.SizedBox(),
                ],
              ),
            ),
          ),

          // ── Colonne QR (fond gris très clair) ────────────────────────────
          pw.Container(
            color: _bgQr,
            padding: const pw.EdgeInsets.all(4),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: qrData,
                  width: 50,
                  height: 50,
                  drawText: false,
                  color: _dark,
                ),
                pw.Text(
                  '[$number]',
                  style: pw.TextStyle(fontSize: 5, color: _grey, font: mono),
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }

  /// Ligne `Label : Valeur` avec label grisé et valeur en monospace bold.
  static pw.Widget _credLine(String label, String value, pw.Font mono, pw.Font monoBold) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          '$label: ',
          style: pw.TextStyle(fontSize: 6.5, color: _mid, font: mono),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 7.5, color: _dark, font: monoBold),
        ),
      ],
    );
  }
}
