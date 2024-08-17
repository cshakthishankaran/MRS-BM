  import 'package:company_studio/components/my_button.dart';
  import 'package:company_studio/components/my_drawer.dart';
  import 'package:company_studio/components/my_textfield.dart';
import 'package:company_studio/file_service.dart';
import 'package:company_studio/screens/orders_and_new_order.dart';
  import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
  import 'package:uuid/uuid.dart';
  import 'package:path_provider/path_provider.dart';
  import 'dart:convert';
  import 'dart:io';
  import 'package:flutter/services.dart';
  import 'package:path/path.dart' as path;
  import 'package:intl/src/intl/date_format.dart';


  class HomeScreen extends StatefulWidget {
    @override
    _HomeScreenState createState() => _HomeScreenState();
  }

  class _HomeScreenState extends State<HomeScreen> {
    final _formKey = GlobalKey<FormState>();
    final fileService = FileService();
    final DateFormat _dateFormatter = DateFormat('dd-MM-yyyy');
    final TextEditingController _customerNameController = TextEditingController();
    final TextEditingController _dateController = TextEditingController();
    final TextEditingController _tonnageController = TextEditingController();
    final TextEditingController _eTonnageController = TextEditingController();
    final TextEditingController _deliveryLocationController = TextEditingController();
    final TextEditingController _saleRateController = TextEditingController();
    final TextEditingController _purchaseRateController = TextEditingController();
    final TextEditingController _saleAmountController = TextEditingController();
    final TextEditingController _purchaseAmountController = TextEditingController();
    final TextEditingController _rentController = TextEditingController();
    final TextEditingController _descriptionController = TextEditingController();
    final FocusNode _tonnageFocusNode = FocusNode();
    final FocusNode _eTonnageFocusNode = FocusNode();
    late List<Map<String,dynamic>> _materials;
    late List<String> _materialsList =[];
    late bool _orderSubmitted ;
    late List<String> _vehicles =[];
    String? _selectedMaterial;
    Map<String, dynamic>? _order;
    String? _selectedVehicle;
    // final Map<String,List<String>> allFormHistoryItems ;

    @override
    void didChangeDependencies() {
      super.didChangeDependencies();

      // Retrieve the passed order argument
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments   != null && _order==null) {
        setState(() {
          _order = arguments as Map<String, dynamic>;
          _getVehicleList();
          _getMaterialList();
          editOrder(_order!);


        });
      }
    }
    @override
    void initState() {
      super.initState();
      fileService.backupFiles();
      _dateController.text = _dateFormatter.format(DateTime.now()).toString().split(' ')[0];
      _materialsList = [];
      _orderSubmitted = false;
      _getVehicleList();
      _getMaterialList();

      _tonnageFocusNode.addListener(() {
        if (!_tonnageFocusNode.hasFocus) {
          _formatTonnageValue();
        }
      });

      _eTonnageFocusNode.addListener(() {
        if (!_eTonnageFocusNode.hasFocus) {
          _formatETonnageValue();
        }
      });

    }

    void _formatTonnageValue() {
      String text = _tonnageController.text.replaceAll('.', '');
      if (text.length >= 4) {
        String formattedText = text.substring(0, text.length - 3) +
            '.' +
            text.substring(text.length - 3);
        _tonnageController.text = formattedText;
      }
    }

    void _formatETonnageValue() {
      String text = _eTonnageController.text.replaceAll('.', '');
      if (text.length >= 4) {
        String formattedText = text.substring(0, text.length - 3) +
            '.' +
            text.substring(text.length - 3);
        _eTonnageController.text = formattedText;
      }
    }

    // void _getVehicles() async{

    @override
    void dispose() {
      _tonnageFocusNode.dispose();
      _eTonnageFocusNode.dispose();
      super.dispose();
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


    int getPurchaseAmountByMaterial(String material){
      List<Map<String,dynamic>> materials = _materials;
      List<Map<String,dynamic>> materialObj = materials.where((materialItem) => materialItem['material'] == material).toList();
      if(materialObj.length>=1)
        return int.parse(materialObj[0]['price'].toString());
      else
        return 0;
    }


    void editOrder(Map<String,dynamic>order){
      _selectedVehicle = order['vehicleNumber'];
      _customerNameController.text = order['customerName'];
      _dateController.text = order['date'];
      _selectedMaterial = order['materialType'] ;
      _deliveryLocationController.text = order['deliveryLocation'];
      _tonnageController.text = order['tonnage'] ?? 0.000;
      _eTonnageController.text = order['eTonnage'] ?? 0.000;
      _saleRateController.text = order['saleRate'];
      _purchaseRateController.text =order['purchaseRate'];
      _saleAmountController.text = order['saleAmount'];
      _purchaseAmountController.text = order['purchaseAmount'];
      _rentController.text = order['rent'] ?? 0;
      _descriptionController.text = order.containsKey('description') ? order['description'] : "";
      setState(() {
        _order = order;
      });

    }
    //   SharedPreferences prefs = await SharedPreferences.getInstance();
    //   List<String> vehicles = [];
    //   if(prefs.getStringList("vehicles")!=null) {
    //     List<String>? vehicles = prefs.getStringList("vehicles");
    //   }
    //   vehicles.add(.text);
    //   prefs.setStringList("vehicles", vehicles);
    //   _vehicles =vehicles;
    // }
    void _getVehicleList() async {
      final filePath = await _getFilePath('vehicles.json');
      final file = File(filePath);

      // Create the directory if it doesn't exist
      if (!(await Directory(path.dirname(filePath)).exists())) {
        await Directory(path.dirname(filePath)).create(recursive: true);
      }

      List<String> vehicles = [];

      // Check if the file exists and read the contents
      if (await file.exists()) {
        final contents = await file.readAsString();
        if (contents.isNotEmpty) {
          // Cast the dynamic list to a List<String>
          vehicles = List<String>.from(json.decode(contents));
          setState(() {
            _vehicles = vehicles;
          });

        }
      }
      print('HomeScreen --> ${_vehicles}');

    }






    Future<String> _getFilePath(filename) async {
      // Get the current directory
      final directory = await getApplicationDocumentsDirectory();
      // Specify the relative path inside your project structure
      final fullPath = path.join(directory.path, 'company_studio', 'lib', 'data', filename);
      print(fullPath);
      return fullPath;
    }

    // String _getFilePath(String filename) {
    //   // Get the current directory synchronously
    //   final directory = Directory('/path/to/external/storage'); // Replace with the actual path
    //   // Specify the relative path inside your project structure
    //   final fullPath = path.join(directory.path, 'company_studio', 'lib', 'data', filename);
    //   print(fullPath);
    //   return fullPath;
    // }

    Future<void> _saveOrder(Map<String, dynamic> order) async {
      final filePath = await _getFilePath('orders.json');
      final file = File(filePath);

      // Create the directory if it doesn't exist
      if (!(await Directory(path.dirname(filePath)).exists())) {
        await Directory(path.dirname(filePath)).create(recursive: true);
      }

      List<dynamic> orders = [];

      // Check if the file exists and read the contents
      if (await file.exists()) {
        final contents = await file.readAsString();
        if (contents.isNotEmpty) {
          orders = json.decode(contents);
        }
      }else{

      }

      // Add the new order and save the file
      if(_order!=null){
        final existingOrderIndex = orders.indexWhere((o) => o['id'] == _order?['id']);
        if (existingOrderIndex != -1) {
          // Replace the existing order
          orders[existingOrderIndex] = order;
        }else{
          orders.add(order);
        }
      }else{
        orders.add(order);
      }

      await file.writeAsString(json.encode(orders));
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
        final uuid = Uuid();
        final order = {
          'id': uuid.v4(),
          'date': _dateController.text,
          'vehicleNumber': _selectedVehicle,
          'customerName': _customerNameController.text.toUpperCase(),
          'materialType': _selectedMaterial,
          'deliveryLocation': _deliveryLocationController.text.toUpperCase(),
          'tonnage': _tonnageController.text,
          'eTonnage': _eTonnageController.text,
          'saleRate': _saleRateController.text,
          'purchaseRate': _purchaseRateController.text,
          'saleAmount': _saleAmountController.text,
          'purchaseAmount': _purchaseAmountController.text,
          'rent': _rentController.text,
          'description' : _descriptionController.text
        };

        await _saveOrder(order);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Order Recorded Successfully'),
            duration: const Duration(seconds: 1), // Automatically dismiss after 0.5 seconds
          ),
        );


        await _clearForm();
        Navigator.pop(context);
        Navigator.push(context , MaterialPageRoute(builder: (context) =>  OrdersAndNewOrderScreen(),));


      }
    }

    Future<String?> getDescription(BuildContext context) async {

      return await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Add Order Description'),
            content: TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter order description here',
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(null); // Dismiss the dialog without returning a value
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(_descriptionController.text); // Return the description
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      );
    }

    Future<void> _clearForm() async {
      setState(() {
        _customerNameController.clear();
        _dateController.text = _dateFormatter.format(DateTime.now()).toString().split(' ')[0];
        _tonnageController.clear();
        _eTonnageController.clear();
        _deliveryLocationController.clear();
        _saleRateController.clear();
        _purchaseRateController.clear();
        _saleAmountController.clear();
        _purchaseAmountController.clear();
        _rentController.clear();
        _selectedVehicle = null;
        _selectedMaterial = null;
        _descriptionController.clear();
        _order=null;
      });
    }

    void calculateSalesAmount() {
      setState(() {
        print('Calculating sales amount...');
        if(!(_rentController.text.isEmpty || _eTonnageController.text.isEmpty || _saleRateController.text.isEmpty)){
          _saleAmountController.text = int.parse(((double.parse(_eTonnageController.text) * double.parse(_saleRateController.text)) + double.parse(_rentController.text)).toString().split(".")[0]).toString();
          print('Sales amount: ${_saleAmountController.text}');
        }

      });
    }

    void calculatePurchaseAmount() {
      setState(() {
        print('Calculating purchase amount...');
        if(!(_tonnageController.text.isEmpty || _purchaseRateController.text.isEmpty)) {
          _purchaseAmountController.text = int.parse(
              (double.parse(_tonnageController.text) *
                  double.parse(_purchaseRateController.text)).toString().split(".")[0]).toString();
          print('Purchase amount: ${_purchaseAmountController.text}');
        }
      });
    }

    void onMaterialSelection(String materialName){

      final material = _materials.where((material) => material['material'] == materialName).toList();

      setState(() {
        _purchaseRateController.text = material[0]['price'];
      });

    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.white,
        // appBar: AppBar(
        //   title: const Text(
        //     'Fill Order Details',
        //     style: TextStyle(
        //       fontWeight: FontWeight.w600,
        //     ),
        //   ),
        //
        //   backgroundColor: Colors.white,
        //
        //
        // ),


        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // if()
                // Padding(padding: EdgeInsets.symmetric(horizontal:5),
                //   child:
                //   Expanded(
                //     child: Padding(
                //       padding: const EdgeInsets.only(bottom: 15.0),
                //       child: Text(
                //         'Order ${_order == null ? "Added" : "Saved"} Successfully',
                //         style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
                //       ),
                //     ),
                //   ),
                // ),
                const SizedBox(height: 20.0),
                Row(
                  children: [


                    Expanded(
                      child: MyTextField(
                        controller: _dateController,
                        hintText: 'Date',
                        obscureText: false,

                        textCapitalization: TextCapitalization.none,
                        inputFormatters: [],
                        keyboardType: TextInputType.datetime,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              _dateController.text = _dateFormatter.format(pickedDate).toString().split(' ')[0];
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10.0), // Add space between the fields
                    Expanded(
                      child: MyTextField(
                        controller: TextEditingController(), // Dummy controller
                        hintText: 'Vehicle Number',
                        obscureText: false,
                        isDropdown: true,
                        dropdownItems: _vehicles,
                        selectedItem: _selectedVehicle,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedVehicle = newValue;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
                MyTextField(
                  controller: _customerNameController,
                  hintText: 'Customer Name',
                  obscureText: false,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[A-Z ]'))],
                ),
                const SizedBox(height: 10.0),
                Row(
                  children: [
                    Expanded(child: MyTextField(
                      controller: TextEditingController(), // Dummy controller
                      hintText: 'Material Type',
                      obscureText: false,
                      isDropdown: true,
                      dropdownItems: _materialsList,
                      selectedItem: _selectedMaterial,
                      onChanged: (newValue) {

                        setState(() {
                          _selectedMaterial = newValue;
                        });
                        onMaterialSelection(newValue!);
                      },
                    ),),
                    const SizedBox(width: 10,),
                    Expanded(child: MyTextField(
                      controller: _rentController,
                      hintText: 'Rent',
                      obscureText: false,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                      ],
                      onChanged: (newValue) {
                        calculateSalesAmount();
                      },
                      keyboardType: TextInputType.numberWithOptions(decimal: false),

                    ),)
                  ],
                ),

                const SizedBox(height: 10.0),
                MyTextField(
                  controller: _deliveryLocationController,
                  hintText: 'Delivery Location',
                  obscureText: false,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[A-Z0-9 ]'))],
                ),
                const SizedBox(height: 10.0),
                Row(
                  children: [

                    Expanded(
                      child: MyTextField(
                        controller: _tonnageController,
                        hintText: 'Tonnage',
                        obscureText: false,
                        textCapitalization: TextCapitalization.characters,
                        // focusNode: _tonnageFocusNode,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                          // DecimalTextInputFormatter(decimalRange: 3),
                          // AutoDecimalTextInputFormatter(decimalRange: 3),
                        ],
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        onChanged: (newValue){

                          calculatePurchaseAmount();
                        },
                      ),
                    ),
                    const SizedBox(width: 10.0), // Add space between the fields
                    Expanded(
                      child: MyTextField(
                        controller: _eTonnageController,
                        hintText: 'E-Tonnage',
                        obscureText: false,
                        textCapitalization: TextCapitalization.characters,
                        // focusNode: _eTonnageFocusNode,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                          // DecimalTextInputFormatter(decimalRange: 3),
                          // AutoDecimalTextInputFormatter(decimalRange: 3),
                        ],
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        onChanged: (newValue){
                          calculateSalesAmount();

                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
                Row(
                  children: [
                    Expanded(child: MyTextField(
                      controller: _purchaseRateController,
                      hintText: 'Purchase Rate',
                      obscureText: false,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                      ],
                      keyboardType: TextInputType.numberWithOptions(decimal: false),
                      onChanged: (newValue){
                        calculatePurchaseAmount();
                      },

                    ),),
                    const SizedBox(width: 10.0),
                    Expanded(child:MyTextField(
                      controller: _saleRateController,
                      hintText: 'Sale Rate',
                      obscureText: false,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                      ],
                      keyboardType: TextInputType.numberWithOptions(decimal: false),
                      onChanged: (newValue){
                        calculateSalesAmount();
                        calculatePurchaseAmount();
                      },
                    ), ),



                  ],
                ),
                const SizedBox(height: 10,),

                const SizedBox(height: 10,),
                Row(
                  children: [
                    Expanded(
                      child: MyTextField(
                        controller: _purchaseAmountController,
                        hintText: 'Purchase Amount',
                        obscureText: false,
                        textCapitalization: TextCapitalization.none,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                          DecimalTextInputFormatter(decimalRange: 2),
                        ],
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        readOnly: false,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: MyTextField(
                        controller: _saleAmountController,
                        hintText: 'Sale Amount',
                        obscureText: false,
                        textCapitalization: TextCapitalization.none,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                          DecimalTextInputFormatter(decimalRange: 2),
                        ],
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        readOnly: false,
                      ),
                    ),




                  ],
                ),
                const SizedBox(height: 10.0),
                SizedBox(
                  child: MyTextField(
                      controller: _descriptionController,
                      hintText: 'Description',
                      obscureText: false,
                      textCapitalization: TextCapitalization.characters,
                    // fieldHeight: 120,

                  ),
                ),

                const SizedBox(height: 10.0),
                MyButton(
                  onTap: _submitForm,
                  text: _order == null ? "Add Order" : "Save Order",
                  padding: const EdgeInsets.all(10),
                ),
              ],
            ),
          ),
        ),
        // drawer: MyDrawer(),
      );
    }

  }

  class DecimalTextInputFormatter extends TextInputFormatter {
    final int decimalRange;

    DecimalTextInputFormatter({required this.decimalRange})
        : assert(decimalRange > 0);

    @override
    TextEditingValue formatEditUpdate(
        TextEditingValue oldValue, TextEditingValue newValue) {
      // Check if the new value is empty
      if (newValue.text.isEmpty) {
        return newValue;
      }

      // Allow only numbers and a single dot
      String newText = newValue.text;
      if (newText.contains('.') &&
          newText.substring(newText.indexOf('.') + 1).length > decimalRange) {
        return oldValue;
      }

      if (newText == '.' || newText.indexOf('.') != newText.lastIndexOf('.')) {
        return oldValue;
      }

      return newValue;
    }
  }

  class AutoDecimalTextInputFormatter extends TextInputFormatter {
    final int decimalRange;

    AutoDecimalTextInputFormatter({this.decimalRange = 3})
        : assert(decimalRange > 0);

    @override
    TextEditingValue formatEditUpdate(
        TextEditingValue oldValue, TextEditingValue newValue) {
      if (newValue.text.isEmpty) {
        return newValue.copyWith(text: '');
      }

      // Remove existing decimal points to avoid issues
      String text = newValue.text.replaceAll('.', '');

      // Only format if the text length is 4 or more
      if (text.length >= 3 && text.length <10) {
        // Insert the decimal point at the correct position
        String formattedText = text.substring(0, text.length - decimalRange) +
            '.' +
            text.substring(text.length - decimalRange);

        return newValue.copyWith(
          text: formattedText,
          selection: TextSelection.collapsed(offset: formattedText.length),
        );
      }

      // If text length is less than 4, return as is
      return newValue.copyWith(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }



