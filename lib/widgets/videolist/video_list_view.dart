import 'package:flutter/material.dart';
import 'package:flutter_ws/model/video.dart';
import 'package:flutter_ws/util/channel_util.dart';
import 'package:flutter_ws/util/cross_axis_count.dart';
import 'package:flutter_ws/widgets/downloadSection/video_list_item_builder.dart';
import 'package:flutter_ws/widgets/videolist/loading_list_view.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

class VideoListView extends StatefulWidget {
  final Logger logger = new Logger('VideoListView');

  List<Video>? videos;
  var queryEntries;
  var refreshList;
  int? amountOfVideosFetched;
  int? totalResultSize;
  int currentQuerySkip;
  TickerProviderStateMixin mixin;

  VideoListView({
    Key? key,
    required this.queryEntries,
    required this.amountOfVideosFetched,
    required this.videos,
    required this.refreshList,
    required this.totalResultSize,
    required this.currentQuerySkip,
    required this.mixin,
  }) : super(key: key);

  @override
  _VideoListViewState createState() => _VideoListViewState();
}

class _VideoListViewState extends State<VideoListView> {
  ScrollController? scrollController;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    widget.logger.info("Rendering Main Video List with list length " +
        widget.videos!.length.toString());

    if (widget.videos!.length == 0 && widget.amountOfVideosFetched == 0) {
      widget.logger.info("No Videos found");
      return new SliverToBoxAdapter(child: buildNoVideosFound());
    } else if (widget.videos!.length == 0) {
      widget.logger.info("Searching: video list legth : 0 & amountFetched: " +
          widget.amountOfVideosFetched.toString());
      return new SliverToBoxAdapter(child: LoadingListPage());
    }

    // do not request previews in the main download section if it is a tablet
    // do not overload CPU
    //bool previewNotDownloadedVideos = !DeviceInformation.isTablet(context);

    var videoListItemBuilder = new VideoListItemBuilder.name(
        widget.videos, true, false, true,
        queryEntries: widget.queryEntries,
        amountOfVideosFetched: widget.amountOfVideosFetched,
        totalResultSize: widget.totalResultSize,
        currentQuerySkip: widget.currentQuerySkip);

    int crossAxisCount = CrossAxisCount.getCrossAxisCount(context);

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 16 / 9,
        mainAxisSpacing: 1.0,
        crossAxisSpacing: 5.0,
      ),
      delegate: SliverChildBuilderDelegate(videoListItemBuilder.itemBuilder,
          childCount: widget.videos!.length),
    );
  }

  Center buildNoVideosFound() {
    return new Center(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Center(
            child: new Text(
              "Keine Videos gefunden",
              style: new TextStyle(fontSize: 25),
            ),
          ),
          new Container(
            height: 50,
            child: new ListView(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ChannelUtil.getAllChannelImages(),
            ),
          ),
        ],
      ),
    );
  }
}
