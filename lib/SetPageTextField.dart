import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:github_finder_rx/services.dart';

class SetPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _streamService = getIt.get<StreamService>();

  @override
  Widget build(BuildContext context) {
    final _pageNumber = _streamService.currentSearch.pageNumber;
    final _totalCount = _streamService.currentGHUResponse.totalCount;
    final _resultPerPage = _streamService.currentSearch.resultPerPage;

    final TextEditingController _setPageKey = TextEditingController(text: _pageNumber.toString());
    final int _theLastPageNumber = (_totalCount / _resultPerPage).ceil();
    final int _apiMaxPage = (1000 ~/ _resultPerPage).ceil();
    final int _currentPge = _pageNumber;

    return Scaffold(
      appBar: AppBar(title: Text("Return to the search result")),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
        child: Form(
          key: _formKey,
          autovalidate: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(height: MediaQuery.of(context).size.height / 8),
              Text('Matches found: $_totalCount'),
              _totalCount > 1000
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                      child: Text('The available only the first 1000 matches', style: Theme.of(context).textTheme.overline),
                    )
                  : Container(),
              Text('Current page - $_currentPge (${_setPageKey.text}); the last - ${_theLastPageNumber > _apiMaxPage ? _apiMaxPage : _theLastPageNumber}'),
              TextFormField(
                  controller: _setPageKey,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  cursorColor: Colors.red[900],
                  decoration: const InputDecoration(hintText: 'Page number'),
                  enableSuggestions: false,
                  inputFormatters: <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                  validator: (data) {
                    if (data.isEmpty)
                      return 'Set the Page Number.';
                    else if (int.tryParse(data, radix: 10) > (_theLastPageNumber > _apiMaxPage ? _apiMaxPage : _theLastPageNumber) || (int.tryParse(data, radix: 10) <= 0))
                      return 'The number shoud be from 1 to ${_theLastPageNumber > _apiMaxPage ? _apiMaxPage : _theLastPageNumber}';
                    else
                      return null;
                  }),
              RaisedButton(
                elevation: 0,
                onPressed: () {
                  _streamService.currentSearch.pageNumber = int.tryParse(_setPageKey.text);
                  _streamService.searchUsers(context: context, streamService: _streamService);
                  Navigator.pop(context);
                },
                child: Text('Set the page number ${_setPageKey.text}'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
