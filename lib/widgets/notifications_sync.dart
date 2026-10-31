import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../models/reservation.dart';
import '../providers/reservations_provider.dart';
import '../providers/session_provider.dart';
import '../services/local_notifications_service.dart';

/// Mantiene los avisos locales en sintonía con la reserva en curso.
///
/// Observa la reserva del servidor y, cada vez que cambia, **reprograma toda la
/// serie** de avisos (RF-3.3, RF-3.4, RF-4.4). Cuando ya no hay reserva
/// —checkout, cancelación o vencimiento— los cancela (RF-4.5).
///
/// Va aquí, y no dentro de `ReservationsProvider`, porque los textos de los
/// avisos están traducidos y hacen falta las localizaciones (que necesitan
/// `BuildContext`). El provider queda así libre de UI.
class NotificationsSync extends StatefulWidget {
  const NotificationsSync({
    required this.child,
    required this.notifications,
    super.key,
  });

  final Widget child;
  final LocalNotificationsService notifications;

  @override
  State<NotificationsSync> createState() => _NotificationsSyncState();
}

class _NotificationsSyncState extends State<NotificationsSync> {
  /// Última reserva sincronizada, para no reprogramar en cada rebuild.
  String? _lastSignature;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final reservation = context.watch<ReservationsProvider>().activeReservation;
    final signature = _signatureOf(reservation);
    if (signature == _lastSignature) return;
    _lastSignature = signature;

    _sync(reservation);
  }

  /// Solo lo que afecta a los avisos: si nada de esto cambia, no hay que
  /// reprogramar nada.
  String? _signatureOf(Reservation? reservation) {
    if (reservation == null) return null;
    return '${reservation.id}|${reservation.status.name}'
        '|${reservation.expiresAt.toIso8601String()}'
        '|${reservation.maxUntil?.toIso8601String()}';
  }

  Future<void> _sync(Reservation? reservation) async {
    final params = context.read<SessionProvider>().params;
    final texts = _textsFrom(context);

    await widget.notifications.syncFor(reservation, params, texts);
  }

  NotificationTexts _textsFrom(BuildContext context) {
    final l10n = context.l10n;
    return NotificationTexts(
      reservationWarningTitle: l10n.notifReservationWarningTitle,
      reservationWarningBody: l10n.notifReservationWarningBody,
      reservationExpiredTitle: l10n.notifReservationExpiredTitle,
      reservationExpiredBody: l10n.notifReservationExpiredBody,
      useWarningTitle: l10n.notifUseWarningTitle,
      useWarningBody: l10n.notifUseWarningBody,
      overstayTitle: l10n.notifOverstayTitle,
      overstayBody: l10n.notifOverstayBody,
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
