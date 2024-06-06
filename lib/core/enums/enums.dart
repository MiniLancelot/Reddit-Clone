enum ThemeMode {
  light,
  dark,
}

enum UserKarma {
  upvote(1),
  downvote(-1);

  final int karma;
  const UserKarma(this.karma);
}
