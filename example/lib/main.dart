import 'dart:io';

import 'package:advance_image_picker/advance_image_picker.dart';
import 'package:advance_image_picker/configs/video_picker_configs.dart';
import 'package:advance_image_picker/widgets/picker/video_picker.dart';
import 'package:example/UiColors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// We don't care about missing API docs in the example app.
// ignore_for_file: public_member_api_docs

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return ErrorWidget(details.exception);
  };
  runApp(const MyApp());
}

/// Example app.
class MyApp extends StatelessWidget {
  /// Example app constructor.
  const MyApp({final Key? key}) : super(key: key);

  setupImagePicker() {
    // Setup image picker configs
    final configs = ImagePickerConfigs();
    // AppBar text color
    configs.primaryColor = UiColors.primaryColor;
    configs.appBarTitle = 'Create Post';
    configs.appBarTextColor = UiColors.black;
    configs.appBarBackgroundColor = UiColors.white;
    configs.backgroundColor = UiColors.white;
    configs.bottomPanelColor = UiColors.white;
    configs.appBarDoneButtonColor = UiColors.primaryColor;
    configs.filterFeatureEnabled = true;
    configs.showFlashMode = false;
    configs.iconClose = Icons.close_outlined;
    configs.iconCamera = Icons.camera_outlined;
    configs.bottomPanelIconColor = UiColors.black;
    configs.bottomPanelIconColorInFullscreen = UiColors.white;
    configs.albumCameraSwitchBackgroundColor = UiColors.white;
    configs.albumCameraSwitchThumbColor = UiColors.primaryColor;
    configs.albumGridCount = 3;

    // Disable select images from album
    // configs.albumPickerModeEnabled = false;
    // Only use front camera for capturing
    // configs.cameraLensDirection = 0;
    // Translate function
    // configs.translateFunc = (name, value) => Intl.message(value, name: name);
    configs.translateFunc = (name, value) {
     if(name == "image_picker_select_images_title"){
        return "Selected images count";
      } else if(name == "image_picker_select_images_guide"){
        return "You can drag images for sorting list...";
      } else if(name == "image_picker_camera_title"){
        return "Camera";
      } else if(name == "image_picker_album_title"){
        return "Album";
      } else if(name == "image_picker_preview_title"){
        return "Preview";
      } else if(name == "image_picker_confirm"){
        return "Confirm";
      } else if(name == "image_picker_exit_without_selecting"){
        return "Do you want to exit without selecting images?";
      } else if(name == "image_picker_confirm_delete"){
        return "Do you want to delete this image?";
      } else if(name == "image_picker_confirm_reset_changes"){
        return "Do you want to clear all changes for this image?";
      } else if(name == "yes"){
        return "Yes";
      } else if(name == "no"){
        return "No";
      } else if(name == "save"){
        return "Save";
      } else if(name == "clear"){
        return "Clear";
      } else if(name == "image_picker_edit_text"){
        return "Edit text";
      } else if(name == "image_picker_no_images"){
        return "No images ...";
      } else if(name == "image_picker_image_crop_title"){
        return "Image crop";
      } else if(name == "image_picker_image_filter_title"){
        return "Image filter";
      } else if(name == "image_picker_image_edit_title"){
        return "Image edit";
      } else if(name == "image_picker_image_sticker_title"){
        return "Image sticker";
      } else if(name == "image_picker_image_addtext_title"){
        return "Image add text";
      } else if(name == "image_picker_select_button_title"){
        return "Next";
      } else if(name == "image_picker_image_sticker_guide"){
        return "You can click on sticker icons to scale it or double click to "
            "remove it from image";
      } else if(name == "image_picker_exposure_title"){
        return "Exposure";
      } else if(name == "image_picker_exposure_locked_title"){
        return "Locked";
      } else if(name == "image_picker_exposure_auto_title"){
        return "auto";
      } else if(name == "image_picker_image_edit_contrast"){
        return "Contrast";
      } else if(name == "image_picker_image_edit_brightness"){
        return "Brightness";
      } else if(name == "image_picker_image_edit_saturation"){
        return "Saturation";
      } else if(name == "image_picker_ocr"){
        return "OCR";
      } else if(name == "image_picker_request_permission"){
        return "Request Permission";
      } else if(name == "image_picker_request_camera_permission"){
        return "You need allow camera permission.";
      } else if(name == "image_picker_request_gallery_permission"){
        return "You need allow photo gallery permission.";
      }

      return Intl.message(value, name: name);
    };
    // Disable edit function, then add other edit control instead
    configs.adjustFeatureEnabled = true;
    configs.stickerFeatureEnabled = false;
  }

