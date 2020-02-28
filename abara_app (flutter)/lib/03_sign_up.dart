import 'package:abara_app/_main_app.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  var tecUserName = TextEditingController();
  var tecEmail = TextEditingController();
  var tecNewPassword = TextEditingController();
  String gender = '';
  int birthYear = 0;

  bool isPosting = false;

  @override
  void initState() {
    super.initState();
    if (isDebug) {
      tecUserName.text = '테스트';
      tecEmail.text = 'tester10@cha.ac.kr';
    }
  }

  @override
  void dispose() {
    tecUserName.dispose();
    tecEmail.dispose();
    tecNewPassword.dispose();
    super.dispose();
  }

  Future<void> post() async {
    if (isPosting) return;
    setState(() {
      isPosting = true;
    });

    await Future.delayed(duration1);

    try {
      var mapRequestBody = {
        'userName': tecUserName.text.trim(),
        'email': tecEmail.text.trim(),
        'newPassword': tecNewPassword.text,
        'gender': gender,
        'birthYear': birthYear.toString(),
      };

      var jd = await getJsonData(context, HttpMethod.post, 'user/sign-up', mapRequestBody);

      if (jd.isSuccess == false && isNotEmpty(jd.responseMessage)) {
        await displayAlert(mounted, context, jd.responseMessage);
      } else if (jd.isSuccess == true && isNotEmpty(jd.responseMessage) && jd.userVerification?.userVerificationId != null) {
        await displayAlert(mounted, context, jd.responseMessage);

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    UserVerificationPage(tecEmail.text.trim(), jd.responseMessage, jd.userVerification.userVerificationId)));
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
      p(ex);
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
        child: WillPopScope(
          onWillPop: () {
            if (tecUserName.text.isEmpty && tecEmail.text.isEmpty) {
              return Future<bool>.value(true);
            } else {
              return displayConfirm(mounted, context, '입력하던 내용이 있습니다',
                  dismissible: false, choiceCancel: '머무르기', choiceOk: '삭제하기');
            }
          },
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
                  CustomAppBar('SIGN UP', canPop: true),
                  H(35),
                  TN2('계정 만들기', 30, -0.75, Colors.black87),
                  H(30),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      style: textStyleTextField1,
                      decoration: InputDecoration(
                        labelText: 'Name',
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
                      controller: tecUserName,
                    ),
                  ),
                  H(30),
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
                      obscureText: true,
                      style: textStyleTextField1,
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
                      controller: tecNewPassword,
                    ),
                  ),
                  H(30),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28),
                    child: Row(
                      children: <Widget>[
                        TN2('GENDER', 18, 0, Colors.black87),
                        W(40),
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: Radio<String>(
                            activeColor: Colors.black,
                            value: 'M',
                            groupValue: gender,
                            onChanged: (String value) {
                              setState(() {
                                gender = value;
                              });
                            },
                          ),
                        ),
                        W(10),
                        TN2('남', 18, 0, Colors.black87),
                        W(29),
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: Radio<String>(
                            activeColor: Colors.black,
                            value: 'F',
                            groupValue: gender,
                            onChanged: (String value) {
                              setState(() {
                                gender = value;
                              });
                            },
                          ),
                        ),
                        W(10),
                        TN2('여', 18, 0, Colors.black87),
                      ],
                    ),
                  ),
                  H(9.5),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 0.5, color: Colors.black),
                  ),
                  H(15),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28),
                    child: Row(
                      children: <Widget>[
                        TN2('BIRTH YEAR', 18, 0, Colors.black87),
                        W(40),
                        PopupMenuButton<int>(
                          child: Container(
                            width: 100,
                            height: 40,
                            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                W(9),
                                if (birthYear == 0)
                                  TN2('선택', 18, 0, Color(0xDDffffff))
                                else
                                  TN2('$birthYear 년', 18, 0, Color(0xDDffffff)),
                                Icon(Icons.arrow_drop_down, color: Color(0xDDffffff)),
                              ],
                            ),
                          ),
                          onSelected: (value) async {
                            p(value);
                            setState(() {
                              birthYear = value;
                            });
                          },
                          color: Colors.black,
                          itemBuilder: (BuildContext context) {
                            List<int> listYear = [];
                            for (int y = DateTime.now().year - 10; y >= DateTime.now().year - 70; y--) {
                              listYear.add(y);
                            }
                            return listYear.map((int year) {
                              return PopupMenuItem<int>(
                                value: year,
                                child: TN2('$year 년', 18, 0, Color(0xDDffffff)),
                              );
                            }).toList();
                          },
                        ),
                      ],
                    ),
                  ),
                  H(9.5),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 0.5, color: Colors.black),
                  ),
                  H(35),
                  CustomFlatButton(
                    'NEXT',
                    onPressed: post,
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
