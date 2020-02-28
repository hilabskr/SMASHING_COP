import 'package:abara_app/_main_app.dart';

class ArticleAddCategoryPage extends StatefulWidget {
  final UserData userData;

  ArticleAddCategoryPage(this.userData);

  @override
  _ArticleAddCategoryPageState createState() => _ArticleAddCategoryPageState();
}

class _ArticleAddCategoryPageState extends State<ArticleAddCategoryPage> {
  @override
  Widget build(BuildContext context) {
    p('build ${this.runtimeType} ~~~~~~~~~~~~~~~~~~~~');

    var userMe = widget.userData.user;

    return Scaffold(
      appBar: CustomAppBar('CREATE'),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TN1('Please Choose', 30, -0.75, Colors.black87),
                TN1('the Create Board', 30, -0.75, Colors.black87),
              ],
            ),
          ),
          if (userMe.email == adminEmail)
            Padding(
              padding: const EdgeInsets.all(20),
              child: CustomFlatButton(
                '공모전',
                onPressed: () async {
                  await Future.delayed(duration1);
                  await Navigator.push(context, MaterialPageRoute(builder: (context) => ArticleAddPage('CT')));
                },
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              buildCard(1),
              W(12),
              buildCard(2),
              W(12),
              buildCard(3),
            ],
          ),
          H(61),
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
          I('create_0$index.png', 100, 120),
          Material(
            color: Colors.transparent,
            child: InkWell(
              highlightColor: Color(0x663366cc),
              splashColor: Color(0x663366cc),
              child: SizedBox(
                width: 100,
                height: 120,
              ),
              onTap: () async {
                await Future.delayed(duration1);
                p(index);

                switch (index) {
                  case 1:
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => ArticleAddPage('MK')));
                    break;
                  case 2:
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => ArticleAddPage('FR')));
                    break;
                  case 3:
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => ArticleAddPage('JB')));
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
