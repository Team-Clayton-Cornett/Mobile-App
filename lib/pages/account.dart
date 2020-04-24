import 'package:flutter/material.dart';
import 'package:capstone_app/models/account.dart';

class AccountPage extends StatelessWidget {
//  String email;
//  String password;
//  String fname;
//  String lname;
//  String phoneNumber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue,
        title: Text('Account Settings', style: TextStyle(color: Colors.white),),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            margin: const EdgeInsets.all(8.0),
            color: Colors.blue,
            child: ListTile(
              onTap: (){
                // open edit profile

              },
            title: Text("John Doe", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500,),),
            trailing: Icon(Icons.edit, color: Colors.white,),
            )
          ),
            const SizedBox(height: 10.0),
            Card(
              margin: const EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 16.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.lock_outline, color: Colors.blue,),
                    title: Text("Change Password"),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: (){
                      // open change password
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10.0),
            Text("Notification Settings", style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),),
            SwitchListTile(
              activeColor: Colors.blue,
              contentPadding: const EdgeInsets.all(0),
              value: true,
              title: Text("Receive notifications"),
              onChanged: (val){
                // notification settings
              },
            ),
        ],
       ),
      ),
    );
  }
}