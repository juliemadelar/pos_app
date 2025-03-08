import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'db_helper.dart';
import 'package:logger/logger.dart'; // Add this import

class BusinessDetailsForm extends StatefulWidget {
  const BusinessDetailsForm({super.key}); // Convert 'key' to a super parameter
  @override
  BusinessDetailsFormState createState() => BusinessDetailsFormState(); // Make the type public
}

class BusinessDetailsFormState extends State<BusinessDetailsForm> {
  // Make the type public
  final TextEditingController _businessNameController = TextEditingController(
    text: 'Demo Business',
  );
  final TextEditingController _businessAddressController =
      TextEditingController(text: '123 Demo Street');
  final TextEditingController _businessContactController =
      TextEditingController(text: '123-456-7890');
  final TextEditingController _businessTaxIdController = TextEditingController(
    text: 'TAX123456',
  );
  final TextEditingController _seniorCitizenController = TextEditingController(
    text: '5',
  );
  final TextEditingController _pwdController = TextEditingController(text: '5');
  final TextEditingController _otherController = TextEditingController(
    text: '2',
  );
  final DBHelper _dbHelper = DBHelper();
  String? _businessLogo;
  String _selectedCurrency = 'PHP';
  final Logger _logger = Logger(); // Add this line

  @override
  void initState() {
    super.initState();
    _loadBusinessDetails();
  }

  Future<void> _loadBusinessDetails() async {
    try {
      _businessNameController.text =
          await _dbHelper.getBusinessDetail('name') ?? 'Demo Business';
      _businessAddressController.text =
          await _dbHelper.getBusinessDetail('address') ?? '123 Demo Street';
      _businessContactController.text =
          await _dbHelper.getBusinessDetail('contact') ?? '123-456-7890';
      _businessTaxIdController.text =
          await _dbHelper.getBusinessDetail('tax_id') ?? 'TAX123456';
      _businessLogo =
          await _dbHelper.getBusinessDetail('logo') ?? 'assets/logo.png';
      _seniorCitizenController.text =
          await _dbHelper.getBusinessDetail('senior_discount') ?? '5';
      _pwdController.text =
          await _dbHelper.getBusinessDetail('pwd_discount') ?? '5';
      _otherController.text =
          await _dbHelper.getBusinessDetail('other_discount') ?? '2';
      _selectedCurrency =
          await _dbHelper.getBusinessDetail('currency') ?? 'PHP';
      setState(() {});
    } catch (e) {
      _logger.e('Error loading business details: $e'); // Use logger
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null && mounted) {
      // Add mounted check
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
      _logger.i('Attempting to save business details'); // Add debug log
      _logger.i(
        'Saving Business Name: ${_businessNameController.text}',
      ); // Use logger
      await _dbHelper.updateBusinessDetail(
        'name',
        _businessNameController.text,
      );
      _logger.i(
        'Saving Business Address: ${_businessAddressController.text}',
      ); // Use logger
      await _dbHelper.updateBusinessDetail(
        'address',
        _businessAddressController.text,
      );
      _logger.i(
        'Saving Business Contact: ${_businessContactController.text}',
      ); // Use logger
      await _dbHelper.updateBusinessDetail(
        'contact',
        _businessContactController.text,
      );
      _logger.i(
        'Saving Business Tax ID: ${_businessTaxIdController.text}',
      ); // Use logger
      await _dbHelper.updateBusinessDetail(
        'tax_id',
        _businessTaxIdController.text,
      );
      _logger.i(
        'Saving Business Logo: ${_businessLogo ?? 'assets/logo.png'}',
      ); // Use logger
      await _dbHelper.updateBusinessDetail(
        'logo',
        _businessLogo ?? 'assets/logo.png',
      );
      _logger.i(
        'Saving Senior Discount: ${_seniorCitizenController.text}',
      ); // Use logger
      await _dbHelper.updateBusinessDetail(
        'senior_discount',
        _seniorCitizenController.text,
      );
      _logger.i('Saving PWD Discount: ${_pwdController.text}'); // Use logger
      await _dbHelper.updateBusinessDetail('pwd_discount', _pwdController.text);
      _logger.i(
        'Saving Other Discount: ${_otherController.text}',
      ); // Use logger
      await _dbHelper.updateBusinessDetail(
        'other_discount',
        _otherController.text,
      );
      _logger.i('Saving Currency: $_selectedCurrency'); // Use logger
      await _dbHelper.updateBusinessDetail('currency', _selectedCurrency);

      if (mounted) {
        // Add mounted check
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Business details saved successfully!')),
        );

        // Verify database update
        final name = await _dbHelper.getBusinessDetail('name');
        final address = await _dbHelper.getBusinessDetail('address');
        final contact = await _dbHelper.getBusinessDetail('contact');
        final taxId = await _dbHelper.getBusinessDetail('tax_id');
        final logo = await _dbHelper.getBusinessDetail('logo');
        final seniorDiscount = await _dbHelper.getBusinessDetail(
          'senior_discount',
        );
        final pwdDiscount = await _dbHelper.getBusinessDetail('pwd_discount');
        final otherDiscount = await _dbHelper.getBusinessDetail(
          'other_discount',
        );
        final currency = await _dbHelper.getBusinessDetail('currency');

        _logger.i('Verified Business Name: $name');
        _logger.i('Verified Business Address: $address');
        _logger.i('Verified Business Contact: $contact');
        _logger.i('Verified Business Tax ID: $taxId');
        _logger.i('Verified Business Logo: $logo');
        _logger.i('Verified Senior Discount: $seniorDiscount');
        _logger.i('Verified PWD Discount: $pwdDiscount');
        _logger.i('Verified Other Discount: $otherDiscount');
        _logger.i('Verified Currency: $currency');
      }
    } catch (e) {
      _logger.e('Error saving changes: $e'); // Use logger
      if (mounted) {
        // Add mounted check
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving business details: $e')),
        );
      }
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
                        color: Colors.grey.withAlpha((0.5 * 255).toInt()),
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
                        decoration: InputDecoration(
                          labelText: 'Business Address',
                        ),
                      ),
                      TextField(
                        controller: _businessContactController,
                        decoration: InputDecoration(
                          labelText: 'Business Contact Number',
                        ),
                      ),
                      TextField(
                        controller: _businessTaxIdController,
                        decoration: InputDecoration(
                          labelText: 'Business Tax ID Number',
                        ),
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
                        color: Colors.grey.withAlpha((0.5 * 255).toInt()),
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
                        decoration: InputDecoration(
                          labelText: 'Senior Citizen (%)',
                        ),
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
                        value:
                            _selectedCurrency.isNotEmpty &&
                                    [
                                      'PHP',
                                      'USD',
                                      'EUR',
                                      'GBP',
                                      'JPY',
                                    ].contains(_selectedCurrency)
                                ? _selectedCurrency
                                : null,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCurrency = newValue!;
                          });
                        },
                        items:
                            <String>[
                              'PHP',
                              'USD',
                              'EUR',
                              'GBP',
                              'JPY',
                            ].map<DropdownMenuItem<String>>((String value) {
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
