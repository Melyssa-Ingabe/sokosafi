/// Quick compliments a customer can tap on the Rate Experience screen.
enum ReviewTag {
  freshFood('Fresh food'),
  quickHandoff('Quick handoff'),
  friendlyStaff('Friendly staff'),
  generousBag('Generous bag');

  const ReviewTag(this.label);

  final String label;
}

/// The comment saved to the review. Tapped tags go first, then the
/// customer's own words
String composeReviewComment(Set<ReviewTag> tags, String note) {
  final tagText = ReviewTag.values
      .where(tags.contains)
      .map((tag) => tag.label)
      .join(', ');
  final trimmedNote = note.trim();
  if (tagText.isEmpty) return trimmedNote;
  if (trimmedNote.isEmpty) return tagText;
  return '$tagText. $trimmedNote';
}
