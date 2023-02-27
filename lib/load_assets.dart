import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;

//import 'package:flame_audio/audio_pool.dart';

// load image assets
loadImage() async {
  List<dynamic> images = [];
  List<String> _fileNames = [
    'image_bg.png',
    'image_group.png',
    'image_explosion048.png',
    'image_replay.png',
    'image_bump_boom.png',
    'image_start_button.png',
  ];

  for (int i = 0; i < _fileNames.length; i++) {
    ByteData _byteData =
        await rootBundle.load('assets/images/' + _fileNames[i]);
    Uint8List _bytes = Uint8List.view(_byteData.buffer);
    ui.Codec _codec = await ui.instantiateImageCodec(_bytes);
    ui.Image _image = (await _codec.getNextFrame()).image;
    images.add(_image);
  }

  return images;
}
