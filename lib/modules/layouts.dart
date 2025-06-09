import 'package:flutter/material.dart';
import '../widgets/dynamic_widget.dart';

class LayoutBuilderModule {
  static Widget build(Map<String, dynamic> json) {
    final String type = json['type'] ?? '';
    final List<dynamic> children = json['children'] ?? [];

    List<Widget> builtChildren = children
        .map((child) => DynamicWidgetBuilder.build(child))
        .toList();

    switch (type) {
      case 'Column':
        return Column(
          crossAxisAlignment: _parseCrossAxis(json['crossAxis']),
          mainAxisAlignment: _parseMainAxis(json['mainAxis']),
          children: builtChildren,
        );

      case 'Row':
        return Row(
          crossAxisAlignment: _parseCrossAxis(json['crossAxis']),
          mainAxisAlignment: _parseMainAxis(json['mainAxis']),
          children: builtChildren,
        );

      case 'Container':
        return Container(
          margin: _parseEdgeInsets(json['margin']),
          padding: _parseEdgeInsets(json['padding']),
          color: _parseColor(json['color']),
          width: (json['width'] ?? 0).toDouble(),
          height: (json['height'] ?? 0).toDouble(),
          child: children.isNotEmpty ? builtChildren.first : null,
        );

      case 'ListView':
        return ListView(
          children: builtChildren,
          padding: _parseEdgeInsets(json['padding']),
        );

      case 'Stack':
        return Stack(
          alignment: Alignment.center,
          children: builtChildren,
        );

      case 'Expanded':
        return Expanded(
          flex: json['flex'] ?? 1,
          child: builtChildren.isNotEmpty ? builtChildren.first : const SizedBox.shrink(),
        );

      case 'SizedBox':
        return SizedBox(
          width: (json['width'] ?? 0).toDouble(),
          height: (json['height'] ?? 0).toDouble(),
          child: builtChildren.isNotEmpty ? builtChildren.first : null,
        );

      case 'Center':
        return Center(
          child: builtChildren.isNotEmpty ? builtChildren.first : null,
        );

      default:
        return const SizedBox.shrink();
    }
  }

  static CrossAxisAlignment _parseCrossAxis(String? value) {
    switch (value) {
      case 'center':
        return CrossAxisAlignment.center;
      case 'end':
        return CrossAxisAlignment.end;
      case 'stretch':
        return CrossAxisAlignment.stretch;
      case 'baseline':
        return CrossAxisAlignment.baseline;
      default:
        return CrossAxisAlignment.start;
    }
  }

  static MainAxisAlignment _parseMainAxis(String? value) {
    switch (value) {
      case 'center':
        return MainAxisAlignment.center;
      case 'end':
        return MainAxisAlignment.end;
      case 'spaceBetween':
        return MainAxisAlignment.spaceBetween;
      case 'spaceAround':
        return MainAxisAlignment.spaceAround;
      case 'spaceEvenly':
        return MainAxisAlignment.spaceEvenly;
      default:
        return MainAxisAlignment.start;
    }
  }

  static EdgeInsets _parseEdgeInsets(dynamic value) {
    if (value is Map) {
      return EdgeInsets.only(
        left: (value['left'] ?? 0).toDouble(),
        top: (value['top'] ?? 0).toDouble(),
        right: (value['right'] ?? 0).toDouble(),
        bottom: (value['bottom'] ?? 0).toDouble(),
      );
    }
    return EdgeInsets.zero;
  }

  static Color? _parseColor(dynamic value) {
    if (value is String) {
      try {
        return Color(int.parse(value.replaceFirst('#', '0xff')));
      } catch (_) {}
    }
    return null;
  }
}
