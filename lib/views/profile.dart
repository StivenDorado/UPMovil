import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

// Componentes de perfil
import '../component/profile/informacionPersonal.dart';
/* import '../component/profile/listaFavoritos.dart'; */
import '../component/profile/ofertasPrecios.dart';
import '../component/profile/citasArrendador.dart';
import '../component/profile/solicitudesCitas.dart';
import '../component/profile/misPropiedades.dart';
/* import '../component/profile/mensajes.dart';
import '../component/profile/solicitudesReservas.dart'; */
import '../component/profile/Perfil.dart';
/* import '../component/profile/registrarArrendador.dart'; */

// Proveedor de autenticación
import '../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  final String? initialSection;

  const ProfileScreen({super.key, this.initialSection});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
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
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user; // Ajusta según tu AuthProvider
    final userType = (user?.esArrendador ?? false) ? 'arrendador' : 'aprendiz';

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isCollapsed ? 80 : 280,
            color: const Color(0xFF0D9488),
            child: Column(
              children: [
                // Perfil de usuario
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment:
                        isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                    children: [
                      if (user.photoURL != null)
                        CircleAvatar(
                          radius: isCollapsed ? 24 : 20,
                          backgroundImage: NetworkImage(user.photoURL!),
                        )
                      else
                        CircleAvatar(
                          radius: isCollapsed ? 24 : 20,
                          backgroundColor: Colors.grey[200],
                          child: Icon(
                            Icons.person,
                            size: isCollapsed ? 24 : 20,
                            color: Colors.grey[500],
                          ),
                        ),
                      if (!isCollapsed) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.displayName ?? 'Usuario',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Row(
                                children: [
                                  Icon(
                                    userType == 'aprendiz'
                                        ? Icons.person
                                        : Icons.apartment,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    userType == 'aprendiz' ? 'Aprendiz' : 'Arrendador',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Menú de navegación
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Column(
                        children: [
                          _buildNavItem(icon: Icons.person, label: 'Perfil', section: 'perfil'),
                          _buildNavItem(icon: Icons.info, label: 'Información personal', section: 'informacion'),
                          if (userType == 'aprendiz') ...[
                            _buildNavItem(icon: Icons.favorite, label: 'Favoritos', section: 'favoritos'),
                            _buildNavItem(icon: Icons.calendar_today, label: 'Solicitudes citas', section: 'solicitudes_citas_aprendiz'),
                          ] else ...[
                            _buildNavItem(icon: Icons.calendar_today, label: 'Citas recibidas', section: 'solicitudes_citas_arrendador'),
                            _buildNavItem(icon: Icons.attach_money, label: 'Ofertas precio', section: 'ofertas'),
                          ],
                          _buildNavItem(icon: Icons.description, label: 'Reservas', section: 'solicitudes_reservas'),
                          _buildNavItem(icon: Icons.message, label: 'Mensajes', section: 'mensajes'),
                          if (userType == 'aprendiz')
                            _buildNavItem(icon: Icons.bar_chart, label: 'Reportes', section: 'reportes'),
                          if (userType == 'arrendador')
                            _buildNavItem(icon: Icons.apartment, label: 'Mis propiedades', section: 'propiedades'),
                          _buildNavItem(
                            icon: Icons.home,
                            label: 'Inicio',
                            section: 'inicio',
                            onTap: () => Navigator.pushReplacementNamed(context, '/home'),
                          ),
                          if (userType == 'aprendiz')
                            _buildNavItem(
                              icon: Icons.group,
                              label: 'Registrarse como Arrendador',
                              section: 'registro_arrendador',
                              onTap: () => setState(() => showLandlordModal = true),
                            ),
                          _buildNavItem(
                            icon: Icons.logout,
                            label: 'Cerrar sesión',
                            section: 'logout',
                            onTap: () => _handleLogout(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Contenido principal
          Expanded(
            child: Column(
              children: [
                Container(
                  color: const Color(0xFF0D9488),
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(isCollapsed ? Icons.chevron_right : Icons.chevron_left, color: Colors.white),
                        onPressed: () => setState(() => isCollapsed = !isCollapsed),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        userType == 'arrendador' ? 'Perfil Arrendador' : 'Perfil Aprendiz',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _renderContent(user), // Pasamos el usuario si se requiere
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: showLandlordModal
          ? FloatingActionButton(
              onPressed: () {
                setState(() => showLandlordModal = false);
                showDialog(
                  context: context,
                  builder: (_) => RegistrarArrendador(onClose: () => Navigator.pop(context)),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required String section, VoidCallback? onTap}) {
    final isActive = activeSection == section;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap ?? () => setState(() => activeSection = section),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: isActive ? const Color(0xFF0D9488).withOpacity(0.8) : Colors.transparent),
            child: Row(
              mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [Icon(icon, color: Colors.white, size: isCollapsed ? 24 : 18), if (!isCollapsed) ...[const SizedBox(width: 12), Text(label, style: const TextStyle(color: Colors.white))]],
            ),
          ),
        ),
      ),
    );
  }

  Widget _renderContent(user) {
    switch (activeSection) {
      case 'perfil':
        return PerfilComponent();
      case 'informacion':
        return InformacionPersonal();
/*       case 'favoritos':
        return FavoritosList(); */
      case 'solicitudes_citas_aprendiz':
        return SolicitudesCitasAprendiz();
      case 'solicitudes_citas_arrendador':
        return CitasArrendador();
/*       case 'solicitudes_reservas':
        return SolicitudesReservas(); */
      case 'ofertas':
        return OfertasPrecios();
/*       case 'mensajes':
        return Mensajes(); */
      case 'reportes':
        return const Center(child: Text('Enviar Reportes - En desarrollo'));
      case 'propiedades':
        return MisPropiedades(propiedades: user.propiedades); // Asegúrate de pasar la lista correcta
      case 'inicio':
        return const Center(child: Text('Inicio - En desarrollo'));
      default:
        return const Center(child: Text('Contenido no encontrado'));
    }
  }

  void _handleLogout(BuildContext context) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cerrar sesión: \$e')));
    }
  }
}
