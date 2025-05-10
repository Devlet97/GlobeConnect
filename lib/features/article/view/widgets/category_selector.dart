import 'package:flutter/material.dart';
import '../../model/category.dart';

class CategorySelector extends StatefulWidget {
  final Function(List<Category>) onCategoriesSelected;
  final List<String> selectedCategories;

  const CategorySelector({
    super.key,
    required this.onCategoriesSelected,
    required this.selectedCategories,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  final TextEditingController _searchController = TextEditingController();
  late List<Category> _categories;
  List<Category> _filteredCategories = [];

  @override
  void initState() {
    super.initState();
    _initializeCategories();
    _searchController.addListener(_filterCategories);
  }

  void _initializeCategories() {
    final categoryData = [
      {'name': 'Profilim', 'icon': Icons.person},
      {'name': 'AI', 'icon': Icons.smart_toy},
      {'name': 'Digital Nomad', 'icon': Icons.laptop},
      {'name': 'HoReCa', 'icon': Icons.restaurant},
      {'name': 'HR', 'icon': Icons.people},
      {'name': 'IT-sektörü', 'icon': Icons.computer},
      {'name': 'ReLife', 'icon': Icons.refresh},
      {'name': 'SEO', 'icon': Icons.search},
      {'name': 'SMM', 'icon': Icons.share},
      {'name': 'Havacılık', 'icon': Icons.flight},
      {'name': 'Otomobil', 'icon': Icons.directions_car},
      {'name': 'Otostop', 'icon': Icons.thumb_up},
      {'name': 'Emlak Kiralama', 'icon': Icons.house},
      {'name': 'Mimarlık', 'icon': Icons.architecture},
      {'name': 'Etkinlikler', 'icon': Icons.event},
      {'name': 'Barlar ve Kulüpler', 'icon': Icons.local_bar},
      {'name': 'Güvenlik', 'icon': Icons.security},
      {'name': 'İş', 'icon': Icons.work},
      {'name': 'Veganlık ve Vejetaryenlik', 'icon': Icons.eco},
      {'name': 'Vizeler', 'icon': Icons.card_membership},
      {'name': 'Yurtdışında Yaşam', 'icon': Icons.flight_takeoff},
      {'name': 'Rehber', 'icon': Icons.map},
      {'name': 'Gastronomi', 'icon': Icons.restaurant_menu},
      {'name': 'Şehirler', 'icon': Icons.location_city},
      {'name': 'Vatandaşlık', 'icon': Icons.how_to_reg},
      {'name': 'Tasarım', 'icon': Icons.design_services},
      {'name': 'Çocuklar için', 'icon': Icons.child_care},
      {'name': 'Belgeler', 'icon': Icons.description},
      {'name': 'Evcil Hayvanlar', 'icon': Icons.pets},
      {'name': 'Yemek ve Mutfak', 'icon': Icons.restaurant},
      {'name': 'Hayvanlar', 'icon': Icons.pets},
      {'name': 'Banliyö Yaşamı', 'icon': Icons.home},
      {'name': 'Sağlıklı Beslenme', 'icon': Icons.local_dining},
      {'name': 'Arkadaşlık', 'icon': Icons.people},
      {'name': 'Konut Yönetimi', 'icon': Icons.apartment},
      {'name': 'Oyunlar', 'icon': Icons.games},
      {'name': 'Yatırımlar', 'icon': Icons.trending_up},
      {'name': 'Yabancı Diller', 'icon': Icons.language},
      {'name': 'Instagram Mekanları', 'icon': Icons.photo_camera},
      {'name': 'İnteraktif', 'icon': Icons.touch_app},
      {'name': 'İç Mekan ve İnşaat', 'icon': Icons.home_work},
      {'name': 'İş Dünyası', 'icon': Icons.business},
      {'name': 'Sanat', 'icon': Icons.palette},
      {'name': 'Tarih', 'icon': Icons.history},
      {'name': 'Yoga', 'icon': Icons.self_improvement},
      {'name': 'Kariyer', 'icon': Icons.work},
      {'name': 'Kafe ve Restoranlar', 'icon': Icons.restaurant},
      {'name': 'E-Spor', 'icon': Icons.sports_esports},
      {'name': 'Bilgisayar Oyunları', 'icon': Icons.gamepad},
      {'name': 'Uzay', 'icon': Icons.rocket_launch},
      {'name': 'Güzellik', 'icon': Icons.face},
      {'name': 'Minimalizm', 'icon': Icons.minimize},
      {'name': 'Kripto ve Blockchain', 'icon': Icons.currency_bitcoin},
      {'name': 'Kültür', 'icon': Icons.theater_comedy},
      {'name': 'Kültürel Etkinlikler', 'icon': Icons.festival},
      {'name': 'Yaşam Tüyoları', 'icon': Icons.lightbulb},
      {'name': 'LGBT', 'icon': Icons.diversity_3},
      {'name': 'Edebiyat', 'icon': Icons.book},
      {'name': 'Kişisel Deneyim', 'icon': Icons.person_outline},
      {'name': 'Pazarlama', 'icon': Icons.campaign},
      {'name': 'Medya', 'icon': Icons.play_circle},
      {'name': 'Tıp', 'icon': Icons.local_hospital},
      {'name': 'Mekanlar', 'icon': Icons.place},
      {'name': 'Moda', 'icon': Icons.shopping_bag},
      {'name': 'Yüzme', 'icon': Icons.pool},
      {'name': 'Müzik', 'icon': Icons.music_note},
      {'name': 'Vergiler', 'icon': Icons.receipt_long},
      {'name': 'Bilim', 'icon': Icons.science},
      {'name': 'Emlak', 'icon': Icons.apartment},
      {'name': 'Haberler', 'icon': Icons.newspaper},
      {'name': 'Eğitim', 'icon': Icons.school},
      {'name': 'Eğitim Kursları', 'icon': Icons.class_},
      {'name': 'Sosyal Aktiviteler', 'icon': Icons.groups},
      {'name': 'İlanlar', 'icon': Icons.campaign},
      {'name': 'Dinlenme', 'icon': Icons.weekend},
      {'name': 'İlişkiler', 'icon': Icons.favorite},
      {'name': 'Avcılık', 'icon': Icons.gps_fixed},
      {'name': 'Emeklilik', 'icon': Icons.elderly},
      {'name': 'Taşınma', 'icon': Icons.moving},
      {'name': 'Yurtdışında İkamet', 'icon': Icons.home_work},
      {'name': 'Emlak Alımı', 'icon': Icons.real_estate_agent},
      {'name': 'Faydalı İletişim', 'icon': Icons.contact_phone},
      {'name': 'Faydalı Linkler', 'icon': Icons.link},
      {'name': 'Politika', 'icon': Icons.policy},
      {'name': 'Yardım', 'icon': Icons.help},
      {'name': 'Giriş Kuralları', 'icon': Icons.rule},
      {'name': 'Doğa', 'icon': Icons.nature},
      {'name': 'Üretim', 'icon': Icons.precision_manufacturing},
      {'name': 'Psikoloji', 'icon': Icons.psychology},
      {'name': 'Seyahat', 'icon': Icons.travel_explore},
      {'name': 'Eğlence', 'icon': Icons.celebration},
      {'name': 'Ebeveynlik', 'icon': Icons.family_restroom},
      {'name': 'Balıkçılık', 'icon': Icons.set_meal},
      {'name': 'Kişisel Gelişim', 'icon': Icons.trending_up},
      {'name': 'İletişim ve İnternet', 'icon': Icons.wifi},
      {'name': 'Aile', 'icon': Icons.family_restroom},
      {'name': 'Hizmetler', 'icon': Icons.miscellaneous_services},
      {'name': 'Diziler', 'icon': Icons.tv},
      {'name': 'Öneriler', 'icon': Icons.recommend},
      {'name': 'Ortak İlgi Alanları', 'icon': Icons.interests},
      {'name': 'Spor', 'icon': Icons.sports},
      {'name': 'Girişimler', 'icon': Icons.rocket_launch},
      {'name': 'Sigorta', 'icon': Icons.health_and_safety},
      {'name': 'Teknoloji', 'icon': Icons.devices},
      {'name': 'Ticaret', 'icon': Icons.shopping_cart},
      {'name': 'Ulaşım', 'icon': Icons.directions_bus},
      {'name': 'Transfer', 'icon': Icons.swap_horiz},
      {'name': 'Turizm', 'icon': Icons.tour},
      {'name': 'Fotoğrafçılık', 'icon': Icons.camera_alt},
      {'name': 'Geri Bildirim', 'icon': Icons.feedback},
      {'name': 'Filmler', 'icon': Icons.movie},
      {'name': 'Mali Giderler', 'icon': Icons.account_balance_wallet},
      {'name': 'Finans', 'icon': Icons.attach_money},
      {'name': 'Fotoğraf', 'icon': Icons.photo},
      {'name': 'Hobiler', 'icon': Icons.interests},
      {'name': 'Gezilecek Yerler', 'icon': Icons.place},
      {'name': 'Alışveriş', 'icon': Icons.shopping_cart},
      {'name': 'Şov Dünyası', 'icon': Icons.theater_comedy},
      {'name': 'Ekoloji', 'icon': Icons.eco},
      {'name': 'Ekonomi', 'icon': Icons.trending_up},
      {'name': 'Turlar', 'icon': Icons.tour},
      {'name': 'Keşif Gezileri', 'icon': Icons.explore},
      {'name': 'Ekstrem Sporlar', 'icon': Icons.skateboarding},
      {'name': 'Göç', 'icon': Icons.flight_land},
      {'name': 'Mizah', 'icon': Icons.mood},
      {'name': 'Hukuk', 'icon': Icons.gavel},
    ];

    _categories = categoryData
        .map((data) => Category(
              name: data['name'] as String,
              icon: data['icon'] as IconData,
              isSelected: widget.selectedCategories.contains(data['name']),
            ))
        .toList();

    _filteredCategories = List.from(_categories);
  }

  void _filterCategories() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _filteredCategories = List.from(_categories);
      });
      return;
    }

    setState(() {
      _filteredCategories = _categories
          .where((category) => category.name
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
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Kategoriler',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
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
          // Kategoriler listesi
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCategories.length,
              itemBuilder: (context, index) {
                final category = _filteredCategories[index];
                return ListTile(
                  leading: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: category.isSelected
                            ? Colors.blue
                            : Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: category.isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.blue,
                            size: 16,
                          )
                        : null,
                  ),
                  title: Text(
                    category.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      if (category.name == 'Profilim') {
                        // Eğer Profilim seçilirse, diğer tüm seçimleri kaldır
                        for (var c in _categories) {
                          if (c.name != 'Profilim') {
                            c.isSelected = false;
                          }
                        }
                        category.isSelected = !category.isSelected;
                      } else {
                        // Eğer başka bir kategori seçilirse, Profilim seçimini kaldır
                        final profileCategory =
                            _categories.firstWhere((c) => c.name == 'Profilim');
                        if (profileCategory.isSelected) {
                          profileCategory.isSelected = false;
                        }
                        category.isSelected = !category.isSelected;
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
                final selectedCategories = _categories
                    .where((category) => category.isSelected)
                    .toList();
                widget.onCategoriesSelected(selectedCategories);
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
