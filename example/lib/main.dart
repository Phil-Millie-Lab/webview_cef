import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_cef/webview_cef.dart';
import 'package:webview_cef/src/webview_inject_user_script.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late WebViewController _controller;
  final _textController = TextEditingController();
  String title = "";
  Map allCookies = {};

  @override
  void initState() {
    var injectUserScripts = InjectUserScripts();
    injectUserScripts.add(UserScript("console.log('injectScript_in_LoadStart')",
        ScriptInjectTime.LOAD_START));
    injectUserScripts.add(UserScript(
        "console.log('injectScript_in_LoadEnd')", ScriptInjectTime.LOAD_END));

    // CSS Injection Script Example
    // injectUserScripts.add(UserScript(
    //   '''
    //     const style = document.createElement('style');
    //     style.innerHTML = `
    //       body {
    //         background-color: yellow;
    //       }
    //     `;
    //
    //     document.head.appendChild(style);
    //   ''',
    //   ScriptInjectTime.LOAD_END,
    // ));

    _controller = WebviewManager().createWebView(
        loading: const Text("not initialized"),
        injectUserScripts: injectUserScripts);
    // _controller2 =
    //     WebviewManager().createWebView(loading: const Text("not initialized"));
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    _controller.dispose();
    WebviewManager().quit();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    await WebviewManager().initialize(userAgent: "test/userAgent");
    String url = "www.millie.co.kr";
    _textController.text = url;
    //unified interface for all platforms set user agent
    _controller.setWebviewListener(WebviewEventsListener(
      onTitleChanged: (t) {
        setState(() {
          title = t;
        });
      },
      onUrlChanged: (url) {
        _textController.text = url;
        final Set<JavascriptChannel> jsChannels = {
          JavascriptChannel(
              name: '_POST',
              onMessageReceived: (JavascriptMessage message) {
                _controller.sendJavaScriptChannelCallBack(
                    false,
                    "{'code':'200','message':'print succeed!'}",
                    message.callbackId,
                    message.frameId);
              }),

        };
        //also you can build your own jssdk by execute JavaScript code to CEF
        _controller.setJavaScriptChannels(jsChannels);
        _controller.executeJavaScript("function abc(e){return 'abc:'+ e}");

      },
      onLoadStart: (controller, url) {
      },
      onLoadEnd: (controller, url) {
      },
    ));

    await _controller.initialize(_textController.text);

    // _controller2.setWebviewListener(WebviewEventsListener(
    //   onTitleChanged: (t) {},
    //   onUrlChanged: (url) {
    //     final Set<JavascriptChannel> jsChannels = {
    //       JavascriptChannel(
    //           name: 'Print',
    //           onMessageReceived: (JavascriptMessage message) {
    //             print(message.message);
    //             _controller.sendJavaScriptChannelCallBack(
    //                 false,
    //                 "{'code':'200','message':'print succeed!'}",
    //                 message.callbackId,
    //                 message.frameId);
    //           }),
    //     };
    //     //normal JavaScriptChannels
    //     _controller2.setJavaScriptChannels(jsChannels);
    //   },
    // ));
    // await _controller2.initialize("millie.co.kr");

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
          body: Row(
        children: [
          // SizedBox(
          //   height: 20,
          //   child: Text(title),
          // ),
          Column(
            children: [
              // SizedBox(
              //   height: 48,
              //   child: MaterialButton(
              //     onPressed: () {
              //       _controller.reload();
              //     },
              //     child: const Icon(Icons.refresh),
              //   ),
              // ),
              // SizedBox(
              //   height: 48,
              //   child: MaterialButton(
              //     onPressed: () {
              //       _controller.goBack();
              //     },
              //     child: const Icon(Icons.arrow_left),
              //   ),
              // ),
              // SizedBox(
              //   height: 48,
              //   child: MaterialButton(
              //     onPressed: () {
              //       _controller.goForward();
              //     },
              //     child: const Icon(Icons.arrow_right),
              //   ),
              // ),
              SizedBox(
                height: 48,
                child: MaterialButton(
                  onPressed: () {
                    _controller.openDevTools();
                  },
                  child: Text("openDevTools"),
                ),
              ),
              SizedBox(
                height: 48,
                child: MaterialButton(
                  onPressed: () {
                    _controller.openDevToolsSub();
                  },
                  child: Text("openDevToolsSub"),
                ),
              ),
              SizedBox(
                height: 48,
                child: MaterialButton(
                  onPressed: () async {
                    await _controller.openWebView(url: "www.naver.com",);
                    final Set<JavascriptChannel> jsChannels2 = {
                      JavascriptChannel(
                          name: '_POST2',
                          onMessageReceived: (JavascriptMessage message) {
                            _controller.sendJavaScriptChannelCallBackSub(
                                false,
                                "{'code':'200','message':'print succeed!!!'}",
                                message.callbackId,
                                message.frameId);
                          }),
                    };
                    _controller.setJavaScriptChannelsSub(jsChannels2);
                  },
                  child: Text("openWebView"),
                ),
              ),
              SizedBox(
                height: 48,
                child: MaterialButton(
                  onPressed: () {
                    final Set<JavascriptChannel> jsChannels2 = {
                      JavascriptChannel(
                          name: '_POST2',
                          onMessageReceived: (JavascriptMessage message) {
                            _controller.sendJavaScriptChannelCallBackSub(
                                false,
                                "{'code':'200','message':'print succeed!!!'}",
                                message.callbackId,
                                message.frameId);
                          }),
                    };
                    _controller.setJavaScriptChannelsSub(jsChannels2);
                    },
                  child: Text("setJavaScriptChannelsSub"),
                ),
              ),
              SizedBox(
                height: 48,
                child: MaterialButton(
                  onPressed: () {
                    _controller.executeJavaScriptSub('''
      if (window._POST2) {
        window._POST2('{"test": "testing _POST2 channel"}');
      } else {
        console.error('_POST2 channel not found');
      }
    ''');
                    },
                  child: Text("executeJavaScriptSub"),
                ),
              ),
              SizedBox(
                height: 48,
                child: MaterialButton(
                  onPressed: () {
                    _controller.loadUrl("www.google.com");
                  },
                  child: Text("loadUrl"),
                ),
              ),
              SizedBox(
                height: 48,
                child: MaterialButton(
                  onPressed: () {
                    _controller.loadUrlSub("www.daum.net");
                  },
                  child: Text("loadUrlSub"),
                ),
              ),
              SizedBox(
                height: 48,
                child: MaterialButton(
                  onPressed: () async {
                    bool resp = await _controller.closeWebView();
                  },
                  child: Text("closeWebView"),
                ),
              ),
              // Expanded(
              //   child: TextField(
              //     controller: _textController,
              //     onSubmitted: (url) {
              //       _controller.loadUrl(url);
              //       WebviewManager().visitAllCookies().then((value) {
              //         allCookies = Map.of(value);
              //         if (url == "millie.co.kr") {
              //           if (!allCookies.containsKey('.$url') ||
              //               !Map.of(allCookies['.$url']).containsKey('test')) {
              //             WebviewManager().setCookie(url, 'test', 'test123');
              //           } else {
              //             WebviewManager().deleteCookie(url, 'test');
              //           }
              //         }
              //       });
              //     },
              //   ),
              // ),
            ],
          ),
          Expanded(
              child: Row(
            children: [
              ValueListenableBuilder(
                valueListenable: _controller,
                builder: (context, value, child) {
                  return _controller.value
                      ? Expanded(child: _controller.webviewWidget)
                      : _controller.loadingWidget;
                },
              ),
              // ValueListenableBuilder(
              //   valueListenable: _controller2,
              //   builder: (context, value, child) {
              //     return _controller2.value
              //         ? Expanded(child: _controller2.webviewWidget)
              //         : _controller2.loadingWidget;
              //   },
              // )
            ],
          ))
        ],
      )),
    );
  }
}
