import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'chatPage.dart';
import 'main.dart';

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
    // ユーザー情報を受け取る
    final UserState userState = Provider.of<UserState>(context);

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
                        // ユーザー情報を更新
                        userState.setUser(result.user!);
                        // ユーザー登録に成功した場合
                        // チャット画面に遷移＋ログイン画面を破棄
                        await Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) {
                            return ChatPage();
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
                      //ユーザー情報を更新
                      userState.setUser(result.user!);
                      // ログイン画面に成功した場合の処理
                      await Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context){
                          return ChatPage();
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