import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uk_untitled_v0/DatabaseHelper.dart';
import 'UniversityService.dart';

class UserInfoForm extends StatefulWidget {
  @override
  _UserInfoFormState createState() => _UserInfoFormState();
}

class _UserInfoFormState extends State<UserInfoForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _jobController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _universitySearchController = TextEditingController();

  String? _gender;
  String? _educationLevel;
  String? _university;
  List<String> _interests = [];
  List<String> _universities = [];
  List<String> _filteredUniversities = [];

  final List<String> _educationLevels = ['Student', 'Graduated', 'MSc.', 'PhD.'];

  @override
  void initState() {
    super.initState();
    _loadUniversities('');
  }

  Future<void> _loadUniversities(String query) async {
    try {
      final universityService = UniversityService();
      List<String> universities = await universityService.fetchUniversities(query);
      setState(() {
        _universities = universities;
        _filteredUniversities = _universities;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load universities: ${e.toString()}')),
      );
    }
  }

  void _onUniversitySearchChanged(String query) {
    setState(() {
      _filteredUniversities = _universities
          .where((university) => university.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await DatabaseHelper().createUserProfile(
          _nameController.text,
          _surnameController.text,
          int.parse(_ageController.text),
          _gender!,
          user.email!,
          _phoneController.text,
          _educationLevel!,
          _university!,
          job: _jobController.text,
          company: _companyController.text,
          salary: _salaryController.text.isNotEmpty ? int.parse(_salaryController.text) : null,
          areasOfInterest: _interests,
        );

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile saved successfully!')));
        // Optionally navigate to another page or clear the form
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Complete Your Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
              ),
              TextFormField(
                controller: _surnameController,
                decoration: InputDecoration(labelText: 'Surname'),
                validator: (value) => value!.isEmpty ? 'Please enter your surname' : null,
              ),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter your age' : null,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Gender'),
                value: _gender,
                onChanged: (String? newValue) {
                  setState(() {
                    _gender = newValue;
                  });
                },
                items: <String>['Male', 'Female', 'Other'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) => value == null ? 'Please select your gender' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Please enter your phone number' : null,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Education Level'),
                value: _educationLevel,
                onChanged: (String? newValue) {
                  setState(() {
                    _educationLevel = newValue;
                  });
                },
                items: _educationLevels.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) => value == null ? 'Please select your education level' : null,
              ),
              TextFormField(
                controller: _universitySearchController,
                decoration: InputDecoration(labelText: 'Search University'),
                onChanged: _onUniversitySearchChanged,
              ),
              DropdownButton<String>(
                hint: Text('Select University'),
                value: _university,
                onChanged: (String? newValue) {
                  setState(() {
                    _university = newValue;
                  });
                },
                items: _filteredUniversities.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              TextFormField(
                controller: _jobController,
                decoration: InputDecoration(labelText: 'Job (Optional)'),
              ),
              TextFormField(
                controller: _companyController,
                decoration: InputDecoration(labelText: 'Company (Optional)'),
              ),
              TextFormField(
                controller: _salaryController,
                decoration: InputDecoration(labelText: 'Salary (Optional)'),
                keyboardType: TextInputType.number,
              ),
              ElevatedButton(
                onPressed: _saveProfile,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
