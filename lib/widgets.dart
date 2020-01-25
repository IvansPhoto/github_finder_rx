import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:github_finder_rx/services.dart';
//import 'package:github_finder_rx/SetPageTextField.dart';

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
            onPressed: () => Navigator.pushNamed(context, RouteNames.selectedUsers),
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

  @override
  Widget build(BuildContext context) {
    final _streamService = getIt.get<StreamService>();
    final int _theLastPageNumber = (_streamService.currentGHUResponse.totalCount / _streamService.currentSearch.resultPerPage).ceil();
    final int _apiMaxPage = (1000 ~/ _streamService.currentSearch.resultPerPage).ceil();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.navigate_before, size: 35),
          onPressed: _streamService.currentSearch.pageNumber != 1
              ? () {
                  _streamService.currentSearch.decreasePage();
                  _streamService.searchUsers(streamService: _streamService, context: context);
                }
              : null,
        ),
        FlatButton(
          onPressed: () {
//						Navigator.pushNamed(context, RouteNames.setPage);
            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => SetPageModal(), fullscreenDialog: true));
          },
          child: Text('${_streamService.currentSearch.pageNumber} / ${_theLastPageNumber > _apiMaxPage ? _apiMaxPage : _theLastPageNumber}'),
        ),
        IconButton(
          icon: Icon(
            Icons.navigate_next,
            size: 35,
          ),
          onPressed:
              ((_streamService.currentGHUResponse.totalCount / _streamService.currentSearch.resultPerPage) != _streamService.currentSearch.pageNumber && _streamService.currentSearch.pageNumber < (1000 / _streamService.currentSearch.resultPerPage))
                  ? () {
                      _streamService.currentSearch.increasePage();
                      _streamService.searchUsers(streamService: _streamService, context: context);
                    }
                  : null,
        ),
      ],
    );
  }
}

class SetPageModal extends StatelessWidget {
  final _streamService = getIt.get<StreamService>();

  @override
  Widget build(BuildContext context) {
    final int _currentPage = _streamService.currentSearch.pageNumber;
    final _setPageKey = TextEditingController(text: _currentPage.toString());
    return Scaffold(
      appBar: AppBar(title: Text('Set page')),
      body: Container(
        height: MediaQuery.of(context).size.height / 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 15),
            Text('Set the page number (current is ${_streamService.currentSearch.pageNumber}).'),
            Text('${_setPageKey.value.text} - ${_setPageKey.text}'),
            TextFormField(
              autofocus: true,
//							onFieldSubmitted: (data) => _setPageKey.text = data,
              onFieldSubmitted: (data) => _streamService.currentSearch.pageNumber = int.tryParse(data),
              textAlign: TextAlign.center,
              cursorColor: Colors.red[900],
              controller: _setPageKey,
              keyboardType: TextInputType.number,
              onSaved: (data) => _streamService.currentSearch.pageNumber = int.tryParse(data),
              inputFormatters: <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly],
              validator: (data) {
                if (data.isEmpty)
                  return 'Set the Page Number.';
                else
                  return null;
              },
            ),
            FlatButton(
              onPressed: () {
                _streamService.currentSearch.pageNumber = int.tryParse(_setPageKey.text);
                _streamService.searchUsers(context: context, streamService: _streamService);
                Navigator.pop(context);
              },
              child: Text('Set'),
            )
          ],
        ),
      ),
    );
  }
}
