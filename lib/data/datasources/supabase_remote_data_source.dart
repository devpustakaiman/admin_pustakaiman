import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SupabaseRemoteDataSource {
  // Books CRUD & Trash
  Future<List<Map<String, dynamic>>> getBooks();
  Future<List<Map<String, dynamic>>> getDeletedBooks();
  Future<void> addBook(Map<String, dynamic> bookMap);
  Future<void> updateBook(Map<String, dynamic> bookMap);
  Future<void> deleteBook(String id);
  Future<void> restoreBooks(List<String> ids);
  Future<void> permanentlyDeleteBooks(List<String> ids);

  // Authors CRUD & Trash
  Future<List<Map<String, dynamic>>> getAuthors();
  Future<List<Map<String, dynamic>>> getDeletedAuthors();
  Future<void> insertAuthor(Map<String, dynamic> authorMap);
  Future<void> updateAuthor(Map<String, dynamic> authorMap);
  Future<void> deleteAuthor(String id);
  Future<void> restoreAuthors(List<String> ids);
  Future<void> permanentlyDeleteAuthors(List<String> ids);

  // Articles CRUD & Trash
  Future<List<Map<String, dynamic>>> getArticles();
  Future<List<Map<String, dynamic>>> getDeletedArticles();
  Future<void> insertArticle(Map<String, dynamic> articleMap);
  Future<void> updateArticle(Map<String, dynamic> articleMap);
  Future<void> deleteArticle(String id);
  Future<void> restoreArticles(List<String> ids);
  Future<void> permanentlyDeleteArticles(List<String> ids);

  // Submissions CRUD & Trash
  Future<List<Map<String, dynamic>>> getSubmissions();
  Future<List<Map<String, dynamic>>> getDeletedSubmissions();
  Future<void> updateSubmissionStatus(String id, String status);
  Future<void> deleteSubmission(String id);
  Future<void> restoreSubmissions(List<String> ids);
  Future<void> permanentlyDeleteSubmissions(List<String> ids);

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
  Future<List<Map<String, dynamic>>> getBooks() async {
    try {
      final response = await supabaseClient
          .from('books')
          .select()
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false)
          .limit(100);
      return List<Map<String, dynamic>>.from(response);
    } catch (_) {
      final response = await supabaseClient.from('books').select().isFilter('deleted_at', null).limit(100);
      return List<Map<String, dynamic>>.from(response);
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

  @override
  Future<void> addBook(Map<String, dynamic> bookMap) async {
    final mapToSave = Map<String, dynamic>.from(bookMap);
    mapToSave['created_at'] = DateTime.now().toIso8601String();
    mapToSave['updated_at'] = DateTime.now().toIso8601String();
    await supabaseClient.from('books').insert(mapToSave);
  }

  @override
  Future<void> updateBook(Map<String, dynamic> bookMap) async {
    final mapToSave = Map<String, dynamic>.from(bookMap);
    mapToSave['updated_at'] = DateTime.now().toIso8601String();
    await supabaseClient.from('books').update(mapToSave).eq('id', bookMap['id']);
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
  Future<List<Map<String, dynamic>>> getAuthors() async {
    try {
      final response = await supabaseClient
          .from('authors')
          .select()
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false)
          .limit(100);
      return List<Map<String, dynamic>>.from(response);
    } catch (_) {
      final response = await supabaseClient.from('authors').select().limit(100);
      return List<Map<String, dynamic>>.from(response);
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
  Future<List<Map<String, dynamic>>> getArticles() async {
    try {
      final response = await supabaseClient
          .from('articles')
          .select()
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false)
          .limit(100);
      return List<Map<String, dynamic>>.from(response);
    } catch (_) {
      final response = await supabaseClient.from('articles').select().limit(100);
      return List<Map<String, dynamic>>.from(response);
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
  Future<List<Map<String, dynamic>>> getSubmissions() async {
    try {
      final response = await supabaseClient
          .from('submissions')
          .select()
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false)
          .limit(100);
      return List<Map<String, dynamic>>.from(response);
    } catch (_) {
      final response = await supabaseClient.from('submissions').select().limit(100);
      return List<Map<String, dynamic>>.from(response);
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
