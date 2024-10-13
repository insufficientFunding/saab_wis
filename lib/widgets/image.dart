import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:saab_wis/extensions/context.dart';
import 'package:saab_wis/theme/theme.dart';
import 'package:saab_wis/widgets/zoom_widget.dart';
import 'package:vector_graphics/vector_graphics.dart';

class WisImage extends StatefulWidget {
  const WisImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height = 400,
  });

  final String imagePath;
  final double? width;
  final double? height;

  @override
  State<WisImage> createState() => _WisImageState();
}

class _WisImageState extends State<WisImage> {
  late final String imagePath;
  late File image;
  late Future<Uint8List> imageBytes;

  @override
  void initState() {
    super.initState();

    imagePath = widget.imagePath.startsWith('wisimg://')
        ? context.getImagePath(widget.imagePath)
        : 'assets/${widget.imagePath}.svg';

    image = File(imagePath);
    imageBytes = image.readAsBytes();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: imageBytes,
      builder: (context, bytes) {
        if (bytes.data == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return Padding(
          padding: const EdgeInsets.all(12),
          child: ZoomWidget(
            heroAnimationTag: widget.imagePath,
            width: widget.width,
            height: widget.height,
            invertColors: context.watchColorScheme.brightness == Brightness.dark,
            shadows: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
              ),
            ],
            zoomWidget: SvgPicture(
              VectorBytesLoader(bytes.requireData),
              colorFilter: ColorFilter.mode(
                AppTheme.backgroundColorsLight[1],
                BlendMode.darken,
              ),
            ),
          ),
        );
      },
    );
  }
}

class VectorBytesLoader extends BytesLoader {
  const VectorBytesLoader(this.bytes);

  final Uint8List bytes;

  @override
  Future<ByteData> loadBytes(BuildContext? context) async {
    return bytes.buffer.asByteData();
  }
}
