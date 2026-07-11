import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:money_tracker_app/core/constants/colors.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';
import 'package:money_tracker_app/core/utils/helper_functions.dart';

class ReceiptAttachmentField extends StatelessWidget {
  const ReceiptAttachmentField({
    super.key,
    required this.previewPath,
    required this.onPickGallery,
    required this.onPickCamera,
    required this.onRemove,
  });

  final String? previewPath;
  final VoidCallback onPickGallery;
  final VoidCallback onPickCamera;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final isDark = MHelperFunctions.isDarkMode(context);
    final hasPreview = previewPath != null && File(previewPath!).existsSync();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photo',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: MSizes.formLabelSize,
              ),
        ),
        const SizedBox(height: MSizes.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(MSizes.md),
          decoration: BoxDecoration(
            color: isDark ? MColors.dark : MColors.light,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              if (hasPreview) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(previewPath!),
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: MSizes.sm),
              ] else
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? MColors.outline.withValues(alpha: 0.35)
                          : MColors.outline.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_outlined,
                        size: 32,
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withValues(alpha: 0.6),
                      ),
                      const SizedBox(height: MSizes.xs),
                      Text(
                        'Add a photo (optional)',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: MSizes.sm),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onPickGallery,
                      icon: const Icon(Icons.photo_library_outlined, size: 18),
                      label: const Text('Gallery'),
                    ),
                  ),
                  const SizedBox(width: MSizes.sm),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onPickCamera,
                      icon: const Icon(Icons.photo_camera_outlined, size: 18),
                      label: const Text('Camera'),
                    ),
                  ),
                ],
              ),
              if (hasPreview) ...[
                const SizedBox(height: MSizes.sm),
                TextButton.icon(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Remove photo'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

Future<String?> pickReceiptImage(ImageSource source) async {
  final picker = ImagePicker();
  final image = await picker.pickImage(
    source: source,
    maxWidth: 1920,
    imageQuality: 85,
  );
  return image?.path;
}

void openReceiptPreview(BuildContext context, String path) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => _ReceiptPreviewScreen(path: path),
    ),
  );
}

class _ReceiptPreviewScreen extends StatelessWidget {
  const _ReceiptPreviewScreen({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Photo'),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.file(File(path)),
        ),
      ),
    );
  }
}
