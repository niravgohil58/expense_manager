import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/design_constants.dart';
import '../../data/models/expense_model.dart';
import '../providers/account_provider.dart';
import '../providers/expense_provider.dart';

/// Add expense screen with form
class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  ExpenseCategory _selectedCategory = ExpenseCategory.food;
  String? _selectedAccountId;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Default to cash account
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final accounts = context.read<AccountProvider>().accounts;
      if (accounts.isNotEmpty) {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an account')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await context.read<ExpenseProvider>().addExpense(
          amount: double.parse(_amountController.text),
          category: _selectedCategory,
          accountId: _selectedAccountId!,
          date: _selectedDate,
          note: _noteController.text.isNotEmpty ? _noteController.text : null,
        );

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense added successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.read<ExpenseProvider>().error ?? 'Failed to add expense'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add Expense'),
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
              // Amount Field
              Text('Amount', style: AppTextStyles.labelMedium),
              const SizedBox(height: DesignConstants.spacingXs),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  prefixText: '${DesignConstants.currencySymbol} ',
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
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: DesignConstants.spacingLg),

              // Category Selection
              Text('Category', style: AppTextStyles.labelMedium),
              const SizedBox(height: DesignConstants.spacingXs),
              Wrap(
                spacing: DesignConstants.spacingSm,
                runSpacing: DesignConstants.spacingSm,
                children: ExpenseCategory.values.map((category) {
                  final isSelected = _selectedCategory == category;
                  return InkWell(
                    onTap: () => setState(() => _selectedCategory = category),
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
                          color: isSelected ? category.color : AppColors.border,
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
                            category.displayName,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: isSelected ? category.color : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
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
                      : Text('Save Expense', style: AppTextStyles.button),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
