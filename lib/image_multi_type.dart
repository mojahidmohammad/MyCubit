import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

enum ImageType { tempImg, assetImg, assetSvg, network, fileAsync, file, networkSvg, icon }

Widget? _errorImage;

void setImageMultiTypeErrorImage(Widget url) => _errorImage = url;

class ImageMultiType extends StatefulWidget {
  const ImageMultiType({
    Key? key,
    required this.url,
    this.height,
    this.width,
    this.fit,
    this.color,
  }) : super(key: key);

  final dynamic url;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final Color? color;

  @override
  State<ImageMultiType> createState() => ImageMultiTypeState();
}

class ImageMultiTypeState extends State<ImageMultiType> {
  var type = ImageType.tempImg;

  void initialType() {
    if (widget.url is Future<Uint8List>) {
      type = ImageType.fileAsync;
      return;
    }
    if (widget.url is Uint8List) {
      type = ImageType.file;
      return;
    }
    if (widget.url is IconData) {
      type = ImageType.icon;
      return;
    }

    if (widget.url is String) {
      if (widget.url.isEmpty) {
        type = ImageType.tempImg;
      } else if (widget.url.startsWith('http') && widget.url.endsWith('svg')) {
        type = ImageType.networkSvg;
      } else if (widget.url.startsWith('http')) {
        type = ImageType.network;
      } else if (widget.url.contains('svg')) {
        type = ImageType.assetSvg;
      } else {
        type = ImageType.assetImg;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    initialType();
    switch (type) {
      case ImageType.assetImg:
        return Image.asset(
          widget.url,
          height: widget.height,
          width: widget.width,
          color: widget.color,
          fit: widget.fit,
        );

      case ImageType.icon:
        return Icon(
          widget.url,
          size: widget.height ?? widget.width,
          color: widget.color,
        );
      case ImageType.assetSvg:
        return SvgPicture.asset(
          widget.url,
          height: widget.height,
          width: widget.width,
          color: widget.color,
          fit: widget.fit ?? BoxFit.contain,
        );
      case ImageType.network:
        return CachedNetworkImage(
          imageUrl: widget.url,
          height: widget.height,
          width: widget.width,
          color: widget.color,
          filterQuality: FilterQuality.low,
          fit: widget.fit ?? BoxFit.cover,
          progressIndicatorBuilder: (context, url, progress) {
            return Shimmer(
              duration: const Duration(seconds: 2),
              color: Colors.grey,
              direction: const ShimmerDirection.fromLTRB(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                clipBehavior: Clip.hardEdge,
                child: Container(
                  color: Colors.blueGrey,
                  height: widget.height,
                  width: widget.width,
                ),
              ),
            );
          },
          alignment: Alignment.center,
          errorWidget: (context, url, error) {
            return _errorImage ??
                Container(
                  height: widget.height,
                  width: widget.width,
                  color: Colors.red.withOpacity(0.6),
                  child: const Icon(Icons.warning),
                );
          },
        );
      case ImageType.fileAsync:
        var byte = (widget.url as Future<Uint8List>);
        return FutureBuilder(
          future: byte,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Image.memory(
                snapshot.requireData,
                fit: widget.fit,
              );
            } else {
              return const SizedBox();
            }
          },
        );
      case ImageType.file:
        var byte = (widget.url as Uint8List);
        return Image.memory(
          byte,
          fit: widget.fit,
        );
      case ImageType.networkSvg:
        return SvgPicture.network(
          widget.url,
          height: widget.height,
          width: widget.width,
          color: widget.color,
          fit: widget.fit ?? BoxFit.contain,
        );
      case ImageType.tempImg:
        return _errorImage ??
            Container(
              height: widget.height,
              width: widget.width,
              color: Colors.red.withOpacity(0.6),
              child: const Icon(Icons.warning),
            );
    }
  }
}
