import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 投稿画面用Widget
class AddPostPage extends StatefulWidget {
  // 引数からユーザー情報を受け取る
  AddPostPage();

  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  // 入力した投稿メッセージ
  String messageText = '';


  @override
  Widget build(BuildContext context) {
    final  UserState userState = Provider.of<UserState>(context);
    final User user = userState.user!;

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
                      final email = user.email; // AddPostPage のデータを参照
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