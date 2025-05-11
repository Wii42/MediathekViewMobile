import 'package:flutter/material.dart';
import 'package:flutter_ws/enum/channels.dart';
import 'package:flutter_ws/model/channel.dart';
import 'package:flutter_ws/util/text_styles.dart';
import 'package:flutter_ws/widgets/filterMenu/channel_list_tile.dart';
import 'package:flutter_ws/widgets/filterMenu/search_filter.dart';
import 'package:logging/logging.dart';

class ChannelPickerDialog extends StatefulWidget {
  final Logger logger = new Logger('ChannelPickerDialog');
  final SearchFilter? filterPreSelection;
  ChannelPickerDialog(this.filterPreSelection);

  @override
  ChannelPickerDialogState createState() {
    logger.fine("Creating state for channel picker");
    Set<String> selectedChannels = extractChannelNamesFromCurrentFilter();
    Set<Channel> channels = new Set();

    Channels.channelMap.forEach((channelName, assetName) => channels.add(
        new Channel(
            channelName, assetName, selectedChannels.contains(channelName))));

    return new ChannelPickerDialogState(channels);
  }

  Set<String> extractChannelNamesFromCurrentFilter() {
    Set<String> selectedChannels = new Set();

    if (filterPreSelection != null &&
        filterPreSelection!.filterValue.isNotEmpty &&
        !filterPreSelection!.filterValue.contains(";")) {
      //only one filter in pre-selection
      logger.fine("One filter pre-selected");
      selectedChannels.add(filterPreSelection!.filterValue);
    } else if (filterPreSelection != null &&
        filterPreSelection!.filterValue.isNotEmpty &&
        filterPreSelection!.filterValue.contains(";")) {
      //multiple filters already
      selectedChannels = filterPreSelection!.filterValue.split(";").toSet();
      logger.fine(selectedChannels.length.toString() + " filters pre-selected");
    }
    return selectedChannels;
  }
}

class ChannelPickerDialogState extends State<ChannelPickerDialog> {
  Set<Channel> channels;
  ChannelPickerDialogState(this.channels);

  Widget itemBuilder(BuildContext context, int index) {
    return new ChannelListTile(channels.elementAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.grey[800],
      body: new Column(
        children: <Widget>[
          new AppBar(
            title: new Text('Wähle Sender', style: sectionHeadingTextStyle),
            backgroundColor: new Color(0xffffbf00),
            leading: new IconButton(
              icon: new Icon(Icons.arrow_back, size: 30.0, color: Colors.white),
              onPressed: () {
                //return channels when user pressed back
                return Navigator.pop(
                    context,
                    channels
                        .where((channel) => channel.isCheck == true)
                        .map((channel) => channel.name)
                        .toSet());
              },
            ),
          ),
          new Flexible(
            child: new ListView.builder(
                itemBuilder: itemBuilder, itemCount: channels.length),
          ),
        ],
      ),
    );
  }
}
