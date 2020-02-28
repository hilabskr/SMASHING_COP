import 'package:abara_app/_main_app.dart';

import 'package:get_version/get_version.dart';

Future<void> main() async {
  String userAgent = userAgentPrefix + (Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'etc'));

  String appVersion;
  try {
    appVersion = await GetVersion.projectVersion;
  } on PlatformException {
    appVersion = '';
  }

  int platformType = (Platform.isAndroid) ? 1 : (Platform.isIOS) ? 2 : 0;

  String platformVersion;
  try {
    platformVersion = await GetVersion.platformVersion;
  } on PlatformException {
    platformVersion = '';
  }
  if (isDebug) platformVersion = 'emul ' + platformVersion;

  var userDataPath = (await getApplicationDocumentsDirectory()).path + '/' + userDataFileName;

  var userData = new UserData(userAgent, appVersion, platformType, platformVersion, userDataPath);

  p('------------------------------ main');
  p(userData.userAgent);
  p(userData.appVersion);
  p(userData.platformVersion);
  p(userData.accessToken);
  p(userData.user);

  runApp(new MainApp(userData));
}
