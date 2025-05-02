import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/landlord_confirmation_dialog.dart';

// Componentes de sección
import '../component/profile/Perfil.dart';
import '../component/profile/informacionPersonal.dart';
// Arrendador
import '../component/profile/profileArrendador/solicitudesCitas.dart';
import '../component/profile/profileArrendador/solicitudesOfertasPrecios.dart';
import '../component/profile/profileArrendador/misPropiedades.dart';
// Usuario
import '../component/profile/profileUsuario/citasArrendador.dart';
import '../component/profile/profileUsuario/listaFavoritos.dart';

class ProfileScreen extends StatefulWidget {
  final String? initialSection;
  const ProfileScreen({super.key, this.initialSection});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isCollapsed = false;
  late String activeSection;
  bool isMobile = false;
  bool isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    activeSection = widget.initialSection ?? 'perfil';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    isMobile = MediaQuery.of(context).size.width < 600;

    if (!auth.authChecked) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (auth.user == null) {
      return const Scaffold(
        body: Center(child: Text('Usuario no autenticado')),
      );
    }

    final user = auth.user!;
    final isArr = auth.isArrendador ?? false;

    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D9488),
          title: Text(
            isArr ? 'Perfil Arrendador' : 'Perfil Aprendiz',
            style: const TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => setState(() => isMenuOpen = !isMenuOpen),
          ),
        ),
        drawer: _buildSidebar(isArr, user, auth),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _renderContent(isArr, auth),
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isCollapsed ? 80 : 280,
            color: const Color(0xFF0D9488),
            child: _buildSidebar(isArr, user, auth),
          ),
          Expanded(
            child: Column(
              children: [
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _renderContent(isArr, auth),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(bool isArr, dynamic user, AuthProvider auth) {
    Widget sidebarContent = Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment:
                isCollapsed && !isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: isCollapsed && !isMobile ? 24 : 20,
                backgroundImage:
                    user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                backgroundColor: Colors.grey[200],
                child: user.photoURL == null
                    ? Icon(Icons.person,
                        size: isCollapsed && !isMobile ? 24 : 20, color: Colors.grey[600])
                    : null,
              ),
              if (!isCollapsed || isMobile) ...[
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName ?? 'Usuario',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                _navItem(Icons.person, 'Perfil', 'perfil'),
                _navItem(Icons.info, 'Información Personal', 'informacion'),
                if (!isArr) ...[
                  _navItem(Icons.favorite, 'Favoritos', 'favoritos'),
                  _navItem(Icons.handshake, 'Ofertas y Contraofertas', 'ofertas_contraofertas'),
                  _navItem(Icons.calendar_today, 'Solicitudes de Citas', 'solicitudes_citas_aprendiz'),
                  _navItem(Icons.book_online, 'Solicitudes de Reservas', 'reservas_usuario'),
                  _navItem(
                    Icons.group,
                    'Registro Arrendador',
                    'registro_arrendador',
                    onTap: () => _showLandlordConfirmationDialog(context),
                  ),
                ] else ...[
                  _navItem(Icons.attach_money, 'Ofertas', 'ofertas'),
                  _navItem(Icons.calendar_today, 'Solicitudes de Citas', 'solicitudes_citas_arrendador'),
                  _navItem(Icons.book_online, 'Solicitudes de Reservas', 'solicitudes_reservas'),
                  _navItem(Icons.apartment, 'Mis Propiedades', 'propiedades'),
                ],
                _navItem(Icons.message, 'Mensajes', 'mensajes'),
                _navItem(Icons.home, 'Inicio', 'inicio',
                    onTap: () => Navigator.pushReplacementNamed(context, '/home')),
                _navItem(Icons.logout, 'Cerrar Sesión', 'logout', onTap: () async {
                  await auth.logout();
                  Navigator.pushReplacementNamed(context, '/login');
                }),
              ],
            ),
          ),
        ),
      ],
    );

    if (isMobile) {
      return Drawer(
        backgroundColor: const Color(0xFF0D9488),
        child: sidebarContent,
      );
    }
    return sidebarContent;
  }

  /// Muestra el diálogo de confirmación de registro como arrendador
  void _showLandlordConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const LandlordConfirmationDialog(),
    );
    if (isMobile) Navigator.pop(context);
  }

  Widget _navItem(IconData icon, String label, String section, {VoidCallback? onTap}) {
    final isActive = activeSection == section;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap ?? () {
          setState(() {
            activeSection = section;
            if (isMobile) Navigator.pop(context);
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isActive ? Colors.white.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white),
              if (!isCollapsed || isMobile) ...[
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    label,
                    style: const TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _renderContent(bool isArrendador, AuthProvider auth) {
    if (activeSection == 'registro_arrendador' && !isArrendador) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLandlordConfirmationDialog(context);
        setState(() => activeSection = 'perfil');
      });
      return const Center(child: Text('Cargando...'));
    }

    switch (activeSection) {
      case 'perfil':
        return const PerfilComponent();
      case 'informacion':
        return const InformacionPersonal();
      case 'favoritos':
        return const FavoritosList(favoriteIds: []);
      case 'solicitudes_citas_aprendiz':
        return const SolicitudesCitasAprendiz();
      case 'solicitudes_citas_arrendador':
        return const CitasArrendador();
      case 'ofertas':
        return const OfertasPrecios();
      case 'propiedades':
        return const MisPropiedades(propiedades: []);
      case 'mensajes':
        return const Center(child: Text('Mensajes en desarrollo'));
      default:
        return const Center(child: Text('En desarrollo'));
    }
  }
}
