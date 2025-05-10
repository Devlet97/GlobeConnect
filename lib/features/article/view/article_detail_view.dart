import 'package:flutter/material.dart';
import 'dart:convert';
import '../model/article_draft.dart';
import '../model/comment.dart';
import '../service/article_draft_service.dart';
import '../view/widgets/country_flag.dart';
import 'package:share_plus/share_plus.dart';
import '../view/create_article_view.dart';

class ArticleDetailView extends StatefulWidget {
  final ArticleDraft article;

  const ArticleDetailView({
    super.key,
    required this.article,
  });

  @override
  State<ArticleDetailView> createState() => _ArticleDetailViewState();
}

class _ArticleDetailViewState extends State<ArticleDetailView> {
  final _draftService = ArticleDraftService();
  final _commentController = TextEditingController();
  bool _isLiking = false;
  bool _isPostingComment = false;
  late bool _localIsLiked;
  late int _localLikesCount;
  String? _editingCommentId;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _localIsLiked = _draftService.isLikedByUser(widget.article);
    _localLikesCount = widget.article.likesCount;
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
    if (_isLiking || widget.article.id == null) return;

    setState(() {
      _isLiking = true;
      _localIsLiked = !_localIsLiked;
      _localLikesCount += _localIsLiked ? 1 : -1;
    });

