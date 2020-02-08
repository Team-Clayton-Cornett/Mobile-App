import 'package:flutter/material.dart';

class ScrollableBottomListSheet extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  ScrollableBottomListSheet({this.itemCount = -1, @required this.itemBuilder});

  @override
  _ScrollableBottomListSheetState createState() =>
      _ScrollableBottomListSheetState();
}

class _ScrollableBottomListSheetState extends State<ScrollableBottomListSheet> {
  final double _expandedSheetSize = 1.0;
  final double _collapsedSheetSize = 0.1;
  final double _initialSheetSize = 0.3;

  bool _expanded = false;

  // TODO: Handle snapping sheet into place either expanded or down
  bool handleScrollNotification(DraggableScrollableNotification notification) {
    if (!_expanded && notification.extent == 1.0) {
      setState(() {
        _expanded = true;
      });
    } else if (_expanded && notification.extent < 1.0) {
      setState(() {
        _expanded = false;
      });
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    BorderRadius sheetRadius = BorderRadius.only(
      topRight: Radius.circular(_expanded ? 0.0 : 15.0),
      topLeft: Radius.circular(_expanded ? 0.0 : 15.0),
      bottomLeft: Radius.circular(0.0),
      bottomRight: Radius.circular(0.0),
    );

    return NotificationListener<DraggableScrollableNotification>(
        onNotification: handleScrollNotification,
        child: DraggableScrollableSheet(
          initialChildSize: _initialSheetSize,
          minChildSize: _collapsedSheetSize,
          maxChildSize: _expandedSheetSize,
          builder: (BuildContext context, ScrollController scrollController) {
            return ClipRRect(
                borderRadius: sheetRadius,
                child: Material(
                    elevation: 4.0,
                    color: Colors.white,
                    child: Container(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: widget.itemCount == -1 ? null : widget.itemCount,
                        itemBuilder: widget.itemBuilder,
                      ),
                    )
                )
            );
          },
        )
    );
  }
}
