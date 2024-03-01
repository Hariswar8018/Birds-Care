import 'dart:async';

import 'package:flutter/material.dart' ;
import 'package:flutter/foundation.dart' ;
import 'package:flutter/gestures.dart' ;
import 'package:flutter/material.dart' ;
import 'package:flutter/material.dart' ;
import 'package:webview_flutter/webview_flutter.dart' ;
import 'dart:io' show Platform ;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;
import 'package:flutter_no_internet_widget/flutter_no_internet_widget.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:birds/adhelp.dart';

// TODO: Import google_mobile_ads.dart
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Birds Pets Care',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:   FutureBuilder(
        future: Future.delayed(Duration(seconds: 3)),
        builder: (ctx, timer) =>
        timer.connectionState == ConnectionState.done
            ? InternetWidget(
          // ignore: avoid_print
            whenOffline: () => print('No Internet'), offline: FullScreenWidget(
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title:  Center(child: Text('Errr : No Internet')),
            ),
            body:  Center(child: Image.asset("assets/2.jpg", height: MediaQuery.of(context).size.height
                , fit : BoxFit.cover, width:MediaQuery.of(context).size.width )),
          ),
        ),
            // ignore: avoid_print
            whenOnline: () => MyHomePage(),
            loadingWidget: const Center(child: Text('Loading')),
            online : MyHomePage()) //Screen to navigate to once the splashScreen is done.
            : Container(
          color: Colors.black,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Image(
            image: AssetImage('assets/1.jpg'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {

  Future<InitializationStatus> _initGoogleMobileAds() {
    // TODO: Initialize Google Mobile Ads SDK
    return MobileAds.instance.initialize();
  }
  InterstitialAd? _interstitialAd;

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {

            },
          );

          setState(() {
            _interstitialAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          print('Failed to load an interstitial ad: ${err.message}');
        },
      ),
    );
  }

  void startTimer() {
    // Create a periodic timer that runs the specified function every 30 seconds
    Timer.periodic(Duration(seconds: 120), (Timer timer) {
      // Call your function here
      print("Executing function every 30 seconds...");
      _loadInterstitialAd();
      _interstitialAd?.show();
      // Uncomment the next line to cancel the timer after a certain condition
      // if (someCondition) timer.cancel();
    });
  }

  late final WebViewController controller;
  double progress = 0.0;
  void initState(){
    _initGoogleMobileAds();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progres) {
            setState(() {
              progress = progres / 100;
            });
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://cycledekhoj.in/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )..loadRequest(Uri.parse('https://birdpetscare.blogspot.com/'));
    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    ).load();
    setState(() {

    });
    startTimer();
  }
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime? _lastPressedAt;
  BannerAd? _bannerAd;
  int c = 0 ;
  @override
  Widget build(BuildContext context) {
    int backButtonPressCount = 0;
    return  WillPopScope(
      onWillPop: () async {
        if (_lastPressedAt == null || DateTime.now().difference(_lastPressedAt!) > Duration(seconds: 2)) {

          // If it's the first press or more than 2 seconds since the last press
          if (await controller.canGoBack()) {
            controller.goBack();
          } else {
            _lastPressedAt = DateTime.now();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Press back again to exit'),
                duration: Duration(seconds: 2),
              ),
            );
          }
          return false; // Do not exit the app
        } else {
          return true; // Allow exit the app
        }
      },
      child: Container(
        width : MediaQuery.of(context).size.width,
        height : MediaQuery.of(context).size.height,
        child: Scaffold(
          resizeToAvoidBottomInset: true , persistentFooterButtons: [
            Container(
              width : MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  if (_bannerAd != null)
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: _bannerAd!.size.width.toDouble(),
                        height: _bannerAd!.size.height.toDouble(),
                        child: AdWidget(ad: _bannerAd!),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children : [
                      IconButton(onPressed: () async {
                        setState((){
                          c = 0 ;
                        });
                        controller.loadRequest( Uri.parse('https://birdpetscare.blogspot.com/'));

                      }, icon:  Icon(Icons.home, size : 25, color : c == 0 ? Colors.orange : Colors.black ),),
                      IconButton(onPressed: (){
                        setState((){
                          c = 1 ;
                        });
                        _refreshWebView() ;
                      }, icon:  Icon(Icons.refresh, size : 25, color : c == 1 ? Colors.orange : Colors.black),),
                      IconButton(onPressed: () async {
                        setState((){
                          c = 2 ;
                        });
                        final Uri _url = Uri.parse('https://whatsapp.com/channel/0029VaKUAqHKwqSR7WwivP20');
                        if (!await launchUrl(_url)) {
                        throw Exception('Could not launch $_url');
                        }
                      }, icon:  Icon(Icons.chat, size : 25, color : c == 2 ? Colors.orange : Colors.black),),
                    ]
                  ),
                ],
              ),
            )
        ],
          key: _scaffoldKey ,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(10.0) , // Set the desired height
            child: AppBar(
              backgroundColor: Colors.black ,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(4.0) , // Set the desired height
                child: LinearProgressIndicator(
                  value: progress ,
                  backgroundColor: Colors.white ,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              ),
            ),
          ),
          body: WebViewWidget(controller: controller,
          ),
        ),
      ),
    );
  }

  Future<void> _refreshWebView() async {
    await controller.reload();
  }


  @override
  void dispose() {
    // TODO: Dispose a BannerAd object
    _bannerAd?.dispose();

    super.dispose();
  }
}