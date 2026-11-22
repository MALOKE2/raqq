import 'package:flutter/material.dart';

/// طرفية جانبية للتنقل السريع.
/// ملاحظة: تُوضع داخل Positioned من قِبل المستدعِي (لا تُعيد Positioned بنفسها)،
/// حتى لا تتحول إلى طبقة تغطي بقية الشاشة وتمنع الضغط.
class QuickScrubber extends StatefulWidget {
  final int count;
  final String Function(int index) label;
  final ValueChanged<int> onScrub;
  final Color color;

  const QuickScrubber({
    super.key,
    required this.count,
    required this.label,
    required this.onScrub,
    this.color = Colors.teal,
  });

  @override
  State<QuickScrubber> createState() => _QuickScrubberState();
}

class _QuickScrubberState extends State<QuickScrubber> {
  double? _dragY;
  double _height = 1;
  int _current = 0;

  void _update(double dy) {
    if (widget.count <= 0) return;
    final f = (dy / _height).clamp(0.0, 1.0);
    final idx = (f * (widget.count - 1)).round().clamp(0, widget.count - 1);
    setState(() {
      _dragY = dy;
      _current = idx;
    });
    widget.onScrub(idx);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _height = constraints.maxHeight;
        if (widget.count <= 0) return const SizedBox(width: 38);
        final safeH = _height > 24 ? _height - 24 : _height;
        final thumbTop = _dragY == null
            ? 0.0
            : ((_dragY! - 20).clamp(0.0, (_height - 40).clamp(0.0, _height)));

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onVerticalDragStart: (d) => _update(d.localPosition.dy),
          onVerticalDragUpdate: (d) => _update(d.localPosition.dy),
          onVerticalDragEnd: (_) => setState(() => _dragY = null),
          onVerticalDragCancel: () => setState(() => _dragY = null),
          onTapDown: (d) => _update(d.localPosition.dy),
          child: Container(
            width: 38,
            color: Colors.transparent,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 5,
                  height: safeH,
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                if (_dragY != null)
                  Positioned(
                    top: thumbTop,
                    right: 36,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: widget.color,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: widget.color.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.label(_current),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                if (_dragY != null)
                  Positioned(
                    top: ((_dragY! - 5).clamp(0.0, (_height - 10).clamp(0.0, _height))),
                    child: Container(
                      width: 24,
                      height: 10,
                      decoration: BoxDecoration(
                        color: widget.color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
