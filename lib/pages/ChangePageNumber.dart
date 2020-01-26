import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:github_finder_rx/services.dart';

class ChangePageNumber extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _streamService = getIt.get<StreamService>();

  @override
  Widget build(BuildContext context) {
    final TextEditingController _pageNumberKey = TextEditingController(text: _streamService.currentSearch.pageNumber.toString());

    final _pageNumber = _streamService.currentSearch.pageNumber;
    final _totalCount = _streamService.currentGHUResponse.totalCount;
    final _resultPerPage = _streamService.currentSearch.resultPerPage;

    final int _theLastPageNumber = (_totalCount / _resultPerPage).ceil();
    final int _apiMaxPage = (1000 ~/ _resultPerPage).ceil();
    final int _currentPge = _pageNumber;

    return Scaffold(
      appBar: AppBar(title: Text('Select the page number.'), elevation: 0, centerTitle: true),
      body: Center(
        child: Form(
            key: _formKey,
            autovalidate: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 15),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  //Container call an error which obstruct save information in the Field.
//                  Container(height: MediaQuery.of(context).size.height / 6),
                  Text('You have ${_streamService.currentGHUResponse.totalCount.toString()} matches.'),
                  _totalCount > 1000
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                          child: Text('The available only the first 1000 matches.', style: Theme.of(context).textTheme.overline),
                        )
                      : Container(),
                  Text('Current page - $_currentPge; the last - ${_theLastPageNumber > _apiMaxPage ? _apiMaxPage : _theLastPageNumber}.'),
                  TextFormField(
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    controller: _pageNumberKey,
                    textAlign: TextAlign.center,
                    inputFormatters: <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(hintText: 'Input the page number.'),
                    validator: (data) {
                      if (data.isEmpty)
                        return 'Set the Page Number.';
                      else if (int.tryParse(data, radix: 10) > (_theLastPageNumber > _apiMaxPage ? _apiMaxPage : _theLastPageNumber) || (int.tryParse(data, radix: 10) <= 0))
                        return 'The number shoud be from 1 to ${_theLastPageNumber > _apiMaxPage ? _apiMaxPage : _theLastPageNumber}';
                      else
                        return null;
                    },
                  ),
                  RaisedButton.icon(
                      elevation: 0,
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          _streamService.currentSearch.pageNumber = int.tryParse(_pageNumberKey.text);
                          _streamService.searchUsers(context: context, streamService: _streamService);
                          print(int.tryParse(_pageNumberKey.text));
                          Navigator.pop(context);
                        } else
                          return null;
                      },
                      icon: Icon(Icons.search),
                      label: Text('Start searching'))
                ],
              ),
            )),
      ),
    );
  }
}
