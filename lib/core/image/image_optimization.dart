import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageOptimization {
  static const int maxWidthCache = 1024;
  static const int maxHeightCache = 1024;
  static const int maxWidthDisk = 1920;
  static const int maxHeightDisk = 1920;

  static CachedNetworkImageProvider cachedImage(String url) {
    return CachedNetworkImageProvider(
      url,
      maxWidthDiskCache: maxWidthDisk,
      maxHeightDiskCache: maxHeightDisk,
    );
  }

  static String optimizedUrl(String url, {int width = 1024, int quality = 80}) {
    if (url.isEmpty) return url;
    final separator = url.contains('?') ? '&' : '?';
    return '$url${separator}w=$width&q=$quality';
  }

  static String avatarUrl(String url, {int size = 256}) {
    return optimizedUrl(url, width: size, quality: 85);
  }

  static String postImageUrl(String url) {
    return optimizedUrl(url, width: maxWidthCache, quality: 75);
  }
}