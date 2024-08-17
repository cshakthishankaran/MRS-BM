import 'package:company_studio/components/my_drawer.dart';
import 'package:company_studio/screens/home_screen.dart';
import 'package:company_studio/screens/orders_screen.dart';
import 'package:flutter/material.dart';


class OrdersAndNewOrderScreen extends StatefulWidget {
  @override
  _OrdersAndNewOrderScreenState createState() => _OrdersAndNewOrderScreenState();
}

class _OrdersAndNewOrderScreenState extends State<OrdersAndNewOrderScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders Panel'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'New Order'),
            Tab(text: 'Orders'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          HomeScreen(), // First page content
          OrdersScreen(), // Second page content
        ],
      ),
      drawer: MyDrawer(),
    );
  }
}
