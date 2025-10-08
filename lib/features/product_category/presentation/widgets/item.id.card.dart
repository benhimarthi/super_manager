import 'package:flutter/material.dart';
import 'package:super_manager/features/image_manager/presentation/widgets/profile.image.dart';

class ItemIdCard extends StatefulWidget {
  final String itemId;
  final String itemName;
  final double radius;
  final double fontSize;
  final Color color;
  const ItemIdCard({
    super.key,
    required this.itemId,
    required this.itemName,
    this.radius = 10,
    this.fontSize = 16,
    this.color = Colors.transparent,
  });

  @override
  State<ItemIdCard> createState() => _ItemIdCardState();
}

class _ItemIdCardState extends State<ItemIdCard> {
  @override
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(widget.radius),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        child: Row(
          children: [
            ProfileImage(
              itemId: widget.itemId,
              entityType: "_",
              name: widget.itemName,
              radius: widget.radius,
              fontSize: widget.fontSize,
              displayEdit: false,
            ),
            SizedBox(width: 10),
            Text(
              widget.itemName,
              style: TextStyle(
                fontSize: widget.fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
