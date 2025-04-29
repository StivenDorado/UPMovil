import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageHelper {
  /// Singleton pattern implementation
  static final ImageHelper _instance = ImageHelper._internal();
  factory ImageHelper() => _instance;
  ImageHelper._internal();

  /// URL base para el servidor API
  final String apiBaseUrl = 'http://localhost:4000';

  /// Limpia la cache de imágenes CachedNetworkImage
  void clearCache() {
    CachedNetworkImage.evictFromCache('/');
  }

  /// Procesa y valida las URLs de imágenes
  /// 
  /// Acepta una URL y la sanitiza, manejando los casos donde:
  /// - La URL está vacía
  /// - La URL es relativa y necesita ser combinada con la base
  /// - La URL es absoluta pero podría ser inválida
  String sanitizeImageUrl(String url) {
    if (url.isEmpty) return '';
    
    try {
      // Verifica si la URL ya está formateada correctamente
      final uri = Uri.parse(url);
      
      // Si la URL ya tiene esquema http o https, la devolvemos
      if (uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https')) {
        return url;
      }
      
      // Si no tiene esquema, construimos la URL completa
      final path = url.startsWith('/') ? url : '/$url';
      return '$apiBaseUrl$path';
    } catch (e) {
      print('Error al procesar URL de imagen: $e');
      return '';
    }
  }

  /// Construye un widget para mostrar una imagen con manejo de errores
  /// 
  /// [imageUrl]: URL de la imagen a mostrar
  /// [height]: Altura del widget (opcional)
  /// [width]: Anchura del widget (opcional)
  /// [borderRadius]: Radio de borde para la imagen (opcional)
  Widget buildNetworkImage({
    required String imageUrl,
    double? height,
    double? width,
    BorderRadius? borderRadius,
    BoxFit fit = BoxFit.cover,
  }) {
    final sanitizedUrl = sanitizeImageUrl(imageUrl);
    
    final imageWidget = sanitizedUrl.isNotEmpty
      ? CachedNetworkImage(
          imageUrl: sanitizedUrl,
          height: height,
          width: width,
          fit: fit,
          fadeInDuration: const Duration(milliseconds: 300),
          placeholder: (context, url) => Container(
            height: height,
            width: width,
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: (context, url, error) {
            print('Error cargando imagen: $error');
            return _buildDefaultImage(height, width);
          },
          // Configuración para mejorar el rendimiento
          memCacheWidth: 400, // Limitar anchura máxima en cache
        )
      : _buildDefaultImage(height, width);
    
    // Aplicar borderRadius si se especifica
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: imageWidget,
      );
    }
    
    return imageWidget;
  }
  
  /// Construye un widget de imagen por defecto cuando no hay imagen disponible
  Widget _buildDefaultImage(double? height, double? width) {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home, size: 40, color: Colors.grey[600]),
          const SizedBox(height: 8),
          Text(
            'Sin imagen',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }
}