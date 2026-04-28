import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/design_constants.dart';
import '../providers/category_provider.dart';
// Add this import

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manage Categories'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.categories.isEmpty) {
            return const Center(child: Text('No categories found'));
          }

          return ListView.separated(
            padding: DesignConstants.screenPadding,
            itemCount: provider.categories.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: DesignConstants.spacingSm),
            itemBuilder: (context, index) {
              final category = provider.categories[index];
              return Container(
                padding: DesignConstants.paddingMd,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: DesignConstants.borderRadiusMd,
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: DesignConstants.paddingSm,
                      decoration: BoxDecoration(
                        color: category.color.withValues(alpha: 0.1),
                        borderRadius: DesignConstants.borderRadiusSm,
                      ),
                      child: Icon(
                        category.icon,
                        color: category.color,
                      ),
                    ),
                    const SizedBox(width: DesignConstants.spacingMd),
                    Expanded(
                      child: Text(
                        category.name,
                        style: AppTextStyles.bodyLarge,
                      ),
                    ),
                    Switch(
                      value: category.isEnabled,
                      onChanged: (value) {
                        provider.toggleCategoryStatus(category);
                      },
                      activeThumbColor: AppColors.primary,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-category'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
