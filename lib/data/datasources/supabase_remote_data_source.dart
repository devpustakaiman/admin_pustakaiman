import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SupabaseRemoteDataSource {
  Future<List<Map<String, dynamic>>> getBooks();
  Future<List<Map<String, dynamic>>> getArticles();
  Future<List<Map<String, dynamic>>> getSubmissions();
  Future<void> addBook(Map<String, dynamic> bookMap);
  Future<void> updateBook(Map<String, dynamic> bookMap);
  Future<void> deleteBook(String id);

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

  @override
  Future<List<Map<String, dynamic>>> getBooks() async {
    final response = await supabaseClient.from('books').select();
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<List<Map<String, dynamic>>> getArticles() async {
    final response = await supabaseClient
        .from('articles')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
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
    await supabaseClient.from('articles').delete().eq('id', id);
  }

  @override
  Future<List<Map<String, dynamic>>> getSubmissions() async {
    final response = await supabaseClient
        .from('submissions')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<void> addBook(Map<String, dynamic> bookMap) async {
    await supabaseClient.from('books').insert(bookMap);
  }

  @override
  Future<void> updateBook(Map<String, dynamic> bookMap) async {
    await supabaseClient.from('books').update(bookMap).eq('id', bookMap['id']);
  }

  @override
  Future<void> deleteBook(String id) async {
    await supabaseClient.from('books').delete().eq('id', id);
  }

  @override
  Future<List<Map<String, dynamic>>> getAuthors() async {
    final response = await supabaseClient
        .from('authors')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
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
    await supabaseClient.from('authors').delete().eq('id', id);
  }
}
