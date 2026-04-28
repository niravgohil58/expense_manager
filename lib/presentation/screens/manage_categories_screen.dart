import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/design_constants.dart';
import '../providers/category_provider.dart';

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

  Future<void> _refreshCategories(BuildContext context) async {
    final categories = context.read<CategoryProvider>();
    await categories.loadCategories(showLoading: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Manage Categories'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.categories.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => _refreshCategories(context),
            child: provider.categories.isEmpty
                ? LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: const Center(
                            child: Text('No categories found'),
                          ),
                        ),
                      );
                    },
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
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
                            Expanded(
                              child: Text(
                                category.name,
                                style: AppTextStyles.bodyLarge,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Switch(
                                  value: category.isEnabled,
                                  onChanged: (value) {
                                    provider.toggleCategoryStatus(category);
                                  },
                                  activeThumbColor: AppColors.primary,
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (v) async {
                                    if (v == 'edit') {
                                      context.push('/edit-category',
                                          extra: category);
                                      return;
                                    }
                                    if (v != 'delete') return;
                                    final ok = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Delete category?'),
                                        content: Text(
                                          category.isSystem
                                              ? 'Built-in categories cannot be deleted.'
                                              : 'This cannot be undone if no expenses use it.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            style: TextButton.styleFrom(
                                              foregroundColor: AppColors.error,
                                            ),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (ok != true || !context.mounted) return;
                                    final deleted =
                                        await provider.deleteCategory(category.id);
                                    if (!context.mounted) return;
                                    if (!deleted &&
                                        provider.error != null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(provider.error!),
                                          backgroundColor: AppColors.error,
                                        ),
                                      );
                                    }
                                  },
                                  itemBuilder: (ctx) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Edit'),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      enabled: !category.isSystem,
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
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
