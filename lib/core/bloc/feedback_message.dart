/// A one-time message for the UI to show in a SnackBar. It is deliberately
/// not Equatable: every new instance counts as a new message, so the same
/// error twice in a row still reaches a BlocListener.
class FeedbackMessage {
  FeedbackMessage.error(this.message) : isError = true;
  FeedbackMessage.success(this.message) : isError = false;

  final String message;
  final bool isError;
}
