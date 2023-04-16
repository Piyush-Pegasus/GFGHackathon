import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mask Detection',
        ),
        backgroundColor: Colors.deepOrange,
      ),
      body: Container(
        height: h,
        width: w,
        child: Column(
            children: [
              Container(
                height: 100,
                width: 100,
                padding: EdgeInsets.all(10),
                child: Image.asset('assets/mask.png'),
              ),
              SizedBox(height: 50),
              Container(
                  padding: EdgeInsets.all(10),
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.deepOrange),
                    child: Text('Mask Detection'),
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) => Mask()));
                    },
                  )),
            ]
        ),
      ),
    );
  }
}

class Mask extends StatefulWidget {
  const Mask({Key? key}) : super(key: key);

  @override
  State<Mask> createState() => _MaskState();
}

class _MaskState extends State<Mask> {
  @override
  bool _isLoading = true;
  late File _image;
  final imagepick = ImagePicker();
  late String output = "";
  late String confidence = "";

  _img_gallery() async {
    var img = await imagepick.getImage(source: ImageSource.gallery);
    if (img == null)
      return null;
    else {
      setState(() {
        _isLoading = false;
        _image = File(img.path);
      });
    }
  }

  _img_cam() async {
    var img = await imagepick.getImage(source: ImageSource.camera);
    if (img == null)
      return null;
    else {
      setState(() {
        _isLoading = false;
        _image = File(img.path);
      });
    }
  }

  upImage() async {
    final request = http.MultipartRequest(
        "POST", Uri.parse("https://0cc8-2405-201-4038-3bc6-4464-5d05-c5f0-b600.in.ngrok.io/api1"));
    final headers = {"Content-type": "multipart/form-data"};
    request.files.add(http.MultipartFile(
        'image', _image.readAsBytes().asStream(), _image.lengthSync(),
        filename: _image.path.split('/').last));
    request.headers.addAll(headers);
    var response = await request.send();
    http.Response res = await http.Response.fromStream(response);
    final resjson = jsonDecode(res.body);
    setState(() {
      output = resjson['output'];
      confidence = resjson['confidence'];
    });
  }

  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MASK DETECTION',
        ),
        backgroundColor: Colors.deepOrange,
      ),
      body: Container(
        height: h,
        width: w,
        child: Column(
          children: [
            Container(
                padding: EdgeInsets.all(10),
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () {
                      _img_cam();
                    },
                    style: ElevatedButton.styleFrom(primary: Colors.deepOrange),
                    child: Text('Capture'))),
            SizedBox(height: 20),
            Container(
                padding: EdgeInsets.all(10),
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () {
                      _img_gallery();
                    },
                    style: ElevatedButton.styleFrom(primary: Colors.deepOrange),
                    child: Text('Upload From Gallery'))),
            _isLoading == false
                ? Container(
              child: Column(
                children: [
                  Container(
                    height: 400,
                    width: 400,
                    child: Image.file(_image),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    child: ElevatedButton(
                        onPressed: () {
                          upImage();
                        },
                        style: ElevatedButton.styleFrom(
                            primary: Colors.deepOrange),
                        child: Text('CHECK')),
                  )
                ],
              ),
            )
                : Container(),
            Text(output + " Confidence=" + confidence),
          ],
        ),
      ),
    );
  }
}
