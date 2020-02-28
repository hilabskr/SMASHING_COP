import 'package:abara_app/_main_app.dart';

class MyNotificationPage extends StatefulWidget {
  @override
  _MyNotificationPageState createState() => _MyNotificationPageState();
}

class _MyNotificationPageState extends State<MyNotificationPage> {
  List<PersonalNotification> listPersonalNotification = [];

  var sc = new StreamController<StreamData>();
  bool isGettingData = false;

  bool hasMoreList = true;

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void dispose() {
    sc.close();
    super.dispose();
  }

  Future<void> getData({bool refresh = false}) async {
    while (isGettingData) await Future.delayed(duration2);
    isGettingData = true;

    p('~~~~~~~~~~~ getData()');
    var sd = new StreamData();

    try {
      var query = (listPersonalNotification.length == 0) ? '' : '?after=${listPersonalNotification.last.personalNotificationId}';

      var jd = await getJsonData(context, HttpMethod.get, 'personal-notification/list$query');
      if (jd.listPersonalNotification == null) {
        throw new Exception();
      } else if (jd.listPersonalNotification.length == 0) {
        hasMoreList = false;
      } else {
        listPersonalNotification.addAll(jd.listPersonalNotification);
      }
    } on UpdateNeededException catch (ex) {
      sd.errorMessage = await processWithUpdateNeededException(mounted, context);
    } on AccessTokenExpiredException catch (ex) {
      sd.errorMessage = '로그인이 만료되었습니다';
    } on SocketException catch (ex) {
      sd.errorMessage = '서버에 접속할 수 없습니다';
    } on TimeoutException catch (ex) {
      sd.errorMessage = '서버에 접속할 수 없습니다';
    } catch (ex) {
      sd.errorMessage = '에러가 발생하였습니다';
    }

    if (sc.isClosed == false) sc.add(sd);
    isGettingData = false;
  }

  @override
  Widget build(BuildContext context) {
    p('build ${this.runtimeType} ~~~~~~~~~~~~~~~~~~~~');
    return Scaffold(
      appBar: CustomAppBarBlank(),
      body: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar('Notifications', canPop: true),
        body: SafeArea(
          child: StreamBuilder<StreamData>(
            stream: sc.stream,
            initialData: new StreamData(isLoading: true),
            builder: (context, snapshot) {
              if (snapshot.data.isLoading == true) {
                return Center(child: CustomCircularProgressIndicator());
              } else if (snapshot.data.errorMessage != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TN1('${snapshot.data.errorMessage}', 20, 0, Colors.black87),
                      H(25),
                      CustomFlatButton(
                        'RETRY',
                        onPressed: () async {
                          await Future.delayed(duration1);
                          sc.add(new StreamData(isLoading: true));
                          await getData();
                        },
                      ),
                    ],
                  ),
                );
              } else if (listPersonalNotification.length == 0) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 42),
                    child: TN1('알림이 없습니다', 20, -0.5, Colors.black87),
                  ),
                );
              } else {
                return buildListView();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget buildListView() {

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
      itemCount: listPersonalNotification.length + ((hasMoreList) ? 1 : 0),
      itemBuilder: (context, i) {
        if (hasMoreList && i == listPersonalNotification.length /*-1+1*/) {
          getData();
          return SizedBox(
            width: 100,
            height: 100,
            child: Center(
              child: CustomCircularProgressIndicator(),
            ),
          );
        } else {
          var pn = listPersonalNotification[i];
          return Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(19, 10, 19, 13),
                color: (pn.hasChecked == false) ? Color(0x19f8cf00) : Colors.white,
                child: Row(
                  children: <Widget>[
                    (isNullOrEmpty(pn.fromUser.profileImage))
                        ? ICB('default_profile.png', 46, 2)
                        : CachedNetworkICB('user-resized-0184/${pn.fromUser.profileImage}', 46, 2),
                    W(11),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${pn.content}',
                              style: TextStyle(
                                fontFamily: 'NanumBarunpenB',
                                fontSize: 14,
                                letterSpacing: -0.35,
                                color: Colors.black87,
                                height: 18 / 14,
                              ),
                            ),
                            TextSpan(
                              text: '   ${pn.insertedAtDiff}',
                              style: TextStyle(
                                fontFamily: 'NanumBarunpenR',
                                fontSize: 14,
                                letterSpacing: 0,
                                color: Colors.black87,
                                height: 18 / 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(height: 1, color: Color(0xffE5E5E5)),
            ],
          );
        }
      },
    );
  }
}
