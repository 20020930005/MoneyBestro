import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../models/transfers.dart';
import '../utils/transfer_manager.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  late TransferManager _transferManager;
  List<Transfer> _transfers = [];
  double totalTransfersAmount = 0.0;
  String searchQuery = '';
  List<Transfer> filteredTransfers = [];

  Future<void> _requestPermissions() async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Permission Denied')));
    }
  }

  @override
  void initState() {
    super.initState();
    _transferManager = TransferManager();
    _initializeTransfers();
    filteredTransfers = _transfers;
  }

  Future<void> _initializeTransfers() async {
    await _transferManager.init();
    _loadTransfers();
  }

  void _loadTransfers() {
    setState(() {
      _transfers = _transferManager.getTransfers();
      filteredTransfers = _transfers;
      totalTransfersAmount = _transfers.fold(
          0.0, (sum, transfer) => sum + (transfer.amount ?? 0.0));
    });
  }

  Future<void> _addTransfer(String name, double amount, String date) async {
    await _transferManager.addTransfer(name, amount, date);
    _loadTransfers();
  }

  Future<void> _deleteTransfer(int index) async {
    await _transferManager.deleteTransfer(index);
    _loadTransfers();
  }

  Future<void> _clearAllTransfers() async {
    await _transferManager.clearAllTransfers();
    _loadTransfers();
  }

  void _updateFilteredCollections(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredTransfers = _transfers.where((transfer) {
        final nameMatch = transfer.name.toLowerCase().contains(searchQuery);
        final amountMatch =
            transfer.amount.toString().toLowerCase().contains(searchQuery);
        final dateMatch = transfer.date.toLowerCase().contains(searchQuery);

        return nameMatch || amountMatch || dateMatch;
      }).toList();
    });
  }

  Widget _buildTextField(
      TextEditingController controller, String label, String hint,
      {bool isNumber = false, IconButton? suffixIcon}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffixIcon,
      ),
    );
  }

  void _showAddTransferDialog() {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final dateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Transfer'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(
                    nameController, 'Transfer Name', 'Enter transfer name'),
                SizedBox(height: 10),
                _buildTextField(amountController, 'Amount', 'Enter amount',
                    isNumber: true),
                SizedBox(height: 10),
                _buildTextField(
                  dateController,
                  'Date (yyyy-mm-dd)',
                  'Select transfer date',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final pickedDate = await _selectDate(context);
                      if (pickedDate != null) {
                        dateController.text =
                            '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final amount =
                    double.tryParse(amountController.text.trim()) ?? 0.0;
                final date = dateController.text.trim();

                if (name.isNotEmpty && amount > 0 && date.isNotEmpty) {
                  _addTransfer(name, amount, date);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('$name transfer added successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all fields correctly')),
                  );
                }

                Navigator.pop(context);
              },
              child: const Text('Add Transfer'),
            ),
          ],
        );
      },
    );
  }

  void _showEditTransferDialog(int index) {
    final nameController = TextEditingController(text: _transfers[index].name);
    final amountController =
        TextEditingController(text: _transfers[index].amount.toString());
    final dateController = TextEditingController(text: _transfers[index].date);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Transfer'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(
                    nameController, 'Transfer Name', 'Enter transfer name'),
                SizedBox(height: 10),
                _buildTextField(amountController, 'Amount', 'Enter amount',
                    isNumber: true),
                SizedBox(height: 10),
                _buildTextField(
                  dateController,
                  'Date (yyyy-mm-dd)',
                  'Select transfer date',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final pickedDate = await _selectDate(context);
                      if (pickedDate != null) {
                        dateController.text =
                            '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final amount =
                    double.tryParse(amountController.text.trim()) ?? 0.0;
                final date = dateController.text.trim();

                if (name.isNotEmpty && amount > 0 && date.isNotEmpty) {
                  _transferManager.updateTransfer(index, name, amount, date);
                  _loadTransfers();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('$name transfer updated successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all fields correctly')),
                  );
                }

                Navigator.pop(context);
              },
              child: const Text('Update Transfer'),
            ),
          ],
        );
      },
    );
  }

  Future<DateTime?> _selectDate(BuildContext context) async {
    final initialDate = DateTime.now();
    final firstDate = DateTime(2000);
    final lastDate = DateTime(2101);

    return await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
  }

  Future<void> _generatePDF() async {
    // Request permissions first
    await _requestPermissions();

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Monthly Collections',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10.0),
              pw.ListView.builder(
                itemCount: filteredTransfers.length,
                itemBuilder: (context, index) {
                  final collection = filteredTransfers[index];
                  return pw.Text(
                    'Date: ${collection.date}, Name: ${collection.name}, Amount: LKR ${collection.amount}',
                    style: pw.TextStyle(fontSize: 16.0),
                  );
                },
              ),
            ],
          );
        },
      ),
    );

    try {
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        final downloadsFolder = Directory('${directory.path}/Transfers');

        if (!await downloadsFolder.exists()) {
          await downloadsFolder.create(recursive: true);
        }

        String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
        final filePath = '${downloadsFolder.path}/collections_$timestamp.pdf';

        final file = File(filePath);
        await file.writeAsBytes(await pdf.save());

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('PDF saved to $filePath')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error saving PDF: $e')));
    }
  }

  void _confirmClearAllData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm'),
        content: const Text('Are you sure you want to clear all data?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              _clearAllTransfers();
              Navigator.pop(context);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: const Text(
          'Transfers',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: const InputDecoration(labelText: 'Search'),
                onChanged: (query) {
                  setState(() {
                    searchQuery = query;
                  });
                  _updateFilteredCollections(query);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Total Transfers: LKR ${totalTransfersAmount.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: _generatePDF,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Export PDF'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _confirmClearAllData,
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Clear All'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filteredTransfers.isEmpty
                  ? const Center(child: Text('No matching transfers found'))
                  : ListView.builder(
                      itemCount: filteredTransfers.length,
                      itemBuilder: (context, index) {
                        final transfer = filteredTransfers[index];
                        return Dismissible(
                          key: Key(transfer.name),
                          onDismissed: (direction) async {
                            bool confirmDelete =
                                await _showDeleteConfirmDialog();
                            if (confirmDelete) {
                              _deleteTransfer(_transfers.indexOf(transfer));
                            }
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20.0),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            elevation: 4.0,
                            child: ListTile(
                              title: Text(transfer.name),
                              subtitle: Text(
                                'Amount: LKR ${transfer.amount} \nDate: ${DateFormat.yMMMd().format(DateTime.parse(transfer.date))}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit),
                                color: Colors.orange,
                                onPressed: () => _showEditTransferDialog(
                                    _transfers.indexOf(transfer)),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransferDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<bool> _showDeleteConfirmDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Transfer'),
            content:
                const Text('Are you sure you want to delete this transfer?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class TransferSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final filteredTransfers = context
        .read<TransferManager>()
        .getTransfers()
        .where((transfer) => transfer.name.contains(query))
        .toList();

    return ListView.builder(
      itemCount: filteredTransfers.length,
      itemBuilder: (context, index) {
        final transfer = filteredTransfers[index];
        return ListTile(
          title: Text(transfer.name),
          subtitle: Text(
            'Amount: LKR ${transfer.amount} \nDate: ${DateFormat.yMMMd().format(DateTime.parse(transfer.date))}',
            style: TextStyle(color: Colors.grey[600]),
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}
