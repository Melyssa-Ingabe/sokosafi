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

  /// A listing as the customer sees it. Pass the card's hero tag as the
  /// route's `extra` so the photo animates in.
  static const String listingDetail = '/listings/:listingId';

  static const String checkout = '/checkout/:listingId';
  static const String myOrders = '/orders';
  static const String orderDetail = '/orders/:orderId';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String settings = '/settings';

  static String listingFor(String listingId) => '/listings/$listingId';

  /// [quantity] pre-fills checkout with what was picked on the detail
  /// screen; checkout still clamps it to what is left.
  static String checkoutFor(String listingId, {int? quantity}) =>
      quantity == null
      ? '/checkout/$listingId'
      : '/checkout/$listingId?quantity=$quantity';
  static String orderFor(String orderId) => '/orders/$orderId';
}
