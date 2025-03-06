class Login {
  final String username;
  final String date;
  final String timeIn;
  final String timeOut;
  final String cashierName;

  Login({
    required this.username,
    required this.date,
    required this.timeIn,
    required this.timeOut,
    required this.cashierName,
  });
}

class LoginData {
  static List<Login> list = [
    Login(
      username: 'cashier1',
      date: '2023-10-01',
      timeIn: '08:00 AM',
      timeOut: '04:00 PM',
      cashierName: 'John Doe',
    ),
    // Add more login records here
  ];
}
