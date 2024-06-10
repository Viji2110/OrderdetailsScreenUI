import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';

class MyorderScreen extends StatelessWidget {
  const MyorderScreen({super.key, required AppBar appBar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NewGradientAppBar(
        gradient:
            LinearGradient(colors: [Color(0xFFe0f5f0), Color(0xFFfbe1df)]),
        elevation: 0,
        leading: Container(
          height: 48,
          width: 48,
          margin: EdgeInsets.only(top: 20, left: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Align(
            alignment: Alignment.center,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
              onPressed: () {},
            ),
          ),
        ),
        title: Text(
          'My Orders',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C2C2C),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Container(
          height: 100,
          padding: const EdgeInsets.all(8.0),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                height: 100,
                width: 328 / 2,
                margin: const EdgeInsets.only(top: 1, left: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  gradient: const LinearGradient(
                    begin: Alignment(-1.3, -1.7),
                    end: Alignment(1.061, 1.038),
                    colors: <Color>[
                      // ColorConstants.gradientGrayColor1,
                      // ColorConstants.gradientGrayColor2
                    ],
                    stops: <double>[0, 1],
                  ),
                ),
                child: const Center(
                    // child: Image.network(
                    //   "",
                    // ),
                    ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        "",
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Flexible(
                      child: Container(
                        child: Text(
                          "",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Flexible(
                      child: Text(
                        "",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
