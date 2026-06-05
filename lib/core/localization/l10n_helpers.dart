import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../data/models/category_model.dart';
import '../../data/models/account_model.dart';
import '../../data/models/udhar_model.dart';

/// Translates system category names (Food, Travel, Rent, Shopping, Other) using AppLocalizations context
String getCategoryName(BuildContext context, Category category) {
  if (category.isSystem) {
    final l10n = AppLocalizations.of(context)!;
    switch (category.id.toLowerCase()) {
      case 'food':
        return l10n.categoryFood;
      case 'travel':
        return l10n.categoryTravel;
      case 'rent':
        return l10n.categoryRent;
      case 'shopping':
        return l10n.categoryShopping;
      case 'other':
      case 'others':
        return l10n.categoryOther;
    }
  }
  return category.name;
}

/// Translates system category names from a string (Food, Travel, Rent, Shopping, Other) using AppLocalizations context
String getCategoryNameFromString(BuildContext context, String categoryName) {
  final l10n = AppLocalizations.of(context)!;
  switch (categoryName.toLowerCase()) {
    case 'food':
      return l10n.categoryFood;
    case 'travel':
      return l10n.categoryTravel;
    case 'rent':
      return l10n.categoryRent;
    case 'shopping':
      return l10n.categoryShopping;
    case 'other':
    case 'others':
      return l10n.categoryOther;
    default:
      return categoryName;
  }
}

/// Translates account type display names using AppLocalizations context
String getAccountTypeDisplayName(BuildContext context, AccountType type) {
  final l10n = AppLocalizations.of(context)!;
  switch (type) {
    case AccountType.cash:
      return l10n.accountTypeCash;
    case AccountType.bank:
      return l10n.accountTypeBank;
  }
}

/// Translates IOU type display names using AppLocalizations context
String getUdharTypeDisplayName(BuildContext context, UdharType type) {
  final l10n = AppLocalizations.of(context)!;
  switch (type) {
    case UdharType.dena:
      return l10n.udharTypeLent;
    case UdharType.lena:
      return l10n.udharTypeBorrowed;
  }
}

/// Translates IOU type short names using AppLocalizations context
String getUdharTypeShortName(BuildContext context, UdharType type) {
  final l10n = AppLocalizations.of(context)!;
  switch (type) {
    case UdharType.dena:
      return l10n.udharTypeReceivable;
    case UdharType.lena:
      return l10n.udharTypePayable;
  }
}

/// Translates IOU status display names using AppLocalizations context
String getUdharStatusDisplayName(BuildContext context, UdharStatus status) {
  final l10n = AppLocalizations.of(context)!;
  switch (status) {
    case UdharStatus.pending:
      return l10n.udharStatusPending;
    case UdharStatus.partial:
      return l10n.udharStatusPartial;
    case UdharStatus.completed:
      return l10n.udharStatusCompleted;
  }
}

/// Translates recurring frequency names using AppLocalizations context
String getFrequencyDisplayName(BuildContext context, String frequency) {
  final l10n = AppLocalizations.of(context)!;
  switch (frequency.toLowerCase()) {
    case 'weekly':
      return l10n.frequencyWeekly;
    case 'monthly':
      return l10n.frequencyMonthly;
    default:
      return frequency;
  }
}
