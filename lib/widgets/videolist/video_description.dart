import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_ws/model/video.dart';
import 'package:flutter_ws/util/text_styles.dart';
import 'package:flutter_ws/util/timestamp_calculator.dart';
import 'package:flutter_ws/widgets/videolist/channel_thumbnail.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoDescription extends StatelessWidget {
  Video video;
  String channelPictureImagePath;
  double verticalOffset;
  BuildContext context;

  VideoDescription(
      this.video, this.channelPictureImagePath, this.verticalOffset);

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return new Padding(
      padding: EdgeInsets.only(top: verticalOffset - 15.0),
      child: new Stack(
        children: <Widget>[
          new GestureDetector(child: getBody()),
          new Padding(
            padding: const EdgeInsets.only(left: 9.0),
            child: channelPictureImagePath.isNotEmpty
                ? new ChannelThumbnail(channelPictureImagePath, false)
                : new Container(),
          ),
        ],
      ),
    );
  }

  Widget getBody() {
    return new ClipRect(
      child: new BackdropFilter(
        filter: new ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: new Padding(
          padding: const EdgeInsets.only(left: 30.0, right: 10.0, top: 10),
          child: new Container(
            //height: 400.0,
            decoration: new BoxDecoration(
              borderRadius: new BorderRadius.only(
                  topLeft: const Radius.circular(40.0),
                  bottomLeft: const Radius.circular(40.0),
                  bottomRight: const Radius.circular(40.0),
                  topRight: const Radius.circular(40.0)),
              color: new Color(0xffffbf00).withOpacity(0.4),
            ),
            child: new Padding(
              padding: const EdgeInsets.only(
                  left: 30.0, right: 30.0, top: 10.0, bottom: 20.0),
              child: new SingleChildScrollView(
                child: new Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    getVerticalDividerLine(bottom: 15.0),
                    getCaption("Titel"),
                    new Text(
                      video.title,
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(color: Colors.black, fontSize: 15.0),
                    ),
                    //getSpacedContentRow(video.title),
                    getDivider(),
                    getCaption("Thema"),
                    new Text(
                      video.topic,
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(color: Colors.black, fontSize: 15.0),
                    ),
                    getDivider(),
                    getCaption("Länge"),
                    new Text(
                      Calculator.calculateDuration(video.duration),
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(color: Colors.black, fontSize: 15.0),
                    ),
                    getDivider(),
                    getCaption("Ausgestrahlt"),
                    new Text(
                      Calculator.calculateTimestamp(video.timestamp),
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(color: Colors.black, fontSize: 15.0),
                    ),
                    video.description != null && video.description.isNotEmpty
                        ? getDivider()
                        : new Container(),
                    video.description != null && video.description.isNotEmpty
                        ? getCaption("Beschreibung")
                        : new Container(),
                    video.description != null && video.description.isNotEmpty
                        ? new Text('"' + video.description + '"',
                            textAlign: TextAlign.left,
                            style: Theme.of(context).textTheme.headline6.copyWith(
                                color: Colors.black,
                                fontSize: 15.0,
                                fontStyle: FontStyle.italic))
                        : new Container(),
                    getDivider(),
                    video.url_website != null
                        ? new FlatButton(
                            color: Colors.grey[800],
                            child: new Text('Website', style: body2TextStyle),
                            onPressed: () => _launchURL(video.url_website),
                          )
                        : new Container(),
                    getVerticalDividerLine(top: 15.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Container getDivider() {
    return new Container(
      padding: EdgeInsets.only(top: 15.0),
    );
  }

  Text getCaption(String caption) {
    return new Text(
      caption,
      style: Theme.of(context).textTheme.headline6.copyWith(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20.0),
    );
  }

  Container getVerticalDividerLine({double bottom, double top}) {
    return new Container(
      height: 2.0,
      color: Colors.grey,
      margin: bottom != null
          ? EdgeInsets.only(left: 20, right: 20.0, bottom: bottom)
          : EdgeInsets.only(left: 20, right: 20.0, top: top),
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}
