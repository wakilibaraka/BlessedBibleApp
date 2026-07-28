import 'dart:math' as math;

class SunsetCalculator {
  /// Calculates the sunset time for a given date and location.
  /// Returns the local DateTime of sunset.
  /// Reference: standard sunrise equation.
  static DateTime? getSunset(double lat, double lng, DateTime date) {
    // 1. first calculate the day of the year
    int N = date.difference(DateTime(date.year, 1, 1)).inDays + 1;

    // 2. convert the longitude to hour value and calculate an approximate time
    double lngHour = lng / 15.0;
    double t = N + ((18 - lngHour) / 24.0);

    // 3. calculate the Sun's mean anomaly
    double M = (0.9856 * t) - 3.289;

    // 4. calculate the Sun's true longitude
    // math.sin uses radians
    double L = M + (1.916 * math.sin(M * math.pi / 180.0)) + (0.020 * math.sin(2 * M * math.pi / 180.0)) + 282.634;
    L = L % 360.0;
    if (L < 0) L += 360.0;

    // 5a. calculate the Sun's right ascension
    double ra = (180.0 / math.pi) * math.atan(0.91764 * math.tan(L * math.pi / 180.0));
    ra = ra % 360.0;
    if (ra < 0) ra += 360.0;

    // 5b. right ascension value needs to be in the same quadrant as L
    double lQuadrant = (L / 90.0).floor() * 90.0;
    double raQuadrant = (ra / 90.0).floor() * 90.0;
    ra = ra + (lQuadrant - raQuadrant);

    // 5c. right ascension value needs to be converted into hours
    ra = ra / 15.0;

    // 6. calculate the Sun's declination
    double sinDec = 0.39782 * math.sin(L * math.pi / 180.0);
    double cosDec = math.cos(math.asin(sinDec));

    // 7a. calculate the Sun's local hour angle
    // Zenith for official sunset is 90.8333 degrees
    double zenith = 90.8333;
    double cosH = (math.cos(zenith * math.pi / 180.0) - (sinDec * math.sin(lat * math.pi / 180.0))) / (cosDec * math.cos(lat * math.pi / 180.0));

    if (cosH > 1) {
      // The sun never rises on this location (on the specified date)
      return null;
    }
    if (cosH < -1) {
      // The sun never sets on this location (on the specified date)
      return null;
    }

    // 7b. finish calculating H and convert into hours
    double H = (180.0 / math.pi) * math.acos(cosH);
    H = H / 15.0;

    // 8. calculate local mean time of rising/setting
    double T = H + ra - (0.06571 * t) - 6.622;

    // 9. adjust back to UTC
    double ut = T - lngHour;
    ut = ut % 24.0;
    if (ut < 0) ut += 24.0;

    // Convert UT (in hours) to hours and minutes
    int sunsetHour = ut.floor();
    int sunsetMinute = ((ut - sunsetHour) * 60.0).round();

    // Create UTC DateTime and convert to local time
    DateTime sunsetUtc = DateTime.utc(date.year, date.month, date.day, sunsetHour, sunsetMinute);
    return sunsetUtc.toLocal();
  }

  /// Helper to get the next occurrence of a specific day of the week (e.g., DateTime.friday)
  static DateTime getNextDayOfWeek(DateTime from, int weekday) {
    int daysUntil = (weekday - from.weekday + 7) % 7;
    // If it's today but the time has already passed, we schedule for next week.
    // We will handle time passing inside the caller.
    return from.add(Duration(days: daysUntil));
  }
}