  setupVideoPicker() {
    // Setup image picker configs
    final configs = VideoPickerConfigs();
    // AppBar text color
    configs.primaryColor = UiColors.primaryColor;
    configs.appBarTitle = 'Create Post';
    configs.appBarTextColor = UiColors.black;
    configs.appBarBackgroundColor = UiColors.white;
    configs.backgroundColor = UiColors.white;
    configs.bottomPanelColor = UiColors.white;
    configs.appBarDoneButtonColor = UiColors.primaryColor;
    configs.filterFeatureEnabled = true;
    configs.showFlashMode = false;
    configs.iconClose = Icons.close_outlined;
    configs.iconCamera = Icons.camera_outlined;
    configs.bottomPanelIconColor = UiColors.black;
    configs.bottomPanelIconColorInFullscreen = UiColors.white;
    configs.albumCameraSwitchBackgroundColor = UiColors.white;
    configs.albumCameraSwitchThumbColor = UiColors.primaryColor;
    configs.albumGridCount = 3;

    // Disable select images from album
    // configs.albumPickerModeEnabled = false;
    // Only use front camera for capturing
    // configs.cameraLensDirection = 0;
    // Translate function
    // configs.translateFunc = (name, value) => Intl.message(value, name: name);
    configs.translateFunc = (name, value) {
      if(name == "image_picker_select_images_title"){
        return "Selected images count";
      } else if(name == "image_picker_select_images_guide"){
        return "You can drag images for sorting list...";
      } else if(name == "image_picker_camera_title"){
        return "Camera";
      } else if(name == "image_picker_album_title"){
        return "Album";
      } else if(name == "image_picker_preview_title"){
        return "Preview";
      } else if(name == "image_picker_confirm"){
        return "Confirm";
      } else if(name == "image_picker_exit_without_selecting"){
        return "Do you want to exit without selecting images?";
      } else if(name == "image_picker_confirm_delete"){
        return "Do you want to delete this image?";
      } else if(name == "image_picker_confirm_reset_changes"){
        return "Do you want to clear all changes for this image?";
      } else if(name == "yes"){
        return "Yes";
      } else if(name == "no"){
        return "No";
      } else if(name == "save"){
        return "Save";
      } else if(name == "clear"){
        return "Clear";
      } else if(name == "image_picker_edit_text"){
        return "Edit text";
      } else if(name == "image_picker_no_images"){
        return "No images ...";
      } else if(name == "image_picker_image_crop_title"){
        return "Image crop";
      } else if(name == "image_picker_image_filter_title"){
        return "Image filter";
      } else if(name == "image_picker_image_edit_title"){
        return "Image edit";
      } else if(name == "image_picker_image_sticker_title"){
        return "Image sticker";
      } else if(name == "image_picker_image_addtext_title"){
        return "Image add text";
      } else if(name == "image_picker_select_button_title"){
        return "Next";
      } else if(name == "image_picker_image_sticker_guide"){
        return "You can click on sticker icons to scale it or double click to "
            "remove it from image";
      } else if(name == "image_picker_exposure_title"){
        return "Exposure";
      } else if(name == "image_picker_exposure_locked_title"){
        return "Locked";
      } else if(name == "image_picker_exposure_auto_title"){
        return "auto";
      } else if(name == "image_picker_image_edit_contrast"){
        return "Contrast";
      } else if(name == "image_picker_image_edit_brightness"){
        return "Brightness";
      } else if(name == "image_picker_image_edit_saturation"){
        return "Saturation";
      } else if(name == "image_picker_ocr"){
        return "OCR";
      } else if(name == "image_picker_request_permission"){
        return "Request Permission";
      } else if(name == "image_picker_request_camera_permission"){
        return "You need allow camera permission.";
      } else if(name == "image_picker_request_gallery_permission"){
        return "You need allow photo gallery permission.";
      }

      return Intl.message(value, name: name);
    };
    // Disable edit function, then add other edit control instead
    configs.adjustFeatureEnabled = true;
    configs.stickerFeatureEnabled = false;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Setup image picker config
    setupImagePicker();
    setupVideoPicker();

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'advance_image_picker Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<ImageObject> _imgObjs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          children: <Widget>[
            GridView.builder(
                shrinkWrap: true,
                itemCount: _imgObjs.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, mainAxisSpacing: 2, crossAxisSpacing: 2),
                itemBuilder: (BuildContext context, int index) {
                  final image = _imgObjs[index];
                  return Padding(
                    padding: const EdgeInsets.all(2),
                    child: Image.file(File(image.modifiedPath),
                        height: 80, fit: BoxFit.cover),
                  );
                })
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Get max 5 images
          final List<ImageObject>? objects = await Navigator.of(context)
              .push(PageRouteBuilder(pageBuilder: (context, animation, __) {
            return ImagePickerUi(maxCount: 10, isCaptureFirst: false, isFullscreenImage: true,);
          }));
          print(objects);
          if ((objects?.length ?? 0) > 0) {
            setState(() {
              _imgObjs = objects!;
            });
          }

          // var result = await Navigator.of(context)
          //     .push(PageRouteBuilder(pageBuilder: (context, animation, __) => VideoPicker(cameraWidget: Icon(Icons.camera_alt_outlined),)));
          // if(result != null) {
          //   debugPrint('result ---> $result');
          // }
        },
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
