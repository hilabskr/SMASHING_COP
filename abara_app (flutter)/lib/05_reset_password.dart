import 'package:abara_app/_main_app.dart';

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  var tecEmail = TextEditingController();

  bool isPosting = false;

  @override
  void initState() {
    super.initState();
    tecEmail.text = Provider.of<UserData>(context, listen: false).rememberEmail ?? '';
  }

  @override
  void dispose() {
    tecEmail.dispose();
    super.dispose();
  }

  Future<void> post() async {
    if (isPosting) return;

    await Future.delayed(duration1);

    if (await displayConfirm(mounted, context, '비밀번호 초기화를 요청하면\n\n새로운 암호가 설정되어 메일로 보내집니다',
            dismissible: false, choiceCancel: '취소', choiceOk: '요청') ==
        false) {
      return;
    }

    setState(() {
      isPosting = true;
    });

    try {
      var mapRequestBody = {
        'email': tecEmail.text.trim(),
      };

      var jd = await getJsonData(context, HttpMethod.post, 'user/reset-password', mapRequestBody);

      if (jd.isSuccess == false && isNotEmpty(jd.responseMessage)) {
        await displayAlert(mounted, context, jd.responseMessage);
      } else if (jd.isSuccess == true) {
        if (isNotEmpty(jd.responseMessage)) {
          await displayAlert(mounted, context, jd.responseMessage);
        }

        Provider.of<UserData>(context, listen: false).rememberEmail = tecEmail.text.trim();
        Provider.of<UserData>(context, listen: false).saveData();

        Navigator.pop(context);
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
                  CustomAppBar('Reset Password', canPop: true),
                  H(35),
                  TN2('비밀번호 초기화', 30, -0.75, Colors.black87),
                  H(62),
                  TN1('Forgot your membership information?', 18, 0, Colors.black87, height: 1.25),
                  H(8),
                  TN1('학교 이메일을 입력하세요.', 18, 0, Colors.black87, height: 1.25),
                  H(24),
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
                  H(41),
                  CustomFlatButton(
                    'OK',
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
