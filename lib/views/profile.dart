import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

// Componentes de sección
import '../component/profile/Perfil.dart';
import '../component/profile/informacionPersonal.dart';
import '../component/profile/solicitudesCitas.dart';
import '../component/profile/citasArrendador.dart';
import '../component/profile/ofertasPrecios.dart';
import '../component/profile/misPropiedades.dart';
import '../component/profile/registrarArrendador.dart';

class ProfileScreen extends StatefulWidget {
  final String? initialSection;
  const ProfileScreen({super.key, this.initialSection});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isCollapsed = false;
  late String activeSection;
  bool showLandlordModal = false;

  @override
  void initState() {
    super.initState();
    activeSection = widget.initialSection ?? 'perfil';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // 1) Mientras no sepamos si hay sesión
    if (!auth.authChecked) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 2) Si no hay usuario
    if (auth.user == null) {
      return const Scaffold(
        body: Center(child: Text('Usuario no autenticado')),
      );
    }

    // 3) Tenemos usuario: renderizamos el layout
    final user = auth.user!;
    final isArr = auth.isArrendador ?? false;

    return Scaffold(
      body: Row(
        children: [
          // — Sidebar —
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isCollapsed ? 80 : 280,
            color: const Color(0xFF0D9488),
            child: Column(
              children: [
                // Avatar + rol + indicador de carga pequeño
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment:
                        isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: isCollapsed ? 24 : 20,
                        backgroundImage:
                            user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                        backgroundColor: Colors.grey[200],
                        child: user.photoURL == null
                            ? Icon(Icons.person,
                                size: isCollapsed ? 24 : 20, color: Colors.grey[600])
                            : null,
                      ),
                      if (!isCollapsed) ...[
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.displayName ?? 'Usuario',
                              style:
                                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                Text(
                                  isArr ? 'Arrendador' : 'Aprendiz',
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                                if (auth.profileLoading) ...[
                                  const SizedBox(width: 6),
                                  const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // — Menú lateral —
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        _navItem(Icons.person, 'Perfil', 'perfil'),
                        _navItem(Icons.info, 'Información', 'informacion'),
                        if (!isArr) ...[
                          _navItem(Icons.favorite, 'Favoritos', 'favoritos'),
                          _navItem(Icons.calendar_today, 'Solicitudes citas', 'solicitudes_citas_aprendiz'),
                        ] else ...[
                          _navItem(Icons.calendar_today, 'Citas recibidas', 'solicitudes_citas_arrendador'),
                          _navItem(Icons.attach_money, 'Ofertas precio', 'ofertas'),
                        ],
                        _navItem(Icons.apartment, 'Mis propiedades', 'propiedades'),
                        _navItem(Icons.home, 'Inicio', 'inicio',
                            onTap: () => Navigator.pushReplacementNamed(context, '/home')),
                        if (!isArr)
                          _navItem(Icons.group, 'Registro Arrendador', 'registro_arrendador',
                              onTap: () => setState(() => showLandlordModal = true)),
                        _navItem(Icons.logout, 'Cerrar sesión', 'logout',
                            onTap: () async {
                          await auth.logout();
                          Navigator.pushReplacementNamed(context, '/login');
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // — Contenido principal —
          Expanded(
            child: Column(
              children: [
                // Header con colapsar
                Container(
                  color: const Color(0xFF0D9488),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(isCollapsed ? Icons.chevron_right : Icons.chevron_left),
                        color: Colors.white,
                        onPressed: () => setState(() => isCollapsed = !isCollapsed),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isArr ? 'Perfil Arrendador' : 'Perfil Aprendiz',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),

                // Sección activa
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _renderContent(isArr),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Modal de registro de arrendador
      floatingActionButton: showLandlordModal
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                setState(() => showLandlordModal = false);
                showDialog(
                  context: context,
                  builder: (_) => const LandlordRegistrationModal(),
                );
              },
            )
          : null,
    );
  }

  Widget _navItem(IconData icon, String label, String section, {VoidCallback? onTap}) {
    final isActive = activeSection == section;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap ?? () => setState(() => activeSection = section),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isActive ? Colors.white.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Text(label, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _renderContent(bool isArrendador) {
    switch (activeSection) {
      case 'perfil':
        return const PerfilComponent();
      case 'informacion':
        return const InformacionPersonal();
      case 'solicitudes_citas_aprendiz':
        return const SolicitudesCitasAprendiz();
      case 'solicitudes_citas_arrendador':
        return const CitasArrendador();
      case 'ofertas':
        return const OfertasPrecios();
      case 'propiedades':
        return const MisPropiedades(propiedades: []);
      case 'registro_arrendador':
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            builder: (_) => const LandlordRegistrationModal(),
          );
          setState(() => showLandlordModal = false);
        });
        return const SizedBox.shrink();
      default:
        return const Center(child: Text('En desarrollo'));
    }
  }
}
