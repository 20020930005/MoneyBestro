import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';

import '../models/collections.dart';

class AddCollectionPage extends StatefulWidget {
  final Function(Collection) onAddCollection;

  const AddCollectionPage({super.key, required this.onAddCollection});

  @override
  State<AddCollectionPage> createState() => _AddCollectionPageState();
}

class _AddCollectionPageState extends State<AddCollectionPage> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController qpController = TextEditingController();
  final TextEditingController uqController = TextEditingController();
  final TextEditingController spController = TextEditingController();
  final TextEditingController nbController = TextEditingController();
  final TextEditingController rtController = TextEditingController();
  final TextEditingController rvController = TextEditingController();

  DateTime? selectedDate;

  Future<void> pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  bool isNumeric(String value) {
    return double.tryParse(value) != null;
  }

  String? validateAmount(String? value) {
    if (value == null || value.isEmpty) return 'Please enter an amount';
    if (!isNumeric(value)) return 'Please enter a valid number';
    return null;
  }

  // void submitForm() async {
  //   if (formKey.currentState!.validate()) {
  //     final double? amount = double.tryParse(amountController.text);
  //     if (amount == null) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Amount must be a valid number')),
  //       );
  //       return;
  //     }

  //     if (selectedDate == null) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Please select a date')),
  //       );
  //       return;
  //     }

  //     final box = await Hive.openBox<Collection>('collections');
  //     final existingCollection = box.values
  //         .where((collection) =>
  //             collection.name == nameController.text.trim() &&
  //             collection.date == DateFormat('yyyy-MM-dd').format(selectedDate!))
  //         .toList();

  //     if (existingCollection.isNotEmpty) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('This collection already exists')),
  //       );
  //       return;
  //     }

  //     final collectionData = Collection(
  //       name: nameController.text.trim(),
  //       amount: amount,
  //       qp: qpController.text.trim().isNotEmpty
  //           ? qpController.text.trim()
  //           : 'N/A',
  //       uq: uqController.text.trim().isNotEmpty
  //           ? uqController.text.trim()
  //           : 'N/A',
  //       sp: spController.text.trim().isNotEmpty
  //           ? spController.text.trim()
  //           : 'N/A',
  //       nb: nbController.text.trim().isNotEmpty
  //           ? nbController.text.trim()
  //           : 'N/A',
  //       rt: rtController.text.trim().isNotEmpty
  //           ? rtController.text.trim()
  //           : 'N/A',
  //       rv: rvController.text.trim().isNotEmpty
  //           ? rvController.text.trim()
  //           : 'N/A',
  //       date: DateFormat('yyyy-MM-dd').format(selectedDate!),
  //     );

  //     await box.add(collectionData);

  //     formKey.currentState!.reset();
  //     nameController.clear();
  //     amountController.clear();
  //     qpController.clear();
  //     uqController.clear();
  //     spController.clear();
  //     nbController.clear();
  //     rtController.clear();
  //     rvController.clear();
  //     selectedDate = null;

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Collection added successfully!')),
  //     );

  //     Navigator.pop(context);
  //   }
  // }
  void submitForm() async {
    if (formKey.currentState!.validate()) {
      final double? amount = double.tryParse(amountController.text);
      if (amount == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Amount must be a valid number')),
        );
        return;
      }

      if (selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a date')),
        );
        return;
      }

      final box = await Hive.openBox<Collection>('collections');
      final existingCollection = box.values
          .where((collection) =>
              collection.name == nameController.text.trim() &&
              collection.date == DateFormat('yyyy-MM-dd').format(selectedDate!))
          .toList();

      if (existingCollection.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This collection already exists')),
        );
        return;
      }

      final collectionData = Collection(
        name: nameController.text.trim(),
        amount: amount,
        qp: qpController.text.trim().isNotEmpty
            ? qpController.text.trim()
            : 'N/A',
        uq: uqController.text.trim().isNotEmpty
            ? uqController.text.trim()
            : 'N/A',
        sp: spController.text.trim().isNotEmpty
            ? spController.text.trim()
            : 'N/A',
        nb: nbController.text.trim().isNotEmpty
            ? nbController.text.trim()
            : 'N/A',
        rt: rtController.text.trim().isNotEmpty
            ? rtController.text.trim()
            : 'N/A',
        rv: rvController.text.trim().isNotEmpty
            ? rvController.text.trim()
            : 'N/A',
        date: DateFormat('yyyy-MM-dd').format(selectedDate!),
      );

      await box.add(collectionData);

      // Call the onAddCollection callback to update the parent state
      widget.onAddCollection(collectionData);

      // Reset form fields
      formKey.currentState!.reset();
      nameController.clear();
      amountController.clear();
      qpController.clear();
      uqController.clear();
      spController.clear();
      nbController.clear();
      rtController.clear();
      rvController.clear();
      selectedDate = null;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Collection added successfully!')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: const Text(
          'Add Collection',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: validateAmount,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: qpController,
                decoration: const InputDecoration(labelText: 'QP'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: uqController,
                decoration: const InputDecoration(labelText: 'UQ'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: spController,
                decoration: const InputDecoration(labelText: 'SP'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nbController,
                decoration: const InputDecoration(labelText: 'NB'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: rtController,
                decoration: const InputDecoration(labelText: 'RT'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: rvController,
                decoration: const InputDecoration(labelText: 'RV'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    selectedDate == null
                        ? 'No date selected'
                        : 'Selected date: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}',
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: pickDate,
                    child: const Text('Pick Date'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  onPressed: submitForm,
                  icon: const Icon(Icons.add_outlined),
                  label: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
