import 'package:flutter/material.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  String? avatar;
  String userName = 'Anonymous';
  int money = 0;

  @override
  void initState() {
    super.initState();
  }

  void onAvatarChange() {
    print('Avatar change clicked');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Page'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (/* 사용자 UID가 특정 값인 경우 */ false)
              GestureDetector(
                onTap: () {},
                child: Text(
                  'DashboardPage로 이동',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w400),
                ),
              ),
            Text(
              'My Info',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w400),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: onAvatarChange,
                  child: Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: avatar != null
                        ? ClipOval(
                            child: Image.network(
                              avatar!,
                              width: 65,
                              height: 65,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.account_circle,
                            size: 40,
                            color: Colors.white,
                          ),
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  userName,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    print('Edit name clicked');
                  },
                ),
                Spacer(),
                Text(
                  '$money 원',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'My Instas',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 20),
            Text(
              'My Tweets',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 20),
            Text(
              'My Sales',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }
}
