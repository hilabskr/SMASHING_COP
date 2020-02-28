import 'package:abara_app/_main_app.dart';

import 'package:flutter_swiper/flutter_swiper.dart';

class UserInfoPage extends StatefulWidget {
  final User user;

  UserInfoPage(this.user, {Key key}) : super(key: key);

  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  List<Article> listArticle = [];

  var sc = new StreamController<StreamData>();
  bool isGettingData = false;

  bool hasMoreList = true;

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void dispose() {
    sc.close();
    super.dispose();
  }

  Future<void> getData() async {
    if (isGettingData) return;

    isGettingData = true;

    p('~~~~~~~~~~~ getData()');
    var sd = new StreamData();

    try {

      var query = (listArticle.length == 0) ? '' : '&after=${listArticle.last.articleId}';

      var jd = await getJsonData(context, HttpMethod.get, 'article/list?userId=${widget.user.userId}$query');
      if (jd.listArticle == null) {
        throw new Exception();
      } else if (jd.listArticle.length == 0) {
        hasMoreList = false;
      } else {
        listArticle.addAll(jd.listArticle);
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
      backgroundColor: Colors.white,
      appBar: CustomAppBar('${widget.user.userName}', canPop: true),
      body: Column(
        children: <Widget>[
          H(15),
          SizedBox(
            height: 50,
            child: Row(
              children: <Widget>[
                W(19),
                if (isNullOrEmpty(widget.user.profileImage))
                  ICB('default_profile.png', 46, 2)
                else
                  CachedNetworkICB('user-resized-0184/${widget.user.profileImage}', 46, 2),
                W(11),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TN2('${widget.user.userName}', 18, -0.45, Colors.black87),
                    H(5),
                    TN1('${widget.user.schoolName}', 14, 0, Colors.black87),
                  ],
                ),
              ],
            ),
          ),
          H(22),
          Expanded(
            child: Container(
              color: colorDarkYellow,
              child: StreamBuilder<StreamData>(
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
                  } else if (listArticle.length == 0) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 0),
                        child: TN1('게시물이 없습니다', 18, -0.45, Colors.black87),
                      ),
                    );
                  } else {
                    return buildSwiper();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSwiper() {
    p('buildSwiper ~~~');
    return Swiper(
      loop: false,
      itemCount: listArticle.length + ((hasMoreList) ? 1 : 0),
      viewportFraction: 0.8,
      scale: 1,
      itemBuilder: (context, i) {
        if (hasMoreList && i == listArticle.length /*-1+1*/) {
          getData();
          return SizedBox(
            width: 100,
            height: 100,
            child: Center(
              child: CustomCircularProgressIndicator(),
            ),
          );
        } else {
          var article = listArticle[i];
          var listUpvoteProfileImages = (article.upvoteProfileImages ?? '').split(',');

          return Center(
            child: Stack(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(10, 20, 10, 35),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        spreadRadius: -3,
                        offset: Offset(3, 10),
                      ),
                    ],
                  ),
                  child: AspectRatio(
                    aspectRatio: 250 / 320,
                    child: Container(
                      color: Colors.black,
                      padding: EdgeInsets.all(2),
                      child: Container(
                        color: Colors.white,
                        child: Stack(
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Flexible(
                                  flex: 1,
                                  child: Stack(
                                    children: <Widget>[
                                      Positioned(
                                        left: 18,
                                        top: 17,
                                        child: I('icon_action_favorite_2.png', 14, 13),
                                      ),
                                      Positioned(
                                        left: 39,
                                        top: 16,
                                        child: TN2('${article.upvoteCount}', 14, -0.35, Color(0xffff5700)),
                                      ),
                                      if (listUpvoteProfileImages.length >= 3)
                                        Positioned(
                                          left: 51,
                                          top: 38,
                                          child: (listUpvoteProfileImages[2] == '_')
                                              ? ICB('default_profile.png', 19, 2)
                                              : CachedNetworkICB('user-resized-0184/${listUpvoteProfileImages[2]}', 19, 2),
                                        ),
                                      if (listUpvoteProfileImages.length >= 2)
                                        Positioned(
                                          left: 34,
                                          top: 38,
                                          child: (listUpvoteProfileImages[1] == '_')
                                              ? ICB('default_profile.png', 19, 2)
                                              : CachedNetworkICB('user-resized-0184/${listUpvoteProfileImages[1]}', 19, 2),
                                        ),
                                      if (listUpvoteProfileImages[0] != '')
                                        Positioned(
                                          left: 17,
                                          top: 38,
                                          child: (listUpvoteProfileImages[0] == '_')
                                              ? ICB('default_profile.png', 19, 2)
                                              : CachedNetworkICB('user-resized-0184/${listUpvoteProfileImages[0]}', 19, 2),
                                        ),
                                      if (article.relationshipScore != null && article.relationshipScore != -1)
                                        Positioned(
                                          top: -5,
                                          right: -12,
                                          child: TN1('${article.relationshipScore}', 100, -2.5, colorDarkYellow),
                                        ),
                                      Positioned(
                                        left: 18,
                                        bottom: 11,
                                        child: TN2('${article.subject}', 18, -0.45, Colors.black87),
                                      ),
                                    ],
                                  ),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: Stack(
                                    children: <Widget>[
                                      if (isNotEmpty(article.coverImage))
                                        Positioned(
                                          left: 0,
                                          top: 0,
                                          right: 0,
                                          bottom: 0,
                                          child: CachedNetworkImage(
                                            imageUrl: '$imageUrl/article-resized/${article.coverImage}',
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Container(color: Colors.grey[200]),
                                          ),
                                        ),
                                      Positioned(
                                        left: 18,
                                        top: 10,
                                        right: 18,
                                        child: TN1('${article.content}', 11, -0.27, Colors.black87, maxLines: 10),
                                      ),
                                      if (article.user?.userName != null)
                                        Positioned(
                                          right: 13,
                                          bottom: 15,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                            height: 20,
                                            decoration:
                                                BoxDecoration(color: Color(0xd9ff5700), borderRadius: BorderRadius.circular(20)),
                                            child: Center(child: TN1('by ${article.user.userName}', 11, 0, Color(0xdeffffff))),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                highlightColor: Color(0x663366cc),
                                splashColor: Color(0x663366cc),
                                onTap: () async {
                                  await Future.delayed(duration1);

                                  await globalKeyNavigatorMain.currentState
                                      .push(MaterialPageRoute(builder: (context) => ArticleDetailsPage(article.articleId)));
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (article.relationshipScore != null && article.relationshipScore != -1)
                  Positioned(
                    left: 0,
                    top: 0,
                    right: 0,
                    child: Center(child: I(getEmoji(article.relationshipScore), 80, 83)),
                  ),
              ],
            ),
          );
        }
      },
    );
  }
}
