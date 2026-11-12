part of 'business_settings_cubit.dart';

enum BusinessSettingsStatus { loading, ready, failure }

/// A one-off message for a SnackBar. Deliberately not Equatable: every
/// message is a new object, so the same text can show twice in a row.
class SettingsFeedback {
  const SettingsFeedback.success(this.message) : isError = false;
  const SettingsFeedback.error(this.message) : isError = true;

  final String message;
  final bool isError;
}

class BusinessSettingsState extends Equatable {
  const BusinessSettingsState({
    this.status = BusinessSettingsStatus.loading,
    this.settings,
    this.payoutAccount,
    this.errorMessage,
    this.feedback,
  });

  final BusinessSettingsStatus status;
  final BusinessSettings? settings;

  /// Null while the owner's phone is loading.
  final PayoutAccount? payoutAccount;

  /// Why the settings could not load.
  final String? errorMessage;
  final SettingsFeedback? feedback;

  BusinessSettingsState copyWith({
    BusinessSettingsStatus? status,
    BusinessSettings? settings,
    PayoutAccount? payoutAccount,
    String? errorMessage,
    SettingsFeedback? feedback,
  }) {
    return BusinessSettingsState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      payoutAccount: payoutAccount ?? this.payoutAccount,
      errorMessage: errorMessage,
      // Cleared on every other change so a message only shows once.
      feedback: feedback,
    );
  }

  @override
  List<Object?> get props => [
    status,
    settings,
    payoutAccount,
    errorMessage,
    feedback,
  ];
}
