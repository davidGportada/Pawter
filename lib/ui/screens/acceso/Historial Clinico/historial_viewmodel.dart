import 'package:flutter/material.dart';
import 'package:pawter/data/models/historial_clinico.dart';
import 'package:pawter/data/repositories/historial_repository.dart';

class HistorialClinicoViewModel extends ChangeNotifier {
  final HistorialRepository _repo = HistorialRepository();
  List<HistorialClinico> _todosLosRegistros = [];
  String _tagSeleccionado = 'Todos';
  bool cargando = true; 
  String get tagSeleccionado => _tagSeleccionado;
  final List<String> categorias = [
    'Todos',
    'Urgencia',
    'Vacuna',
    'Revision',
    'Otros', 
  ];

  Future<void> cargarHistorial(int idMascota) async {
    cargando = true;
    notifyListeners();
    try {
      _todosLosRegistros = await _repo.obtenerHistorial(idMascota);
    } catch (_) {
      _todosLosRegistros = [];
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  void filtrarPorTag(String tag) {
    _tagSeleccionado = tag;
    notifyListeners();
  }

  List<HistorialClinico> get registrosFiltrados {
    if (_tagSeleccionado == 'Todos') return _todosLosRegistros;
    
    //filtro comparando en minúsculas para evitar errores de escritura por parte del usuario
    return _todosLosRegistros
        .where(
          (r) => r.tipoRegistro?.toLowerCase() == _tagSeleccionado.toLowerCase(),
        )
        .toList();
  }
}