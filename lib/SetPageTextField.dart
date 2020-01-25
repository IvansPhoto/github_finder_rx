import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:github_finder_rx/services.dart';

class SetPage extends StatelessWidget {
  final _streamService = getIt.get<StreamService>();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final TextEditingController _setPageKey = TextEditingController(text: _streamService.currentSearch.pageNumber.toString());
    final int _theLastPageNumber = (_streamService.currentGHUResponse.totalCount / _streamService.currentSearch.resultPerPage).ceil();
    final int _apiMaxPage = (1000 ~/ _streamService.currentSearch.resultPerPage).ceil();
    final int _currentPge = _streamService.currentSearch.pageNumber;
    return Scaffold(
      appBar: AppBar(title: Text("Return to the search result")),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(height: MediaQuery.of(context).size.height / 4),
            Text('Matches found: ${_streamService.currentGHUResponse.totalCount}'),
            _streamService.currentGHUResponse.totalCount > 1000
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                    child: Text('The available only the first 1000 matches', style: Theme.of(context).textTheme.overline),
                  )
                : Container(),
            TextFormField(
                key: _formKey,
                autovalidate: true,
                controller: _setPageKey,
                autofocus: true,
                textAlign: TextAlign.center,
                cursorColor: Colors.red[900],
                decoration: const InputDecoration(hintText: 'Page number'),
                enableSuggestions: false,
                inputFormatters: <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
                onChanged: (data) {
                  _setPageKey.text = data;
                  print(_setPageKey.text + ' ' + data);
                },
                onFieldSubmitted: (data) {
                  _setPageKey.text = data;
                  print('onFieldSubmitted ' + _setPageKey.text + ' ' + data);
                },
//				  				onSaved: (data) {
//				  					_searchParameters.setPage = int.tryParse(data, radix: 10);
//				  					print('onSaved');
//				  				},
                validator: (data) {
                  if (data.isEmpty)
                    return 'Set the Page Number.';
                  else if (int.tryParse(data, radix: 10) > (_theLastPageNumber > _apiMaxPage ? _apiMaxPage : _theLastPageNumber) || (int.tryParse(data, radix: 10) <= 0))
                    return 'The number shoud be from 1 to ${_theLastPageNumber > _apiMaxPage ? _apiMaxPage : _theLastPageNumber}';
                  else
                    return null;
                }),
            Text('Current - $_currentPge. The last page - ${_theLastPageNumber > _apiMaxPage ? _apiMaxPage : _theLastPageNumber}'),
            RaisedButton(
              elevation: 0,
              onPressed: () {
                _streamService.currentSearch.pageNumber = int.tryParse(_setPageKey.text);
                _streamService.searchUsers(context: context, streamService: _streamService);
                Navigator.pop(context);
              },
              child: Text('Set the page number'),
            )
          ],
        ),
      ),
    );
  }
}
