import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/colors/colors.dart';
import 'screens/inbox_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/auth/login_screen.dart';
import 'services/auth_service.dart';
import 'services/partner_service.dart';
import 'services/moment_service.dart';
import 'widgets/nav_icon.dart';
import 'screens/no_partner_screen.dart';
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => PartnerService()),
        ChangeNotifierProvider(create: (context) => MomentService()),
      ],
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
    // Initialize services when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final partnerService = Provider.of<PartnerService>(context, listen: false);
      final momentService = Provider.of<MomentService>(context, listen: false);

      authService.initialize().then((_) {
        // Once auth is initialized, load partner and moments if authenticated
        if (authService.isAuthenticated) {
          partnerService.getCurrentPartner();
          momentService.getMomentsForDate(DateTime.now());
        }
      });
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PartnerService>(
      builder: (context, partnerService, child) {
        // Show loading screen while checking partner status
        if (partnerService.isLoading && partnerService.currentPartner == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Show NoPartnerScreen if user doesn't have a partner
        if (!partnerService.hasPartner) {
          return const NoPartnerScreen();
        }

        // Show main app with navigation
        return _buildMainApp(context);
      },
    );
  }

  Widget _buildMainApp(BuildContext context) {
    final List<Widget> screens = [
      const TimelineScreen(),
      const InboxScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
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
