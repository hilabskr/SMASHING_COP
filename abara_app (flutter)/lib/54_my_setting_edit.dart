import 'package:abara_app/_main_app.dart';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class MySettingEditPage extends StatefulWidget {
  @override
  _MySettingEditPageState createState() => _MySettingEditPageState();
}

class _MySettingEditPageState extends State<MySettingEditPage> {
  var sc = new StreamController<StreamData>();
  bool isGettingData = false;

  File fileProfileImage;

  var tecUserName = TextEditingController();
  var tecComment = TextEditingController();

  bool isPosting = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void dispose() {
    sc.close();
    tecUserName.dispose();
    tecComment.dispose();
    super.dispose();
  }

  Future<void> getData() async {
    while (isGettingData) await Future.delayed(duration2);
    isGettingData = true;

    p('~~~~~~~~~~~ getData()');
    var sd = new StreamData();

    try {
      var jd = await getJsonData(context, HttpMethod.get, 'user/edit/me');
      if (jd.isSuccess == false && isNotEmpty(jd.responseMessage)) {
        sd.errorMessage = jd.responseMessage;
      } else if (jd.user == null) {
        throw new Exception();
      } else {
        tecUserName.text = jd.user.userName;
        tecComment.text = jd.user.comment ?? '';

        await Provider.of<UserData>(context, listen: false).update(jd.user);

        sd.jd = jd;
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
      body: StreamBuilder<StreamData>(
        stream: sc.stream,
        initialData: new StreamData(isLoading: true),
        builder: (context, snapshot) {
          if (snapshot.data.isLoading == true) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                child: Center(
                  child: CustomCircularProgressIndicator(),
                ),
              ),
            );
          } else if (snapshot.data.errorMessage != null) {
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: CustomAppBar('', canPop: true),
              body: SafeArea(
                child: Center(
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
                ),
              ),
            );
          } else {
            return Scaffold(
              backgroundColor: colorDarkYellow,
              appBar: CustomAppBar('내 정보 관리', canPop: true, backgroundColor: Colors.white),
              body: SafeArea(
                child: WillPopScope(
                  onWillPop: () {
                    if (tecUserName.text == snapshot.data.jd.user.userName &&
                        tecComment.text == (snapshot.data.jd.user.comment ?? '') &&
                        fileProfileImage == null) {
                      return Future<bool>.value(true);
                    } else {
                      return displayConfirm(mounted, context, '변경하던 내용이 있습니다',
                          dismissible: false, choiceCancel: '머무르기', choiceOk: '나가기');
                    }
                  },
                  child: AbsorbPointer(
                    absorbing: (isPosting),
                    child: Stack(
                      children: <Widget>[
                        buildListView(snapshot.data.jd),
                        if (isPosting) Center(child: CustomCircularProgressIndicator()),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget buildListView(JsonData jd) {
    var userMe = jd.user;

    return ListView(
      children: <Widget>[
        Column(
          children: <Widget>[
            H(24),
            Stack(
              children: <Widget>[
                if (fileProfileImage != null)
                  FileICB(fileProfileImage, 116, 2)
                else if (isNullOrEmpty(userMe.profileImage))
                  ICB('default_profile.png', 116, 2)
                else
                  CachedNetworkICB('user-resized-1020/${userMe.profileImage}', 116, 2),
                IC('profile_photo_change.png', 120),
                Positioned(
                  bottom: 0,
                  child: SizedBox(
                    width: 120,
                    height: 40,
                    child: FlatButton(
                      color: Colors.transparent,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      padding: EdgeInsets.all(0),
                      child: PopupMenuButton<ImageSource>(
                        offset: Offset(-102, -12),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: TN2('수정', 14, -0.35, Color(0xdeffffff)),
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: ImageSource.camera,
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.photo_camera, color: Colors.black87),
                                W(7),
                                TN1('사진찍기', 18, 0, Colors.black87),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: ImageSource.gallery,
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.photo, color: Colors.black87),
                                W(7),
                                TN1('앨범에서 가져오기', 18, 0, Colors.black87),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) async {
                          await Future.delayed(duration1);
                          p(value);
                          switch (value) {
                            case ImageSource.camera:
                              await pickImage(ImageSource.camera);
                              break;
                            case ImageSource.gallery:
                              await pickImage(ImageSource.gallery);
                              break;
                          }
                        },
                      ),
                      onPressed: null,
                    ),
                  ),
                ),
              ],
            ),
            H(14),
            TN2('${userMe.userName}', 18, -0.45, Colors.black87),
            H(5),
            TN1('${userMe.email}', 14, 0, Colors.black87),
          ],
        ),
        H(19),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            style: textStyleTextField1,
            decoration: InputDecoration(
              labelText: 'Name',
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
            controller: tecUserName,
          ),
        ),
        H(30),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            style: textStyleTextField1,
            decoration: InputDecoration(
              labelText: 'Comment',
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
            controller: tecComment,
          ),
        ),
        H(33),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            height: 48,
            child: FlatButton(
              color: Color(0xff272727),
              splashColor: Colors.white,
              shape: StadiumBorder(),
              child: TN1('프로필 수정완료', 16, 0, Colors.white),
              onPressed: post,
            ),
          ),
        ),
        H(24),
      ].where((child) => child != null).toList(),
    );
  }

  Future<void> pickImage(ImageSource imageSource) async {
    if (imageSource == ImageSource.camera) {
      if (isAndroid) {
      }
      if (isIOS) {
        if (await checkAndTryToRequestPermissionIosCamera() == false) {
          if (await displayConfirm(mounted, context, '카메라 권한이 없습니다\n\n설정으로 이동하여 변경하시겠습니까?', choiceOk: '이동')) {
            await PermissionHandler().openAppSettings();
            return;
          } else {
            return;
          }
        }
      }
    }

    if (imageSource == ImageSource.gallery) {
      if (isAndroid) {
        if (await checkAndTryToRequestPermissionAndroidStorage() == false) {
          if (await displayConfirm(mounted, context, '사진 권한이 없습니다\n\n설정으로 이동하여 변경하시겠습니까?', choiceOk: '이동')) {
            await PermissionHandler().openAppSettings();
            return;
          } else {
            return;
          }
        }
      }
      if (isIOS) {
        if (await checkAndTryToRequestPermissionIosPhotos() == false) {
          if (await displayConfirm(mounted, context, '사진 권한이 없습니다\n\n설정으로 이동하여 변경하시겠습니까?', choiceOk: '이동')) {
            await PermissionHandler().openAppSettings();
            return;
          } else {
            return;
          }
        }
      }
    }

    try {
      var file = await ImagePicker.pickImage(source: imageSource);

      if (file != null) {
        var extension = path.extension(file.path).toLowerCase();
        if (extension != '.jpg' && extension != '.jpeg' && extension != '.png') {
          await displayAlert(mounted, context, 'jpg png 사진만 올릴 수 있습니다');
          return;
        }

        setState(() {
          fileProfileImage = file;
        });

        await displayAlert(mounted, context, '수정완료 버튼을 눌러줘야\n변경사항이 적용됩니다');
      }
    } catch (ex) {
      p(ex);
      await displayAlert(mounted, context, '에러가 발생하였습니다');
    }
  }

  Future<void> post() async {
    await Future.delayed(duration1);

    if (isPosting) return;

    if (tecUserName.text.trim().length < 2) {
      await displayAlert(mounted, context, '이름을 2자 이상 입력해주세요');
      return;
    }
    if (tecUserName.text.trim().length > 20) {
      await displayAlert(mounted, context, '이름을 20자 이하로 입력해주세요');
      return;
    }
    if (tecComment.text.trim().length > 20) {
      await displayAlert(mounted, context, 'Comment 를 20자 이하로 입력해주세요');
      return;
    }

    setState(() {
      isPosting = true;
    });

    try {
      var userAgent = Provider.of<UserData>(context, listen: false).userAgent;
      var accessToken = Provider.of<UserData>(context, listen: false).accessToken;
      p(accessToken);

      var request = new http.MultipartRequest('POST', Uri.parse(baseUrl + 'user/edit/me'));
      request.headers['User-Agent'] = userAgent;
      request.headers[HttpHeaders.authorizationHeader] = 'Bearer $accessToken';

      request.fields['userName'] = tecUserName.text.trim();
      request.fields['comment'] = tecComment.text.trim();

      var duration = Duration(seconds: 5);

      if (fileProfileImage != null) {
        var filename = path.basename(fileProfileImage.path);
        request.files
            .add(new http.MultipartFile.fromBytes('fileProfileImage', await fileProfileImage.readAsBytes(), filename: filename));
        duration += Duration(seconds: 30);
        p(duration);
      }

      p('before send()');
      var response = await request.send().timeout(duration);
      p('after send()');

      await verifyResponse(context, response);

      var responseBody = await response.stream.transform(utf8.decoder).join();
      p(responseBody);

      var jd = JsonData.fromMap(json.decode(responseBody));

      if (jd.isSuccess == false && isNotEmpty(jd.responseMessage)) {
        await displayAlert(mounted, context, jd.responseMessage);
      } else if (jd.isSuccess == true && jd.user != null) {
        if (isNotEmpty(jd.responseMessage)) {
          await displayAlert(mounted, context, jd.responseMessage);
        }

        await Provider.of<UserData>(context, listen: false).update(jd.user);

        Navigator.pop(context);
      } else {
        throw new Exception();
      }
    } on UpdateNeededException catch (ex) {
      await processWithUpdateNeededException(mounted, context);
    } on AccessTokenExpiredException catch (ex) {
      await displayAlert(mounted, context, '로그인이 만료되었습니다');
    } on SocketException catch (ex) {
      p(ex);
      await displayAlert(mounted, context, '서버에 ��속할 수 없습니다');
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
}
