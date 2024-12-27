import 'dart:convert';
import 'dart:io';

import 'package:company_studio/components/my_button.dart';
import 'package:company_studio/components/my_drawer.dart';
import 'package:company_studio/components/my_textfield.dart';
import 'package:company_studio/screens/customers_and_balance.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class Transaction {
  final String id;
  final String type; // 'borrowed' or 'paid'
  final int amount;
  final String date;

  Transaction({required this.id, required this.type, required this.amount, required this.date});
}

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {

  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _newBalanceController = TextEditingController();
  late List<String> _customers =[];
  final _formKey = GlobalKey<FormState>();
  bool _editMode = false;
  bool _isButtonDisabled = false;
  bool _isLoading = false;


  @override
  void initState() {
    super.initState();

    _getCustomerList();
    _customerNameController.addListener(_checkInput);
  }

  Future<String> _getFilePath(filename) async {
    // Get the current directory
    final directory = await getApplicationDocumentsDirectory();
    // Specify the relative path inside your project structure
    final fullPath = path.join(directory.path, 'company_studio', 'lib', 'data', filename);
    print(fullPath);
    return fullPath;
  }

  void _getCustomerList() async {
    setState(() {
      _isLoading = true; // Show the loader
    });
    final filePath = await _getFilePath('customers.json');
    File file = File(filePath);

    // Create the directory if it doesn't exist
    if ((await Directory(path.dirname(filePath)).exists())) {
      await Directory(path.dirname(filePath)).create(recursive: true);
    }

    await Future.delayed(const Duration(seconds: 1));
    List<String> customers = [];

    // Check if the file exists and read the contents
    if (await file.exists()) {
      final contents = await file.readAsString();
      if (contents.isNotEmpty) {
        // Cast the dynamic list to a List<String>
        customers = List<String>.from(json.decode(contents));
        setState(() {
          _customers = customers;
        });

      }
    }
    print('CustomerScreen --> ${_customers}');
    setState(() {
      _isLoading = false; // Hide the loader
    });
  }

  void _checkInput() {
    setState(() {
      _isButtonDisabled = _customerNameController.text.isEmpty;
    });
  }

  @override
  void dispose() {
    // Dispose of the controller when done
    _customerNameController.dispose();
    super.dispose();
  }

  Future<void> _saveCustomer(customer) async {
    final filePath = await _getFilePath('customers.json');
    final file = File(filePath);

    // Create the directory if it doesn't exist
    if (!(await Directory(path.dirname(filePath)).exists())) {
      await Directory(path.dirname(filePath)).create(recursive: true);
    }

    List<String> customers = [];

    // Check if the file exists and read the contents
    if (await file.exists()) {
      final contents = await file.readAsString();
      if (contents.isNotEmpty) {
        setState(() {
          customers = List<String>.from(json.decode(contents));
        });

      }
    }

    // Check for duplicates before adding the new vehicle


    final existingCustomerIndex = customers.indexWhere((o) => o== customer);
    if (existingCustomerIndex !=   -1) {
      // Replace the existing order
      customers[existingCustomerIndex] = customer;
    }else{
      customers.add(customer);
    }
    _editMode != _editMode;
    await file.writeAsString(json.encode(customers)).then((value)=> _customers = customers);

  }


  Future<void> _submitForm() async {

    // String? description = await getDescription(context);

    // if (description != null && description.isNotEmpty) {
    //   // Proceed to add the order with the description
    //   _descriptionController.text= description;
    //   // Add your logic here to save or process the order
    // } else {
    //   _descriptionController.text= 'No description provided';
    // }
    if (_formKey.currentState?.validate() ?? false) {
      var now = DateTime.now();
      final uuid = Uuid();
      final transaction = Transaction(id: uuid.v4(), type: "Credit", amount: int.parse(_newBalanceController.text), date: DateFormat('yyyy-MM-dd – kk:mm').format(now));
      final customer = {
        'id': uuid.v4(),
        'created_date':  DateFormat('yyyy-MM-dd – kk:mm').format(now),
        'customerName': _customerNameController.text.toUpperCase(),
        'newBalance': _newBalanceController.text,
        'transactions' : [
          transaction
        ]

      };

      await _saveCustomer(customer);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Order Recorded Successfully'),
          duration: const Duration(seconds: 1), // Automatically dismiss after 0.5 seconds
        ),
      );


      await _clearForm();
      Navigator.pop(context);
      Navigator.push(context , MaterialPageRoute(builder: (context) =>  CustomersAndBalanceScreen(),));


    }
  }

  Future<void> _clearForm() async {
    setState(() {
      _customerNameController.clear();
      _newBalanceController.clear();
    });
  }

  void _editCustomer(String vehicle) {
    print(vehicle);
    _editMode = true;
    _customerNameController.text = vehicle;


  }

  void _deleteVehicle(int index) async {

    final filePath = await _getFilePath('vehicles.json');
    final file = File(filePath);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Vehicle'),
          content: const Text('Are you sure you want to delete this vehicle?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _customers.removeAt(index);
                  file.writeAsString(json.encode(_customers));
                });
              },
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Column(
                children: [
                  const SizedBox(height: 10.0),
                  MyTextField(
                    controller: _customerNameController,
                    hintText: 'Customer Name',
                    obscureText: false,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[A-Z]'))
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  MyTextField(
                    controller: _newBalanceController,
                    hintText: 'New Balance',
                    obscureText: false,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                    ],
                    keyboardType: TextInputType.numberWithOptions(decimal: false),
                  ),
                  const SizedBox(height: 10.0),
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      :MyButton(
                    onTap: _submitForm,
                    isEnabled: _isButtonDisabled == true ? _isButtonDisabled : false,
                    text: _editMode ==false ? "Add Customer" : "Edit Customer",
                    padding: const EdgeInsets.all(10),
                  ),
                  const SizedBox(height: 20.0),
                  const Text(
                    'Customer List:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10.0),
                  SizedBox(
                    height: MediaQuery.of(context).size.height,

                    child: ListView.builder(
                      itemCount: _customers.length,
                      itemBuilder: (context, index) {
                        final vehicle = _customers[index];
                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 5,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16.0),
                            title: Text('Vehicle #${index + 1}'),
                            subtitle: Text('Number: $vehicle'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                // IconButton(
                                //   icon: const Icon(Icons.edit),
                                //   onPressed: () => _editVehicle(vehicle),
                                // ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteVehicle(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
      drawer: MyDrawer(),
    );

  }
}
