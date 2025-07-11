import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'routes.dart';
import 'services/login.dart';
import 'services/weather.dart';
import 'services/vpn.dart';

void main() async {
  // Ensures that all Flutter bindings are initialized before any asynchronous operations (비동기 작업 전에 Flutter 바인딩 초기화 보장)
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Retrieve stored user credentials from persistent local storage (로컬 저장소에서 사용자 로그인 정보 불러오기)
  final prefs = await SharedPreferences.getInstance();
  final userEmail = prefs.getString('userEmail');
  final userPassword = prefs.getString('userPassword');

  final loginService = LoginService();

  // Auto-login if stored credentials exist and are valid (저장된 로그인 정보로 자동 로그인 시도)
  if (userEmail != null && userPassword != null) {
    final result = await loginService.loginUser(userEmail, userPassword);
    if (result['success']) {
      loginService.setUserData(userEmail);
    }
  }

  // Launch the application with dependency-injected services (서비스 주입 방식으로 앱 실행)
  runApp(App(
    loginService: loginService,
    weatherService: WeatherService(loginService),
    vpnService: VPNService(loginService),
  ));
}

class App extends StatelessWidget {
  final LoginService loginService;
  final WeatherService weatherService;
  final VPNService vpnService;

  const App({
    Key? key,
    required this.loginService,
    required this.weatherService,
    required this.vpnService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Register service instances with Provider for state management (상태 관리를 위한 서비스 인스턴스 등록)
      providers: [
        ChangeNotifierProvider.value(value: loginService),
        ChangeNotifierProvider.value(value: weatherService),
        ChangeNotifierProvider.value(value: vpnService),
      ],
      child: MaterialApp(
        // Conditionally route based on authentication state (로그인 상태에 따라 초기 라우팅 결정)
        initialRoute:
            loginService.isLoggedIn ? AppRoutes.main : AppRoutes.intro,
        // Register named routes (라우트 정의)
        routes: AppRoutes.routes,
      ),
    );
  }
}
