import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/transaction_model.dart';
import '../widgets/transaction_tile.dart';    

class BackupHistoryScreen extends StatefulWidget { 
  const BackupHistoryScreen({super.key});

  @override
  State<BackupHistoryScreen> createState() => _BackupHistoryScreenState();
}

class _BackupHistoryScreenState extends State<BackupHistoryScreen> {
  late Future<Box<TransactionModel>> _backupBoxFuture;

  @override
  void initState() {
    super.initState();
    _backupBoxFuture = Hive.openBox<TransactionModel>(
      'transaction_history_backup',
    );
  }

  Future<void> _confirmResetHistory(Box<TransactionModel> backupBox) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text("Reset Backup History"),
            content: const Text(
              "Are you sure you want to permanently delete all backup history?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Yes, Delete All"),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await backupBox.clear();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Backup history cleared.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFDBF0FF), Color(0xFFE6F4FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<Box<TransactionModel>>(
          future: _backupBoxFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(
                child: Text(
                  "Oops! Failed to load backup history.",
                  style: TextStyle(color: Colors.red),
                ),
              );
            } else {
              final backupBox = snapshot.data!;
              final backups = backupBox.values.toList();
              backups.sort((a, b) => b.date.compareTo(a.date));

              return Stack(
                children: [
                  Container(
                    height: 200,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF4F46E5), Color(0xFF6D28D9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 24.0),
                          child: Center(
                            child: Text(
                              "📦 Backup History",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child:
                              backups.isEmpty
                                  ? const Center(
                                    child: Text(
                                      "No backup history found.",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(
                                          0xFF444444,
                                        ), // 🔆 Brighter text
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  )
                                  : Container(
                                    margin: const EdgeInsets.only(top: 12),
                                    padding: const EdgeInsets.only(top: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.95),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(24),
                                        topRight: Radius.circular(24),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 8,
                                          offset: const Offset(0, -4),
                                        ),
                                      ],
                                    ),
                                    child: ListView.separated(
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        10,
                                        16,
                                        100,
                                      ),
                                      itemCount: backups.length,
                                      separatorBuilder:
                                          (_, __) => const SizedBox(height: 10),
                                      itemBuilder: (context, index) {
                                        return TransactionTile(
                                          tx: backups[index],
                                        );
                                      },
                                    ),
                                  ),
                        ),
                      ],
                    ),
                  ),
                  if (backups.isNotEmpty)
                    Positioned(
                      bottom: 20,
                      left: 16,
                      right: 16,
                      child: ElevatedButton.icon(
                        onPressed: () => _confirmResetHistory(backupBox),
                        icon: const Icon(Icons.delete_forever),
                        label: const Text("Reset Backup History"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 6,
                          shadowColor: Colors.red.withOpacity(0.3),
                        ),
                      ),
                    ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
