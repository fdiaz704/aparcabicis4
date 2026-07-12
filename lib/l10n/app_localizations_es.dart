// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get activeCancelReservation => 'Cancelar reserva';

  @override
  String get activeCancelReservationError => 'Error al cancelar la reserva';

  @override
  String get activeDoorOpenError => 'No se ha podido abrir la puerta';

  @override
  String get activeDoorOpenedSuccess => 'Puerta abierta correctamente';

  @override
  String get activeDoorUnavailable =>
      'La puerta no responde. Inténtalo de nuevo o contacta con soporte.';

  @override
  String get activeFinalInstructions => 'Instrucciones finales';

  @override
  String get activeFinishUsage => 'Finalizar uso';

  @override
  String get activeFinishUsageError => 'Error al finalizar el uso';

  @override
  String get activeInstructionCloseDoor => 'Cierre la puerta';

  @override
  String get activeInstructionRemoveBelongings =>
      'Retire todas sus pertenencias';

  @override
  String get activeInstructionSpotAvailable =>
      'La plaza quedará disponible\npara otros usuarios';

  @override
  String get activeInstructionsInUse =>
      'Puedes abrir y cerrar la puerta tantas veces como necesites durante tu uso.';

  @override
  String get activeInstructionsReserved =>
      'Abre la puerta para comenzar a usar la plaza. Tienes 30 minutos para llegar.';

  @override
  String activeMaxTime(String time) {
    return 'Tiempo máximo: $time';
  }

  @override
  String get activeOpenDoor => 'Abrir puerta';

  @override
  String get activeReservationCancelled => 'Reserva cancelada';

  @override
  String get activeReservationTimeLeft => 'Tiempo restante de reserva';

  @override
  String get activeStatusInUse => 'En uso';

  @override
  String get activeStatusReserved => 'Reservada';

  @override
  String get activeTapToContinue => 'Toca en cualquier parte para\ncontinuar';

  @override
  String get activeUsageFinishedSuccess => 'Uso finalizado correctamente';

  @override
  String get activeUsageTime => 'Tiempo de uso';

  @override
  String get appName => 'Aparcabicis';

  @override
  String get biometricEnableAccept => 'Activar';

  @override
  String get biometricEnableMessage =>
      'La próxima vez podrás restaurar tu sesión con huella o Face ID, sin escribir la contraseña.';

  @override
  String get biometricEnableSkip => 'Ahora no';

  @override
  String get biometricEnableTitle => '¿Activar acceso biométrico?';

  @override
  String get biometricEnabledSuccess => 'Acceso biométrico activado';

  @override
  String get biometricFallbackMessage =>
      'No se pudo verificar tu identidad. Inicia sesión con tu contraseña.';

  @override
  String get biometricPromptReason =>
      'Confirma tu identidad para acceder a Aparcabicis';

  @override
  String get biometricUnavailable =>
      'Este dispositivo no tiene biometría configurada';

  @override
  String get changePasswordCancelButton => 'Cancelar';

  @override
  String get changePasswordConfirmNewHint => 'Repite la nueva contraseña';

  @override
  String get changePasswordConfirmNewLabel => 'Confirmar nueva contraseña';

  @override
  String get changePasswordConfirmNewRequired =>
      'Por favor confirma tu nueva contraseña';

  @override
  String get changePasswordCurrentHint => 'Tu contraseña actual';

  @override
  String get changePasswordCurrentLabel => 'Contraseña actual';

  @override
  String get changePasswordCurrentRequired =>
      'Por favor ingresa tu contraseña actual';

  @override
  String get changePasswordEmailHint => 'Tu email actual';

  @override
  String get changePasswordEmailInvalid => 'Por favor ingresa un email válido';

  @override
  String get changePasswordEmailLabel => 'Email';

  @override
  String get changePasswordEmailRequired => 'Por favor ingresa tu email';

  @override
  String get changePasswordError => 'Error al cambiar la contraseña';

  @override
  String get changePasswordMismatch => 'Las contraseñas nuevas no coinciden';

  @override
  String get changePasswordNewHint => 'Mínimo 8 caracteres';

  @override
  String get changePasswordNewLabel => 'Nueva contraseña';

  @override
  String get changePasswordNewRequired =>
      'Por favor ingresa una nueva contraseña';

  @override
  String get changePasswordSameAsCurrent =>
      'La nueva contraseña debe ser diferente a la actual';

  @override
  String get changePasswordSubmitButton => 'Cambiar contraseña';

  @override
  String get changePasswordTitle => 'Cambiar Contraseña';

  @override
  String changePasswordTooShort(int count) {
    return 'La contraseña debe tener al menos $count caracteres';
  }

  @override
  String get createUserCancelButton => 'Cancelar';

  @override
  String get createUserConfirmPasswordHint => 'Repite la contraseña';

  @override
  String get createUserConfirmPasswordLabel => 'Confirmar contraseña';

  @override
  String get createUserConfirmPasswordRequired =>
      'Por favor confirma tu contraseña';

  @override
  String get createUserEmailHint => 'ejemplo@correo.com';

  @override
  String get createUserEmailInvalid => 'Por favor ingresa un email válido';

  @override
  String get createUserEmailLabel => 'Email';

  @override
  String get createUserEmailRequired => 'Por favor ingresa tu email';

  @override
  String get createUserError => 'Error al crear el usuario';

  @override
  String get createUserPasswordHint => 'Mínimo 8 caracteres';

  @override
  String get createUserPasswordLabel => 'Contraseña';

  @override
  String get createUserPasswordMismatch => 'Las contraseñas no coinciden';

  @override
  String get createUserPasswordRequired => 'Por favor ingresa una contraseña';

  @override
  String createUserPasswordTooShort(int count) {
    return 'La contraseña debe tener al menos $count caracteres';
  }

  @override
  String get createUserSubmitButton => 'Crear usuario';

  @override
  String get createUserTitle => 'Crear Usuario';

  @override
  String get deleteUserCancelButton => 'Cancelar';

  @override
  String get deleteUserConfirmButton => 'Eliminar';

  @override
  String get deleteUserConfirmContent =>
      'Esta acción eliminará permanentemente tu cuenta y no se puede deshacer.';

  @override
  String get deleteUserConfirmPasswordHint => 'Repite tu contraseña';

  @override
  String get deleteUserConfirmPasswordLabel => 'Confirmar contraseña';

  @override
  String get deleteUserConfirmPasswordRequired =>
      'Por favor confirma tu contraseña';

  @override
  String get deleteUserConfirmTitle => '¿Estás seguro?';

  @override
  String get deleteUserConfirmationInvalid =>
      'Debes escribir exactamente \"ELIMINAR\"';

  @override
  String get deleteUserConfirmationLabel =>
      'Escribir \"ELIMINAR\" para confirmar';

  @override
  String get deleteUserConfirmationRequired =>
      'Por favor escribe ELIMINAR para confirmar';

  @override
  String get deleteUserEmailHint => 'Tu email actual';

  @override
  String get deleteUserEmailInvalid => 'Por favor ingresa un email válido';

  @override
  String get deleteUserEmailLabel => 'Email';

  @override
  String get deleteUserEmailRequired => 'Por favor ingresa tu email';

  @override
  String get deleteUserError => 'Error al eliminar la cuenta';

  @override
  String get deleteUserPasswordHint => 'Tu contraseña actual';

  @override
  String get deleteUserPasswordLabel => 'Contraseña';

  @override
  String get deleteUserPasswordMismatch => 'Las contraseñas no coinciden';

  @override
  String get deleteUserPasswordRequired => 'Por favor ingresa tu contraseña';

  @override
  String get deleteUserSubmitButton => 'Eliminar cuenta';

  @override
  String get deleteUserTitle => 'Eliminar Cuenta';

  @override
  String get deleteUserWarning =>
      'Esta acción es permanente y no se puede deshacer';

  @override
  String get helpActiveContent =>
      'Cuando tengas una reserva activa:\n\n• Estado \"Reservada\": Tienes 30 minutos para llegar\n• Estado \"En uso\": Puedes usar la plaza hasta 2 horas\n• Puedes abrir la puerta tantas veces como necesites\n• Finaliza tu uso cuando termines';

  @override
  String get helpActiveTitle => 'Reserva activa';

  @override
  String get helpCancel => 'Cancelar';

  @override
  String get helpContactChatDesc =>
      'Respuesta inmediata durante horario laboral';

  @override
  String get helpContactChatTitle => 'Chat en vivo';

  @override
  String get helpContactChatValue => 'Disponible de 9:00 a 18:00';

  @override
  String get helpContactEmailDesc =>
      'Para problemas técnicos y consultas generales';

  @override
  String get helpContactEmailTitle => 'Email de soporte';

  @override
  String get helpContactEmailValue => 'soporte@aparcabicis.com';

  @override
  String get helpContactPhoneDesc => 'Disponible 24/7 para emergencias';

  @override
  String get helpContactPhoneTitle => 'Teléfono de emergencia';

  @override
  String get helpContactPhoneValue => '+34 900 123 456';

  @override
  String get helpContactSocialDesc =>
      'Síguenos para novedades y actualizaciones';

  @override
  String get helpContactSocialTitle => 'Redes sociales';

  @override
  String get helpContactSocialValue => '@AparcabicisApp';

  @override
  String get helpContactTitle => 'Contacta con nosotros';

  @override
  String get helpDemoContent =>
      'El demo interactivo te guiará paso a paso por todas las funciones de la aplicación.';

  @override
  String get helpDemoInDevelopment =>
      'Demo interactivo - Funcionalidad en desarrollo';

  @override
  String get helpDemoTitle => 'Demo interactivo';

  @override
  String get helpFaq10Answer =>
      'El servicio básico es gratuito. Solo pagas si excedes el tiempo máximo de uso o por servicios premium adicionales.';

  @override
  String get helpFaq10Question => '¿Hay algún coste por usar el servicio?';

  @override
  String get helpFaq1Answer =>
      'Ve a la sección de Aparcamientos, selecciona un aparcamiento disponible y presiona \"Reservar\". Tendrás 30 minutos para llegar y abrir la puerta.';

  @override
  String get helpFaq1Question => '¿Cómo reservo una plaza?';

  @override
  String get helpFaq2Answer =>
      'Sí, puedes cancelar tu reserva desde la pantalla de reserva activa presionando \"Cancelar reserva\". Esto liberará la plaza para otros usuarios.';

  @override
  String get helpFaq2Question => '¿Puedo cancelar mi reserva?';

  @override
  String get helpFaq3Answer =>
      'Puedes usar una plaza por un máximo de 2 horas. El timer comenzará cuando abras la puerta por primera vez.';

  @override
  String get helpFaq3Question => '¿Cuánto tiempo puedo usar una plaza?';

  @override
  String get helpFaq4Answer =>
      'Si no abres la puerta en 30 minutos, tu reserva se cancelará automáticamente y la plaza quedará disponible para otros usuarios.';

  @override
  String get helpFaq4Question => '¿Qué pasa si no llego a tiempo?';

  @override
  String get helpFaq5Answer =>
      'No, solo puedes tener una reserva activa a la vez. Debes finalizar tu uso actual antes de hacer una nueva reserva.';

  @override
  String get helpFaq5Question => '¿Puedo tener múltiples reservas?';

  @override
  String get helpFaq6Answer =>
      'Presiona el icono de estrella en cualquier aparcamiento para marcarlo como favorito. Luego puedes filtrar para ver solo tus favoritos.';

  @override
  String get helpFaq6Question => '¿Cómo marco un aparcamiento como favorito?';

  @override
  String get helpFaq7Answer =>
      'Sí, ve a la pestaña \"Historial\" para ver todas tus reservas anteriores, estadísticas de uso y filtrar por estado.';

  @override
  String get helpFaq7Question => '¿Puedo ver mi historial de reservas?';

  @override
  String get helpFaq8Answer =>
      'Necesitas conexión a internet para hacer reservas y abrir puertas. Sin embargo, puedes ver tu historial y configuración sin conexión.';

  @override
  String get helpFaq8Question => '¿La aplicación funciona sin internet?';

  @override
  String get helpFaq9Answer =>
      'Ve a Perfil > Configuración de cuenta > Cambiar contraseña, o desde Ajustes > Cuenta > Cambiar contraseña.';

  @override
  String get helpFaq9Question => '¿Cómo cambio mi contraseña?';

  @override
  String get helpOfficeCity => '28001 Madrid, España';

  @override
  String get helpOfficeName => 'Aparcabicis S.L.';

  @override
  String get helpOfficeSaturday => 'Sábados: 10:00 - 14:00';

  @override
  String get helpOfficeScheduleLabel => 'Horario de atención:';

  @override
  String get helpOfficeStreet => 'Calle Mayor, 123';

  @override
  String get helpOfficeSunday => 'Domingos: Cerrado';

  @override
  String get helpOfficeTitle => 'Oficinas centrales';

  @override
  String get helpOfficeWeekdays => 'Lunes a Viernes: 9:00 - 18:00';

  @override
  String get helpQuickActionsTitle => 'Acciones rápidas';

  @override
  String get helpRateDesc => 'Ayúdanos dejando una reseña en la tienda';

  @override
  String get helpRateInDevelopment =>
      'Valorar app - Funcionalidad en desarrollo';

  @override
  String get helpRateTitle => 'Valorar la app';

  @override
  String get helpReportDesc =>
      'Informa sobre aparcamientos dañados o problemas técnicos';

  @override
  String get helpReportInDevelopment =>
      'Reportar problema - Funcionalidad en desarrollo';

  @override
  String get helpReportTitle => 'Reportar un problema';

  @override
  String get helpReserveContent =>
      '1. Ve a la sección \"Aparcamientos\"\n2. Selecciona un aparcamiento disponible\n3. Presiona \"Reservar\"\n4. Tienes 30 minutos para llegar\n5. Abre la puerta para comenzar a usar la plaza';

  @override
  String get helpReserveTitle => 'Cómo hacer una reserva';

  @override
  String get helpStart => 'Iniciar';

  @override
  String get helpStartDemo => 'Iniciar demo interactivo';

  @override
  String get helpSuggestDesc => 'Comparte tus ideas para mejorar la aplicación';

  @override
  String get helpSuggestInDevelopment =>
      'Sugerir mejora - Funcionalidad en desarrollo';

  @override
  String get helpSuggestTitle => 'Sugerir mejora';

  @override
  String get helpTabContact => 'Contacto';

  @override
  String get helpTabFaq => 'FAQ';

  @override
  String get helpTabTutorial => 'Tutorial';

  @override
  String get helpTipsContent =>
      '• Marca como favoritos los aparcamientos que uses frecuentemente\n• Revisa tu historial para ver estadísticas de uso\n• Activa las notificaciones para recordatorios\n• Usa los filtros para encontrar aparcamientos más rápido\n• Cancela tu reserva si no vas a usarla';

  @override
  String get helpTipsTitle => 'Consejos útiles';

  @override
  String get helpTitle => 'Ayuda y Tutorial';

  @override
  String get helpUsingContent =>
      '• Lista: Ve todos los aparcamientos en formato lista\n• Mapa: Visualiza los aparcamientos en un mapa interactivo\n• Favoritos: Marca tus aparcamientos preferidos\n• Filtros: Busca por disponibilidad o favoritos\n• Historial: Revisa tus reservas anteriores';

  @override
  String get helpUsingTitle => 'Usando la aplicación';

  @override
  String get helpWelcomeContent =>
      'Tu aplicación para reservar plazas de aparcamiento para bicicletas de forma inteligente.';

  @override
  String get helpWelcomeTitle => 'Bienvenido a Aparcabicis';

  @override
  String get historyAll => 'Todos';

  @override
  String get historyCardCancelled => 'Cancelada';

  @override
  String get historyCardCompleted => 'Completada';

  @override
  String historyCardCost(String cost) {
    return '€$cost';
  }

  @override
  String get historyCardExpired => 'Expirada';

  @override
  String get historyCardUnfinished => 'Sin finalizar';

  @override
  String get historyClose => 'Cerrar';

  @override
  String get historyCompleted => 'Completadas';

  @override
  String get historyLabelCost => 'Coste';

  @override
  String get historyLabelDate => 'Fecha';

  @override
  String get historyLabelDuration => 'Duración';

  @override
  String get historyLabelParking => 'Aparcamiento';

  @override
  String get historyNoReservations => 'No hay reservas en el historial';

  @override
  String historyNoReservationsFiltered(String status) {
    return 'No hay reservas $status';
  }

  @override
  String get historyReservationDetails => 'Detalles de la reserva';

  @override
  String get historyReservationsWillAppear =>
      'Tus reservas aparecerán aquí una vez que las completes';

  @override
  String historyResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reservas encontradas',
      one: '$count reserva encontrada',
    );
    return '$_temp0';
  }

  @override
  String get historyShowAll => 'Mostrar todas';

  @override
  String get historySortDurationAsc => '- Duración';

  @override
  String get historySortDurationDesc => '+ Duración';

  @override
  String get historySortLabel => 'Ordenar';

  @override
  String get historySortOldest => 'Antiguo';

  @override
  String get historySortRecent => 'Reciente';

  @override
  String get historyStatistics => 'Estadísticas';

  @override
  String get historyStatus => 'Estado';

  @override
  String get historyStatusCancelled => 'Canceladas';

  @override
  String get historyStatusCompleted => 'Completadas';

  @override
  String get historyStatusExpired => 'Expiradas';

  @override
  String historySuccessRate(Object rate) {
    return '$rate% éxito';
  }

  @override
  String get historyTotalReservations => 'Total reservas';

  @override
  String get historyTotalTime => 'Tiempo total';

  @override
  String get historyTryChangeFilter =>
      'Intenta cambiar el filtro para ver más reservas';

  @override
  String get lockMessage => 'Desbloquea con tu huella o Face ID para continuar';

  @override
  String get lockRetry => 'Reintentar';

  @override
  String get lockTitle => 'App bloqueada';

  @override
  String get lockUsePassword => 'Usar contraseña';

  @override
  String get loginEmailHint => 'ejemplo@correo.com';

  @override
  String get loginEmailInvalid => 'Por favor ingresa un email válido';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginEmailRequired => 'Por favor ingresa tu email';

  @override
  String get loginError => 'Error al iniciar sesión';

  @override
  String get loginInvalidCredentials => 'Email o contraseña incorrectos';

  @override
  String get loginMenuChangePassword => 'Cambiar contraseña';

  @override
  String get loginMenuCreateUser => 'Crear usuario';

  @override
  String get loginMenuDeleteUser => 'Eliminar usuario';

  @override
  String get loginMenuRecoverPassword => 'Recuperar contraseña';

  @override
  String get loginPasswordHint => 'Mínimo 8 caracteres';

  @override
  String get loginPasswordLabel => 'Contraseña';

  @override
  String get loginPasswordRequired => 'Por favor ingresa tu contraseña';

  @override
  String loginPasswordTooShort(int count) {
    return 'La contraseña debe tener al menos $count caracteres';
  }

  @override
  String get loginRememberMe => 'Recuérdame';

  @override
  String get loginSignInButton => 'Iniciar sesión';

  @override
  String get loginSuccess => 'Inicio de sesión exitoso';

  @override
  String get mainActiveReservation => 'Reserva activa';

  @override
  String get mainLogout => 'Cerrar sesión';

  @override
  String get mainTabHistory => 'Historial';

  @override
  String get mainTabList => 'Lista';

  @override
  String get mainTabMap => 'Mapa';

  @override
  String get mainTabParkings => 'Aparcamientos';

  @override
  String get mainTabProfile => 'Perfil';

  @override
  String get mainTabSettings => 'Ajustes';

  @override
  String mapAddedToFavorites(String name) {
    return '$name añadido a favoritos';
  }

  @override
  String get mapAlreadyActiveReservation => 'Ya tienes una reserva activa';

  @override
  String mapCenteringOn(String city) {
    return 'Centrando en $city';
  }

  @override
  String mapFreeSpots(int count) {
    return '$count plazas libres';
  }

  @override
  String get mapLocating => 'Obteniendo tu ubicación...';

  @override
  String get mapLocationDenied =>
      'Necesitamos tu ubicación para centrar el mapa';

  @override
  String get mapLocationDeniedForever =>
      'Permiso de ubicación bloqueado. Actívalo en los ajustes del sistema.';

  @override
  String get mapLocationServiceDisabled =>
      'La ubicación del dispositivo está desactivada';

  @override
  String get mapLocationUnavailable => 'No se ha podido obtener tu ubicación';

  @override
  String get mapNoSpotsAvailable =>
      'No hay plazas disponibles en este aparcamiento';

  @override
  String get mapNotAvailable => 'No disponible';

  @override
  String get mapOpenSettings => 'Ajustes';

  @override
  String mapRemovedFromFavorites(String name) {
    return '$name eliminado de favoritos';
  }

  @override
  String mapReservationCreated(String name) {
    return 'Reserva creada exitosamente en $name';
  }

  @override
  String get mapReservationError => 'Error al crear la reserva';

  @override
  String get mapReserve => 'Reservar';

  @override
  String mapSpotsAvailable(int available, int total) {
    return '$available de $total disponibles';
  }

  @override
  String get parkingCardActiveReservation => 'Reserva activa';

  @override
  String get parkingCardAddFavorite => 'Agregar a favoritos';

  @override
  String parkingCardAddedToFavorites(String name) {
    return '$name añadido a favoritos';
  }

  @override
  String get parkingCardAlreadyReserved => 'Ya tienes una reserva activa';

  @override
  String get parkingCardNoSpots => 'Sin plazas';

  @override
  String get parkingCardNoSpotsAvailable =>
      'No hay plazas disponibles en este aparcamiento';

  @override
  String get parkingCardRemoveFavorite => 'Quitar de favoritos';

  @override
  String parkingCardRemovedFromFavorites(String name) {
    return '$name eliminado de favoritos';
  }

  @override
  String parkingCardReservationCreated(String name) {
    return 'Reserva creada exitosamente en $name';
  }

  @override
  String get parkingCardReservationError => 'Error al crear la reserva';

  @override
  String get parkingCardReserve => 'Reservar';

  @override
  String get parkingsListActiveReservation => 'Reserva activa';

  @override
  String get parkingsListApplyFilters => 'Aplicar filtros';

  @override
  String get parkingsListClearAll => 'Limpiar todo';

  @override
  String get parkingsListClearFilters => 'Limpiar filtros';

  @override
  String get parkingsListEmptySubtitle =>
      'Intenta ajustar los filtros de búsqueda';

  @override
  String get parkingsListEmptyTitle => 'No se encontraron aparcamientos';

  @override
  String get parkingsListFilters => 'Filtros';

  @override
  String parkingsListFiltersWithCount(int count) {
    return 'Filtros ($count)';
  }

  @override
  String get parkingsListOnlyAvailable => 'Solo disponibles';

  @override
  String get parkingsListOnlyAvailableSubtitle =>
      'Mostrar solo aparcamientos con plazas libres';

  @override
  String get parkingsListOnlyFavorites => 'Solo favoritos';

  @override
  String get parkingsListOnlyFavoritesSubtitle =>
      'Mostrar solo aparcamientos marcados como favoritos';

  @override
  String parkingsListResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aparcamientos encontrados',
      one: '$count aparcamiento encontrado',
    );
    return '$_temp0';
  }

  @override
  String get parkingsListSearchHint => 'Buscar aparcamientos...';

  @override
  String get parkingsListSortAvailability => 'Disponibilidad (más a menos)';

  @override
  String get parkingsListSortBy => 'Ordenar por';

  @override
  String get parkingsListSortName => 'Nombre (A-Z)';

  @override
  String get parkingsListSortNone => 'Sin ordenar';

  @override
  String get profileAccountSettings => 'Configuración de cuenta';

  @override
  String get profileActivitySummary => 'Resumen de actividad';

  @override
  String get profileAverageTime => 'Tiempo promedio';

  @override
  String get profileByTimeout => 'Por timeout';

  @override
  String get profileCancel => 'Cancelar';

  @override
  String profileCancellationRate(String rate) {
    return '$rate% del total';
  }

  @override
  String get profileCancelled => 'Canceladas';

  @override
  String get profileChangePassword => 'Cambiar contraseña';

  @override
  String get profileChangePasswordSubtitle =>
      'Actualiza tu contraseña de acceso';

  @override
  String get profileCompleted => 'Completadas';

  @override
  String get profileDefaultUser => 'Usuario';

  @override
  String get profileDeleteAccount => 'Eliminar cuenta';

  @override
  String get profileDeleteAccountSubtitle =>
      'Eliminar permanentemente tu cuenta';

  @override
  String get profileDetailedStats => 'Estadísticas detalladas';

  @override
  String get profileExpired => 'Expiradas';

  @override
  String get profileFavorites => 'Favoritos';

  @override
  String get profileLogout => 'Cerrar sesión';

  @override
  String get profileLogoutConfirmContent =>
      '¿Estás seguro de que quieres cerrar tu sesión?';

  @override
  String get profileLogoutConfirmTitle => '¿Cerrar sesión?';

  @override
  String get profileLogoutError => 'Error al cerrar sesión';

  @override
  String get profileLogoutSubtitle => 'Salir de tu cuenta';

  @override
  String get profileMarkedParkings => 'Aparcamientos marcados';

  @override
  String profileMemberSince(String date) {
    return 'Miembro desde $date';
  }

  @override
  String get profilePerReservation => 'Por reserva';

  @override
  String profileSuccessRate(String rate) {
    return '$rate% éxito';
  }

  @override
  String get profileTotalReservations => 'Reservas totales';

  @override
  String get profileTotalTime => 'Tiempo total';

  @override
  String get sendPasswordAdditionalTitle => 'Instrucciones adicionales:';

  @override
  String get sendPasswordBackToLoginButton => 'Volver al login';

  @override
  String get sendPasswordCancelButton => 'Cancelar';

  @override
  String get sendPasswordConfirmationMessage =>
      'Hemos enviado las instrucciones para restablecer tu contraseña a:';

  @override
  String get sendPasswordEmailHint => 'ejemplo@correo.com';

  @override
  String get sendPasswordEmailInvalid => 'Por favor ingresa un email válido';

  @override
  String get sendPasswordEmailLabel => 'Email';

  @override
  String get sendPasswordEmailRequired => 'Por favor ingresa tu email';

  @override
  String get sendPasswordError => 'Error al enviar el email';

  @override
  String get sendPasswordInstructions =>
      'Ingresa tu email y te enviaremos instrucciones para restablecer tu contraseña.';

  @override
  String get sendPasswordSendAgainButton => 'Enviar de nuevo';

  @override
  String get sendPasswordSubmitButton => 'Recibir email';

  @override
  String get sendPasswordSuccessAlert => 'Email enviado exitosamente';

  @override
  String get sendPasswordTip1 => '• Revisa tu bandeja de entrada';

  @override
  String get sendPasswordTip2 =>
      '• Si no encuentras el email, revisa la carpeta de spam';

  @override
  String get sendPasswordTip3 => '• El enlace expirará en 24 horas';

  @override
  String get sendPasswordTip4 =>
      '• Si no recibes el email, puedes enviarlo de nuevo';

  @override
  String get sendPasswordTitle => 'Recuperar Contraseña';

  @override
  String get settingsAboutSection => 'Acerca de';

  @override
  String get settingsAccountSection => 'Cuenta';

  @override
  String get settingsAppSection => 'Configuración de la aplicación';

  @override
  String get settingsBiometric => 'Acceso biométrico';

  @override
  String get settingsBiometricDisabled => 'Acceso biométrico desactivado';

  @override
  String get settingsBiometricSubtitle =>
      'Desbloquear la app con huella o Face ID';

  @override
  String get settingsCallSupport => 'Llamar a soporte';

  @override
  String settingsCallSupportError(String phone) {
    return 'No se puede abrir el marcador automáticamente.\nPor favor llama manualmente al $phone';
  }

  @override
  String get settingsCallSupportSubtitle =>
      'Contactar con nuestro equipo de soporte';

  @override
  String get settingsChangePassword => 'Cambiar contraseña';

  @override
  String get settingsChangePasswordSubtitle =>
      'Actualizar tu contraseña de acceso';

  @override
  String get settingsDarkMode => 'Modo oscuro';

  @override
  String get settingsDarkModeSubtitle => 'Usar tema oscuro en la aplicación';

  @override
  String get settingsDeleteAccount => 'Eliminar cuenta';

  @override
  String get settingsDeleteAccountSubtitle =>
      'Eliminar permanentemente tu cuenta';

  @override
  String get settingsFaq => 'Preguntas frecuentes';

  @override
  String get settingsFaqAnswer1 =>
      'Ve a la sección de Aparcamientos, selecciona un aparcamiento disponible y presiona \"Reservar\". Tendrás 30 minutos para llegar.';

  @override
  String get settingsFaqAnswer2 =>
      'Sí, puedes cancelar tu reserva desde la pantalla de reserva activa antes de 30 minutos desde el momento en que se efectuó la reserva.';

  @override
  String get settingsFaqAnswer3 =>
      'Puedes usar una plaza por un máximo de 14 horas. Después de este tiempo, la plaza se liberará automáticamente.';

  @override
  String get settingsFaqAnswer4 =>
      'Si no abres la puerta en 30 minutos, tu reserva se cancelará automáticamente y la plaza quedará disponible.';

  @override
  String get settingsFaqAnswer5 =>
      'No, solo puedes tener una reserva activa a la vez. Debes finalizar tu uso actual antes de hacer una nueva reserva.';

  @override
  String get settingsFaqQuestion1 => '¿Cómo reservo una plaza?';

  @override
  String get settingsFaqQuestion2 => '¿Puedo cancelar mi reserva?';

  @override
  String get settingsFaqQuestion3 => '¿Cuánto tiempo puedo usar una plaza?';

  @override
  String get settingsFaqQuestion4 => '¿Qué pasa si no llego a tiempo?';

  @override
  String get settingsFaqQuestion5 => '¿Puedo tener múltiples reservas?';

  @override
  String get settingsFaqSubtitle => 'Encuentra respuestas a dudas comunes';

  @override
  String get settingsHelpSection => 'Ayuda y soporte';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageValue => 'Español';

  @override
  String get settingsNotifications => 'Notificaciones';

  @override
  String get settingsNotificationsSubtitle =>
      'Recibir notificaciones de reservas y recordatorios';

  @override
  String get settingsPrivacy => 'Política de privacidad';

  @override
  String get settingsPrivacyInDevelopment =>
      'Política de privacidad - Funcionalidad en desarrollo';

  @override
  String get settingsPrivacySubtitle =>
      'Información sobre el manejo de tus datos';

  @override
  String get settingsTerms => 'Términos de servicio';

  @override
  String get settingsTermsInDevelopment =>
      'Términos de servicio - Funcionalidad en desarrollo';

  @override
  String get settingsTermsSubtitle => 'Lee nuestros términos y condiciones';

  @override
  String get settingsTutorial => 'Tutorial';

  @override
  String get settingsTutorialSubtitle => 'Aprende a usar la aplicación';

  @override
  String get settingsVersion => 'Versión';

  @override
  String get splashDescription =>
      'Sistema de reserva de plazas\ninteligentes para bicicletas';

  @override
  String get splashInitializing => 'Inicializando...';
}
