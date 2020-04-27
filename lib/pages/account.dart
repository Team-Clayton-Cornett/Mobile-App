import 'package:flutter/material.dart';
import 'package:capstone_app/services/auth.dart';
import 'package:capstone_app/repositories/accountRepository.dart';
import 'package:capstone_app/models/account.dart';
import 'package:capstone_app/models/authentication.dart';

class AccountPage extends StatefulWidget {
  AccountPage({Key key}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  AccountRepository _accountRepo = AccountRepository.getInstance();

  Future<Account> accountInfo;
  Account _account;
  AuthArguments _args;

  @override
  initState() {
    super.initState();

    accountInfo = _accountRepo.getAccount();

    accountInfo.then((Account account) async {
      setState(() {
        _account = account;
      });

  }).catchError((error) {
      debugPrint('Error getting user info');

      SnackBar snackBar = SnackBar(
      content: Text('Could not connect to server'),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
    _scaffoldKey.currentState.showSnackBar(snackBar);
    });

  });

  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: false,
        title: Text('Account Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Text(
                "Email",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                margin: const EdgeInsets.all(20.0),
                color: Colors.lightBlue,
            child: ListTile(
//                child: TextFormField(
//                  style: TextStyle(
//                    color: Colors.white,
//                    fontWeight: FontWeight.w500,
//                  ),
//                  decoration: InputDecoration(
//                    contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
//                    hintText: _account.email,
//                  ),
                  onTap: (){
                    // open edit first name
                    print("First Name Tapped");
                  },
              title: Text(_account.email, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500,),),
                )
            ),

            Center(
              child: Text(
                "First Name",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            margin: const EdgeInsets.all(20.0),
            color: Colors.lightBlue,
//            child: ListTile(
             child: TextFormField(
               style: TextStyle(
                 color: Colors.white,
                 fontWeight: FontWeight.w500,
               ),
               decoration: InputDecoration(
                   contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                   hintText: _account.firstName,
               ),
              onTap: (){
                // open edit first name
                print("First Name Tapped");
              },
//            title: Text("John", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500,),),
//            trailing: Icon(Icons.edit, color: Colors.white,),
            )
          ),

            Center(
              child: Text(
                "Last Name",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              margin: const EdgeInsets.all(20.0),
              color: Colors.lightBlue,
                child: TextFormField(
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    hintText: _account.lastName,
                  ),
                  onTap: (){
                    // open edit first name
                    print("Last Name Tapped");
                  },
                )
            ),

            Center(
              child: Text(
                "Phone Number",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              margin: const EdgeInsets.all(20.0),
              color: Colors.lightBlue,
                child: TextFormField(
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    hintText: _account.phoneNumber,
                  ),
                  onTap: (){
                    // open edit first name
                    print("Phone Number Tapped");
                  },
                )
            ),

            const SizedBox(height: 10.0),
            Card(
             // margin: const EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 16.0),
              margin: const EdgeInsets.all(20.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.lock_outline, color: Colors.blue,),
                    title: Text("Change Password"),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: (){
                      // open change password
                      print("Change Password Tapped");
                      Navigator.pushNamed(
                          context,
                          '/forgot_password/reset',
                          arguments: AuthArguments(email: _account.email, token: null)
                      );
                    },
                  ),
                ],
              ),
            ),
//            const SizedBox(height: 10.0),
//            Text("Notification Settings", style: TextStyle(
//              fontSize: 20.0,
//              fontWeight: FontWeight.bold,
//              color: Colors.blue,
//            ),),
//            SwitchListTile(
//              activeColor: Colors.blue,
//              contentPadding: const EdgeInsets.all(0),
//              value: true,
//              title: Text("Receive notifications"),
//              onChanged: (val){
//                // notification settings
//              },
//            ),
        ],
       ),
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'App Name',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: (){
                Navigator.of(context).pushReplacementNamed('/home');
              },
            ),
            ListTile(
              leading: Icon(Icons.report),
              title: Text('Report'),
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('History'),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(context, "/history", (r) => false);
              },
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Account'),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(context, "/account", (r) => false);
              },
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('About'),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(context, "/about", (r) => false);
              },
            ),
            ListTile(
              leading: Icon(Icons.directions_run),
              title: Text('Sign Out'),
              onTap: () {
                AuthService appAuth = new AuthService();
                appAuth.logout();

                Navigator.pushNamedAndRemoveUntil(context, "/login", (r) => false);
              },
            ),
          ],
        ),
      ),

    );
  }
}