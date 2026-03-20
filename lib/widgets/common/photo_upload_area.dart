import 'package:flutter/material.dart';

class PhotoUploadArea extends StatefulWidget {
  const PhotoUploadArea({
    required this.label,
    required this.placeholder,
    this.onImagePicked,
    super.key,
  });

  final String label;
  final String placeholder;
  final ValueChanged<String>? onImagePicked;

  @override
  State<PhotoUploadArea> createState() => _PhotoUploadAreaState();
}

class _PhotoUploadAreaState extends State<PhotoUploadArea> {
  int _imageCount = 0;
  final int _maxImages = 150;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: const Color(0xFFD8D8D8),
              width: 1.5,
              strokeAlign: BorderSide.strokeAlignCenter,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // Photo pick logic here
                setState(() => _imageCount = (_imageCount + 1).clamp(0, _maxImages));
                widget.onImagePicked?.call('image_$_imageCount');
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFD0D0D0),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 28,
                      color: Color(0xFFC0C0C0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '$_imageCount/$_maxImages',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFA8A8A8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
