import 'dart:async';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:shell/shell.dart';
import 'package:path_provider/path_provider.dart';

Timer? pTimer = null;
String homePath = "";
bool doInit = true;
Shell shell = Shell();
// ミラーリングを実施するクラス
class MirroringScreen extends StatefulWidget {
  const MirroringScreen({Key? key}) : super(key: key);

  @override
  _MirroringScreenState createState() => _MirroringScreenState();
}

class _MirroringScreenState extends State<MirroringScreen> {
  File? oldImageFile = null;
  File? imageFile = null;

  @override
  void initState() {
    super.initState();

    pTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) async {
       await _init();
       var newPngFile = await _reload(shell);
       setState(() {
         imageFile = newPngFile;
       });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ミラーリング中"),
        leading: IconButton(onPressed: () {
          print("back");
          Navigator.pop(context);
          pTimer?.cancel();
        },icon: Icon(Icons.backspace)),
        actions: <Widget>[
          IconButton(onPressed: () {
            print("スクショ");
            _getScreenShot();
          }, icon: Icon(Icons.camera))
        ],
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: imageFile == null ? Text('開始前です。') :
        Image.memory(
          imageFile!.readAsBytesSync(), //変更
          height: 600.0,
          width: 600.0,
        ),
      )
    );
  }

  // 初期設定
  Future<void> _init() async {
    if(doInit) {
      homePath = Platform.environment['HOME']!;
      Shell workspaceShell = await _createWorkspaceFolder(homePath);
      workspaceShell.navigate('./screens');
      // 現在のshellに置換
      shell = Shell.copy(workspaceShell);
      doInit = false;
      print("end");
    }
  }

  // スクショを取得する
  Future<void> _getScreenShot() async {
    print("start _getScreenShot++++++");
    print("end _getScreenShot++++++");
  }

  Future<Shell> _createWorkspaceFolder(String pwdCmdResultStr) async {
    var workspacePath = pwdCmdResultStr + '/Pictures';
    shell.navigate(workspacePath);
    var result = await shell.run('mkdir', arguments: ['mirroring_android_workspace']);
    print('${result.stdout} : ${result.exitCode} : ${result.stderr}');

    shell.navigate(workspacePath + '/mirroring_android_workspace');
    result = await shell.run('mkdir', arguments: ['screens']);
    print('${result.stdout} : ${result.exitCode} : ${result.stderr}');

    return shell;
  }

  // リロード
  Future<File> _reload(Shell shell) async {
    print('start _reload+++++++');
    var documentDirectoryPath = (await getApplicationDocumentsDirectory()).path;
    var result = await shell.run('cp', arguments: ['-f', '${homePath}/Pictures/mirroring_android_workspace/screens/screen.png', '${documentDirectoryPath}/screen.png']);
    print('${result.stdout} : ${result.exitCode} : ${result.stderr}');
    print('end _reload+++++++');
    return File('${documentDirectoryPath}/screen.png');
  }

  Future<File> _getFileFromAssets(String name) async {
    final byteData = await rootBundle.load('assets/$name');
    final file = File(
        '${(await getApplicationDocumentsDirectory()).path}/$name');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }
}

