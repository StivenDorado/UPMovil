// citas_arrendador.dart
import 'package:flutter/material.dart';

class CitasArrendador extends StatelessWidget {
  const CitasArrendador({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          color: const Color(0xFF2A8C82),
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.calendar_today, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'GESTIÓN DE SOLICITUDES',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 3,
            itemBuilder: (context, index) {
              return ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade200,
                ),
                title: const Text(
                  'Nombre Aprendiz',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14),
                        SizedBox(width: 4),
                        Text('Fecha de solicitud'),
                      ],
                    ),
                    Text('Día de la cita'),
                    Text('Hora cita: 4:00 PM'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check, size: 14),
                      label: const Text('Aceptar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A8C82),
                      ),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {},
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
