import 'package:flutter/material.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 8,
                shadowColor: Colors.black,
                child: Column(
                    children: [
                      ListTile(
                        title: Container(
                          child: Text(
                              "mutasem"),
                        ),
                      ),
                    ]
                ),
              )
          )
      ),
    );
  }
}
