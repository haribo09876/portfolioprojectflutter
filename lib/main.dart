import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'routes.dart';
import 'services/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // 자동 로그인 처리
  final prefs = await SharedPreferences.getInstance();
  final userEmail = prefs.getString('userEmail');
  final userPassword = prefs.getString('userPassword');

  final loginService = LoginService();
  if (userEmail != null && userPassword != null) {
    final result = await loginService.loginUser(userEmail, userPassword);
    if (result['success']) {
      loginService.setUserData(userEmail);
    }
  }

  runApp(App(loginService: loginService));
}

class App extends StatelessWidget {
  final LoginService loginService;

  const App({Key? key, required this.loginService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: loginService),
      ],
      child: MaterialApp(
        initialRoute:
            loginService.isLoggedIn ? AppRoutes.main : AppRoutes.intro,
        routes: AppRoutes.routes,
      ),
    );
  }
}
