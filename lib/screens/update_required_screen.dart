import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:aparcabicis4/l10n/l10n.dart';
import '../utils/constants.dart';
import '../utils/platform_icons.dart';

/// Pantalla de actualización obligatoria (RF-A.3, HU-1).
///
/// Es un callejón sin salida a propósito: no se puede descartar, ni volver
/// atrás, ni saltársela. La única acción es abrir la tienda.
class UpdateRequiredScreen extends StatelessWidget {
  const UpdateRequiredScreen({
    super.key,
    required this.latestVersion,
    required this.storeUrl,
  });

  final String latestVersion;
  final String? storeUrl;

  Future<void> _openStore(BuildContext context) async {
    final url = storeUrl;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final error = context.l10n.updateStoreError;

    var opened = false;
    if (url != null && url.isNotEmpty) {
      final uri = Uri.tryParse(url);
      if (uri != null) {
        opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }

    if (!opened && messenger != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return PopScope(
      // Ni con el botón "atrás" del sistema: la actualización es obligatoria.
      canPop: false,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: AppColors.loginGradient,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      PlatformIcons.download,
                      size: 72,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      l10n.updateRequiredTitle,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.heading2,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.updateRequiredMessage(latestVersion),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _openStore(context),
                        child: Text(l10n.updateButton),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
