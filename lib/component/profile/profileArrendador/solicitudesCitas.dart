// solicitudes_citas_aprendiz.dart
import 'package:flutter/material.dart';

class SolicitudesCitasAprendiz extends StatelessWidget {
  const SolicitudesCitasAprendiz({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          color: const Color(0xFF2A8C82),
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: const <Widget>[
                  Icon(Icons.calendar_today, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'MIS CITAS',
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
            itemBuilder: (context, index) => const AppointmentItem(),
          ),
        ),
      ],
    );
  }
}

class AppointmentItem extends StatelessWidget {
  const AppointmentItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey.shade200,
            child: const Icon(Icons.calendar_today, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Nombre Arrendador',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: const <Widget>[
                    Icon(Icons.calendar_today, size: 14),
                    SizedBox(width: 4),
                    Text('Fecha de solicitud'),
                  ],
                ),
                const Text('Día de la cita'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const <Widget>[
                      Icon(Icons.access_time, size: 14),
                      SizedBox(width: 4),
                      Text('Pendiente'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
