import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SupabaseRemoteDataSource {
  Future<List<Map<String, dynamic>>> getBooks();
  Future<List<Map<String, dynamic>>> getArticles();
  Future<List<Map<String, dynamic>>> getSubmissions();
  Future<void> deleteSubmission(String id);
  Future<void> updateSubmissionStatus(String id, String status);
  Future<void> addBook(Map<String, dynamic> bookMap);
  Future<void> updateBook(Map<String, dynamic> bookMap);
  Future<void> deleteBook(String id);

  // Storage Upload Helper
  Future<String> uploadStorageFile({
    required String bucket,
    required String path,
    required Uint8List bytes,
    String? contentType,
  });

  // Article CRUD
  Future<void> insertArticle(Map<String, dynamic> articleMap);
  Future<void> updateArticle(Map<String, dynamic> articleMap);
  Future<void> deleteArticle(String id);

  // Author CRUD
  Future<List<Map<String, dynamic>>> getAuthors();
  Future<void> insertAuthor(Map<String, dynamic> authorMap);
  Future<void> updateAuthor(Map<String, dynamic> authorMap);
  Future<void> deleteAuthor(String id);
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

  @override
  Future<List<Map<String, dynamic>>> getBooks() async {
    try {
      final response = await supabaseClient
          .from('books')
          .select()
          .limit(50);
      return List<Map<String, dynamic>>.from(response);
    } catch (_) {
      final response = await supabaseClient.from('books').select().limit(50);
      return List<Map<String, dynamic>>.from(response);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getArticles() async {
    try {
      final response = await supabaseClient
          .from('articles')
          .select()
          .order('created_at', ascending: false)
          .limit(50);
      return List<Map<String, dynamic>>.from(response);
    } catch (_) {
      final response = await supabaseClient.from('articles').select().limit(50);
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
      final article = await supabaseClient.from('articles').select().eq('id', id).maybeSingle();
      if (article != null) {
        final imageUrl = article['image_url'] ?? article['imageUrl'];
        await _deleteStorageFile('pustaka-assets', imageUrl?.toString());
      }
    } catch (_) {}
    await supabaseClient.from('articles').delete().eq('id', id);
  }

  @override
  Future<List<Map<String, dynamic>>> getSubmissions() async {
    try {
      final response = await supabaseClient
          .from('submissions')
          .select()
          .order('created_at', ascending: false)
          .limit(50);
      return List<Map<String, dynamic>>.from(response);
    } catch (_) {
      final response = await supabaseClient.from('submissions').select().limit(50);
      return List<Map<String, dynamic>>.from(response);
    }
  }

  @override
  Future<void> deleteSubmission(String id) async {
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

  @override
  Future<void> updateSubmissionStatus(String id, String status) async {
    await supabaseClient
        .from('submissions')
        .update({'status': status})
        .eq('id', id);
  }

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
  Future<List<Map<String, dynamic>>> getAuthors() async {
    try {
      final response = await supabaseClient
          .from('authors')
          .select()
          .order('created_at', ascending: false)
          .limit(50);
      return List<Map<String, dynamic>>.from(response);
    } catch (_) {
      final response = await supabaseClient.from('authors').select().limit(50);
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
      final author = await supabaseClient.from('authors').select().eq('id', id).maybeSingle();
      if (author != null) {
        final photoUrl = author['photo_url'] ?? author['photoUrl'];
        await _deleteStorageFile('pustaka-assets', photoUrl?.toString());
      }
    } catch (_) {}
    await supabaseClient.from('authors').delete().eq('id', id);
  }
}
