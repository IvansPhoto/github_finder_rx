import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:github_finder_rx/widgets.dart';

class SelectedUsers extends StatelessWidget {
	final _formKey = GlobalKey<FormState>();

	@override
	Widget build(BuildContext context) {
		final TextEditingController _userNameKey = TextEditingController(text: 'Name');
		return Scaffold(
			drawer: MainDrawer(),
			appBar: AppBar(title: Text('Selected User'), elevation: 0, centerTitle: true),
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
									Text('Selected users.'),
									TextFormField(
										keyboardType: TextInputType.text,
										controller: _userNameKey,
										decoration: const InputDecoration(hintText: 'Input a user name'),
										validator: (value) => value.isEmpty ? 'Enter a user name here.' : null,
									),
									RaisedButton.icon(
											elevation: 0,
											onPressed: () {
												print('Pressed');
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
