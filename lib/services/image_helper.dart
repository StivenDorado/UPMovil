import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageHelper {
  static final ImageHelper _instance = ImageHelper._internal();
  factory ImageHelper() => _instance;
  ImageHelper._internal();

  final String apiBaseUrl = 'http://localhost:4000';

  String sanitizeImageUrl(String url) {
    if (url.isEmpty) return '';
    try {
      final uri = Uri.parse(url);
      if (uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https')) {
        return url;
      }
      final path = url.startsWith('/') ? url : '/$url';
      return '$apiBaseUrl$path';
    } catch (e) {
      print('Error al procesar URL de imagen: $e');
      return '';
    }
  }

  Widget buildNetworkImage({
    required String imageUrl,
    double? height,
    double? width,
    BorderRadius? borderRadius,
    BoxFit fit = BoxFit.cover,
  }) {
    final sanitizedUrl = sanitizeImageUrl(imageUrl);
    debugPrint('🔍 Intentando cargar imagen en: $sanitizedUrl');

    Widget imageWidget;
    if (sanitizedUrl.isEmpty) {
      imageWidget = _buildDefaultImage(height, width);
    } else if (kIsWeb) {
      imageWidget = Image.network(
        sanitizedUrl,
        height: height,
        width: width,
        fit: fit,
        loadingBuilder: (ctx, child, prog) =>
            prog == null
                ? child
                : Container(
                    height: height,
                    width: width,
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
        errorBuilder: (ctx, err, st) {
          debugPrint('❌ Error cargando imagen Web: $err');
          return _buildDefaultImage(height, width);
        },
      );
    } else {
      imageWidget = CachedNetworkImage(
        imageUrl: sanitizedUrl,
        height: height,
        width: width,
        fit: fit,
        placeholder: (ctx, _) => Container(
          height: height,
          width: width,
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (ctx, _, err) {
          debugPrint('❌ Error cargando imagen Móvil: $err');
          return _buildDefaultImage(height, width);
        },
        memCacheWidth: 400,
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius, child: imageWidget);
    }
    return imageWidget;
  }

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
          Text('Sin imagen', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }
}
