import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../controllers/book_controller.dart';

class BookFormDialog extends StatelessWidget {
  final BookController controller;

  const BookFormDialog({super.key, required this.controller});

  String _formatPromoDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppTheme.primaryColor),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildCardContainer({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 850),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Obx(() {
          final isBusy = controller.isLoading.value || controller.isUploading.value;
          final isEditing = controller.editingBookId.value.isNotEmpty;

          return Stack(
            children: [
              Column(
                children: [
                  // Dialog Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isEditing ? LucideIcons.edit3 : LucideIcons.plusCircle,
                            color: AppTheme.primaryColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEditing ? 'Edit Informasi Buku' : 'Tambah Buku Baru',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isEditing
                                    ? 'Perbarui detail data katalog buku'
                                    : 'Isi formulir untuk menambahkan buku ke pustaka',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.x, color: AppTheme.textSecondary),
                          onPressed: isBusy ? null : () => Get.back(),
                        ),
                      ],
                    ),
                  ),

                  // Form Content (Categorized Cards)
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SECTION 1: Informasi Utama
                          _buildCardContainer(
                            children: [
                              _buildSectionHeader('Informasi Utama', LucideIcons.fileText),
                              const SizedBox(height: 16),
                              TextField(
                                controller: controller.titleController,
                                decoration: const InputDecoration(
                                  labelText: 'Judul Buku *',
                                  hintText: 'Masukkan judul lengkap buku',
                                  prefixIcon: Icon(LucideIcons.book, size: 18),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: controller.authorController,
                                decoration: const InputDecoration(
                                  labelText: 'Nama Penulis *',
                                  hintText: 'Nama lengkap penulis',
                                  prefixIcon: Icon(LucideIcons.user, size: 18),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: controller.synopsisController,
                                maxLines: 4,
                                decoration: const InputDecoration(
                                  labelText: 'Sinopsis Buku',
                                  hintText: 'Tulis ringkasan atau deskripsi buku...',
                                  alignLabelWithHint: true,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // SECTION 2: Klasifikasi & Harga
                          _buildCardContainer(
                            children: [
                              _buildSectionHeader('Klasifikasi & Harga', LucideIcons.tag),
                              const SizedBox(height: 16),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Autocomplete<String>(
                                      initialValue: TextEditingValue(
                                        text: controller.categoryController.text,
                                      ),
                                      optionsBuilder: (TextEditingValue textEditingValue) {
                                        if (textEditingValue.text.isEmpty) {
                                          return BookController.mizanCategories;
                                        }
                                        return BookController.mizanCategories.where(
                                          (String option) => option.toLowerCase().contains(
                                                textEditingValue.text.toLowerCase(),
                                              ),
                                        );
                                      },
                                      onSelected: (String selection) {
                                        controller.categoryController.text = selection;
                                      },
                                      optionsViewBuilder: (context, onSelected, options) {
                                        return Align(
                                          alignment: Alignment.topLeft,
                                          child: Material(
                                            elevation: 8,
                                            borderRadius: BorderRadius.circular(16),
                                            color: Colors.white,
                                            child: Container(
                                              width: (MediaQuery.of(context).size.width - 64).clamp(240.0, 380.0),
                                              constraints: const BoxConstraints(maxHeight: 250),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(16),
                                                border: Border.all(color: AppTheme.borderColor),
                                              ),
                                              child: ListView.builder(
                                                padding: const EdgeInsets.symmetric(vertical: 4),
                                                shrinkWrap: true,
                                                itemCount: options.length,
                                                itemBuilder: (BuildContext context, int index) {
                                                  final String option = options.elementAt(index);
                                                  return ListTile(
                                                    dense: true,
                                                    title: Text(
                                                      option,
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                    onTap: () => onSelected(option),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
                                        textController.addListener(() {
                                          controller.categoryController.text = textController.text;
                                        });
                                        return TextField(
                                          controller: textController,
                                          focusNode: focusNode,
                                          decoration: const InputDecoration(
                                            labelText: 'Kategori Buku *',
                                            hintText: 'Cari atau pilih kategori...',
                                            prefixIcon: Icon(LucideIcons.folder, size: 18),
                                            suffixIcon: Icon(LucideIcons.chevronDown, size: 18),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      controller: controller.priceController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                      decoration: const InputDecoration(
                                        labelText: 'Harga Buku',
                                        hintText: '0',
                                        prefixIcon: Padding(
                                          padding: EdgeInsets.all(12),
                                          child: Text(
                                            'Rp',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primaryColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // SECTION 3: Kurasi & Promosi
                          _buildCardContainer(
                            children: [
                              _buildSectionHeader('Kurasi & Promosi', LucideIcons.sparkles),
                              const SizedBox(height: 12),

                              // SwitchListTile: Rekomendasikan Buku Ini
                              Obx(() {
                                return SwitchListTile(
                                  value: controller.isRecommended.value,
                                  onChanged: (val) => controller.isRecommended.value = val,
                                  activeThumbColor: AppTheme.primaryColor,
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text(
                                    'Rekomendasikan Buku Ini',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                  ),
                                  subtitle: const Text(
                                    'Tampilkan lencana rekomendasi emas di katalog & aplikasi',
                                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                  ),
                                );
                              }),

                              const Divider(height: 20),

                              // SwitchListTile: Sedang Promo
                              Obx(() {
                                return SwitchListTile(
                                  value: controller.isPromo.value,
                                  onChanged: (val) {
                                    controller.isPromo.value = val;
                                    if (!val) {
                                      controller.promoPriceController.clear();
                                      controller.promoPercentageController.clear();
                                    }
                                  },
                                  activeThumbColor: Colors.redAccent,
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text(
                                    'Sedang Promo',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                  ),
                                  subtitle: const Text(
                                    'Aktifkan potongan harga khusus dan diskon persentase',
                                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                  ),
                                );
                              }),

                              // Bi-directional Promo Fields & Date Picker (Revealed when isPromo is true)
                              Obx(() {
                                if (!controller.isPromo.value) return const SizedBox.shrink();

                                final promoEndDate = controller.promoEndDate.value;

                                return Padding(
                                  padding: const EdgeInsets.only(top: 14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller: controller.promoPriceController,
                                              keyboardType: TextInputType.number,
                                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                              onChanged: controller.onPromoPriceChanged,
                                              decoration: const InputDecoration(
                                                labelText: 'Harga Promo (Rp)',
                                                hintText: 'Misal: 75000',
                                                prefixIcon: Padding(
                                                  padding: EdgeInsets.all(12),
                                                  child: Text(
                                                    'Rp',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.redAccent,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: TextFormField(
                                              controller: controller.promoPercentageController,
                                              keyboardType: TextInputType.number,
                                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                              onChanged: controller.onPromoPercentageChanged,
                                              decoration: const InputDecoration(
                                                labelText: 'Persentase Diskon (%)',
                                                hintText: 'Misal: 20',
                                                suffixIcon: Icon(LucideIcons.percent, size: 16, color: Colors.redAccent),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      InkWell(
                                        onTap: isBusy
                                            ? null
                                            : () async {
                                                final now = DateTime.now();
                                                final initial = promoEndDate ?? now;
                                                final picked = await showDatePicker(
                                                  context: context,
                                                  initialDate: initial.isBefore(now) ? now : initial,
                                                  firstDate: now,
                                                  lastDate: DateTime(now.year + 5),
                                                  builder: (context, child) {
                                                    return Theme(
                                                      data: Theme.of(context).copyWith(
                                                        colorScheme: const ColorScheme.light(
                                                          primary: AppTheme.primaryColor,
                                                          onPrimary: Colors.white,
                                                          onSurface: AppTheme.textPrimary,
                                                        ),
                                                      ),
                                                      child: child!,
                                                    );
                                                  },
                                                );
                                                if (picked != null) {
                                                  controller.promoEndDate.value = picked;
                                                }
                                              },
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          decoration: BoxDecoration(
                                            color: AppTheme.inputFillColor,
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(color: AppTheme.borderColor),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Text(
                                                      'Tanggal Berakhir Promo',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w500,
                                                        color: AppTheme.textSecondary,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      promoEndDate != null
                                                          ? _formatPromoDate(promoEndDate)
                                                          : 'Pilih Tanggal Berakhir Promo (Opsional)',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight: promoEndDate != null
                                                            ? FontWeight.w600
                                                            : FontWeight.normal,
                                                        color: promoEndDate != null
                                                            ? AppTheme.textPrimary
                                                            : AppTheme.textMuted,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  if (promoEndDate != null)
                                                    IconButton(
                                                      icon: const Icon(LucideIcons.x, size: 16, color: AppTheme.textSecondary),
                                                      onPressed: () => controller.promoEndDate.value = null,
                                                      tooltip: 'Hapus Tanggal',
                                                      padding: EdgeInsets.zero,
                                                      constraints: const BoxConstraints(),
                                                    ),
                                                  if (promoEndDate != null) const SizedBox(width: 8),
                                                  const Icon(
                                                    LucideIcons.calendar,
                                                    size: 18,
                                                    color: Colors.redAccent,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // SECTION 4: Media & Galeri
                          _buildCardContainer(
                            children: [
                              _buildSectionHeader('Media & Dokumen Galeri', LucideIcons.image),
                              const SizedBox(height: 16),

                              // Cover Image Picker Box
                              const Text(
                                'Cover Utama Buku',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Obx(() {
                                final file = controller.selectedCoverFile.value;
                                final rxCover = controller.coverUrl.value.trim();
                                final textCover = controller.coverUrlController.text.trim();
                                final existingUrl = rxCover.isNotEmpty ? rxCover : textCover;

                                Widget previewWidget;
                                if (file != null) {
                                  if (file.bytes != null) {
                                    previewWidget = Image.memory(
                                      file.bytes!,
                                      width: 75,
                                      height: 105,
                                      fit: BoxFit.cover,
                                    );
                                  } else {
                                    previewWidget = Container(
                                      width: 75,
                                      height: 105,
                                      color: AppTheme.inputFillColor,
                                      child: const Icon(LucideIcons.image, color: AppTheme.textMuted),
                                    );
                                  }
                                } else if (existingUrl.isNotEmpty) {
                                  previewWidget = CachedNetworkImage(
                                    imageUrl: existingUrl,
                                    width: 75,
                                    height: 105,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(
                                      width: 75,
                                      height: 105,
                                      color: AppTheme.inputFillColor,
                                      child: const Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      ),
                                    ),
                                    errorWidget: (_, __, ___) => Container(
                                      width: 75,
                                      height: 105,
                                      color: AppTheme.inputFillColor,
                                      child: const Icon(LucideIcons.imageOff, color: AppTheme.textMuted),
                                    ),
                                  );
                                } else {
                                  previewWidget = Container(
                                    width: 75,
                                    height: 105,
                                    color: AppTheme.inputFillColor,
                                    child: const Icon(
                                      LucideIcons.image,
                                      color: AppTheme.textMuted,
                                      size: 28,
                                    ),
                                  );
                                }

                                return Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: AppTheme.borderColor),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: previewWidget,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          OutlinedButton.icon(
                                            onPressed: isBusy ? null : () => controller.pickCoverFile(),
                                            icon: const Icon(LucideIcons.uploadCloud, size: 16),
                                            label: const Text('Pilih File Cover'),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            file != null
                                                ? 'File dipilih: ${file.name}'
                                                : (existingUrl.isNotEmpty
                                                    ? 'Cover URL tersimpan'
                                                    : 'Belum ada gambar cover dipilih'),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: (file != null || existingUrl.isNotEmpty)
                                                  ? AppTheme.primaryColor
                                                  : AppTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }),

                              const SizedBox(height: 20),
                              const Divider(),
                              const SizedBox(height: 16),

                              // Multi-Image Gallery Section
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Galeri Foto Buku (Multi-Image)',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: isBusy ? null : () => controller.pickGalleryImages(),
                                    icon: const Icon(LucideIcons.plus, size: 16),
                                    label: const Text('Tambah Foto Galeri'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              Obx(() {
                                final hasExisting = controller.existingGalleryUrls.isNotEmpty;
                                final hasSelected = controller.selectedGalleryFiles.isNotEmpty;

                                if (!hasExisting && !hasSelected) {
                                  return Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppTheme.inputFillColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Belum ada foto galeri dipilih',
                                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                }

                                return Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    // Existing URLs
                                    for (int i = 0; i < controller.existingGalleryUrls.length; i++)
                                      Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Image.network(
                                              controller.existingGalleryUrls[i],
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Container(
                                                width: 80,
                                                height: 80,
                                                color: AppTheme.inputFillColor,
                                                child: const Icon(LucideIcons.imageOff, size: 20),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 4,
                                            right: 4,
                                            child: InkWell(
                                              onTap: isBusy
                                                  ? null
                                                  : () => controller.removeExistingGalleryUrl(i),
                                              child: Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: const BoxDecoration(
                                                  color: Colors.redAccent,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  LucideIcons.x,
                                                  size: 12,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                    // Newly Selected Local Files
                                    for (int i = 0; i < controller.selectedGalleryFiles.length; i++)
                                      Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: FutureBuilder<Uint8List>(
                                              future: controller.selectedGalleryFiles[i].readAsBytes(),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  return Image.memory(
                                                    snapshot.data!,
                                                    width: 80,
                                                    height: 80,
                                                    fit: BoxFit.cover,
                                                  );
                                                }
                                                return Container(
                                                  width: 80,
                                                  height: 80,
                                                  color: AppTheme.inputFillColor,
                                                  child: const Center(
                                                    child: SizedBox(
                                                      width: 16,
                                                      height: 16,
                                                      child: CircularProgressIndicator(strokeWidth: 2),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          Positioned(
                                            top: 4,
                                            right: 4,
                                            child: InkWell(
                                              onTap: isBusy
                                                  ? null
                                                  : () => controller.removeSelectedGalleryFile(i),
                                              child: Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: const BoxDecoration(
                                                  color: Colors.redAccent,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  LucideIcons.x,
                                                  size: 12,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                );
                              }),

                              const SizedBox(height: 20),
                              const Divider(),
                              const SizedBox(height: 16),

                              // PDF Preview Section
                              const Text(
                                'Preview PDF Naskah Buku',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Obx(() {
                                final file = controller.selectedPdfFile.value;
                                final existingUrl = controller.pdfPreviewUrlController.text.trim();
                                return Row(
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: isBusy ? null : () => controller.pickPdfFile(),
                                      icon: const Icon(LucideIcons.fileText, size: 16),
                                      label: const Text('Pilih File PDF'),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        file != null
                                            ? 'File PDF: ${file.name}'
                                            : (existingUrl.isNotEmpty
                                                ? 'PDF tersimpan'
                                                : 'Belum ada PDF dipilih'),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: file != null
                                              ? AppTheme.primaryColor
                                              : AppTheme.textSecondary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // SECTION 4: Tautan Penjualan
                          _buildCardContainer(
                            children: [
                              _buildSectionHeader('Tautan Penjualan', LucideIcons.shoppingBag),
                              const SizedBox(height: 16),
                              TextField(
                                controller: controller.mizanstoreUrlController,
                                decoration: const InputDecoration(
                                  labelText: 'Link Pembelian MMU / Mizanstore',
                                  hintText: 'https://mizanstore.com/...',
                                  prefixIcon: Icon(LucideIcons.link, size: 18),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Dialog Footer Buttons
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                      border: Border(top: BorderSide(color: AppTheme.borderColor)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: isBusy ? null : () => Get.back(),
                          child: const Text('Batal'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: isBusy ? null : () => controller.saveBook(),
                          icon: const Icon(LucideIcons.check, size: 18),
                          label: Text(isEditing ? 'Simpan Perubahan' : 'Tambah Buku'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Uploading / Loading Overlay
              if (isBusy)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppTheme.softShadow,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(color: AppTheme.primaryColor),
                            const SizedBox(height: 16),
                            Text(
                              controller.uploadStatusMessage.value.isNotEmpty
                                  ? controller.uploadStatusMessage.value
                                  : 'Memproses data buku...',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}
