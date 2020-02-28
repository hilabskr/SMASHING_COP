import 'package:abara_app/_main_app.dart';

class MySettingContactPage extends StatefulWidget {
  @override
  _MySettingContactPageState createState() => _MySettingContactPageState();
}

class _MySettingContactPageState extends State<MySettingContactPage> {
  var tecSubject = TextEditingController();
  var tecContent = TextEditingController();

  bool isPosting = false;

  @override
  void initState() {
    super.initState();
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
      backgroundColor: Colors.white,
      appBar: CustomAppBar('CUSTOMER CENTER', canPop: true),
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            return Future<bool>.value(true);
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
    );
  }

  Widget buildListView() {
    return ListView(
      children: <Widget>[
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
        H(24),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            style: textStyleTextField3,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '내용을 입력해 주세요\n\n\n\n\n',
              contentPadding: EdgeInsets.fromLTRB(0, 7, 0, 7),
            ),
            keyboardType: TextInputType.multiline,
            maxLines: null,
            controller: tecContent,
          ),
        ),
        H(12),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            height: 48,
            child: FlatButton(
              color: Color(0xff272727),
              splashColor: Colors.white,
              shape: StadiumBorder(),
              child: TN1('고객센터 문의하기', 16, 0, Colors.white),
              onPressed: () {},
            ),
          ),
        ),
        H(24),
      ].where((child) => child != null).toList(),
    );
  }
}
