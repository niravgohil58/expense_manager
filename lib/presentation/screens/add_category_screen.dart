import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/category_picker_icons.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/design_constants.dart';
import '../../data/models/category_model.dart';
import '../providers/category_provider.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key, this.category});

  /// When set, screen edits this category (name / icon / color).
  final Category? category;

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  // Predefined colors
  final List<Color> _colors = [
    const Color(0xFFE57373), // Red
    const Color(0xFF64B5F6), // Blue
    const Color(0xFF81C784), // Green
    const Color(0xFFBA68C8), // Purple
    const Color(0xFF90A4AE), // Blue Grey
    const Color(0xFFFFB74D), // Orange
    const Color(0xFF4DB6AC), // Teal
    const Color(0xFFF06292), // Pink
    const Color(0xFF7986CB), // Indigo
    const Color(0xFFAED581), // Light Green
    const Color(0xFFFFD54F), // Amber
    const Color(0xFFA1887F), // Brown
  ];

  late IconData _selectedIcon;
  late Color _selectedColor;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final c = widget.category;
    if (c != null) {
      _nameController.text = c.name;
      _selectedIcon = c.icon;
      _selectedColor = c.color;
    } else {
      _selectedIcon = kCategoryPickerIcons.first;
      _selectedColor = _colors.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final provider = context.read<CategoryProvider>();
    late final bool success;
    if (widget.category != null) {
      success = await provider.updateCategoryFull(
        id: widget.category!.id,
        name: _nameController.text,
        icon: _selectedIcon,
        color: _selectedColor,
      );
    } else {
      success = await provider.addCategory(
        name: _nameController.text.trim(),
        icon: _selectedIcon,
        color: _selectedColor,
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.category != null
              ? 'Category updated'
              : 'Category added successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.error ??
                (widget.category != null
                    ? 'Failed to update category'
                    : 'Failed to add category'),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.category != null ? 'Edit Category' : 'Add Category'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: DesignConstants.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name Field
              Text('Name', style: AppTextStyles.labelMedium),
              const SizedBox(height: DesignConstants.spacingXs),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Category Name',
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: DesignConstants.borderRadiusMd,
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: DesignConstants.borderRadiusMd,
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter category name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: DesignConstants.spacingLg),

              // Icon Selection
              Text('Icon', style: AppTextStyles.labelMedium),
              const SizedBox(height: DesignConstants.spacingXs),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: DesignConstants.spacingSm,
                  mainAxisSpacing: DesignConstants.spacingSm,
                ),
                itemCount: kCategoryPickerIcons.length,
                itemBuilder: (context, index) {
                  final icon = kCategoryPickerIcons[index];
                  final isSelected = _selectedIcon == icon;
                  return InkWell(
                    onTap: () => setState(() => _selectedIcon = icon),
                    borderRadius: DesignConstants.borderRadiusSm,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.surface,
                        borderRadius: DesignConstants.borderRadiusSm,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: DesignConstants.spacingLg),

              // Color Selection
              Text('Color', style: AppTextStyles.labelMedium),
              const SizedBox(height: DesignConstants.spacingXs),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: DesignConstants.spacingSm,
                  mainAxisSpacing: DesignConstants.spacingSm,
                ),
                itemCount: _colors.length,
                itemBuilder: (context, index) {
                  final color = _colors[index];
                  final isSelected = _selectedColor == color;
                  return InkWell(
                    onTap: () => setState(() => _selectedColor = color),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: AppColors.textPrimary, width: 2)
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    ),
                  );
                },
              ),
              const SizedBox(height: DesignConstants.spacingXl),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: DesignConstants.buttonHeightLg,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveCategory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: DesignConstants.borderRadiusMd,
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textOnPrimary,
                          ),
                        )
                      : Text('Save Category', style: AppTextStyles.button),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
