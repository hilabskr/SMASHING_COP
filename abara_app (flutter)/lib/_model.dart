import 'package:abara_app/_main_app.dart';
import 'package:http/http.dart' as http;

class UserData with ChangeNotifier {
  String userAgent;
  String appVersion;
  int platformType;
  String platformVersion;
  String userDataPath;

  String rememberEmail;
  String accessToken;
  User user;

  int newCount = 0;

  UserData(this.userAgent, this.appVersion, this.platformType, this.platformVersion, this.userDataPath) {
    p('loadData() from $userDataPath');

    if (File(userDataPath).existsSync()) {
      try {
        var content = File(userDataPath).readAsStringSync();
        p(content);
        var map = json.decode(content);
        this.rememberEmail = map['rememberEmail'];
        this.accessToken = map['accessToken'];
        this.user = User.fromMap(map['user']);
        this.newCount = map['newCount'];
      } catch (ex) {}
    }
  }

  Map<String, dynamic> toMap() => {
        'rememberEmail': rememberEmail,
        'accessToken': accessToken,
        'user': (user == null) ? null : user.toMap(),
        'newCount': newCount,
      };

  bool get shouldLogin => (accessToken == null || user == null);

  bool get isLogged => (accessToken != null && user != null);

  Future<void> saveData() async {
    p('saveData() to $userDataPath');
    var content = json.encode(this.toMap());
    p(content);

    await File(userDataPath).writeAsString(content);
  }

  Future<void> login(String rememberEmail, String accessToken, User user) async {
    this.rememberEmail = rememberEmail;
    this.accessToken = accessToken;
    this.user = user;

    await saveData();
  }

  Future<void> update(User user) async {
    this.user = user;

    await saveData();
    notifyListeners();
  }

  Future<void> updateCurrentActiveUser() async {
    if (shouldLogin) return;

    try {
      var api = 'current-active-user/update';
      var response = await http.post(
        baseUrl + api,
        headers: {
          'User-Agent': userAgent,
          HttpHeaders.authorizationHeader: 'Bearer ${this.accessToken}',
        },
      ).timeout(Duration(milliseconds: 5000));
      p('$api ${response.statusCode}');
    } catch (ex) {}
  }

  Future<void> updateSession() async {
    if (shouldLogin) return;

    var mapRequestBody = {
      'appVersion': appVersion,
      'platformType': platformType.toString(),
      'platformVersion': platformVersion,
    };

    try {
      final firebaseToken = await firebaseMessaging.getToken().timeout(Duration(milliseconds: 3000));

      if (firebaseToken != null) mapRequestBody['firebaseToken'] = firebaseToken;
      p(firebaseToken);
    } catch (ex) {}

    try {
      var api = 'session/update';
      var response = await http
          .post(
            baseUrl + api,
            headers: {
              'User-Agent': userAgent,
              HttpHeaders.authorizationHeader: 'Bearer ${this.accessToken}',
            },
            body: mapRequestBody,
          )
          .timeout(Duration(milliseconds: 5000));
      p('$api ${response.statusCode}');
    } catch (ex) {}
  }

  Future<void> logout() async {
    try {
      var api = 'session/logout';
      var response = await http.post(baseUrl + api, headers: {
        'User-Agent': userAgent,
        HttpHeaders.authorizationHeader: 'Bearer ${this.accessToken}',
      }).timeout(Duration(milliseconds: 3000));
      p('$api ${response.statusCode}');
    } catch (ex) {}

    this.accessToken = null;
    this.user = null;
    this.newCount = 0;

    await saveData();

    globalKeyNavigatorMenu0.currentState.popUntil((route) => route.isFirst);

    globalKeyNavigatorMain.currentState.popUntil((route) => route.isFirst);

    globalKeyNavigatorMain.currentState.pushReplacement(MaterialPageRoute(builder: (context) => new LoginPage()));

  }
}

class UserVerification {
  final int userVerificationId;

  UserVerification({
    this.userVerificationId,
  });

  factory UserVerification.fromMap(Map<String, dynamic> map) {
    return (map == null)
        ? null
        : UserVerification(
            userVerificationId: map['userVerificationId'],
          );
  }
}

class User {
  final String userId;
  final String userName;
  final String email;
  final String schoolName;
  final String comment;
  final String profileImage;
  final bool allowOthersToFindMe;
  final int relationshipScore;

  User({
    this.userId,
    this.userName,
    this.email,
    this.schoolName,
    this.comment,
    this.profileImage,
    this.allowOthersToFindMe,
    this.relationshipScore,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return (map == null)
        ? null
        : User(
            userId: map['userId'],
            userName: map['userName'],
            email: map['email'],
            schoolName: map['schoolName'],
            comment: map['comment'],
            profileImage: map['profileImage'],
            allowOthersToFindMe: map['allowOthersToFindMe'],
            relationshipScore: map['relationshipScore'],
          );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'userName': userName,
        'email': email,
        'schoolName': schoolName,
        'comment': comment,
        'profileImage': profileImage,
        'allowOthersToFindMe': allowOthersToFindMe,
      };
}

class Weather {
  final String icon;
  final String temperature;
  final DateTime createdAt;

