import 'package:flutter/material.dart';
import 'package:nexamobile_app/screens/home_screen.dart';
import 'package:nexamobile_app/screens/jadwal_screen.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class MyBottomNav extends StatefulWidget {
  const MyBottomNav({super.key});

  @override
  State<MyBottomNav> createState() => _MyBottomNavState();
}

class _MyBottomNavState extends State<MyBottomNav> {
  PersistentTabController controllertab =
      PersistentTabController(initialIndex: 0);

  List<Widget> buildScreens() {
    return [HomeScreen(), JadwalScreen()];
  }

  List<PersistentBottomNavBarItem> navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(
          Icons.house,
          size: 24,
        ),
        activeColorPrimary: Colors.white,
        activeColorSecondary: Colors.blue,
        inactiveColorPrimary: Colors.white,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(
          Icons.calendar_today,
          size: 24,
        ),
        activeColorPrimary: Colors.white,
        activeColorSecondary: Colors.blue,
        inactiveColorPrimary: Colors.white,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(
          Icons.message,
          size: 24,
        ),
        activeColorPrimary: Colors.white,
        activeColorSecondary: Colors.blue,
        inactiveColorPrimary: Colors.white,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(
          Icons.person,
          size: 24,
        ),
        activeColorPrimary: Colors.white,
        activeColorSecondary: Colors.blue,
        inactiveColorPrimary: Colors.white,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: controllertab,
      screens: buildScreens(),
      items: navBarsItems(),
      confineInSafeArea: true,
      backgroundColor: Colors.white,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardShows: true,
      popAllScreensOnTapOfSelectedTab: true,
      popActionScreens: PopActionScreensType.all,
      itemAnimationProperties: const ItemAnimationProperties(
        duration: Duration(milliseconds: 200),
        curve: Curves.ease,
      ),
      screenTransitionAnimation: const ScreenTransitionAnimation(
        animateTabTransition: true,
        curve: Curves.ease,
        duration: Duration(milliseconds: 200),
      ),
      navBarStyle: NavBarStyle.style7,
    );
  }
}
