import "package:company_studio/components/my_drawer_tile.dart";
import "package:company_studio/screens/expenses_and_new_expense.dart";
import "package:company_studio/screens/home_screen.dart";
import "package:company_studio/screens/login_screen.dart";
import "package:company_studio/screens/materials.dart";
import "package:company_studio/screens/orders_and_new_order.dart";
import "package:company_studio/screens/orders_screen.dart";
import "package:company_studio/screens/vehicles.dart";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";


class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});


  Future<void> setLogOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("clickedLoggedOut", true );
  }


  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Stack(
              children: [
                Image.asset(
                  'asset/images/mrs_logo-3-nb.png', // The first image
                  width: 100,
                ),
                Positioned(
                  top: -3,
                  right: 10,
                  child: Image.asset(
                    'asset/images/login_image.png', // The second image
                    width: 50,  // Adjust the size to fit properly
                    height: 50,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Divider(
              color: Colors.white,
            ),
          ),

          MyDrawerTile(text: "Orders", icon: Icons.list, onTap: (){
            Navigator.pop(context);
            Navigator.push(context , MaterialPageRoute(builder: (context) =>  OrdersAndNewOrderScreen(),));
          } ),
          // MyDrawerTile(text: "Expenses", icon: Icons.attach_money, onTap: (){
          //   Navigator.pop(context);
          //   Navigator.push(context , MaterialPageRoute(builder: (context) => ExpensesAndNewExpenseScreen(),));
          // } ),
          MyDrawerTile(text: "Vehicles", icon: Icons.car_crash, onTap: (){
            Navigator.pop(context);
            Navigator.push(context , MaterialPageRoute(builder: (context) => const VehicleScreen(),));
            } ),
          MyDrawerTile(text: "Materials", icon: Icons.construction, onTap: (){
            Navigator.pop(context);
            Navigator.push(context , MaterialPageRoute(builder: (context) => const MaterialsScreen(),));
          } ),
          // MyDrawerTile(text: "Settings", icon: Icons.settings, onTap: ()
          // {
          //   Navigator.pop(context);
          //   Navigator.push(context,MaterialPageRoute(builder: (context) => const SettingsPage(),));
          // }
          // ),

          const Spacer(),
          MyDrawerTile(text: "Log Out", icon: Icons.logout, onTap: (){
            setLogOut();
            Navigator.pop(context);
            Navigator.push(context,MaterialPageRoute(builder: (context) => LoginScreen(onTap: () {},),));
          }),
        ],),

    );
  }
}