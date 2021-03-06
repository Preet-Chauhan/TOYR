import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toyr2/Providers/Auth.dart';
import 'package:toyr2/Screens/Auth_Screen.dart';
import 'package:toyr2/Screens/create_Package.dart';
import '../Models/TOYR.dart';
import 'view_Profile.dart';
import 'favourites_Screen.dart';
import '../Widget/TOYR_widget.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'view_All_TOYRS.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  static const Routename = './HomeScreen';
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<TOYR> publicTOYR = [];
  final List<TOYR> latestTOYR = [];
  final List<TOYR> yourTOYR = [];

  final _advancedDrawerController = AdvancedDrawerController();
  final Future<FirebaseApp> _initilization = Firebase.initializeApp();
  void _handleMenuButtonPressed() {
    _advancedDrawerController.value = AdvancedDrawerValue.visible();
    _advancedDrawerController.showDrawer();
  }

  bool _isLoadedFirstTime = true;
  bool _isLoadedFirstTime2 = true;
  var listOfFavourites = List<dynamic>.empty(growable: true);
  List<TOYR> listOfFavouriteTOYRS = new List<TOYR>.empty(growable: true);
  String profileImgUrl =
      'https://monomousumi.com/wp-content/uploads/anonymous-user-3.png';
  String userName = '';

  Future<void> _goToFavourites() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    final listOfFavourites = doc.get('listOfFavourites') as List<dynamic>;
    listOfFavourites.forEach((element) async {
      final doc1 = await FirebaseFirestore.instance
          .collection('packages')
          .doc(element)
          .get();
      print(listOfFavourites);
      listOfFavouriteTOYRS.add(new TOYR(
          toyrId: element,
          name: doc1.get('packageName'),
          imgUrl: doc1.get('imgUrl'),
          createdAt: doc1.get('createdAt'),
          views: doc1.get('views')));
      print(listOfFavouriteTOYRS);
    });
  }

  final _scrollController = ScrollController();
  var _isScrolled = false;

  @override
  Widget build(BuildContext context) {
    final sf = SharedPreferences.getInstance();
    sf.then(
      (value) {
        profileImgUrl = value.getString('profileImgUrl')!;
        userName = value.getString('userName')!;
      },
    );

    return FutureBuilder<FirebaseApp>(
      future: _initilization,
      builder: (ctx, snapshot) {
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return AdvancedDrawer(
            backdropColor: Colors.grey.shade900,
            controller: _advancedDrawerController,
            animationCurve: Curves.easeInOut,
            animationDuration: const Duration(milliseconds: 300),
            animateChildDecoration: true,
            rtlOpening: false,
            disabledGestures: false,
            childDecoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade900,
                  blurRadius: 20.0,
                  spreadRadius: 5.0,
                  offset: Offset(-20.0, 0.0),
                ),
              ],
              borderRadius: BorderRadius.circular(30),
            ),
            drawer: SafeArea(
              child: Container(
                child: ListTileTheme(
                  textColor: Colors.white,
                  iconColor: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: 128.0,
                        height: 128.0,
                        margin: const EdgeInsets.only(
                          top: 24.0,
                          bottom: 30.0,
                        ),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          shape: BoxShape.circle,
                        ),
                        child: Image.network(profileImgUrl, fit: BoxFit.cover),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 15),
                        child: Text(userName,
                            style: GoogleFonts.comfortaa(
                                fontSize: 36,
                                fontWeight: FontWeight.w500,
                                color: Colors.white)),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Divider(
                        indent: 20,
                        color: Colors.grey,
                      ),
                      ListTile(
                        onTap: () {
                          Navigator.of(context).pushNamed('/');
                        },
                        leading: Icon(Icons.home),
                        title: Text('Home'),
                      ),
                      ListTile(
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(createPackageScreen.Routename);
                        },
                        leading: Icon(Icons.add),
                        title: Text('Create Package'),
                      ),
                      ListTile(
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(viewProfile.Routename);
                        },
                        leading: Icon(Icons.account_circle_rounded),
                        title: Text('Profile'),
                      ),
                      ListTile(
                        onTap: () async {
                          Navigator.of(context).pushNamed(
                            favouritesScreen.Routename,
                          );
                        },
                        leading: Icon(Icons.favorite),
                        title: Text('Favourites'),
                      ),
                      ListTile(
                        onTap: () {
                          FirebaseAuth.instance.signOut();
                          var sf = SharedPreferences.getInstance();
                          sf.then((value) {
                            value.clear();
                            value.commit();
                          });

                          Navigator.of(context).pushNamed('/');
                        },
                        leading: Icon(Icons.logout_rounded),
                        title: Text('LogOut'),
                      ),
                      Spacer(),
                      // DefaultTextStyle(
                      //   style: TextStyle(
                      //     fontSize: 12,
                      //     color: Colors.white54,
                      //   ),
                      //   child: Container(
                      //     margin: const EdgeInsets.symmetric(
                      //       vertical: 16.0,
                      //     ),
                      //     child: Text('Terms of Service | Privacy Policy'),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
            child: FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection("packages")
                    .orderBy('createdAt', descending: true)
                    .get(),
                builder: (ctx, snapshot) {
                  if (snapshot.hasError) {
                    return Scaffold(
                      body: Center(
                        child: Text("Error 404"),
                      ),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Scaffold(
                      body: Center(
                        child: Row(
                          children: [
                            Spacer(),
                            Text(
                              "Loading",
                              style: TextStyle(fontSize: 20),
                            ),
                            AnimatedTextKit(animatedTexts: [
                              TyperAnimatedText('...',
                                  textStyle: TextStyle(fontSize: 20),
                                  speed: Duration(milliseconds: 300))
                            ]),
                            Spacer(),
                          ],
                        ),
                      ),
                    );
                  }
                  if (snapshot.data == null) {
                    return Scaffold(
                      body: Center(
                        child: Text("Just a Sec..."),
                      ),
                    );
                  }
                  if (_isLoadedFirstTime) {
                    final document = snapshot.data!.docs;
                    publicTOYR.clear();
                    yourTOYR.clear();
                    latestTOYR.clear();
                    document.forEach((element) {
                      if (element.get('isPublic')) {
                        latestTOYR.add(TOYR(
                            toyrId: element.id,
                            name: element.get('packageName'),
                            imgUrl: element.get('imgUrl'),
                            createdAt: element.get('createdAt'),
                            views: element.get('views')));
                        publicTOYR.add(TOYR(
                            toyrId: element.id,
                            name: element.get('packageName'),
                            imgUrl: element.get('imgUrl'),
                            createdAt: element.get('createdAt'),
                            views: element.get('views')));
                      }
                    });
                    publicTOYR.sort((t1, t2) => t2.views.compareTo(t1.views));
                    document.forEach((element) {
                      if (element.get('createdBy') ==
                          FirebaseAuth.instance.currentUser!.email) {
                        yourTOYR.add(TOYR(
                            toyrId: element.id,
                            name: element.get('packageName'),
                            imgUrl: element.get('imgUrl'),
                            createdAt: element.get('createdAt'),
                            views: element.get('views')));
                      }
                    });
                    _isLoadedFirstTime = false;
                  }
                  final GlobalKey<LiquidPullToRefreshState>
                      _refreshIndicatorKey =
                      GlobalKey<LiquidPullToRefreshState>();
                  final GlobalKey<ScaffoldState> _scaffoldKey =
                      GlobalKey<ScaffoldState>();
                  int refreshNum = 50;
                  Future<void> _handleRefresh() {
                    final Completer<void> completer = Completer<void>();
                    Timer(const Duration(seconds: 6), () {
                      completer.complete();
                    });
                    setState(() {
                      refreshNum = Random().nextInt(100);
                    });
                    return completer.future.then<void>((_) {
                      ScaffoldMessenger.of(_scaffoldKey.currentState!.context)
                          .showSnackBar(
                        SnackBar(
                          content: const Text('Refresh complete'),
                          action: SnackBarAction(
                            label: 'RETRY',
                            onPressed: () {
                              _refreshIndicatorKey.currentState!.show();
                            },
                          ),
                        ),
                      );
                    });
                  }

                  return Scaffold(
                      key: _scaffoldKey,
                      body: LiquidPullToRefresh(
                        // borderWidth: 5.0,
                        // color: Colors.deepPurple,
                        onRefresh: _handleRefresh,
                        height: 150,
                        showChildOpacityTransition: false,
                        key: _refreshIndicatorKey,
                        child: Container(
                          child: ListView(
                            controller: _scrollController,
                            physics: BouncingScrollPhysics(),
                            children: [
                              const SizedBox(
                                height: 40,
                              ),
                              Row(
                                children: [
                                  Container(
                                      margin:
                                          EdgeInsets.only(left: 15, right: 5),
                                      decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.shade400,
                                              blurRadius: 7.0,
                                              spreadRadius: 1.0,
                                              offset: Offset(1.0, 1.0),
                                            ),
                                          ],
                                          color: Colors.grey[200],
                                          // color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      child: IconButton(
                                        onPressed: _handleMenuButtonPressed,
                                        icon: ValueListenableBuilder<
                                            AdvancedDrawerValue>(
                                          valueListenable:
                                              _advancedDrawerController,
                                          builder: (_, value, __) {
                                            return AnimatedSwitcher(
                                              duration:
                                                  Duration(milliseconds: 250),
                                              child: Icon(
                                                value.visible
                                                    ? Icons.clear
                                                    : Icons.menu,
                                                key: ValueKey<bool>(
                                                    value.visible),
                                              ),
                                            );
                                          },
                                        ),
                                      )),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Text(
                                      "TOYR",
                                      style: GoogleFonts.comfortaa(
                                          fontSize: 36,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 5),
                                  ),
                                ],
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "YOUR TOYRS",
                                      style: GoogleFonts.roboto(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pushNamed(
                                              viewAllTOYRSScreen.Routename,
                                              arguments: {
                                                'listOfTOYR': yourTOYR,
                                                'title': 'YOUR TOYRS',
                                              });
                                        },
                                        child: Text(
                                          'View All',
                                          style: TextStyle(
                                              color: Colors.deepPurple),
                                        ))
                                  ],
                                ),
                                margin: const EdgeInsets.only(
                                    top: 20, left: 5, bottom: 10),
                              ),
                              if (yourTOYR.isEmpty)
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 30),
                                  child: Center(
                                      child: Text(
                                          "You haven't Created Any TOYRS Yet!!")),
                                ),
                              if (yourTOYR.isNotEmpty)
                                Container(
                                  height: MediaQuery.of(context).size.height *
                                              0.565 <
                                          395
                                      ? MediaQuery.of(context).size.height * 0.5
                                      : 390,
                                  width: MediaQuery.of(context).size.width,
                                  child: ListView.builder(
                                    itemBuilder: (ctx, i) => Container(
                                        width: 330,
                                        child: ToyrWidget(
                                          name: yourTOYR[i].name,
                                          imgUrl: yourTOYR[i].imgUrl,
                                          date: yourTOYR[i].createdAt,
                                          id: yourTOYR[i].toyrId,
                                        )),
                                    itemCount: yourTOYR.length,
                                    scrollDirection: Axis.horizontal,
                                    physics: BouncingScrollPhysics(),
                                  ),
                                ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "TRENDING TOYRS",
                                      style: GoogleFonts.roboto(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pushNamed(
                                              viewAllTOYRSScreen.Routename,
                                              arguments: {
                                                'listOfTOYR': publicTOYR,
                                                'title': 'PUBLIC TOYRS',
                                              });
                                        },
                                        child: Text(
                                          'View All',
                                          style: TextStyle(
                                              color: Colors.deepPurple),
                                        ))
                                  ],
                                ),
                                margin: EdgeInsets.only(
                                    top: 15, left: 5, bottom: 10),
                              ),
                              Container(
                                height: MediaQuery.of(context).size.height *
                                            0.565 <
                                        395
                                    ? MediaQuery.of(context).size.height * 0.5
                                    : 390,
                                width: MediaQuery.of(context).size.width,
                                child: ListView.builder(
                                  itemBuilder: (ctx, i) => Container(
                                    width: 330,
                                    child: ToyrWidget(
                                      name: publicTOYR[i].name,
                                      imgUrl: publicTOYR[i].imgUrl,
                                      date: publicTOYR[i].createdAt,
                                      id: publicTOYR[i].toyrId,
                                    ),
                                  ),
                                  itemCount: publicTOYR.length,
                                  scrollDirection: Axis.horizontal,
                                  physics: BouncingScrollPhysics(),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "LATEST TOYRS",
                                      style: GoogleFonts.roboto(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pushNamed(
                                              viewAllTOYRSScreen.Routename,
                                              arguments: {
                                                'listOfTOYR': latestTOYR,
                                                'title': 'LATEST TOYRS',
                                              });
                                        },
                                        child: Text(
                                          'View All',
                                          style: TextStyle(
                                              color: Colors.deepPurple),
                                        ))
                                  ],
                                ),
                                margin: EdgeInsets.only(
                                    top: 15, left: 5, bottom: 10),
                              ),
                              Container(
                                height: MediaQuery.of(context).size.height *
                                            0.565 <
                                        395
                                    ? MediaQuery.of(context).size.height * 0.5
                                    : 390,
                                width: MediaQuery.of(context).size.width,
                                child: ListView.builder(
                                  itemBuilder: (ctx, i) => Container(
                                    width: 330,
                                    child: ToyrWidget(
                                      name: latestTOYR[i].name,
                                      imgUrl: latestTOYR[i].imgUrl,
                                      date: latestTOYR[i].createdAt,
                                      id: latestTOYR[i].toyrId,
                                    ),
                                  ),
                                  itemCount: latestTOYR.length,
                                  scrollDirection: Axis.horizontal,
                                  physics: BouncingScrollPhysics(),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              )
                            ],
                          ),
                        ),
                      ),
                      floatingActionButton: FloatingActionButton.extended(
                        extendedPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        isExtended: true,
                        elevation: 15,
                        focusElevation: 30,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        label: Text(
                          'Create package',
                        ),
                        icon: Icon(Icons.add),
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed(createPackageScreen.Routename);
                        },
                      ));
                }),
          );
        }
        return Scaffold(
          body: Center(
            child: Text("Initializing..."),
          ),
        );
      },
    );
  }
}
