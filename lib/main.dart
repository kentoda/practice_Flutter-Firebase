import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async{
  // 初期化処理を追加
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // 最初に表示するWidget
  runApp(ChatApp());
}

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // アプリ名
      title: 'ChatApp',
      theme: ThemeData(
        // テーマカラー
        primarySwatch: Colors.blue,
      ),
      // ログイン画面を表示
      home: LoginPage(),
    );
  }
}

// ログイン画面用Widget
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // メッセージ表示用
  String infoText = '';
  // 入力したメールアドレス・パスワード
  String name = '';
  String email = '';
  String password = '';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              //名前入力
              // TextFormField(
              //   decoration: InputDecoration(labelText: '名前'),
              //   obscureText: true,
              //   onChanged: (String value) {
              //     setState(() {
              //       name = value;
              //     });
              //   },
              // ),
              // メールアドレス入力
              TextFormField(
                decoration: InputDecoration(labelText: 'メールアドレス'),
                onChanged: (String value) {
                  setState(() {
                    email = value;
                  });
                },
              ),
              // パスワード入力
              TextFormField(
                decoration: InputDecoration(labelText: 'パスワード'),
                obscureText: true,
                onChanged: (String value) {
                  setState(() {
                    password = value;
                  });
                },
              ),
              Container(
                padding: EdgeInsets.all(8),
                // メッセージ表示
                child: Text(infoText),
              ),
              Container(
                  width: double.infinity,
                  // ユーザー登録ボタン
              child: ElevatedButton(
                child: Text('ユーザー登録'),
                onPressed: () async {
                  try {
                    // メール/パスワードでユーザー登録
                    final FirebaseAuth auth = FirebaseAuth.instance;
                    final result = await auth.createUserWithEmailAndPassword(
                      email: email,
                      password: password,
                    );
                    // ユーザー登録に成功した場合
                    // チャット画面に遷移＋ログイン画面を破棄
                    await Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) {
                        return ChatPage(result.user!);
                      }),
                    );
                  } catch (e) {
                    // ユーザー登録に失敗した場合
                    setState(() {
                      infoText = "登録に失敗しました：${e.toString()}";
                    });
                  }
                },
              )
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
              //  ログイン登録ボタン
                child: OutlinedButton(
                  child: Text("ログイン"),
                  onPressed: () async {
                    try {
                    //  メールアドレス、パスワードでログイン
                      final FirebaseAuth auth = FirebaseAuth.instance;
                      final result = await auth.signInWithEmailAndPassword(
                        email: email,
                        password: password,
                      );
                      // ログイン画面に成功した場合の処理
                      await Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context){
                            return ChatPage(result.user!);
                          }),
                      );
                    } catch (e) {
                    //  ログインに失敗した場合の処理
                      setState(() {
                        infoText = "ログインに失敗しました:${e.toString()}";
                      });
                    }

                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// チャット画面用Widget
class ChatPage extends StatelessWidget {
  //ChatPage の引数から値を受け取る
  ChatPage(this.user);
  //ユーザー情報
  final User user;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('チャット'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              //ログアウト処理
              await FirebaseAuth.instance.signOut();
              // ログイン画面に遷移＋チャット画面を破棄
              await Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) {
                  return LoginPage();
                }),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            // ユーザー情報を表示
            child: Text('ログイン情報：${user.email}'),
          ),
          Expanded(
            // FutureBuilder
            // 非同期処理の結果を元にWidgetを作れる
              child: FutureBuilder<QuerySnapshot> (
                // 投稿メッセージ一覧を取得（非同期処理）
                // 投稿日時でソート
                future: FirebaseFirestore.instance
                .collection('posts')
                    .orderBy('date')
                    .get(),
                builder: (context, snapshot) {
                  //データが取得できた場合の処理
                  if (snapshot.hasData) {
                    final List <DocumentSnapshot> documents = snapshot.data!.docs;
                    // 取得した投稿メッセージ一覧を元にリスト表示
                    return ListView(
                      children: documents.map((document) {
                        return Card(
                            child: ListTile(
                              title: Text(document['text']),
                              subtitle: Text(document['email']),
                            //  自分の投稿には削除ボタンを表示
                              trailing: document['email'] == user.email
                                ? IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () async {
                                    // 投稿メッセージのドキュメントを削除
                                  await FirebaseFirestore.instance
                            .collection('posts')
                            .doc(document.id)
                            .delete();
                        },

                            )
                        :null,
                            )
                        );
                      }).toList(),
                    );
                  }
                  return Center(
                    child: Text('読み込み中...'),
                  );
                },

              ),
          ),
        ],

      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          // 投稿画面に遷移
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return AddPostPage(user);
            }),
          );
        },
      ),
    );
  }
}

// 投稿画面用Widget
class AddPostPage extends StatefulWidget {
  // 引数からユーザー情報を受け取る
  AddPostPage(this.user);
  // ユーザー情報
  final User user;

  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  // 入力した投稿メッセージ
  String messageText = '';


@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('チャット投稿'),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
        //  投稿メッセージを入力
          TextField(
            decoration: InputDecoration(labelText: '投稿メッセージ'),
          //  複数行のテキスを入力
            keyboardType: TextInputType.multiline,
          //  最大3行
            maxLines: 3,
            onChanged: (String value){
              setState(() {
                messageText = value;
              });
            },
          ),
            const SizedBox(height: 8),
          Container(
            width: double.infinity,
            child: ElevatedButton(
            child: Text("投稿"),
            onPressed: () async {
              final date =
                  DateTime.now().toLocal().toIso8601String(); // 現在の日時
              final email = widget.user.email; // AddPostPage のデータを参照
              // 投稿メッセージ用ドキュメント作成
              await FirebaseFirestore.instance
                  .collection('posts') // コレクションID指定
                  .doc() // ドキュメントID自動生成
                  .set({
                'text': messageText,
                'email': email,
                'date': date
              });
              // 1つ前の画面に戻る
              Navigator.of(context).pop();
            },
          ),
          ),

        ],
      ),
      )

      ),
    );
  }
}