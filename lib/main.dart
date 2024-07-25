import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  // HTTP POST 요청을 보내는 함수
  Future<void> makePostRequest() async {
    var url = Uri.parse(
        'https://kc7a81mlbk.execute-api.ap-northeast-2.amazonaws.com/purchaseFunc');
    var data = {
      "action": "create",
      "userId": "80ed128b-195e-4560-a108-2827a1bc2f48",
      "itemId": "cd7c65b2-11b0-41c1-b728-6707bae3a3af",
      "purchaseStatus": "Purchased"
    };

    try {
      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        print('Response data: ${response.body}');
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter POST Example'),
      ),
      body: Center(
        child: Text('Press the button to make a POST request'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: makePostRequest, // 버튼을 누를 때 함수 호출
        tooltip: 'Send POST Request',
        child: Icon(Icons.send),
      ),
    );
  }
}
