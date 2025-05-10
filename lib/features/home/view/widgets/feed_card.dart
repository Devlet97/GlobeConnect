import 'package:flutter/material.dart';
import '../../../article/model/article_draft.dart';
import '../../../article/view/widgets/country_flag.dart';
import '../../../article/service/article_draft_service.dart';
import '../../../article/view/article_detail_view.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedCard extends StatefulWidget {
  final ArticleDraft draft;

  const FeedCard({
    super.key,
    required this.draft,
  });

  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> {
  final _draftService = ArticleDraftService();
  final _firestore = FirebaseFirestore.instance;
  bool _isLiking = false;
  String? _authorName;
  String? _authorPhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadAuthorData();
  }

  Future<void> _loadAuthorData() async {
    try {
      final userDoc =
          await _firestore.collection('users').doc(widget.draft.userId).get();
      if (mounted && userDoc.exists) {
        setState(() {
          _authorName = userDoc.data()?['displayName'] ?? 'Anonim';
          _authorPhotoUrl = userDoc.data()?['photoURL'];
        });
      }
    } catch (e) {
      print('Yazar bilgileri yüklenirken hata: $e');
    }
  }

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
      return '${date.day}.${date.month}.${date.year}';
    }
  }

  Future<void> _handleLike() async {
    if (_isLiking || widget.draft.id == null) return;

    setState(() {
      _isLiking = true;
    });

    try {
      await _draftService.toggleLike(widget.draft.id!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Beğeni işlemi başarısız: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLiking = false;
        });
      }
    }
  }

  void _navigateToDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleDetailView(article: widget.draft),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLiked = _draftService.isLikedByUser(widget.draft);

    return GestureDetector(
      onTap: _navigateToDetail,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _authorPhotoUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _authorPhotoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 18,
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 18,
                          ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _authorName ?? 'Anonim',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _formatTimeAgo(widget.draft.createdAt),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (widget.draft.countries.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CountryFlag(
                        countryName: widget.draft.countries.first,
                        size: 20,
                      ),
                    ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_horiz,
                      color: Colors.white.withOpacity(0.7),
                      size: 20,
                    ),
                    color: const Color(0xFF2C2C2C),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'share',
                        child: Row(
                          children: [
                            Icon(
                              Icons.share_outlined,
                              color: Colors.white.withOpacity(0.7),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Paylaş',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      // TODO: Paylaşım işlemi
                    },
                  ),
                ],
              ),
            ),
            if (widget.draft.coverImageBase64 != null &&
                widget.draft.coverImageBase64!.isNotEmpty)
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    base64Decode(widget.draft.coverImageBase64!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('Resim yükleme hatası: $error');
                      return Container(
                        height: 180,
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
              ),
            if (widget.draft.title != null && widget.draft.title!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                child: Text(
                  widget.draft.title!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (widget.draft.description != null &&
                widget.draft.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: Text(
                  widget.draft.description!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _handleLike,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked
                            ? Colors.red
                            : Colors.white.withOpacity(0.7),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (widget.draft.likesCount > 0)
                    Text(
                      widget.draft.likesCount.toString(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
