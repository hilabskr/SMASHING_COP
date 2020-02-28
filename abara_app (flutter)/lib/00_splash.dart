import 'package:abara_app/_main_app.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer timer;

  @override
  void initState() {
    super.initState();

    p('new Timer');
    timer = new Timer(Duration(milliseconds: 1200), prepareToGo);
  }

  var listPrecacheImage = [
    'arrow_right.png',
    'bookmark.png',
    'bookmark_on.png',
    'comment.png',
    'create_01.png',
    'create_02.png',
    'create_03.png',
    'default_profile.png',
    'emoji_a_1.png',
    'emoji_a_2.png',
    'emoji_a_3.png',
    'emoji_a_4.png',
    'emoji_a_5.png',
    'emoji_a_6.png',
    'emoji_a_7.png',
    'icon_action_favorite_2.png',
    'icon_delete.png',
    'icon_menu_chat.png',
    'icon_menu_chat_on.png',
    'icon_menu_fab.png',
    'icon_menu_fab_on.png',
    'icon_menu_favorite.png',
    'icon_menu_favorite_on.png',
    'icon_menu_home.png',
    'icon_menu_home_on.png',
    'icon_menu_my.png',
    'icon_menu_my_on.png',
    'logo.png',
    'logotype.png',
    'message.png',
    'profile_photo_change.png',
    'share.png',
    'splash_logo.png',
    'thumbnail_1_depth_01.png',
    'thumbnail_1_depth_02.png',
    'thumbnail_1_depth_03.png',
    'thumbnail_1_depth_04.png',
    'thumbnail_1_depth_05.png',
  ];

  Future<void> prepareToGo() async {
    p('000');

    for (var fileName in listPrecacheImage) {
      precacheImage(new AssetImage('assets/images/$fileName'), context);
      p('precacheImage $fileName');
    }

    p('111');

    try {
      final userData = Provider.of<UserData>(context, listen: false);

      var mapRequestBody = {
        'appVersion': userData.appVersion,
      };

      var jd = await getJsonData(context, HttpMethod.post, 'check-version', mapRequestBody);

      if (jd.isUpdateNeeded == true && isNotEmpty(jd.responseMessage)) {
        await displayAlert(mounted, context, jd.responseMessage);
        await launchStore();
      } else if (jd.isUpdateRecommended == true && isNotEmpty(jd.responseMessage)) {
        if (await displayConfirm(mounted, context, jd.responseMessage, choiceOk: '업데이트') == true) {
          await launchStore();
        } else {
          goToNextPage();
        }
      } else {
        goToNextPage();
      }
    } on SocketException catch (ex) {
      await displayAlert(mounted, context, '서버에 접속할 수 없습니다');
      goToNextPage();
    } on TimeoutException catch (ex) {
      await displayAlert(mounted, context, '서버에 접속할 수 없습니다');
      goToNextPage();
    } catch (ex) {
      await displayAlert(mounted, context, '에러가 발생하였습니다');
      goToNextPage();
    }

    p('222');
  }

  Future<void> launchStore() async {
    var updateUrl = (isAndroid) ? urlPlayStore : (isIOS) ? urlAppStore : null;
    if (await canLaunch(updateUrl)) {
      launch(updateUrl);
    } else {
      await displayAlert(mounted, context, '에러가 발생하였습니다');
    }
  }

  void goToNextPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            Provider.of<UserData>(context, listen: false).shouldLogin ? new LoginPage() : new MainScaffoldPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    p('build ${this.runtimeType} ~~~~~~~~~~~~~~~~~~~~');

    setSystemUIOverlayStyle(Colors.black);

    var size = MediaQuery.of(context).size;
    w360plus = (size.width > 430) ? 430 : size.width;
    w340plus = w360plus - 20;
    p('size.width ${size.width}');
    p('w360plus $w360plus');
    p('w340plus $w340plus');

    if (isDebug) {
      p(MediaQuery.of(context).devicePixelRatio);
      p(MediaQuery.of(context).orientation);
      p(MediaQuery.of(context).padding);
      p(MediaQuery.of(context).textScaleFactor);
    }

    return Scaffold(
      backgroundColor: colorDarkYellow,
      body: SafeArea(
        child: Center(
          child: Container(
            width: 284,
            height: 216,
            child: I('splash_logo.png', 284, 216),
          ),
        ),
      ),
    );
  }
}
