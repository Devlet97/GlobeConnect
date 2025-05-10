import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/article_draft.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import '../model/comment.dart';

class ArticleDraftService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> saveDraft({
    String? id,
    required String? title,
    required String? description,
    required String? content,
    required File? coverImage,
    required List<String> categories,
    required List<String> countries,
  }) async {
    try {
      print('Taslak kaydetme işlemi başladı');

      final user = _auth.currentUser;
      if (user == null) throw Exception('Kullanıcı oturum açmamış');
      print('Kullanıcı kontrolü yapıldı: ${user.uid}');

      String? base64Image;
      if (coverImage != null) {
        print('Kapak fotoğrafı işleniyor...');
        try {
          // Resmi yükle ve boyutunu küçült
          final bytes = await coverImage.readAsBytes();
          final image = img.decodeImage(bytes);
          if (image == null) throw Exception('Fotoğraf okunamadı');

          // Resmi maksimum 800x800 boyutuna küçült
          final resized = img.copyResize(
            image,
            width: 800,
            height: 800,
            maintainAspect: true,
          );

          // Base64'e çevir
          final jpegBytes = img.encodeJpg(resized, quality: 70);
          base64Image = base64Encode(jpegBytes);
          print('Kapak fotoğrafı Base64 formatına dönüştürüldü');
        } catch (e) {
          print('Kapak fotoğrafı işlenirken hata: $e');
          throw Exception('Kapak fotoğrafı işlenirken bir hata oluştu: $e');
        }
      }

      print('Taslak verisi hazırlanıyor...');
      final draft = ArticleDraft(
        title: title,
        description: description,
        content: content,
        coverImageBase64: base64Image,
        categories: categories,
        countries: countries,
        createdAt: DateTime.now(),
        userId: user.uid,
      );

      print('Firestore\'a taslak kaydediliyor...');
      String docId;
      if (id != null) {
        // Mevcut taslağı güncelle
        await _firestore
            .collection('article_drafts')
            .doc(id)
            .update(draft.toMap());
        docId = id;
        print('Taslak güncellendi. ID: $docId');
      } else {
        // Yeni taslak oluştur
        final docRef =
            await _firestore.collection('article_drafts').add(draft.toMap());
        docId = docRef.id;
        print('Yeni taslak oluşturuldu. ID: $docId');
      }

      return docId;
    } catch (e, stackTrace) {
      print('Taslak kaydedilirken hata oluştu: $e');
      print('Hata detayı: $stackTrace');
      throw Exception('Taslak kaydedilirken bir hata oluştu: $e');
    }
  }

  Future<String> publishDraft(ArticleDraft draft) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Kullanıcı oturum açmamış');

      // Yayınlanmış makaleler koleksiyonuna ekle
      final publishedRef =
          await _firestore.collection('published_articles').add({
        ...draft.toMap(),
        'publishedAt': DateTime.now(),
      });

      // Eğer taslak ise sil
      if (draft.id != null) {
        final draftDoc =
            await _firestore.collection('article_drafts').doc(draft.id).get();
        if (draftDoc.exists) {
          await _firestore.collection('article_drafts').doc(draft.id).delete();
        }
      }

      return publishedRef.id;
    } catch (e) {
      print('Makale yayınlanırken hata oluştu: $e');
      throw Exception('Makale yayınlanırken bir hata oluştu: $e');
    }
  }

  Stream<List<ArticleDraft>> getDrafts() {
    try {
      print('Taslakları getirme işlemi başladı');
      final user = _auth.currentUser;
      print('Mevcut kullanıcı: ${user?.uid}');

      if (user == null) {
        print('Kullanıcı oturum açmamış');
        throw Exception('Kullanıcı oturum açmamış');
      }

      return _firestore
          .collection('article_drafts')
          .where('userId', isEqualTo: user.uid)
          .snapshots()
          .map((snapshot) {
        print(
            'Firestore snapshot alındı. Döküman sayısı: ${snapshot.docs.length}');
        final drafts = snapshot.docs.map((doc) {
          print('Döküman verisi: ${doc.data()}');
          return ArticleDraft.fromMap(doc.data(), doc.id);
        }).toList();

        drafts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return drafts;
      });
    } catch (e, stackTrace) {
      print('Taslakları getirirken hata oluştu: $e');
      print('Hata detayı: $stackTrace');
      rethrow;
    }
  }

  Stream<List<ArticleDraft>> getPublishedArticles() {
    return _firestore
        .collection('published_articles')
        .orderBy('publishedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ArticleDraft.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> deleteDraft(String draftId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Kullanıcı oturum açmamış');

      await _firestore.collection('article_drafts').doc(draftId).delete();
    } catch (e) {
      throw Exception('Taslak silinirken bir hata oluştu: $e');
    }
  }

  Future<void> toggleLike(String articleId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Kullanıcı oturum açmamış');

      final articleRef =
          _firestore.collection('published_articles').doc(articleId);
      final article = await articleRef.get();

      if (!article.exists) throw Exception('Makale bulunamadı');

      final likedByUsers =
          List<String>.from(article.data()?['likedByUsers'] ?? []);
      final isLiked = likedByUsers.contains(user.uid);

      if (isLiked) {
        // Unlike
        await articleRef.update({
          'likesCount': FieldValue.increment(-1),
          'likedByUsers': FieldValue.arrayRemove([user.uid]),
        });
      } else {
        // Like
        await articleRef.update({
          'likesCount': FieldValue.increment(1),
          'likedByUsers': FieldValue.arrayUnion([user.uid]),
        });
      }
    } catch (e) {
      print('Beğeni işlemi sırasında hata: $e');
      throw Exception('Beğeni işlemi sırasında bir hata oluştu: $e');
    }
  }

  bool isLikedByUser(ArticleDraft article) {
    final user = _auth.currentUser;
    if (user == null) return false;
    return article.likedByUsers.contains(user.uid);
  }

  // Yorum ekler
  Future<void> addComment(String articleId, String content) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kullanıcı oturum açmamış');

    try {
      final commentRef = _firestore
          .collection('published_articles')
          .doc(articleId)
          .collection('comments')
          .doc();

      final comment = {
        'id': commentRef.id,
        'userId': user.uid,
        'userName': user.displayName ?? 'Anonim',
        'userPhotoUrl': user.photoURL,
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
        'likesCount': 0,
        'likedByUsers': [],
      };

      await commentRef.set(comment);
    } catch (e) {
      print('Yorum ekleme hatası: $e');
      throw Exception('Yorum eklenirken bir hata oluştu: $e');
    }
  }

  // Yorumları getirme
  Stream<List<Comment>> getComments(String articleId) {
    return _firestore
        .collection('published_articles')
        .doc(articleId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Comment.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Yorumu beğenme/beğenmeme
  Future<void> toggleCommentLike(String articleId, String commentId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Kullanıcı oturum açmamış');

      final commentRef = _firestore
          .collection('published_articles')
          .doc(articleId)
          .collection('comments')
          .doc(commentId);

      final comment = await commentRef.get();

      if (!comment.exists) throw Exception('Yorum bulunamadı');

      final likedByUsers =
          List<String>.from(comment.data()?['likedByUsers'] ?? []);
      final isLiked = likedByUsers.contains(user.uid);

      if (isLiked) {
        await commentRef.update({
          'likesCount': FieldValue.increment(-1),
          'likedByUsers': FieldValue.arrayRemove([user.uid]),
        });
      } else {
        await commentRef.update({
          'likesCount': FieldValue.increment(1),
          'likedByUsers': FieldValue.arrayUnion([user.uid]),
        });
      }
    } catch (e) {
      print('Yorum beğenme hatası: $e');
      throw Exception('Yorum beğenilirken bir hata oluştu: $e');
    }
  }

  bool isCommentLikedByUser(Comment comment) {
    final user = _auth.currentUser;
    if (user == null) return false;
    return comment.likedByUsers.contains(user.uid);
  }

  // Mevcut kullanıcının ID'sini döndürür
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // Yorumu günceller
  Future<void> updateComment(
      String articleId, String commentId, String newContent) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('Kullanıcı oturum açmamış');

    try {
      // Önce mevcut yorumu al
      final commentRef = _firestore
          .collection('published_articles')
          .doc(articleId)
          .collection('comments')
          .doc(commentId);

      final comment = await commentRef.get();

      if (!comment.exists) {
        throw Exception('Yorum bulunamadı');
      }

      // Mevcut yorum verilerini al ve sadece içerik ve güncelleme zamanını değiştir
      final currentData = comment.data() ?? {};
      final updatedData = {
        ...currentData,
        'content': newContent,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Tüm verileri güncelle
      await commentRef.set(updatedData);
    } catch (e) {
      print('Yorum güncelleme hatası: $e');
      throw Exception('Yorum güncellenirken bir hata oluştu: $e');
    }
  }

  // Yorumu siler
  Future<void> deleteComment(String articleId, String commentId) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('Kullanıcı oturum açmamış');

    try {
      print(
          'Yorum silme işlemi başlatıldı: articleId=$articleId, commentId=$commentId');

      // Önce yorumun var olduğunu ve kullanıcının sahibi olduğunu kontrol et
      final commentDoc = await _firestore
          .collection('published_articles')
          .doc(articleId)
          .collection('comments')
          .doc(commentId)
          .get();

      if (!commentDoc.exists) {
        throw Exception('Yorum bulunamadı');
      }

      final commentData = commentDoc.data();
      if (commentData?['userId'] != userId) {
        throw Exception('Bu yorumu silme yetkiniz yok');
      }

      // Yorumu sil
      await _firestore
          .collection('published_articles')
          .doc(articleId)
          .collection('comments')
          .doc(commentId)
          .delete();

      print('Yorum başarıyla silindi');
    } catch (e) {
      print('Yorum silme hatası: $e');
      throw Exception('Yorum silinirken bir hata oluştu: $e');
    }
  }

  // Makaleyi siler
  Future<void> deleteArticle(String articleId) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('Kullanıcı oturum açmamış');

    try {
      print('Makale silme işlemi başlatıldı: articleId=$articleId');

      // Önce makaleyi kontrol et
      final articleDoc = await _firestore
          .collection('published_articles')
          .doc(articleId)
          .get();

      if (!articleDoc.exists) {
        print('Makale bulunamadı: $articleId');
        throw Exception('Makale bulunamadı');
      }

      final articleData = articleDoc.data();
      if (articleData?['userId'] != userId) {
        print(
            'Silme yetkisi yok. Makale sahibi: ${articleData?['userId']}, İsteyen kullanıcı: $userId');
        throw Exception('Bu makaleyi silme yetkiniz yok');
      }

      print('Makale kontrolü tamamlandı, silme işlemi başlıyor');

      // Makaleyi doğrudan sil
      await _firestore.collection('published_articles').doc(articleId).delete();

      print('Makale başarıyla silindi');

      // Yorumları arka planda sil
      _deleteCommentsInBackground(articleId);
    } catch (e) {
      print('Makale silme hatası: $e');
      throw Exception('Makale silinirken bir hata oluştu: $e');
    }
  }

  // Yorumları arka planda sil
  Future<void> _deleteCommentsInBackground(String articleId) async {
    try {
      print('Yorumları silme işlemi başlatıldı');

      final commentsSnapshot = await _firestore
          .collection('published_articles')
          .doc(articleId)
          .collection('comments')
          .get();

      print('Silinecek yorum sayısı: ${commentsSnapshot.docs.length}');

      for (var doc in commentsSnapshot.docs) {
        await doc.reference.delete();
      }

      print('Tüm yorumlar başarıyla silindi');
    } catch (e) {
      print('Yorumları silme hatası: $e');
      // Yorumları silme hatası ana işlemi etkilemesin
    }
  }

  Future<void> updateArticle(ArticleDraft article) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Kullanıcı oturum açmamış');
      if (article.id == null) throw Exception('Makale ID\'si bulunamadı');

      // Makalenin mevcut olduğunu ve kullanıcının sahibi olduğunu kontrol et
      final articleRef =
          _firestore.collection('published_articles').doc(article.id);
      final articleDoc = await articleRef.get();

      if (!articleDoc.exists) throw Exception('Makale bulunamadı');
      if (articleDoc.data()?['userId'] != user.uid) {
        throw Exception('Bu makaleyi düzenleme yetkiniz yok');
      }

      // Mevcut makale verilerini al
      final currentData = articleDoc.data() ?? {};

      // Güncellenecek verileri hazırla
      final updateData = {
        'title': article.title,
        'description': article.description,
        'content': article.content,
        'coverImageBase64': article.coverImageBase64,
        'categories': article.categories,
        'countries': article.countries,
        'updatedAt': FieldValue.serverTimestamp(),
        'userId': user.uid,
        'createdAt': Timestamp.fromDate(article.createdAt),
        'likesCount': article.likesCount,
        'likedByUsers': article.likedByUsers,
      };

      // Null değerleri filtrele
      final cleanedData = Map<String, dynamic>.from(updateData)
        ..removeWhere((key, value) => value == null);

      // Makaleyi güncelle
      await articleRef.update(cleanedData);

      print('Makale başarıyla güncellendi: ${article.id}');
    } catch (e) {
      print('Makale güncellenirken hata: $e');
      throw Exception('Makale güncellenirken bir hata oluştu: $e');
    }
  }
}
