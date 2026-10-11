import '../models/countdown.dart';

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String formatWhen(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '${dateTime.day} ${_months[dateTime.month - 1]}, $hour:$minute';
}

String formatDate(DateTime dateTime) {
  return '${dateTime.day} ${_months[dateTime.month - 1]}';
}

String formatClock(int hour, int minute) {
  final hours = hour.toString().padLeft(2, '0');
  final minutes = minute.toString().padLeft(2, '0');
  return '$hours:$minutes';
}

String formatCountdown(Countdown countdown) => switch (countdown) {
  Upcoming(:final remaining) => 'in ${_span(remaining)}',
  Started() => 'Live',
  Ended() => 'Ended',
};

String _span(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final hours = duration.inHours;
  if (hours >= 48) {
    return '${duration.inDays}d ${hours.remainder(24)}h';
  }
  if (hours > 0) {
    return '${hours}h ${minutes}m';
  }
  return '${minutes}m';
}
