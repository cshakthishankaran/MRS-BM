import 'package:company_studio/components/my_drawer.dart';
import 'package:company_studio/screens/customers_balance.dart';
import 'package:company_studio/screens/customers_screen.dart';
import 'package:flutter/material.dart';

class CustomersAndBalanceScreen extends StatefulWidget {
  const CustomersAndBalanceScreen({super.key});

  @override
  State<CustomersAndBalanceScreen> createState() => _CustomersAndBalanceScreenState();
}

class _CustomersAndBalanceScreenState extends State<CustomersAndBalanceScreen> with SingleTickerProviderStateMixin {

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
        title: Text('Manage Customers'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Customers'),
            Tab(text: 'Balance'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          CustomersScreen(), // First page content
          CustomersBalanceScreen(), // Second page content
        ],
      ),
      drawer: MyDrawer(),
    );
  }
}
