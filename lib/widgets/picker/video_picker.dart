import 'dart:typed_data';

import 'package:advance_image_picker/configs/video_picker_configs.dart';
import 'package:advance_image_picker/utils/log_utils.dart';
import 'package:advance_image_picker/widgets/common/portrait_mode_mixin.dart';
import 'package:advance_image_picker/widgets/picker/media_album.dart';
import 'package:advance_image_picker/widgets/picker/video_album.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import 'image_picker.dart';

class VideoPicker extends StatefulWidget {
  Widget? cameraWidget;

  VideoPicker({Key? key, this.cameraWidget}) : super(key: key);

  @override
  _VideoPickerState createState() => _VideoPickerState();
}

class _VideoPickerState extends State<VideoPicker>
    with
// ignore: prefer_mixin
        WidgetsBindingObserver,
        TickerProviderStateMixin,
        PortraitStatefulModeMixin<VideoPicker> {
  /// Flag indicating status of permission to access photo libray
  bool _isGalleryPermissionOK = false;

  /// Photo album list.
  List<AssetPathEntity> _albums = [];

  /// Currently viewing album.
  AssetPathEntity? _currentAlbum;

  /// Album thumbnail cache.
  List<Uint8List?> _albumThumbnails = [];

  /// Key for current album object.
  final GlobalKey<MediaAlbumState> _currentAlbumKey = GlobalKey();

  /// Global key for this screen.
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Image configuration.
  VideoPickerConfigs _configs = VideoPickerConfigs();

  /// Max selecting count
  final int maxCount = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      await _initVideoGallery();
    });
  }

  /// Init video gallery for video selecting
  Future<void> _initVideoGallery() async {
    LogUtils.log("[_initVideoGallery] start");

    try {
      // Request permission for image selecting
      final result = await PhotoManager.requestPermissionExtend();
      if (result.isAuth) {
        LogUtils.log('PhotoGallery permission allowed');

        _isGalleryPermissionOK = true;

        // Get albums then set first album as current album
        _albums = await PhotoManager.getAssetPathList(type: RequestType.video);
        if (_albums.isNotEmpty) {
          final isAllAlbum = _albums.firstWhere((element) => element.isAll,
              orElse: () => _albums.first);
          setState(() {
            _currentAlbum = isAllAlbum;
          });
        }
      } else {
        LogUtils.log('PhotoGallery permission not allowed');
      }
    } catch (e) {
      LogUtils.log('PhotoGallery error ${e.toString()}');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    _albums.clear();
    _albumThumbnails.clear();
    super.dispose();
  }

  /// Called when the system puts the app in the background or
  /// returns the app to the foreground.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {}

  Color? _appBarBackgroundColor;
  Color? _appBarTextColor;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Use theme based AppBar colors if config values are not defined.
    // The logic is based on same approach that is used in AppBar SDK source.
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final AppBarTheme appBarTheme = AppBarTheme.of(context);
    _appBarBackgroundColor = _configs.appBarBackgroundColor ??
        appBarTheme.backgroundColor ??
        (colorScheme.brightness == Brightness.dark
            ? colorScheme.surface
            : colorScheme.primary);
    _appBarTextColor = _configs.appBarTextColor ??
        appBarTheme.foregroundColor ??
        (colorScheme.brightness == Brightness.dark
            ? colorScheme.onSurface
            : colorScheme.onPrimary);

    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: _configs.backgroundColor,
        appBar: AppBar(
          title: _buildAppBarTitle(
            context,
            _appBarBackgroundColor!,
            _appBarTextColor!,
          ),
          elevation: 0,
          backgroundColor: _appBarBackgroundColor,
          foregroundColor: _appBarTextColor,
          centerTitle: true,
        ),
        body: SafeArea(child: _buildBodyView(context)));
  }

  /// Build app bar title
  Widget _buildAppBarTitle(
    BuildContext context,
    Color appBarBackgroundColor,
    Color appBarTextColor,
  ) {
    return Text(_configs.appBarTitle,
        style: TextStyle(color: _configs.appBarTextColor, fontSize: 16));
    // return GestureDetector(
    //     onTap: () {
    //       Navigator.of(context, rootNavigator: true)
    //           .push<void>(PageRouteBuilder(
    //               pageBuilder: (context, animation, __) {
    //                 return Scaffold(
    //                     appBar: AppBar(
    //                         title:
    //                             _buildAlbumSelectButton(context, isPop: true),
    //                         backgroundColor: appBarBackgroundColor,
    //                         foregroundColor: appBarTextColor,
    //                         centerTitle: false),
    //                     body: Material(
    //                         color: Colors.black,
    //                         child: SafeArea(
    //                           child: _buildAlbumList(_albums, context, (val) {
    //                             Navigator.of(context).pop();
    //                             setState(() {
    //                               _currentAlbum = val;
    //                             });
    //                             _currentAlbumKey.currentState
    //                                 ?.updateStateFromExternal(
    //                                     album: _currentAlbum);
    //                           }),
    //                         )));
    //               },
    //               fullscreenDialog: true));
    //     },
    //     child: _buildAlbumSelectButton(context));
  }

  /// Build album select button.
  Widget _buildAlbumSelectButton(BuildContext context,
      {bool isPop = false, bool isCameraMode = false}) {
    if (isCameraMode) {
      return Text(_configs.textCameraTitle,
          style: TextStyle(color: _configs.appBarTextColor, fontSize: 16));
    }

    final size = MediaQuery.of(context).size;
    final container = Container(
      // decoration: BoxDecoration(
      //     borderRadius: BorderRadius.circular(10),
      //     color: Colors.black.withOpacity(0.1)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: size.width / 2.5),
              child: Text(_currentAlbum?.name ?? "",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: _configs.appBarTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(isPop ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: Colors.grey, size: 24),
            )
          ],
        ));

    return isPop
        ? GestureDetector(
      child: container,
      onTap: () async {
        Navigator.of(context).pop();
      },
    )
        : container;
  }

  /// Build album thumbnail preview.
  Future<List<Uint8List?>> _buildAlbumThumbnails() async {
    LogUtils.log("[_buildAlbumThumbnails] start");

    if (_albums.isNotEmpty && _albumThumbnails.isEmpty) {
      final List<Uint8List?> ret = [];
      for (final a in _albums) {
        final f = await (await a.getAssetListRange(start: 0, end: 1))
            .first
            .thumbDataWithSize(
                _configs.albumThumbWidth, _configs.albumThumbHeight);
        ret.add(f);
      }
      _albumThumbnails = ret;
    }

    return _albumThumbnails;
  }

  /// Build album list screen.
  Widget _buildAlbumList(List<AssetPathEntity> albums, BuildContext context,
      Function(AssetPathEntity newValue) callback) {
    LogUtils.log("[_buildAlbumList] start");

    return FutureBuilder(
      future: _buildAlbumThumbnails(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Container(
            color: _configs.backgroundColor,
            child: ListView.builder(
                itemCount: _albums.length,
                itemBuilder: (context, i) {
                  final album = _albums[i];
                  final thumbnail = _albumThumbnails[i]!;
                  return InkWell(
                    child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: SizedBox(
                              width: 80,
                              height: 80,
                              child: Image.memory(thumbnail, fit: BoxFit.cover)),
                        ),
                        title: Text(album.name,
                            style: TextStyle(color: _configs.appBarTextColor)),
                        subtitle: Text(album.assetCount.toString(),
                            style: TextStyle(color: _configs.appBarTextColor)),
                        onTap: () async {
                          callback.call(album);
                        }),
                  );
                }),
          );
        } else {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        }
      },
    );
  }

  /// Build body view.
  Widget _buildBodyView(BuildContext context) {
    LogUtils.log("[_buildBodyView] start");
    final size = MediaQuery.of(context).size;

    return Stack(children: [
      SizedBox(height: size.height, width: size.width),
      _isGalleryPermissionOK
          ? _buildAlbumPreview(context)
          : _builGalleryRequestPermissionView(context),
    ]);
  }

  /// Build camera request permission view
  Widget _builGalleryRequestPermissionView(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomHeight = (maxCount == 1)
        ? (kBottomControlPanelHeight - 40)
        : kBottomControlPanelHeight;
    return SizedBox(
        width: size.width,
        height: size.height - bottomHeight,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey.shade400,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
            ),
            onPressed: _initVideoGallery,
            child: Text(_configs.textRequestPermission,
                style: const TextStyle(color: Colors.black)),
          ),
          Text(_configs.textRequestGalleryPermission,
              style: const TextStyle(color: Colors.grey))
        ]));
  }

  /// Build album preview widget.
  Widget _buildAlbumPreview(BuildContext context) {
    LogUtils.log("[_buildAlbumPreview] start");

    final bottomHeight = (maxCount == 1)
        ? (kBottomControlPanelHeight - 40)
        : kBottomControlPanelHeight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAlbumSelectionAndCameraButton(),
        SizedBox(
          height: MediaQuery.of(context).size.height - bottomHeight,
          child: _currentAlbum != null
              ? VideoAlbum(
              key: _currentAlbumKey,
              gridCount: _configs.albumGridCount,
              maxCount: maxCount,
              album: _currentAlbum!,
              onImageSelected: (image) async {
                LogUtils.log("[_buildAlbumPreview] onImageSelected start");
              })
              : const SizedBox(),
        )
      ],
    );
  }

  Widget _buildAlbumSelectionAndCameraButton() {
    return Row(
      children: [
        GestureDetector(
            onTap: () {
              Navigator.of(context, rootNavigator: true)
                  .push<void>(PageRouteBuilder(
                  pageBuilder: (context, animation, __) {
                    return Scaffold(
                        appBar: AppBar(
                            title: _buildAlbumSelectButton(context,
                                isPop: true),
                            backgroundColor: _appBarBackgroundColor!,
                            foregroundColor: _appBarTextColor!,
                            elevation: 0,
                            centerTitle: false),
                        body: Material(
                            color: Colors.black,
                            child: SafeArea(
                              child: _buildAlbumList(_albums, context,
                                      (val) {
                                    Navigator.of(context).pop();
                                    setState(() {
                                      _currentAlbum = val;
                                    });
                                    _currentAlbumKey.currentState
                                        ?.updateStateFromExternal(
                                        album: _currentAlbum);
                                  }),
                            )));
                  },
                  fullscreenDialog: true));
            },
            child: _buildAlbumSelectButton(context)),
        Spacer(),
        if (widget.cameraWidget != null) widget.cameraWidget!,
        SizedBox(width: 16)
      ],
    );
  }


}
