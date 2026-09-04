import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/app_toast.dart';
import '../../domain/entities/media_video.dart';
import '../../domain/repositories/video_repository.dart';
import '../widgets/video_form_dialog.dart';

class VideoController extends GetxController {
  final VideoRepository videoRepository;

  VideoController({required this.videoRepository});

  static const List<String> categories = [
    'LIPUTAN UTAMA',
    'WAWANCARA',
    'BEDAH BUKU',
    'DOKUMENTER',
    'CERITA DALAM SOROTAN',
    'LAIN-LAIN',
  ];

  final RxList<MediaVideo> videos = <MediaVideo>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategoryFilter = 'Semua Kategori'.obs;
  final RxBool isLoading = false.obs;
  final RxBool isUploading = false.obs;
  final RxString uploadStatusMessage = ''.obs;
  final RxString errorMessage = ''.obs;
  final RxString editingVideoId = ''.obs;

  // Selected file for custom thumbnail
  final Rx<PlatformFile?> selectedThumbnailFile = Rx<PlatformFile?>(null);

  // Form Controllers
  final titleController = TextEditingController();
  final youtubeUrlController = TextEditingController();
  final thumbnailUrlController = TextEditingController();
  final durationController = TextEditingController();
  final categoryController = TextEditingController();
  final speakerNameController = TextEditingController();
  final orderIndexController = TextEditingController();
  final RxBool isFeatured = false.obs;

  List<MediaVideo> get filteredVideos {
    List<MediaVideo> result = List.from(videos);

    if (searchQuery.value.trim().isNotEmpty) {
      final query = searchQuery.value.toLowerCase().trim();
      result = result.where((video) {
        final titleMatch = video.title.toLowerCase().contains(query);
        final speakerMatch = video.speakerName.toLowerCase().contains(query);
        final categoryMatch = video.category.toLowerCase().contains(query);
        return titleMatch || speakerMatch || categoryMatch;
      }).toList();
    }

    if (selectedCategoryFilter.value != 'Semua Kategori') {
      final selectedCat = selectedCategoryFilter.value.toLowerCase();
      result = result
          .where((video) => video.category.toLowerCase() == selectedCat)
          .toList();
    }

    return result;
  }

  @override
  void onInit() {
    super.onInit();
    fetchVideos();
  }

  @override
  void onClose() {
    titleController.dispose();
    youtubeUrlController.dispose();
    thumbnailUrlController.dispose();
    durationController.dispose();
    categoryController.dispose();
    speakerNameController.dispose();
    orderIndexController.dispose();
    super.onClose();
  }

  String extractYoutubeId(String url) {
    if (url.trim().isEmpty) return '';
    final trimmed = url.trim();
    final regExp = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(trimmed);
    if (match != null && match.groupCount >= 1) {
      return match.group(1)!;
    }
    if (trimmed.length == 11 && !trimmed.contains('/')) {
      return trimmed;
    }
    return '';
  }

  void clearForm() {
    titleController.clear();
    youtubeUrlController.clear();
    thumbnailUrlController.clear();
    durationController.clear();
    categoryController.text = 'LIPUTAN UTAMA';
    speakerNameController.clear();
    orderIndexController.text = '0';
    isFeatured.value = false;
    selectedThumbnailFile.value = null;
    editingVideoId.value = '';
    uploadStatusMessage.value = '';
    isUploading.value = false;
  }

