import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../models/image_object.dart';
import '../../utils/image_utils.dart';
import '../../utils/log_utils.dart';

/// MediaAlbum or photo album widget.
class MediaAlbum extends StatefulWidget {
  /// Default constructor for photo album widget.
  const MediaAlbum(
      {Key? key,
      this.gridCount = 4,
      this.maxCount,
      required this.album,
      this.maxWidth = 1280,
      this.maxHeight = 720,
      this.albumThumbWidth = 200,
      this.albumThumbHeight = 200,
      this.selectedImages,
      this.preProcessing,
      this.onImageSelected,
      this.checkBoxActiveColor, this.primaryColor = Colors.grey})
      : super(key: key);

  /// Grid count.
  final int gridCount;

  /// Max selecting count.
  final int? maxCount;

  /// Max image width.
  final int maxWidth;

  /// Max image height.
  final int maxHeight;

  /// Album thumbnail width.
  final int albumThumbWidth;

  /// Album thumbnail height.
  final int albumThumbHeight;

  /// Album object.
  final AssetPathEntity album;

  /// Selected image objects.
  final List<ImageObject>? selectedImages;

  /// Pre-processing function for image object.
  final Future<File> Function(String)? preProcessing;

  /// Image selected event.
  final Function(ImageObject)? onImageSelected;

  /// Image selected checkbox color.
  final Color? checkBoxActiveColor;

  final Color primaryColor;

  @override
  MediaAlbumState createState() => MediaAlbumState();
}

/// State holding class of the MediaAlbum.
class MediaAlbumState extends State<MediaAlbum> {
  /// Current selected images
  List<ImageObject> _selectedImages = [];

  /// Asset lists for this album.
  List<AssetEntity> _assets = [];

  /// Thumbnail cache.
  final Map<String, Uint8List?> _thumbnailCache = {};

  /// Loading asset.
  String _loadingAsset = "";

  /// Album object.
  late AssetPathEntity _album;

  @override
  void initState() {
    super.initState();
    _selectedImages.addAll(widget.selectedImages!);
    _album = widget.album;
    _fetchMedia(_album);
  }

  @override
  void dispose() {
    _assets.clear();
    _thumbnailCache.clear();
    super.dispose();
  }

  /// Update private state by function call from external function.
  void updateStateFromExternal(
      {AssetPathEntity? album, List<ImageObject>? selectedImages}) {
    if (selectedImages != null) {
      _selectedImages = [...selectedImages];
    }
    if (album != null) {
      _assets.clear();
      _thumbnailCache.clear();
      _album = album;
      _fetchMedia(_album);
    }
  }

  /// Get thumbnail bytes for an asset.
  Future<Uint8List?> _getAssetThumbnail(AssetEntity asset) async {
    if (_thumbnailCache.containsKey(asset.id)) {
      return _thumbnailCache[asset.id];
    } else {
      final data = await asset.thumbnailDataWithSize(
          ThumbnailSize(widget.albumThumbWidth, widget.albumThumbHeight),
          quality: 90);
      _thumbnailCache[asset.id] = data;
      return data;
    }
  }

  /// Fetch media/assets for [currentAlbum].
  Future<void> _fetchMedia(AssetPathEntity currentAlbum) async {
    LogUtils.log("[_fetchMedia] start");

    if (_assets.isEmpty) {
      final ret = await currentAlbum.getAssetListRange(start: 0, end: 5000);

      final List<AssetEntity> assets = [];
      for (final asset in ret) {
        if (asset.type == AssetType.image && asset.mimeType != 'application/octet-stream') assets.add(asset);
      }

      setState(() {
        _assets = assets;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gridview = GridView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        itemCount: _assets.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.gridCount,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8),
        itemBuilder: (BuildContext context, int index) {
          final asset = _assets[index];
          final idx = _selectedImages.indexWhere(
              (element) => ImageUtils.isTheSameAsset(asset, element));
          final isMaxCount = _selectedImages.length >= widget.maxCount!;
          final isSelectable = widget.maxCount == 1 ? true : (idx >= 0) || !isMaxCount;
          final data = (_thumbnailCache.containsKey(asset.id))
              ? _thumbnailCache[asset.id]
              : null;

          return GestureDetector(
            onTap: (isSelectable && _loadingAsset.isEmpty)
                ? () async {
                    LogUtils.log("[_MediaAlbumState.build] onTap start");

                    setState(() {
                      _loadingAsset = asset.id;
                    });

                    var file = await asset.originFile;
                    if (idx < 0) {
                      file =
                          await widget.preProcessing?.call(file!.path) ?? file;
                    }
                    final image = ImageObject(
                        originalPath: file!.path,
                        modifiedPath: file.path,
                        assetId: asset.id);

                    setState(() {
                      if (widget.maxCount == 1) {
                        _selectedImages.clear();
                      }

                      if (idx >= 0) {
                        _selectedImages.removeAt(idx);
                      } else {
                        _selectedImages.add(image);
                      }

                      _loadingAsset = "";
                    });

                    widget.onImageSelected?.call(image);
                  }
                : null,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Stack(fit: StackFit.passthrough, children: [
                Positioned.fill(
                    child: (data == null)
                        ? FutureBuilder(
                            future: _getAssetThumbnail(asset),
                            builder: (BuildContext context, snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.done &&
                                  snapshot.data != null) {
                                return Image.memory(
                                  snapshot.data! as Uint8List,
                                  fit: BoxFit.cover,
                                );
                              }
                              return Center(
                                  child: CircularProgressIndicator(strokeWidth: 2, color: widget.primaryColor,));
                            },
                          )
                        : Image.memory(data,
                            fit: BoxFit.cover, gaplessPlayback: true)),
                if (widget.maxCount != 1) ...[
                  if (!isSelectable)
                    Positioned.fill(
                        child: Container(
                            color: Colors.grey.shade200.withOpacity(0.8))),
                  if (_loadingAsset == asset.id)
                    Positioned.fill(child: CircularProgressIndicator(strokeWidth: 2, color: widget.primaryColor,)),
                  if (idx >= 0)
                    Positioned(
                        top: 10,
                        right: 10,
                        child: Icon(Icons.check_circle,
                            color:
                                widget.checkBoxActiveColor ?? Colors.pinkAccent,
                            size: 24))
                ]
              ]),
            ),
          );
        });

    return gridview;
  }
}
