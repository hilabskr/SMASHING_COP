import 'package:abara_app/_main_app.dart';

import 'package:intl/intl.dart';

class ChatRoomPage extends StatefulWidget {
  final User userFriend;
  final int chatRoomId;

  ChatRoomPage(this.userFriend, Key key, {this.chatRoomId}) : super(key: key);

  @override
  ChatRoomPageState createState() => ChatRoomPageState();
}

class ChatRoomPageState extends State<ChatRoomPage> {
  int chatRoomId;
  List<ChatMessage> listChatMessage = [];
  bool hasMoreList = true;

  bool isFirstLoading = true;
  String errorMessage;

  bool isIniting = false;
  bool isInited = false;
  bool isGettingDataAfter = false;
  bool isGettingDataBefore = false;
  bool isPosting = false;

  var scrollController = new ScrollController();

  var tecMessage = TextEditingController();
  bool isNewCountUpdatedOrAdded = false;

  @override
  void initState() {
    super.initState();
    initRoom();
  }

  @override
  void dispose() {
    tecMessage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    p('build ${this.runtimeType} ~~~~~~~~~~~~~~~~~~~~');

    return Scaffold(
      appBar: CustomAppBarBlank(),
      body: Scaffold(
        backgroundColor: Color(0xFFeeeeee),
        appBar: CustomAppBar('${widget.userFriend.userName}',
            canPop: true, backgroundColor: colorDarkYellow, elevation: 4, actions: null),
        body: SafeArea(
          child: (isFirstLoading)
              ? Center(child: CustomCircularProgressIndicator())
              : (errorMessage != null)
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          TN1('$errorMessage', 18, -0.45, Colors.black87),
                          H(25),
                          CustomFlatButton(
                            'RETRY',
                            onPressed: () async {
                              setState(() {
                                isFirstLoading = true;
                                errorMessage = null;
                              });
                              await Future.delayed(duration1);
                              await initRoom();
                            },
                          ),
                        ],
                      ),
                    )
                  : WillPopScope(
                      onWillPop: () async {
                        if (tecMessage.text.trim() == '') {
                          Navigator.pop(context, isNewCountUpdatedOrAdded);
                          return Future<bool>.value(false);
                        } else {
                          if (await displayConfirm(mounted, context, '입력하던 메시지가 있습니다',
                              dismissible: false, choiceCancel: '머무르기', choiceOk: '삭제하기')) {
                            Navigator.pop(context, isNewCountUpdatedOrAdded);
                          }
                          return Future<bool>.value(false);
                        }
                      },
                      child: AbsorbPointer(
                        absorbing: (isPosting),
                        child: Stack(
                          children: <Widget>[
                            buildContent(),
                            if (isGettingDataBefore || isPosting)
                              Center(child: CustomCircularProgressIndicator(size: 18, strokeWidth: 3)),
                          ],
                        ),
                      ),
                    ),
        ),
      ),
    );
  }

  Widget buildContent() {
    return Column(
      children: <Widget>[
        if (listChatMessage.length == 0)
          Expanded(
            child: Center(child: TN1('메시지가 없습니다', 18, -0.45, Colors.black87)),
          )
        else
          Expanded(
            child: buildListView(),
          ),
        ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: 42,
            maxHeight: 200,
          ),
          child: Row(
            children: <Widget>[
              W(7),
              Expanded(
                child: TextField(
                  style: textStyleTextField1,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    hintText: 'Type a message',
                    contentPadding: EdgeInsets.fromLTRB(15, 10, 0, 10),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50 / 2)),
                        borderSide: BorderSide(
                          color: Colors.black12,
                          width: 1,
                        )),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50 / 2)),
                        borderSide: BorderSide(
                          color: Colors.black12,
                          width: 1,
                        )),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50 / 2)),
                        borderSide: BorderSide(
                          color: Colors.black12,
                          width: 1,
                        )),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.send),
                      onPressed: post,
                    ),
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  controller: tecMessage,
                ),
              ),
              W(9),
            ],
          ),
        ),
        H(6.6),
      ],
    );
  }

  Widget buildListView() {
    return ListView.separated(
      reverse: true,
      controller: scrollController,
      padding: EdgeInsets.fromLTRB(3, 5, 3, 5),
      separatorBuilder: (context, i) {
        return H(1);
      },
      itemCount: listChatMessage.length + ((hasMoreList) ? 1 : 0),
      itemBuilder: (context, i) {
        if (hasMoreList && i == listChatMessage.length /*-1+1*/) {
          getDataAfter();
          return SizedBox(
            width: 30,
            height: 30,
            child: Center(
              child: CustomCircularProgressIndicator(size: 18, strokeWidth: 3),
            ),
          );
        } else {
          var chatMessage = listChatMessage[i];

          var containerNewDay = Container(
            margin: const EdgeInsets.only(top: 10),
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(color: Color(0x10000000), borderRadius: BorderRadius.circular(17)),
            child: TN1('${chatMessage.insertedAt.toString().substring(0, 10)}', 16, 0, Colors.black, maxLines: 1000, height: 1.3),
          );

          var displayTime = DateFormat('hh:mm a', 'en_US').format(chatMessage.insertedAt);

          if (chatMessage.isMyMessage == false) {
            return Column(
              children: <Widget>[
                if (chatMessage.isNewDay == true) containerNewDay,
                H(10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    W(6),
                    Padding(
                      padding: const EdgeInsets.only(top: 2.5),
                      child: (isNullOrEmpty(widget.userFriend.profileImage))
                          ? ICB('default_profile.png', 35, 0)
                          : CachedNetworkICB('user-resized-0184/${widget.userFriend.profileImage}', 35, 0),
                    ),
                    W(7),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(color: colorDarkYellow, borderRadius: BorderRadius.circular(17)),
                        child: TN1('${chatMessage.message}', 16, 0, Colors.black, maxLines: 1000, height: 1.3),
                      ),
                    ),
                    W(30),
                  ],
                ),
                H(5),
                Container(
                  margin: EdgeInsets.only(left: 57),
                  alignment: Alignment.centerLeft,
                  child: TN1('$displayTime', 10, 0.2, Color(0xFF546e7a)),
                ),
                H(10),
              ],
            );
          } else {
            return Column(
              children: <Widget>[
                if (chatMessage.isNewDay == true) containerNewDay,
                H(10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    W(60),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17)),
                        child: TN1('${chatMessage.message}', 16, 0, Colors.black, maxLines: 1000, height: 1.3),
                      ),
                    ),
                    W(6),
                  ],
                ),
                H(5),
                Container(
                  margin: EdgeInsets.only(right: 15),
                  alignment: Alignment.centerRight,
                  child: TN1('$displayTime', 10, 0.2, Color(0xFF546e7a)),
                ),
                H(10),
              ],
            );
          }
        }
      },
    );
  }

  Future<void> initRoom() async {
    if (isIniting) return;
    isIniting = true;

    if (widget.chatRoomId != null) {
      chatRoomId = widget.chatRoomId;
    } else {
      try {
        var jd = await getJsonData(context, HttpMethod.get, 'chat-room/open/${widget.userFriend.userId}');

        if (jd.isSuccess == true && jd.chatRoom.chatRoomId != null) {
          chatRoomId = jd.chatRoom.chatRoomId;
        } else if (jd.responseMessage != null) {
          errorMessage = jd.responseMessage;
        } else {
          throw new Exception();
        }
      } on UpdateNeededException catch (ex) {
        errorMessage = await processWithUpdateNeededException(mounted, context);
      } on AccessTokenExpiredException catch (ex) {
        errorMessage = '로그인이 만료되었습니다';
      } on SocketException catch (ex) {
        errorMessage = '서버에 접속할 수 없습니다';
      } on TimeoutException catch (ex) {
        errorMessage = '서버에 접속할 수 없습니다';
      } catch (ex) {
        p(ex);
        errorMessage = '에러가 발생하였습니다';
      }
    }

    if (errorMessage == null && chatRoomId != null) {
      try {
        var jd = await getJsonData(context, HttpMethod.get, 'chat-message/$chatRoomId/list');

        if (jd.listChatMessage == null) {
          throw new Exception();
        } else {
          listChatMessage = jd.listChatMessage;
          if (jd.isNewCountUpdated == true) isNewCountUpdatedOrAdded = true;
        }
      } on UpdateNeededException catch (ex) {
        errorMessage = await processWithUpdateNeededException(mounted, context);
      } on AccessTokenExpiredException catch (ex) {
        errorMessage = '로그인이 만료되었습니다';
      } on SocketException catch (ex) {
        errorMessage = '서버에 접속할 수 없습니다';
      } on TimeoutException catch (ex) {
        errorMessage = '서버에 접속할 수 없습니다';
      } catch (ex) {
        p(ex);
        errorMessage = '에러가 발생하였습니다';
      }
    }

    if (errorMessage == null && chatRoomId != null) {
      isInited = true;
    }

    if (mounted) {
      setState(() {
        if (isFirstLoading) isFirstLoading = false;
      });
    }

    isIniting = false;
  }

  Future<void> getDataAfter() async {
    if (isGettingDataAfter) return;

    isGettingDataAfter = true;

    p('~~~~~~~~~~~ getDataAfter()');

    try {
      var jd =
          await getJsonData(context, HttpMethod.get, 'chat-message/$chatRoomId/list?after=${listChatMessage.last.chatMessageId}');

      if (jd.listChatMessage == null) {
        throw new Exception();
      } else if (jd.listChatMessage.length == 0) {
        setState(() {
          hasMoreList = false;
        });
      } else {
        setState(() {
          listChatMessage.addAll(jd.listChatMessage);
        });
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
      p(ex);
      await displayAlert(mounted, context, '에러가 발생하였습니다');
    }

    isGettingDataAfter = false;
  }

  Future<void> getDataBefore() async {
    while (isGettingDataBefore) await Future.delayed(duration2);

    if (mounted) {
      setState(() {
        isGettingDataBefore = true;
      });
    }

    p('~~~~~~~~~~~ getDataBefore()');

    try {
      var query = (listChatMessage.length == 0) ? '' : '?before=${listChatMessage.first.chatMessageId}';

      var jd = await getJsonData(context, HttpMethod.get, 'chat-message/$chatRoomId/list$query');

      if (jd.listChatMessage == null) {
        throw new Exception();
      } else if (jd.listChatMessage.length == 0) {
      } else {
        isNewCountUpdatedOrAdded = true;

        if (listChatMessage.length == 0) {
          listChatMessage.insertAll(0, jd.listChatMessage);
        } else {
          listChatMessage.insertAll(0, jd.listChatMessage);
          scrollController.jumpTo(0);
        }
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
      p(ex);
      await displayAlert(mounted, context, '에러가 발생하였습니다');
    } finally {
      if (mounted) {
        setState(() {
          isGettingDataBefore = false;
        });
      }
    }
  }

  Future<void> post() async {
    await Future.delayed(duration1);

    if (isPosting) return;

    if (isNullOrWhiteSpace(tecMessage.text)) {
      await displayAlert(mounted, context, '메시지를 입력해주세요');
      return;
    }
    if (tecMessage.text.trim().length < 2) {
      await displayAlert(mounted, context, '메시지를 2글자 이상 입력해주세요');
      return;
    }

    setState(() {
      isPosting = true;
    });

    bool isSuccess = false;

    try {
      var mapRequestBody = {
        'message': tecMessage.text.trim(),
      };

      var jd = await getJsonData(context, HttpMethod.post, 'chat-message/$chatRoomId/add', mapRequestBody);

      if (jd.isSuccess == false && isNotEmpty(jd.responseMessage)) {
        await displayAlert(mounted, context, jd.responseMessage);
      } else if (jd.isSuccess == true) {
        isSuccess = true;
        tecMessage.clear();
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
      p(ex);
      await displayAlert(mounted, context, '에러가 발생하였습니다');
    } finally {
      if (isSuccess) {
        await getDataBefore();
      }

      if (mounted) {
        setState(() {
          isPosting = false;
        });
      }
    }
  }
}
