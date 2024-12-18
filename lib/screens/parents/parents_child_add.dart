import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import '../side_menu.dart';

class ParentsChildAddScreen extends StatefulWidget {
  final String userId;
  final String userEmail;
  final String userType;

  ParentsChildAddScreen({
    required this.userId,
    required this.userEmail,
    required this.userType,
  });

  @override
  _ParentsChildAddScreenState createState() => _ParentsChildAddScreenState();
}

class _ParentsChildAddScreenState extends State<ParentsChildAddScreen> {
  final _formKey = GlobalKey<FormState>();
  String childDetails = '';
  String childAddress = '';
  String childAge = 'baby';
  String childLanguage = 'English';
  String childMoney = '';
  List<String> selectedDays = [];
  List<String> selectedRequirements = [];
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  final List<String> _ageOptions = [
    'baby',
    'toddler',
    'preschool',
    'grade schooler',
    'teenager',
  ];

  final List<String> _languageOptions = [
    'English',
    'Chinese',
    'Malay',
  ];

  final List<String> _requirementOptions = [
    'Pets',
    'Cooking',
    'Chores',
    'Homework assistance',
  ];

  Future<void> _addChild() async {
    String serviceTime = _formatServiceTime();
    String requirements = selectedRequirements.join(', ');

    if (serviceTime.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select service days and time.')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${Config.apiUrl}/add_parents_child.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'parents_id': widget.userId,
          'parents_child_details': childDetails,
          'parents_child_address': childAddress,
          'parents_child_age': childAge,
          'parents_child_language': childLanguage,
          'parents_child_require': requirements,
          'parents_child_time': serviceTime,
          'parents_child_money': childMoney,
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Child added successfully')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add child: ${result['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network Error: $e')),
      );
    }
  }

  String _formatServiceTime() {
    if (selectedDays.isEmpty || startTime == null || endTime == null) return '';

    String formattedStartTime = startTime!.format(context);
    String formattedEndTime = endTime!.format(context);
    return '${selectedDays.join(', ')}: $formattedStartTime - $formattedEndTime';
  }

  Future<void> _selectTime({required bool isStartTime}) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          startTime = pickedTime;
        } else {
          endTime = pickedTime;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Child Information'),
      ),
      drawer: SideMenu(
        userId: widget.userId,
        userEmail: widget.userEmail,
        userType: widget.userType,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SectionTitle(title: 'Child Information'),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Details',
                    hintText: 'e.g., 5-year-old boy who loves painting',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter child details';
                    }
                    return null;
                  },
                  onSaved: (value) => childDetails = value ?? '',
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Address (City)',
                    hintText: 'e.g., Kuala Lumpur',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter child address';
                    }
                    return null;
                  },
                  onSaved: (value) => childAddress = value ?? '',
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Age'),
                        value: childAge,
                        items: _ageOptions.map((age) {
                          return DropdownMenuItem(value: age, child: Text(age));
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => childAge = value ?? 'baby'),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Language'),
                        value: childLanguage,
                        items: _languageOptions.map((language) {
                          return DropdownMenuItem(
                              value: language, child: Text(language));
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => childLanguage = value ?? 'English'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                SectionTitle(title: 'Service Information'),
                Wrap(
                  spacing: 10.0,
                  children: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
                      .map((day) => FilterChip(
                            label: Text(day),
                            selected: selectedDays.contains(day),
                            onSelected: (isSelected) {
                              setState(() {
                                if (isSelected) {
                                  selectedDays.add(day);
                                } else {
                                  selectedDays.remove(day);
                                }
                              });
                            },
                          ))
                      .toList(),
                ),
                SizedBox(height: 10),
                Text('Select Time:'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () => _selectTime(isStartTime: true),
                      child: Text(
                          startTime != null ? startTime!.format(context) : 'Start Time'),
                    ),
                    ElevatedButton(
                      onPressed: () => _selectTime(isStartTime: false),
                      child: Text(
                          endTime != null ? endTime!.format(context) : 'End Time'),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text('Requirements:', style: TextStyle(fontSize: 16)),
                Wrap(
                  spacing: 10.0,
                  children: _requirementOptions.map((requirement) {
                    return FilterChip(
                      label: Text(requirement),
                      selected: selectedRequirements.contains(requirement),
                      onSelected: (isSelected) {
                        setState(() {
                          if (isSelected) {
                            selectedRequirements.add(requirement);
                          } else {
                            selectedRequirements.remove(requirement);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Price',
                    prefixText: 'RM ',
                    hintText: 'e.g., 20/hour',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter price';
                    }
                    return null;
                  },
                  onSaved: (value) => childMoney = value ?? '',
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        _formKey.currentState?.save();
                        _addChild();
                      }
                    },
                    child: Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
