import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/colors/colors.dart';
import 'screens/inbox_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/auth/login_screen.dart';
import 'services/auth_service.dart';
import 'widgets/nav_icon.dart';
// import 'screens/no_partner_screen.dart';
import 'screens/timeline_screen.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {

  tz.initializeTimeZones();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: MaterialApp(
        title: 'Alonet App',
        theme: ThemeColors.lightTheme,
        darkTheme: ThemeColors.darkTheme,
        themeMode: ThemeMode.system,
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Initialize auth service when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthService>(context, listen: false).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        // Show loading screen while initializing
        if (authService.isLoading && authService.currentUser == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Show main app if authenticated, otherwise show login
        return authService.isAuthenticated
            ? const MainScreen()
            : const LoginScreen();
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const TimelineScreen(),
    const InboxScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(_titles[_currentIndex]),
      // ),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(32)),
        ),
        margin: const EdgeInsets.all(20),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(32)),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            iconSize: 28,
            showSelectedLabels: false,
            selectedItemColor: AppColors.primaryBlue,
            showUnselectedLabels: false,
            items: [
              NavIcon(
                iconPath: 'assets/icons/home.svg',
                activeCirclePath: 'assets/icons/highlight.svg',
                iconSize: 28,
                circleSize: 60,
                overallSize: 60,
              ).toNavBarItem(label: 'Timeline'),
              NavIcon(
                iconPath: 'assets/icons/inbox.svg',
                activeCirclePath: 'assets/icons/highlight.svg',
                iconSize: 28,
                circleSize: 60,
                overallSize: 60,
              ).toNavBarItem(label: 'Box'),
              NavIcon(
                iconPath: 'assets/icons/user.svg',
                activeCirclePath: 'assets/icons/highlight.svg',
                iconSize: 28,
                circleSize: 60,
                overallSize: 60,
              ).toNavBarItem(label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}
