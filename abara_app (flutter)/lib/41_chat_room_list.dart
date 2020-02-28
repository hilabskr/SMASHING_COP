import 'package:abara_app/_main_app.dart';

class ChatRoomListPage extends StatefulWidget {
  final UserData userData;

  ChatRoomListPage(this.userData, Key key) : super(key: key);

  @override
  ChatRoomListPageState createState() => ChatRoomListPageState();
}

class ChatRoomListPageState extends State<ChatRoomListPage> {

  var sc = new StreamController<StreamData>();
  bool isGettingData = false;

  var swc = new SwiperController();

  @override
  void initState() {
    super.initState();
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
      if (refresh == true) {
        sc.add(new StreamData(isLoading: true));
      }

      var jd = await getJsonData(context, HttpMethod.get, 'chat-room/list');
      if (jd.listChatRoom == null) throw new Exception();
      sd.jd = jd;
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
      appBar: CustomAppBar('CHAT'),
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
                            await getData(refresh: true);
                          },
                        ),
                      ],
                    ),
                  );
                } else {
                  return buildSwiper(snapshot.data.jd.listChatRoom);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSwiper(List<ChatRoom> listChatRoom) {
    p('buildSwiper ~~~');
    return Swiper(
      controller: swc,
      loop: false,
      itemCount: listChatRoom.length,
      viewportFraction: 0.8,
      scale: 0.9,
      itemBuilder: (context, i) {
        var chatRoom = listChatRoom[i];

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
                                      bottom: 56,
                                      child: TN2('${chatRoom.userFriend.userName}', 18, -0.45, Colors.black87),
                                    ),
                                    Positioned(
                                      left: 18,
                                      bottom: 30,
                                      child:
                                          TN2('${chatRoom.lastChatMessage.message}', 12, -0.3, Colors.black87, maxLines: 1),
                                    ),
                                    Positioned(
                                      left: 18,
                                      bottom: 14,
                                      child: TN2('${chatRoom.lastChatMessage.insertedAtDiff}', 10, -0.25, Colors.black87),
                                    ),
                                    Positioned(
                                      right: 16,
                                      bottom: 17,
                                      child: I('message.png', 24, 24),
                                    ),
                                    if (chatRoom.userMeNewCount > 0)
                                      Positioned(
                                        left: 18,
                                        top: 18,
                                        width: 30,
                                        height: 30,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Color(0xFFff5700),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                              child: Padding(
                                            padding: const EdgeInsets.only(top: 2.5),
                                            child: TN2('${chatRoom.userMeNewCount}', 21, -0.45, Colors.white),
                                          )),
                                        ),
                                      ),
                                    if (chatRoom.relationshipScore != null && chatRoom.relationshipScore != -1)
                                      Positioned(
                                        top: -5,
                                        right: -12,
                                        child: TN1('${chatRoom.relationshipScore}', 100, -2.5, colorDarkYellow),
                                      ),
                                  ],
                                ),
                              ),
                              Flexible(
                                flex: 1,
                                child: Stack(
                                  children: <Widget>[
                                    if (isNullOrEmpty(chatRoom.userFriend.profileImage))
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
                                          imageUrl: '$imageUrl/user-resized-1020/${chatRoom.userFriend.profileImage}',
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

                                bool isNewCountUpdatedOrAdded = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ChatRoomPage(chatRoom.userFriend, globalKeyChatRoom,
                                            chatRoomId: chatRoom.chatRoomId)));
                                p('get back =============================================');
                                if (isNewCountUpdatedOrAdded == true) {
                                  await getData(refresh: true);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (chatRoom.relationshipScore != null && chatRoom.relationshipScore != -1)
                Positioned(
                  left: 0,
                  top: 0,
                  right: 0,
                  child: Center(child: I(getEmoji(chatRoom.relationshipScore), 80, 83)),
                ),
            ],
          ),
        );
      },
    );
  }
}
