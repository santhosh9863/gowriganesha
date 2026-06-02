import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ganesha_2026/core/design/app_colors.dart';
import 'package:ganesha_2026/core/design/app_radius.dart';
import 'package:ganesha_2026/core/design/app_spacing.dart';
import 'package:ganesha_2026/core/models/festival.dart';

const _qrSize = 240.0;

void showPaymentQrSheet(BuildContext context, Festival festival) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.bottomSheet),
      ),
    ),
    builder: (_) => _PaymentQrSheet(festival: festival),
  );
}

class _PaymentQrSheet extends StatefulWidget {
  final Festival festival;
  const _PaymentQrSheet({required this.festival});

  @override
  State<_PaymentQrSheet> createState() => _PaymentQrSheetState();
}

class _PaymentQrSheetState extends State<_PaymentQrSheet> {
  final _repaintKey = GlobalKey();
  bool _sharing = false;

  Future<void> _shareQr() async {
    if (kIsWeb) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(const SnackBar(content: Text('QR sharing is not available on web. Please use the mobile app.')));
      return;
    }
    setState(() => _sharing = true);
    try {
      final boundary = _repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/festival_qr.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: '${widget.festival.name} — Payment QR',
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Widget _buildQrContent(ThemeData theme, bool hasUpi, String upiLink) {
    final hasImage = widget.festival.qrImageUrl != null &&
        widget.festival.qrImageUrl!.isNotEmpty;

    if (hasImage) {
      return Container(
        width: _qrSize,
        height: _qrSize,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.cardBorder,
          border: Border.all(color: AppColors.outline),
        ),
        child: ClipRRect(
          borderRadius: AppRadius.cardBorder,
          child: Image.network(
            widget.festival.qrImageUrl!,
            width: _qrSize,
            height: _qrSize,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => _qrEmpty(theme, 'Failed to load QR image'),
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return Center(
                child: SizedBox(
                  width: 32, height: 32,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            },
          ),
        ),
      );
    }

    if (hasUpi) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.cardBorder,
          border: Border.all(color: AppColors.outline),
        ),
        child: QrImageView(
          data: upiLink,
          version: QrVersions.auto,
          size: _qrSize,
          backgroundColor: Colors.white,
          eyeStyle: const QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: AppColors.charcoal,
          ),
          dataModuleStyle: const QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: AppColors.charcoal,
          ),
        ),
      );
    }

    return _qrEmpty(theme, 'No UPI ID configured');
  }

  Widget _qrEmpty(ThemeData theme, String text) {
    return Container(
      width: _qrSize,
      height: _qrSize,
      decoration: BoxDecoration(
        color: AppColors.warmGray50,
        borderRadius: AppRadius.cardBorder,
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_2_rounded, size: 48, color: AppColors.warmGray300),
          const SizedBox(height: AppSpacing.sm),
          Text(text, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.warmGray400)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final upiLink = widget.festival.upiDeepLink;
    final hasUpi = upiLink.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.xxl,
        right: AppSpacing.xxl,
        top: AppSpacing.xl,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.warmGray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Header
          Text(
            'Festival QR',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          // QR Code
          RepaintBoundary(
            key: _repaintKey,
            child: _buildQrContent(theme, hasUpi, upiLink),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Festival info
          Text(
            widget.festival.name,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.charcoal,
            ),
          ),
          if (widget.festival.accountName != null &&
              widget.festival.accountName!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              widget.festival.accountName!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.warmGray500,
              ),
            ),
          ],
          if (widget.festival.upiId != null &&
              widget.festival.upiId!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              widget.festival.upiId!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.warmGray400,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xxl),
          // Actions
          Row(
            children: [
              if (hasUpi)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _sharing ? null : _shareQr,
                    icon: _sharing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.share_rounded, size: 16),
                    label: const Text('Share QR'),
                  ),
                ),
              if (hasUpi) const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: const Text('Close'),
                ),
              ),
            ],
          ),
          if (hasUpi) ...[
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: upiLink));
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context)
                    ..clearSnackBars()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text('UPI ID copied'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                },
                icon: const Icon(Icons.copy_rounded, size: 14),
                label: Text(
                  'Copy UPI ID',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.warmGray400,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
