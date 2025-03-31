import 'dart:isolate';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int result = 0;

  Isolate? _taskIsolate;

  String name = "Jack";

  void _dataCount() async {

    setState(() {
      result = 0;
    });

    final ReceivePort receivePort = ReceivePort();

    _taskIsolate = await Isolate.spawn((sendPort) {
      int count = 0;
      for (int i = 1; i < 1000000000; i++) {
        count += i;
      }
      sendPort.send(count);
    }, receivePort.sendPort);

    receivePort.listen((message) {
      setState(() {
        result = message;
      });

      _taskIsolate?.kill(priority: Isolate.immediate);
      _taskIsolate = null;
      receivePort.close();

    });

  }

  Future<void> isolateRun()async{

   final result =  await Isolate.run((){
      int count = 0;
      for (int i = 0; i < 2000000000; i++) {
        count += i;
      }
      return count;

    });

   print("result: $result");

  }

  void _updateName() {
    setState(() {
      name = "Mike";
    });
  }

  @override
  void initState() {
    super.initState();
   // isolateRun();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
        backgroundColor: Colors.blue.shade800,
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(),
          Text("$result"),
          ElevatedButton(
            onPressed: () {
              print("Button Clicked");
              _updateName();
            },
            child: Text("Action"),
          ),

          SizedBox(height: 20),

          TextProvider(text: name, child: Center(child: const MyTextWidget())),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _dataCount(),
      ),
    );
  }
}

class TextProvider extends InheritedWidget {
  final String text;

  const TextProvider({super.key, required this.text, required super.child});

  static TextProvider of(context) {
    return context.dependOnInheritedWidgetOfExactType<TextProvider>()!;
  }

  @override
  bool updateShouldNotify(TextProvider oldWidget) {
    return text != oldWidget.text;
  }
}

class MyTextWidget extends StatefulWidget {
  const MyTextWidget({super.key});

  @override
  State<MyTextWidget> createState() => _MyTextWidgetState();
}

class _MyTextWidgetState extends State<MyTextWidget> {
  String name = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final provider = TextProvider.of(context);

    if (name != provider.text) {
      name = TextProvider.of(context).text;
    }

    print("didChangeDependencies(): Called");
  }

  @override
  Widget build(BuildContext context) {
    return Text(name);
  }
}
