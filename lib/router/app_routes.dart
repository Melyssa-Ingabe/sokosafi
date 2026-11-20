/// Every route path in one place. Add your own screens here.
abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String verifyEmail = '/verify-email';
  static const String customerHome = '/customer';
  static const String businessHome = '/business';
  static const String businessSetup = '/business-setup';

  /// Opened by "Switch to business" in Settings.
  static const String switchToBusiness = '/switch-to-business';

  static const String myListings = '/business/listings';
  static const String createListing = '/business/listings/new';

  /// Pass the Listing to edit as the route's `extra`.
  static const String editListing = '/business/listings/edit';

  static const String checkout = '/checkout/:listingId';
  static const String myOrders = '/orders';
  static const String orderDetail = '/orders/:orderId';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String settings = '/settings';

  static const String businessOrders = '/business/orders';
  static const String businessAnalytics = '/business/analytics';
  static const String businessSettings = '/business/settings';
  static const String confirmPickup = '/business/confirm-pickup';
  static const String rateOrder = '/orders/:orderId/rate';

  static String checkoutFor(String listingId) => '/checkout/$listingId';
  static String orderFor(String orderId) => '/orders/$orderId';
  static String rateOrderFor(String orderId) => '/orders/$orderId/rate';
}
