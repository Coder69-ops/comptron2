import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? color;
  final double? width;
  final double height;
  final IconData? icon;
  final ButtonSize size;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.color,
    this.width,
    this.height = 52,
    this.icon,
    this.size = ButtonSize.medium,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

enum ButtonSize { small, medium, large }

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  EdgeInsets get _buttonPadding {
    switch (widget.size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 20);
    }
  }

  double get _fontSize {
    switch (widget.size) {
      case ButtonSize.small:
        return 14;
      case ButtonSize.medium:
        return 16;
      case ButtonSize.large:
        return 18;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient:
                  !widget.isOutlined &&
                      widget.onPressed != null &&
                      !widget.isLoading
                  ? LinearGradient(
                      colors: [
                        widget.color ?? Theme.of(context).primaryColor,
                        (widget.color ?? Theme.of(context).primaryColor)
                            .withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              boxShadow:
                  !widget.isOutlined &&
                      widget.onPressed != null &&
                      !widget.isLoading
                  ? [
                      BoxShadow(
                        color: (widget.color ?? Theme.of(context).primaryColor)
                            .withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: GestureDetector(
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              child: widget.isOutlined
                  ? OutlinedButton(
                      onPressed: widget.isLoading ? null : widget.onPressed,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: widget.color ?? Theme.of(context).primaryColor,
                          width: 1.5,
                        ),
                        padding: _buttonPadding,
                        foregroundColor:
                            widget.color ?? Theme.of(context).primaryColor,
                      ),
                      child: _buildButtonContent(),
                    )
                  : ElevatedButton(
                      onPressed: widget.isLoading ? null : widget.onPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: _buttonPadding,
                        foregroundColor: Colors.white,
                      ),
                      child: _buildButtonContent(),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildButtonContent() {
    if (widget.isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: widget.isOutlined
              ? (widget.color ?? Theme.of(context).primaryColor)
              : Colors.white,
        ),
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, size: _fontSize + 2),
          const SizedBox(width: 8),
          Text(
            widget.text,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: _fontSize),
          ),
        ],
      );
    }

    return Text(
      widget.text,
      style: TextStyle(fontWeight: FontWeight.w600, fontSize: _fontSize),
    );
  }
}
