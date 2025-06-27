import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:impaxt_alert/pages/utils/index.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PageController controller;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    controller = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  void onPageChanged(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  void onBottomNavTap(int index) {
    controller.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: controller,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: onPageChanged,
        children: [
          Container(color: Colors.blue),
          Container(color: Colors.red),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: blue,
        currentIndex: _currentPageIndex,
        onTap: onBottomNavTap,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'profilo'),
        ],
      ),
    );
  }
}
