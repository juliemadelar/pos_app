import 'package:flutter/material.dart';

class Sale {
  final String date;
  final double amount;
  final String username;

  Sale({
    required this.date,
    required this.amount,
    required this.username,
  });
}

class SalesData {
  static List<Sale> sales = [
    Sale(date: '2025-02-01', amount: 100.0, username: 'cashier1'),
    Sale(date: '2025-02-02', amount: 150.0, username: 'cashier2'),
    // Add more sales records here
  ];

  static List<String> get usernames {
    return sales.map((sale) => sale.username).toSet().toList();
  }

  static List<Sale> getSalesByDateRange(DateTimeRange? dateRange) {
    if (dateRange == null) return [];
    return sales.where((sale) {
      DateTime saleDate = DateTime.parse(sale.date);
      return saleDate.isAfter(dateRange.start) && saleDate.isBefore(dateRange.end);
    }).toList();
  }

  static List<Sale> getSalesByUsernameAndDateRange(String? username, DateTimeRange? dateRange) {
    if (username == null || dateRange == null) return [];
    return sales.where((sale) {
      DateTime saleDate = DateTime.parse(sale.date);
      return sale.username == username &&
             saleDate.isAfter(dateRange.start) && saleDate.isBefore(dateRange.end);
    }).toList();
  }
}
