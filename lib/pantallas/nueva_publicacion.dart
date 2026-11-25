import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import '../services/fs_service.dart';
import '../theme/app_theme.dart';

class NuevaPublicacion extends StatefulWidget {
  const NuevaPublicacion({super.key});

  @override
  State<NuevaPublicacion> createState() => _NuevaPublicacionState();
}

class _NuevaPublicacionState extends State<NuevaPublicacion> {
  final formKey = GlobalKey<FormState>();
  final tituloController = TextEditingController();
  final descripcionController = TextEditingController();
  final lugarController = TextEditingController();

  final FSService servicio = FSService();

  late final Future<QuerySnapshot> categorias;

  String tipo = 'Perdido';
  String? categoria;
  DateTime fecha = DateTime.now();
  Uint8List? foto;
  bool guardando = false;

  @override
  void initState() {
    super.initState();
    categorias = servicio.obtenerCategorias();
  }

  @override
  void dispose() {
    tituloController.dispose();
    descripcionController.dispose();
    lugarController.dispose();
    super.dispose();
  }

  void mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<void> seleccionarFoto(ImageSource origen) async {
    try {
      final imagen = await ImagePicker().pickImage(
        source: origen,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 70,
      );

      if (imagen == null) return;

      final bytes = await imagen.readAsBytes();

      if (!mounted) return;

      if (bytes.lengthInBytes > 900000) {
        mostrarMensaje('La fotografía supera el tamaño permitido');
        return;
      }

      setState(() {
        foto = bytes;
      });
    } catch (e) {
      if (mounted) {
        mostrarMensaje('No se pudo obtener la fotografía');
      }
    }
  }

  Future<void> seleccionarFecha() async {
    final seleccion = await showDatePicker(
      context: context,
      initialDate: fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (seleccion == null || !mounted) return;

    setState(() {
      fecha = DateTime(
        seleccion.year,
        seleccion.month,
        seleccion.day,
        fecha.hour,
        fecha.minute,
      );
    });
  }

  Future<void> seleccionarHora() async {
    final seleccion = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(fecha),
    );

    if (seleccion == null || !mounted) return;

    setState(() {
      fecha = DateTime(
        fecha.year,
        fecha.month,
        fecha.day,
        seleccion.hour,
        seleccion.minute,
      );
    });
  }

  String formatearFecha() {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year}';
  }

  String formatearHora() {
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');

    return '$hora:$minuto';
  }

  Future<void> publicar() async {
    if (!formKey.currentState!.validate()) return;

    if (foto == null) {
      mostrarMensaje('Debes agregar una fotografía');
      return;
    }

    if (foto!.lengthInBytes > 900000) {
      mostrarMensaje('La fotografía supera el tamaño permitido');
      return;
    }

    if (fecha.isAfter(DateTime.now())) {
      mostrarMensaje('La fecha y hora no pueden ser futuras');
      return;
    }

    setState(() {
      guardando = true;
    });

    try {
      await servicio.agregarPublicacion(
        tituloController.text.trim(),
        descripcionController.text.trim(),
        tipo,
        categoria!,
        lugarController.text.trim(),
        fecha,
        foto!,
      );

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        mostrarMensaje('No se pudo guardar la publicación');
        debugPrint(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          guardando = false;
        });
      }
    }
  }

  InputDecoration decoracion(String texto) {
    return InputDecoration(
      hintText: texto,
      filled: true,
      fillColor: AppTheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.border),
      ),
    );
  }

  Widget etiqueta(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppTheme.primary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.primary,
        title: const Text(
          'Nueva publicación',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Publica un objeto',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Completa los datos del objeto perdido o encontrado.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 24),
              etiqueta('Título'),
              TextFormField(
                controller: tituloController,
                maxLength: 100,
                decoration: decoracion('Ej. Audífonos Bluetooth negros'),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Ingresa un título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              etiqueta('Descripción'),
              TextFormField(
                controller: descripcionController,
                maxLines: 4,
                maxLength: 500,
                decoration: decoracion(
                  'Describe las características del objeto',
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Ingresa una descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              etiqueta('Tipo de publicación'),
              DropdownButtonFormField<String>(
                initialValue: tipo,
                decoration: decoracion('Selecciona el tipo'),
                items: const [
                  DropdownMenuItem(value: 'Perdido', child: Text('Perdido')),
                  DropdownMenuItem(
                    value: 'Encontrado',
                    child: Text('Encontrado'),
                  ),
                ],
                onChanged: (valor) {
                  setState(() {
                    tipo = valor!;
                  });
                },
              ),
              const SizedBox(height: 20),
              etiqueta('Categoría'),
              FutureBuilder<QuerySnapshot>(
                future: categorias,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Error al cargar las categorías');
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return DropdownButtonFormField<String>(
                    initialValue: categoria,
                    isExpanded: true,
                    decoration: decoracion('Selecciona una categoría'),
                    items: snapshot.data!.docs.map((doc) {
                      final nombre = doc['nombre'] as String;

                      return DropdownMenuItem<String>(
                        value: nombre,
                        child: Text(nombre),
                      );
                    }).toList(),
                    onChanged: (valor) {
                      setState(() {
                        categoria = valor;
                      });
                    },
                    validator: (valor) {
                      if (valor == null) {
                        return 'Selecciona una categoría';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
              etiqueta('Lugar del campus'),
              TextFormField(
                controller: lugarController,
                maxLength: 150,
                decoration: decoracion('Ej. Biblioteca Central'),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Ingresa el lugar';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              etiqueta('Fecha y hora'),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: seleccionarFecha,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(formatearFecha()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: seleccionarHora,
                      icon: const Icon(Icons.access_time),
                      label: Text(formatearHora()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              etiqueta('Fotografía del objeto'),
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.border),
                ),
                child: foto == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            size: 45,
                            color: AppTheme.textSecondary,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Agrega una fotografía',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.memory(foto!, fit: BoxFit.contain),
                      ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        seleccionarFoto(ImageSource.camera);
                      },
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Cámara'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        seleccionarFoto(ImageSource.gallery);
                      },
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Galería'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: guardando || categoria == null ? null : publicar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondary,
                    foregroundColor: AppTheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: guardando
                      ? const CircularProgressIndicator(color: AppTheme.surface)
                      : const Text(
                          'Publicar objeto',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
