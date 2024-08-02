import 'dart:developer';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';

enum ImageType {
  tempImg,
  assetImg,
  assetSvg,
  network,
  fileAsync,
  file,
  networkSvg,
  widget,
  icon
}

dynamic _errorImage;

void setImageMultiTypeErrorImage(dynamic url) => _errorImage = url;

Widget get getErrorWidget {
  if (_errorImage == null ||
      _errorImage.toString().isEmpty ||
      _errorImage.toString().startsWith('http')) {
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.warning),
    );
  }
  return ImageMultiType(url: _errorImage, defaultTempImage: true);
}

class ImageMultiType extends StatefulWidget {
  const ImageMultiType({
    Key? key,
    required this.url,
    this.height,
    this.width,
    this.fit,
    this.color,
    this.defaultTempImage = false,
  }) : super(key: key);

  final dynamic url;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final Color? color;
  final bool defaultTempImage;

  @override
  State<ImageMultiType> createState() => ImageMultiTypeState();

  static ImageType initialType(dynamic url) {
    var type = ImageType.tempImg;

    if (url is Future<Uint8List>) {
      type = ImageType.fileAsync;
    }

    if (url is Uint8List) {
      type = ImageType.file;
    }

    if (url is IconData) {
      type = ImageType.icon;
    }

    if (url is Widget) {
      type = ImageType.widget;
    }

    if (url is String) {
      if (url.isEmpty) {
        type = ImageType.tempImg;
      } else if (url.startsWith('http') && url.endsWith('svg')) {
        type = ImageType.networkSvg;
      } else if (url.startsWith('http')) {
        type = ImageType.network;
      } else if (url.contains('svg')) {
        type = ImageType.assetSvg;
      } else if (url.contains('assets/')) {
        type = ImageType.assetImg;
      } else {
        type = ImageType.tempImg;
      }
    }

    return type;
  }
}

class ImageMultiTypeState extends State<ImageMultiType> {
  ImageType get getImageType {
    return ImageMultiType.initialType(widget.url);
  }

  Widget get getWidget {
    switch (getImageType) {
      case ImageType.widget:
        return widget.url;

      case ImageType.assetImg:
        return Image.asset(
          widget.url,
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
          color: widget.color,
          fit: widget.fit ?? BoxFit.contain,
        );
      case ImageType.network:
        return CachedNetworkImage(
          imageUrl: widget.url,
          color: widget.color,
          filterQuality: FilterQuality.low,
          fit: widget.fit ?? BoxFit.cover,
          // progressIndicatorBuilder: (context, url, progress) {
          //   return ClipRRect(
          //     borderRadius: BorderRadius.circular(12.0),
          //     clipBehavior: Clip.hardEdge,
          //     child: Container(
          //       color: Colors.blueGrey,
          //       height: widget.height,
          //       width: widget.width,
          //     ),
          //   );
          // },
          alignment: Alignment.center,
          errorWidget: (context, url, error) {
            log('ERROR IMAGE MULTI TYPE NETWORK IMAGE: ', name: url, error: error);
            return getErrorWidget;
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
          color: widget.color,
          fit: widget.fit ?? BoxFit.contain,
        );
      case ImageType.tempImg:
        log('ERROR IMAGE MULTI TYPE TEMP IMAGE: ');
        return widget.defaultTempImage
            ? Container(
                color: Colors.grey[300],
                child: const Icon(Icons.warning),
              )
            : getErrorWidget;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: getWidget,
    );
  }
}
