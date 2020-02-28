import 'package:abara_app/_main_app.dart';
import 'package:abara_app/_main_app.dart' as prefix0;

class BookmarkPage extends StatefulWidget {
  final UserData userData;

  BookmarkPage(this.userData, Key key) : super(key: key);

  @override
  BookmarkPageState createState() => BookmarkPageState();
}

class BookmarkPageState extends State<BookmarkPage> {

  var sc = new StreamController<StreamData>();
  bool isGettingData = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    sc.close();
    super.dispose();
  }

  Future<void> getData() async {
    while (isGettingData) await Future.delayed(duration2);
    isGettingData = true;

    p('~~~~~~~~~~~ getData()');
    var sd = new StreamData();

    try {
      var jd = await getJsonData(context, HttpMethod.get, 'bookmark/list');
      if (jd.listBookmark == null) throw new Exception();
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
      appBar: CustomAppBar('BOOKMARK'),
      body: StreamBuilder<StreamData>(
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
                      sc.add(new StreamData(isLoading: true));
                      await getData();
                    },
                  ),
                ],
              ),
            );
          } else if (snapshot.data.jd.listBookmark.length == 0) {
            return Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 37),
                child: TN1('즐겨찾기 한 컨텐츠가 없습니다', 18, -0.45, Colors.black87),
              ),
            );
          } else {
            return buildListView(snapshot.data.jd.listBookmark);
          }
        },
      ),
    );
  }

  Widget buildListView(List<Bookmark> listBookmark) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(3, 5, 3, 5),
      separatorBuilder: (context, i) {
        return H(1);
      },
      itemCount: listBookmark.length,
      itemBuilder: (context, i) {
        var article = listBookmark[i].article;
        return Material(
          color: Colors.white,
          child: InkWell(
            highlightColor: Colors.blue[100],
            splashColor: Colors.blue[100],
            child: Padding(
              padding: EdgeInsets.fromLTRB(6, 5, 13, 5),
              child: Row(
                children: <Widget>[
                  if (isNotEmpty(article.coverImage))
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CachedNetworkImage(
                        imageUrl: '$imageUrl/article-resized/${article.coverImage}',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: Colors.grey[200]),
                      ),
                    )
                  else
                    SizedBox(
                      width: 60,
                      height: 60,
                    ),
                  W(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            TN2('${article.subject}', 16, -0.4, Colors.black87),
                            TN1('${article.insertedAtDiff}', 14, 0, Colors.black87),
                          ],
                        ),
                        H(4),
                        TN1('${article.content}', 14, 0, Colors.black87, maxLines: 2, height: 1.0),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            onTap: () async {
              await Future.delayed(duration1);

              await globalKeyNavigatorMain.currentState
                  .push(MaterialPageRoute(builder: (context) => ArticleDetailsPage(article.articleId)));
            },
          ),
        );
      },
    );
  }
}
