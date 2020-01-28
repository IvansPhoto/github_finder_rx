import 'package:flutter/material.dart';
import 'package:github_finder_rx/pages/ChangePageNumber.dart';
import 'package:github_finder_rx/services.dart';

class MainDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AppBar(
            automaticallyImplyLeading: false,
            elevation: 0,
            centerTitle: true,
            title: Text('Title in the menu'),
          ),
          FlatButton.icon(
            onPressed: () => Navigator.pushReplacementNamed(context, RouteNames.index),
            icon: Icon(Icons.supervised_user_circle, size: 30),
            label: Text('Find user'),
          ),
          FlatButton.icon(
            onPressed: () => Navigator.pushReplacementNamed(context, RouteNames.selectedUsers),
            icon: Icon(Icons.star, size: 30),
            label: Text('Selected users'),
          ),
        ],
      ),
    );
  }
}

class ImageUrlIndicator extends StatelessWidget {
  final String url;
  final double height;
  final double width;

  ImageUrlIndicator({this.url, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      height: height,
      width: width,
      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes : null,
          ),
        );
      },
    );
  }
}

class SearchingButton extends StatelessWidget {
  SearchingButton(BuildContext context);

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
          child: Text('$_pageNumber / ${_theLastPageNumber > _apiMaxPage ? _apiMaxPage : _theLastPageNumber}'),
        ),
        IconButton(
          icon: Icon(
            Icons.navigate_next,
            size: 35,
          ),
          onPressed: ((_totalCount / _resultPerPage) != _pageNumber &&
                  _pageNumber < (1000 / _resultPerPage))
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
