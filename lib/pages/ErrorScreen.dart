import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		final error = ModalRoute.of(context).settings.arguments;
		return SafeArea(
			child: Container(
				color: Colors.red[900],
				child: Center(
					child: Text(error.toString()),
				),
			),
		);
	}
}

//ErrorWidget

