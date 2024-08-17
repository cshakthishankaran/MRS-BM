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
import "package:uuid/uuid.dart";



class MaterialsScreen extends StatefulWidget {
  const MaterialsScreen({super.key});

  @override
  State<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends State<MaterialsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _materialController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  late List<Map<String,dynamic>> _materials =[];
  bool _editMode = false;
  bool _isButtonDisabled = false;


  @override
  void initState() {
    super.initState();

      _getMaterialList();


  }

  @override
  void setState(fn) {
    if (!mounted) return;
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _materialController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<String> _getFilePath(filename) async {
    // Get the current directory
    final directory = await getApplicationDocumentsDirectory();
    // Specify the relative path inside your project structure
    final fullPath = path.join(directory.path, 'company_studio', 'lib', 'data', filename);
    print(fullPath);
    return fullPath;
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
        });
  }
      }
    }
    print('MaterialsScreen --> ${_materials}');

  }





  Future<void> _saveMaterial(Map<String, dynamic> material) async {
    final filePath = await _getFilePath('materials.json');
    final file = File(filePath);

    // Create the directory if it doesn't exist
    if (!(await Directory(path.dirname(filePath)).exists())) {
      await Directory(path.dirname(filePath)).create(recursive: true);
    }

    List<Map<String,dynamic>> materials = [];

    // Check if the file exists and read the contents
    if (await file.exists()) {
      final contents = await file.readAsString();
      if (contents.isNotEmpty) {
        setState(() {
          materials = List<Map<String,dynamic>>.from(json.decode(contents));
        });

      }
    }

    // Check for duplicates before adding the new vehicle


    final existingMaterialIndex = materials.indexWhere((o) => o['id']== material['id']);
    if (existingMaterialIndex !=   -1) {
      // Replace the existing order
      materials[existingMaterialIndex] = material;
    }else{
      materials.add(material);
    }
    _editMode != _editMode;
    await file.writeAsString(json.encode(materials)).then((value)=> _materials = materials);



  }


  void _submitForm() {

    if (_formKey.currentState?.validate() ?? false) {
      final uuid = Uuid();
      final material = {
        "id" : uuid.v4(),
        "material":_materialController.text,
        "price" : _priceController.text,
      };
      _saveMaterial(material).then((_) {
        _materialController.clear();
        _priceController.clear();
        Navigator.pushNamed(context, '/material');
      });



    }




  }
  void _editMaterial(Map<String,dynamic> material) {
    print(material);
    _editMode = true;
    _materialController.text = material['material'];
    _priceController.text = material['price'];


  }

  void _deleteMaterial(Map<String,dynamic> material) async {

    final filePath = await _getFilePath('materials.json');
    final file = File(filePath);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Material'),
          content: const Text('Are you sure you want to delete this material?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _materials.remove(material);
                  file.writeAsString(json.encode(_materials));
                });
              },
              child: const Text('Delete',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel',style: TextStyle(color: Colors.black)),
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
          'Add Material',
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
          child: Column(
            children: [
              const SizedBox(height: 10.0),
              Row(
                children: [
                  Expanded(
                    child: MyTextField(
                      controller: _materialController,
                      hintText: 'Material Name',
                      obscureText: false,
                      textCapitalization: TextCapitalization.characters,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: MyTextField(
                      controller: _priceController,
                      hintText: 'Price Amount',
                      obscureText: false,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                      ],
                      keyboardType: TextInputType.numberWithOptions(decimal: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              MyButton(
                onTap: _submitForm,
                isEnabled: _isButtonDisabled == true ? _isButtonDisabled : false,
                text: _editMode == false ? "Add Material" : "Save Material",
                padding: const EdgeInsets.all(10),
              ),
              const SizedBox(height: 20.0),
              const Text(
                'Saved Materials:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10.0),

              // Make the list scrollable by using an expanded ListView.builder
              Expanded(
                child: ListView.builder(
                  itemCount: _materials.length,
                  itemBuilder: (context, index) {
                    final material = _materials[index];
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 5,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Text('${material['material']}'),
                        subtitle: Text('Price: ${material['price']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteMaterial(material),
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
        ),
      ),
      drawer: const MyDrawer(),
    );
  }


}
