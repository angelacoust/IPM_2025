/// Validates date format (YYYY-MM-DD) with realistic day/month checks.
/// 
/// Checks:
/// - Format is exactly YYYY-MM-DD
/// - Month is 1-12
/// - Day is valid for the given month (1-31, considering Feb 28/29 for leap years)
/// - Year is reasonable (1900-2100)
/// 
/// Returns true if valid, false otherwise.
bool isValidDateFormat(String dateStr) {
  // Regex: Check basic YYYY-MM-DD format
  final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
  if (!regex.hasMatch(dateStr)) {
    return false;
  }

  try {
    final parts = dateStr.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);

    // Year check (reasonable range)
    if (year < 1900 || year > 2100) {
      return false;
    }

    // Month check (1-12)
    if (month < 1 || month > 12) {
      return false;
    }

    // Day check (depends on month and leap year)
    int daysInMonth;
    switch (month) {
      case 1:
      case 3:
      case 5:
      case 7:
      case 8:
      case 10:
      case 12:
        daysInMonth = 31;
        break;
      case 4:
      case 6:
      case 9:
      case 11:
        daysInMonth = 30;
        break;
      case 2:
        // Check for leap year
        if (_isLeapYear(year)) {
          daysInMonth = 29;
        } else {
          daysInMonth = 28;
        }
        break;
      default:
        return false;
    }

    if (day < 1 || day > daysInMonth) {
      return false;
    }

    // Final check: try to parse as DateTime to ensure it's a valid date
    DateTime.parse(dateStr);
    return true;
  } catch (e) {
    return false;
  }
}

/// Determines if a year is a leap year.
bool _isLeapYear(int year) {
  return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
}
