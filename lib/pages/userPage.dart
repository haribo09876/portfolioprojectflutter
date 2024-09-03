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
            if (false)
              GestureDetector(
                onTap: () {},
                child: Text(
                  'DashboardPage로 이동',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w400),
                ),
              ),
            Text(
              'My Info',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 8),
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
                SizedBox(width: 8),
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
              'My Tweet',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 8),
            // 가로 스크롤 가능한 박스들 추가
            Container(
              height: 100, // 박스의 높이
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Container(
                    width: 100, // 박스의 너비
                    height: 100,
                    margin: EdgeInsets.only(right: 10),
                    color: Colors.grey,
                    child: Center(
                      child: Text(
                        'Box ${index + 1}',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              'My Insta',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 8),
            // 가로 스크롤 가능한 박스들 추가
            Container(
              height: 80, // 박스의 높이
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Container(
                    width: 80, // 박스의 너비
                    height: 100,
                    margin: EdgeInsets.only(right: 10),
                    color: Colors.grey,
                    child: Center(
                      child: Text(
                        'Box ${index + 1}',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              'My Item',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 8),
            // 가로 스크롤 가능한 박스들 추가
            Container(
              height: 150, // 박스의 높이
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Container(
                    width: 100, // 박스의 너비
                    height: 100,
                    margin: EdgeInsets.only(right: 10),
                    color: Colors.grey,
                    child: Center(
                      child: Text(
                        'Box ${index + 1}',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
