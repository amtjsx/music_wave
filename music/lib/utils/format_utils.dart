class FormatUtils {
  static String formatDuration(double value) {
    // Convert slider value to time format
    final int seconds = (value / 100 * 200).round();
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
