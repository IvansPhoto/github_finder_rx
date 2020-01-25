import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:github_finder_rx/widgets.dart';
import 'package:github_finder_rx/services.dart';

class SearchingUsersPage extends StatelessWidget {
  final _streamService = getIt.get<StreamService>();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final TextEditingController _userNameKey = TextEditingController();
    final TextEditingController _perPageKey = TextEditingController(text: _streamService.currentSearch.resultPerPage.toString());
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(title: Text('Index Page'), elevation: 0, centerTitle: true),
      body: Center(
        child: Form(
            key: _formKey,
            autovalidate: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 15),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(height: 25),
                  Text('Search a user by his login and profile properties.'),
                  SizedBox(height: 10),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: _userNameKey,
                    decoration: const InputDecoration(hintText: 'Input a user name'),
                    validator: (value) => value.isEmpty ? 'Enter a user name here.' : null,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: _perPageKey,
                    decoration: const InputDecoration(hintText: 'Show matches per one page'),
                    inputFormatters: <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly],
                    validator: (data) {
                      if (data.isEmpty)
                        return 'Set matches per page.';
                      else if (RegExp(r'[\D]').hasMatch(data))
                        return 'It should be a number!';
                      else if ((int.tryParse(data, radix: 10) > 100) || (int.tryParse(data, radix: 10) <= 0))
                        return 'The number shoud be from 1 to 100!';
                      else
                        return null;
                    },
                  ),
                  SizedBox(height: 10),
                  RaisedButton.icon(
                      elevation: 0,
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          _streamService.currentSearch.searchString = _userNameKey.text; //Set search string to object.
                          _streamService.currentSearch.resultPerPage = int.parse(_perPageKey.text);
                          _streamService.currentSearch.pageNumber = 1;
                          _streamService.searchUsers(context: context, streamService: _streamService);
                          Navigator.pushNamed(context, RouteNames.users);
                        } else {
                          return null;
                        }
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
