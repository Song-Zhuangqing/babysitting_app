import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart'; // 导入配置文件
import 'nannies_sidemenu.dart'; // 导入侧边栏文件

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
  String certificateInfo = ''; // 证书信息

  // 选择证书图片
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _certificateImage = File(pickedFile.path);
      });
    }
  }

  // 上传证书信息和图片
  Future<void> _uploadCertificate() async {
    if (_certificateImage == null || certificateInfo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields and select an image.')),
      );
      return;
    }

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Config.apiUrl}/update_nannies_certificate.php'),
      );

      request.fields['user_id'] = widget.userId;
      request.fields['certificate_info'] = certificateInfo;

      // 上传证书图片
      request.files.add(await http.MultipartFile.fromPath(
        'certificate_image',
        _certificateImage!.path,
      ));

      // 打印调试信息
      print('Request fields: ${request.fields}');
      print('Request files: ${request.files}');

      final response = await request.send();

      if (response.statusCode == 200) {
        final result = await response.stream.bytesToString();
        print('Response body: $result'); // 打印调试信息
        final jsonResponse = json.decode(result);

        if (jsonResponse['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Certificate uploaded successfully.')),
          );
          Navigator.pop(context); // 返回上一页
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: ${jsonResponse['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Server Error')));
      }
    } catch (e) {
      print('Error: $e'); // 打印调试信息
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
      drawer: NanniesSideMenu(
        userId: widget.userId,
        userEmail: widget.userEmail,
        userType: widget.userType,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Certificate Info',
                helperText: 'e.g., Childcare Certification',
              ),
              onChanged: (value) {
                setState(() {
                  certificateInfo = value;
                });
              },
            ),
            SizedBox(height: 20),
            _certificateImage != null
                ? Image.file(_certificateImage!, height: 200)
                : Text('No certificate selected.'),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  child: Text('Choose from Gallery'),
                ),
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.camera),
                  child: Text('Take a Photo'),
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
