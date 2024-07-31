import 'package:flutter/material.dart';

class TweetPage extends StatelessWidget {
  Future<void> _showMyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Dialog Title'),
          content: Text('This is a simple dialog message.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tweet Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Here is TweetPage'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showMyDialog(context);
              },
              child: Text('Show Dialog'),
            ),
          ],
        ),
      ),
    );
  }
}
