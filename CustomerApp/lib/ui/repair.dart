import 'dart:math';
import 'package:abg_utils/abg_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ondemandservice/model/model.dart';
import 'package:ondemandservice/ui/search.dart';
import 'package:ondemandservice/ui/service_item.dart';
import 'package:ondemandservice/widgets/buttons/button202m.dart';
import 'package:ondemandservice/widgets/horizontal_articles.dart';
import 'strings.dart';
import 'elements/address.dart';
import 'theme.dart';
import 'package:ondemandservice/widgets/buttons/button202nn.dart';
import 'package:provider/provider.dart';

class RepairScreen extends StatefulWidget {
  const RepairScreen({Key? key}) : super(key: key);

  @override
  _RepairScreenState createState() => _RepairScreenState();
}

class _RepairScreenState extends State<RepairScreen> {

  double windowWidth = 0;
  double windowHeight = 0;
  double windowSize = 0;
  final ScrollController _scrollController = ScrollController();
  ScrollController _scrollController2 = ScrollController();
  final _controllerSearch = TextEditingController();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  late MainModel _mainModel;

  @override
  void initState() {
    _mainModel = Provider.of<MainModel>(context, listen: false);
    _scrollController.addListener(_scrollListener);
    comboBoxInitAddress(_mainModel);
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      var t = routeGetPosition();
      if (t != 0)
        _scrollController2.animateTo(t, duration: Duration(milliseconds: 300), curve: Curves.bounceIn);
    });
    super.initState();
  }

  double _scroller = 20;

  _scrollListener() {
    var _scrollPosition = _scrollController.position.pixels;
    _scroller = 20 - (_scrollPosition / (windowHeight * 0.1 / 20));
    if (_scroller < 0)
      _scroller = 0;
    setState(() {});
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controllerSearch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    windowSize = min(windowWidth, windowHeight);

    return Scaffold(
        backgroundColor: (theme.darkMode) ? theme.blackColorTitleBkg : theme.colorBackground,
        body: Directionality(
          textDirection: strings.direction,
          child: Stack(
              children: [

                if (_mainModel.searchActivate)
                  SearchScreen(
                    jump: () {
                      _scrollController.jumpTo(96);
                    }, close: () {
                    _mainModel.searchActivate = false;
                    _redraw();
                  },
                  ),

                if (!_mainModel.searchActivate)
                  NestedScrollView(
                      controller: _scrollController,
                      headerSliverBuilder: (BuildContext context,
                          bool innerBoxIsScrolled) {
                        return [
                          SliverAppBar(
                              expandedHeight: windowHeight * 0.2,
                              automaticallyImplyLeading: false,
                              pinned: true,
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              flexibleSpace: ClipPath(
                                clipper: ClipPathClass23(
                                    (_scroller < 5) ? 5 : _scroller),
                                child: Container(
                                    color: (theme.darkMode) ? Colors.black : Colors.white,
                                    child: Stack(
                                      children: [
                                        FlexibleSpaceBar(
                                            collapseMode: CollapseMode.pin,
                                            //background: _title(),
                                            titlePadding: EdgeInsets.only(
                                                bottom: 10, left: 20, right: 20),
                                            title: _titleSmall()
                                        )
                                      ],
                                    )),
                              ))
                        ];
                      },
                      body: Builder(
                          builder: (BuildContext context) {
                            _scrollController2 = PrimaryScrollController.of(context)!;
                            _scrollController2.addListener(() {
                              routeSavePosition(_scrollController2.position.pixels);
                            });

                            return Container(
                              width: windowWidth,
                              height: windowHeight,
                              child: Stack(
                                children: [
                                  _body(),
                                  if (_wait)
                                    Center(child: Container(
                                        child: Loader7v1(color: theme.mainColor,))),
                                ],
                              ),
                            );
                          })),

              ]),
        ));
  }



  _titleSmall() {
    return Container(
        alignment: Alignment.bottomLeft,
        padding: EdgeInsets.only(
            bottom: _scroller, left: 20, right: 20, top: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              !_mainModel.searchActivate ? "Hello," : strings.get(122), /// "Home services", // "Search",
              style: theme.style16W800,),
            SizedBox(height: 3,),
            Text("What do you need?", // Find what you need
                style: theme.style10W600Grey),
          ],
        )
    );
  }

  _body() {
    List<Widget> list = [];

    //
    // address
    //



    for (var item in appSettings.customerAppElements) {


      //
      // category_details
      //
      if (item == "category_details") {
        for (var item in categories) {
          var t = _horizontalCategoryDetails(item);
          if (t != null) {
            list.add(Container(
                child: Container(
                  color: item.color.withAlpha(20),
                  width: windowSize,
                  height: 60,
                  child: button157(
                      getTextByLocale(item.name, strings.locale),
                      item.color,
                      item.serverPath, () {},
                      windowSize ,
                      60),
                )
            )
            );
            list.add(t);
            list.add(SizedBox(height: 10,));
          }
        }
      }

    }


    list.add(SizedBox(height: 150,));
    return Container(
        child: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: () async {
              _waits(true);
              var ret = await _mainModel.init2(_redraw);
              if (ret != null)
                messageError(context, ret);
              _waits(false);
              ret = await loadBlog(true);
              if (ret != null)
                messageError(context, ret);
              _redraw();
            },
            child: ListView(
              padding: EdgeInsets.only(top: 0),
              children: list,
            )
        ));
  }

  _listFavorites(List<Widget> list) {

    var _count = 0;
    for (var item in product) {
      if (!userAccountData.userFavorites.contains(item.id))
        continue;

      list.add(serviceItem(item, _mainModel, windowWidth));

      list.add(SizedBox(height: 10,));
      _count++;
      if (_count == 3)
        break;
    }
  }

  _addTopServices(List<Widget> list) {

    for (var item in product) {
      if (!appSettings.inMainScreenServices.contains(item.id))
        continue;

      list.add(serviceItem(item, _mainModel, windowWidth));

      // var _prov = getProviderById(item.providers[0]);
      // _prov ??= ProviderData.createEmpty();
      //
      // var _tag = UniqueKey().toString();
      // list.add(InkWell(onTap: () {
      //   _openDetails(_tag, item);
      // },
      //     child: Hero(
      //         tag: _tag,
      //         child: Container(
      //             width: windowWidth,
      //             margin: EdgeInsets.only(left: 10, right: 10),
      //             child: Stack(
      //               children: [
      //                 Card50(item: item,
      //                   locale: strings.locale,
      //                   direction: strings.direction,
      //                   category: _mainModel.categories,
      //                   providerData: _prov,
      //                 ),
      //                 if (user != null)
      //                   Container(
      //                     margin: EdgeInsets.all(6),
      //                     alignment: strings.direction == TextDirection.ltr
      //                         ? Alignment.topRight
      //                         : Alignment.topLeft,
      //                     child: IconButton(
      //                       icon: userAccountData.userFavorites.contains(item.id)
      //                           ? Icon(Icons.favorite, size: 25,)
      //                           : Icon(Icons.favorite_border, size: 25,),
      //                       color: Colors.orange,
      //                       onPressed: () {
      //                         changeFavorites(item);
      //                       },),
      //                   )
      //               ],
      //             )
      //         ))));
      list.add(SizedBox(height: 10,));
    }
  }

  _openBanner(String id, String heroId, String image) {
    for (var item in banners)
      if (item.id == id) {
        if (item.type == "provider") {
          for (var pr in providers)
            if (pr.id == item.open) {
              _mainModel.currentProvider = pr;
              route("provider");
              break;
            }
        }
        if (item.type == "category") {
          for (var cat in categories)
            if (cat.id == item.open) {
              _mainModel.categoryData = cat;
              route("category");
              break;
            }
        }
        if (item.type == "service") {
          for (var ser in product)
            if (ser.id == item.open) {
              _mainModel.currentService = ser;
              route("service");
              break;
            }
        }
      }
  }

  bool _wait = false;

  _waits(bool value) {
    _wait = value;
    _redraw();
  }

  _redraw() {
    if (mounted)
      setState(() {});
  }

  //
  // Services
  //
  Widget? _horizontalCategoryDetails(CategoryData parent) {
    User? user = FirebaseAuth.instance.currentUser;
    List<Widget> list = [];
    var index = 0;
    for (var item in product) {
      if (!item.category.contains(parent.id))
        continue;
      var _tag = UniqueKey().toString();
      list.add(Hero(
          tag: _tag,
          child: Container(
              width: windowSize * 0.7,
              child: Stack(
                children: [
                  button202N(item, _mainModel,
                    windowWidth - 20, windowSize / 2, () {
                      _mainModel.currentService = item;
                      route("service");
                    },),

                  if (user != null)
                    Container(
                      margin: EdgeInsets.all(6),
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: userAccountData.userFavorites.contains(item.id)
                            ? Icon(Icons.favorite, size: 25,)
                            : Icon(Icons.favorite_border, size: 25,),
                        color: Colors.orange,
                        onPressed: () {
                          changeFavorites(item);
                        },),
                    )
                ],
              ))
      ));
      index++;
      if (index >= 10)
        break;
    }
    if (list.isEmpty)
      return null;
    return Container(
      height: windowSize * 0.7 * 0.6,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: list,
      ),
    );
  }

  _addBlog(List<Widget> list) {
    list.add(SizedBox(height: 10,));
    var _count = 0;
    for (var item in blog) {
      list.add(Container(
        margin: EdgeInsets.only(left: 10, right: 10),
        child: button202Blog(item,
            (theme.darkMode) ? Colors.black : Colors.white,
            windowWidth, windowWidth * 0.35, () {
              _mainModel.openBlog = item;
              route("blog_details");
            }),
      )
      );
      list.add(SizedBox(height: 10,));
      _count++;
      if (_count == 3)
        break;
    }
  }

  _addProviders(List<Widget> list) {
    var _count = 0;
    for (var item in providers) {
      list.add(Container(
          color: (theme.darkMode) ? Colors.black : Colors.white,
          padding: EdgeInsets.only(bottom: 5, top: 5),
          child: button202m(item,
            windowWidth * 0.26, _mainModel, _redraw, () {
              _mainModel.currentProvider = item;
              route("provider");
            },)),
      );
      list.add(SizedBox(height: 1,));
      _count++;
      if (_count == 5)
        break;
    }
  }

}
