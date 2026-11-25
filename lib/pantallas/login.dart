import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';
import '../services/auth_service.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool cargando = false;

  Future<void> iniciarSesion() async {
    setState(() {
      cargando = true;
    });

    try {
      await AuthService().iniciarSesionGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo iniciar sesión')),
        );

        debugPrint(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            color: AppTheme.secondary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.search,
                            size: 60,
                            color: AppTheme.surface,
                          ),
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          'ReEncuentra',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.surface,
                          ),
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          'Lo que pierdes, alguien puede encontrarlo.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            color: AppTheme.surface,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),

                      const Text(
                        '¡Bienvenido!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'Encuentra objetos perdidos y ayuda '
                        'a tu comunidad universitaria.',
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: AppTheme.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 32),

                      Center(
                        child: cargando
                            ? const CircularProgressIndicator()
                            : GestureDetector(
                                onTap: iniciarSesion,
                                child: Image.asset(
                                  'assets/images/google.png',
                                  width: 240,
                                  fit: BoxFit.contain,
                                ),
                              ),
                      ),

                      const SizedBox(height: 28),

                      const Center(
                        child: Text(
                          'Acceso seguro a través de Google',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