  Weather({
    this.icon,
    this.temperature,
    this.createdAt,
  });

  factory Weather.fromMap(Map<String, dynamic> map) {
    return (map == null)
        ? null
        : Weather(
            icon: map['icon'],
            temperature: map['temperature'],
            createdAt: DateTime.parse(map['createdAt'].substring(0, 19)),
          );
  }
}

class Article {
  final int articleId;
  final User user;
  final String category1;
  final String category2;
  final String subject;
  final String content;
  final String fileNames;
  final String fileProperties;
  final String coverImage;
  final String insertedAtDiff;
  final int viewCount;
  final String upvoteProfileImages;
  final int upvoteCount;
  final int commentCount;
  final bool isEditable;
  final bool isUpvoted;
  final bool isBookmarked;
  final int relationshipScore;

  Article({
    this.articleId,
    this.user,
    this.category1,
    this.category2,
    this.subject,
    this.content,
    this.fileNames,
    this.fileProperties,
    this.coverImage,
    this.insertedAtDiff,
    this.viewCount,
    this.upvoteProfileImages,
    this.upvoteCount,
    this.commentCount,
    this.isEditable,
    this.isUpvoted,
    this.isBookmarked,
    this.relationshipScore,
  });

  factory Article.fromMap(Map<String, dynamic> map) {
    return (map == null)
        ? null
        : Article(
            articleId: map['articleId'],
            user: User.fromMap(map['user']),
            category1: map['category1'],
            category2: map['category2'],
            subject: map['subject'],
            content: map['content'],
            fileNames: map['fileNames'],
            fileProperties: map['fileProperties'],
            coverImage: map['coverImage'],
            insertedAtDiff: map['insertedAtDiff'],
            viewCount: map['viewCount'],
            upvoteProfileImages: map['upvoteProfileImages'],
            upvoteCount: map['upvoteCount'],
            commentCount: map['commentCount'],
            isEditable: map['isEditable'],
            isUpvoted: map['isUpvoted'],
            isBookmarked: map['isBookmarked'],
            relationshipScore: map['relationshipScore'],
          );
  }
}

class ArticleComment {
  final User user;
  final String comment;
  final String insertedAtDiff;

  ArticleComment({
    this.user,
    this.comment,
    this.insertedAtDiff,
  });

  factory ArticleComment.fromMap(Map<String, dynamic> map) {
    return (map == null)
        ? null
        : ArticleComment(
            user: User.fromMap(map['user']),
            comment: map['comment'],
            insertedAtDiff: map['insertedAtDiff'],
          );
  }
}

class Bookmark {
  final int bookmarkId;
  final Article article;

  Bookmark({
    this.bookmarkId,
    this.article,
  });

  factory Bookmark.fromMap(Map<String, dynamic> map) {
    return (map == null)
        ? null
        : Bookmark(
            bookmarkId: map['bookmarkId'],
            article: Article.fromMap(map['article']),
          );
  }
}

class Room {
  final int roomId;
  final User userFrom;
  final String lastMessage;
  final String lastMessageDateTime;

  Room({
    this.roomId,
    this.userFrom,
    this.lastMessage,
    this.lastMessageDateTime,
  });

  factory Room.fromMap(Map<String, dynamic> map) {
    return (map == null)
        ? null
        : Room(
            roomId: map['roomId'],
            userFrom: User.fromMap(map['userFrom']),
            lastMessage: map['lastMessage'],
            lastMessageDateTime: map['lastMessageDateTime'],
          );
  }
}

class PersonalNotification {
  final int personalNotificationId;
  final Article article;
  final User fromUser;
  final String content;
  final String insertedAtDiff;
  final bool hasChecked;

  PersonalNotification({
    this.personalNotificationId,
    this.article,
    this.fromUser,
    this.content,
    this.insertedAtDiff,
    this.hasChecked,
  });

  factory PersonalNotification.fromMap(Map<String, dynamic> map) {
    return (map == null)
        ? null
        : PersonalNotification(
            personalNotificationId: map['personalNotificationId'],
            article: Article.fromMap(map['article']),
            fromUser: User.fromMap(map['fromUser']),
            content: map['content'],
            insertedAtDiff: map['insertedAtDiff'],
            hasChecked: map['hasChecked'],
          );
  }
}

class ChatRoom {
  final int chatRoomId;
  final User userFriend;
  final int userMeNewCount;
  final ChatMessage lastChatMessage;
  final int relationshipScore;

