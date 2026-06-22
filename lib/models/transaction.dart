class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final bool isCredit; // true for credit, false for debit
  final String category;

  const Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.isCredit,
    required this.category,
  });
}
