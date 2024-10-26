import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart'; // 导入配置文件
import '../side_menu.dart'; // 导入侧边栏文件

class NanniesUpdateCertificateScreen extends StatefulWidget {
  final String userId;
  final String userEmail;
  final String userType;

  NanniesUpdateCertificateScreen({
    required this.userId,
    required this.userEmail,
    required this.userType,
  });

  @override
  _NanniesUpdateCertificateScreenState createState() =>
      _NanniesUpdateCertificateScreenState();
}

class _NanniesUpdateCertificateScreenState
    extends State<NanniesUpdateCertificateScreen> {
  File? _certificateImage;
  final ImagePicker _picker = ImagePicker();
  bool hasCertificate = false;

  @override
  void initState() {
    super.initState();
    _fetchUserCertificateStatus();
  }

  // 获取用户当前证书状态
  Future<void> _fetchUserCertificateStatus() async {
    try {
      final response = await http.post(
        Uri.parse('${Config.apiUrl}/babysitting_app/php/get_nannies_certificate_status.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'user_id': widget.userId,
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'success') {
          setState(() {
            hasCertificate = result['has_certificate'] == '1';
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Network Error: $e')));
    }
  }

  // 选择证书图片
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _certificateImage = File(pickedFile.path);
      });
    }
  }

  // 上传或更新证书图片
  Future<void> _uploadCertificate() async {
    if (_certificateImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a certificate image.')),
      );
      return;
    }

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Config.apiUrl}/babysitting_app/php/update_nannies_certificate.php'),
      );

      request.fields['user_id'] = widget.userId;

      // 上传证书图片
      if (_certificateImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'certificate_image_url',
          _certificateImage!.path,
        ));
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        final result = await response.stream.bytesToString();
        final jsonResponse = json.decode(result);

        if (jsonResponse['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Certificate updated successfully.')),
          );
          Navigator.pop(context); // 返回上一页
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Update failed: ${jsonResponse['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Server Error')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Network Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Certificate'),
      ),
      drawer: SideMenu(
        userId: widget.userId,
        userEmail: widget.userEmail,
        userType: widget.userType,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SwitchListTile(
              title: Text('Do you have a certificate?'),
              value: hasCertificate,
              onChanged: (bool value) {
                setState(() {
                  hasCertificate = value;
                });
              },
            ),
            if (hasCertificate)
              Column(
                children: <Widget>[
                  SizedBox(height: 20),
                  _certificateImage != null
                      ? Image.file(_certificateImage!, height: 200)
                      : Text('No certificate selected.'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text('Choose Certificate Image'),
                  ),
                ],
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadCertificate,
              child: Text('Upload Certificate'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
