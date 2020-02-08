import "package:flutter/material.dart";

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool email = false;
  bool password = false;
  String emailT = 'Your Email';
  String passwordT = 'Your Password';
  final usercontroller = TextEditingController();
  final passwordcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("profile"),
        centerTitle: true,
        backgroundColor: Colors.grey,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.spaceEvenly,

            children: <Widget>[
              CircleAvatar(
                //backgroundImage: AssetImage("assets/images/guest.bmp"),
                maxRadius: 50.0,
              ),
              SizedBox(
                height: 20.0,
              ),
              email == false
                  ? Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(emailT),
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                setState(() {
                                  email = true;
                                  usercontroller.text = emailT;
                                });
                              },
                            )
                          ],
                        ),
                      ),
                    )
                  : TextField(
                      controller: usercontroller,
                      onSubmitted: (_) {},
                      decoration: InputDecoration(labelText: 'Email'),
                    ),
              SizedBox(
                height: 10.0,
              ),
              password == false
                  ? Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(passwordT),
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                setState(() {
                                  password = true;
                                  passwordcontroller.text = passwordT;
                                });
                              },
                            )
                          ],
                        ),
                      ),
                    )
                  : TextField(
                      controller: passwordcontroller,
                      onSubmitted: (_) {},
                      decoration: InputDecoration(labelText: 'Password'),
                    ),
              SizedBox(
                height: 20.0,
              ),
              RaisedButton(
                onPressed: () {
                  setState(() {
                    email = false;
                    password = false;
                  });
                },
                color: Colors.blue,
                child: Text('Save',
                    style: TextStyle(
                      color: Colors.white,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
