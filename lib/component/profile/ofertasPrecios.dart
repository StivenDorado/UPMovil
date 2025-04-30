// ofertas_precios.dart
import 'package:flutter/material.dart';

class OfertasPrecios extends StatelessWidget {
  const OfertasPrecios({super.key});

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
                  Icon(Icons.local_offer, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'OFERTAS RECIBIDAS',
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
            itemBuilder: (context, index) => const OfferItem(),
          ),
        ),
      ],
    );
  }
}

class OfferItem extends StatelessWidget {
  const OfferItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: const Color(0xFF91F2E9).withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF91F2E9).withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(Icons.attach_money, color: Color(0xFF275950)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Text(
                      'Producto',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF275950),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF41BFB3).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.access_time, size: 14),
                          SizedBox(width: 4),
                          Text('Pendiente'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Oferta: \$500.000',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                Text(
                  'Precio original: \$750.000',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF91F2E9).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('"Mensaje de la oferta"'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
