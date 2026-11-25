import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';
import 'inicio.dart';
import 'mis_publicaciones.dart';
import 'perfil.dart';

class Principal extends StatefulWidget {
  const Principal({super.key});

  @override
  State<Principal> createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  int indice = 0;

  final List<Widget> pantallas = const [Inicio(), MisPublicaciones(), Perfil()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: indice, children: pantallas),
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppTheme.surface,
        indicatorColor: AppTheme.secondary.withValues(alpha: 0.15),
        selectedIndex: indice,
        onDestinationSelected: (valor) {
          setState(() {
            indice = valor;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppTheme.secondary),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment, color: AppTheme.secondary),
            label: 'Mis publicaciones',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppTheme.secondary),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
