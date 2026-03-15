/// Instagram-style abbreviated count (e.g. 158K, 105K, 1.2M). Use for likes and send.
String formatCount(int count) {
  if (count < 1000) return count.toString();
  if (count < 1000000) {
    final k = count / 1000;
    if (k >= 100) return '${k.toInt()}K';
    if (k >= 10) return '${k.toInt()}K';
    return '${k.toStringAsFixed(1)}K';
  }
  final m = count / 1000000;
  if (m >= 10) return '${m.toInt()}M';
  return '${m.toStringAsFixed(1)}M';
}

/// Full number with comma (e.g. 1,279, 755). Use for comments and repost/share.
String formatCountWithComma(int count) {
  if (count < 1000) return count.toString();
  final str = count.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
    buffer.write(str[i]);
  }
  return buffer.toString();
}

/// Format time ago for comments (e.g. "3h", "4h", "2d").
String formatTimeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final diff = now.difference(dateTime);
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';
  if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w';
  return '${(diff.inDays / 30).floor()}mo';
}

/// Long form for post header (e.g. "1 day ago", "2 hours ago").
String formatTimeAgoLong(DateTime dateTime) {
  final now = DateTime.now();
  final diff = now.difference(dateTime);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
  if (diff.inDays < 7) return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} week${diff.inDays >= 14 ? 's' : ''} ago';
  return '${(diff.inDays / 30).floor()} month${diff.inDays >= 60 ? 's' : ''} ago';
}
