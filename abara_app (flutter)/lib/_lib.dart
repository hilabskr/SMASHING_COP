import 'package:abara_app/_main_app.dart';

import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

enum DetailsMenu { edit, delete, report }

bool get isDebug {
  bool isDebug = false;
  assert(isDebug = true);
  return isDebug;
}

bool get isAndroid => Platform.isAndroid;
bool get isIOS => Platform.isIOS;

String get baseUrl {
  return (isIOS) ? baseUrlRelease : (isDebug) ? baseUrlDebug : baseUrlRelease;
}

void p(Object o) {
  if (isDebug) {
    var timestamp = DateFormat('HH:mm:ss').format(DateTime.now());
    print('${DateTime.now().microsecondsSinceEpoch} $timestamp $o');
  }
}

class BreakException implements Exception {}

class UpdateNeededException implements Exception {}

class AccessTokenExpiredException implements Exception {}

class CustomException implements Exception {
  String errorMessage;
  CustomException(this.errorMessage);
}

enum HttpMethod { get, post }

bool isNullOrEmpty(String s) => (s == null || s == '');
bool isNullOrWhiteSpace(String s) => (s == null || s.trim() == '');
bool isNotEmpty(String s) => (s != null && s != '');

Future<JsonData> getJsonData(BuildContext context, HttpMethod httpMethod, String api,
    [Map<String, String> mapRequestBody]) async {
  var userAgent = Provider.of<UserData>(context, listen: false).userAgent;
  var accessToken = Provider.of<UserData>(context, listen: false).accessToken;

  var headers = {
    'User-Agent': userAgent,
  };
  if (accessToken != null) {
    headers[HttpHeaders.authorizationHeader] = 'Bearer $accessToken';
  }

  var response = (httpMethod == HttpMethod.get)
      ? await http
          .get(
            baseUrl + api,
            headers: headers,
          )
          .timeout(Duration(milliseconds: 5000))
      : await http
          .post(
            baseUrl + api,
            headers: headers,
            body: mapRequestBody,
          )
          .timeout(Duration(milliseconds: 5000));

  await verifyResponse(context, response);

  p(response.body);

  return JsonData.fromMap(json.decode(response.body));
}

Future<void> verifyResponse(BuildContext context, http.BaseResponse response) async {

  p('------------------------------ verifyResponse');
  p(response.request.url);
  p(response.statusCode);
  p(response.headers);

  var apiDeprecatedVersions = response.headers['api-deprecated-versions'];
  if (apiDeprecatedVersions != null && apiDeprecatedVersions.indexOf(apiVersion) != -1) throw new UpdateNeededException();

  if (response.statusCode == 401 || response.statusCode == 403) {
    throw new AccessTokenExpiredException();
  } else if (response.statusCode != 200) {
    throw new Exception();
  }
}

Future<String> processWithUpdateNeededException(bool mounted, BuildContext context, {bool isSilent = false}) async {
  if (isSilent == false) {
    if (await displayConfirm(mounted, context, '업데이트가 필요합니다\n업데이트 페이지로 이동할까요?')) {
      var updateUrl = (isAndroid) ? urlPlayStore : (isIOS) ? urlAppStore : null;
      if (await canLaunch(updateUrl)) {
        launch(updateUrl);
      } else {
        return '에러가 발생하였습니다';
      }
    }
  }

  return '업데이트가 필요합니다';
}

Future<bool> checkAndTryToRequestPermissionIosCamera() async {
  var permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.camera);
  if (permission == PermissionStatus.granted) {
    return true;
  } else {
    var mapPermission = await PermissionHandler().requestPermissions([PermissionGroup.camera]);
    return mapPermission[PermissionGroup.camera] == PermissionStatus.granted;
  }
}

Future<bool> checkAndTryToRequestPermissionIosPhotos() async {
  var permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.photos);
  if (permission == PermissionStatus.granted) {
    return true;
  } else {
    var mapPermission = await PermissionHandler().requestPermissions([PermissionGroup.photos]);
    return mapPermission[PermissionGroup.photos] == PermissionStatus.granted;
  }
}

Future<bool> checkAndTryToRequestPermissionAndroidStorage() async {
  var permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
  if (permission == PermissionStatus.granted) {
    return true;
  } else {
    var mapPermission = await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    return mapPermission[PermissionGroup.storage] == PermissionStatus.granted;
  }
}

const colorDarkYellow = Color(0xFFf8cf00);
const colorOrange = Color(0xFFff5700);

