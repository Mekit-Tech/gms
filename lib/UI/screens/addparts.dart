class AddParts {
  final String partName;
  final double amount;
  final int quantity;
  final double total;

  AddParts({
    required this.partName,
    required this.amount,
    required this.quantity,
  }) : total = amount * quantity;
}
