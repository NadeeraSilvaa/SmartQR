import 'package:flutter/material.dart';
import 'package:smartqr_plus/utils/app_colors.dart';

class CustomizationPanel extends StatefulWidget {
  final Color qrColor;
  final Color backgroundColor;
  final double qrSize;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<Color> onBackgroundColorChanged;
  final ValueChanged<double> onSizeChanged;

  const CustomizationPanel({
    super.key,
    required this.qrColor,
    required this.backgroundColor,
    required this.qrSize,
    required this.onColorChanged,
    required this.onBackgroundColorChanged,
    required this.onSizeChanged,
  });

  @override
  State<CustomizationPanel> createState() => _CustomizationPanelState();
}

class _CustomizationPanelState extends State<CustomizationPanel> {
  final List<Color> _presetColors = [
    Colors.black,
    AppColors.primary,
    AppColors.accent,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
  ];

  final List<Color> _presetBackgrounds = [
    Colors.white,
    Colors.black,
    Colors.grey[200]!,
    Colors.grey[900]!,
    AppColors.primary.withOpacity(0.1),
    AppColors.accent.withOpacity(0.1),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customize QR Code',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // QR Color Selection
          const Text(
            'QR Color',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _presetColors.map((color) {
                    final isSelected = color.value == widget.qrColor.value;
                    return GestureDetector(
                      onTap: () => widget.onColorChanged(color),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.color_lens),
                onPressed: () async {
                  final color = await showDialog<Color>(
                    context: context,
                    builder: (context) => const ColorPickerDialog(),
                  );
                  if (color != null) {
                    widget.onColorChanged(color);
                  }
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Background Color Selection
          const Text(
            'Background Color',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _presetBackgrounds.map((color) {
              final isSelected =
                  color.value == widget.backgroundColor.value;
              return GestureDetector(
                onTap: () => widget.onBackgroundColorChanged(color),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.grey[300]!,
                      width: 3,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: AppColors.primary,
                          size: 20,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          
          // Size Slider
          const Text(
            'Size',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('150'),
              Expanded(
                child: Slider(
                  value: widget.qrSize,
                  min: 150,
                  max: 300,
                  divisions: 15,
                  label: '${widget.qrSize.toInt()}px',
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    widget.onSizeChanged(value);
                  },
                ),
              ),
              const Text('300'),
            ],
          ),
        ],
      ),
    );
  }
}

class ColorPickerDialog extends StatefulWidget {
  const ColorPickerDialog({super.key});

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  Color _selectedColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pick a Color',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Simple color picker - in production, use a proper color picker package
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(20, (index) {
                final hue = (index * 18.0) % 360;
                final color = HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor();
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedColor == color
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, _selectedColor),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Select'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