    try {
      await _draftService.toggleLike(widget.article.id!);
    } catch (e) {
      // Hata durumunda local state'i geri al
      if (mounted) {
        setState(() {
          _localIsLiked = !_localIsLiked;
          _localLikesCount += _localIsLiked ? 1 : -1;
        });
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

  Future<void> _handleCommentLike(String commentId) async {
    try {
      await _draftService.toggleCommentLike(widget.article.id!, commentId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Yorum beğenme işlemi başarısız: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _postComment() async {
    if (_isPostingComment || _commentController.text.trim().isEmpty) return;

    setState(() {
      _isPostingComment = true;
    });

    try {
      if (_editingCommentId != null) {
        // Yorumu güncelle
        await _draftService.updateComment(
          widget.article.id!,
          _editingCommentId!,
          _commentController.text.trim(),
        );
        _editingCommentId = null;
      } else {
        // Yeni yorum ekle
        await _draftService.addComment(
          widget.article.id!,
          _commentController.text.trim(),
        );
      }
      _commentController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_editingCommentId != null
                ? 'Yorum güncelleme başarısız: $e'
                : 'Yorum gönderme başarısız: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPostingComment = false;
        });
      }
    }
  }

  // Yorum düzenleme işlemi
  void _startEditingComment(Comment comment) {
    setState(() {
      _editingCommentId = comment.id;
      _commentController.text = comment.content;
    });
    // Klavyeyi aç ve input alanına odaklan
    FocusScope.of(context).requestFocus(FocusNode());
  }

  // Düzenlemeyi iptal et
  void _cancelEditing() {
    setState(() {
      _editingCommentId = null;
      _commentController.clear();
    });
  }

  Widget _buildCommentCard(Comment comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Profil fotoğrafı
              if (comment.userPhotoUrl != null)
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(comment.userPhotoUrl!),
                )
              else
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFF2C2C2C),
                  child: Icon(
                    Icons.person,
                    color: Colors.white54,
                    size: 20,
                  ),
                ),
              const SizedBox(width: 8),
              // Kullanıcı adı
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _formatTimeAgo(comment.createdAt),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Üç nokta menü butonu
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.white.withOpacity(0.7),
                  size: 20,
                ),
                color: const Color(0xFF2C2C2C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                itemBuilder: (context) => [
                  if (comment.userId == _draftService.getCurrentUserId())
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit,
                            color: Colors.white.withOpacity(0.7),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Düzenle',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (comment.userId == _draftService.getCurrentUserId())
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete,
                            color: Colors.white.withOpacity(0.7),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Sil',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  PopupMenuItem<String>(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(
                          Icons.flag,
                          color: Colors.white.withOpacity(0.7),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Şikayet Et',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) async {
                  switch (value) {
                    case 'edit':
                      _startEditingComment(comment);
                      break;
                    case 'delete':
                      _showDeleteCommentDialog(comment);
                      break;
                    case 'report':
                      _showReportCommentDialog(comment);
                      break;
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Yorum içeriği
          Text(
            comment.content,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          // Beğeni butonu
          Row(
            children: [
              GestureDetector(
                onTap: () => _handleCommentLike(comment.id),
                child: Icon(
                  _draftService.isCommentLikedByUser(comment)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: _draftService.isCommentLikedByUser(comment)
                      ? Colors.red
                      : Colors.white.withOpacity(0.7),
                  size: 18,
                ),
              ),
              if (comment.likesCount > 0)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    comment.likesCount.toString(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Yorum silme dialog'u
  void _showDeleteCommentDialog(Comment comment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'Yorumu Sil',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Bu yorumu silmek istediğinizden emin misiniz?\nBu işlem geri alınamaz.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                Navigator.pop(context); // Dialog'u kapat

                await _draftService.deleteComment(
                  widget.article.id!,
                  comment.id,
                );

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Yorum başarıyla silindi'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Yorum silinirken bir hata oluştu: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Sil',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Yorum şikayet dialog'u
  void _showReportCommentDialog(Comment comment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Yorumu Şikayet Et',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Bu yorumu şikayet etmek istediğinizden emin misiniz?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              // TODO: Şikayet işlemi için gerekli servisi ekle
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Yorum şikayet edildi.'),
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Şikayet Et'),
          ),
        ],
      ),
    );
  }

  // Paylaşım fonksiyonu
  void _shareArticle() {
    final title = widget.article.title ?? '';
    final content = widget.article.content ?? '';

    final shareText = '''
$title

$content

Relife uygulamasından paylaşıldı.
''';

    Share.share(shareText);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isDeleting) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.article.title ?? '',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white.withOpacity(0.7),
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.share,
              color: Colors.white.withOpacity(0.7),
              size: 24,
            ),
            onPressed: _shareArticle,
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Colors.white.withOpacity(0.7),
              size: 24,
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: const Color(0xFF1E1E1E),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.translate,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      title: const Text(
                        'Çevir',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Çeviri işlemi
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.edit,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      title: const Text(
                        'Düzenle',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateArticleView(
                              editingArticle: widget.article,
                              draft: null,
                            ),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.delete,
                        color: Colors.red.withOpacity(0.7),
                      ),
                      title: const Text(
                        'Sil',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _showDeleteArticleDialog();
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Makale kartı
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Kapak fotoğrafı
                              if (widget.article.coverImageBase64 != null)
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  child: Image.memory(
                                    base64Decode(
                                        widget.article.coverImageBase64!),
                                    width: double.infinity,
                                    height: 250,
                                    fit: BoxFit.cover,
                                  ),
                                ),

                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Başlık
                                    if (widget.article.title != null)
                                      Text(
                                        widget.article.title!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    const SizedBox(height: 16),

                                    // Üst bilgi satırı
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          color: Colors.white.withOpacity(0.7),
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _formatTimeAgo(
                                              widget.article.createdAt),
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.7),
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        if (widget.article.countries.isNotEmpty)
                                          CountryFlag(
                                            countryName:
                                                widget.article.countries.first,
                                            size: 16,
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    // Kategoriler
                                    if (widget.article.categories.isNotEmpty)
                                      Wrap(
                                        spacing: 8,
                                        children: widget.article.categories
                                            .map((category) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF2C2C2C),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              category,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    const SizedBox(height: 24),

                                    // İçerik
                                    if (widget.article.content != null)
                                      Text(
                                        widget.article.content!,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 16,
                                          height: 1.6,
                                        ),
                                      ),
                                    const SizedBox(height: 24),

                                    // Beğeni butonu
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: _handleLike,
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            child: Icon(
                                              _localIsLiked
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: _localIsLiked
                                                  ? Colors.red
                                                  : Colors.white
                                                      .withOpacity(0.7),
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (_localLikesCount > 0)
                                          Text(
                                            _localLikesCount.toString(),
                                            style: TextStyle(
                                              color:
                                                  Colors.white.withOpacity(0.7),
                                              fontSize: 14,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),
                        // Yorumlar başlığı
                        const Text(
                          'Yorumlar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Yorum listesi
                        StreamBuilder<List<Comment>>(
                          stream: _draftService.getComments(widget.article.id!),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  'Yorumlar yüklenirken bir hata oluştu\n${snapshot.error}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              );
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.blue,
                                ),
                              );
                            }

                            final comments = snapshot.data ?? [];

                            if (comments.isEmpty) {
                              return Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.chat_bubble_outline,
                                      color: Colors.white.withOpacity(0.7),
                                      size: 48,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Henüz yorum yapılmamış',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return Column(
                              children:
                                  comments.map(_buildCommentCard).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Sabit yorum yazma alanı
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF121212),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_editingCommentId != null)
                      Container(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit,
                              color: Colors.blue,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Yorumu Düzenliyorsunuz',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                color: Colors.white.withOpacity(0.7),
                                size: 20,
                              ),
                              onPressed: _cancelEditing,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 36,
                                minHeight: 36,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2C),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                hintText: _editingCommentId != null
                                    ? 'Yorumu düzenleyin...'
                                    : 'Yorum yaz...',
                                hintStyle: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                isDense: true,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: _isPostingComment
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.blue,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(
                                    _editingCommentId != null
                                        ? Icons.check
                                        : Icons.send,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                            onPressed: _isPostingComment ? null : _postComment,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Makale silme dialog'u
  void _showDeleteArticleDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'Makaleyi Sil',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Bu makaleyi silmek istediğinizden emin misiniz?\nBu işlem geri alınamaz.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'İptal',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _deleteArticle(dialogContext),
            child: const Text(
              'Sil',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Makale silme işlemi
  Future<void> _deleteArticle(BuildContext dialogContext) async {
    try {
      // Onay dialog'unu kapat
      Navigator.pop(dialogContext);

      // Loading göster
      setState(() {
        _isDeleting = true;
      });

      // Silme işlemini gerçekleştir
      await _draftService.deleteArticle(widget.article.id!);

      if (!mounted) return;

      // Ana sayfaya dön
      Navigator.of(context).pop();

      // Başarı mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Makale başarıyla silindi'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Makale silme hatası: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Makale silinirken bir hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }
}
