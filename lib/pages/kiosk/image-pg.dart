import 'package:flutter/material.dart';

class ImagePage extends StatefulWidget {
  const ImagePage({super.key});

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  child: Image.network("https://farm2.staticflickr.com/1533/26541536141_41abe98db3_z_d.jpg"),
                )
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Container(
                  child: Image.network("https://farm9.staticflickr.com/8505/8441256181_4e98d8bff5_z_d.jpg"),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