  Future<void> pickThumbnailFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        selectedThumbnailFile.value = result.files.first;
      }
    } catch (e) {
      errorMessage.value = 'Gagal memilih file gambar thumbnail: $e';
    }
  }

  Future<String?> uploadThumbnailStorage(PlatformFile file) async {
    Uint8List? bytes = file.bytes;
    if (bytes == null) {
      throw Exception('File thumbnail kosong atau tidak dapat dibaca');
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = file.extension ?? 'jpg';
    final sanitizedName = file.name.replaceAll(RegExp(r'[^a-zA-Z0-9\._-]'), '_').toLowerCase();
    final path = 'videos/$timestamp-$sanitizedName';
    final contentType = 'image/${extension == "png" ? "png" : (extension == "webp" ? "webp" : "jpeg")}';

    final supabase = Supabase.instance.client;
    try {
      await supabase.storage.from('media-thumbnails').uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(upsert: true, contentType: contentType),
          );
      return supabase.storage.from('media-thumbnails').getPublicUrl(path);
    } catch (_) {
      try {
        await supabase.storage.from('pustaka-assets').uploadBinary(
              path,
              bytes,
              fileOptions: FileOptions(upsert: true, contentType: contentType),
            );
        return supabase.storage.from('pustaka-assets').getPublicUrl(path);
      } catch (_) {
        rethrow;
      }
    }
  }

  void openFormDialog({MediaVideo? video}) {
    if (video != null) {
      editingVideoId.value = video.id;
      titleController.text = video.title;
      youtubeUrlController.text = video.youtubeUrl;
      thumbnailUrlController.text = video.thumbnailUrl;
      durationController.text = video.duration;
      categoryController.text = video.category.isNotEmpty ? video.category : 'LIPUTAN UTAMA';
      speakerNameController.text = video.speakerName;
      orderIndexController.text = video.orderIndex.toString();
      isFeatured.value = video.isFeatured;
      selectedThumbnailFile.value = null;

      Get.dialog(
        VideoFormDialog(controller: this),
        barrierDismissible: false,
      );
    } else {
      clearForm();
      Get.dialog(
        VideoFormDialog(controller: this),
        barrierDismissible: false,
      );
    }
  }

  Future<void> fetchVideos() async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await videoRepository.getVideos();
    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (data) {
        videos.assignAll(data);
        isLoading.value = false;
      },
    );
  }

  Future<void> saveVideo() async {
    final title = titleController.text.trim();
    final yUrl = youtubeUrlController.text.trim();

    if (title.isEmpty) {
      if (Get.context != null) {
        AppToast.showError(Get.context!, 'Judul Video wajib diisi');
      }
      return;
    }

    if (yUrl.isEmpty) {
      if (Get.context != null) {
        AppToast.showError(Get.context!, 'Link YouTube wajib diisi');
      }
      return;
    }

    isLoading.value = true;
    isUploading.value = true;
    errorMessage.value = '';

    try {
      String uploadedThumbUrl = thumbnailUrlController.text.trim();

      // 1. Upload custom thumbnail file if picked
      if (selectedThumbnailFile.value != null) {
        uploadStatusMessage.value = 'Mengunggah Thumbnail Video...';
        final uploaded = await uploadThumbnailStorage(selectedThumbnailFile.value!);
        if (uploaded != null && uploaded.isNotEmpty) {
          uploadedThumbUrl = uploaded;
        }
      }

      // 2. Auto-fallback to YouTube HQ default thumbnail if thumbnail_url is empty
      if (uploadedThumbUrl.isEmpty) {
        final yId = extractYoutubeId(yUrl);
        if (yId.isNotEmpty) {
          uploadedThumbUrl = 'https://img.youtube.com/vi/$yId/hqdefault.jpg';
        }
      }

      uploadStatusMessage.value = 'Menyimpan data video...';
      final orderIndexVal = int.tryParse(orderIndexController.text.trim()) ?? 0;

      final video = MediaVideo(
        id: editingVideoId.value,
        title: title,
        youtubeUrl: yUrl,
        thumbnailUrl: uploadedThumbUrl,
        duration: durationController.text.trim(),
        category: categoryController.text.trim().isNotEmpty
            ? categoryController.text.trim()
            : 'LIPUTAN UTAMA',
        speakerName: speakerNameController.text.trim(),
        isFeatured: isFeatured.value,
        orderIndex: orderIndexVal,
        updatedAt: DateTime.now(),
      );

      final result = editingVideoId.value.isEmpty
          ? await videoRepository.addVideo(video)
          : await videoRepository.updateVideo(video);

      result.fold(
        (failure) {
          errorMessage.value = failure.message;
          if (Get.context != null) {
            AppToast.showError(Get.context!, 'Gagal menyimpan video: ${failure.message}');
          }
        },
        (_) async {
          clearForm();
          await fetchVideos();
          if (Get.isDialogOpen ?? false) Get.back();
          if (Get.context != null) {
            AppToast.showSuccess(
              Get.context!,
              editingVideoId.value.isEmpty
                  ? 'Video media berhasil ditambahkan'
                  : 'Data video berhasil diperbarui',
            );
          }
        },
      );
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan: $e';
    } finally {
      isUploading.value = false;
      isLoading.value = false;
      uploadStatusMessage.value = '';
    }
  }

  Future<void> toggleFeatured(MediaVideo video) async {
    final newFeaturedStatus = !video.isFeatured;
    final updatedVideo = MediaVideo(
      id: video.id,
      title: video.title,
      youtubeUrl: video.youtubeUrl,
      thumbnailUrl: video.thumbnailUrl,
      duration: video.duration,
      category: video.category,
      speakerName: video.speakerName,
      isFeatured: newFeaturedStatus,
      orderIndex: video.orderIndex,
      updatedAt: DateTime.now(),
    );

    final result = await videoRepository.updateVideo(updatedVideo);
    result.fold(
      (failure) {
        if (Get.context != null) {
          AppToast.showError(Get.context!, 'Gagal mengubah status unggulan: ${failure.message}');
        }
      },
      (_) async {
        await fetchVideos();
        if (Get.context != null) {
          AppToast.showSuccess(
            Get.context!,
            newFeaturedStatus
                ? '"${video.title}" kini menjadi Video Utama (Featured)'
                : 'Status Video Utama dinonaktifkan',
          );
        }
      },
    );
  }

  Future<void> deleteVideo(MediaVideo video) async {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 10),
            Text('Hapus Video'),
          ],
        ),
        content: Text('Apakah Anda yakin ingin memindahkan video "${video.title}" ke Keranjang Sampah?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Get.back();
              final result = await videoRepository.deleteVideo(video.id);
              result.fold(
                (failure) {
                  if (Get.context != null) {
                    AppToast.showError(Get.context!, 'Gagal menghapus video: ${failure.message}');
                  }
                },
                (_) async {
                  await fetchVideos();
                  if (Get.context != null) {
                    AppToast.showSuccess(
                      Get.context!,
                      'Video berhasil dipindahkan ke Keranjang Sampah',
                    );
                  }
                },
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

