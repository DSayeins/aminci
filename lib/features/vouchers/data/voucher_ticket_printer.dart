import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:aminci/core/models/profile.dart';
import 'package:aminci/core/models/voucher.dart';

/// Génère et envoie au système d'impression une page de tickets voucher.
///
/// Mise en page : 3 tickets par ligne, format A4 portrait.
abstract final class VoucherTicketPrinter {
  static const _perRow = 3;
  static const _pageMargin = 20.0;
  static const _gap = 8.0;

  /// Couleurs Aminci
  static const _green = PdfColor.fromInt(0xFF4CAF50);
  static const _greenLight = PdfColor.fromInt(0xFFE8F5E9);
  static const _textPrimary = PdfColor.fromInt(0xFF1A1A1A);
  static const _textSecondary = PdfColor.fromInt(0xFF6B6B6B);
  static const _border = PdfColor.fromInt(0xFFDDDDDD);

  static Future<void> printTickets({
    required List<Voucher> vouchers,
    required String routerName,
    required Map<String, HotspotProfile> profilesByName,
  }) async {
    final doc = pw.Document();

    // Polices intégrées PDF (pas de dépendance réseau)
    final regular = pw.Font.helvetica();
    final bold = pw.Font.helveticaBold();
    final mono = pw.Font.courier();

    // Calcul des dimensions — A4 : 595.28 x 841.89 pts
    final pageWidth = PdfPageFormat.a4.availableWidth;
    final ticketWidth = (pageWidth - (_perRow - 1) * _gap) / _perRow;
    const ticketHeight = 175.0;

    // Découper les vouchers en pages (calcul du nombre de lignes par page)
    const rowsPerPage = 4;
    const perPage = _perRow * rowsPerPage;
    final pages = <List<Voucher>>[];
    for (var i = 0; i < vouchers.length; i += perPage) {
      pages.add(vouchers.sublist(i, i + perPage > vouchers.length ? vouchers.length : i + perPage));
    }

    for (final pageVouchers in pages) {
      // Regrouper en lignes de 3
      final rows = <List<Voucher>>[];
      for (var i = 0; i < pageVouchers.length; i += _perRow) {
        rows.add(pageVouchers.sublist(i, i + _perRow > pageVouchers.length ? pageVouchers.length : i + _perRow));
      }

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(_pageMargin),
          build: (ctx) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: rows.map((rowVouchers) {
              return pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: _gap),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: rowVouchers.map((v) {
                    final profile = profilesByName[v.profileName];
                    return pw.Padding(
                      padding: pw.EdgeInsets.only(right: rowVouchers.last == v ? 0 : _gap),
                      child: _buildTicket(
                        voucher: v,
                        profile: profile,
                        routerName: routerName,
                        width: ticketWidth,
                        height: ticketHeight,
                        regular: regular,
                        bold: bold,
                        mono: mono,
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ),
        ),
      );
    }

    await Printing.layoutPdf(onLayout: (_) async => doc.save());
  }

  static pw.Widget _buildTicket({
    required Voucher voucher,
    required HotspotProfile? profile,
    required String routerName,
    required double width,
    required double height,
    required pw.Font regular,
    required pw.Font bold,
    required pw.Font mono,
  }) {
    return pw.Container(
      width: width,
      height: height,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _border, width: 0.5),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          // En-tête vert
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: const pw.BoxDecoration(
              color: _green,
              borderRadius: pw.BorderRadius.only(topLeft: pw.Radius.circular(5), topRight: pw.Radius.circular(5)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'AMINCI',
                  style: pw.TextStyle(font: bold, fontSize: 11, color: PdfColors.white, letterSpacing: 1.5),
                ),
                pw.Text(
                  'Ticket Hotspot',
                  style: pw.TextStyle(font: regular, fontSize: 7, color: PdfColors.white),
                ),
              ],
            ),
          ),

          // Corps
          pw.Expanded(
            child: pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Code + mot de passe
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: pw.BoxDecoration(
                      color: _greenLight,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          voucher.code,
                          style: pw.TextStyle(font: mono, fontSize: 14, color: _textPrimary, letterSpacing: 1),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Mot de passe : ${voucher.password}',
                          style: pw.TextStyle(font: mono, fontSize: 7.5, color: _textSecondary),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 7),

                  // Infos en grille 2 colonnes
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            _infoRow('Profil', voucher.profileName, regular: regular, bold: bold),
                            pw.SizedBox(height: 4),
                            _infoRow('Durée', profile?.sessionTimeout ?? '—', regular: regular, bold: bold),
                            pw.SizedBox(height: 4),
                            _infoRow('Débit', profile?.rateLimit ?? '—', regular: regular, bold: bold),
                          ],
                        ),
                      ),
                      pw.SizedBox(width: 6),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            _infoRow('Site', routerName, regular: regular, bold: bold),
                            pw.SizedBox(height: 4),
                            _infoRow('Prix', '${voucher.price.toStringAsFixed(0)} FCFA', regular: regular, bold: bold),
                            pw.SizedBox(height: 4),
                            _infoRow('Date', _formatDate(voucher.createdAt), regular: regular, bold: bold),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _infoRow(String label, String value, {required pw.Font regular, required pw.Font bold}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label.toUpperCase(),
          style: pw.TextStyle(font: regular, fontSize: 6, color: _textSecondary),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(font: bold, fontSize: 8, color: _textPrimary),
        ),
      ],
    );
  }

  static String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year;
    return '$d/$m/$y';
  }
}
