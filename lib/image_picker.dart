import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as Path;

class GalleryImagePicker extends StatefulWidget {
  @override
  State<GalleryImagePicker> createState() => _GalleryImagePickerState();
}

class _GalleryImagePickerState extends State<GalleryImagePicker> {
  CollectionReference imgRef = FirebaseFirestore.instance.collection("images");

  var val = 0.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  List<File> _image = [];
  ImagePicker picker = ImagePicker();

  Future getImages() async {
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    // print(jsonDecode(image.toString()));
    setState(() {
      if (pickedImage == null) {
        return;
      } else {
        _image.add(File(pickedImage.path));
      }
    });
  }

  // FirebaseStorage
  FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  String? imgUrl;

  // upload img to firebase storage

  Future addImageToFirebaseStorage() async {
    int i = 1;
    for (var img in _image) {
      setState(() {
        val = i / _image.length;
      });
      Reference ref = firebaseStorage.ref().child("${Path.basename(img.path)}");
      await ref.putFile(img).whenComplete(() async {
        await ref.getDownloadURL().then((url) async {
          DocumentReference<Object?> img = await imgRef.add({"url": url});
          if (img.id.isEmpty) {
            return await ref.delete();
          }
          i++;
        });
      });
    }
  }

  int count = 1;
  bool selectImg = true;
  bool looding = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "select images screen",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: ListView(
          children: [
            Container(
              color: Colors.transparent,
              height: 200,
              width: double.infinity,
              child: GridView.builder(
                itemCount: _image.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 10),
                itemBuilder: (BuildContext context, int index) {
                  return selectImg
                      ? Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: FileImage(_image[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Text("sabfjsabfjkbfjbj");
                },
              ),
            ),

            SizedBox(
              height: 40,
            ),
            ElevatedButton(
                onPressed: () => getImages(),
                child: const Text("select image")),
            SizedBox(
              height: 20,
            ),
            // save image firesbase
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    looding = true;
                    addImageToFirebaseStorage()
                        .whenComplete(() => Navigator.pop(context));
                  });
                },
                child: const Text("save image")),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 20,
            ),
            looding
                ? Center(
                    child: Column(
                      children: [
                        Text("uploading in progress!"),
                        SizedBox(
                          height: 20,
                        ),
                        CircularProgressIndicator(
                            value: val,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.green)),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  )
                : Container(),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

//   String docId = "";
//   Future<void> docsData() => imgRef.get().then(
//       (QuerySnapshot<Object?> snapshot) => snapshot.docs.forEach((documents) {
//             print(documents.id);
//             docId = documents.id;
//             docId = documents["imageurl"];
//           }));
//   Future deleteurl(String url) async {
//     imgRef.doc(url).delete();
//   }
//

}
