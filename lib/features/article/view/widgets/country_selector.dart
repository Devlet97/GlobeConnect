import 'package:flutter/material.dart';
import '../../model/country.dart';

class CountrySelector extends StatefulWidget {
  final Function(List<Country>) onCountriesSelected;
  final List<String> selectedCountries;

  const CountrySelector({
    super.key,
    required this.onCountriesSelected,
    required this.selectedCountries,
  });

  @override
  State<CountrySelector> createState() => _CountrySelectorState();
}

class _CountrySelectorState extends State<CountrySelector> {
  final TextEditingController _searchController = TextEditingController();
  late List<Country> _countries;
  List<Country> _filteredCountries = [];

  @override
  void initState() {
    super.initState();
    _initializeCountries();
    _searchController.addListener(_filterCountries);
  }

  void _initializeCountries() {
    final countryData = [
      {'name': 'Tüm ülkeler', 'flag': '🌍'},
      {'name': 'Avustralya', 'flag': '🇦🇺'},
      {'name': 'Avusturya', 'flag': '🇦🇹'},
      {'name': 'Azerbaycan', 'flag': '🇦🇿'},
      {'name': 'Arnavutluk', 'flag': '🇦🇱'},
      {'name': 'Cezayir', 'flag': '🇩🇿'},
      {'name': 'Andorra', 'flag': '🇦🇩'},
      {'name': 'Arjantin', 'flag': '🇦🇷'},
      {'name': 'Ermenistan', 'flag': '🇦🇲'},
      {'name': 'Afganistan', 'flag': '🇦🇫'},
      {'name': 'Bahamalar', 'flag': '🇧🇸'},
      {'name': 'Belarus', 'flag': '🇧🇾'},
      {'name': 'Belçika', 'flag': '🇧🇪'},
      {'name': 'Bulgaristan', 'flag': '🇧🇬'},
      {'name': 'Brezilya', 'flag': '🇧🇷'},
      {'name': 'Kanada', 'flag': '🇨🇦'},
      {'name': 'Çin', 'flag': '🇨🇳'},
      {'name': 'Hırvatistan', 'flag': '🇭🇷'},
      {'name': 'Kıbrıs', 'flag': '🇨🇾'},
      {'name': 'Çek Cumhuriyeti', 'flag': '🇨🇿'},
      {'name': 'Danimarka', 'flag': '🇩🇰'},
      {'name': 'Mısır', 'flag': '🇪🇬'},
      {'name': 'Estonya', 'flag': '🇪🇪'},
      {'name': 'Finlandiya', 'flag': '🇫🇮'},
      {'name': 'Fransa', 'flag': '🇫🇷'},
      {'name': 'Gürcistan', 'flag': '🇬🇪'},
      {'name': 'Almanya', 'flag': '🇩🇪'},
      {'name': 'Yunanistan', 'flag': '🇬🇷'},
      {'name': 'Macaristan', 'flag': '🇭🇺'},
      {'name': 'İzlanda', 'flag': '🇮🇸'},
      {'name': 'Hindistan', 'flag': '🇮🇳'},
      {'name': 'Endonezya', 'flag': '🇮🇩'},
      {'name': 'İran', 'flag': '🇮🇷'},
      {'name': 'Irak', 'flag': '🇮🇶'},
      {'name': 'İrlanda', 'flag': '🇮🇪'},
      {'name': 'İsrail', 'flag': '🇮🇱'},
      {'name': 'İtalya', 'flag': '🇮🇹'},
      {'name': 'Japonya', 'flag': '🇯🇵'},
      {'name': 'Ürdün', 'flag': '🇯🇴'},
      {'name': 'Kazakistan', 'flag': '🇰🇿'},
      {'name': 'Kenya', 'flag': '🇰🇪'},
      {'name': 'Kuzey Kore', 'flag': '🇰🇵'},
      {'name': 'Güney Kore', 'flag': '🇰🇷'},
      {'name': 'Kuveyt', 'flag': '🇰🇼'},
      {'name': 'Kırgızistan', 'flag': '🇰🇬'},
      {'name': 'Letonya', 'flag': '🇱🇻'},
      {'name': 'Lübnan', 'flag': '🇱🇧'},
      {'name': 'Libya', 'flag': '🇱🇾'},
      {'name': 'Lihtenştayn', 'flag': '🇱🇮'},
      {'name': 'Litvanya', 'flag': '🇱🇹'},
      {'name': 'Lüksemburg', 'flag': '🇱🇺'},
      {'name': 'Makedonya', 'flag': '🇲🇰'},
      {'name': 'Malezya', 'flag': '🇲🇾'},
      {'name': 'Malta', 'flag': '🇲🇹'},
      {'name': 'Meksika', 'flag': '🇲🇽'},
      {'name': 'Moldova', 'flag': '🇲🇩'},
      {'name': 'Monako', 'flag': '🇲🇨'},
      {'name': 'Moğolistan', 'flag': '🇲🇳'},
      {'name': 'Karadağ', 'flag': '🇲🇪'},
      {'name': 'Fas', 'flag': '🇲🇦'},
      {'name': 'Nepal', 'flag': '🇳🇵'},
      {'name': 'Hollanda', 'flag': '🇳🇱'},
      {'name': 'Yeni Zelanda', 'flag': '🇳🇿'},
      {'name': 'Nijerya', 'flag': '🇳🇬'},
      {'name': 'Norveç', 'flag': '🇳🇴'},
      {'name': 'Pakistan', 'flag': '🇵🇰'},
      {'name': 'Panama', 'flag': '🇵🇦'},
      {'name': 'Paraguay', 'flag': '🇵🇾'},
      {'name': 'Peru', 'flag': '🇵🇪'},
      {'name': 'Filipinler', 'flag': '🇵🇭'},
      {'name': 'Polonya', 'flag': '🇵🇱'},
      {'name': 'Portekiz', 'flag': '🇵🇹'},
      {'name': 'Katar', 'flag': '🇶🇦'},
      {'name': 'Romanya', 'flag': '🇷🇴'},
      {'name': 'Rusya', 'flag': '🇷🇺'},
      {'name': 'San Marino', 'flag': '🇸🇲'},
      {'name': 'Suudi Arabistan', 'flag': '🇸🇦'},
      {'name': 'Sırbistan', 'flag': '🇷🇸'},
      {'name': 'Singapur', 'flag': '🇸🇬'},
      {'name': 'Slovakya', 'flag': '🇸🇰'},
      {'name': 'Slovenya', 'flag': '🇸🇮'},
      {'name': 'Güney Afrika', 'flag': '🇿🇦'},
      {'name': 'İspanya', 'flag': '🇪🇸'},
      {'name': 'Sri Lanka', 'flag': '🇱🇰'},
      {'name': 'İsveç', 'flag': '🇸🇪'},
      {'name': 'İsviçre', 'flag': '🇨🇭'},
      {'name': 'Suriye', 'flag': '🇸🇾'},
      {'name': 'Tayvan', 'flag': '🇹🇼'},
      {'name': 'Tacikistan', 'flag': '🇹🇯'},
      {'name': 'Tayland', 'flag': '🇹🇭'},
      {'name': 'Türkiye', 'flag': '🇹🇷'},
      {'name': 'Türkmenistan', 'flag': '🇹🇲'},
      {'name': 'Ukrayna', 'flag': '🇺🇦'},
      {'name': 'Birleşik Arap Emirlikleri', 'flag': '🇦🇪'},
      {'name': 'Birleşik Krallık', 'flag': '🇬🇧'},
      {'name': 'Amerika Birleşik Devletleri', 'flag': '🇺🇸'},
      {'name': 'Uruguay', 'flag': '🇺🇾'},
      {'name': 'Özbekistan', 'flag': '🇺🇿'},
      {'name': 'Venezuela', 'flag': '🇻🇪'},
      {'name': 'Vietnam', 'flag': '🇻🇳'},
      {'name': 'Yemen', 'flag': '🇾🇪'},
      {'name': 'Zambiya', 'flag': '🇿🇲'},
      {'name': 'Zimbabve', 'flag': '🇿🇼'},
    ];

    _countries = countryData
        .map((data) => Country(
              name: data['name']!,
              flag: data['flag']!,
              isSelected: widget.selectedCountries.contains(data['name']),
            ))
        .toList();

    _filteredCountries = List.from(_countries);
  }

