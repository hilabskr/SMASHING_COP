import 'package:abara_app/_main_app.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    p('build ${this.runtimeType} ~~~~~~~~~~~~~~~~~~~~');
    return Scaffold(
      backgroundColor: colorDarkYellow,
      body: SafeArea(
        child: Center(
          child: Column(
            children: <Widget>[
              CustomAppBarImage(),
              H(36),
              I('logo.png', 66, 121),
              H(13),
              TN1('Welcome', 60, 0, Colors.black87),
              H(13),
              TN1('Welcome to Abara', 20, -0.5, Colors.black87),
              TN1('Community for College Students.', 20, -0.5, Colors.black87),
              Expanded(
                child: Center(
                  child: CustomFlatButton(
                    'NEXT',
                    onPressed: () async {
                      await Future.delayed(duration1);

                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => new LoginPage()));
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
