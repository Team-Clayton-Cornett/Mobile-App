import 'dart:convert';

import 'package:capstone_app/main.dart';
import 'package:flutter/material.dart';
import 'package:capstone_app/services/auth.dart';
import 'package:capstone_app/repositories/accountRepository.dart';
import 'package:capstone_app/models/account.dart';
import 'package:capstone_app/models/authentication.dart';
import 'package:capstone_app/style/appTheme.dart';
import 'package:capstone_app/components/handle.dart';

class AccountPage extends StatefulWidget {
  AccountPage({Key key}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  AccountRepository _accountRepo = AccountRepository.getInstance();
  TextStyle _style;
  Future<Account> accountFuture;
  Account _account;
  AuthArguments _args;

  TextEditingController _firstNameController;
  TextEditingController _lastNameController;
  TextEditingController _phoneController;
  GlobalKey<FormState> _formKey;

  @override
  initState() {
    super.initState();
//    _accountRepo.invalidateCurrentAccount();

    _style = getAppTheme().primaryTextTheme.body1;
    accountFuture = _accountRepo.getAccount();
    _formKey = GlobalKey<FormState>();

    accountFuture.then((Account account) async {
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

  void submit() {
    String email = _account.email;
    String firstName = _firstNameController.text;
    String lastName = _lastNameController.text;
    String phone = _phoneController.text;
    print("Submit function called");


    if (_formKey.currentState.validate()) {
      appAuth.updateAccount(email, firstName, lastName, phone).then((result) {
        setState(() {
          _account.firstName = firstName;
          _account.lastName = lastName;
          _account.phoneNumber = phone;
        });
        if (result != true) {
          print("Error");
          Widget okButton = FlatButton(
            child: Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          );

          AlertDialog alert = AlertDialog(
            title: Text("Error"),
            content: Text("Your settings have not been saved"),
            actions: [
              okButton,
            ],
          );

          showDialog(context: context,
            builder: (BuildContext context) {
              return alert;
            },
          );
        } else {
          Widget okButton = FlatButton(
            child: Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          );

          AlertDialog alert = AlertDialog(
            title: Text("Settings"),
            content: Text("Your settings have been saved successfully"),
            actions: [
              okButton,
            ],
          );

          showDialog(context: context,
            builder: (BuildContext context) {
              return alert;
            },
          );

          // Navigator.of(context).pushReplacementNamed('/home');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
//    _firstNameController = TextEditingController(text: _account.firstName);
//    _lastNameController = TextEditingController(text: _account.lastName);
//    _phoneController = TextEditingController(text: _account.phoneNumber);
    var futureBuilder = new FutureBuilder(
        future: accountFuture,
        builder: (BuildContext context, AsyncSnapshot<Account> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return new Text('Loading...');
          }
          if (snapshot.hasError) {
            return new Text('Error: ${snapshot.error}');
          }
          else {
            return createAccountSettingsPage(context, snapshot);
          }
        }
    );


    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          centerTitle: false,
          title: Text('Account Settings'),
          iconTheme: IconThemeData(
              color: Colors.white
          ),
        ),
        body: Container(
          child: futureBuilder,
        ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: getAppTheme().primaryColor,
              ),
              child: Text(
                'PARKR',
                style: TextStyle(
                  color: getAppTheme().accentColor,
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

  Widget createAccountSettingsPage(BuildContext context,
      AsyncSnapshot<Account> snapshot)  {
    _firstNameController = TextEditingController(text: _account.firstName);
    _lastNameController = TextEditingController(text: _account.lastName);
    _phoneController = TextEditingController(text: _account.phoneNumber);

    return SingleChildScrollView(
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              margin: const EdgeInsets.all(20.0),
              color: getAppTheme().primaryColor,
              child: Center(
//                onTap: () {
//                  print("Email Tapped");
//                },
                child: Text(_account.email, style: TextStyle(
                  color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500,),),
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              margin: const EdgeInsets.all(20.0),
              color: getAppTheme().primaryColor,
//            child: ListTile(
              child: TextFormField(
                controller: _firstNameController,

                validator: (firstName) {
                  if (firstName.isEmpty) {
                    return 'This field is required.';
                  }

                  if (firstName.length > 30) {
                    return 'First name cannot exceed 30 characters.';
                  }

                  return null;
                },
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0)
                  ),
                  hintText: _account.firstName,
                ),
                onTap: () {
                  // open edit first name
                  print("First Name Tapped");
                },
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              margin: const EdgeInsets.all(20.0),
              color: getAppTheme().primaryColor,
              child: TextFormField(
                controller: _lastNameController,
                validator: (lastName) {
                  if (lastName.isEmpty) {
                    return 'This field is required.';
                  }

                  if (lastName.length > 150) {
                    return 'Last name cannot exceed 150 characters.';
                  }

                  return null;
                },
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0)
                  ),
                  hintText: _account.lastName,
                ),
                onTap: () {
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              margin: const EdgeInsets.all(20.0),
              color: getAppTheme().primaryColor,
              child: TextFormField(
                controller: _phoneController,
                validator: (phone) {
                  RegExp phoneRegExp = RegExp(r'^\+?1?\d{9,15}$');

                  if (phone.isNotEmpty && !phoneRegExp.hasMatch(phone)) {
                    return 'Phone number must be entered in the format: \'+999999999\'.';
                  }

                  return null;
                },
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0)
                  ),
                  hintText: _account.phoneNumber,
                ),
                onTap: () {
                  // open edit first name
                  print("Phone Number Tapped");
                },
              )
          ),

          const SizedBox(height: 10.0),


          Center(
            child: Container(
              width: 200,
              child: Form(
                key: _formKey,
                child: Card(
                  // margin: const EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 16.0),
                  margin: const EdgeInsets.all(20.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(200.0)),
                  color: getAppTheme().accentColor,
                  child: Column(
                    children: <Widget>[
                      ListTile(

                        title: Text(
                          "Save Changes", textAlign: TextAlign.center,),
                        onTap: () {
                          // open change password
                          print("Save Changes Tapped");
                          submit();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10.0),
          Card(
            // margin: const EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 16.0),
            margin: const EdgeInsets.all(20.0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.lock_outline, color: Colors.blue,),
                  title: Text("Change Password"),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    // open change password
                    print("Change Password Tapped");
                    Navigator.pushNamed(
                        context,
                        '/forgot_password',
                        arguments: AuthArguments(
                            email: _account.email, token: null)
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
    );
  }
}


