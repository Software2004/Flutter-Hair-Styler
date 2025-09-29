import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'account_screen.dart';
import 'ai_recommendation_tab.dart';
import 'home_tab.dart';
import 'my_styles_screen.dart'; // Added import for MyStylesScreen

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late final PageStorageBucket _bucket;
  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _bucket = PageStorageBucket();
    // Keep a single instance of each tab to preserve state
    _tabs = const [
      HomeTab(key: ValueKey('tab_home')),
      AIRecommendationTab(key: ValueKey('tab_ai')),
      MyStylesScreen(key: ValueKey('tab_my_styles')),
      AccountScreen(key: ValueKey('tab_account')),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure system status/navigation bars match current theme background
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).colorScheme.background;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: bgColor,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: bgColor,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    if (!isLandscape) {
      return Scaffold(
        body: PageStorage(
          bucket: _bucket,
          child: IndexedStack(index: _currentIndex, children: _tabs),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
              showUnselectedLabels: true,
              selectedLabelStyle: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(fontWeight: FontWeight.w600, height: 1.5),
              unselectedLabelStyle: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(fontWeight: FontWeight.w400, height: 1.5),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.auto_awesome_outlined),
                  activeIcon: Icon(Icons.auto_awesome),
                  label: 'AI Styler',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.folder_open_outlined),
                  activeIcon: Icon(Icons.folder),
                  label: 'My Styles',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle_outlined),
                  activeIcon: Icon(Icons.account_circle),
                  label: 'Account',
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Landscape with a left-side NavigationRail
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              backgroundColor: Theme.of(context).colorScheme.background,
              selectedIndex: _currentIndex,
              onDestinationSelected: (i) => setState(() => _currentIndex = i),
              selectedIconTheme: IconThemeData(
                color: Theme.of(context).colorScheme.primary,
              ),
              unselectedIconTheme: IconThemeData(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              indicatorColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
              labelType: NavigationRailLabelType.all,
              groupAlignment: 0.0,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.auto_awesome_outlined),
                  selectedIcon: Icon(Icons.auto_awesome),
                  label: Text('AI'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.folder_open_outlined),
                  selectedIcon: Icon(Icons.folder),
                  label: Text('My Styles'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.account_circle_outlined),
                  selectedIcon: Icon(Icons.account_circle),
                  label: Text('Account'),
                ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: PageStorage(
                bucket: _bucket,
                child: IndexedStack(index: _currentIndex, children: _tabs),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
