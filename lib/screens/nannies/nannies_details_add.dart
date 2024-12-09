import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import 'nannies_sidemenu.dart'; // 导入 NanniesSideMenu 组件
import 'nannies_detail.dart'; // 导入 NanniesDetailScreen 页面

class NanniesDetailsAddScreen extends StatefulWidget {
  final String userId;
  final String userEmail;
  final String userType;

  NanniesDetailsAddScreen({
    required this.userId,
    required this.userEmail,
    required this.userType,
  });

  @override
  _NanniesDetailsAddScreenState createState() =>
      _NanniesDetailsAddScreenState();
}

class _NanniesDetailsAddScreenState extends State<NanniesDetailsAddScreen> {
  final _formKey = GlobalKey<FormState>();
  String content = '';
  String location = '';
  List<String> selectedDays = []; // 用户选择的周几
  TimeOfDay? startTime; // 每天的开始时间
  TimeOfDay? endTime; // 每天的结束时间

  final Map<String, TextEditingController> priceControllers = {
    'Hourly': TextEditingController(),
    'Daily': TextEditingController(),
    'Weekly': TextEditingController(),
    'Monthly': TextEditingController(),
  };

  List<String> selectedChargeModes = []; // 用户选择的收费模式
  final List<String> chargeModes = ['Hourly', 'Daily', 'Weekly', 'Monthly']; // 可选收费模式

  Future<void> _addNannyDetail() async {
    String serviceTime = _formatServiceTime();

    if (serviceTime.isEmpty || selectedChargeModes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Please select service days, time, and at least one charge mode.')),
      );
      return;
    }

    // 构建价格 JSON
    Map<String, String> prices = {};
    for (var mode in selectedChargeModes) {
      String price = priceControllers[mode]?.text.trim() ?? '';
      if (price.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter price for $mode')),
        );
        return;
      }
      prices[mode] = "RM $price"; // 在数字前加 "RM"
    }
    String priceJson = json.encode(prices);

    try {
      final response = await http.post(
        Uri.parse('${Config.apiUrl}/babysitting_app/php/add_nanny_detail.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'user_id': widget.userId,
          'nannies_details_price': priceJson, // 将价格作为 JSON 字符串传递
          'nannies_details_content': content,
          'nannies_details_location': location,
          'nannies_service_time': serviceTime,
        },
      );

      print('HTTP status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'success') {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Successfully Added')));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => NanniesDetailScreen(
                userId: widget.userId,
                userEmail: widget.userEmail,
                userType: widget.userType,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to Add: ${result['message']}')));
        }
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Server Error')));
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Internet Error: $e')));
    }
  }

  // 格式化服务时间
  String _formatServiceTime() {
    if (selectedDays.isEmpty || startTime == null || endTime == null) return '';

    String formattedStartTime = startTime!.format(context);
    String formattedEndTime = endTime!.format(context);
    return '${selectedDays.join(', ')}: $formattedStartTime - $formattedEndTime';
  }

  // 显示时间选择器
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
  void dispose() {
    // 清理控制器
    for (var controller in priceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Nanny Detail')),
      drawer: NanniesSideMenu(
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
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Location (City)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter location';
                    }
                    return null;
                  },
                  onSaved: (value) => location = value ?? '',
                ),
                SizedBox(height: 20),
                // 周几选择
                Text('Select Service Days:',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                SizedBox(height: 20),
                // 收费模式选择
                Text('Select Charge Modes and Enter Prices:',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Column(
                  children: chargeModes.map((mode) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CheckboxListTile(
                          title: Text(mode),
                          value: selectedChargeModes.contains(mode),
                          onChanged: (bool? isSelected) {
                            setState(() {
                              if (isSelected == true) {
                                selectedChargeModes.add(mode);
                              } else {
                                selectedChargeModes.remove(mode);
                              }
                            });
                          },
                        ),
                        if (selectedChargeModes.contains(mode))
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: TextFormField(
                              controller: priceControllers[mode],
                              decoration: InputDecoration(
                                labelText: 'Enter Price for $mode',
                                prefixText: 'RM ',
                              ),
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (selectedChargeModes.contains(mode) &&
                                    (value == null || value.isEmpty)) {
                                  return 'Please enter price for $mode';
                                }
                                return null;
                              },
                            ),
                          ),
                      ],
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
                // 时间选择
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text('Start Time',
                            style: TextStyle(fontSize: 16)),
                        ElevatedButton(
                          onPressed: () => _selectTime(isStartTime: true),
                          child: Text(startTime != null
                              ? startTime!.format(context)
                              : 'Select Start Time'),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text('End Time', style: TextStyle(fontSize: 16)),
                        ElevatedButton(
                          onPressed: () => _selectTime(isStartTime: false),
                          child: Text(endTime != null
                              ? endTime!.format(context)
                              : 'Select End Time'),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Service Description',
                    hintText: 'Please describe the services you can provide.',
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter content';
                    }
                    return null;
                  },
                  onSaved: (value) => content = value ?? '',
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _formKey.currentState?.save();
                      print('Form saved, calling _addNannyDetail...');
                      _addNannyDetail();
                    }
                  },
                  child: Text('Add'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
