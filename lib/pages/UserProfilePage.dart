import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:github_finder_rx/apiClasses.dart';
import 'package:github_finder_rx/widgets.dart';
import 'package:http/http.dart';

class UserProfilePage extends StatelessWidget {
  final double _verticalPadding = 3.5;
  final double _verticalHeight = 1;

  Widget _rowProperties(BuildContext context, String propertyName, String dataProperty) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(propertyName, style: Theme.of(context).textTheme.display1),
            Text(dataProperty),
          ],
        ),
        Container(height: _verticalHeight, color: Colors.grey, margin: EdgeInsets.symmetric(vertical: _verticalPadding)),
      ],
    );
  }

  Widget _listViewHorizontal(BuildContext context, String propertyName, String dataProperty) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: 25,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              Text(propertyName, style: Theme.of(context).textTheme.display1),
              Text(dataProperty),
            ],
          ),
        ),
        Container(height: _verticalHeight, color: Colors.grey, margin: EdgeInsets.symmetric(vertical: _verticalPadding)),
      ],
    );
  }

  Widget _textSpans(BuildContext context, String propertyName, String dataProperty) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text.rich(
          TextSpan(children: [
            TextSpan(text: propertyName, style: Theme.of(context).textTheme.display1),
            TextSpan(text: dataProperty),
          ]),
        ),
        Container(height: _verticalHeight, color: Colors.grey, margin: EdgeInsets.symmetric(vertical: _verticalPadding)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    UserProfile theUserProfile = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(elevation: 0, title: Text('The profile of ${theUserProfile.login}'), centerTitle: true),
      body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Hero(
                  tag: theUserProfile.avatarUrl,
                  child: ImageUrlIndicator(url: theUserProfile.avatarUrl),
                ),
                Container(height: 6),
                _rowProperties(context, 'Login: ', theUserProfile.login),
                _rowProperties(context, 'Name: ', theUserProfile.name),
                _rowProperties(context, 'Followers: ', theUserProfile.followers.toString()),
                _rowProperties(context, 'Following: ', theUserProfile.following.toString()),
                _rowProperties(context, 'Email: ', theUserProfile.email),
                _rowProperties(context, 'Company: ', theUserProfile.company),
                _rowProperties(context, 'Hireable: ', theUserProfile.hireable.toString()),
                _listViewHorizontal(context, 'Page: ', theUserProfile.htmlUrl),
                _listViewHorizontal(context, 'Blog: ', theUserProfile.blog),
                _textSpans(context, 'Biography: ', theUserProfile.bio)
              ],
            ),
          )),
    );
  }
}

class UserProfilePageFutureBuilder extends StatelessWidget {

  Widget _listViewHorizontal(BuildContext context, String propertyName, String dataProperty) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: 25,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              Text(propertyName + ': ', style: Theme.of(context).textTheme.display1),
              Text(dataProperty),
            ],
          ),
        ),
        Container(height: 1, color: Colors.grey, margin: EdgeInsets.symmetric(vertical: 6)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Map theUserProfile = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(elevation: 0, title: Text('The profile of ${theUserProfile['login']}'), centerTitle: true),
      body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Hero(
                  tag: theUserProfile['avatarUrl'],
                  child: ImageUrlIndicator(url: theUserProfile['avatarUrl']),
                ),
                Container(height: 6),
                FutureBuilder(
                  future: get(theUserProfile['url']),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {

                    List<Widget> children = [];

                    if (snapshot.hasData) {
                      final Map<String, dynamic> userData = jsonDecode(snapshot.data.body);
                      userData.forEach((String key, value) {
                        children.add(_listViewHorizontal(context, key, value.toString()));
                      });
                    } else if (snapshot.hasError) {
                      children = <Widget>[
                        Icon(Icons.error_outline, color: Colors.red, size: 60),
                        Text('Error: ${snapshot.error}'),
                      ];
                    } else {
                      children = <Widget>[
                        CircularProgressIndicator(),
                        Text('Awaiting server response...')
                      ];
                    }

                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: children,
                      ),
                    );
                  },
                ),
                Container(height: 6),
              ],
            ),
          )),
    );
  }
}
