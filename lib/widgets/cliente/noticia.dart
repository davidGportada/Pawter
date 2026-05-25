
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pawter/ui/utils/app_colors.dart';

class Noticia {
  final String titulo;
  final String imagenUrl;
  final String enlace;

  const Noticia({
    required this.titulo,
    required this.imagenUrl,
    required this.enlace,
  });
}

const List<Noticia> noticias = [
  Noticia(
    titulo: '¿Por qué los gatos amasan?',
    imagenUrl: 'https://images.unsplash.com/photo-1511275539165-cc46b1ee89bf?q=80&w=1740&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D?w=600&q=80',
    enlace: 'https://onlyfresh.com/blogs/noticias/por-que-los-gatos-amasan',
  ),
  Noticia(
    titulo: 'La IA que traduce ladridos y maullidos con precisión',
    imagenUrl: 'https://plus.unsplash.com/premium_photo-1661676172038-377ab3d82a18?q=80&w=1740&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D?w=600&q=80',
    enlace: 'https://www.elespanol.com/omicrono/hardware/20260418/invento-entender-perro-dispositivo-ia-traduce-ladridos-maullidos-precision/1003744208634_0.html',
  ),
  Noticia(
    titulo: '¿Por qué los perros se estiran antes de saludar?',
    imagenUrl: 'https://images.unsplash.com/photo-1709497083548-b6669f390b64?q=80&w=1738&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D?w=600&q=80',
    enlace: 'https://tctelevision.com/lo-ultimo/ciencia-tecnologia/por-que-los-perros-se-estiran-antes-de-saludar/',
  ),
  Noticia(
    titulo: 'Ni indiferencia ni falta de memoria: el estudio que confirma que tu gato reconoce su nombre',
    imagenUrl: 'https://images.unsplash.com/photo-1638947693941-669835e07b4c?q=80&w=1740&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D?w=600&q=80',
    enlace: 'https://www.vozpopuli.com/mascotas/ni-indiferencia-ni-falta-de-memoria-el-estudio-que-confirma-que-tu-gato-reconoce-su-nombre-perfectamente.html',
  ),
];

class NoticiaCard extends StatelessWidget {
  final Noticia noticia;

  const NoticiaCard({super.key, required this.noticia});

  Future<void> _abrirEnlace() async {
    final uri = Uri.parse(noticia.enlace);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _abrirEnlace,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: AppColors.black05, blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            Expanded(
              child: Image.network(
                noticia.imagenUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: AppColors.lightGrey,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.lightGrey,
                  child: Icon(Icons.image_not_supported_outlined,
                      color: AppColors.textGrey),
                ),
              ),
            ),
            // Título
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                noticia.titulo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkTeal,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}