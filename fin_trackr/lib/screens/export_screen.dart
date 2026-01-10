import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';   
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import '../models/transaction_model.dart'; 

class ExportScreen extends StatelessWidget {
  final List<TransactionModel> filteredTransactions;

  const ExportScreen({super.key, required this.filteredTransactions});  

  Future<String> _getDownloadPath(String filename) async {
    final dir = Directory('/storage/emulated/0/Download');
    if (!await dir.exists()) await dir.create(recursive: true);
    return '${dir.path}/$filename';
  } 

  void _showMessage(BuildContext context, String msg, [Color? color]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color ?? Colors.black87,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<bool> _requestPermission(BuildContext context) async {
    if (Platform.isAndroid) {
      final version =
          int.tryParse(
            Platform.operatingSystemVersion
                .replaceAll(RegExp(r'[^0-9.]'), '')
                .split('.')
                .first,
          ) ??
          30;

      if (version >= 30) {
        final status = await Permission.manageExternalStorage.status;
        if (status.isGranted) return true;
        final result = await Permission.manageExternalStorage.request();
        if (!result.isGranted) {
          _showMessage(context, "❌ Storage permission denied", Colors.red);
          return false;
        }
        return true;
      } else {
        final status = await Permission.storage.status;
        if (status.isGranted) return true;
        final result = await Permission.storage.request();
        if (!result.isGranted) {
          _showMessage(context, "❌ Storage permission denied", Colors.red);
          return false;
        }
        return true;
      }
    }
    return true;
  }

  Future<void> _exportPDF(
    BuildContext context,
    List<TransactionModel> txns,
    String filename,
  ) async {
    if (!await _requestPermission(context)) return;

    final pdf = PdfDocument();
    final page = pdf.pages.add();
    final grid = PdfGrid();

    grid.columns.add(count: 4);
    grid.headers.add(1);
    final header = grid.headers[0];
    header.cells[0].value = 'Title';
    header.cells[1].value = 'Amount';
    header.cells[2].value = 'Type';
    header.cells[3].value = 'Date';

    for (var tx in txns) {
      final row = grid.rows.add();
      row.cells[0].value = tx.title;
      row.cells[1].value = tx.amount.toStringAsFixed(2);
      row.cells[2].value = tx.type;
      row.cells[3].value = tx.date.toLocal().toString().split(' ')[0];
    }

    grid.draw(page: page, bounds: const Rect.fromLTWH(0, 0, 500, 800));
    final bytes = await pdf.save();
    pdf.dispose();

    final path = await _getDownloadPath("$filename.pdf");
    final file = File(path);
    await file.writeAsBytes(bytes);

    _showMessage(context, "✅ PDF saved to: $path", Colors.green);
  }

  Future<void> _exportExcel(
    BuildContext context,
    List<TransactionModel> txns,
    String filename,
  ) async {
    if (!await _requestPermission(context)) return;

    final workbook = xlsio.Workbook();
    final sheet = workbook.worksheets[0];

    sheet.getRangeByName('A1').setText('Title');
    sheet.getRangeByName('B1').setText('Amount');
    sheet.getRangeByName('C1').setText('Type');
    sheet.getRangeByName('D1').setText('Date');

    for (int i = 0; i < txns.length; i++) {
      final tx = txns[i];
      sheet.getRangeByName('A${i + 2}').setText(tx.title);
      sheet.getRangeByName('B${i + 2}').setNumber(tx.amount);
      sheet.getRangeByName('C${i + 2}').setText(tx.type);
      sheet
          .getRangeByName('D${i + 2}')
          .setText(tx.date.toLocal().toString().split(' ')[0]);
    }

    final bytes = workbook.saveAsStream();
    workbook.dispose();

    final path = await _getDownloadPath("$filename.xlsx");
    final file = File(path);
    await file.writeAsBytes(bytes);

    _showMessage(context, "✅ Excel saved to: $path", Colors.green);
  }

  void _showExportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Choose Export Type",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4F46E5),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.data_usage, color: Colors.indigo),
                title: const Text("Export Regular Transactions"),
                onTap: () {
                  Navigator.pop(context);
                  _showFormatDialog(
                    context,
                    filteredTransactions,
                    "FinTrackr_Regular",
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(
                  Icons.backup_outlined,
                  color: Colors.deepPurple,
                ),
                title: const Text("Export Backup History"),
                onTap: () async {
                  Navigator.pop(context);
                  final box = await Hive.openBox<TransactionModel>(
                    'transaction_history_backup',
                  );
                  final backupData = box.values.toList();
                  _showFormatDialog(context, backupData, "FinTrackr_Backup");
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFormatDialog(
    BuildContext context,
    List<TransactionModel> data,
    String filename,
  ) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text("Select Format"),
            content: const Text(
              "Choose the format you want to export the data in.",
            ),
            actions: [
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _exportPDF(context, data, filename);
                },
                icon: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                label: const Text("PDF"),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _exportExcel(context, data, filename);
                },
                icon: const Icon(Icons.grid_on, color: Colors.green),
                label: const Text("Excel"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF6F8FF), Color(0xFFE4E8FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Container(
              height: 240,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF6D28D9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ShaderMask(
                    shaderCallback:
                        (bounds) => LinearGradient(
                          colors: [Colors.white, Color(0xFFE0E7FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                    child: const Text(
                      "📤 Export Data",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 8,
                            color: Colors.black45,
                            offset: Offset(1.5, 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 240),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.97),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.indigo.withOpacity(0.12),
                                blurRadius: 25,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "Easily export your financial records in PDF or Excel.\nChoose what you want to export.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 30),
                              ElevatedButton.icon(
                                onPressed: () => _showExportOptions(context),
                                icon: const Icon(Icons.cloud_upload_rounded),
                                label: const Text("Export Now"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4F46E5),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 36,
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  elevation: 8,
                                  shadowColor: Colors.deepPurple.withOpacity(
                                    0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
