import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(const MyApp());
}

//Xcvsvdv

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'Cupertino Upload Demo',
      theme: CupertinoThemeData(primaryColor: CupertinoColors.activeBlue),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  String _status = '';

  // Galeriden fotoğraf seçme fonksiyonu
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _status = 'Fotoğraf seçildi. Yüklemeye hazır.';
      });
    } else {
      setState(() {
        _status = 'Fotoğraf seçilmedi.';
      });
    }
  }

  // Seçilen fotoğrafı ve statik prompt'u API'ye yükleme fonksiyonu
  Future<void> _uploadImage() async {
    if (_image == null) {
      setState(() {
        _status = 'Lütfen önce bir fotoğraf seçin.';
      });
      return;
    }

    setState(() {
      _status = 'Veriler yükleniyor...';
    });

    String uploadUrl =
        'https://ibrahimkahramann.xyz/webhook-test/f1585b3d-d87a-43fb-88ca-0b8cc79a0275';
    Dio dio = Dio();

    const String staticPrompt = "the camera follows the subject moving";

    try {
      String fileName = _image!.path.split('/').last;

      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(_image!.path, filename: fileName),
        "prompt": staticPrompt,
      });

      Response response = await dio.post(uploadUrl, data: formData);

      if (response.statusCode == 200) {
        setState(() {
          _status = 'Yükleme başarılı: ${response.data}';
        });
      } else {
        setState(() {
          _status = 'Yükleme başarısız oldu. Hata kodu: ${response.statusCode}';
        });
      }
    } on DioException catch (e) {
      print('Dio Hatası:');
      print('  Type: ${e.type}');
      print('  Message: ${e.message}');
      print('  Response: ${e.response}');
      setState(() {
        _status = 'Yükleme sırasında bir hata oluştu: ${e.message}';
      });
    } catch (e) {
      print('Beklenmedik Hata: $e');
      setState(() {
        _status = 'Beklenmedik bir hata oluştu: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Görsel Yükleme'),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Seçilen fotoğrafı göstermek için bir alan
                _image == null
                    ? const Text('Henüz fotoğraf seçilmedi.')
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.file(
                          _image!,
                          width: 250,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                      ),
                const SizedBox(height: 20),

                // Durum mesajını gösteren metin
                Text(_status, textAlign: TextAlign.center),
                const SizedBox(height: 20),

                // Fotoğraf seçme butonu
                CupertinoButton(
                  onPressed: _pickImage,
                  child: const Text('Galeriden Fotoğraf Seç'),
                ),
                const SizedBox(height: 10),

                // Yükleme butonu
                CupertinoButton.filled(
                  onPressed: _uploadImage,
                  child: const Text('Yükle'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
