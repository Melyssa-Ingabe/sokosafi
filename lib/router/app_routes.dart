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
}
