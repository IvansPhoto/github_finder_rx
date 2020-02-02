import 'package:flutter/material.dart';
import 'package:github_finder_rx/services.dart';

class WidgetSettingPage extends StatelessWidget {
  final _widgetTypes = getIt.get<WidgetTypes>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: RaisedButton(
	        elevation: 0,
	        child: Text('Change to ${_widgetTypes.imageType ? 'Fade' : 'Indicator'}'),
          onPressed: () {
          	print(_widgetTypes.imageType);
          	_widgetTypes.inverseImageType();
          	_widgetTypes.inverseUserView();
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}

class TextStateful extends StatefulWidget {

	final String _text;
	TextStateful(this._text);

  @override
  _TextStatefulState createState() => _TextStatefulState();
}

class _TextStatefulState extends State<TextStateful> {

	@override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Text(widget._text);
  }
}
