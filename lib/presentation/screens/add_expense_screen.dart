import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/ads/ads_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/design_constants.dart';
import '../../core/formatting/app_currency.dart';
import '../../data/models/expense_model.dart';
import '../providers/account_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/settings_provider.dart';

import '../providers/category_provider.dart';
import '../../data/models/category_model.dart';
// For ManageCategoriesScreen route

/// Add expense screen with form
class AddExpenseScreen extends StatefulWidget {
  final Expense? expense;

  const AddExpenseScreen({super.key, this.expense});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  Category? _selectedCategory;
  String? _selectedAccountId;
  late DateTime _selectedDate;
  bool _isLoading = false;
  String? _receiptPath;

  bool get _isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.expense?.amount.toString(),
    );
    _noteController = TextEditingController(text: widget.expense?.note);
    _selectedCategory = widget.expense?.category;
    _selectedDate = widget.expense?.date ?? DateTime.now();
    _receiptPath = widget.expense?.attachmentPath;

    // Default to cash account or existing expense account
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final accounts = context.read<AccountProvider>().accounts;
      context.read<CategoryProvider>().loadCategories(showLoading: false);

      if (widget.expense != null) {
        setState(() {
          _selectedAccountId = widget.expense!.accountId;
        });
      } else if (accounts.isNotEmpty) {
        setState(() {
          _selectedAccountId = accounts.first.id;
        });
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickReceipt() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery);
    if (x == null || !mounted) return;
    try {
      final docs = await getApplicationDocumentsDirectory();
      final dir = Directory('${docs.path}/receipts');
      await dir.create(recursive: true);
      final ext = p.extension(x.path);
      final dest = File(p.join(dir.path, '${const Uuid().v4()}$ext'));
      await File(x.path).copy(dest.path);
      setState(() => _receiptPath = dest.path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not attach image: $e')),
      );
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select an account')));
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    setState(() => _isLoading = true);

    final provider = context.read<ExpenseProvider>();
    bool success;

    if (_isEditing) {
      success = await provider.updateExpense(
        widget.expense!.copyWith(
          amount: double.parse(_amountController.text),
          category: _selectedCategory,
          accountId: _selectedAccountId!,
          date: _selectedDate,
          note: _noteController.text.isNotEmpty ? _noteController.text : null,
          attachmentPath: _receiptPath,
          clearAttachmentPath: _receiptPath == null &&
              widget.expense!.attachmentPath != null,
        ),
      );
    } else {
      success = await provider.addExpense(
        amount: double.parse(_amountController.text),
        category: _selectedCategory!,
        accountId: _selectedAccountId!,
        date: _selectedDate,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
        attachmentPath: _receiptPath,
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Expense updated successfully'
                : 'Expense added successfully',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      await context.read<AdsController>().presentInterstitialIfEligible();
      if (!mounted) return;
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.error ??
                (_isEditing
                    ? 'Failed to update expense'
                    : 'Failed to add expense'),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _deleteExpense() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      final success = await context.read<ExpenseProvider>().deleteExpense(
        widget.expense!.id,
      );
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<ExpenseProvider>().error ??
                  'Failed to delete expense',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyCode = context.watch<SettingsProvider>().currencyCode;
    final cf = AppCurrencyFormat(currencyCode);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Expense' : 'Add Expense'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        actions: [
          if (_isEditing)
            IconButton(
              onPressed: _isLoading ? null : _deleteExpense,
              icon: const Icon(Icons.delete),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: DesignConstants.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount Field
              Text('Amount', style: AppTextStyles.labelMedium),
              const SizedBox(height: DesignConstants.spacingXs),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  prefixText: cf.prefix,
                  hintText: '0.00',
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
                style: AppTextStyles.amountMedium,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickReceipt,
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Attach receipt'),
                  ),
                  if (_receiptPath != null)
                    TextButton(
                      onPressed: () => setState(() => _receiptPath = null),
                      child: const Text('Remove'),
                    ),
                ],
              ),
              if (_receiptPath != null) ...[
                const SizedBox(height: DesignConstants.spacingSm),
                ClipRRect(
                  borderRadius: DesignConstants.borderRadiusMd,
                  child: Image.file(
                    File(_receiptPath!),
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              const SizedBox(height: DesignConstants.spacingLg),

              // Category Selection
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Category', style: AppTextStyles.labelMedium),
                  TextButton(
                    onPressed: () => context.push('/manage-categories'),
                    child: const Text('Manage'),
                  ),
                ],
              ),
              const SizedBox(height: DesignConstants.spacingXs),
              Consumer<CategoryProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Use enabled categories, or if editing and current category is disabled, include it
                  final categories = provider.enabledCategories;
                  if (_isEditing &&
                      _selectedCategory != null &&
                      !categories.contains(_selectedCategory)) {
                    // Ensure the currently selected category is visible even if disabled
                    // Note: This check relies on object equality or ID equality.
                    // Since we load fresh categories, the object instance might be different.
                    // We should match by ID.
                  }

                  // Helper to check if category is in list
                  bool containsCategory(List<Category> list, Category? c) {
                    if (c == null) return false;
                    return list.any((element) => element.id == c.id);
                  }

                  // Verify specific selected category is in the list
                  if (_selectedCategory != null &&
                      !containsCategory(categories, _selectedCategory)) {
                    // It's hidden/disabled or custom.
                    // We need to display it as selected.
                    // If the provider list doesn't have it, we might need to fetch all or manually add it to display list
                    // For now, let's just use the selected instance if it's not in the list.
                    // Ideally we should use the one from the provider's full list if available
                    final fullList = provider.categories;
                    final found = fullList.firstWhere(
                      (e) => e.id == _selectedCategory!.id,
                      orElse: () => _selectedCategory!,
                    );
                    if (!containsCategory(categories, found)) {
                      categories.add(found);
                    }
                  }

                  return Wrap(
                    spacing: DesignConstants.spacingSm,
                    runSpacing: DesignConstants.spacingSm,
                    children: categories.map((category) {
                      final isSelected = _selectedCategory?.id == category.id;
                      return InkWell(
                        onTap: () =>
                            setState(() => _selectedCategory = category),
                        borderRadius: DesignConstants.borderRadiusMd,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: DesignConstants.spacingMd,
                            vertical: DesignConstants.spacingSm,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? category.color.withValues(alpha: 0.2)
                                : AppColors.surface,
                            borderRadius: DesignConstants.borderRadiusMd,
                            border: Border.all(
                              color: isSelected
                                  ? category.color
                                  : AppColors.border,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                category.icon,
                                color: category.color,
                                size: DesignConstants.iconSizeSm,
                              ),
                              const SizedBox(width: DesignConstants.spacingXs),
                              Text(
                                category.name,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: isSelected
                                      ? category.color
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: DesignConstants.spacingLg),

              // Account Selection
              Text('Payment From', style: AppTextStyles.labelMedium),
              const SizedBox(height: DesignConstants.spacingXs),
              Consumer<AccountProvider>(
                builder: (context, provider, _) {
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedAccountId,
                    decoration: InputDecoration(
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
                    items: provider.accounts.map((account) {
                      return DropdownMenuItem(
                        value: account.id,
                        child: Text(account.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedAccountId = value);
                    },
                  );
                },
              ),
              const SizedBox(height: DesignConstants.spacingLg),

              // Date Selection
              Text('Date', style: AppTextStyles.labelMedium),
              const SizedBox(height: DesignConstants.spacingXs),
              InkWell(
                onTap: _selectDate,
                borderRadius: DesignConstants.borderRadiusMd,
                child: Container(
                  width: double.infinity,
                  padding: DesignConstants.paddingMd,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: DesignConstants.borderRadiusMd,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: AppColors.primary),
                      const SizedBox(width: DesignConstants.spacingMd),
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: AppTextStyles.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: DesignConstants.spacingLg),

              // Note Field
              Text('Note (Optional)', style: AppTextStyles.labelMedium),
              const SizedBox(height: DesignConstants.spacingXs),
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Add a note...',
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
              ),
              const SizedBox(height: DesignConstants.spacingXl),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: DesignConstants.buttonHeightLg,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveExpense,
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
                      : Text(
                          _isEditing ? 'Update Expense' : 'Save Expense',
                          style: AppTextStyles.button,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
