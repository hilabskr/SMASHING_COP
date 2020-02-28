import 'package:abara_app/_main_app.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var tecEmail = TextEditingController();
  var tecPassword = TextEditingController();

  bool isPosting = false;

  @override
  void initState() {
    super.initState();
    tecEmail.text = Provider.of<UserData>(context, listen: false).rememberEmail ?? '';
    if (isDebug) {
      tecPassword.text = '1111';
    }
  }

  @override
  void dispose() {
    tecEmail.dispose();
    tecPassword.dispose();
    super.dispose();
    p('dispose ~~~~~~');
  }

  Future<void> post() async {
    if (isPosting) return;
    setState(() {
      isPosting = true;
    });

    await Future.delayed(duration1);

    try {
      var mapRequestBody = {
        'email': tecEmail.text.trim(),
        'password': tecPassword.text,
      };

      var jd = await getJsonData(context, HttpMethod.post, 'user/login', mapRequestBody);

      if (jd.isSuccess == false && isNotEmpty(jd.responseMessage)) {
        await displayAlert(mounted, context, jd.responseMessage);
      } else if (jd.isSuccess == true) {
        if (isNotEmpty(jd.responseMessage)) {
          await displayAlert(mounted, context, jd.responseMessage);
        }

        await Provider.of<UserData>(context, listen: false).login(tecEmail.text.trim(), jd.accessToken, jd.user);

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => new MainScaffoldPage()));
      } else {
        throw new Exception();
      }
    } on UpdateNeededException catch (ex) {
      await processWithUpdateNeededException(mounted, context);
    } on SocketException catch (ex) {
      await displayAlert(mounted, context, '서버에 접속할 수 없습니다');
    } on TimeoutException catch (ex) {
      await displayAlert(mounted, context, '서버에 접속할 수 없습니다');
    } catch (ex) {
      await displayAlert(mounted, context, '에러가 발생하였습니다');
    } finally {
      if (mounted) {
        setState(() {
          isPosting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    p('build ${this.runtimeType} ~~~~~~~~~~~~~~~~~~~~');
    return Scaffold(
      backgroundColor: colorDarkYellow,
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: (isPosting),
          child: Stack(
            children: <Widget>[
              buildContent(),
              if (isPosting) Center(child: CustomCircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: <Widget>[
                  CustomAppBarImage(),
                  H(36),
                  I('logo.png', 52, 95),
                  H(31),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      style: textStyleTextField1,
                      decoration: InputDecoration(
                        labelText: 'School E-Mail',
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            borderSide: BorderSide(
                              color: Color(0x80000000),
                              width: 1,
                            )),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 2,
                            )),
                        contentPadding: EdgeInsets.all(20),
                      ),
                      controller: tecEmail,
                    ),
                  ),
                  H(30),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      style: textStyleTextField1,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            borderSide: BorderSide(
                              color: Color(0x80000000),
                              width: 1,
                            )),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 2,
                            )),
                        contentPadding: EdgeInsets.all(20),
                      ),
                      controller: tecPassword,
                    ),
                  ),
                  H(70),
                  InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.white,
                    child: TN2('FORGOT YOUR PASSWORD?', 14, 2, Colors.black87),
                    onTap: () async {
                      await Future.delayed(duration1);
                      await Navigator.push(context, MaterialPageRoute(builder: (context) => ResetPasswordPage()));
                      tecEmail.text = Provider.of<UserData>(context, listen: false).rememberEmail;
                    },
                  ),
                  H(16),
                  CustomFlatButton(
                    'LOGIN',
                    onPressed: post,
                  ),
                  H(14),
                  InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.white,
                    child: TN2('SIGN UP', 20, 2, Colors.black87, decoration: TextDecoration.underline),
                    onTap: () async {
                      await Future.delayed(duration1);

                      await Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
                      p('get back =============================================');
                      tecEmail.text = Provider.of<UserData>(context, listen: false).rememberEmail;
                    },
                  ),
                  Expanded(child: H(20)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
