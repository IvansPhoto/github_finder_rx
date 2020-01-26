import 'package:flutter/material.dart';
import 'package:github_finder_rx/supportPages/LoadingScreen.dart';
import 'package:github_finder_rx/pages/ChangePageNumber.dart';
import 'package:github_finder_rx/services.dart';
import 'package:github_finder_rx/widgets.dart';
import 'package:github_finder_rx/apiClasses.dart';

class ResultSearchPage extends StatelessWidget {
  final _streamService = getIt.get<StreamService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('The Users have found'),
        elevation: 0,
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ChangePageNumber(), fullscreenDialog: true)),
          )
        ],
      ),
      body: StreamBuilder(
          stream: _streamService.streamGHUResponse$,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return LoadingScreen();
            } else if (_streamService.currentGHUResponse.headerStatus != '200 OK') {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(_streamService.currentGHUResponse.headerStatus),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Text(_streamService.currentGHUResponse.message, style: Theme.of(context).textTheme.overline),
                    ),
                    Text(_streamService.currentGHUResponse.docUrl),
                  ],
                ),
              );
            } else {
              final List<GitHubUsers> gitHubUsers = snapshot.data.users;
              return ListView.builder(
                  itemCount: gitHubUsers.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (gitHubUsers.length < 1) {
                      return Center(heightFactor: 10, child: Text('No users found', style: TextStyle(fontSize: 45)));
                    } else if (index > gitHubUsers.length - 1) {
                      return SearchingButton(context);
//                      return searchingButtonFunction(context: context, streamService: _streamService);
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
                                  onPressed: () => StreamService.showUserProfileHero(context: context, url: gitHubUsers[index].url),
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
