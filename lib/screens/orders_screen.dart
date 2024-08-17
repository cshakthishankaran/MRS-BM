import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:company_studio/components/my_drawer.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<dynamic> _orders = [];
  final DateFormat _dateFormatter = DateFormat('dd-MM-yyyy');
  DateTime? _startDate;
  DateTime? _endDate = DateTime.now();
  bool _isFiltered = false;
  bool _reportGenerated = false;
  bool _emailSent = false;
  bool _isLoading = false;
  List<dynamic> _filteredSearches = [];
  String _filePath = "";
  late List<Map<String,dynamic>> _materials ;
  late List<String>  _materialsList ;


  @override
  void initState() {
    super.initState();
    _loadOrders();
    _getMaterialList();
    requestManageExternalStoragePermission();
  }


  Future<void> requestManageExternalStoragePermission() async {
    if (await Permission.manageExternalStorage.request().isGranted) {
      print('Manage External Storage permission granted');
    } else {
      print('Manage External Storage permission denied');
      await openAppSettings();
    }
  }

  void _getMaterialList() async {

    final filePath = await _getFilePath('materials.json');
    final file = File(filePath);

    // Create the directory if it doesn't exist
    if (!(await Directory(path.dirname(filePath)).exists())) {
      await Directory(path.dirname(filePath)).create(recursive: true);
    }


    List<Map<String,dynamic>> materials ;

    // Check if the file exists and read the contents
    if (await file.exists()) {
      final contents = await file.readAsString();
      if (contents.isNotEmpty) {
        // Cast the dynamic list to a List<String>
        materials = List<Map<String,dynamic>>.from(json.decode(contents));
        if (this.mounted) {
          setState(() {
            _materials = materials;
            _materialsList = _materials.map((material)=> material['material'].toString()).toList();
          });
        }
      }
    }
    print('MaterialsScreen --> ${_materials}');



  }

  Future<String> _getFilePath(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final fullPath = path.join(directory.path, 'company_studio', 'lib', 'data', filename);
    print(fullPath);
    return fullPath;
  }

  Future<String> _getDownloadFilePath(String filename) async {
    final directory = await getExternalStorageDirectory();
    final fullPath = path.join(directory!.path, 'company_studio', 'lib', 'download', filename);
    print(fullPath);
    return fullPath;
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });
    final filePath = await _getFilePath('orders.json');
    final file = File(filePath);


    if (await file.exists()) {
      final contents = await file.readAsString();
      setState(() {
        _orders = json.decode(contents);
      });
    }
    String formattedTodayDate = _dateFormatter.format(DateTime.now());
    _filteredSearches = _orders.where((order)=> order['date']==formattedTodayDate).toList();

    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
      _startDate = DateTime.now();
    });
  }



  Future<String> _generateExcel() async {
    setState(() {
      _isLoading = true;
      _emailSent = false;
    });

    var excel = Excel.createExcel();

    // Check if the sheet exists before attempting to delete it
    Sheet sheetObject = excel['Sheet1'];
    Sheet orderSheet = excel['Orders'];
    Sheet salesSheet = excel['Sales'];
    Sheet purchaseSheet = excel['Purchases'];

    excel.setDefaultSheet(orderSheet.sheetName);
    excel.unLink(sheetObject.sheetName);
    print(excel.getDefaultSheet());

    print(excel.sheets);

    // Define the headers
    List<String> orderHeaders = [
      'S.No',
      'Date',
      'Vehicle Number',
      'Customer Name',
      'Material Type',
      'Delivery Location',
      'Tonnage',
      'E-Tonnage',
      'Purchase Rate',
      'Sales Rate',
      'Rent',
      'Purchase Amount',
      'Sales Amount',
      'Comments',
      'Profits'
    ];

    List<String> salesHeaders = [
      'S.No',
      'Date',
      'Vehicle Number',
      'Customer Name',
      'Material Type',
      'Delivery Location',
      'Tonnage',
      'Sales Rate',
      'Rent',
      'Sales Amount',
    ];

    List<String> purchaseHeaders = [
      'S.No',
      'Date',
      'Vehicle Number',
      'Customer Name',
      'Material Type',
      'Delivery Location',
      'Tonnage',
      'Purchase Rate',
      'Purchase Amount',
    ];


    // Create a centered CellStyle
    var cellStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    // Add headers to the first row with center alignment
    for (int i = 0; i < orderHeaders.length; i++) {
      var cell = orderSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = orderHeaders[i];
      cell.cellStyle = cellStyle;
    }

    for (int i = 0; i < salesHeaders.length; i++) {
      var cell = salesSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = salesHeaders[i];
      cell.cellStyle = cellStyle;
    }

    for (int i = 0; i < purchaseHeaders.length; i++) {
      var cell = purchaseSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = purchaseHeaders[i];
      cell.cellStyle = cellStyle;
    }

    await Future.delayed(const Duration(seconds: 1));

    // Add orders data with center alignment
    for (var order in _filteredSearches) {
      int rowIndex = _filteredSearches.indexOf(order) + 1;

      orderSheet.appendRow([
        rowIndex,
        order['date'],
        order['vehicleNumber'],
        order['customerName'],
        order['materialType'],
        order['deliveryLocation'],
        order['tonnage'],
        order['eTonnage'],
        order['purchaseRate'],
        order['saleRate'],
        order['rent'],
        order['purchaseAmount'],
        order['saleAmount'],
        order['description'],
        calculateProfits(order['saleAmount'], order['purchaseAmount']),
      ]);

      salesSheet.appendRow([
        rowIndex,
        order['date'],
        order['vehicleNumber'],
        order['customerName'],
        order['materialType'],
        order['deliveryLocation'],
        order['eTonnage'],
        order['saleRate'],
        order['rent'],
        order['saleAmount'],

      ]);

      purchaseSheet.appendRow([
        rowIndex,
        order['date'],
        order['vehicleNumber'],
        order['customerName'],
        order['materialType'],
        order['deliveryLocation'],
        order['tonnage'],
        order['purchaseRate'],
        order['purchaseAmount'],
      ]);



      // Center-align all cells in the row
      for (int i = 0; i < orderHeaders.length; i++) {
        var cell = orderSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex));
        cell.cellStyle = cellStyle;
      }
      for (int i = 0; i < salesHeaders.length; i++) {
        var cell = salesSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex));
        cell.cellStyle = cellStyle;
      }
      for (int i = 0; i < purchaseHeaders.length; i++) {
        var cell = purchaseSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex));
        cell.cellStyle = cellStyle;
      }

    }

    // Adjust column widths based on content
    for (int i = 0; i < orderHeaders.length; i++) {
      int maxLength = orderHeaders[i].length;
      for (var row in orderSheet.rows) {
        String cellValue = row[i]?.value?.toString() ?? '';
        if (cellValue.length > maxLength) {
          maxLength = cellValue.length;
        }
      }
      orderSheet.setColWidth(i, maxLength.toDouble() + 5.0); // Adjust column width
    }

    for (int i = 0; i < salesHeaders.length; i++) {
      int maxLength = salesHeaders[i].length;
      for (var row in salesSheet.rows) {
        String cellValue = row[i]?.value?.toString() ?? '';
        if (cellValue.length > maxLength) {
          maxLength = cellValue.length;
        }
      }
      salesSheet.setColWidth(i, maxLength.toDouble() + 5.0); // Adjust column width
    }
    for (int i = 0; i < purchaseHeaders.length; i++) {
      int maxLength = purchaseHeaders[i].length;
      for (var row in purchaseSheet.rows) {
        String cellValue = row[i]?.value?.toString() ?? '';
        if (cellValue.length > maxLength) {
          maxLength = cellValue.length;
        }
      }
      purchaseSheet.setColWidth(i, maxLength.toDouble() + 5.0); // Adjust column width
    }

    // Get the path to the internal storage 'Download' directory
    Directory? directory = Directory('/storage/emulated/0/Download');
    String filename = (_startDate == null || _endDate == null)
        ? 'All-Orders.xlsx'
        : '${DateFormat('d-MMM-yyyy').format(_startDate!)}-${DateFormat('d-MMM-yyyy').format(_endDate!)}-Orders.xlsx';
    String filePath = '${directory.path}/$filename';

    // Write the Excel file to the Download folder
    File file = File(filePath);
    file.createSync(recursive: true);
    file.writeAsBytesSync(excel.save()!);

    // Open the file
    final result = await OpenFile.open(filePath);

    // Check result
    if (result.type != ResultType.done) {
      print('Failed to open file: ${result.message}');
    }

    print('Excel file saved to: $filePath');
    setState(() {
      _reportGenerated = true;
      _isLoading = false;
      _filePath = filePath;
    });

    return _filePath;
  }


  String calculateProfits(saleAmount,purchaseAmount){
    try{
      return (double.parse(saleAmount) - double.parse(purchaseAmount)).toString().split(".")[0];
    }
    catch (e) {
      print(e.toString());
      return "";
    }

  }


  int getPurchaseAmountByMaterial(String material){
    List<Map<String,dynamic>> materials = _materials;
    List<Map<String,dynamic>> materialObj = materials.where((materialItem) => materialItem['material'] == material).toList();
    if(materialObj.length>=1)
      return int.parse(materialObj[0]['price'].toString());
    else
      return 0;
  }

  String calculateSalesAmount(eTonnage,salesRate,rent) {

    print('Calculating sales amount...');
    final salesAmount = ((double.parse(eTonnage) * double.parse(salesRate))+ double.parse(rent)).toString();
    print('Sales amount: ${salesAmount}');
    return salesAmount.toString();
  }

  String calculatePurchaseAmount(tonnage,purchaseRate) {

      print('Calculating purchase amount...');
      final purchaseAmount = (double.parse(tonnage) * double.parse(purchaseRate.toString())).toString();
      print('Purchase amount: ${purchaseAmount}');
      return purchaseAmount.toString();

  }


  Future<void> _downloadFile(String filePath) async {
    // On Android, use the file path for download.
    if (Platform.isAndroid) {
      final downloadPath = _getDownloadFilePath("orders.xlsx");
      final File newFile = File(downloadPath as String);

      await newFile.writeAsBytes(File(filePath).readAsBytesSync());
      print('Excel file downloaded to: $downloadPath');
    }
  }

  Future<void> _sendEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Show loading indicator
    setState(() {
      _isLoading = true;
      _reportGenerated = false;

    });

    // Generate the Excel file and get the file path
    String filePath = await _generateExcel();

    // Get username from SharedPreferences
    String userName = prefs.getString('username') ?? '';

    // Check if startDate, endDate, and filePath are valid
    if ( (_startDate==null && _endDate == null) || filePath.isEmpty) {
      print('Required data is missing.');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Format dates
    String formattedStartDate = _startDate != null
        ? DateFormat('d-MMM-yyyy').format(_startDate!)
        : 'All Time';
    String formattedEndDate = _endDate != null
        ? DateFormat('d-MMM-yyyy').format(_endDate!)
        : 'Till Today';

    // Configure the SMTP server
    final smtpServer = gmail('mrsbmorders@gmail.com', 'tuxonhtfeuvbrkvy'); // Use actual credentials here

    try {
      // Create the email message
      final message = Message()
        ..from = const Address('mrsbmorders@gmail.com', 'Admin') // Use your email here
        ..recipients.add('mrsbmorders@gmail.com')
        ..ccRecipients.add('mrsbmorders@gmail.com')// Replace with actual recipient
        ..subject = 'Excel Order Report - ${filePath.split("/").last.replaceAll(".xlsx", "")}'
        ..text = ''
        ..html = generateEmailBody(userName, formattedStartDate, formattedEndDate);

      // Attach the generated Excel file
      message.attachments.add(FileAttachment(File(filePath)));

      // Send the email
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
      setState(() {
        _emailSent = true;
      });
    } catch (e) {
      setState(() {
        _emailSent = false;
      });
      print('Message not sent.');
      print(e);
    } finally {
      // Hide loading indicator
      setState(() {
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
    _loadOrders();
  }

  Future<void> _filterSearch() async {
    setState(() {
      _isLoading = true;
      _emailSent = false;
    });
    final filePath = await _getFilePath('orders.json');
    final file = File(filePath);

    if (await file.exists()) {
      final contents = await file.readAsString();
      final List<dynamic> allOrders = json.decode(contents);

      // Format the start and end dates
      String formattedStartDate = _dateFormatter.format(_startDate!).toString();
      String formattedEndDate = _dateFormatter.format(_endDate!).toString();

      // Filter orders based on the date range
      _filteredSearches = allOrders.where((order) {
        final orderDate = _dateFormatter.parse(order['date']);
        return (orderDate.isAtSameMomentAs(_dateFormatter.parse(formattedStartDate)) || orderDate.isAtSameMomentAs(_dateFormatter.parse(formattedEndDate))) || (
            orderDate.isAfter(_dateFormatter.parse(formattedStartDate)) &&
            orderDate.isBefore(_dateFormatter.parse(formattedEndDate)));
      }).toList();

      await Future.delayed(const Duration(seconds: 1));

      // Update the state with filtered orders
      setState(() {

        _filteredSearches.sort((a, b) {
          DateTime dateA = _dateFormatter.parse(a['date']);
          DateTime dateB = _dateFormatter.parse(b['date']);
          return dateA.compareTo(dateB);
        });

        _isFiltered = true;
        _isLoading = false;
        if(_filteredSearches.isEmpty){
          _reportGenerated = false;
          _isFiltered = true;
        }
      });
    }

  }



  Future<void> deleteOrder (int index) async{

    var order_item = _filteredSearches[index];
    _orders.removeWhere((order)=> order['id']==order_item['id']);
    _filteredSearches.removeAt(index);
    final filePath = await _getFilePath('orders.json');
    final file = File(filePath);


    if (await file.exists()) {
      await file.writeAsString(json.encode(_orders));
      }
    }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('All Recorded Orders', style: TextStyle(color: Colors.black,fontWeight: FontWeight.w600,)),
      //   backgroundColor: Colors.white,
      // ),
      body: Stack(
        children: [
          _isLoading && _reportGenerated==false ?
          Center(child: CircularProgressIndicator())
              : Padding(
            padding: const EdgeInsets.fromLTRB(0,250,0,10),
            child:  ListView.builder(
              itemCount: _filteredSearches.length,
              itemBuilder: (context, index) {
                final order = _filteredSearches[index];
                return Card(

                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  elevation: 5,
                  child:
                   ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '# ${index+1}\n\n',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: '${order['customerName']}\n',
                            style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: '${order['date']}\n',
                            style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.w400),
                          ),
                          TextSpan(
                            text: '${order['vehicleNumber']}\n',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w900
                            ),
                          ),
                          TextSpan(
                            text: '${order['materialType']} - T (${order['tonnage']}) - eT (${order['eTonnage']})',
                            style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                ),
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
                            Navigator.pushNamed(context, '/home', arguments: order);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Delete Order'),
                                  content: const Text('Are you sure you want to delete this order?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        setState(() {
                                          deleteOrder(index);
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
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row (
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(width:0.0),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.yellow, // Set the background color to yellow
                              foregroundColor: Colors.black,  // Set the text color to black
                            ),
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
                        } , child: _startDate!=null ? Text(_dateFormatter.format(_startDate!).toString().split(' ')[0]) : const Text("Start Date")),
                        SizedBox(width: 60.0),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.yellow, // Set the background color to yellow
                              foregroundColor: Colors.black,  // Set the text color to black
                            ),onPressed: () async {
                          final DateTime? endPicker = await showDatePicker(
                            context: context,
                            initialDate: _endDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (endPicker != null) {
                            setState(() {
                              _endDate = endPicker;
                            });
                          }
                        } , child: _endDate !=null ? Text(_dateFormatter.format(_endDate!).toString().split(' ')[0]) : const Text("End Date")),

                      ],
                    ),

                    SizedBox(height: 16.0),
                    Row
                      (
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.resolveWith<Color?>(
                                  (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed))
                                  return Colors.green;
                                return Colors.green;
                              },
                            ),
                            foregroundColor:
                            MaterialStateProperty.resolveWith<Color?>(
                                  (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed))
                                  return Colors.white;
                                return Colors.white;
                              },
                            ),
                          ),
                          onPressed: _generateExcel,
                          child: Icon(
                            Icons.file_download,
                          ),
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.resolveWith<Color?>(
                                  (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed))
                                  return Colors.red;
                                return Colors.redAccent;
                              },
                            ),
                            foregroundColor:
                            MaterialStateProperty.resolveWith<Color?>(
                                  (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed))
                                  return Colors.white;
                                return Colors.white;
                              },
                            ),
                          ),
                          onPressed: _sendEmail,
                          child: Icon(
                            Icons.email,
                            color: Colors.white,
                          ),
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.resolveWith<Color?>(
                                  (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed))
                                  return Colors.green;
                                return Colors.brown;
                              },
                            ),
                            foregroundColor:
                            MaterialStateProperty.resolveWith<Color?>(
                                  (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed))
                                  return Colors.white;
                                return Colors.white;
                              },
                            ),
                          ),
                          onPressed:
                               _filterSearch,

                          child: Icon(

                                Icons.filter_alt

                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25.0),
                    if (_isFiltered ==true && _reportGenerated==false)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          'Filtered for ${_dateFormatter.format(_startDate!).toString().split(' ')[0]} to ${_dateFormatter.format(_endDate!).toString().split(' ')[0]}',
                          style: TextStyle(color: Colors.brown,fontWeight: FontWeight.bold),
                        ),
                      ),
                    if (_isFiltered ==true && _reportGenerated==true)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          'Generated for ${_dateFormatter.format(_startDate!).toString().split(' ')[0]} to ${_dateFormatter.format(_endDate!).toString().split(' ')[0]}',
                          style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold),
                        ),
                      ),
                    if (_isFiltered ==false && _reportGenerated==true)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          'Generated for all recorded orders',
                          style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold),
                        ),
                      ),
                    if (_emailSent)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          'Email sent Successfully',
                          style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
                        ),
                      ),
                    if(_filteredSearches.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          '${_filteredSearches.length} Orders',
                          style: TextStyle(color: Colors.deepPurple,fontWeight: FontWeight.bold,fontSize: 18),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // drawer: const MyDrawer(),
    );
  }
}


String generateEmailBody(String userName, String startDate, String endDate) {
  return '''
<!DOCTYPE html>
<html>
<head>
  <style>
    body {
      font-family: Arial, sans-serif;
      line-height: 1.6;
      margin: 0;
      padding: 0;
      color: #333;
    }
    .container {
      width: 80%;
      margin: auto;
      padding: 20px;
    }
    .header {
      background-color: #f4f4f4;
      padding: 10px;
      text-align: center;
      border-bottom: 2px solid #e0e0e0;
    }
    .content {
      margin: 20px 0;
    }
    .footer {
      font-size: 0.8em;
      color: #888;
      text-align: center;
      margin: 20px 0;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>Greetings!</h1>
    </div>
    <div class="content">
      <p>Dear $userName,</p>
      <p>We are pleased to send you the attached report for the period of $startDate to $endDate. Please review the document at your convenience.</p>
      <p>If you have any questions or need further assistance, feel free to reach out to us through the appropriate channels.</p>
    </div>
    <div class="footer">
      <p>Please do not reply to this email address. For any inquiries or support, please contact our support team directly.</p>
    </div>
  </div>
</body>
</html>
''';
}
