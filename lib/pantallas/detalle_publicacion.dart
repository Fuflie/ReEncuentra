import 'package:material_ui/material_ui.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/fs_service.dart';
import '../theme/app_theme.dart';

class DetallePublicacion extends StatelessWidget {
  final String id;

  const DetallePublicacion({super.key, required this.id});

  String formatearFecha(Timestamp timestamp) {
    final fecha = timestamp.toDate();
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year} $hora:$minuto';
  }

  Future<void> marcarDevuelto(BuildContext context) async {
    try {
      await FSService().marcarDevuelto(id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Objeto marcado como devuelto')),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo actualizar la publicación')),
      );
    }
  }

  Future<void> eliminar(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar publicación'),
          content: const Text(
            '¿Estás seguro de que deseas eliminar esta publicación? '
            'Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !context.mounted) return;

    try {
      await FSService().eliminarPublicacion(id);

      if (!context.mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo eliminar la publicación')),
      );
    }
  }

  Widget informacion(IconData icono, String titulo, String valor) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icono, color: AppTheme.secondary),
      title: Text(
        titulo,
        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
      ),
      subtitle: Text(
        valor,
        style: const TextStyle(
          fontSize: 15,
          color: AppTheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget etiqueta(String texto, Color fondo, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        texto,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuario = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.primary,
        title: const Text('Detalle de publicación'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('publicaciones')
            .doc(id)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar la publicación'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final documento = snapshot.data!;

          if (!documento.exists) {
            return const Center(child: Text('La publicación ya no existe'));
          }

          final foto = documento['foto'] as Blob;
          final tipo = documento['tipo'] as String;
          final estado = documento['estado'] as String;

          final esAutor = usuario?.uid == documento['autorId'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.memory(foto.bytes, fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  children: [
                    etiqueta(
                      tipo,
                      tipo == 'Perdido'
                          ? const Color(0xFFFFE9D9)
                          : const Color(0xFFDDEEF8),
                      tipo == 'Perdido'
                          ? const Color(0xFFA65D26)
                          : AppTheme.primary,
                    ),
                    etiqueta(
                      estado,
                      estado == 'Devuelto'
                          ? const Color(0xFFDDF2E4)
                          : AppTheme.surface,
                      estado == 'Devuelto'
                          ? const Color(0xFF287A48)
                          : AppTheme.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  documento['titulo'],
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  documento['categoria'],
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Descripción',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  documento['descripcion'],
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      informacion(
                        Icons.location_on_outlined,
                        'Lugar',
                        documento['lugar'],
                      ),
                      const Divider(),
                      informacion(
                        Icons.calendar_today_outlined,
                        'Fecha y hora',
                        formatearFecha(documento['fecha']),
                      ),
                      const Divider(),
                      informacion(
                        Icons.person_outline,
                        'Publicado por',
                        documento['autorNombre'],
                      ),
                    ],
                  ),
                ),
                if (estado == 'Devuelto') ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDF2E4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: Color(0xFF287A48),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Este objeto ya fue devuelto a su dueño.',
                            style: TextStyle(color: Color(0xFF287A48)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (esAutor) ...[
                  const SizedBox(height: 24),
                  if (estado == 'Vigente')
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          marcarDevuelto(context);
                        },
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Marcar como devuelto'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondary,
                          foregroundColor: AppTheme.surface,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        eliminar(context);
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Eliminar publicación'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
