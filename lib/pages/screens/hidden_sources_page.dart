import 'package:flutter/material.dart';

import 'package:MyNews/services/prefs_service.dart';

import 'package:MyNews/widgets/ui_elements/global_widgets/app_bar_title.dart';

class HiddenSourcesPage extends StatefulWidget {
  @override
  _HiddenSourcesPageState createState() => _HiddenSourcesPageState();
}

class _HiddenSourcesPageState extends State<HiddenSourcesPage> {
  List<String> hiddenSources;
  @override
  void initState() {
    // get hidden sources from prefs service
    hiddenSources = Prefs.getHiddenSources();
    super.initState();
  }

  // return scaffold body widget
  Widget _buildScaffoldBody() {
    if (hiddenSources != null && hiddenSources.isNotEmpty) {
      return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: ListTile(
              title: Text(hiddenSources[index]),
              trailing: IconButton(
                icon: Icon(Icons.remove_circle),
                onPressed: () {},
                tooltip: 'Remove',
              ),
            ),
          );
        },
        itemCount: hiddenSources.length,
      );
    } else {
      return Container(
        padding: EdgeInsets.only(top: 40),
        alignment: Alignment.topCenter,
        child: Text(
          'You haven\'t hidden any sources',
          style: Theme.of(context).textTheme.headline6,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitle('Sources you\'ve hidden'),
      ),
      body: Container(
        padding: EdgeInsets.all(4.0),
        child: _buildScaffoldBody(),
      ),
    );
  }
}
