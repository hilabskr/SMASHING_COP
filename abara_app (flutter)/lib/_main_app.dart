import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:audioplayers/audio_cache.dart';

import 'package:abara_app/_lib.dart';
import 'package:abara_app/_model.dart';
import 'package:abara_app/00_splash.dart';
import 'package:abara_app/21_bookmark.dart';
import 'package:abara_app/41_chat_room_list.dart';
import 'package:abara_app/42_chat_room.dart';
import 'package:abara_app/51_my.dart';

export 'dart:async';
export 'dart:convert';
export 'dart:io';
export 'dart:math';

export 'package:flutter/material.dart';
export 'package:flutter/services.dart';
export 'package:provider/provider.dart';
export 'package:path_provider/path_provider.dart';
export 'package:permission_handler/permission_handler.dart';
export 'package:url_launcher/url_launcher.dart';
export 'package:image_picker/image_picker.dart';
export 'package:cached_network_image/cached_network_image.dart';
export 'package:flutter_swiper/flutter_swiper.dart';

export 'package:abara_app/_lib.dart';
export 'package:abara_app/_model.dart';
export 'package:abara_app/01_welcome.dart';
export 'package:abara_app/02_login.dart';
export 'package:abara_app/03_sign_up.dart';
export 'package:abara_app/04_user_verification.dart';
export 'package:abara_app/05_reset_password.dart';
export 'package:abara_app/10_main_scaffold.dart';
export 'package:abara_app/11_home.dart';
export 'package:abara_app/12_home_article_list.dart';
export 'package:abara_app/13_home_user_list.dart';
export 'package:abara_app/21_bookmark.dart';
export 'package:abara_app/31_article_add_category.dart';
export 'package:abara_app/41_chat_room_list.dart';
export 'package:abara_app/42_chat_room.dart';
export 'package:abara_app/51_my.dart';
export 'package:abara_app/52_my_notification.dart';
export 'package:abara_app/53_my_setting.dart';
export 'package:abara_app/54_my_setting_edit.dart';
export 'package:abara_app/55_my_setting_terms.dart';
export 'package:abara_app/56_my_setting_contact.dart';
export 'package:abara_app/article_add.dart';
export 'package:abara_app/article_details.dart';
export 'package:abara_app/article_edit.dart';
export 'package:abara_app/user_info.dart';

const userAgentPrefix = 'abara_';
const appTitle = 'ABARA';
const apiVersion = '1.0';

const baseUrlDebug = 'https://app.abara.co.kr/api/v$apiVersion/';

const baseUrlRelease = 'https://app.abara.co.kr/api/v$apiVersion/';
const imageUrl = 'https://app.abara.co.kr/image';

const adminEmail = 'contact@hilabs.co.kr';

const userDataFileName = 'user_data_v1.0.json';

const duration1 = Duration(milliseconds: 150);
const duration2 = Duration(milliseconds: 50);

const urlPlayStore = 'https://play.google.com/store/apps/details?id=kr.co.abara.app';
const urlAppStore = 'https://apps.apple.com/app/id1498865466';

double w360plus = 360;
double w340plus = 340;

FirebaseMessaging firebaseMessaging;

const mapCategory1Name = {
  'FR': '자유게시판',
  'MK': '중고마켓',
  'JB': '구직구인',
  'CT': '공모전',
  'SS': '장학금',
};

const mapCategory1Url = {
  'FR': 'free',
  'MK': 'market',
  'JB': 'job',
  'CT': 'contest',
  'SS': 'scholarship',
};

const mapListCategory2 = {
  'MK': ['', '의류', '화장품', '디지털', '가구', '식품', '스포츠', '생활', '기타'],
  'JB': ['', '구직', '구인'],
};

const listCategory1My = ['', 'FR', 'MK'];

final globalKeyNavigatorMain = GlobalKey<NavigatorState>();
final globalKeyNavigatorMenu0 = GlobalKey<NavigatorState>();

final globalKeyBookmark = GlobalKey<BookmarkPageState>();
final globalKeyChatRoomList = GlobalKey<ChatRoomListPageState>();
final globalKeyChatRoom = GlobalKey<ChatRoomPageState>();
final globalKeyMy = GlobalKey<MyPageState>();

class MainApp extends StatefulWidget {
  final UserData userData;

  MainApp(this.userData);

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    configureFirebaseMessaging();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void configureFirebaseMessaging() {
    firebaseMessaging = FirebaseMessaging();

    if (isIOS) {
      firebaseMessaging.requestNotificationPermissions(IosNotificationSettings(sound: true, badge: true, alert: true));
      firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
        p("Settings registered: $settings");
      });
    }

    firebaseMessaging.configure(
      onLaunch: (Map<String, dynamic> map) async {
        p('~~~~onLaunch $map');
      },
      onResume: (Map<String, dynamic> map) async {
        p('~~~~onResume $map');
      },
      onMessage: (Map<String, dynamic> map) async {
        p('~~~~onMessage $map');

        try {
          String command = (isIOS) ? map['command'] : map['data']['command'];
          if (command.startsWith('NEW_CHAT_MESSAGE=')) {
            var list = command.split('=');
            if (list.length == 2) {
              if (globalKeyChatRoom.currentState != null &&
                  globalKeyChatRoom.currentState.isInited == true &&
                  globalKeyChatRoom.currentState.chatRoomId?.toString() == list[1]) {
                p('globalKeyChatRoom');
                playSound();
                await globalKeyChatRoom.currentState.getDataBefore();
              } else if (globalKeyChatRoomList.currentState != null) {
                p('globalKeyChatRoomList');
                playSound();
                await globalKeyChatRoomList.currentState.getData(refresh: true);
              } else {
                p('token remain');
              }
            }
          }
        } catch (ex) {
          p(ex);
        }

      },
    );
  }

  Future<void> playSound() async {
    var audioPlayer = new AudioCache();
    await audioPlayer.play('sounds/stairs.mp3', volume: 1.0);
  }

  @override
  Widget build(BuildContext context) {
    p('build ${this.runtimeType} ~~~~~~~~~~~~~~~~~~~~');

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return ChangeNotifierProvider.value(
      value: widget.userData,
      child: MaterialApp(
        locale: const Locale('ko', 'KR'),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('ko', 'KR'),
        ],
        debugShowCheckedModeBanner: false,
        title: appTitle,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.transparent,
        ),
        home: SplashPage(),
        navigatorKey: globalKeyNavigatorMain,
      ),
    );
  }
}
