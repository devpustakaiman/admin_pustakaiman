import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SupabaseRemoteDataSource {
  // Books CRUD & Trash
  Future<List<Map<String, dynamic>>> getBooks({int page = 0, int pageSize = 15});
  Future<Map<String, dynamic>?> getBookById(String id);
  Future<int> getBooksCount();
  Future<int> getActivePromosCount();
  Future<List<Map<String, dynamic>>> getDeletedBooks();
  Future<void> addBook(Map<String, dynamic> bookMap);
  Future<void> updateBook(Map<String, dynamic> bookMap);
  Future<void> deleteBook(String id);
  Future<void> restoreBooks(List<String> ids);
  Future<void> permanentlyDeleteBooks(List<String> ids);

  // Authors CRUD & Trash
  Future<List<Map<String, dynamic>>> getAuthors({int page = 0, int pageSize = 15});
  Future<Map<String, dynamic>?> getAuthorById(String id);
  Future<int> getAuthorsCount();
  Future<List<Map<String, dynamic>>> getDeletedAuthors();
  Future<void> insertAuthor(Map<String, dynamic> authorMap);
  Future<void> updateAuthor(Map<String, dynamic> authorMap);
  Future<void> deleteAuthor(String id);
  Future<void> restoreAuthors(List<String> ids);
  Future<void> permanentlyDeleteAuthors(List<String> ids);

  // Articles CRUD & Trash
  Future<List<Map<String, dynamic>>> getArticles({int page = 0, int pageSize = 15});
  Future<Map<String, dynamic>?> getArticleById(String id);
  Future<int> getArticlesCount();
  Future<List<Map<String, dynamic>>> getDeletedArticles();
  Future<void> insertArticle(Map<String, dynamic> articleMap);
  Future<void> updateArticle(Map<String, dynamic> articleMap);
  Future<void> deleteArticle(String id);
  Future<void> restoreArticles(List<String> ids);
  Future<void> permanentlyDeleteArticles(List<String> ids);

  // Submissions CRUD & Trash
  Future<List<Map<String, dynamic>>> getSubmissions({int page = 0, int pageSize = 15, String? status});
  Future<Map<String, dynamic>?> getSubmissionById(String id);
  Future<int> getSubmissionsCount({String? status});
  Future<int> getPendingSubmissionsCount();
  Future<List<Map<String, dynamic>>> getRecentUnreviewedSubmissions({int limit = 5});
  Future<List<Map<String, dynamic>>> getDeletedSubmissions();
  Future<void> updateSubmissionStatus(String id, String status);
  Future<void> deleteSubmission(String id);
  Future<void> restoreSubmissions(List<String> ids);
  Future<void> permanentlyDeleteSubmissions(List<String> ids);

  // Dashboard Aggregates
  Future<Map<String, dynamic>> getDashboardMetrics();

  // Web Settings (Landing Page CMS) & Pre-Order Settings
  Future<List<Map<String, dynamic>>> getBooksForDropdown();
  Future<Map<String, dynamic>?> getSiteSettings();
  Future<void> updateSiteSettings(Map<String, dynamic> settings);
  Future<String> getPreorderNotificationEmail();
  Future<void> updatePreorderNotificationEmail(String email);
  Future<List<Map<String, dynamic>>> getBankAccounts();
  Future<void> updateBankAccounts(List<Map<String, dynamic>> bankAccounts);
  Future<List<Map<String, dynamic>>> getPreorders();
  Future<List<Map<String, dynamic>>> getDeletedPreorders();
  Future<void> updatePreorderStatus(String id, String status);
  Future<void> deletePreorder(String id);
  Future<void> restorePreorders(List<String> ids);
  Future<void> permanentlyDeletePreorders(List<String> ids);
  Future<String> uploadSiteBanner(Uint8List bytes, String fileName, {String? contentType});

  // Media Videos CRUD & Trash
  Future<List<Map<String, dynamic>>> getMediaVideos({int page = 0, int pageSize = 30});
  Future<Map<String, dynamic>?> getMediaVideoById(String id);
  Future<int> getMediaVideosCount();
  Future<List<Map<String, dynamic>>> getDeletedMediaVideos();
  Future<void> addMediaVideo(Map<String, dynamic> videoMap);
  Future<void> updateMediaVideo(Map<String, dynamic> videoMap);
  Future<void> deleteMediaVideo(String id);
  Future<void> setFeaturedMediaVideo(String id);
  Future<void> restoreMediaVideos(List<String> ids);
  Future<void> permanentlyDeleteMediaVideos(List<String> ids);

  // Storage Upload Helper
  Future<String> uploadStorageFile({
    required String bucket,
    required String path,
    required Uint8List bytes,
    String? contentType,
  });
}

class SupabaseRemoteDataSourceImpl implements SupabaseRemoteDataSource {
  final SupabaseClient supabaseClient;

