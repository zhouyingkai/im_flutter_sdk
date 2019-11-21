import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk_example/utils/theme_util.dart';

import 'package:im_flutter_sdk_example/utils/style.dart';
import 'package:im_flutter_sdk_example/utils/theme_util.dart';
import 'package:im_flutter_sdk_example/utils/localizations.dart';
import 'package:im_flutter_sdk_example/common/common.dart';
import 'package:im_flutter_sdk_example/pages/chat_page.dart';
import 'chatroom_list_page.dart';
import 'package:im_flutter_sdk_example/utils/widget_util.dart';

class EMContactsListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _EMContactsListPageState();
  }
}

class _EMContactsListPageState extends State<EMContactsListPage> implements EMContactEventListener {

  String _imageName;
  String _name;


//  List contactsList = ['小明','小红','小刚','小王','小丽','小丽','小丽','小丽','小丽','小丽'];
  var contactsList = new List();

  var mapTest = [
    {'imageName':'images/新的好友@2x.png','name':'新的好友'},
    {'imageName':'images/群聊@2x.png','name':'群聊'},
    {'imageName':'images/标签@2x.png','name':'标签'},
    {'imageName':'images/聊天室@2x.png','name':'聊天室'},
    {'imageName':'images/公众号@2x.png','name':'公众号'}
  ];

  Offset tapPos;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    EMClient.getInstance().contactManager().addContactListener(this);
    loadEMContactsList();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    EMClient.getInstance().contactManager().removeContactListener(this);
  }

  String _getData(int index) {
    return this.contactsList[index];
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    // 允许子控件滑动
    return Scaffold(
      appBar: AppBar(
        centerTitle : true,
        title: Text(DemoLocalizations.of(context).addressBook, style: TextStyle(fontSize: EMFont.emAppBarTitleFont, color: ThemeUtils.isDark(context) ? EMColor.darkText : EMColor.text)),
        leading: Icon(null),
        elevation: 0, // 隐藏阴影
        backgroundColor: ThemeUtils.isDark(context) ? EMColor.darkAppMain : EMColor.appMain,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.add,), onPressed: (){
            Navigator.of(context).pushNamed(Constant.toAddContact);
          }),
          SizedBox(width: 12.0),
        ],
      ),
      key: UniqueKey(),
      body: ListView.builder(
//        shrinkWrap: true,
//        physics:NeverScrollableScrollPhysics(),
        itemCount: this.contactsList.length + 7,
        itemBuilder: (BuildContext context,int index){
          return _rowStyle(index);
        },
      ),
    );
  }

  Widget _rowStyle(int index) {
    if(index == 0) {
      return InkWell(
        onTap: (){
          print('search');
        },
        child : Stack(children: <Widget>[
          Container(height: EMLayout.emSearchBarHeight, color: ThemeUtils.isDark(context) ? EMColor.darkBgColor : EMColor.bgColor,),
          Container(
            padding: EdgeInsets.only(left: 8.0),
            margin: EdgeInsets.only(right: 8.0, left: 8.0),
            height: EMLayout.emSearchBarHeight,
            decoration:  BoxDecoration(
              color: ThemeUtils.isDark(context)? EMColor.darkBgSearchBar : EMColor.bgSearchBar,
              borderRadius: BorderRadius.all(Radius.circular(EMLayout.emSearchBarHeight/2)),
              border: Border.all(width: 1, color: ThemeUtils.isDark(context) ? EMColor.darkBgSearchBar : EMColor.bgSearchBar),
            ),
            child:Row(
              children: <Widget>[
                Icon(Icons.search),
                Text(DemoLocalizations.of(context).search, style: TextStyle(color: ThemeUtils.isDark(context)? EMColor.darkText : EMColor.text),),
              ],
            ),
          ),
        ],
        ),
      );
    } else if(index > 0 && index < 6) {
      this._imageName = mapTest[index - 1]['imageName'];
      this._name = mapTest[index - 1]['name'];

    } else if(index == 6) {
      return Container(
        height: 5.0,
      );
    } else {
      this._imageName = 'images/default_avatar.png';
      this._name = _getData(index - 7);
    }

    return InkWell(
      onTap: (){
        if(index > 0 && index < 7){
          if(index == 1){
//            Navigator.of(context).pushNamed(Constant.toAddContact);
          } else if (index == 2) {
            WidgetUtil.hintBoxWithDefault('正在开发中...');
          } else if (index == 3) {
            WidgetUtil.hintBoxWithDefault('正在开发中...');
          } else if (index == 4) {
            Navigator.of(context).pushNamed(Constant.toChatRoomListPage);
          } else {
            WidgetUtil.hintBoxWithDefault('正在开发中...');
          }
        } else {
          Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context){
            return new ChatPage(arguments: {'mType': Constant.chatTypeSingle,'toChatUsername':_getData(index - 7)});
          }));
        }
      },

      onTapDown: (TapDownDetails details) {
        tapPos = details.globalPosition;
      },

      onLongPress: (){
        if(index >= 7){
          Map<String,String> actionMap = {
            Constant.deleteContactKey:DemoLocalizations.of(context).deleteContact,
          };
          WidgetUtil.showLongPressMenu(context, tapPos,actionMap,(String key){
            if(key == "DeleteContactKey") {
              _deleteContact(index);
            }
          });
        }
      },
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 16.0),
            height: 67,
            child: Row(
              children: <Widget>[
                ClipOval(
                  child: Image.asset(this._imageName, width: 40.0,height: 40.0,),
                ),
                Padding(padding: EdgeInsets.all(8.0)),
                Text(this._name, style: TextStyle(fontSize: 18.0),)
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width - 64.0,
            height: 1.0,
            color: Color(0xffe5e5e5),
            margin: EdgeInsets.fromLTRB(64.0, 66.0, 0.0, 0.0),
          ),
        ],
      ),
    );
  }

  void loadEMContactsList() {
    EMClient.getInstance().contactManager().getAllContactsFromServer(
        onSuccess: (contacts){
          this.contactsList = contacts.toList();
          _refreshUI();
        },
        onError: (code, desc){
          WidgetUtil.hintBoxWithDefault(desc);
        }
    );
  }

  void _refreshUI() {
    setState(() {});
  }

  _deleteContact(int index) {
    EMClient.getInstance().contactManager().deleteContact(userName: _getData(index - 7),
        onSuccess: (){
          this.contactsList.removeAt(index - 7);
          loadEMContactsList();
        },
        onError: (code, desc){

        });
  }

  void onContactAdded(String userName){
    loadEMContactsList();
  }
  void onContactDeleted(String userName){
    loadEMContactsList();
  }
  void onContactInvited(String userName, String reason){
    EMClient.getInstance().contactManager().acceptInvitation(userName: userName,
        onSuccess: (){
          Future.sync((){
            WidgetUtil.hintBoxWithDefault('自动同意$userName的好友请求!');
          });
        },
        onError: (code, desc){
          WidgetUtil.hintBoxWithDefault(desc);
        });
    loadEMContactsList();
  }
  void onFriendRequestAccepted(String userName){
    loadEMContactsList();
  }
  void onFriendRequestDeclined(String userName){
    loadEMContactsList();
  }



}