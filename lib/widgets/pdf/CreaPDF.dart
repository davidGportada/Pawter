import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pawter/data/models/historial_clinico.dart';
import 'package:pawter/data/models/mascotas.dart';
import 'package:pawter/widgets/pdf/ficha_contenido.dart';

class PdfHelper {
  static Future<void> generarInformePdf({
    required HistorialClinico registro,
    required Mascota mascota,
    required dynamic usuario,
    bool descargaDirecta = false,
  }) async {
    final pdf = pw.Document();
    final ByteData bytes = await rootBundle.load('assets/LogoPawter.png');
    final Uint8List listaBytes = bytes.buffer.asUint8List();
    final logo = pw.MemoryImage(listaBytes);
    final infoGeneral = FichaClinicaLogic.obtenerInfoGeneral(registro, mascota, usuario);
    final fechaFormateada = FichaClinicaLogic.obtenerFechaInforme(registro.fecha);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) => [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Center(child: pw.Image(logo, height: 45)),
              pw.SizedBox(height: 16),

              pw.Text(
                "INFORME DE CONSULTA",
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  "Fecha: $fechaFormateada",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: const {
                  0: pw.FlexColumnWidth(),
                  1: pw.FlexColumnWidth(),
                },
                children: infoGeneral.map((info) {
                  return pw.TableRow(
                    children: [
                      _celdaPdf("${info['izq_label']} ${info['izq_val']}"),
                      _celdaPdf("${info['der_label']} ${info['der_val']}"),
                    ],
                  );
                }).toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border.all()),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    _celdaPdf("DIAGNÓSTICO", negrita: true, fondoGris: true),
                    pw.Container(
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(top: pw.BorderSide()),
                      ),
                      child: _celdaPdf(
                        "\n${registro.diagnostico ?? 'Sin detalles registrados.'}",
                        minHeight: 100,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border.all()),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    _celdaPdf("TRATAMIENTO", negrita: true, fondoGris: true),
                    pw.Container(
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(top: pw.BorderSide()),
                      ),
                      child: _celdaPdf(
                        "\n${registro.tratamiento ?? 'Sin detalles registrados.'}",
                        minHeight: 100,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 60),

              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text("Firma del veterinario: ____________________"),
              ),
            ],
          ),
        ],
      ),
    );

    final nombreArchivo = 'Informe_${mascota.nombre}_${registro.tipoRegistro}.pdf';
    if (descargaDirecta) {
      await Printing.sharePdf(bytes: await pdf.save(), filename: nombreArchivo);
    } else {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: nombreArchivo,
      );
    }
  }

  static pw.Widget _celdaPdf(
    String texto, {
    bool negrita = false,
    bool fondoGris = false,
    double minHeight = 0,
    bool centrado = false,
  }) {
    return pw.Container(
      constraints: pw.BoxConstraints(minHeight: minHeight),
      padding: const pw.EdgeInsets.all(10),
      color: fondoGris ? PdfColors.grey300 : null,
      child: pw.Text(
        texto,
        textAlign: centrado ? pw.TextAlign.center : pw.TextAlign.left,
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: negrita ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}