  ChatRoom({
    this.chatRoomId,
    this.userFriend,
    this.userMeNewCount,
    this.lastChatMessage,
    this.relationshipScore,
  });

  factory ChatRoom.fromMap(Map<String, dynamic> map) {
    return (map == null)
        ? null
        : ChatRoom(
            chatRoomId: map['chatRoomId'],
            userFriend: User.fromMap(map['userFriend']),
            userMeNewCount: map['userMeNewCount'],
            lastChatMessage: ChatMessage.fromMap(map['lastChatMessage']),
            relationshipScore: map['relationshipScore'],
          );
  }
}

class ChatMessage {
  final int chatMessageId;
  final ChatRoom chatRoom;
  final User user;
  final String message;
  final bool isNewDay;
  final DateTime insertedAt;
  final String insertedAtDiff;
  final bool isMyMessage;

  ChatMessage({
    this.chatMessageId,
    this.chatRoom,
    this.user,
    this.message,
    this.isNewDay,
    this.insertedAt,
    this.insertedAtDiff,
    this.isMyMessage,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return (map == null)
        ? null
        : ChatMessage(
            chatMessageId: map['chatMessageId'],
            chatRoom: ChatRoom.fromMap(map['chatRoom']),
            user: User.fromMap(map['user']),
            message: map['message'],
            isNewDay: map['isNewDay'],
            insertedAt: (map['insertedAt'] == null) ? null : DateTime.parse(map['insertedAt'].substring(0, 19)),
            insertedAtDiff: map['insertedAtDiff'],
            isMyMessage: map['isMyMessage'],
          );
  }
}

class JsonData {
  final bool isUpdateNeeded;
  final bool isUpdateRecommended;
  final bool isSuccess;
  final String responseMessage;
  final UserVerification userVerification;
  final String accessToken;
  final Weather weather;
  final List<Article> listArticle;
  final Article article;
  final List<ArticleComment> listArticleComment;
  final bool isToggled;
  final List<Bookmark> listBookmark;
  final List<User> listUser;
  final User user;
  final List<PersonalNotification> listPersonalNotification;
  final List<ChatRoom> listChatRoom;
  final ChatRoom chatRoom;
  final List<ChatMessage> listChatMessage;
  final bool isNewCountUpdated;

  JsonData({
    this.isUpdateNeeded,
    this.isUpdateRecommended,
    this.isSuccess,
    this.responseMessage,
    this.userVerification,
    this.accessToken,
    this.weather,
    this.listArticle,
    this.article,
    this.listArticleComment,
    this.isToggled,
    this.listBookmark,
    this.listUser,
    this.user,
    this.listPersonalNotification,
    this.listChatRoom,
    this.chatRoom,
    this.listChatMessage,
    this.isNewCountUpdated,
  });

  factory JsonData.fromMap(Map<String, dynamic> map) {
    return JsonData(
      isUpdateNeeded: map['isUpdateNeeded'],
      isUpdateRecommended: map['isUpdateRecommended'],
      isSuccess: map['isSuccess'],
      responseMessage: map['responseMessage'],
      userVerification: UserVerification.fromMap(map['userVerification']),
      accessToken: map['accessToken'],
      weather: Weather.fromMap(map['weather']),
      listArticle: map['listArticle'] == null ? null : (map['listArticle'] as List).map((V) => Article.fromMap(V)).toList(),
      article: Article.fromMap(map['article']),
      listArticleComment: map['listArticleComment'] == null
          ? null
          : (map['listArticleComment'] as List).map((V) => ArticleComment.fromMap(V)).toList(),
      isToggled: map['isToggled'],
      listBookmark: map['listBookmark'] == null ? null : (map['listBookmark'] as List).map((V) => Bookmark.fromMap(V)).toList(),
      listUser: map['listUser'] == null ? null : (map['listUser'] as List).map((V) => User.fromMap(V)).toList(),
      user: User.fromMap(map['user']),
      listPersonalNotification: map['listPersonalNotification'] == null
          ? null
          : (map['listPersonalNotification'] as List).map((V) => PersonalNotification.fromMap(V)).toList(),
      listChatRoom: map['listChatRoom'] == null ? null : (map['listChatRoom'] as List).map((V) => ChatRoom.fromMap(V)).toList(),
      chatRoom: ChatRoom.fromMap(map['chatRoom']),
      listChatMessage:
          map['listChatMessage'] == null ? null : (map['listChatMessage'] as List).map((V) => ChatMessage.fromMap(V)).toList(),
      isNewCountUpdated: map['isNewCountUpdated'],
    );
  }
}

class StreamData {
  JsonData jd;
  String errorMessage;
  bool isLoading;

  StreamData({this.isLoading});
}
