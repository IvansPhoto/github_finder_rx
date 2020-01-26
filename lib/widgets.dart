import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:github_finder_rx/pages/SelectedUsers.dart';
import 'package:github_finder_rx/services.dart';
import 'package:github_finder_rx/SetPageTextField.dart';

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

  final _streamService = getIt.get<StreamService>();

  @override
  Widget build(BuildContext context) {
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
            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => SetPage(), fullscreenDialog: true));
          },
          child: Text('${_streamService.currentSearch.pageNumber} / ${_theLastPageNumber > _apiMaxPage ? _apiMaxPage : _theLastPageNumber}'),
        ),
        IconButton(
          icon: Icon(
            Icons.navigate_next,
            size: 35,
          ),
          onPressed: ((_streamService.currentGHUResponse.totalCount / _streamService.currentSearch.resultPerPage) != _streamService.currentSearch.pageNumber &&
                  _streamService.currentSearch.pageNumber < (1000 / _streamService.currentSearch.resultPerPage))
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

Widget searchingButtonFunction({BuildContext context, StreamService streamService}) {
  final int _theLastPageNumber = (streamService.currentGHUResponse.totalCount / streamService.currentSearch.resultPerPage).ceil();
  final int _apiMaxPage = (1000 ~/ streamService.currentSearch.resultPerPage).ceil();
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      IconButton(
        icon: Icon(Icons.navigate_before, size: 35),
        onPressed: streamService.currentSearch.pageNumber != 1
            ? () {
                streamService.currentSearch.decreasePage();
                streamService.searchUsers(streamService: streamService, context: context);
              }
            : null,
      ),
      FlatButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => SelectedPage(), fullscreenDialog: true));
        },
        child: Text('${streamService.currentSearch.pageNumber} / ${_theLastPageNumber > _apiMaxPage ? _apiMaxPage : _theLastPageNumber}'),
      ),
      IconButton(
        icon: Icon(
          Icons.navigate_next,
          size: 35,
        ),
        onPressed: ((streamService.currentGHUResponse.totalCount / streamService.currentSearch.resultPerPage) != streamService.currentSearch.pageNumber &&
                streamService.currentSearch.pageNumber < (1000 / streamService.currentSearch.resultPerPage))
            ? () {
                streamService.currentSearch.increasePage();
                streamService.searchUsers(streamService: streamService, context: context);
              }
            : null,
      ),
    ],
  );
}

class SetPageModal extends StatelessWidget {
  final _streamService = getIt.get<StreamService>();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final int _currentPage = _streamService.currentSearch.pageNumber;
    final _setPageKey = TextEditingController(text: _currentPage.toString());
    return Scaffold(
      appBar: AppBar(title: Text('Set page.')),
      body: Container(
        height: MediaQuery.of(context).size.height / 2,
        child: Form(
          key: _formKey,
          autovalidate: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 15),
                Text('Ccurrent is ${_streamService.currentSearch.pageNumber}'),
                Text('${_setPageKey.value.text} - ${_setPageKey.text}'),
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: _setPageKey,
                  autofocus: true,
//                  textAlign: TextAlign.center,
                  cursorColor: Colors.red[900],
                  inputFormatters: <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly],
                  validator: (data) => data.isEmpty ? 'Set the Page Number.' : null,
                  onFieldSubmitted: (data) => _setPageKey.text = data,
//              onFieldSubmitted: (data) => _streamService.currentSearch.pageNumber = int.tryParse(data),
//              onSaved: (data) => _streamService.currentSearch.pageNumber = int.tryParse(data),
                ),
                RaisedButton.icon(
                  elevation: 0,
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _streamService.currentSearch.pageNumber = int.tryParse(_setPageKey.text);
                      _streamService.searchUsers(context: context, streamService: _streamService);
                      Navigator.pop(context);
                    } else {
                      return null;
                    }
                  },
                  label: Text('Set'),
                  icon: Icon(Icons.track_changes),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
