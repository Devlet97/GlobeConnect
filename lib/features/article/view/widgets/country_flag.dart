import 'package:flutter/material.dart';

class CountryFlag extends StatelessWidget {
  final String countryName;
  final double size;

  const CountryFlag({
    super.key,
    required this.countryName,
    this.size = 24,
  });

  String getFlagEmoji() {
    // Ülke adından emoji bayrağı döndür
    switch (countryName.toLowerCase()) {
      case 'türkiye':
        return '🇹🇷';
      case 'almanya':
        return '🇩🇪';
      case 'rusya':
        return '🇷🇺';
      case 'amerika':
        return '🇺🇸';
      case 'ingiltere':
        return '🇬🇧';
      case 'fransa':
        return '🇫🇷';
      case 'italya':
        return '🇮🇹';
      case 'ispanya':
        return '🇪🇸';
      case 'hollanda':
        return '🇳🇱';
      case 'belçika':
        return '🇧🇪';
      case 'isviçre':
        return '🇨🇭';
      case 'avusturya':
        return '🇦🇹';
      case 'polonya':
        return '🇵🇱';
      case 'çekya':
        return '🇨🇿';
      case 'macaristan':
        return '🇭🇺';
      case 'yunanistan':
        return '🇬🇷';
      default:
        return '🌍'; // Varsayılan dünya ikonu
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF2C2C2C),
      ),
      child: Center(
        child: Text(
          getFlagEmoji(),
          style: TextStyle(
            fontSize: size * 0.6,
          ),
        ),
      ),
    );
  }
}
