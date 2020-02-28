import 'package:abara_app/_main_app.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';

class ArticleDetailsPage extends StatefulWidget {
  final int articleId;

  ArticleDetailsPage(this.articleId, {Key key}) : super(key: key);

  @override
  _ArticleDetailsPageState createState() => _ArticleDetailsPageState();
}

class _ArticleDetailsPageState extends State<ArticleDetailsPage> {
  var sc = new StreamController<StreamData>();
  bool isGettingData = false;

  var tecComment = TextEditingController();

  bool isPosting = false;

  bool isBookmarked;

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void dispose() {
    sc.close();
    tecComment.dispose();
    super.dispose();
  }

  Future<void> getData() async {
    while (isGettingData) await Future.delayed(duration2);
    isGettingData = true;

    p('~~~~~~~~~~~ getData()');
    var sd = new StreamData();

    try {
      var jd = await getJsonData(context, HttpMethod.get, 'article/details/${widget.articleId}');
      if (jd.isSuccess == false && isNotEmpty(jd.responseMessage)) {
        sd.errorMessage = jd.responseMessage;
      } else if (jd.article == null || jd.listArticleComment == null) {
        throw new Exception();
      } else {
        isBookmarked = jd.article.isBookmarked;
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
      p(ex);
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
            return buildContent(snapshot.data.jd);
          }
        },
      ),
    );
  }

  Widget buildContent(JsonData jd) {
    p('buildContent ~~');

    var article = jd.article;

    var actions = <Widget>[
      PopupMenuButton<DetailsMenu>(
        offset: Offset(0, 56),
        itemBuilder: (context) => [
          if (article.isEditable == true)
            PopupMenuItem(
              value: DetailsMenu.edit,
              child: Row(
                children: <Widget>[
                  Icon(Icons.mode_edit, color: Colors.black87),
                  W(7),
                  TN1('수정', 18, 0, Colors.black87),
                ],
              ),
            ),
          if (article.isEditable == true)
            PopupMenuItem(
              value: DetailsMenu.delete,
              child: Row(
                children: <Widget>[
                  Icon(Icons.delete, color: Colors.black87),
                  W(7),
                  TN1('삭제', 18, 0, Colors.black87),
                ],
              ),
            ),
        ],
        onSelected: (value) async {
          await Future.delayed(duration1);
          p(value);
          switch (value) {
            case DetailsMenu.edit:
              await edit();
              break;
            case DetailsMenu.delete:
              await delete();
              break;
            case DetailsMenu.report:
              break;
          }
        },
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar('${article.subject}', canPop: true, actions: (article.isEditable == true) ? actions : null),
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            if (tecComment.text.trim() == '') {
              return Future<bool>.value(true);
            } else {
              return displayConfirm(mounted, context, '댓글에 입력하던 내용이 있습니다',
                  dismissible: false, choiceCancel: '머무르기', choiceOk: '삭제하기');
            }
          },
          child: AbsorbPointer(
            absorbing: (isPosting || isUpvoting || isEditing || isDeleting || isBookmarking),
            child: Stack(
              children: <Widget>[
                buildListView(jd),
                if (isPosting || isUpvoting || isEditing || isDeleting || isBookmarking)
                  Center(child: CustomCircularProgressIndicator()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildListView(JsonData jd) {
    p('buildListView ~~');

    var article = jd.article;

    var listFileName = article.fileNames.split('/');
    var listFileProperty = article.fileProperties.split('/');

    var listImageWidget = [];
    for (int i = 0; i < listFileName.length; i++) {
      if (listFileName[i] == '_') continue;
      p(listFileName[i]);
      p(listFileProperty[i]);
      p('$imageUrl/article-resized/${listFileName[i]}');

      var wOriginal = int.parse(listFileProperty[i].split('x')[0]);
      var hOriginal = int.parse(listFileProperty[i].split('x')[1]);

      listImageWidget.add(
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: GestureDetector(
              child: Container(
                width: w340plus,
                height: hOriginal * w340plus / wOriginal,
                child: CachedNetworkImage(
                  fit: BoxFit.fill,
                  fadeInDuration: Duration(milliseconds: 0),
                  imageUrl: '$imageUrl/article-resized/${listFileName[i]}',
                  placeholder: (context, url) => Container(color: Colors.grey[200]),
                  errorWidget: (context, url, error) => Icon(
                    Icons.error,
                    color: Colors.grey[300],
                    size: 50,
                  ),
                ),
                margin: EdgeInsets.only(bottom: 7),
              ),
            ),
          ),
        ),
      );
    }

    return ListView(
      children: <Widget>[
        H(7),
        if (listImageWidget.length > 0)
          ...listImageWidget
        else
          H(7),
        H(10),
        if (article.user == null)
          SizedBox(
            height: 18,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Positioned(
                  left: 19,
                  top: 2,
                  child: TN1('${article.insertedAtDiff}', 14, 0, Colors.black87),
                ),
                Positioned(
                  top: 2,
                  right: 39,
                  child: TN2('${article.upvoteCount}', 14, -0.35, colorOrange),
                ),
                Positioned(
                  top: -16,
                  right: 3,
                  child: IconButton(
                    icon: Icon((article.isUpvoted == true)
                        ? Icons.favorite
                        : Icons.favorite_border),
                    iconSize: 16,
                    color: colorOrange,
                    onPressed: () async {
                      if (article.isUpvoted == false) {
                        await upvote();
                      }
                    },
                  ),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 72,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Positioned(
                  left: 19,
                  child: GestureDetector(
                    child: (isNullOrEmpty(article.user.profileImage))
                        ? ICB('default_profile.png', 46, 2)
                        : CachedNetworkICB('user-resized-0184/${article.user.profileImage}', 46, 2),
                    onTap: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (context) => UserInfoPage(article.user)));
                    },
                  ),
                ),
                Positioned(
                  left: 81,
                  top: 9,
                  child: TN2('${article.user.userName}', 18, -0.45, Colors.black87),
                ),
                Positioned(
                  left: 81,
                  top: 32,
                  child: TN1('${article.insertedAtDiff}', 14, 0, Colors.black87),
                ),
                Positioned(
                  top: 5,
                  right: 14,
                  child: GestureDetector(
                    child: I('message.png', 24, 24),
                    onTap: () async {
                      await Navigator.push(
                          context, MaterialPageRoute(builder: (context) => ChatRoomPage(article.user, globalKeyChatRoom)));
                    },
                  ),
                ),
                Positioned(
                  top: 48,
                  right: 39,
                  child: TN2('${article.upvoteCount}', 14, -0.35, colorOrange),
                ),
                Positioned(
                  top: 30,
                  right: 3,
                  child: IconButton(
                    icon: Icon((article.isUpvoted == true)
                        ? Icons.favorite
                        : Icons.favorite_border),
                    iconSize: 16,
                    color: colorOrange,
                    onPressed: () async {
                      if (article.isUpvoted == false) {
                        await upvote();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

        (article.user == null) ? H(21) : H(1),
        Container(height: 1, color: Colors.black12),
        H(17),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 17),
          child: TN2('${article.subject}', 20, 0, Colors.black87, maxLines: 10, height: 32 / 20),
        ),
        H(20),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: TN1('${article.content}', 16, 0, Colors.black87, maxLines: 10000, height: 26 / 16),
        ),
        H(60),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  children: <Widget>[
                    I('comment.png', 16, 16),
                    W(8),
                    TR1('${article.commentCount} ' + ((article.commentCount > 1) ? 'Comments' : 'Comment'), 12, 0,
                        Colors.black54),
                  ],
                ),
              ),
              InkWell(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: <Widget>[
                      I('share.png', 16, 16),
                      W(8),
                      TR1('Share', 12, 0, Colors.black54),
                    ],
                  ),
                ),
                onTap: () {
                  Share.text(article.subject, article.content, 'text/plain');
                },
              ),
              InkWell(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: <Widget>[
                      if (isBookmarked == true) I('bookmark_on.png', 16, 16) else I('bookmark.png', 16, 16),
                      W(8),
                      TR1('Save', 12, 0, Colors.black54),
                    ],
                  ),
                ),
                onTap: bookmark,
              ),
            ],
          ),
        ),
        H(8),
        Container(height: 1, color: Colors.black12),

        for (var articleComment in jd.listArticleComment) ...[
          H(13),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (articleComment.user?.userId == null)
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: Stack(
                      children: <Widget>[
                        Center(
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Color(0xFFff5a00),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Center(
                          child: TN2('W', 12, -0.3, Colors.white),
                        ),
                      ],
                    ),
                  )
                else
                  GestureDetector(
                    child: (isNullOrEmpty(articleComment.user.profileImage))
                        ? ICB('default_profile.png', 28, 2)
                        : CachedNetworkICB('user-resized-0184/${articleComment.user.profileImage}', 28, 2),
                    onTap: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (context) => UserInfoPage(articleComment.user)));
                    },
                  ),
                W(9),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    H(6),
                    if (articleComment.user?.userId == null)
                      Row(
                        children: <Widget>[
                          TN2('작성자', 14, -0.35, Colors.black87),
                          W(7),
                          Container(
                            width: 0,
                            height: 18,
                          ),
                          W(3),
                          TN1('${articleComment.insertedAtDiff}', 14, 0, Color(0xFFcccccc)),
                        ],
                      )
                    else if (article.user?.userId != null && article.user.userId == articleComment.user.userId)
                      Row(
                        children: <Widget>[
                          TN2('${articleComment.user.userName}', 14, -0.35, Colors.black87),
                          W(7),
                          Container(
                            width: 57,
                            height: 18,
                            decoration: BoxDecoration(color: Color(0xFFff5c08), borderRadius: BorderRadius.circular(9)),
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 2),
                                child: TN2('WRITER', 12, -0.3, Colors.white),
                              ),
                            ),
                          ),
                          W(7),
                          TN1('${articleComment.insertedAtDiff}', 14, 0, Color(0xFFcccccc)),
                        ],
                      )
                    else
                      Row(
                        children: <Widget>[
                          TN2('${articleComment.user.userName}', 14, -0.35, Colors.black87),
                          W(7),
                          Container(
                            width: 0,
                            height: 18,
                          ),
                          W(3),
                          TN1('${articleComment.insertedAtDiff}', 14, 0, Color(0xFFcccccc)),
                        ],
                      ),
                    H(6),
                    TN1('${articleComment.comment}', 14, -0.35, Colors.black87, maxLines: 1000),
                  ],
                ),
              ],
            ),
          ),
          H(13),
          Container(height: 1, color: Colors.black12),
        ],

        H(55),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Material(
            child: TextField(
              style: textStyleTextField1,
              decoration: InputDecoration(
                fillColor: Color(0x4ccccccc),
                filled: true,
                hintText: '댓글쓰기',
                border: UnderlineInputBorder(),
                focusedBorder: UnderlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.create),
                  onPressed: post,
                ),
                enabled: !isPosting,
              ),
              keyboardType: TextInputType.multiline,
              maxLines: null,
              controller: tecComment,
            ),
          ),
        ),
        H(16),
      ],
    );
  }

  Future<void> post() async {
    await Future.delayed(duration1);

    if (isPosting) return;

    if (isNullOrWhiteSpace(tecComment.text)) {
      await displayAlert(mounted, context, '댓글을 입력해주세요');
      return;
    }
    if (tecComment.text.trim().length < 2) {
      await displayAlert(mounted, context, '댓글을 2글자 이상 입력해주세요');
      return;
    }

    setState(() {
      isPosting = true;
    });

    try {
      var mapRequestBody = {
        'articleId': widget.articleId.toString(),
        'comment': tecComment.text.trim(),
      };

      var jd = await getJsonData(context, HttpMethod.post, 'article-comment/add', mapRequestBody);

      if (jd.isSuccess == false && isNotEmpty(jd.responseMessage)) {
        await displayAlert(mounted, context, jd.responseMessage);
      } else if (jd.isSuccess == true) {
        if (isNotEmpty(jd.responseMessage)) {
          await displayAlert(mounted, context, jd.responseMessage);
        }
        tecComment.clear();
        sc.add(new StreamData(isLoading: true));
        await getData();
      } else {
        throw new Exception();
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

  bool isUpvoting = false;

  Future<void> upvote() async {
    await Future.delayed(duration1);

    if (isUpvoting) return;
    isUpvoting = true;

    try {
      var jd = await getJsonData(context, HttpMethod.post, 'article/upvote/${widget.articleId}');

      if (jd.isSuccess == false) {
        if (isNotEmpty(jd.responseMessage)) {
          await displayAlert(mounted, context, jd.responseMessage);
        }
      } else if (jd.isSuccess == true) {
        await getData();
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
      isUpvoting = false;
    }
  }

  bool isEditing = false;

  Future<void> edit() async {
    await Future.delayed(duration1);

    if (isEditing) return;
    setState(() {
      isEditing = true;
    });

    try {
      var jd = await getJsonData(context, HttpMethod.get, 'article/details/${widget.articleId}');

      if (jd.isSuccess == false) {
        if (isNotEmpty(jd.responseMessage)) {
          await displayAlert(mounted, context, jd.responseMessage);
        } else {
          throw new Exception();
        }
      } else if (jd.article == null || jd.listArticleComment == null) {
        throw new Exception();
      } else {
        bool isEdited = await Navigator.push(context, MaterialPageRoute(builder: (context) => ArticleEditPage(jd.article)));
        p('get back =============================================');
        if (isEdited == true) {
          await getData();
        }
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
          isEditing = false;
        });
      }
    }
  }

  bool isDeleting = false;

  Future<void> delete() async {
    await Future.delayed(duration1);

    if (isDeleting) return;
    setState(() {
      isDeleting = true;
    });

    try {
      if (await displayConfirm(mounted, context, '삭제할까요?\n\n삭제되면 복구할 수 없습니다')) {
        var jd = await getJsonData(context, HttpMethod.post, 'article/delete/${widget.articleId}');

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

          await getData();
        }
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
          isDeleting = false;
        });
      }
    }
  }

  bool isBookmarking = false;

  Future<void> bookmark() async {
    await Future.delayed(duration1);

    if (isBookmarking) return;
    setState(() {
      isBookmarking = true;
    });

    try {
      var query = (isBookmarked == true) ? 'remove' : 'add';

      var mapRequestBody = {
        'articleId': widget.articleId.toString(),
      };

      var jd = await getJsonData(context, HttpMethod.post, 'bookmark/$query', mapRequestBody);

      if (jd.isToggled == null) throw new Exception();

      if (isNotEmpty(jd.responseMessage)) {
        await displayAlert(mounted, context, jd.responseMessage);
      }

      setState(() {
        isBookmarked = jd.isToggled;
      });

      await globalKeyBookmark.currentState.getData();
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
          isBookmarking = false;
        });
      }
    }
  }
}
