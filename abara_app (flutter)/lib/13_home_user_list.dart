import 'package:abara_app/_main_app.dart';

class HomeUserListPage extends StatefulWidget {
  @override
  _HomeUserListPageState createState() => _HomeUserListPageState();
}

class _HomeUserListPageState extends State<HomeUserListPage> {
  List<User> listUser = [];

  var sc = new StreamController<StreamData>();
  bool isGettingData = false;

  bool hasMoreList = true;
  int pageToQuery = 1;

  var swc = new SwiperController();

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

  Future<void> getData(/*{bool refresh = false}*/) async {
    if (isGettingData) return;

    isGettingData = true;

    p('~~~~~~~~~~~ getData()');
    var sd = new StreamData();

    try {

      var jd = await getJsonData(context, HttpMethod.get, 'user/list?page=$pageToQuery');
      if (jd.listUser == null) {
        throw new Exception();
      } else if (jd.listUser.length == 0) {
        hasMoreList = false;
      } else {
        for (var user in jd.listUser) {
          if (listUser.indexWhere((u) => u.userId == user.userId) == -1) listUser.add(user);
        }
        pageToQuery++;
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
      p(ex);
      sd.errorMessage = '에러가 발생하였습니다';
    }

    if (sc.isClosed == false) sc.add(sd);
    isGettingData = false;
  }

  @override
  Widget build(BuildContext context) {
    p('build ${this.runtimeType} ~~~~~~~~~~~~~~~~~~~~');
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: CustomAppBar('친구찾기', canPop: true),
      body: Column(
        children: <Widget>[
          Expanded(
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
                } else {
                  return buildSwiper();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSwiper() {
    p('buildSwiper ~~~');
    return Swiper(
      controller: swc,
      loop: false,
      itemCount: listUser.length + ((hasMoreList) ? 1 : 0),
      viewportFraction: 0.8,
      scale: 0.9,
      itemBuilder: (context, i) {
        if (hasMoreList && i == listUser.length /*-1+1*/) {
          getData();
          return SizedBox(
            width: 100,
            height: 100,
            child: Center(
              child: CustomCircularProgressIndicator(),
            ),
          );
        } else {
          var user = listUser[i];

          return Center(
            child: Stack(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(10, 20, 10, 35),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        spreadRadius: -3,
                        offset: Offset(3, 10),
                      ),
                    ],
                  ),
                  child: AspectRatio(
                    aspectRatio: 250 / 320,
                    child: Container(
                      color: Colors.black,
                      padding: EdgeInsets.all(2),
                      child: Container(
                        color: Colors.white,
                        child: Stack(
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Flexible(
                                  flex: 1,
                                  child: Stack(
                                    children: <Widget>[
                                      Positioned(
                                        left: 18,
                                        bottom: 35,
                                        child: TN2('${user.userName}', 18, -0.45, Colors.black87),
                                      ),
                                      Positioned(
                                        left: 18,
                                        bottom: 15,
                                        child: TN2('${user.schoolName}', 12, -0.3, Colors.black87),
                                      ),
                                      if (user.relationshipScore != null && user.relationshipScore != -1)
                                        Positioned(
                                          top: -5,
                                          right: -12,
                                          child: TN1('${user.relationshipScore}', 100, -2.5, colorDarkYellow),
                                        ),
                                    ],
                                  ),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: Stack(
                                    children: <Widget>[
                                      if (isNullOrEmpty(user.profileImage))
                                        Positioned(
                                          left: 0,
                                          top: 0,
                                          right: 0,
                                          bottom: 0,
                                          child: Image.asset('assets/images/default_profile.png', fit: BoxFit.cover),
                                        )
                                      else
                                        Positioned(
                                          left: 0,
                                          top: 0,
                                          right: 0,
                                          bottom: 0,
                                          child: CachedNetworkImage(
                                            imageUrl: '$imageUrl/user-resized-1020/${user.profileImage}',
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Container(color: Colors.grey[200]),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                highlightColor: Color(0x663366cc),
                                splashColor: Color(0x663366cc),
                                onTap: () async {
                                  await Future.delayed(duration1);

                                  await globalKeyNavigatorMain.currentState
                                      .push(MaterialPageRoute(builder: (context) => ChatRoomPage(user, globalKeyChatRoom)));
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (user.relationshipScore != null && user.relationshipScore != -1)
                  Positioned(
                    left: 0,
                    top: 0,
                    right: 0,
                    child: Center(child: I(getEmoji(user.relationshipScore), 80, 83)),
                  ),
              ],
            ),
          );
        }
      },
    );
  }
}
