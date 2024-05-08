bool isCurrentTimeBetween(DateTime startTime, DateTime endTime) {
  DateTime currentTime = DateTime.now();
  return currentTime.isAfter(startTime) && currentTime.isBefore(endTime);
}
