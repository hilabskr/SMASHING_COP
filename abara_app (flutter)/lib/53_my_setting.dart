import 'package:abara_app/_main_app.dart';

class MySettingPage extends StatefulWidget {
  @override
  _MySettingPageState createState() => _MySettingPageState();
}

class _MySettingPageState extends State<MySettingPage> {
  @override
  Widget build(BuildContext context) {
    p('build ${this.runtimeType} ~~~~~~~~~~~~~~~~~~~~');
    return Scaffold(
      appBar: CustomAppBarBlank(),
      body: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar('Setting', canPop: true),
        body: SafeArea(
          child: AbsorbPointer(
            absorbing: (isPosting),
            child: Stack(
              children: <Widget>[
                Consumer<UserData>(
                  builder: (_, userData, __) {
                    if (userData.shouldLogin)
                      return W(0);
                    else
                      return buildContent(context, userData);
                  },
                ),
                if (isPosting) Center(child: CustomCircularProgressIndicator()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildContent(BuildContext context, UserData userData) {
    return ListView(
      padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
      children: <Widget>[
        SizedBox(
          height: 48,
          child: FlatButton(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: Color(0xff000000),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                W(19),
                TN1('내 정보 관리', 16, 0, Colors.black),
                Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: I('arrow_right.png', 15, 13),
                ),
              ],
            ),
            onPressed: () async {
              await Future.delayed(duration1);
              await Navigator.push(context, MaterialPageRoute(builder: (context) => MySettingEditPage()));
            },
          ),
        ),
        H(20),
        SizedBox(
          height: 48,
          child: FlatButton(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: Color(0xff000000),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                W(19),
                TN1('약관 및 정책', 16, 0, Colors.black),
                Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: I('arrow_right.png', 15, 13),
                ),
              ],
            ),
            onPressed: () async {
              await Future.delayed(duration1);
              await Navigator.push(context, MaterialPageRoute(builder: (context) => MySettingTermsPage()));
            },
          ),
        ),
        H(20),
        SizedBox(
          height: 48,
          child: FlatButton(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: Color(0xff000000),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                W(19),
                TN1('알림설정', 16, 0, Colors.black),
                Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: I('arrow_right.png', 15, 13),
                ),
              ],
            ),
            onPressed: () async {
              await PermissionHandler().openAppSettings();
            },
          ),
        ),
        H(20),
        SizedBox(
          height: 48,
          child: FlatButton(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: Color(0xff000000),
                width: 2,
              ),
            ),
            child: (userData.user.allowOthersToFindMe == true)
                ? TN1('친구찾기 비활성화', 16, 0, Colors.black)
                : TN1('친구찾기 활성화', 16, 0, Colors.black),
            onPressed: () async {
              if ((userData.user.allowOthersToFindMe == true)) {
                if (await displayConfirm(mounted, context, '현재 친구찾기 활성화 상태입니다\n\n비활성화 시킬까요?')) {
                  await post("off");
                }
              } else {
                if (await displayConfirm(mounted, context, '현재 친구찾기 비활성화 상태입니다\n\n활성화 시킬까요?')) {
                  await post("on");
                }
              }
            },
          ),
        ),
        H(20),
        SizedBox(
          height: 48,
          child: FlatButton(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: Color(0xff000000),
                width: 2,
              ),
            ),
            child: TN1('로그아웃', 16, 0, Colors.black),
            onPressed: () async {
              try {
                if (await displayConfirm(mounted, context, '로그아웃할까요?')) {
                  await userData.logout();
                }
              } catch (ex) {
                p(ex);
                await displayAlert(mounted, context, '에러가 발생하였습니다');
              }
            },
          ),
        ),
        H(37),
        Align(
          alignment: Alignment.center,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TN1('버전', 16, 0, Colors.white),
                H(4),
                TN1('${userData.appVersion}', 20, 1, colorDarkYellow),
              ],
            ),
          ),
        ),
        H(25),
        Align(
          alignment: Alignment.center,
          child: TN1('IITP 과제번호 2017-0-00403', 16, 0, Colors.black),
        ),
        H(25),
      ],
    );
  }

  bool isPosting = false;

  Future<void> post(String allowOthersToFindMe) async {
    await Future.delayed(duration1);

    if (isPosting) return;
    setState(() {
      isPosting = true;
    });

    try {
      var mapRequestBody = {
        'allowOthersToFindMe': allowOthersToFindMe,
      };

      var jd = await getJsonData(context, HttpMethod.post, 'user/edit/me/allow-others-to-find-me', mapRequestBody);

      if (jd.isSuccess == false && isNotEmpty(jd.responseMessage)) {
        await displayAlert(mounted, context, jd.responseMessage);
      } else if (jd.isSuccess == true && jd.user != null) {
        if (isNotEmpty(jd.responseMessage)) {
          await displayAlert(mounted, context, jd.responseMessage);
        }

        await Provider.of<UserData>(context, listen: false).update(jd.user);
      } else {
        throw new Exception();
      }
    } on UpdateNeededException catch (ex) {
      await processWithUpdateNeededException(mounted, context);
    } on AccessTokenExpiredException catch (ex) {
      await displayAlert(mounted, context, '로그인이 만료되었습니다');
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
}
