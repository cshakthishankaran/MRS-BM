import "dart:convert";
import "dart:io";
import "package:company_studio/components/my_button.dart";
import "package:company_studio/components/my_drawer.dart";
import "package:company_studio/components/my_textfield.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:path_provider/path_provider.dart";
import 'package:path/path.dart' as path;
import "package:shared_preferences/shared_preferences.dart";



class VehicleScreen extends StatefulWidget {
  const VehicleScreen({super.key});

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _vehicleNumberController = TextEditingController();
  late List<String> _vehicles =[];
  bool _editMode = false;
  bool _isButtonDisabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _getVehicleList();
    _vehicleNumberController.addListener(_checkInput);
  }

  Future<String> _getFilePath(filename) async {
    // Get the current directory
    final directory = await getApplicationDocumentsDirectory();
    // Specify the relative path inside your project structure
    final fullPath = path.join(directory.path, 'company_studio', 'lib', 'data', filename);
    print(fullPath);
    return fullPath;
  }

  void _getVehicleList() async {
    setState(() {
      _isLoading = true; // Show the loader
    });
    final filePath = await _getFilePath('vehicles.json');
    final file = File(filePath);

    // Create the directory if it doesn't exist
    if (!(await Directory(path.dirname(filePath)).exists())) {
      await Directory(path.dirname(filePath)).create(recursive: true);
    }
    
    await Future.delayed(const Duration(seconds: 1));
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
    print('VehicleScreen --> ${_vehicles}');
    setState(() {
      _isLoading = false; // Hide the loader
    });
  }

  void _checkInput() {
    setState(() {
      _isButtonDisabled = _vehicleNumberController.text.isEmpty;
    });
  }

  @override
  void dispose() {
    // Dispose of the controller when done
    _vehicleNumberController.dispose();
    super.dispose();
  }

  Future<void> _saveVehicle(String vehicle) async {
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
        setState(() {
          vehicles = List<String>.from(json.decode(contents));
        });

      }
    }

    // Check for duplicates before adding the new vehicle


      final existingVehicleIndex = vehicles.indexWhere((o) => o== vehicle);
      if (existingVehicleIndex !=   -1) {
        // Replace the existing order
        vehicles[existingVehicleIndex] = vehicle;
      }else{
        vehicles.add(vehicle);
      }
      _editMode != _editMode;
      await file.writeAsString(json.encode(vehicles)).then((value)=> _vehicles = vehicles);

  }


  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      if(!_vehicleNumberController.text.isEmpty){
        _saveVehicle(_vehicleNumberController.text).then((_) {
          Navigator.pushNamed(context, '/vehicle');
        });
      }

    }

  }
  void _editVehicle(String vehicle) {
    print(vehicle);
    _editMode = true;
    _vehicleNumberController.text = vehicle;


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
                  _vehicles.removeAt(index);
                  file.writeAsString(json.encode(_vehicles));
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Add Vehicle',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Column(
                children: [
                  const SizedBox(height: 10.0),
                  MyTextField(
                    controller: _vehicleNumberController,
                    hintText: 'Vehicle Number',
                    obscureText: false,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[A-Z0-9]'))
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                    :MyButton(
                    onTap: _submitForm,
                    isEnabled: _isButtonDisabled == true ? _isButtonDisabled : false,
                    text: _editMode ==false ? "Add Vehicle" : "Save Vehicle",
                    padding: const EdgeInsets.all(10),
                  ),
                  const SizedBox(height: 20.0),
                  const Text(
                    'Saved Vehicles:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10.0),
                  SizedBox(
                    height: MediaQuery.of(context).size.height,

                    child: ListView.builder(
                      itemCount: _vehicles.length,
                      itemBuilder: (context, index) {
                        final vehicle = _vehicles[index];
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
      drawer: const MyDrawer(),
    );
  }

}
