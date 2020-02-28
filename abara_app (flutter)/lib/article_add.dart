import 'package:abara_app/_main_app.dart';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class ArticleAddPage extends StatefulWidget {
  final String category1;

  ArticleAddPage(this.category1, {Key key}) : super(key: key);

  @override
  _ArticleAddPageState createState() => _ArticleAddPageState();
}

class _ArticleAddPageState extends State<ArticleAddPage> {
  var tecSubject = TextEditingController();
  var tecContent = TextEditingController();

  var selectedChip = '';

  Map<int, File> mapFile = {};

  bool isPosting = false;

  var defaultMKContentText = '거래방법 : \n연락처 : \n가격 : \n';

  @override
  void initState() {
    super.initState();

    if (isDebug) {
    }

    if (widget.category1 == 'MK') {
      tecContent.text = defaultMKContentText;
    }
  }

  @override
  void dispose() {
    tecSubject.dispose();
    tecContent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    p('build ${this.runtimeType} ~~~~~~~~~~~~~~~~~~~~');

    return Scaffold(
      appBar: CustomAppBarBlank(),
      body: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar('${mapCategory1Name[widget.category1]} 글쓰기', canPop: true),
        body: SafeArea(
          child: WillPopScope(
            onWillPop: () {
              if (tecSubject.text.trim().isEmpty &&
                  (tecContent.text.trim().isEmpty || (widget.category1 == 'MK' && tecContent.text == defaultMKContentText)) &&
                  mapFile[0] == null &&
                  mapFile[1] == null &&
                  mapFile[2] == null &&
                  mapFile[3] == null) {
                return Future<bool>.value(true);
              } else {
                return displayConfirm(mounted, context, '입력하던 내용이 있습니다',
                    dismissible: false, choiceCancel: '머무르기', choiceOk: '삭제하기');
              }
            },
            child: AbsorbPointer(
              absorbing: (isPosting),
              child: Stack(
                children: <Widget>[
                  buildListView(),
                  if (isPosting) Center(child: CustomCircularProgressIndicator()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildListView() {
    double wPhoto = (w360plus - (16 * 2) - 8) / 2;
    double hPhoto = 90 * wPhoto / 160;

    var userMe = Provider.of<UserData>(context, listen: false).user;

    return ListView(
      children: <Widget>[
        if (widget.category1 == 'MK' || (widget.category1 == 'JB' && userMe.email == adminEmail))
          Container(
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: mapListCategory2[widget.category1].where((item) => item != '').map((item) {
                return Center(
                  child: GestureDetector(
                    child: Container(
                      margin: EdgeInsets.all(6),
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      height: 24,
                      decoration: BoxDecoration(
                          color: (item == selectedChip) ? Colors.black : Color(0x4d000000),
                          borderRadius: BorderRadius.circular(20)),
                      child: Center(child: TN2('$item', 14, -0.35, Color(0xdeffffff))),
                    ),
                    onTap: () {
                      if (item != selectedChip) {
                        setState(() {
                          selectedChip = item;
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            style: textStyleTextField2,
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              hintText: '제목',
              focusedBorder: UnderlineInputBorder(),
            ),
            controller: tecSubject,
          ),
        ),
        H(12),
        if (widget.category1 == 'MK' ||
            (widget.category1 == 'JB' && userMe.email == adminEmail) ||
            (widget.category1 == 'CT' && userMe.email == adminEmail))
          Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: <Widget>[
                    buildPicker(wPhoto, hPhoto, 0),
                    W(8),
                    buildPicker(wPhoto, hPhoto, 1),
                  ],
                ),
              ),
              H(8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: <Widget>[
                    buildPicker(wPhoto, hPhoto, 2),
                    W(8),
                    buildPicker(wPhoto, hPhoto, 3),
                  ],
                ),
              ),
              H(12),
            ],
          ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            style: textStyleTextField3,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '내용을 입력해 주세요\n\n\n',
              contentPadding: EdgeInsets.fromLTRB(0, 7, 0, 7),
            ),
            keyboardType: TextInputType.multiline,
            maxLines: null,
            controller: tecContent,
          ),
        ),
        H(22),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            height: 48,
            child: FlatButton(
              color: Color(0xff121212),
              splashColor: Colors.white,
              shape: StadiumBorder(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.create, color: Colors.white),
                  W(10),
                  TN1('CREATE', 16, 0, Colors.white),
                ],
              ),
              onPressed: post,
            ),
          ),
        ),
        H(8),
      ].where((child) => child != null).toList(),
    );
  }

  Widget buildPicker(double wPhoto, double hPhoto, int index) {
    return SizedBox(
      width: wPhoto,
      height: hPhoto,
      child: Stack(
        children: <Widget>[
          Positioned(
            width: wPhoto,
            height: hPhoto,
            child: FlatButton(
              color: Color(0x07000000),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
                side: BorderSide(
                  color: Color(0xff979797),
                  width: 0.5,
                ),
              ),
              padding: EdgeInsets.all(0),
              child: PopupMenuButton<ImageSource>(
                offset: Offset(0, -12),
                child: SizedBox(width: wPhoto, height: hPhoto, child: Icon(Icons.add)),
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
                      await pickImage(ImageSource.camera, index);
                      break;
                    case ImageSource.gallery:
                      await pickImage(ImageSource.gallery, index);
                      break;
                  }
                },
              ),
              onPressed: () {},
            ),
          ),
          if (mapFile[index] != null)
            Positioned(
              width: wPhoto,
              height: hPhoto,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.file(mapFile[index], width: wPhoto, fit: BoxFit.cover),
              ),
            ),
          if (mapFile[index] != null)
            Positioned(
              right: 5,
              top: 5,
              child: GestureDetector(
                child: I('icon_delete.png', 15, 15),
                onTap: () {
                  setState(() {
                    mapFile[index] = null;
                  });
                },
              ),
            ),
        ].where((child) => child != null).toList(),
      ),
    );
  }

  Future<void> pickImage(ImageSource imageSource, int index) async {
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
          mapFile[index] = file;
        });
      }
    } catch (ex) {
      p(ex);
      await displayAlert(mounted, context, '에러가 발생하였습니다');
    }
  }

  Future<void> post() async {
    await Future.delayed(duration1);

    if (isPosting) return;

    var userMe = Provider.of<UserData>(context, listen: false).user;

    if ((widget.category1 == 'MK' || (widget.category1 == 'JB' && userMe.email == adminEmail)) && selectedChip == '') {
      await displayAlert(mounted, context, '분류를 선택해주세요');
      return;
    }
    if (tecSubject.text.trim().length == 0) {
      await displayAlert(mounted, context, '제목을 입력해주세요');
      return;
    }
    if (tecSubject.text.trim().length < 2) {
      await displayAlert(mounted, context, '제목을 2자 이상 입력해주세요');
      return;
    }
    if (tecContent.text.trim().length == 0) {
      await displayAlert(mounted, context, '내용을 입력해주세요');
      return;
    }
    if (tecContent.text.trim().length < 10) {
      await displayAlert(mounted, context, '내용을 10자 이상 입력해주세요');
      return;
    }

    for (int i = 0; i < 1; i++) {
      setState(() {
        isPosting = true;
      });

      try {
        var userAgent = Provider.of<UserData>(context, listen: false).userAgent;
        var accessToken = Provider.of<UserData>(context, listen: false).accessToken;
        p(accessToken);

        var query1 = '';
        if (widget.category1 == 'MK') query1 = '$selectedChip/';

        var request =
            new http.MultipartRequest('POST', Uri.parse(baseUrl + 'article/${mapCategory1Url[widget.category1]}/${query1}add'));
        request.headers['User-Agent'] = userAgent;
        request.headers[HttpHeaders.authorizationHeader] = 'Bearer $accessToken';

        request.fields['subject'] = tecSubject.text.trim();
        request.fields['content'] = tecContent.text.trim();

        var duration = Duration(seconds: 5);

        for (int i = 0; i < 4; i++) {
          if (mapFile[i] == null) continue;

          var file = mapFile[i];
          var filename = path.basename(file.path);

          request.files.add(new http.MultipartFile.fromBytes('file$i', await file.readAsBytes(), filename: filename));
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
        } else if (jd.isSuccess == true) {
          if (isNotEmpty(jd.responseMessage)) {
            await displayAlert(mounted, context, jd.responseMessage);
          }

          Navigator.pop(context, true);
        } else {
          throw new Exception();
        }
      } on UpdateNeededException catch (ex) {
        await processWithUpdateNeededException(mounted, context);
      } on AccessTokenExpiredException catch (ex) {
        await displayAlert(mounted, context, '로그인이 만료되었습니다');
      } on SocketException catch (ex) {
        p(ex);
        await displayAlert(mounted, context, '서버에 접속할 수 없습니다');
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
}
