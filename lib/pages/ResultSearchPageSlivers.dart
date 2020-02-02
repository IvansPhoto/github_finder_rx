import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:github_finder_rx/pages/WidgetSettingsPage.dart';
//import 'package:github_finder_rx/supportPages/LoadingScreen.dart';
import 'package:github_finder_rx/pages/ChangePageNumber.dart';
import 'package:github_finder_rx/services.dart';
import 'package:github_finder_rx/widgets.dart';
import 'package:github_finder_rx/apiClasses.dart';

class ResultSearchPageSlivers extends StatelessWidget {
  final _streamService = getIt.get<StreamService>();
  final _widgetTypes = getIt.get<WidgetTypes>();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          title: Text('The Users have found!'),
          elevation: 0,
          floating: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => WidgetSettingPage(), fullscreenDialog: true)),
            )
          ],
        ),
        StreamBuilder(
            stream: _streamService.streamGHUResponse$,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData)
                return SliverList(
                  delegate: SliverChildListDelegate.fixed([
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[Text('Loading')],
                    ),
                  ]),
                );
              else if (_streamService.currentGHUResponse.headerStatus != '200 OK')
                return _ApiError(_streamService.currentGHUResponse);
              else
                switch (_widgetTypes.usersGridInsteadList) {
                case 0:
                  return _GridViewUsers(snapshot.data.users);
                case 1:
                  return _ListViewUsers(snapshot.data.users);
              };
            }),
      ],
    );
  }
}

class _ListViewUsers extends StatelessWidget {
  final List<GitHubUsers> gitHubUsers;
  _ListViewUsers(this.gitHubUsers);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: gitHubUsers.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (gitHubUsers.length < 1) {
            return Center(heightFactor: 10, child: Text('No users found', style: TextStyle(fontSize: 45)));
          } else if (index > gitHubUsers.length - 1) {
            return _SearchingButton();
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
                        onPressed: () => Navigator.pushNamed(context, RouteNames.profile,
                            arguments: {'url': gitHubUsers[index].url, 'avatarUrl': gitHubUsers[index].avatarUrl, 'login': gitHubUsers[index].login}),
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
}

class _GridViewUsers extends StatelessWidget {
  final List<GitHubUsers> gitHubUsers;
  _GridViewUsers(this.gitHubUsers);

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) => Container(
          width: 100,
          height: 100,
          child: Hero(
            tag: gitHubUsers[index].avatarUrl,
            child: ImageUrlIndicator(url: gitHubUsers[index].avatarUrl),
          ),
        ),
        childCount: gitHubUsers.length,
      ),
    );
  }
}

class _SearchingButton extends StatelessWidget {
//  SearchingButton(BuildContext context);

  final _streamService = getIt.get<StreamService>();

  @override
  Widget build(BuildContext context) {
    final _pageNumber = _streamService.currentSearch.pageNumber;
    final _resultPerPage = _streamService.currentSearch.resultPerPage;
    final _totalCount = _streamService.currentGHUResponse.totalCount;
    final int _theLastPageNumber = (_totalCount / _resultPerPage).ceil();
    final int _apiMaxPage = (1000 ~/ _resultPerPage).ceil();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.navigate_before, size: 35),
          onPressed: _pageNumber != 1
              ? () {
                  _streamService.currentSearch.decreasePage();
                  ApiRequests.searchUsers(streamService: _streamService, context: context);
                }
              : null,
        ),
        FlatButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ChangePageNumber(), fullscreenDialog: true));
          },
          child: Column(
            children: <Widget>[
              Text(
                'Tap to change page',
                style: Theme.of(context).textTheme.overline,
              ),
              Text(
                '$_pageNumber / ${_theLastPageNumber > _apiMaxPage ? _apiMaxPage : _theLastPageNumber}',
                style: Theme.of(context).textTheme.overline,
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.navigate_next,
            size: 35,
          ),
          onPressed: ((_totalCount / _resultPerPage) != _pageNumber && _pageNumber < (1000 / _resultPerPage))
              ? () {
                  _streamService.currentSearch.increasePage();
                  ApiRequests.searchUsers(streamService: _streamService, context: context);
                }
              : null,
        ),
      ],
    );
  }
}

class _ApiError extends StatelessWidget {
  final GitHubUserResponse currentGHUResponse;
  _ApiError(this.currentGHUResponse);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(currentGHUResponse.headerStatus),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Text(currentGHUResponse.message, style: Theme.of(context).textTheme.overline),
          ),
          Text(currentGHUResponse.docUrl),
        ],
      ),
    );
  }
}