const textStyleTextField1 = TextStyle(
  fontFamily: 'Roboto-Regular',
  fontSize: 16,
  letterSpacing: 0.15,
  color: Colors.black87,
);

const textStyleTextField2 = TextStyle(
  fontFamily: 'NanumBarunpenR',
  fontSize: 16,
  letterSpacing: 0.15,
  color: Colors.black,
);

const textStyleTextField3 = TextStyle(
  fontFamily: 'NanumBarunpenR',
  fontSize: 16,
  letterSpacing: 0,
  color: Colors.black87,
  height: 1.25,
);

class CustomAppBarImage extends StatelessWidget implements PreferredSizeWidget {
  final bool canPop;
  CustomAppBarImage({this.canPop = false});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      leading: (canPop == true) ? CustomBackButton() : null,
      title: Padding(
        padding: EdgeInsets.fromLTRB(0, 13, 0, 10),
        child: I('logotype.png', 78, 33),
      ),
      centerTitle: true,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => new Size.fromHeight(56);
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String text;
  final bool canPop;
  final Color backgroundColor;
  final List<Widget> actions;
  final double elevation;
  CustomAppBar(this.text, {this.canPop = false, this.backgroundColor = Colors.transparent, this.actions, this.elevation = 0});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: this.backgroundColor,
      leading: (this.canPop == true) ? CustomBackButton() : null,
      title: TN2('${this.text}', 20, 0, Colors.black87, maxLines: 1),
      titleSpacing: 0,
      actions: this.actions,
      actionsIconTheme: IconThemeData(color: Colors.black87),
      centerTitle: true,
      elevation: this.elevation,
    );
  }

  @override
  Size get preferredSize => new Size.fromHeight(56);
}

class CustomAppBarBlank extends StatelessWidget implements PreferredSizeWidget {
  CustomAppBarBlank();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.black,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => new Size.fromHeight(0);
}

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      color: Colors.black87,
      icon: Icon(Icons.arrow_back),
      onPressed: () async {
        Navigator.maybePop(context);
      },
    );
  }
}

void setSystemUIOverlayStyle(Color color) {
  if (isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: color));
  }
  if (isIOS) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarBrightness: Brightness.dark));
  }
}

Future<void> displayAlert(bool mounted, BuildContext context, String text) async {
  if (mounted == false)
    return;
  else
    return await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(text, style: TextStyle(fontSize: 16)),
          actions: <Widget>[
            FlatButton(
              child: Text('확인', style: TextStyle(fontSize: 16)),
              onPressed: () async {
                await Future.delayed(duration1);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
}

Future<bool> displayConfirm(bool mounted, BuildContext context, String text,
    {bool dismissible = true, String choiceCancel = '취소', String choiceOk = '확인'}) async {
  if (mounted == false)
    return false;
  else
    return await showDialog<bool>(
          context: context,
          barrierDismissible: dismissible,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(text, style: TextStyle(fontSize: 16), maxLines: 10000),
              actions: <Widget>[
                FlatButton(
                  child: Text('$choiceCancel', style: TextStyle(fontSize: 16)),
                  onPressed: () async {
                    await Future.delayed(duration1);
                    Navigator.pop(context, false);
                  },
                ),
                FlatButton(
                  child: Text('$choiceOk', style: TextStyle(fontSize: 16)),
                  onPressed: () async {
                    await Future.delayed(duration1);
                    Navigator.pop(context, true);
                  },
                ),
              ],
            );
          },
        ) ??
        false;
}

class I extends StatelessWidget {
  final String name;
  final double width;
  final double height;
  I(this.name, this.width, this.height);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Image.asset('assets/images/$name', fit: BoxFit.fill),
    );
  }
}

class IC extends StatelessWidget {
  final String name;
  final double width;
  IC(this.name, this.width);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(width / 2),
        child: Image.asset('assets/images/$name', fit: BoxFit.cover),
      ),
    );
  }
}

