import 'package:flutter/material.dart';
import 'package:github_finder_rx/pages/LoadingScreen.dart';
import 'package:github_finder_rx/services.dart';
import 'package:github_finder_rx/widgets.dart';
import 'package:github_finder_rx/apiClasses.dart';

class ResultSearchPage extends StatelessWidget {
  final _searchParameters = getIt.get<StreamService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('The Users have found'), elevation: 0, centerTitle: true),
      body: StreamBuilder(
          stream: _searchParameters.streamGHUResponse$,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return LoadingScreen();
            } else if (_searchParameters.currentGHUResponse.headerStatus != '200 OK') {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(_searchParameters.currentGHUResponse.headerStatus),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Text(
                        _searchParameters.currentGHUResponse.message,
                        style: Theme.of(context).textTheme.overline,
                      ),
                    ),
                    Text(_searchParameters.currentGHUResponse.docUrl),
                  ],
                ),
              );
//              return Center(
//                child: Text.rich(TextSpan(children: [
//                  TextSpan(text: _searchParameters.currentGHUResponse.message + '\n'),
//                  TextSpan(text: _searchParameters.currentGHUResponse.docUrl + '\n'),
//                  TextSpan(text: _searchParameters.currentGHUResponse.headerStatus),
//                ])),
//              );
            } else {
              final List<GitHubUsers> gitHubUsers = snapshot.data.users;
              return ListView.builder(
                  itemCount: gitHubUsers.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (gitHubUsers.length < 1) {
                      return Center(heightFactor: 10, child: Text('No users found', style: TextStyle(fontSize: 45)));
                    } else if (index > gitHubUsers.length - 1) {
                      return SearchingButton(context);
                    } else {
                      return Card(
                        elevation: 0,
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 100,
                              height: 100,
                              child: Hero(
                                tag: gitHubUsers[index].avatarUrl,
                                child: ImageUrlIndicator(url: gitHubUsers[index].avatarUrl),
                              ),
                            ),
                            Container(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('Login: ' + gitHubUsers[index].login),
                                Text('Score: ' + gitHubUsers[index].score.toString()),
                                RaisedButton(
                                  elevation: 0,
                                  onPressed: () {
                                    StreamService.showUserProfileHero(context: context, url: gitHubUsers[index].url);
                                  },
                                  child: Text('View profile'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }
                  });
            }
          }),
    );
  }
}

//class SearchUsersResultPageInStream extends StatelessWidget {
//	final _searchParameters = getIt.get<SearchParameters>();
//
//	@override
//	Widget build(BuildContext context) {
//		return Scaffold(
//			appBar: AppBar(title: Text('The Users have found'), elevation: 0, centerTitle: true),
//			body: StreamBuilder(
//					stream: _searchParameters.streamGHUResponse$,
//					builder: (BuildContext context, AsyncSnapshot snapshot) {
//						if (!snapshot.hasData) {
//							return LoadingScreen();
//						} else {
//							final List<GitHubUsers> gitHubUsers = snapshot.data.users;
//							return Column(
//								children: <Widget>[
//									SearchingButton(),
//									Expanded(
//										child: ListView.builder(
//												itemCount: gitHubUsers.length + 1,
//												itemBuilder: (BuildContext context, int index) {
//													if (index > gitHubUsers.length - 1) {
//														return SearchingButton();
//													} else {
//														return Card(
//															elevation: 0,
//															child: Row(
//																children: <Widget>[
//																	ImageUrlIndicator(url: gitHubUsers[index].avatarUrl),
//																	Container(width: 10),
//																	Column(
//																		crossAxisAlignment: CrossAxisAlignment.start,
//																		children: <Widget>[
//																			Text('Login: ' + gitHubUsers[index].login),
//																			Text('Score: ' + gitHubUsers[index].score.toString()),
//																			FlatButton(
//																				onPressed: () {
//																					SearchParameters.getUserProfile(context: context, url: gitHubUsers[index].url);
//																				},
//																				child: Text('View profile'),
//																				color: Theme.of(context).primaryColor,
//																			)
//																		],
//																	),
//																],
//															),
//														);
//													}
//												}),
//									),
//								],
//							);
//						}
//					}),
//		);
//		;
//	}
//}
