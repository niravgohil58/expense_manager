/// In-app purchase product identifiers.
abstract final class PurchaseConstants {
  /// Non-consumable product that permanently removes all ads.
  static const String removeAdsProductId = 'remove_ads';

  /// All product IDs queried from the store.
  static const Set<String> productIds = {removeAdsProductId};
}
