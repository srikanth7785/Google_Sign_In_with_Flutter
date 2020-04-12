import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

var displayName = "no one";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}


AuthResult authResult;


class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  bool signedIn = false;
  
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _handleSignIn() async {
    final GoogleSignInAccount googleUser = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential _credential = GoogleAuthProvider.getCredential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );
    
    authResult = await firebaseAuth.signInWithCredential(_credential).then((v){
      print("V Value is : $v\n\n");
      var userData = {
        'name' : v.user.displayName,
        'photoUrl' : v.user.photoUrl,
        'mail' : v.user.email,
      };
      Firestore.instance.collection('users').add(userData).catchError((e) => print(e)).then((v) {
        print("\n\nWritten Succesfully : ${v.documentID} \n\n");
      });
      setState((){
        displayName = v.user.displayName;
        signedIn = true;
      });
      return v;
    });

  }

  void _handleSignOut() async {
    await googleSignIn.disconnect();
      setState((){
        displayName = "Signed Out";
        print("PHONE NUMBER IS : ${authResult.user.metadata.creationTime}");
        // authResult.user.delete();
        signedIn = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              // style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              authResult != null ? authResult.user.displayName : ""
            ),
            signedIn ? RaisedButton(
              child: Text("Sign Out"),
              onPressed: (){
                _handleSignOut();
              },
            ) :
            RaisedButton(
              child: Text("Sign In"),
              onPressed: (){
                _handleSignIn();
              },
            ),
            signedIn ? Text(authResult.user.email) : Text("NO EMAIL"),
            signedIn ? Container(
              child: Image.network(authResult.user.photoUrl)) 
              : Container(color: Colors.red, height: 20, width: 20,)
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
