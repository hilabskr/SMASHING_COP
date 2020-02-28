import 'package:abara_app/_main_app.dart';

class ArticleEditPage extends StatefulWidget {
  final Article article;

  ArticleEditPage(this.article, {Key key}) : super(key: key);

  @override
  _ArticleEditPageState createState() => _ArticleEditPageState();
}

class _ArticleEditPageState extends State<ArticleEditPage> {
  var tecSubject = TextEditingController();
  var tecContent = TextEditingController();

  bool isPosting = false;

  @override
  void initState() {
    super.initState();
    tecSubject.text = widget.article.subject;
    tecContent.text = widget.article.content;
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
        appBar: CustomAppBar('글수정', canPop: true),
        body: SafeArea(
          child: WillPopScope(
            onWillPop: () {
              if (widget.article.subject == tecSubject.text && widget.article.content == tecContent.text) {
                return Future<bool>.value(true);
              } else {
                return displayConfirm(mounted, context, '수정하던 내용이 있습니다',
                    dismissible: false, choiceCancel: '머무르기', choiceOk: '창닫기');
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
    return ListView(
      children: <Widget>[
        if (isNotEmpty(widget.article.category2))
          Container(
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Center(
                  child: Container(
                    margin: EdgeInsets.all(6),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    height: 24,
                    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
                    child: Center(child: TN2('${widget.article.category2}', 14, -0.35, Color(0xdeffffff))),
                  ),
                )
              ],
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
                  TN1('수정하기', 16, 0, Colors.white),
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

  Future<void> post() async {
    await Future.delayed(duration1);

    if (isPosting) return;

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

    setState(() {
      isPosting = true;
    });

    try {
      var mapRequestBody = {
        'subject': tecSubject.text.trim(),
        'content': tecContent.text.trim(),
      };

      var jd = await getJsonData(context, HttpMethod.post, 'article/edit/${widget.article.articleId}', mapRequestBody);

      if (jd.isSuccess == false) {
        if (isNotEmpty(jd.responseMessage)) {
          await displayAlert(mounted, context, jd.responseMessage);
        } else {
          throw new Exception();
        }
      } else if (jd.isSuccess == true) {
        if (isNotEmpty(jd.responseMessage)) {
          await displayAlert(mounted, context, jd.responseMessage);
        }

        Navigator.pop(context, true);
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
