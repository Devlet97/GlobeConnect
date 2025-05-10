import 'package:flutter/material.dart';
import 'widgets/country_selector.dart';
import '../model/country.dart';
import '../model/category.dart';
import '../model/article_draft.dart';
import 'widgets/category_selector.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'article_content_view.dart';
import '../service/article_draft_service.dart';
import 'drafts_view.dart';
import 'dart:convert';

class CreateArticleView extends StatefulWidget {
  final ArticleDraft? draft;
  final ArticleDraft? editingArticle;

  const CreateArticleView({
    super.key,
    this.draft,
    this.editingArticle,
  });

  @override
  State<CreateArticleView> createState() => _CreateArticleViewState();
}

class _CreateArticleViewState extends State<CreateArticleView> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();
  int _titleLength = 0;
  int _descriptionLength = 0;
  int _contentLength = 0;
  List<Country> _selectedCountries = [];
  List<String> selectedCategories = [];
  List<Category> _categories = [];
  File? _selectedImage;
  final _picker = ImagePicker();
  final _draftService = ArticleDraftService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeCategories();
    _loadData();
    _titleController.addListener(() {
      setState(() {
        _titleLength = _titleController.text.length;
      });
    });
    _descriptionController.addListener(() {
      setState(() {
        _descriptionLength = _descriptionController.text.length;
      });
    });
    _contentController.addListener(() {
      setState(() {
        _contentLength = _contentController.text.length;
      });
    });
  }

  Future<void> _loadData() async {
    // Önce tüm alanları temizle
    setState(() {
      _titleController.text = '';
      _descriptionController.text = '';
      _contentController.text = '';
      selectedCategories = [];
      _selectedCountries = [];
      _selectedImage = null;
    });

    // Düzenleme veya taslak verilerini yükle
    final articleToLoad = widget.editingArticle ?? widget.draft;
    if (articleToLoad != null) {
      setState(() {
        _titleController.text = articleToLoad.title ?? '';
        _descriptionController.text = articleToLoad.description ?? '';
        _contentController.text = articleToLoad.content ?? '';
        selectedCategories = List.from(articleToLoad.categories);
        _selectedCountries = articleToLoad.countries
            .map((name) => Country(name: name, flag: ''))
            .toList();
      });

      // Fotoğrafı yükle
      if (articleToLoad.coverImageBase64 != null &&
          articleToLoad.coverImageBase64!.isNotEmpty) {
        try {
          final bytes = base64Decode(articleToLoad.coverImageBase64!);
          final tempDir = Directory.systemTemp;
          final tempFile = File(
              '${tempDir.path}/temp_image_${DateTime.now().millisecondsSinceEpoch}.jpg');
          await tempFile.writeAsBytes(bytes);

          if (mounted) {
            setState(() {
              _selectedImage = tempFile;
            });
          }
        } catch (e) {
          print('Fotoğraf yüklenirken hata: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Fotoğraf yüklenirken bir hata oluştu: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
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
              isSelected: selectedCategories.contains(data['name']),
            ))
        .toList();
  }

  void _showCountrySelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CountrySelector(
        selectedCountries: _selectedCountries.map((c) => c.name).toList(),
        onCountriesSelected: (countries) {
          setState(() {
            _selectedCountries = countries;
          });
        },
      ),
    );
  }

  void _clearSelectedCountry() {
    setState(() {
      _selectedCountries = [];
    });
  }

  void _showCategorySelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CategorySelector(
        selectedCategories: selectedCategories,
        onCategoriesSelected: (List<Category> categories) {
          setState(() {
            selectedCategories = categories.map((c) => c.name).toList();
            // Seçilen kategorileri _categories listesinde güncelle
            for (var category in _categories) {
              category.isSelected = selectedCategories.contains(category.name);
            }
          });
        },
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      // Hata durumunda kullanıcıya bilgi ver
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fotoğraf seçilirken bir hata oluştu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveDraft() async {
    if (_isSaving) return;

    // Minimum içerik kontrolü
    if (_titleController.text.isEmpty &&
        _descriptionController.text.isEmpty &&
        _contentController.text.isEmpty &&
        _selectedImage == null &&
        selectedCategories.isEmpty &&
        _selectedCountries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen en az bir alan doldurun'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      print('Taslak kaydetme başlatılıyor...');
      final draftId = await _draftService.saveDraft(
        id: widget.editingArticle?.id, // Eğer düzenleme ise ID'yi gönder
        title: _titleController.text,
        description: _descriptionController.text,
        content: _contentController.text,
        coverImage: _selectedImage,
        categories: selectedCategories,
        countries: _selectedCountries.map((c) => c.name).toList(),
      );
      print('Taslak kaydedildi. ID: $draftId');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Taslak kaydedildi'),
            backgroundColor: Colors.green,
          ),
        );

        // Taslaklar sayfasına yönlendir
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DraftsView(),
          ),
        );
      }
    } catch (e) {
      print('Taslak kaydetme hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Taslak kaydedilirken bir hata oluştu: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          widget.editingArticle != null ? 'Makaleyi Düzenle' : 'Makale Oluştur',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            _buildLabel('Başlık', _titleLength, 80),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _titleController,
              hintText: 'Başlık girin',
              maxLength: 80,
            ),
            const SizedBox(height: 24),

            // Kısa Açıklama
            _buildLabel('Kısa Açıklama', _descriptionLength, 180),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _descriptionController,
              hintText: 'Kısa açıklama girin',
              maxLength: 180,
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Ülkeler
            _buildLabel('Ülkeler', null, null),
            const SizedBox(height: 8),
            InkWell(
              onTap: _showCountrySelector,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedCountries.isEmpty)
                      ListTile(
                        title: Text(
                          'Ülke seçin',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        trailing: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ..._selectedCountries.map((country) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2C2C2C),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      country.flag,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      country.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedCountries.remove(country);
                                        });
                                      },
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white.withOpacity(0.7),
                                        size: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            GestureDetector(
                              onTap: _showCountrySelector,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2C2C2C),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Kategoriler
            _buildLabel('Kategoriler', null, null),
            const SizedBox(height: 8),
            InkWell(
              onTap: _showCategorySelector,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (selectedCategories.isEmpty)
                      ListTile(
                        title: Text(
                          'Kategori seçin',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        trailing: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      )
                    else
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              ...selectedCategories.map((category) {
                                final categoryData = _categories
                                    .firstWhere((c) => c.name == category);
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2C2C2C),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          categoryData.icon,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          category,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedCategories
                                                  .remove(category);
                                            });
                                          },
                                          child: Icon(
                                            Icons.close,
                                            color:
                                                Colors.white.withOpacity(0.7),
                                            size: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                              GestureDetector(
                                onTap: _showCategorySelector,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2C2C2C),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // İçerik
            _buildLabel('İçerik', _contentLength, 20000),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                        image: _selectedImage != null
                            ? DecorationImage(
                                image: FileImage(_selectedImage!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _selectedImage == null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_outlined,
                                    color: Colors.white.withOpacity(0.7),
                                    size: 32,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Kapak',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ArticleContentView(
                            initialContent: _contentController.text,
                            onContentChanged: (content) {
                              setState(() {
                                _contentController.text = content;
                                _contentLength = content.length;
                              });
                            },
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              color: Colors.white.withOpacity(0.7),
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Makale İçeriği',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '$_contentLength / 20.000',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        ),
        child: Row(
          children: [
            // Düzenleme modunda taslak düğmesini gösterme
            if (widget.editingArticle == null)
              GestureDetector(
                onTap: _isSaving ? null : _saveDraft,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          Icons.description_outlined,
                          color: Colors.white.withOpacity(0.7),
                        ),
                ),
              ),
            if (widget.editingArticle == null) const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  if (_isSaving) return;

                  // Minimum içerik kontrolü
                  if (_titleController.text.isEmpty &&
                      _descriptionController.text.isEmpty &&
                      _contentController.text.isEmpty &&
                      _selectedImage == null &&
                      selectedCategories.isEmpty &&
                      _selectedCountries.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Lütfen en az bir alan doldurun'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  setState(() {
                    _isSaving = true;
                  });

                  try {
                    String? imageBase64;
                    if (_selectedImage != null) {
                      final bytes = await _selectedImage!.readAsBytes();
                      imageBase64 = base64Encode(bytes);
                    }

                    final article = ArticleDraft(
                      id: widget.editingArticle?.id ?? widget.draft?.id,
                      title: _titleController.text,
                      description: _descriptionController.text,
                      content: _contentController.text,
                      coverImageBase64: imageBase64,
                      categories: selectedCategories,
                      countries: _selectedCountries.map((c) => c.name).toList(),
                      createdAt:
                          widget.editingArticle?.createdAt ?? DateTime.now(),
                      userId: widget.editingArticle?.userId ??
                          _draftService.getCurrentUserId()!,
                      likesCount: widget.editingArticle?.likesCount ?? 0,
                      likedByUsers: widget.editingArticle?.likedByUsers ?? [],
                    );

                    if (widget.editingArticle != null) {
                      // Makaleyi güncelle
                      await _draftService.updateArticle(article);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Makale başarıyla güncellendi'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    } else {
                      // Yeni makale yayınla
                      await _draftService.publishDraft(article);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Makale başarıyla yayınlandı'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(widget.editingArticle != null
                              ? 'Makale güncellenirken bir hata oluştu: $e'
                              : 'Makale yayınlanırken bir hata oluştu: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isSaving = false;
                      });
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        widget.editingArticle != null ? 'Güncelle' : 'Yayınla',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label, int? length, int? maxLength) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
          ),
        ),
        if (length != null && maxLength != null)
          Text(
            '$length / $maxLength',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required int maxLength,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        maxLength: maxLength,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.3),
          ),
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}
