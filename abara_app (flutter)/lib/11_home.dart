import 'package:abara_app/_main_app.dart';

import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  final UserData userData;

  HomePage(this.userData);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Weather weather;

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getData() async {
    p('~~~~~~~~~~~ getData()');

    try {
      var jd = await getJsonData(context, HttpMethod.get, 'weather/current');
      if (jd.isSuccess == true && jd.weather != null) {
        setState(() {
          weather = jd.weather;
        });
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
      await displayAlert(mounted, context, '날씨정보를 받아오는 중\n에러가 발생하였습니다');
    }
  }

  @override
  Widget build(BuildContext context) {
    p('build ${this.runtimeType} ~~~~~~~~~~~~~~~~~~~~');

    var userMe = widget.userData.user;
    var date = DateFormat('M/d, EEE').format(DateTime.now());

    return Scaffold(
      appBar: CustomAppBarImage(),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  W(51),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TN1('Hello,', 60, 0, Colors.black87),
                      TN1('${userMe.userName}', 60, 0, Colors.black87),
                      H(20),
                      TN1('${userMe.schoolName}', 20, -0.5, Colors.black87),
                      H(20),
                      TN1('$date', 14, -0.35, Colors.black87),
                      H(2),
                      if (weather != null)
                        Row(
                          children: <Widget>[
                            CachedNetworkImage(
                              width: 30,
                              height: 30,
                              imageUrl: weather.icon,
                              fit: BoxFit.fill,
                            ),
                            W(3),
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: TN1('${weather.temperature}', 20, -0.5, Colors.black87),
                            ),
                          ],
                        )
                      else
                        H(30),
                    ],
                  ),
                  W(30),
                  buildCard(1),
                  W(55),
                  buildCard(2),
                  W(55),
                  buildCard(3),
                  W(55),
                  buildCard(4),
                  W(55),
                  buildCard(5),
                  W(55),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCard(int index) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 20,
            spreadRadius: -3,
            offset: Offset(3, 5),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          I('thumbnail_1_depth_0$index.png', 250, 320),
          Material(
            color: Colors.transparent,
            child: InkWell(
              highlightColor: Color(0x663366cc),
              splashColor: Color(0x663366cc),
              child: SizedBox(
                width: 250,
                height: 320,
              ),
              onTap: () async {
                await Future.delayed(duration1);
                p(index);

                switch (index) {
                  case 1:
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => HomeArticleListPage('FR')));
                    break;
                  case 2:
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => HomeArticleListPage('MK')));
                    break;
                  case 3:
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => HomeArticleListPage('JB')));
                    break;
                  case 4:
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => HomeArticleListPage('CT')));
                    break;
                  case 5:
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => HomeUserListPage()));
                    break;
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
