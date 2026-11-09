/// Every route path in one place. Add your own screens here.
abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String verifyEmail = '/verify-email';
  static const String customerHome = '/customer';
  static const String businessHome = '/business';
  static const String switchToBusiness = '/switch-to-business';

  static const String checkout = '/checkout/:listingId';
  static const String myOrders = '/orders';
  static const String orderDetail = '/orders/:orderId';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String settings = '/settings';

  static String checkoutFor(String listingId) => '/checkout/$listingId';
  static String orderFor(String orderId) => '/orders/$orderId';
}
