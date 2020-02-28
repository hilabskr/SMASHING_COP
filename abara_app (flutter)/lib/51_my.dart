import 'package:abara_app/_main_app.dart';

import 'package:flutter_swiper/flutter_swiper.dart';

class MyPage extends StatefulWidget {
  final UserData userData;

  MyPage(this.userData, Key key) : super(key: key);

  @override
  MyPageState createState() => MyPageState();
}

class MyPageState extends State<MyPage> with SingleTickerProviderStateMixin {
  List<Article> listArticle = [];
  var selectedChip = '';

  var sc = new StreamController<StreamData>();
  bool isGettingData = false;

  bool hasMoreList = true;

  var swc = new SwiperController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    sc.close();
    super.dispose();
  }

  Future<void> getData({bool refresh = false}) async {
    if (isGettingData) return;

    isGettingData = true;

    p('~~~~~~~~~~~ getData()');
    var sd = new StreamData();

    try {
      if (refresh == true) {
        sc.add(new StreamData(isLoading: true));
        setState(() {
          hasMoreList = true;
          listArticle.clear();
          swc.move(0, animation: true);
        });
      }

      var userMe = widget.userData.user;

      var query1 = (selectedChip == '') ? '' : '${mapCategory1Url[selectedChip]}/';
      var query2 = (listArticle.length == 0) ? '' : '&after=${listArticle.last.articleId}';

      var jd = await getJsonData(context, HttpMethod.get, 'article/${query1}list?userId=${userMe.userId}$query2');
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

    var actions = <Widget>[
      IconButton(
        icon: Icon(Icons.settings),
        color: Colors.black,
        onPressed: () async {
          await Future.delayed(duration1);
          var result = await Navigator.push(context, MaterialPageRoute(builder: (context) => MySettingPage()));
          p('get back =============================================');
        },
      )
    ];

    var userMe = widget.userData.user;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar('MY ACCOUNT', actions: actions),
      body: Column(
        children: <Widget>[
          H(15),
          SizedBox(
            height: 50,
            child: Stack(
              children: <Widget>[
                Positioned(
                  left: 0,
                  top: 0,
                  right: 0,
                  child: Row(
                    children: <Widget>[
                      W(19),
                      if (isNullOrEmpty(userMe.profileImage))
                        ICB('default_profile.png', 46, 2)
                      else
                        CachedNetworkICB('user-resized-0184/${userMe.profileImage}', 46, 2),
                      W(11),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          TN2('${userMe.userName}', 18, -0.45, Colors.black87),
                          H(5),
                          TN1('${userMe.email}', 14, 0, Colors.black87),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: Icon(Icons.notifications),
                    color: Colors.black,
                    onPressed: () async {
                      await Future.delayed(duration1);
                      var result = await Navigator.push(context, MaterialPageRoute(builder: (context) => MyNotificationPage()));
                      p('get back =============================================');
                    },
                  ),
                ),
              ].where((child) => child != null).toList(),
            ),
          ),
          H(22),
          Expanded(
            child: Container(
              color: colorDarkYellow,
              child: Column(
                children: <Widget>[
                  H(10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: listCategory1My.map((item) {
                        return Center(
                          child: GestureDetector(
                            child: Container(
                              margin: EdgeInsets.all(6),
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                              height: 26,
                              decoration: BoxDecoration(
                                  color: (item == selectedChip) ? Colors.black : Color(0x4d000000),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Center(child: TN2('${mapCategory1Name[item] ?? '전체'}', 14, -0.35, Color(0xdeffffff))),
                            ),
                            onTap: () async {
                              if (item != selectedChip) {
                                while (isGettingData) await Future.delayed(duration2);
                                setState(() {
                                  selectedChip = item;
                                });
                                await getData(refresh: true);
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Expanded(
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
                              padding: EdgeInsets.only(bottom: 20),
                              child: TN1('게시물이 없습니다', 18, -0.45, Colors.black87),
                            ),
                          );
                        } else {
                          return buildSwiper();
                        }
                      },
                    ),
                  ),
                ],
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
      controller: swc,
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
            child: Container(
              margin: EdgeInsets.fromLTRB(10, 10, 10, 30),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
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
          );
        }
      },
    );
  }
}
