import 'package:flutter/material.dart';
import 'package:pawter/ui/screens/acceso/Informe/informe_view.dart';
import 'package:pawter/ui/screens/acceso/cliente/cliente_viewmodel.dart';
import 'package:pawter/widgets/pdf/CreaPDF.dart';
import 'package:provider/provider.dart';
import 'package:pawter/data/models/mascotas.dart';
import 'package:pawter/ui/utils/app_colors.dart';
import 'package:pawter/ui/screens/acceso/Historial%20Clinico/historial_viewmodel.dart';
import 'package:pawter/ui/screens/acceso/Historial%20Clinico/crear_consulta_view.dart';
import 'package:pawter/ui/screens/acceso/veterinario/vet_viewmodel.dart';
import 'package:pawter/data/models/usuarios.dart';

class HistorialMedicoView extends StatefulWidget {
  final Mascota mascota;
  final bool esVeterinario;

  const HistorialMedicoView({
    super.key, 
    required this.mascota,
    this.esVeterinario = false,
  });
  @override
  State<HistorialMedicoView> createState() => _HistorialMedicoViewState();
}

class _HistorialMedicoViewState extends State<HistorialMedicoView> {
  bool _cambiosRealizados = false; 
  Color _obtenerColorPorTipo(String? tipo) {
    switch (tipo?.toLowerCase()) {
      case 'vacuna': return AppColors.tagVacuna;
      case 'urgencia': return AppColors.tagUrgencia;
      case 'revision': return AppColors.primaryGreen;
      case 'otros': return AppColors.tagOtros;
      default: return AppColors.tagDefault;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HistorialClinicoViewModel()..cargarHistorial(widget.mascota.idMascota),
      child: Scaffold(
        backgroundColor: AppColors.blancoTiza,
        appBar: AppBar(
          title: Text(
            "Historial de ${widget.mascota.nombre}",
            style: TextStyle(color: AppColors.darkTeal, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppColors.darkTeal),
            onPressed: () => Navigator.pop(context, _cambiosRealizados),
          ),
        ),
        body: Column(
          children: [
            _barraFiltros(),
            Expanded(child: _listaRegistrosClinicos()),
          ],
        ),
        floatingActionButton: widget.esVeterinario
            ? Builder(
                builder: (ctx) => FloatingActionButton(
                  backgroundColor: AppColors.primaryGreen,
                  child: Icon(Icons.add, color: AppColors.white),
                  onPressed: () async {
                    final creado = await Navigator.push(
                      ctx,
                      MaterialPageRoute(
                        builder: (_) => CrearConsultaView(mascota: widget.mascota),
                      ),
                    );
                    if (creado == true && ctx.mounted) {
                      setState(() => _cambiosRealizados = true);
                      ctx.read<HistorialClinicoViewModel>().cargarHistorial(widget.mascota.idMascota);
                    }
                  },
                ),
              )
            : null,
      ),
    );
  }

  Widget _barraFiltros() {
    return Consumer<HistorialClinicoViewModel>(
      builder: (context, vm, _) => SizedBox(
        height: 65,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          itemCount: vm.categorias.length,
          itemBuilder: (context, index) {
            final categoria = vm.categorias[index];
            final esSeleccionado = vm.tagSeleccionado == categoria;

            return Padding(
              padding: EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () => vm.filtrarPorTag(categoria),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 22),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: esSeleccionado ? AppColors.primaryGreen : AppColors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: esSeleccionado ? AppColors.primaryGreen : AppColors.black10,
                    ),
                  ),
                  child: Text(
                    categoria,
                    style: TextStyle(
                      color: esSeleccionado ? AppColors.white : AppColors.darkTeal,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _listaRegistrosClinicos() {
    return Consumer<HistorialClinicoViewModel>(
      builder: (context, vm, _) {
        if (vm.cargando) {
          return Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
        }

        final registros = vm.registrosFiltrados;
        if (registros.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: Text(
                "Sin registros todavía",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textGrey, fontSize: 16),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(24),
          physics: const BouncingScrollPhysics(),
          itemCount: registros.length,
          itemBuilder: (context, index) {
            final historial = registros[index];
            final colorTag = _obtenerColorPorTipo(historial.tipoRegistro);

            return Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: InkWell(
                onTap: () {
                  Usuario? dueno;
                  
                  if (widget.esVeterinario) {
                    final vmVeterinario = context.read<VeterinarioViewModel>();
                    try {
                      dueno = vmVeterinario.pacientesFiltrados
                          .firstWhere((p) => p.mascota.idMascota == widget.mascota.idMascota)
                          .dueno;
                    } catch (_) {}
                  } else {
                    dueno = context.read<ClienteViewModel>().usuario;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InformeMedicoDetalleView(
                        registro: historial,
                        mascota: widget.mascota,
                        propietario: dueno,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border(left: BorderSide(color: colorTag, width: 8)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black05,
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: colorTag.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                (historial.tipoRegistro ?? "CONSULTA").toUpperCase(),
                                style: TextStyle(color: colorTag, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ),
                            Text(
                              "${historial.fecha.day.toString().padLeft(2, '0')}/${historial.fecha.month.toString().padLeft(2, '0')}/${historial.fecha.year}",
                              style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text(
                          historial.titulo ?? "Consulta general",
                          style:  TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkTeal,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          historial.diagnostico ?? "Sin descripción.",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.black54, height: 1.4, fontSize: 14),
                        ),
                        Divider(height: 35),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              historial.nombreVeterinario ?? "Veterinario",
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54),
                            ),
                            if (!widget.esVeterinario)
                              IconButton(
                                onPressed: () async {
                                  final usuario = context.read<ClienteViewModel>().usuario;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Preparando documento...'),
                                      backgroundColor: AppColors.darkTeal,
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                  await Future.delayed(Duration(milliseconds: 100));
                                  await PdfHelper.generarInformePdf(
                                    registro: historial,
                                    mascota: widget.mascota,
                                    usuario: usuario,
                                    descargaDirecta: true,
                                  );
                                },
                                icon: Icon(
                                  Icons.picture_as_pdf_rounded,
                                  color: AppColors.lightRed,
                                  size: 26,
                                ),
                                tooltip: "Descargar PDF",
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}