  SupabaseRemoteDataSourceImpl({SupabaseClient? client})
      : supabaseClient = client ?? Supabase.instance.client;

  String? extractStoragePath(String? url, String bucket) {
    if (url == null || url.trim().isEmpty) return null;
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      final bucketIndex = pathSegments.indexOf(bucket);
      if (bucketIndex != -1 && bucketIndex + 1 < pathSegments.length) {
        return Uri.decodeComponent(pathSegments.sublist(bucketIndex + 1).join('/'));
      }
    } catch (_) {}
    return null;
  }

  Future<void> _deleteStorageFile(String bucket, String? url) async {
    final path = extractStoragePath(url, bucket);
    if (path != null && path.isNotEmpty) {
      try {
        await supabaseClient.storage.from(bucket).remove([path]);
      } catch (_) {}
    }
  }

  // ---------------- BOOK METHODS ----------------
  @override
  Future<List<Map<String, dynamic>>> getBooks({int page = 0, int pageSize = 15}) async {
    final from = page * pageSize;
    final to = from + pageSize - 1;
    try {
      // Lightweight fetch: include cover_url and coverUrl gracefully
      final response = await supabaseClient
          .from('books')
          .select('id, title, author, category, price, is_promo, promo_price, promo_percentage, promo_end_date, is_recommended, cover_url, created_at, updated_at')
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false)
          .range(from, to);
      return List<Map<String, dynamic>>.from(response);
    } catch (_) {
      try {
        final response = await supabaseClient
            .from('books')
            .select('id, title, author, category, price, is_promo, promo_price, is_recommended, cover_url, created_at')
            .isFilter('deleted_at', null)
            .range(from, to);
        return List<Map<String, dynamic>>.from(response);
      } catch (_) {
        // Fallback
        final response = await supabaseClient
            .from('books')
            .select()
            .isFilter('deleted_at', null)
            .limit(pageSize);
        return List<Map<String, dynamic>>.from(response);
      }
    }
  }

  @override
  Future<Map<String, dynamic>?> getBookById(String id) async {
    try {
      final response = await supabaseClient
          .from('books')
          .select()
          .eq('id', id)
          .maybeSingle();
      return response;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> getBooksCount() async {
    try {
      final count = await supabaseClient
          .from('books')
          .count(CountOption.exact)
          .isFilter('deleted_at', null);
      return count;
    } catch (_) {
      try {
        final res = await supabaseClient
            .from('books')
            .select('id')
            .isFilter('deleted_at', null);
        return res.length;
      } catch (_) {
        return 0;
      }
    }
  }

  @override
  Future<int> getActivePromosCount() async {
    try {
      final count = await supabaseClient
          .from('books')
          .count(CountOption.exact)
          .isFilter('deleted_at', null)
          .eq('is_promo', true);
      return count;
    } catch (_) {
      try {
        final res = await supabaseClient
            .from('books')
            .select('id')
            .isFilter('deleted_at', null)
            .eq('is_promo', true);
        return res.length;
      } catch (_) {
        return 0;
      }
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getDeletedBooks() async {
    try {
      final response = await supabaseClient
          .from('books')
          .select()
          .not('deleted_at', 'is', null)
          .order('deleted_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (_) {
      final response = await supabaseClient
          .from('books')
          .select()
          .not('deleted_at', 'is', null);
      return List<Map<String, dynamic>>.from(response);
    }
  }

  Future<void> _safeSaveBookPayload({
    required Map<String, dynamic> initialMap,
    required Future<void> Function(Map<String, dynamic> payload) saveAction,
  }) async {
    final payload = Map<String, dynamic>.from(initialMap);

    final cover = payload['cover_url'] ?? payload['coverUrl'] ?? '';
    final pdf = payload['pdf_preview_url'] ?? payload['pdfPreviewUrl'] ?? '';
    final mizan = payload['mizanstore_url'] ?? payload['mizanstoreUrl'] ?? '';
    final gallery = payload['gallery_urls'] ?? payload['gallery_images'] ?? payload['galleryUrls'] ?? [];

    if (cover.toString().isNotEmpty) {
      payload['cover_url'] = cover;
      payload['coverUrl'] = cover;
    }
    if (pdf.toString().isNotEmpty) {
      payload['pdf_preview_url'] = pdf;
      payload['pdfPreviewUrl'] = pdf;
    }
    if (mizan.toString().isNotEmpty) {
      payload['mizanstore_url'] = mizan;
      payload['mizanstoreUrl'] = mizan;
    }
    payload['gallery_urls'] = gallery;
    payload['gallery_images'] = gallery;
    payload['galleryUrls'] = gallery;

    for (int attempt = 0; attempt < 10; attempt++) {
      try {
        await saveAction(payload);
        return;
      } catch (e) {
        final errStr = e.toString();
        final match = RegExp(r"Could not find the '([^']+)' column").firstMatch(errStr);
        if (match != null && match.groupCount >= 1) {
          final missingCol = match.group(1)!;
          if (payload.containsKey(missingCol)) {
            payload.remove(missingCol);
            continue;
          }
        }
        rethrow;
      }
    }
  }

  @override
  Future<void> addBook(Map<String, dynamic> bookMap) async {
    final mapToSave = Map<String, dynamic>.from(bookMap);
    mapToSave['created_at'] = DateTime.now().toIso8601String();
    mapToSave['updated_at'] = DateTime.now().toIso8601String();

    await _safeSaveBookPayload(
      initialMap: mapToSave,
      saveAction: (payload) async {
        await supabaseClient.from('books').insert(payload);
      },
    );
  }

  @override
  Future<void> updateBook(Map<String, dynamic> bookMap) async {
    final mapToSave = Map<String, dynamic>.from(bookMap);
    mapToSave['updated_at'] = DateTime.now().toIso8601String();
    final id = mapToSave['id'];

    await _safeSaveBookPayload(
      initialMap: mapToSave,
      saveAction: (payload) async {
        await supabaseClient.from('books').update(payload).eq('id', id);
      },
    );
  }

  @override
  Future<void> deleteBook(String id) async {
    try {
      await supabaseClient
          .from('books')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', id);
    } catch (_) {
      try {
        final book = await supabaseClient.from('books').select().eq('id', id).maybeSingle();
        if (book != null) {
          final coverUrl = book['coverUrl'] ?? book['cover_url'];
          final pdfUrl = book['pdfPreviewUrl'] ?? book['pdf_preview_url'];
          await _deleteStorageFile('pustaka-assets', coverUrl?.toString());
          await _deleteStorageFile('naskah', pdfUrl?.toString());
        }
      } catch (_) {}
      await supabaseClient.from('books').delete().eq('id', id);
    }
  }

  @override
  Future<void> restoreBooks(List<String> ids) async {
    if (ids.isEmpty) return;
    await supabaseClient
        .from('books')
        .update({'deleted_at': null})
        .inFilter('id', ids);
  }

  @override
  Future<void> permanentlyDeleteBooks(List<String> ids) async {
    if (ids.isEmpty) return;
    for (final id in ids) {
      try {
        final book = await supabaseClient.from('books').select().eq('id', id).maybeSingle();
        if (book != null) {
          final coverUrl = book['coverUrl'] ?? book['cover_url'];
          final pdfUrl = book['pdfPreviewUrl'] ?? book['pdf_preview_url'];
          await _deleteStorageFile('pustaka-assets', coverUrl?.toString());
          await _deleteStorageFile('naskah', pdfUrl?.toString());
        }
      } catch (_) {}
    }
    await supabaseClient.from('books').delete().inFilter('id', ids);
  }

  // ---------------- AUTHOR METHODS ----------------
  @override
  Future<List<Map<String, dynamic>>> getAuthors({int page = 0, int pageSize = 15}) async {
    final from = page * pageSize;
    final to = from + pageSize - 1;
    try {
      // Lightweight fetch: omit heavy bio column on list cards
      final response = await supabaseClient
          .from('authors')
          .select('id, name, photo_url, photoUrl, created_at')
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false)
          .range(from, to);
      return List<Map<String, dynamic>>.from(response);
    } catch (_) {
      try {
        final response = await supabaseClient
            .from('authors')
            .select('id, name, created_at')
            .isFilter('deleted_at', null)
            .range(from, to);
        return List<Map<String, dynamic>>.from(response);
      } catch (_) {
        final response = await supabaseClient
            .from('authors')
            .select()
            .isFilter('deleted_at', null)
            .limit(pageSize);
        return List<Map<String, dynamic>>.from(response);
      }
    }
  }

  @override
  Future<Map<String, dynamic>?> getAuthorById(String id) async {
    try {
      final response = await supabaseClient
          .from('authors')
          .select()
          .eq('id', id)
          .maybeSingle();
      return response;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> getAuthorsCount() async {
    try {
      final count = await supabaseClient
          .from('authors')
          .count(CountOption.exact)
          .isFilter('deleted_at', null);
      return count;
    } catch (_) {
      try {
        final res = await supabaseClient
            .from('authors')
            .select('id')
            .isFilter('deleted_at', null);
        return res.length;
      } catch (_) {
        return 0;
      }
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getDeletedAuthors() async {
    try {
      final response = await supabaseClient
          .from('authors')
          .select()
          .not('deleted_at', 'is', null)
          .order('deleted_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (_) {
      final response = await supabaseClient
          .from('authors')
          .select()
          .not('deleted_at', 'is', null);
      return List<Map<String, dynamic>>.from(response);
    }
  }

  @override
  Future<void> insertAuthor(Map<String, dynamic> authorMap) async {
    await supabaseClient.from('authors').insert(authorMap);
  }

  @override
  Future<void> updateAuthor(Map<String, dynamic> authorMap) async {
    await supabaseClient
        .from('authors')
        .update(authorMap)
        .eq('id', authorMap['id']);
  }

  @override
  Future<void> deleteAuthor(String id) async {
    try {
      await supabaseClient
          .from('authors')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', id);
    } catch (_) {
      try {
        final author = await supabaseClient.from('authors').select().eq('id', id).maybeSingle();
        if (author != null) {
          final photoUrl = author['photo_url'] ?? author['photoUrl'];
          await _deleteStorageFile('pustaka-assets', photoUrl?.toString());
        }
      } catch (_) {}
      await supabaseClient.from('authors').delete().eq('id', id);
    }
  }

  @override
  Future<void> restoreAuthors(List<String> ids) async {
    if (ids.isEmpty) return;
    await supabaseClient
        .from('authors')
        .update({'deleted_at': null})
        .inFilter('id', ids);
  }

  @override
  Future<void> permanentlyDeleteAuthors(List<String> ids) async {
    if (ids.isEmpty) return;
    for (final id in ids) {
      try {
        final author = await supabaseClient.from('authors').select().eq('id', id).maybeSingle();
        if (author != null) {
          final photoUrl = author['photo_url'] ?? author['photoUrl'];
          await _deleteStorageFile('pustaka-assets', photoUrl?.toString());
        }
      } catch (_) {}
    }
    await supabaseClient.from('authors').delete().inFilter('id', ids);
  }

  // ---------------- ARTICLE METHODS ----------------
  @override
  Future<List<Map<String, dynamic>>> getArticles({int page = 0, int pageSize = 15}) async {
    final from = page * pageSize;
    final to = from + pageSize - 1;
    try {
      // Lightweight fetch: omit heavy Quill Delta JSON content on list cards
      final response = await supabaseClient
          .from('articles')
          .select('id, title, author, date, image_url, imageUrl, created_at')
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false)
          .range(from, to);
      return List<Map<String, dynamic>>.from(response);
    } catch (_) {
      try {
        final response = await supabaseClient
            .from('articles')
            .select('id, title, author, date, created_at')
            .isFilter('deleted_at', null)
            .range(from, to);
        return List<Map<String, dynamic>>.from(response);
      } catch (_) {
        final response = await supabaseClient
            .from('articles')
            .select()
            .isFilter('deleted_at', null)
            .limit(pageSize);
        return List<Map<String, dynamic>>.from(response);
      }
    }
  }

  @override
  Future<Map<String, dynamic>?> getArticleById(String id) async {
    try {
      final response = await supabaseClient
          .from('articles')
          .select()
          .eq('id', id)
          .maybeSingle();
      return response;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> getArticlesCount() async {
    try {
      final count = await supabaseClient
          .from('articles')
          .count(CountOption.exact)
          .isFilter('deleted_at', null);
      return count;
    } catch (_) {
      try {
        final res = await supabaseClient
            .from('articles')
            .select('id')
            .isFilter('deleted_at', null);
        return res.length;
      } catch (_) {
        return 0;
      }
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getDeletedArticles() async {
    try {
      final response = await supabaseClient
          .from('articles')
          .select()
          .not('deleted_at', 'is', null)
          .order('deleted_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (_) {
      final response = await supabaseClient
          .from('articles')
          .select()
          .not('deleted_at', 'is', null);
      return List<Map<String, dynamic>>.from(response);
    }
  }

  @override
  Future<void> insertArticle(Map<String, dynamic> articleMap) async {
    await supabaseClient.from('articles').insert(articleMap);
  }

  @override
  Future<void> updateArticle(Map<String, dynamic> articleMap) async {
    await supabaseClient
        .from('articles')
        .update(articleMap)
        .eq('id', articleMap['id']);
  }

  @override
  Future<void> deleteArticle(String id) async {
    try {
      await supabaseClient
          .from('articles')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', id);
    } catch (_) {
      try {
        final article = await supabaseClient.from('articles').select().eq('id', id).maybeSingle();
        if (article != null) {
          final imageUrl = article['image_url'] ?? article['imageUrl'];
          await _deleteStorageFile('pustaka-assets', imageUrl?.toString());
        }
      } catch (_) {}
      await supabaseClient.from('articles').delete().eq('id', id);
    }
  }

  @override
  Future<void> restoreArticles(List<String> ids) async {
    if (ids.isEmpty) return;
    await supabaseClient
        .from('articles')
        .update({'deleted_at': null})
        .inFilter('id', ids);
  }

  @override
  Future<void> permanentlyDeleteArticles(List<String> ids) async {
    if (ids.isEmpty) return;
    for (final id in ids) {
      try {
        final article = await supabaseClient.from('articles').select().eq('id', id).maybeSingle();
        if (article != null) {
          final imageUrl = article['image_url'] ?? article['imageUrl'];
          await _deleteStorageFile('pustaka-assets', imageUrl?.toString());
        }
      } catch (_) {}
    }
    await supabaseClient.from('articles').delete().inFilter('id', ids);
  }

  // ---------------- SUBMISSION METHODS ----------------
  @override
  Future<List<Map<String, dynamic>>> getSubmissions({
    int page = 0,
    int pageSize = 15,
    String? status,
  }) async {
    final from = page * pageSize;
    final to = from + pageSize - 1;
    try {
      // Lightweight fetch: omit heavy synopsis and pdf document url on list cards
      var query = supabaseClient
          .from('submissions')
          .select('id, sender_name, email, status, created_at')
          .isFilter('deleted_at', null);

      if (status != null &&
          status.trim().isNotEmpty &&
          status.toLowerCase() != 'semua status') {
        query = query.eq('status', status.toLowerCase());
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(from, to);
      return List<Map<String, dynamic>>.from(response);
    } catch (_) {
      try {
        final response = await supabaseClient
            .from('submissions')
            .select('id, sender_name, email, status, created_at')
            .isFilter('deleted_at', null)
            .range(from, to);
        return List<Map<String, dynamic>>.from(response);
      } catch (_) {
        final response = await supabaseClient
            .from('submissions')
            .select()
            .isFilter('deleted_at', null)
            .limit(pageSize);
        return List<Map<String, dynamic>>.from(response);
      }
    }
  }

  @override
  Future<Map<String, dynamic>?> getSubmissionById(String id) async {
    try {
      final response = await supabaseClient
          .from('submissions')
          .select()
          .eq('id', id)
          .maybeSingle();
      return response;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> getSubmissionsCount({String? status}) async {
    try {
      var query = supabaseClient
          .from('submissions')
          .count(CountOption.exact)
          .isFilter('deleted_at', null);
      if (status != null &&
          status.trim().isNotEmpty &&
          status.toLowerCase() != 'semua status') {
        query = query.eq('status', status.toLowerCase());
      }
      final count = await query;
      return count;
    } catch (_) {
      try {
        var query = supabaseClient
            .from('submissions')
            .select('id')
            .isFilter('deleted_at', null);
        if (status != null &&
            status.trim().isNotEmpty &&
            status.toLowerCase() != 'semua status') {
          query = query.eq('status', status.toLowerCase());
        }
        final res = await query;
        return res.length;
      } catch (_) {
        return 0;
      }
    }
  }

  @override
  Future<int> getPendingSubmissionsCount() async {
    return await getSubmissionsCount(status: 'pending');
  }

  @override
  Future<List<Map<String, dynamic>>> getRecentUnreviewedSubmissions({int limit = 5}) async {
    try {
      final response = await supabaseClient
          .from('submissions')
          .select('id, sender_name, email, synopsis, pdf_document_url, status, created_at')
          .isFilter('deleted_at', null)
          .eq('status', 'pending')
          .order('created_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (_) {
      try {
        final response = await supabaseClient
            .from('submissions')
            .select()
            .isFilter('deleted_at', null)
            .limit(limit);
        return List<Map<String, dynamic>>.from(response);
      } catch (_) {
        return [];
      }
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getDeletedSubmissions() async {
    try {
      final response = await supabaseClient
          .from('submissions')
          .select()
          .not('deleted_at', 'is', null)
          .order('deleted_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (_) {
      final response = await supabaseClient
          .from('submissions')
          .select()
          .not('deleted_at', 'is', null);
      return List<Map<String, dynamic>>.from(response);
    }
  }

  @override
  Future<void> deleteSubmission(String id) async {
    try {
      await supabaseClient
          .from('submissions')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', id);
    } catch (_) {
      try {
        final submission = await supabaseClient.from('submissions').select().eq('id', id).maybeSingle();
        if (submission != null) {
          final pdfUrl = submission['pdf_document_url'] ??
              submission['pdfDocumentUrl'] ??
              submission['pdf_url'] ??
              submission['file_url'];
          await _deleteStorageFile('naskah', pdfUrl?.toString());
        }
      } catch (_) {}
      await supabaseClient.from('submissions').delete().eq('id', id);
    }
  }

  @override
  Future<void> updateSubmissionStatus(String id, String status) async {
    await supabaseClient
        .from('submissions')
        .update({'status': status})
        .eq('id', id);
  }

  @override
  Future<void> restoreSubmissions(List<String> ids) async {
    if (ids.isEmpty) return;
    await supabaseClient
        .from('submissions')
        .update({'deleted_at': null})
        .inFilter('id', ids);
  }

  @override
  Future<void> permanentlyDeleteSubmissions(List<String> ids) async {
    if (ids.isEmpty) return;
    for (final id in ids) {
      try {
        final submission = await supabaseClient.from('submissions').select().eq('id', id).maybeSingle();
        if (submission != null) {
          final pdfUrl = submission['pdf_document_url'] ??
              submission['pdfDocumentUrl'] ??
              submission['pdf_url'] ??
              submission['file_url'];
          await _deleteStorageFile('naskah', pdfUrl?.toString());
        }
      } catch (_) {}
    }
    await supabaseClient.from('submissions').delete().inFilter('id', ids);
  }

  // ---------------- DASHBOARD AGGREGATES ----------------
  @override
  Future<Map<String, dynamic>> getDashboardMetrics() async {
    // Run counts concurrently with server-side head/exact queries
    final results = await Future.wait([
      getBooksCount(),
      getPendingSubmissionsCount(),
      getAuthorsCount(),
      getActivePromosCount(),
      getRecentUnreviewedSubmissions(limit: 5),
    ]);

    // Fetch dates for monthly growth trend calculation
    List<DateTime> bookDates = [];
    List<DateTime> submissionDates = [];

    try {
      final booksDatesRes = await supabaseClient
          .from('books')
          .select('created_at')
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false)
          .limit(200);

      bookDates = (booksDatesRes as List)
          .map((e) => DateTime.tryParse(e['created_at']?.toString() ?? ''))
          .whereType<DateTime>()
          .toList();
    } catch (_) {}

    try {
      final subDatesRes = await supabaseClient
          .from('submissions')
          .select('created_at')
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false)
          .limit(200);

      submissionDates = (subDatesRes as List)
          .map((e) => DateTime.tryParse(e['created_at']?.toString() ?? ''))
          .whereType<DateTime>()
          .toList();
    } catch (_) {}

    return {
      'totalBooks': results[0] as int,
      'pendingSubmissions': results[1] as int,
      'totalAuthors': results[2] as int,
      'activePromos': results[3] as int,
      'recentSubmissions': results[4] as List<Map<String, dynamic>>,
      'bookDates': bookDates,
      'submissionDates': submissionDates,
    };
  }

  // ---------------- SITE SETTINGS (WEB CMS) ----------------
  @override
  Future<List<Map<String, dynamic>>> getBooksForDropdown() async {
    try {
      final res = await supabaseClient
          .from('books')
          .select('id, title, author, price, promo_price, cover_url, coverUrl')
          .isFilter('deleted_at', null)
          .order('title', ascending: true);
      return List<Map<String, dynamic>>.from(res);
    } catch (_) {
      try {
        final res = await supabaseClient
            .from('books')
            .select('id, title, author, price, discount_price, cover_url')
            .isFilter('deleted_at', null)
            .order('title', ascending: true);
        return List<Map<String, dynamic>>.from(res);
      } catch (_) {
        try {
          final res = await supabaseClient
              .from('books')
              .select('id, title, author, price')
              .isFilter('deleted_at', null)
              .order('title', ascending: true);
          return List<Map<String, dynamic>>.from(res);
        } catch (_) {
          return [];
        }
      }
    }
  }

  @override
  Future<Map<String, dynamic>?> getSiteSettings() async {
    try {
      final res = await supabaseClient
          .from('site_settings')
          .select()
          .limit(1)
          .maybeSingle();
      return res;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateSiteSettings(Map<String, dynamic> settings) async {
    final payload = Map<String, dynamic>.from(settings);
    payload['updated_at'] = DateTime.now().toIso8601String();
    if (!payload.containsKey('id') || payload['id'] == null) {
      payload['id'] = 'default';
    }
    await supabaseClient.from('site_settings').upsert(payload);
  }

  @override
  Future<String> getPreorderNotificationEmail() async {
    try {
      final res = await supabaseClient
          .from('site_settings')
          .select('preorder_notification_email')
          .eq('id', 'default')
          .maybeSingle();

      if (res != null &&
          res['preorder_notification_email'] != null &&
          res['preorder_notification_email'].toString().trim().isNotEmpty) {
        return res['preorder_notification_email'].toString().trim();
      }
    } catch (_) {
      try {
        final res = await supabaseClient
            .from('site_settings')
            .select()
            .limit(1)
            .maybeSingle();

        if (res != null) {
          final emailCol = res['preorder_notification_email'] ?? res['value'];
          if (emailCol != null && emailCol.toString().trim().isNotEmpty) {
            return emailCol.toString().trim();
          }
        }
      } catch (_) {}
    }

    return 'admin@pustakaiman.com';
  }

  @override
  Future<void> updatePreorderNotificationEmail(String email) async {
    final trimmedEmail = email.trim();
    final now = DateTime.now().toIso8601String();

    try {
      await supabaseClient
          .from('site_settings')
          .update({
            'preorder_notification_email': trimmedEmail,
            'updated_at': now,
          })
          .eq('id', 'default');
    } catch (_) {
      await supabaseClient.from('site_settings').upsert({
        'id': 'default',
        'preorder_notification_email': trimmedEmail,
        'updated_at': now,
      });
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getBankAccounts() async {
    try {
      final res = await supabaseClient
          .from('site_settings')
          .select('bank_accounts')
          .eq('id', 'default')
          .maybeSingle();

      if (res != null && res['bank_accounts'] != null && res['bank_accounts'] is List) {
        return List<Map<String, dynamic>>.from(res['bank_accounts']);
      }
    } catch (_) {
      try {
        final res = await supabaseClient
            .from('site_settings')
            .select()
            .limit(1)
            .maybeSingle();

        if (res != null && res['bank_accounts'] != null && res['bank_accounts'] is List) {
          return List<Map<String, dynamic>>.from(res['bank_accounts']);
        }
      } catch (_) {}
    }
    return [];
  }

  @override
  Future<void> updateBankAccounts(List<Map<String, dynamic>> bankAccounts) async {
    final now = DateTime.now().toIso8601String();
    try {
      await supabaseClient
          .from('site_settings')
          .update({
            'bank_accounts': bankAccounts,
            'updated_at': now,
          })
          .eq('id', 'default');
    } catch (_) {
      await supabaseClient.from('site_settings').upsert({
        'id': 'default',
        'bank_accounts': bankAccounts,
        'updated_at': now,
      });
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPreorders() async {
    try {
      final res = await supabaseClient
          .from('preorders')
          .select()
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (_) {
      try {
        final res = await supabaseClient
            .from('pre_orders')
            .select()
            .isFilter('deleted_at', null)
            .order('created_at', ascending: false);
        return List<Map<String, dynamic>>.from(res);
      } catch (_) {
        return [];
      }
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getDeletedPreorders() async {
    try {
      final res = await supabaseClient
          .from('preorders')
          .select()
          .not('deleted_at', 'is', null)
          .order('deleted_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (_) {
      try {
        final res = await supabaseClient
            .from('pre_orders')
            .select()
            .not('deleted_at', 'is', null)
            .order('deleted_at', ascending: false);
        return List<Map<String, dynamic>>.from(res);
      } catch (_) {
        return [];
      }
    }
  }

  @override
  Future<void> updatePreorderStatus(String id, String status) async {
    try {
      await supabaseClient
          .from('preorders')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (_) {
      await supabaseClient
          .from('pre_orders')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    }
  }

  @override
  Future<void> deletePreorder(String id) async {
    final now = DateTime.now().toIso8601String();
    try {
      await supabaseClient
          .from('preorders')
          .update({'deleted_at': now})
          .eq('id', id);
    } catch (_) {
      await supabaseClient
          .from('pre_orders')
          .update({'deleted_at': now})
          .eq('id', id);
    }
  }

  @override
  Future<void> restorePreorders(List<String> ids) async {
    if (ids.isEmpty) return;
    try {
      await supabaseClient
          .from('preorders')
          .update({'deleted_at': null})
          .inFilter('id', ids);
    } catch (_) {
      await supabaseClient
          .from('pre_orders')
          .update({'deleted_at': null})
          .inFilter('id', ids);
    }
  }

  @override
  Future<void> permanentlyDeletePreorders(List<String> ids) async {
    if (ids.isEmpty) return;
    try {
      await supabaseClient.from('preorders').delete().inFilter('id', ids);
    } catch (_) {
      await supabaseClient.from('pre_orders').delete().inFilter('id', ids);
    }
  }

  @override
  Future<String> uploadSiteBanner(Uint8List bytes, String fileName, {String? contentType}) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : 'jpg';
    final sanitizedName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9\._-]'), '_').toLowerCase();
    final path = 'hero/$timestamp-$sanitizedName';
    final mimeType = contentType ?? (extension == 'png' ? 'image/png' : (extension == 'webp' ? 'image/webp' : 'image/jpeg'));

    try {
      return await uploadStorageFile(
        bucket: 'public_assets',
        path: path,
        bytes: bytes,
        contentType: mimeType,
      );
    } catch (_) {
      // Fallback to pustaka-assets if public_assets bucket is not created
      return await uploadStorageFile(
        bucket: 'pustaka-assets',
        path: path,
        bytes: bytes,
        contentType: mimeType,
      );
    }
  }

  // ---------------- MEDIA VIDEOS METHODS ----------------
  @override
  Future<List<Map<String, dynamic>>> getMediaVideos({int page = 0, int pageSize = 30}) async {
    final from = page * pageSize;
    final to = from + pageSize - 1;
    try {
      final response = await supabaseClient
          .from('media_videos')
          .select()
          .isFilter('deleted_at', null)
          .order('order_index', ascending: true)
          .order('created_at', ascending: false)
          .range(from, to);
      return List<Map<String, dynamic>>.from(response);
    } catch (_) {
      try {
        final response = await supabaseClient
            .from('media_videos')
            .select()
            .isFilter('deleted_at', null)
            .order('created_at', ascending: false)
            .range(from, to);
        return List<Map<String, dynamic>>.from(response);
      } catch (_) {
        final response = await supabaseClient
            .from('media_videos')
            .select()
            .limit(pageSize);
        return List<Map<String, dynamic>>.from(response);
      }
    }
  }

  @override
  Future<Map<String, dynamic>?> getMediaVideoById(String id) async {
    try {
      final response = await supabaseClient
          .from('media_videos')
          .select()
          .eq('id', id)
          .maybeSingle();
      return response;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> getMediaVideosCount() async {
    try {
      final count = await supabaseClient
          .from('media_videos')
          .count(CountOption.exact)
          .isFilter('deleted_at', null);
      return count;
    } catch (_) {
      return 0;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getDeletedMediaVideos() async {
    try {
      final response = await supabaseClient
          .from('media_videos')
          .select()
          .not('deleted_at', 'is', null)
          .order('deleted_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (_) {
      return [];
    }
  }

  Future<void> _safeSaveMediaVideoPayload({
    required Map<String, dynamic> initialMap,
    required Future<void> Function(Map<String, dynamic> payload) saveAction,
  }) async {
    final payload = Map<String, dynamic>.from(initialMap);

    for (int attempt = 0; attempt < 10; attempt++) {
      try {
        await saveAction(payload);
        return;
      } catch (e) {
        final errStr = e.toString();
        final match = RegExp(r"Could not find the '([^']+)' column").firstMatch(errStr);
        if (match != null && match.groupCount >= 1) {
          final missingCol = match.group(1)!;
          if (payload.containsKey(missingCol)) {
            payload.remove(missingCol);
            continue;
          }
        }
        rethrow;
      }
    }
  }

  @override
  Future<void> addMediaVideo(Map<String, dynamic> videoMap) async {
    final mapToSave = Map<String, dynamic>.from(videoMap);
    mapToSave['created_at'] = DateTime.now().toIso8601String();
    mapToSave['updated_at'] = DateTime.now().toIso8601String();
    if (mapToSave['id'] == null || mapToSave['id'].toString().isEmpty) {
      mapToSave.remove('id');
    }

    if (mapToSave['is_featured'] == true) {
      try {
        await supabaseClient
            .from('media_videos')
            .update({'is_featured': false})
            .eq('is_featured', true);
      } catch (_) {}
    }

    await _safeSaveMediaVideoPayload(
      initialMap: mapToSave,
      saveAction: (payload) async {
        await supabaseClient.from('media_videos').insert(payload);
      },
    );
  }

  @override
  Future<void> updateMediaVideo(Map<String, dynamic> videoMap) async {
    final mapToSave = Map<String, dynamic>.from(videoMap);
    mapToSave['updated_at'] = DateTime.now().toIso8601String();
    final id = mapToSave['id'];

    if (mapToSave['is_featured'] == true && id != null) {
      try {
        await supabaseClient
            .from('media_videos')
            .update({'is_featured': false})
            .neq('id', id);
      } catch (_) {}
    }

    await _safeSaveMediaVideoPayload(
      initialMap: mapToSave,
      saveAction: (payload) async {
        await supabaseClient.from('media_videos').update(payload).eq('id', id);
      },
    );
  }

  @override
  Future<void> deleteMediaVideo(String id) async {
    await supabaseClient
        .from('media_videos')
        .update({'deleted_at': DateTime.now().toIso8601String()})
        .eq('id', id);
  }

  @override
  Future<void> setFeaturedMediaVideo(String id) async {
    await supabaseClient
        .from('media_videos')
        .update({'is_featured': false})
        .neq('id', id);

    await supabaseClient
        .from('media_videos')
        .update({'is_featured': true})
        .eq('id', id);
  }

  @override
  Future<void> restoreMediaVideos(List<String> ids) async {
    if (ids.isEmpty) return;
    await supabaseClient
        .from('media_videos')
        .update({'deleted_at': null})
        .inFilter('id', ids);
  }

  @override
  Future<void> permanentlyDeleteMediaVideos(List<String> ids) async {
    if (ids.isEmpty) return;
    await supabaseClient.from('media_videos').delete().inFilter('id', ids);
  }

  // ---------------- STORAGE HELPER ----------------
  @override
  Future<String> uploadStorageFile({
    required String bucket,
    required String path,
    required Uint8List bytes,
    String? contentType,
  }) async {
    await supabaseClient.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: contentType,
          ),
        );
    return supabaseClient.storage.from(bucket).getPublicUrl(path);
  }
}
