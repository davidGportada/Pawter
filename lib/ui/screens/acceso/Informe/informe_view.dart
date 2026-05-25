import 'package:flutter/material.dart';
import 'package:pawter/data/models/historial_clinico.dart';
import 'package:pawter/data/models/mascotas.dart';
import 'package:pawter/data/models/usuarios.dart';
import 'package:pawter/widgets/pdf/CreaPDF.dart';
import 'package:pawter/widgets/pdf/ficha_contenido.dart';
import 'package:pawter/ui/utils/app_colors.dart';

class InformeMedicoDetalleView extends StatelessWidget {
  final HistorialClinico registro;
  final Mascota mascota;
  final Usuario? propietario;

  const InformeMedicoDetalleView({
    super.key,
    required this.registro,
    required this.mascota,
    this.propietario,
  });

  @override
  Widget build(BuildContext context) {
    final infoGeneral = FichaClinicaLogic.obtenerInfoGeneral(
      registro,
      mascota,
      propietario,
    );

    return Scaffold(
      backgroundColor: AppColors.blancoTiza,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.darkTeal),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Image.asset(
            "assets/LogoPawter.png",
            height: 75,
            fit: BoxFit.contain,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf, color: AppColors.lightRed),
            onPressed: () async {
              await PdfHelper.generarInformePdf(
                registro: registro,
                mascota: mascota,
                usuario: propietario,
                descargaDirecta: false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [BoxShadow(color: AppColors.black10, blurRadius: 10)],
          ),
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "INFORME DE CONSULTA",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkTeal,
                ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Fecha: ${FichaClinicaLogic.obtenerFechaInforme(registro.fecha)}",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              SizedBox(height: 15),

              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: Column(
                  children: infoGeneral.map((info) {
                    return FilaDoble(
                      izq: Celda("${info['izq_label']} ${info['izq_val']}"),
                      der: Celda("${info['der_label']} ${info['der_val']}"),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: Column(
                  children: [
                    FilaUnica(
                      Celda("DIAGNÓSTICO", negrita: true, fondoGris: true),
                    ),

                    FilaUnica(
                      Celda(
                        "\n${registro.diagnostico ?? 'Sin detalles registrados.'}",
                        altoMinimo: 120,
                      ),
                    ),

                    FilaUnica(
                      Celda("TRATAMIENTO", negrita: true, fondoGris: true),
                    ),

                    FilaUnica(
                      Celda(
                        "\n${registro.tratamiento ?? 'Sin detalles registrados.'}",
                        altoMinimo: 120,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 60),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Firma del veterinario: ____________________",
                  style: TextStyle(color: AppColors.darkTeal),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