class ICB extends StatelessWidget {
  final String name;
  final double width;
  final double border;
  ICB(this.name, this.width, this.border);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width + border * 2,
      height: width + border * 2,
      child: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          Positioned(
            left: border,
            top: border,
            right: border,
            bottom: border,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(width / 2),
              child: Image.asset('assets/images/$name', fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }
}

class FileICB extends StatelessWidget {
  final File file;
  final double width;
  final double border;
  FileICB(this.file, this.width, this.border);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width + border * 2,
      height: width + border * 2,
      child: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          Positioned(
            left: border,
            top: border,
            right: border,
            bottom: border,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(width / 2),
              child: Image.file(file, fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }
}

class CachedNetworkICB extends StatelessWidget {
  final String url;
  final double width;
  final double border;
  CachedNetworkICB(this.url, this.width, this.border);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width + border * 2,
      height: width + border * 2,
      child: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          Positioned(
            left: border,
            top: border,
            right: border,
            bottom: border,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(width / 2),
              child: CachedNetworkImage(
                imageUrl: '$imageUrl/$url',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey[200]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class R extends StatelessWidget {
  final double width;
  final double height;
  R(this.width, this.height);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      width: width,
      height: height,
    );
  }
}

class TN1 extends StatelessWidget {
  final String text;
  final double fontSize;
  final double letterSpacing;
  final Color color;
  final double height;
  final int maxLines;
  final TextDecoration decoration;
  TN1(this.text, this.fontSize, this.letterSpacing, this.color,
      {Key key, this.height = 1.0, this.maxLines = 1, this.decoration = TextDecoration.none})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      this.text,
      style: TextStyle(
        fontFamily: 'NanumBarunpenR',
        fontSize: this.fontSize,
        letterSpacing: this.letterSpacing,
        color: this.color,
        height: this.height,
        decoration: this.decoration,
      ),
      maxLines: this.maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class TN2 extends StatelessWidget {
  final String text;
  final double fontSize;
  final double letterSpacing;
  final Color color;
  final double height;
  final int maxLines;
  final TextDecoration decoration;
  TN2(this.text, this.fontSize, this.letterSpacing, this.color,
      {Key key, this.height = 1.0, this.maxLines = 1, this.decoration = TextDecoration.none})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      this.text,
      style: TextStyle(
        fontFamily: 'NanumBarunpenB',
        fontSize: this.fontSize,
        letterSpacing: this.letterSpacing,
        color: this.color,
        height: this.height,
        decoration: this.decoration,
      ),
      maxLines: this.maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class TR1 extends StatelessWidget {
  final String text;
  final double fontSize;
  final double letterSpacing;
  final Color color;
  final double height;
  final int maxLines;
  final TextDecoration decoration;
  TR1(this.text, this.fontSize, this.letterSpacing, this.color,
      {Key key, this.height = 1.0, this.maxLines = 1, this.decoration = TextDecoration.none})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      this.text,
      style: TextStyle(
        fontFamily: 'Roboto-Regular',
        fontSize: this.fontSize,
        letterSpacing: this.letterSpacing,
        color: this.color,
        height: this.height,
        decoration: this.decoration,
      ),
      maxLines: this.maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}

SizedBox W(double w) {
  return SizedBox(width: w);
}

SizedBox H(double h) {
  return SizedBox(height: h);
}

class CustomFlatButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;
  final Color color;
  CustomFlatButton(this.text, {Key key, @required this.onPressed, this.width = 120, this.color = Colors.black}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: this.width,
      height: 36,
      child: FlatButton(
        color: this.color,
        splashColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        onPressed: this.onPressed,
        child: Text(
          this.text,
          style: TextStyle(
            fontFamily: 'Roboto-Medium',
            fontSize: 14,
            color: Colors.white,
            letterSpacing: 1.25,
          ),
        ),
      ),
    );
  }
}

class CustomCircularProgressIndicator extends StatelessWidget {
  final double size;
  final double strokeWidth;
  CustomCircularProgressIndicator({this.size = 36, this.strokeWidth = 4});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: this.size,
      height: this.size,
      child: CircularProgressIndicator(
        strokeWidth: this.strokeWidth,
        backgroundColor: Colors.transparent,
        valueColor: AlwaysStoppedAnimation(Colors.black87),
      ),
    );
  }
}

String getEmoji(int relationshipScore) {
  double threshold = 100 / 7;

  if (relationshipScore > threshold * 6)
    return 'emoji_a_1.png';
  else if (relationshipScore > threshold * 5)
    return 'emoji_a_2.png';
  else if (relationshipScore > threshold * 4)
    return 'emoji_a_3.png';
  else if (relationshipScore > threshold * 3)
    return 'emoji_a_4.png';
  else if (relationshipScore > threshold * 2)
    return 'emoji_a_5.png';
  else if (relationshipScore > threshold * 1)
    return 'emoji_a_6.png';
  else
    return 'emoji_a_7.png';
}