  void _filterCountries() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _filteredCountries = List.from(_countries);
      });
      return;
    }

    setState(() {
      _filteredCountries = _countries
          .where((country) => country.name
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Kapat çizgisi
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Başlık ve Kapat butonu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ülkeler',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Arama alanı
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Arama',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Tekli seçim başlığı
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Çoklu seçim',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Ülkeler listesi
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCountries.length,
              itemBuilder: (context, index) {
                final country = _filteredCountries[index];
                return ListTile(
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: country.isSelected
                                ? Colors.blue
                                : Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: country.isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.blue,
                                size: 16,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        country.flag,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  title: Text(
                    country.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      if (country.name == 'Tüm ülkeler') {
                        // Tüm ülkeler seçilirse diğer seçimleri kaldır
                        final allSelected = country.isSelected;
                        for (var c in _countries) {
                          c.isSelected = false;
                        }
                        country.isSelected = !allSelected;
                      } else {
                        // Başka bir ülke seçilirse "Tüm ülkeler" seçimini kaldır
                        _countries[0].isSelected = false;
                        country.isSelected = !country.isSelected;
                      }
                    });
                  },
                );
              },
            ),
          ),
          // Uygula butonu
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                final selectedCountries =
                    _countries.where((country) => country.isSelected).toList();
                widget.onCountriesSelected(selectedCountries);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Uygula',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
