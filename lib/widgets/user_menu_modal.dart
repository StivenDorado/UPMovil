// lib/widgets/user_menu_button.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/theme_service.dart';
import '../views/profile.dart';

class UserMenuButton extends StatefulWidget {
  const UserMenuButton({super.key});

  @override
  State<UserMenuButton> createState() => _UserMenuButtonState();
}

class _UserMenuButtonState extends State<UserMenuButton> {
  void _showUserMenu() {
    showDialog(
      context: context,
      builder: (_) => const UserMenuModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.account_circle, size: 28),
      onPressed: _showUserMenu,
      tooltip: 'Menú de usuario',
    );
  }
}

class UserMenuModal extends StatelessWidget {
  const UserMenuModal({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();
    final isDarkMode = themeService.isDarkMode;
    final screen = MediaQuery.of(context).size;

    return Dialog(
      insetPadding: EdgeInsets.only(
        top: 70,
        left: screen.width - 250,
        right: 20,
        bottom: screen.height - 280,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      child: Container(
        width: 230,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Cabecera
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(Icons.person, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Usuario Demo',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    SizedBox(height: 2),
                    Text('usuario@ejemplo.com',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ]),
          ),

          // Opciones
          MenuOption(
            icon: Icons.person_outline,
            title: 'Mi Perfil',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
          ),

          MenuOption(
            icon: Icons.notifications_outlined,
            title: 'Notificaciones',
            badge: 3,
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navegando a Notificaciones')),
              );
            },
          ),

          MenuOption(
            icon: Icons.settings_outlined,
            title: 'Configuración',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navegando a Configuración')),
              );
            },
          ),

          // Toggle tema
          MenuOption(
            icon: Icons.brightness_6,
            title: isDarkMode ? 'Modo Claro' : 'Modo Oscuro',
            onTap: () {
              Navigator.pop(context);
              themeService.toggleTheme();
            },
          ),

          const Divider(height: 1),

          MenuOption(
            icon: Icons.logout,
            title: 'Cerrar Sesión',
            textColor: Colors.red,
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Cerrar Sesión'),
                  content: const Text(
                      '¿Estás seguro que deseas cerrar sesión?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar')),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cerrando sesión...')),
                        );
                      },
                      child: const Text('Cerrar Sesión',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ]),
      ),
    );
  }
}

class MenuOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final int? badge;
  final Color? textColor;

  const MenuOption({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.badge,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Icon(icon, size: 20, color: textColor ?? Theme.of(context).iconTheme.color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: TextStyle(fontSize: 14, color: textColor)),
          ),
          if (badge != null)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                badge.toString(),
                style: const TextStyle(
                    color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
        ]),
      ),
    );
  }
}
