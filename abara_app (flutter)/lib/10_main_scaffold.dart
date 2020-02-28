import 'package:abara_app/_main_app.dart';

class MainScaffoldPage extends StatefulWidget {

  @override
  MainScaffoldPageState createState() => MainScaffoldPageState();
}

class MainScaffoldPageState extends State<MainScaffoldPage> with WidgetsBindingObserver {
  int selectedMenu = 0;
  bool isActive;
  Timer timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    isActive = true;
    sendActiveSignal();

    Provider.of<UserData>(context, listen: false).updateSession();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);

    cancelTimer();

    p('dispose ~~~~~~ MainScaffoldPageState');
  }

  Future<void> sendActiveSignal() async {
    p('sendActiveSignal() isActive == $isActive');
    if (isActive == true) {
      cancelTimer();

      await Provider.of<UserData>(context, listen: false).updateCurrentActiveUser();

      timer = new Timer(Duration(seconds: 30), sendActiveSignal);
    }
  }

  void cancelTimer() {
    p('timer?.isActive ${timer?.isActive}');
    if (timer?.isActive == true) {
      timer.cancel();
      p('timer.cancel()');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    p(this.toString() + ' ~~~~~~~~~~~~~~~~~ ' + state.toString());
    switch (state) {
      case AppLifecycleState.resumed:
        await refreshState();
        isActive = true;
        await sendActiveSignal();
        break;
      case AppLifecycleState.inactive:
        isActive = false;
        break;
      case AppLifecycleState.paused:
        isActive = false;
        break;
      case AppLifecycleState.suspending:
        isActive = false;
        break;
    }
  }

  Future<void> refreshState() async {
    if (globalKeyChatRoom.currentState != null && globalKeyChatRoom.currentState.isInited == true) {
      await globalKeyChatRoom.currentState.getDataBefore();
    } else if (globalKeyChatRoomList.currentState != null) {
      await globalKeyChatRoomList.currentState.getData(refresh: true);
    } else {
    }
  }

  @override
  Widget build(BuildContext context) {
    p('build !! MainScaffoldPageState ~~~~~~~~~~~~~~~~~~~~');
    return WillPopScope(
      onWillPop: () {
        if (selectedMenu == 0 && globalKeyNavigatorMenu0.currentState.canPop()) {
          globalKeyNavigatorMenu0.currentState.pop();
          return Future<bool>.value(false);
        } else {
          return Future<bool>.value(true);
        }
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Consumer<UserData>(
            builder: (context, userData, child) {
              if (userData.shouldLogin)
                return W(0);
              else
                return Material(
                  color: colorDarkYellow,
                  child: IndexedStack(
                    index: selectedMenu,
                    children: <Widget>[
                      Navigator(
                        key: globalKeyNavigatorMenu0,
                        onGenerateRoute: (route) => MaterialPageRoute(
                          builder: (context) => HomePage(userData),
                        ),
                      ),
                      BookmarkPage(userData, globalKeyBookmark),
                      ArticleAddCategoryPage(userData),
                      ChatRoomListPage(userData, globalKeyChatRoomList),
                      MyPage(userData, globalKeyMy),
                    ],
                  ),
                );
            },
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: InkWell(
            child: I((selectedMenu == 2) ? 'icon_menu_fab_on.png' : 'icon_menu_fab.png', 78, 78),
            onTap: () {
              onTap(2);
            },
          ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                height: 2,
                color: Colors.black,
              ),
              Container(
                height: 54,
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    SizedBox(
                      width: 54,
                      height: 54,
                      child: FlatButton(
                        padding: EdgeInsets.all(0),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onPressed: () {
                          onTap(0);
                        },
                        child: Column(
                          children: <Widget>[
                            H(5),
                            (selectedMenu == 0) ? I('icon_menu_home_on.png', 24, 24) : I('icon_menu_home.png', 24, 24),
                            TN2('HOME', 14, 0, Colors.black),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 54,
                      height: 54,
                      child: FlatButton(
                        padding: EdgeInsets.all(0),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onPressed: () {
                          onTap(1);
                        },
                        child: Column(
                          children: <Widget>[
                            H(5),
                            (selectedMenu == 1) ? I('icon_menu_favorite_on.png', 24, 24) : I('icon_menu_favorite.png', 24, 24),
                            TN2('SAVE', 14, 0, Colors.black),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 54,
                      height: 54,
                      child: FlatButton(
                        padding: EdgeInsets.all(0),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onPressed: () {
                          onTap(2);
                        },
                        child: Column(
                          children: <Widget>[
                            H(5),
                            H(24),
                            TN2('CREATE', 14, 0, Colors.black),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 54,
                      height: 54,
                      child: FlatButton(
                        padding: EdgeInsets.all(0),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onPressed: () {
                          onTap(3);
                        },
                        child: Column(
                          children: <Widget>[
                            H(5),
                            (selectedMenu == 3) ? I('icon_menu_chat_on.png', 24, 24) : I('icon_menu_chat.png', 24, 24),
                            TN2('CHAT', 14, 0, Colors.black),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 54,
                      height: 54,
                      child: FlatButton(
                        padding: EdgeInsets.all(0),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onPressed: () {
                          onTap(4);
                        },
                        child: Column(
                          children: <Widget>[
                            H(5),
                            (selectedMenu == 4) ? I('icon_menu_my_on.png', 24, 24) : I('icon_menu_my.png', 24, 24),
                            TN2('MY', 14, 0, Colors.black),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onTap(int index) async {
    if (selectedMenu != index) {
      setState(() {
        selectedMenu = index;
      });

      switch (index) {
        case 0:
          break;
        case 1:
          await globalKeyBookmark.currentState.getData();
          break;
        case 2:
          break;
        case 3:
          await globalKeyChatRoomList.currentState.getData(refresh: true);
          break;
        case 4:
          await globalKeyMy.currentState.getData(refresh: true);
          break;
      }
    }
  }
}
