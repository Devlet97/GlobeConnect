import 'package:flutter/material.dart';
import '../model/article_draft.dart';
import '../model/category.dart';
import '../service/article_draft_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'create_article_view.dart';
import 'widgets/country_flag.dart';

class DraftsView extends StatelessWidget {
  final ArticleDraftService _draftService = ArticleDraftService();
  final List<Category> _categories = [
    Category(name: 'Profilim', icon: Icons.person, isSelected: false),
    Category(name: 'AI', icon: Icons.smart_toy, isSelected: false),
    Category(name: 'Digital Nomad', icon: Icons.laptop, isSelected: false),
    Category(name: 'HoReCa', icon: Icons.restaurant, isSelected: false),
    Category(name: 'HR', icon: Icons.people, isSelected: false),
    Category(name: 'IT-sektörü', icon: Icons.computer, isSelected: false),
    Category(name: 'ReLife', icon: Icons.refresh, isSelected: false),
    Category(name: 'SEO', icon: Icons.search, isSelected: false),
    Category(name: 'SMM', icon: Icons.share, isSelected: false),
    Category(name: 'Havacılık', icon: Icons.flight, isSelected: false),
    Category(name: 'Otomobil', icon: Icons.directions_car, isSelected: false),
    Category(name: 'Otostop', icon: Icons.thumb_up, isSelected: false),
    Category(name: 'Emlak Kiralama', icon: Icons.house, isSelected: false),
    Category(name: 'Mimarlık', icon: Icons.architecture, isSelected: false),
    Category(name: 'Etkinlikler', icon: Icons.event, isSelected: false),
    Category(
        name: 'Barlar ve Kulüpler', icon: Icons.local_bar, isSelected: false),
    Category(name: 'Güvenlik', icon: Icons.security, isSelected: false),
    Category(name: 'İş', icon: Icons.work, isSelected: false),
    Category(
        name: 'Veganlık ve Vejetaryenlik', icon: Icons.eco, isSelected: false),
    Category(name: 'Vizeler', icon: Icons.card_membership, isSelected: false),
    Category(
        name: 'Yurtdışında Yaşam',
        icon: Icons.flight_takeoff,
        isSelected: false),
    Category(name: 'Rehber', icon: Icons.map, isSelected: false),
    Category(
        name: 'Gastronomi', icon: Icons.restaurant_menu, isSelected: false),
    Category(name: 'Şehirler', icon: Icons.location_city, isSelected: false),
    Category(name: 'Vatandaşlık', icon: Icons.how_to_reg, isSelected: false),
    Category(name: 'Tasarım', icon: Icons.design_services, isSelected: false),
    Category(name: 'Çocuklar için', icon: Icons.child_care, isSelected: false),
    Category(name: 'Belgeler', icon: Icons.description, isSelected: false),
    Category(name: 'Evcil Hayvanlar', icon: Icons.pets, isSelected: false),
    Category(
        name: 'Yemek ve Mutfak', icon: Icons.restaurant, isSelected: false),
    Category(name: 'Hayvanlar', icon: Icons.pets, isSelected: false),
    Category(name: 'Banliyö Yaşamı', icon: Icons.home, isSelected: false),
    Category(
        name: 'Sağlıklı Beslenme', icon: Icons.local_dining, isSelected: false),
    Category(name: 'Arkadaşlık', icon: Icons.people, isSelected: false),
    Category(name: 'Konut Yönetimi', icon: Icons.apartment, isSelected: false),
    Category(name: 'Oyunlar', icon: Icons.games, isSelected: false),
    Category(name: 'Yatırımlar', icon: Icons.trending_up, isSelected: false),
    Category(name: 'Yabancı Diller', icon: Icons.language, isSelected: false),
    Category(
        name: 'Instagram Mekanları',
        icon: Icons.photo_camera,
        isSelected: false),
    Category(name: 'İnteraktif', icon: Icons.touch_app, isSelected: false),
  ];

  DraftsView({super.key});

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Az önce';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} saat önce';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} gün önce';
    } else {
      return DateFormat('dd.MM.yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Taslaklar',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<List<ArticleDraft>>(
        stream: _draftService.getDrafts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('StreamBuilder hatası: ${snapshot.error}');
            return Center(
              child: Text(
                'Bir hata oluştu\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            );
          }

          final drafts = snapshot.data ?? [];
          print('Gelen taslak sayısı: ${drafts.length}');

          if (drafts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.description_outlined,
                    color: Colors.white.withOpacity(0.7),
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz taslak yok',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: drafts.length,
            itemBuilder: (context, index) {
              final draft = drafts[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C2C2C),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.article_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Makale',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                _formatTimeAgo(draft.createdAt),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          if (draft.countries.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: CountryFlag(
                                countryName: draft.countries.first,
                                size: 24,
                              ),
                            ),
                          PopupMenuButton<String>(
                            icon: Icon(
                              Icons.more_horiz,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            color: const Color(0xFF2C2C2C),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.edit_outlined,
                                      color: Colors.white.withOpacity(0.7),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Düzenle',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline,
                                      color: Colors.white.withOpacity(0.7),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Sil',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) async {
                              if (value == 'edit') {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreateArticleView(
                                      draft: draft,
                                    ),
                                  ),
                                );
                              } else if (value == 'delete') {
                                try {
                                  await _draftService.deleteDraft(draft.id!);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Taslak silindi'),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Taslak silinirken bir hata oluştu'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    if (draft.coverImageBase64 != null &&
                        draft.coverImageBase64!.isNotEmpty)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(0),
                              topRight: Radius.circular(0),
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                            child: Image.memory(
                              base64Decode(draft.coverImageBase64!),
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print('Resim yükleme hatası: $error');
                                return Container(
                                  height: 200,
                                  color: const Color(0xFF2C2C2C),
                                  child: Center(
                                    child: Icon(
                                      Icons.error_outline,
                                      color: Colors.white.withOpacity(0.7),
                                      size: 32,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          if (draft.categories.isNotEmpty)
                            Positioned(
                              top: 12,
                              left: 12,
                              child: Row(
                                children: draft.categories.map((category) {
                                  String shortName = category;
                                  if (category.contains(' ')) {
                                    shortName = category
                                        .split(' ')
                                        .map((word) => word[0])
                                        .join('');
                                  } else if (category.length > 3) {
                                    shortName =
                                        category.substring(0, 3).toUpperCase();
                                  } else {
                                    shortName = category.toUpperCase();
                                  }

                                  return Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      shortName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      ),
                    if (draft.title != null && draft.title!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          draft.title!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    if (draft.description != null &&
                        draft.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16)
                            .copyWith(bottom: 16),
                        child: Text(
                          draft.description!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
