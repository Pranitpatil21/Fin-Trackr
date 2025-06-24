import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel tx;

  const TransactionTile({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final isIncome = tx.type == "income";
    final color =
        isIncome ? Colors.greenAccent.shade400 : Colors.redAccent.shade400;
    final icon = isIncome ? Icons.arrow_downward : Icons.arrow_upward;

    return Semantics(
      label:
          '${tx.title}, ${isIncome ? "Income" : "Expense"}, ₹${tx.amount.toStringAsFixed(2)}, on ${tx.date.toLocal().toString().split(" ")[0]}',
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                tx.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 14, color: color),
                  const SizedBox(width: 4),
                  Text(
                    isIncome ? "Income" : "Expense",
                    style: TextStyle(fontSize: 12, color: color),
                  ),
                ],
              ),
            ),
          ],
        ),
        subtitle: Text(
          tx.date.toLocal().toString().split(" ")[0],
          style: const TextStyle(color: Colors.black54),
        ),
        trailing: Text(
          "₹${tx.amount.toStringAsFixed(2)}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isIncome ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }
}
