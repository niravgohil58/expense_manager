import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/design_constants.dart';
import '../providers/category_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../core/localization/l10n_helpers.dart';


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
        title: Text(AppLocalizations.of(context)!.titleManageCategories),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: Consumer<CategoryProvider>(
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
                          child: Center(
                            child: Text(AppLocalizations.of(context)!.catNoCategories),
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
                          color: Theme.of(context).cardColor,
                          borderRadius: DesignConstants.borderRadiusMd,
                          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
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
                                getCategoryName(context, category),
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
                                        title: Text(AppLocalizations.of(context)!.catDeleteConfirmTitle),
                                        content: Text(
                                          category.isSystem
                                              ? AppLocalizations.of(context)!.catDeleteBuiltInError
                                              : AppLocalizations.of(context)!.catDeleteConfirmBody,
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: Text(AppLocalizations.of(context)!.commonCancel),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            style: TextButton.styleFrom(
                                              foregroundColor: AppColors.error,
                                            ),
                                            child: Text(AppLocalizations.of(context)!.commonDelete),
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
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text(AppLocalizations.of(context)!.commonEdit),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      enabled: !category.isSystem,
                                      child: Text(AppLocalizations.of(context)!.commonDelete),
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
