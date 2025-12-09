import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../data/db/app_database.dart';
import '../../data/repositories/crop_repository.dart';
import '../../services/permission_service.dart';

final _cropRepoProvider = Provider<CropRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return CropRepository(db);
});

class CropFormScreen extends ConsumerStatefulWidget {
  const CropFormScreen({super.key});

  @override
  ConsumerState<CropFormScreen> createState() => _CropFormScreenState();
}

class _CropFormScreenState extends ConsumerState<CropFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _soilTypeController = TextEditingController();
  final _soilPropertiesController = TextEditingController();
  final _leafColorController = TextEditingController();
  final _stemDescriptionController = TextEditingController();
  final _heightController = TextEditingController();
  final _notesController = TextEditingController();

  File? _selectedImage;
  bool _saving = false;
  int? _editingId;
  String? _editingExistingImagePath;

  @override
  void dispose() {
    _soilTypeController.dispose();
    _soilPropertiesController.dispose();
    _leafColorController.dispose();
    _stemDescriptionController.dispose();
    _heightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    setState(() {
      _selectedImage = File(picked.path);
    });
  }

  Future<void> _save() async {
    // Ensure we have permission to write files before proceeding.
    final permissionService = ref.read(permissionServiceProvider);
    final allowed = await permissionService.ensureStoragePermission();
    if (!allowed) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Storage permission is required to save crop photos and data.',
            ),
          ),
        );
      }
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null && _editingExistingImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image of the crop')),
      );
      return;
    }

    setState(() {
      _saving = true;
    });
    try {
      final repo = ref.read(_cropRepoProvider);
      final now = DateTime.now();

      final cropId = await repo.insertOrUpdateCropParams(
        CropParamsCompanion.insert(
          createdAt: now,
          soilType: _soilTypeController.text,
          soilProperties: _soilPropertiesController.text,
          leafColor: _leafColorController.text,
          stemDescription: _stemDescriptionController.text,
          heightCm: double.parse(_heightController.text),
          notes: drift.Value(
            _notesController.text.isEmpty ? null : _notesController.text,
          ),
        ),
        existingId: _editingId,
      );

      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(p.join(appDir.path, 'crop_images'));
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // Only create a new image entry if the user selected a new image or
      // there was no existing image.
      final shouldAddImage = _selectedImage != null &&
          _selectedImage!.path != _editingExistingImagePath;
      if (shouldAddImage) {
        // Get all existing images to determine next sequential number
        final allImages = await repo.getAllImages();
        int maxImageNumber = 0;
        for (final img in allImages) {
          // Extract number from filename like "tomato_001.jpg"
          final match =
              RegExp(r'tomato_(\d+)').firstMatch(img.relabelledFileName);
          if (match != null) {
            final num = int.tryParse(match.group(1) ?? '0') ?? 0;
            if (num > maxImageNumber) {
              maxImageNumber = num;
            }
          }
        }

        // Generate next sequential number (001, 002, etc.)
        final nextNumber = maxImageNumber + 1;
        final imageExtension = p.extension(_selectedImage!.path);
        final fileName =
            'tomato_${nextNumber.toString().padLeft(3, '0')}$imageExtension';
        final destPath = p.join(imagesDir.path, fileName);
        final savedFile = await _selectedImage!.copy(destPath);

        await repo.insertCropImage(
          CropImagesCompanion.insert(
            cropParamsId: cropId,
            filePath: savedFile.path,
            relabelledFileName: fileName,
            createdAt: now,
          ),
        );
      }

      if (!mounted) return;

      // Refresh the history list so the new set appears immediately.
      ref.invalidate(_cropHistoryProvider);

      final wasEditing = _editingId != null;

      // Clear the form fields and image.
      _formKey.currentState!.reset();
      _soilTypeController.clear();
      _soilPropertiesController.clear();
      _leafColorController.clear();
      _stemDescriptionController.clear();
      _heightController.clear();
      _notesController.clear();

      setState(() {
        _selectedImage = null;
        _editingId = null;
        _editingExistingImagePath = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wasEditing
                ? 'Tomato parameters updated'
                : 'Tomato parameters saved',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving data: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tomato Parameters'),
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.deferToChild,
          onTap: () {
            final currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
              currentFocus.unfocus();
            }
          },
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _soilTypeController,
                        decoration: const InputDecoration(
                          labelText: 'Soil type',
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _soilPropertiesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Soil properties',
                          hintText: 'Texture, drainage, organic matter, etc.',
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _leafColorController,
                        decoration: const InputDecoration(
                          labelText: 'Leaf color',
                          hintText: 'e.g. dark green, pale yellow',
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _stemDescriptionController,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Stem size (cm)',
                          hintText: 'e.g. 1.5',
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _heightController,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Plant height (cm)',
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          final value = double.tryParse(v);
                          if (value == null) return 'Enter a valid number';
                          if (value <= 0) return 'Height must be positive';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Notes (optional)',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pickImage(ImageSource.camera),
                              icon: const Icon(Icons.photo_camera),
                              label: const Text('Camera'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pickImage(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library),
                              label: const Text('Gallery'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_selectedImage != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        const Text(
                          'No image selected yet.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saving ? null : _save,
                          child: _saving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _editingId == null
                                      ? 'Save parameters'
                                      : 'Update parameters',
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _CropParamsHistorySection(
                  onEdit: _startEdit,
                  onDelete: _confirmDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _startEdit(CropParam item) async {
    _soilTypeController.text = item.soilType;
    _soilPropertiesController.text = item.soilProperties;
    _leafColorController.text = item.leafColor;
    _stemDescriptionController.text = item.stemDescription;
    _heightController.text = item.heightCm.toString();
    _notesController.text = item.notes ?? '';
    _editingId = item.id;
    _editingExistingImagePath = null;

    // Load first associated image (if any) so editing doesn't require re-pick.
    final repo = ref.read(_cropRepoProvider);
    final images = await repo.getImagesForCrop(item.id);
    if (images.isNotEmpty) {
      final file = File(images.first.filePath);
      if (await file.exists()) {
        setState(() {
          _selectedImage = file;
          _editingExistingImagePath = file.path;
        });
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Loaded set #${item.id} for editing')),
    );
  }

  Future<void> _confirmDelete(CropParam item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete parameters?'),
        content: Text(
          'This will delete tomato set #${item.id} and its images.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final repo = ref.read(_cropRepoProvider);
    await repo.deleteCropParams(item.id);
    ref.invalidate(_cropHistoryProvider);

    // If we were editing this item, clear the form.
    if (_editingId == item.id) {
      _formKey.currentState?.reset();
      _soilTypeController.clear();
      _soilPropertiesController.clear();
      _leafColorController.clear();
      _stemDescriptionController.clear();
      _heightController.clear();
      _notesController.clear();
      setState(() {
        _selectedImage = null;
        _editingId = null;
        _editingExistingImagePath = null;
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted set #${item.id}')),
      );
    }
  }
}

final _cropHistoryProvider =
    FutureProvider.autoDispose<List<CropParam>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final repo = CropRepository(db);
  return repo.getAllCropParams();
});

class _CropParamsHistorySection extends ConsumerWidget {
  const _CropParamsHistorySection({
    required this.onEdit,
    required this.onDelete,
  });

  final void Function(CropParam) onEdit;
  final void Function(CropParam) onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncHistory = ref.watch(_cropHistoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Saved parameter sets',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        asyncHistory.when(
          data: (items) {
            if (items.isEmpty) {
              return const Text('No parameter sets saved yet.');
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(
                    'Tomato set #${item.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${item.createdAt.toLocal()} • Soil: ${item.soilType}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => onEdit(item),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => onDelete(item),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(8),
            child: CircularProgressIndicator.adaptive(),
          ),
          error: (e, st) => Text('Error loading history: $e'),
        ),
      ],
    );
  }
}


