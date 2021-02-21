import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Workrec'),
      ),
      body: Center(
        child: Text(
          '',
          style: Theme.of(context).textTheme.headline4,
        ),
      ),
    );
  }
}
