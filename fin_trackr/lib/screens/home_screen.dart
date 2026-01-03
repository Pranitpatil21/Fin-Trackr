import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart'; 
 
import '../blocs/transaction/transaction_bloc.dart'; 
import '../blocs/transaction/transaction_event.dart';
import '../blocs/transaction/transaction_state.dart';
import '../models/transaction_model.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/balance_card.dart';
import '../widgets/expense_chart.dart';
import 'add_transaction_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onThemeToggle;
  final ThemeMode? currentThemeMode;
                   
  const HomeScreen({super.key, this.onThemeToggle, this.currentThemeMode});

  Future<void> _handleReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Reset All Transactions"),
            content: const Text(
              "Are you sure you want to reset?\n\nYour current transactions will be backed up before deletion.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Yes, Reset"),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final transactionBox = Hive.box<TransactionModel>('transactions');
      final backupBox = await Hive.openBox<TransactionModel>(
        'transaction_history_backup',
      );
      for (var tx in transactionBox.values) {
        await backupBox.add(tx);
      }
      await transactionBox.clear();
      context.read<TransactionBloc>().add(LoadTransactions());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Transactions reset & backup saved."),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = currentThemeMode == ThemeMode.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: ShaderMask(
          shaderCallback:
              (bounds) => const LinearGradient(
                colors: [Color(0xFFFAFAFA), Color(0xFFB3B3FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
          child: const Text(
            "FinTrackr",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Colors.white,
            ),
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF6C63FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.wb_sunny : Icons.nightlight_round,
              color: Colors.white,
            ),
            tooltip: isDark ? "Switch to Light Mode" : "Switch to Dark Mode",
            onPressed: onThemeToggle,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: "Reset All",
            onPressed: () => _handleReset(context),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFDBF0FF), // 🌤 light sky blue
              Color(0xFFE6F4FF), // 🌥 soft fade to light
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, state) {
              if (state is TransactionLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is TransactionLoaded) {
                final transactions = state.transactions;

                if (transactions.isEmpty) {
                  return const Center(
                    child: Text(
                      "No transactions yet. Add your first!",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }

                final income = transactions
                    .where((t) => t.type == "income")
                    .fold(0.0, (sum, t) => sum + t.amount);
                final expense = transactions
                    .where((t) => t.type == "expense")
                    .fold(0.0, (sum, t) => sum + t.amount);

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                  children: [
                    _glassCard(
                      child: BalanceCard(income: income, expense: expense),
                    ),
                    const SizedBox(height: 16),
                    _glassCard(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: ExpenseChart(income: income, expense: expense),
                      ),
                    ),
                    const SizedBox(height: 28),
                    ShaderMask(
                      shaderCallback:
                          (bounds) => const LinearGradient(
                            colors: [Color(0xFF4F46E5), Color(0xFF6C63FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                      child: const Text(
                        "Recent Transactions",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...transactions.map(
                      (tx) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Dismissible(
                          key: Key(tx.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            padding: const EdgeInsets.only(right: 20),
                            alignment: Alignment.centerRight,
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (_) {
                            context.read<TransactionBloc>().add(
                              DeleteTransaction(tx.id),
                            );
                          },
                          child: TransactionTile(tx: tx),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return const Center(child: Text("Something went wrong."));
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "add_txn",
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Add Transaction"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
        },
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.97),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Padding(padding: const EdgeInsets.all(18), child: child),
    );
  }
}
