import 'package:abara_app/_main_app.dart';

class UserVerificationPage extends StatefulWidget {
  final String email;
  final String message;
  final int userVerificationId;

  UserVerificationPage(this.email, this.message, this.userVerificationId, {Key key}) : super(key: key);

  @override
  _UserVerificationPageState createState() => _UserVerificationPageState();
}

class _UserVerificationPageState extends State<UserVerificationPage> {
  var tecVerificationCode = TextEditingController();

  bool isPosting = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    tecVerificationCode.dispose();
    super.dispose();
  }

  Future<void> post() async {
    if (isPosting) return;

    await Future.delayed(duration1);

    setState(() {
      isPosting = true;
    });

    try {
      var mapRequestBody = {
        'verificationCode': tecVerificationCode.text.trim(),
      };

      var jd = await getJsonData(
          context, HttpMethod.post, 'user/check-verification-code/${widget.userVerificationId}', mapRequestBody);

      if (jd.isSuccess == false && isNotEmpty(jd.responseMessage)) {
        await displayAlert(mounted, context, jd.responseMessage);
      } else if (jd.isSuccess == true) {
        if (isNotEmpty(jd.responseMessage)) {
          await displayAlert(mounted, context, jd.responseMessage);
        }

        Provider.of<UserData>(context, listen: false).rememberEmail = widget.email;
        Provider.of<UserData>(context, listen: false).saveData();

        Navigator.popUntil(context, (route) => route.isFirst);
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
                  CustomAppBar('SIGN UP', canPop: true),
                  H(35),
                  TN2('Verification Code', 30, -0.75, Colors.black87),
                  H(62),
                  TN1('${widget.message.split('\n')[0]}', 18, 0, Colors.black87, height: 1.25),
                  if (widget.message.split('\n').length >= 2)
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: TN1('${widget.message.split('\n')[1]}', 18, 0, Colors.black87, height: 1.25),
                    ),
                  if (widget.message.split('\n').length >= 3)
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: TN1('${widget.message.split('\n')[2]}', 18, 0, Colors.black87, height: 1.25),
                    ),
                  H(24),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      style: textStyleTextField1,
                      decoration: InputDecoration(
                        labelText: '보안코드',
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
                      controller: tecVerificationCode,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  H(41),
                  CustomFlatButton(
                    'COMPLETE',
                    color: Color(0xFFff5700),
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
