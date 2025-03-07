import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'db_helper.dart';

class BusinessDetailsForm extends StatefulWidget {
  @override
  _BusinessDetailsFormState createState() => _BusinessDetailsFormState();
}

class _BusinessDetailsFormState extends State<BusinessDetailsForm> {
  final TextEditingController _businessNameController = TextEditingController(text: 'Demo Business');
  final TextEditingController _businessAddressController = TextEditingController(text: '123 Demo Street');
  final TextEditingController _businessContactController = TextEditingController(text: '123-456-7890');
  final TextEditingController _businessTaxIdController = TextEditingController(text: 'TAX123456');
  final TextEditingController _seniorCitizenController = TextEditingController(text: '5');
  final TextEditingController _pwdController = TextEditingController(text: '5');
  final TextEditingController _otherController = TextEditingController(text: '2');
  final DBHelper _dbHelper = DBHelper();
  String? _businessLogo;
  String _selectedCurrency = 'PHP';

  @override
  void initState() {
    super.initState();
    _loadBusinessDetails();
  }

  Future<void> _loadBusinessDetails() async {
    try {
      _businessNameController.text = await _dbHelper.getBusinessDetail('name') ?? 'Demo Business';
      _businessAddressController.text = await _dbHelper.getBusinessDetail('address') ?? '123 Demo Street';
      _businessContactController.text = await _dbHelper.getBusinessDetail('contact') ?? '123-456-7890';
      _businessTaxIdController.text = await _dbHelper.getBusinessDetail('tax_id') ?? 'TAX123456';
      _businessLogo = await _dbHelper.getBusinessDetail('logo') ?? 'assets/logo.png';
      _seniorCitizenController.text = await _dbHelper.getBusinessDetail('senior_discount') ?? '5';
      _pwdController.text = await _dbHelper.getBusinessDetail('pwd_discount') ?? '5';
      _otherController.text = await _dbHelper.getBusinessDetail('other_discount') ?? '2';
      _selectedCurrency = await _dbHelper.getBusinessDetail('currency') ?? 'PHP';
      setState(() {});
    } catch (e) {
      print('Error loading business details: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _businessLogo = pickedFile.path;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected image: ${pickedFile.path}')),
      );
    }
  }

  void _saveBusinessDetails() async {
    try {
      print('Saving Business Name: ${_businessNameController.text}');
      await _dbHelper.updateBusinessDetail('name', _businessNameController.text);
      print('Saving Business Address: ${_businessAddressController.text}');
      await _dbHelper.updateBusinessDetail('address', _businessAddressController.text);
      print('Saving Business Contact: ${_businessContactController.text}');
      await _dbHelper.updateBusinessDetail('contact', _businessContactController.text);
      print('Saving Business Tax ID: ${_businessTaxIdController.text}');
      await _dbHelper.updateBusinessDetail('tax_id', _businessTaxIdController.text);
      print('Saving Business Logo: ${_businessLogo ?? 'assets/logo.png'}');
      await _dbHelper.updateBusinessDetail('logo', _businessLogo ?? 'assets/logo.png');
      print('Saving Senior Discount: ${_seniorCitizenController.text}');
      await _dbHelper.updateBusinessDetail('senior_discount', _seniorCitizenController.text);
      print('Saving PWD Discount: ${_pwdController.text}');
      await _dbHelper.updateBusinessDetail('pwd_discount', _pwdController.text);
      print('Saving Other Discount: ${_otherController.text}');
      await _dbHelper.updateBusinessDetail('other_discount', _otherController.text);
      print('Saving Currency: $_selectedCurrency');
      await _dbHelper.updateBusinessDetail('currency', _selectedCurrency);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Changes Saved')),
      );
    } catch (e) {
      print('Error saving changes: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving changes: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back button
        title: Text('Business Details'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: 600,
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _businessNameController,
                        decoration: InputDecoration(labelText: 'Business Name'),
                      ),
                      TextField(
                        controller: _businessAddressController,
                        decoration: InputDecoration(labelText: 'Business Address'),
                      ),
                      TextField(
                        controller: _businessContactController,
                        decoration: InputDecoration(labelText: 'Business Contact Number'),
                      ),
                      TextField(
                        controller: _businessTaxIdController,
                        decoration: InputDecoration(labelText: 'Business Tax ID Number'),
                      ),
                      SizedBox(height: 16.0),
                      _businessLogo != null
                          ? Image.file(File(_businessLogo!))
                          : Text('No logo selected'),
                      ElevatedButton(
                        onPressed: _pickImage,
                        child: Text('Upload Business Logo'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.0),
                Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Discounts',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16.0),
                      TextField(
                        controller: _seniorCitizenController,
                        decoration: InputDecoration(labelText: 'Senior Citizen (%)'),
                      ),
                      TextField(
                        controller: _pwdController,
                        decoration: InputDecoration(labelText: 'PWD (%)'),
                      ),
                      TextField(
                        controller: _otherController,
                        decoration: InputDecoration(labelText: 'Other (%)'),
                      ),
                      SizedBox(height: 16.0),
                      DropdownButton<String>(
                        value: _selectedCurrency,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCurrency = newValue!;
                          });
                        },
                        items: <String>['PHP', 'USD', 'EUR', 'GBP', 'JPY']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _saveBusinessDetails,
                  child: Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
