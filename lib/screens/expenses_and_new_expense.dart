import 'package:company_studio/components/my_drawer.dart';
import 'package:company_studio/screens/expeneses_screen.dart';
import 'package:company_studio/screens/home_screen.dart';
import 'package:company_studio/screens/orders_screen.dart';
import 'package:flutter/material.dart';


class ExpensesAndNewExpenseScreen extends StatefulWidget {
  @override
  _ExpensesAndNewExpenseScreenState createState() => _ExpensesAndNewExpenseScreenState();
}

class _ExpensesAndNewExpenseScreenState extends State<ExpensesAndNewExpenseScreen> with SingleTickerProviderStateMixin {
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
        title: Text('Expenses Panel'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'New Expense'),
            Tab(text: 'Expenses'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          HomeScreen(), // First page content
          ExpensesScreen(), // Second page content
        ],
      ),
      drawer: MyDrawer(),
    );
  }
}
