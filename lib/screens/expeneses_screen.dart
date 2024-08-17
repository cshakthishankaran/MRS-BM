import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  _ExpensesScreenState createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _expenses = [];
  final DateFormat _dateFormatter = DateFormat('dd-MM-yyyy');
  DateTime? _startDate;
  DateTime? _endDate = DateTime.now();
  bool _isFiltered = false;
  bool _reportGenerated = false;
  bool _isLoading = false;
  String _filePath = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadExpenses();
  }

  Future<String> _getFilePath(String filename) async {
    final directory = await getExternalStorageDirectory();
    final fullPath = path.join(directory!.path, 'company_studio', 'lib', 'data', filename);
    print(fullPath);
    return fullPath;
  }

  Future<void> _loadExpenses() async {
    setState(() {
      _isLoading = true;
    });
    final filePath = await _getFilePath('expenses.json');
    final file = File(filePath);

    if (await file.exists()) {
      final contents = await file.readAsString();
      setState(() {
        _expenses = json.decode(contents);
      });
    }
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
    });
  }

  Future<String> _generateExcel() async {
    setState(() {
      _isLoading = true;
    });

    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Expenses'];

    List<String> headers = [
      'ID',
      'Date',
      'Category',
      'Amount',
      'Description'
    ];

    sheetObject.appendRow(headers);
    await Future.delayed(const Duration(seconds: 1));

    for (var expense in _expenses) {
      sheetObject.appendRow([
        expense['id'],
        expense['date'],
        expense['category'],
        expense['amount'],
        expense['description']
      ]);
    }

    String filename = '';
    if(_startDate == null || _endDate == null) {
      filename = 'All-Expenses.xlsx';
    } else {
      String formattedStartDate = DateFormat('d-MMM-yyyy').format(_startDate!);
      String formattedEndDate = DateFormat('d-MMM-yyyy').format(_endDate!);
      filename = '$formattedStartDate-$formattedEndDate-Expenses.xlsx';
    }

    Directory? directory = await getExternalStorageDirectory();
    String downloadPath = '${directory!.path}/Download/${filename}';
    File file = File(downloadPath);

    file.createSync(recursive: true);
    file.writeAsBytesSync(excel.save()!);

    print('Excel file downloaded to: $downloadPath');

    setState(() {
      _reportGenerated = true;
      _isLoading = false;
      _filePath = downloadPath;
    });
    return _filePath;
  }

  Future<void> _filterSearch() async {
    setState(() {
      _isLoading = true;
    });
    final filePath = await _getFilePath('expenses.json');
    final file = File(filePath);

    if (await file.exists()) {
      final contents = await file.readAsString();
      final List<dynamic> allExpenses = json.decode(contents);

      String formattedStartDate = _dateFormatter.format(_startDate!).toString();
      String formattedEndDate = _dateFormatter.format(_endDate!).toString();

      final List<dynamic> filteredExpenses = allExpenses.where((expense) {
        final expenseDate = _dateFormatter.parse(expense['date']);
        return (expenseDate.isAtSameMomentAs(_dateFormatter.parse(formattedStartDate)) || expenseDate.isAtSameMomentAs(_dateFormatter.parse(formattedEndDate))) || (
            expenseDate.isAfter(_dateFormatter.parse(formattedStartDate)) &&
                expenseDate.isBefore(_dateFormatter.parse(formattedEndDate)));
      }).toList();

      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _expenses = filteredExpenses;
        _isFiltered = true;
        _isLoading = false;
      });
    }
  }

  void _clearFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _isFiltered = false;
    });
    _loadExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Create Expense'),
            Tab(text: 'List Expenses'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Create Expense Tab
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Form for creating expenses
                Expanded(
                  child: ListView(
                    children: [
                      TextField(
                        decoration: const InputDecoration(labelText: 'Category'),
                      ),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Amount'),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Description'),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Handle expense creation logic here
                        },
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // List Expenses Tab
          Stack(
            children: [
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: _expenses.length,
                itemBuilder: (context, index) {
                  final expense = _expenses[index];
                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    elevation: 5,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      title: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${expense['id']}\n\n',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: '${expense['category']}\n',
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: '${expense['date']}\n',
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400),
                            ),
                            TextSpan(
                              text: 'Amount: ${expense['amount']}\n',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: 'Description: ${expense['description']}',
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.pushNamed(context, '/editExpense', arguments: expense);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Delete Expense'),
                                    content: const Text('Are you sure you want to delete this expense?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          setState(() {
                                            _expenses.removeAt(index);
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
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Card(
                  color: Colors.white,
                  elevation: 4.0,
                  margin: EdgeInsets.all(7.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Start Date: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _startDate != null
                                  ? _dateFormatter.format(_startDate!)
                                  : 'Not selected',
                            ),
                            IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () async {
                                final DateTime? startPicker = await showDatePicker(
                                  context: context,
                                  initialDate: _startDate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                );
                                if (startPicker != null) {
                                  setState(() {
                                    _startDate = startPicker;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'End Date: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _endDate != null
                                  ? _dateFormatter.format(_endDate!)
                                  : 'Not selected',
                            ),
                            IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () async {
                                final DateTime? endPicker = await showDatePicker(
                                  context: context,
                                  initialDate: _endDate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                );
                                if (endPicker != null) {
                                  setState(() {
                                    _endDate = endPicker;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.black,
                              ),
                              onPressed: _filterSearch,
                              child: const Text('Filter'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.black,
                              ),
                              onPressed: _clearFilter,
                              child: const Text('Clear Filter'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.black,
                              ),
                              onPressed: () async {
                                final filePath = await _generateExcel();
                                if (filePath.isNotEmpty) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Report Generated'),
                                        content: Text('The report has been generated and saved at: $filePath'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                              child: const Text('Generate Report'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
