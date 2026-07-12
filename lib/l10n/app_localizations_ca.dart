// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class AppLocalizationsCa extends AppLocalizations {
  AppLocalizationsCa([String locale = 'ca']) : super(locale);

  @override
  String get activeCancelReservation => 'Cancel·lar reserva';

  @override
  String get activeCancelReservationError => 'Error en cancel·lar la reserva';

  @override
  String get activeDoorOpenError => 'No s\'ha pogut obrir la porta';

  @override
  String get activeDoorOpenedSuccess => 'Porta oberta correctament';

  @override
  String get activeDoorUnavailable =>
      'La porta no respon. Torna-ho a provar o contacta amb suport.';

  @override
  String get activeFinalInstructions => 'Instruccions finals';

  @override
  String get activeFinishUsage => 'Finalitzar ús';

  @override
  String get activeFinishUsageError => 'Error en finalitzar l\'ús';

  @override
  String get activeInstructionCloseDoor => 'Tanque la porta';

  @override
  String get activeInstructionRemoveBelongings =>
      'Retire totes les seues pertinences';

  @override
  String get activeInstructionSpotAvailable =>
      'La plaça quedarà disponible\nper a altres usuaris';

  @override
  String get activeInstructionsInUse =>
      'Pots obrir i tancar la porta tantes vegades com necessites durant el teu ús.';

  @override
  String get activeInstructionsReserved =>
      'Obri la porta per començar a usar la plaça. Tens 30 minuts per arribar.';

  @override
  String activeMaxTime(String time) {
    return 'Temps màxim: $time';
  }

  @override
  String get activeOpenDoor => 'Obrir porta';

  @override
  String get activeReservationCancelled => 'Reserva cancel·lada';

  @override
  String get activeReservationTimeLeft => 'Temps restant de reserva';

  @override
  String get activeStatusInUse => 'En ús';

  @override
  String get activeStatusReserved => 'Reservada';

  @override
  String get activeTapToContinue => 'Toca en qualsevol lloc per\ncontinuar';

  @override
  String get activeUsageFinishedSuccess => 'Ús finalitzat correctament';

  @override
  String get activeUsageTime => 'Temps d\'ús';

  @override
  String get appName => 'Aparcabicis';

  @override
  String get biometricEnableAccept => 'Activar';

  @override
  String get biometricEnableMessage =>
      'La pròxima vegada podràs restaurar la sessió amb empremta o Face ID, sense escriure la contrasenya.';

  @override
  String get biometricEnableSkip => 'Ara no';

  @override
  String get biometricEnableTitle => 'Vols activar l\'accés biomètric?';

  @override
  String get biometricEnabledSuccess => 'Accés biomètric activat';

  @override
  String get biometricFallbackMessage =>
      'No s\'ha pogut verificar la teua identitat. Inicia sessió amb la contrasenya.';

  @override
  String get biometricPromptReason =>
      'Confirma la teua identitat per a accedir a Aparcabicis';

  @override
  String get biometricUnavailable =>
      'Aquest dispositiu no té biometria configurada';

  @override
  String get changePasswordCancelButton => 'Cancel·lar';

  @override
  String get changePasswordConfirmNewHint => 'Repeteix la nova contrasenya';

  @override
  String get changePasswordConfirmNewLabel => 'Confirmar nova contrasenya';

  @override
  String get changePasswordConfirmNewRequired =>
      'Confirma la teua nova contrasenya';

  @override
  String get changePasswordCurrentHint => 'La teua contrasenya actual';

  @override
  String get changePasswordCurrentLabel => 'Contrasenya actual';

  @override
  String get changePasswordCurrentRequired =>
      'Introdueix la teua contrasenya actual';

  @override
  String get changePasswordEmailHint => 'El teu correu electrònic actual';

  @override
  String get changePasswordEmailInvalid =>
      'Introdueix un correu electrònic vàlid';

  @override
  String get changePasswordEmailLabel => 'Correu electrònic';

  @override
  String get changePasswordEmailRequired =>
      'Introdueix el teu correu electrònic';

  @override
  String get changePasswordError =>
      'S\'ha produït un error en canviar la contrasenya';

  @override
  String get changePasswordMismatch => 'Les noves contrasenyes no coincideixen';

  @override
  String get changePasswordNewHint => 'Mínim 8 caràcters';

  @override
  String get changePasswordNewLabel => 'Nova contrasenya';

  @override
  String get changePasswordNewRequired => 'Introdueix una nova contrasenya';

  @override
  String get changePasswordSameAsCurrent =>
      'La nova contrasenya ha de ser diferent de l\'actual';

  @override
  String get changePasswordSubmitButton => 'Canviar contrasenya';

  @override
  String get changePasswordTitle => 'Canviar contrasenya';

  @override
  String changePasswordTooShort(int count) {
    return 'La contrasenya ha de tindre com a mínim $count caràcters';
  }

  @override
  String get createUserCancelButton => 'Cancel·lar';

  @override
  String get createUserConfirmPasswordHint => 'Repeteix la contrasenya';

  @override
  String get createUserConfirmPasswordLabel => 'Confirmar contrasenya';

  @override
  String get createUserConfirmPasswordRequired =>
      'Confirma la teua contrasenya';

  @override
  String get createUserEmailHint => 'exemple@correu.com';

  @override
  String get createUserEmailInvalid => 'Introdueix un correu electrònic vàlid';

  @override
  String get createUserEmailLabel => 'Correu electrònic';

  @override
  String get createUserEmailRequired => 'Introdueix el teu correu electrònic';

  @override
  String get createUserError => 'S\'ha produït un error en crear l\'usuari';

  @override
  String get createUserPasswordHint => 'Mínim 8 caràcters';

  @override
  String get createUserPasswordLabel => 'Contrasenya';

  @override
  String get createUserPasswordMismatch => 'Les contrasenyes no coincideixen';

  @override
  String get createUserPasswordRequired => 'Introdueix una contrasenya';

  @override
  String createUserPasswordTooShort(int count) {
    return 'La contrasenya ha de tindre com a mínim $count caràcters';
  }

  @override
  String get createUserSubmitButton => 'Crear usuari';

  @override
  String get createUserTitle => 'Crear usuari';

  @override
  String get deleteUserCancelButton => 'Cancel·lar';

  @override
  String get deleteUserConfirmButton => 'Eliminar';

  @override
  String get deleteUserConfirmContent =>
      'Aquesta acció eliminarà permanentment el teu compte i no es pot desfer.';

  @override
  String get deleteUserConfirmPasswordHint => 'Repeteix la teua contrasenya';

  @override
  String get deleteUserConfirmPasswordLabel => 'Confirmar contrasenya';

  @override
  String get deleteUserConfirmPasswordRequired =>
      'Confirma la teua contrasenya';

  @override
  String get deleteUserConfirmTitle => 'Estàs segur?';

  @override
  String get deleteUserConfirmationInvalid =>
      'Has d\'escriure exactament \"ELIMINAR\"';

  @override
  String get deleteUserConfirmationLabel =>
      'Escriu \"ELIMINAR\" per a confirmar';

  @override
  String get deleteUserConfirmationRequired =>
      'Escriu ELIMINAR per a confirmar';

  @override
  String get deleteUserEmailHint => 'El teu correu electrònic actual';

  @override
  String get deleteUserEmailInvalid => 'Introdueix un correu electrònic vàlid';

  @override
  String get deleteUserEmailLabel => 'Correu electrònic';

  @override
  String get deleteUserEmailRequired => 'Introdueix el teu correu electrònic';

  @override
  String get deleteUserError => 'S\'ha produït un error en eliminar el compte';

  @override
  String get deleteUserPasswordHint => 'La teua contrasenya actual';

  @override
  String get deleteUserPasswordLabel => 'Contrasenya';

  @override
  String get deleteUserPasswordMismatch => 'Les contrasenyes no coincideixen';

  @override
  String get deleteUserPasswordRequired => 'Introdueix la teua contrasenya';

  @override
  String get deleteUserSubmitButton => 'Eliminar compte';

  @override
  String get deleteUserTitle => 'Eliminar compte';

  @override
  String get deleteUserWarning =>
      'Aquesta acció és permanent i no es pot desfer';

  @override
  String get helpActiveContent =>
      'Quan tingues una reserva activa:\n\n• Estat \"Reservada\": Tens 30 minuts per a arribar\n• Estat \"En ús\": Pots usar la plaça fins a 2 hores\n• Pots obrir la porta tantes vegades com necessites\n• Finalitza el teu ús quan acabes';

  @override
  String get helpActiveTitle => 'Reserva activa';

  @override
  String get helpCancel => 'Cancel·lar';

  @override
  String get helpContactChatDesc =>
      'Resposta immediata durant l\'horari laboral';

  @override
  String get helpContactChatTitle => 'Xat en directe';

  @override
  String get helpContactChatValue => 'Disponible de 9:00 a 18:00';

  @override
  String get helpContactEmailDesc =>
      'Per a problemes tècnics i consultes generals';

  @override
  String get helpContactEmailTitle => 'Correu de suport';

  @override
  String get helpContactEmailValue => 'soporte@aparcabicis.com';

  @override
  String get helpContactPhoneDesc => 'Disponible 24/7 per a emergències';

  @override
  String get helpContactPhoneTitle => 'Telèfon d\'emergència';

  @override
  String get helpContactPhoneValue => '+34 900 123 456';

  @override
  String get helpContactSocialDesc =>
      'Segueix-nos per a novetats i actualitzacions';

  @override
  String get helpContactSocialTitle => 'Xarxes socials';

  @override
  String get helpContactSocialValue => '@AparcabicisApp';

  @override
  String get helpContactTitle => 'Contacta amb nosaltres';

  @override
  String get helpDemoContent =>
      'El demo interactiu et guiarà pas a pas per totes les funcions de l\'aplicació.';

  @override
  String get helpDemoInDevelopment =>
      'Demo interactiu - Funcionalitat en desenvolupament';

  @override
  String get helpDemoTitle => 'Demo interactiu';

  @override
  String get helpFaq10Answer =>
      'El servei bàsic és gratuït. Només pagues si excedeixes el temps màxim d\'ús o per serveis premium addicionals.';

  @override
  String get helpFaq10Question => 'Hi ha algun cost per usar el servei?';

  @override
  String get helpFaq1Answer =>
      'Ves a la secció d\'Aparcaments, selecciona un aparcament disponible i prem \"Reservar\". Tindràs 30 minuts per a arribar i obrir la porta.';

  @override
  String get helpFaq1Question => 'Com reserve una plaça?';

  @override
  String get helpFaq2Answer =>
      'Sí, pots cancel·lar la teua reserva des de la pantalla de reserva activa prement \"Cancel·lar reserva\". Això alliberarà la plaça per a altres usuaris.';

  @override
  String get helpFaq2Question => 'Puc cancel·lar la meua reserva?';

  @override
  String get helpFaq3Answer =>
      'Pots usar una plaça durant un màxim de 2 hores. El temporitzador començarà quan òbrigues la porta per primera vegada.';

  @override
  String get helpFaq3Question => 'Quant de temps puc usar una plaça?';

  @override
  String get helpFaq4Answer =>
      'Si no obris la porta en 30 minuts, la teua reserva es cancel·larà automàticament i la plaça quedarà disponible per a altres usuaris.';

  @override
  String get helpFaq4Question => 'Què passa si no arribe a temps?';

  @override
  String get helpFaq5Answer =>
      'No, només pots tindre una reserva activa alhora. Has de finalitzar el teu ús actual abans de fer una nova reserva.';

  @override
  String get helpFaq5Question => 'Puc tindre múltiples reserves?';

  @override
  String get helpFaq6Answer =>
      'Prem la icona d\'estrela en qualsevol aparcament per a marcar-lo com a preferit. Després pots filtrar per a veure només els teus preferits.';

  @override
  String get helpFaq6Question => 'Com marque un aparcament com a preferit?';

  @override
  String get helpFaq7Answer =>
      'Sí, ves a la pestanya \"Historial\" per a veure totes les teues reserves anteriors, estadístiques d\'ús i filtrar per estat.';

  @override
  String get helpFaq7Question => 'Puc veure el meu historial de reserves?';

  @override
  String get helpFaq8Answer =>
      'Necessites connexió a internet per a fer reserves i obrir portes. No obstant això, pots veure el teu historial i configuració sense connexió.';

  @override
  String get helpFaq8Question => 'L\'aplicació funciona sense internet?';

  @override
  String get helpFaq9Answer =>
      'Ves a Perfil > Configuració de compte > Canviar contrasenya, o des d\'Ajustos > Compte > Canviar contrasenya.';

  @override
  String get helpFaq9Question => 'Com canvie la meua contrasenya?';

  @override
  String get helpOfficeCity => '28001 Madrid, España';

  @override
  String get helpOfficeName => 'Aparcabicis S.L.';

  @override
  String get helpOfficeSaturday => 'Dissabtes: 10:00 - 14:00';

  @override
  String get helpOfficeScheduleLabel => 'Horari d\'atenció:';

  @override
  String get helpOfficeStreet => 'Calle Mayor, 123';

  @override
  String get helpOfficeSunday => 'Diumenges: Tancat';

  @override
  String get helpOfficeTitle => 'Oficines centrals';

  @override
  String get helpOfficeWeekdays => 'De dilluns a divendres: 9:00 - 18:00';

  @override
  String get helpQuickActionsTitle => 'Accions ràpides';

  @override
  String get helpRateDesc => 'Ajuda\'ns deixant una ressenya a la botiga';

  @override
  String get helpRateInDevelopment =>
      'Valorar app - Funcionalitat en desenvolupament';

  @override
  String get helpRateTitle => 'Valorar l\'app';

  @override
  String get helpReportDesc =>
      'Informa sobre aparcaments danyats o problemes tècnics';

  @override
  String get helpReportInDevelopment =>
      'Reportar problema - Funcionalitat en desenvolupament';

  @override
  String get helpReportTitle => 'Reportar un problema';

  @override
  String get helpReserveContent =>
      '1. Ves a la secció \"Aparcaments\"\n2. Selecciona un aparcament disponible\n3. Prem \"Reservar\"\n4. Tens 30 minuts per a arribar\n5. Obri la porta per a començar a usar la plaça';

  @override
  String get helpReserveTitle => 'Com fer una reserva';

  @override
  String get helpStart => 'Iniciar';

  @override
  String get helpStartDemo => 'Iniciar demo interactiu';

  @override
  String get helpSuggestDesc =>
      'Comparteix les teues idees per a millorar l\'aplicació';

  @override
  String get helpSuggestInDevelopment =>
      'Suggerir millora - Funcionalitat en desenvolupament';

  @override
  String get helpSuggestTitle => 'Suggerir millora';

  @override
  String get helpTabContact => 'Contacte';

  @override
  String get helpTabFaq => 'FAQ';

  @override
  String get helpTabTutorial => 'Tutorial';

  @override
  String get helpTipsContent =>
      '• Marca com a preferits els aparcaments que uses freqüentment\n• Revisa el teu historial per a veure estadístiques d\'ús\n• Activa les notificacions per a recordatoris\n• Usa els filtres per a trobar aparcaments més ràpid\n• Cancel·la la teua reserva si no la vas a usar';

  @override
  String get helpTipsTitle => 'Consells útils';

  @override
  String get helpTitle => 'Ajuda i Tutorial';

  @override
  String get helpUsingContent =>
      '• Llista: Mostra tots els aparcaments en format llista\n• Mapa: Visualitza els aparcaments en un mapa interactiu\n• Preferits: Marca els teus aparcaments preferits\n• Filtres: Busca per disponibilitat o preferits\n• Historial: Revisa les teues reserves anteriors';

  @override
  String get helpUsingTitle => 'Usant l\'aplicació';

  @override
  String get helpWelcomeContent =>
      'La teua aplicació per a reservar places d\'aparcament per a bicicletes de manera intel·ligent.';

  @override
  String get helpWelcomeTitle => 'Benvingut a Aparcabicis';

  @override
  String get historyAll => 'Tots';

  @override
  String get historyCardCancelled => 'Cancel·lada';

  @override
  String get historyCardCompleted => 'Completada';

  @override
  String historyCardCost(String cost) {
    return '€$cost';
  }

  @override
  String get historyCardExpired => 'Expirada';

  @override
  String get historyCardUnfinished => 'Sense finalitzar';

  @override
  String get historyClose => 'Tancar';

  @override
  String get historyCompleted => 'Completades';

  @override
  String get historyLabelCost => 'Cost';

  @override
  String get historyLabelDate => 'Data';

  @override
  String get historyLabelDuration => 'Durada';

  @override
  String get historyLabelParking => 'Aparcament';

  @override
  String get historyNoReservations => 'No hi ha reserves a l\'historial';

  @override
  String historyNoReservationsFiltered(String status) {
    return 'No hi ha reserves $status';
  }

  @override
  String get historyReservationDetails => 'Detalls de la reserva';

  @override
  String get historyReservationsWillAppear =>
      'Les teues reserves apareixeran ací una vegada les completes';

  @override
  String historyResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reserves trobades',
      one: '$count reserva trobada',
    );
    return '$_temp0';
  }

  @override
  String get historyShowAll => 'Mostrar totes';

  @override
  String get historySortDurationAsc => '- Durada';

  @override
  String get historySortDurationDesc => '+ Durada';

  @override
  String get historySortLabel => 'Ordenar';

  @override
  String get historySortOldest => 'Antic';

  @override
  String get historySortRecent => 'Recent';

  @override
  String get historyStatistics => 'Estadístiques';

  @override
  String get historyStatus => 'Estat';

  @override
  String get historyStatusCancelled => 'Cancel·lades';

  @override
  String get historyStatusCompleted => 'Completades';

  @override
  String get historyStatusExpired => 'Expirades';

  @override
  String historySuccessRate(Object rate) {
    return '$rate% èxit';
  }

  @override
  String get historyTotalReservations => 'Total reserves';

  @override
  String get historyTotalTime => 'Temps total';

  @override
  String get historyTryChangeFilter =>
      'Prova a canviar el filtre per veure més reserves';

  @override
  String get lockMessage =>
      'Desbloqueja amb l\'empremta o Face ID per a continuar';

  @override
  String get lockRetry => 'Tornar a provar';

  @override
  String get lockTitle => 'App bloquejada';

  @override
  String get lockUsePassword => 'Usar contrasenya';

  @override
  String get loginEmailHint => 'exemple@correu.com';

  @override
  String get loginEmailInvalid => 'Introdueix un correu electrònic vàlid';

  @override
  String get loginEmailLabel => 'Correu electrònic';

  @override
  String get loginEmailRequired => 'Introdueix el teu correu electrònic';

  @override
  String get loginError => 'S\'ha produït un error en iniciar sessió';

  @override
  String get loginInvalidCredentials => 'Correu o contrasenya incorrectes';

  @override
  String get loginMenuChangePassword => 'Canviar contrasenya';

  @override
  String get loginMenuCreateUser => 'Crear usuari';

  @override
  String get loginMenuDeleteUser => 'Eliminar usuari';

  @override
  String get loginMenuRecoverPassword => 'Recuperar contrasenya';

  @override
  String get loginPasswordHint => 'Mínim 8 caràcters';

  @override
  String get loginPasswordLabel => 'Contrasenya';

  @override
  String get loginPasswordRequired => 'Introdueix la teua contrasenya';

  @override
  String loginPasswordTooShort(int count) {
    return 'La contrasenya ha de tindre com a mínim $count caràcters';
  }

  @override
  String get loginRememberMe => 'Recorda\'m';

  @override
  String get loginSignInButton => 'Iniciar sessió';

  @override
  String get loginSuccess => 'Sessió iniciada correctament';

  @override
  String get mainActiveReservation => 'Reserva activa';

  @override
  String get mainLogout => 'Tancar sessió';

  @override
  String get mainTabHistory => 'Historial';

  @override
  String get mainTabList => 'Llista';

  @override
  String get mainTabMap => 'Mapa';

  @override
  String get mainTabParkings => 'Aparcaments';

  @override
  String get mainTabProfile => 'Perfil';

  @override
  String get mainTabSettings => 'Ajustos';

  @override
  String mapAddedToFavorites(String name) {
    return '$name afegit a preferits';
  }

  @override
  String get mapAlreadyActiveReservation => 'Ja tens una reserva activa';

  @override
  String mapCenteringOn(String city) {
    return 'Centrant en $city';
  }

  @override
  String mapFreeSpots(int count) {
    return '$count places lliures';
  }

  @override
  String get mapNoSpotsAvailable =>
      'No hi ha places disponibles en aquest aparcament';

  @override
  String get mapNotAvailable => 'No disponible';

  @override
  String mapRemovedFromFavorites(String name) {
    return '$name eliminat de preferits';
  }

  @override
  String mapReservationCreated(String name) {
    return 'Reserva creada correctament en $name';
  }

  @override
  String get mapReservationError => 'Error en crear la reserva';

  @override
  String get mapReserve => 'Reservar';

  @override
  String mapSpotsAvailable(int available, int total) {
    return '$available de $total disponibles';
  }

  @override
  String get parkingCardActiveReservation => 'Reserva activa';

  @override
  String get parkingCardAddFavorite => 'Afegir als preferits';

  @override
  String parkingCardAddedToFavorites(String name) {
    return '$name afegit als preferits';
  }

  @override
  String get parkingCardAlreadyReserved => 'Ja tens una reserva activa';

  @override
  String get parkingCardNoSpots => 'Sense places';

  @override
  String get parkingCardNoSpotsAvailable =>
      'No hi ha places disponibles en aquest aparcament';

  @override
  String get parkingCardRemoveFavorite => 'Llevar dels preferits';

  @override
  String parkingCardRemovedFromFavorites(String name) {
    return '$name eliminat dels preferits';
  }

  @override
  String parkingCardReservationCreated(String name) {
    return 'Reserva creada correctament en $name';
  }

  @override
  String get parkingCardReservationError => 'Error en crear la reserva';

  @override
  String get parkingCardReserve => 'Reservar';

  @override
  String get parkingsListActiveReservation => 'Reserva activa';

  @override
  String get parkingsListApplyFilters => 'Aplicar filtres';

  @override
  String get parkingsListClearAll => 'Netejar-ho tot';

  @override
  String get parkingsListClearFilters => 'Netejar filtres';

  @override
  String get parkingsListEmptySubtitle =>
      'Prova d\'ajustar els filtres de cerca';

  @override
  String get parkingsListEmptyTitle => 'No s\'han trobat aparcaments';

  @override
  String get parkingsListFilters => 'Filtres';

  @override
  String parkingsListFiltersWithCount(int count) {
    return 'Filtres ($count)';
  }

  @override
  String get parkingsListOnlyAvailable => 'Només disponibles';

  @override
  String get parkingsListOnlyAvailableSubtitle =>
      'Mostrar només aparcaments amb places lliures';

  @override
  String get parkingsListOnlyFavorites => 'Només preferits';

  @override
  String get parkingsListOnlyFavoritesSubtitle =>
      'Mostrar només aparcaments marcats com a preferits';

  @override
  String parkingsListResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aparcaments trobats',
      one: '$count aparcament trobat',
    );
    return '$_temp0';
  }

  @override
  String get parkingsListSearchHint => 'Cercar aparcaments...';

  @override
  String get parkingsListSortAvailability => 'Disponibilitat (més a menys)';

  @override
  String get parkingsListSortBy => 'Ordenar per';

  @override
  String get parkingsListSortName => 'Nom (A-Z)';

  @override
  String get parkingsListSortNone => 'Sense ordenar';

  @override
  String get profileAccountSettings => 'Configuració del compte';

  @override
  String get profileActivitySummary => 'Resum d\'activitat';

  @override
  String get profileAverageTime => 'Temps mitjà';

  @override
  String get profileByTimeout => 'Per temps esgotat';

  @override
  String get profileCancel => 'Cancel·lar';

  @override
  String profileCancellationRate(String rate) {
    return '$rate% del total';
  }

  @override
  String get profileCancelled => 'Cancel·lades';

  @override
  String get profileChangePassword => 'Canviar contrasenya';

  @override
  String get profileChangePasswordSubtitle =>
      'Actualitza la teua contrasenya d\'accés';

  @override
  String get profileCompleted => 'Completades';

  @override
  String get profileDefaultUser => 'Usuari';

  @override
  String get profileDeleteAccount => 'Eliminar compte';

  @override
  String get profileDeleteAccountSubtitle =>
      'Eliminar permanentment el teu compte';

  @override
  String get profileDetailedStats => 'Estadístiques detallades';

  @override
  String get profileExpired => 'Expirades';

  @override
  String get profileFavorites => 'Preferits';

  @override
  String get profileLogout => 'Tancar sessió';

  @override
  String get profileLogoutConfirmContent =>
      'Segur que vols tancar la teua sessió?';

  @override
  String get profileLogoutConfirmTitle => 'Tancar sessió?';

  @override
  String get profileLogoutError => 'Error en tancar la sessió';

  @override
  String get profileLogoutSubtitle => 'Eixir del teu compte';

  @override
  String get profileMarkedParkings => 'Aparcaments marcats';

  @override
  String profileMemberSince(String date) {
    return 'Membre des de $date';
  }

  @override
  String get profilePerReservation => 'Per reserva';

  @override
  String profileSuccessRate(String rate) {
    return '$rate% èxit';
  }

  @override
  String get profileTotalReservations => 'Reserves totals';

  @override
  String get profileTotalTime => 'Temps total';

  @override
  String get sendPasswordAdditionalTitle => 'Instruccions addicionals:';

  @override
  String get sendPasswordBackToLoginButton => 'Tornar a l\'inici de sessió';

  @override
  String get sendPasswordCancelButton => 'Cancel·lar';

  @override
  String get sendPasswordConfirmationMessage =>
      'Hem enviat les instruccions per a restablir la contrasenya a:';

  @override
  String get sendPasswordEmailHint => 'exemple@correu.com';

  @override
  String get sendPasswordEmailInvalid =>
      'Introdueix un correu electrònic vàlid';

  @override
  String get sendPasswordEmailLabel => 'Correu electrònic';

  @override
  String get sendPasswordEmailRequired => 'Introdueix el teu correu electrònic';

  @override
  String get sendPasswordError => 'S\'ha produït un error en enviar el correu';

  @override
  String get sendPasswordInstructions =>
      'Introdueix el teu correu i t\'enviarem instruccions per a restablir la contrasenya.';

  @override
  String get sendPasswordSendAgainButton => 'Tornar a enviar';

  @override
  String get sendPasswordSubmitButton => 'Rebre correu';

  @override
  String get sendPasswordSuccessAlert => 'Correu enviat correctament';

  @override
  String get sendPasswordTip1 => '• Revisa la teua safata d\'entrada';

  @override
  String get sendPasswordTip2 =>
      '• Si no trobes el correu, revisa la carpeta de correu brossa';

  @override
  String get sendPasswordTip3 => '• L\'enllaç caducarà en 24 hores';

  @override
  String get sendPasswordTip4 =>
      '• Si no reps el correu, pots tornar a enviar-lo';

  @override
  String get sendPasswordTitle => 'Recuperar contrasenya';

  @override
  String get settingsAboutSection => 'Quant a';

  @override
  String get settingsAccountSection => 'Compte';

  @override
  String get settingsAppSection => 'Configuració de l\'aplicació';

  @override
  String get settingsBiometric => 'Accés biomètric';

  @override
  String get settingsBiometricDisabled => 'Accés biomètric desactivat';

  @override
  String get settingsBiometricSubtitle =>
      'Desbloquejar l\'app amb empremta o Face ID';

  @override
  String get settingsCallSupport => 'Trucar a suport';

  @override
  String settingsCallSupportError(String phone) {
    return 'No es pot obrir el marcador automàticament.\nPer favor, truca manualment al $phone';
  }

  @override
  String get settingsCallSupportSubtitle =>
      'Contactar amb el nostre equip de suport';

  @override
  String get settingsChangePassword => 'Canviar contrasenya';

  @override
  String get settingsChangePasswordSubtitle =>
      'Actualitzar la teua contrasenya d\'accés';

  @override
  String get settingsDarkMode => 'Mode fosc';

  @override
  String get settingsDarkModeSubtitle => 'Usar tema fosc en l\'aplicació';

  @override
  String get settingsDeleteAccount => 'Eliminar compte';

  @override
  String get settingsDeleteAccountSubtitle =>
      'Eliminar permanentment el teu compte';

  @override
  String get settingsFaq => 'Preguntes freqüents';

  @override
  String get settingsFaqAnswer1 =>
      'Ves a la secció d\'Aparcaments, selecciona un aparcament disponible i prem \"Reservar\". Tindràs 30 minuts per a arribar.';

  @override
  String get settingsFaqAnswer2 =>
      'Sí, pots cancel·lar la teua reserva des de la pantalla de reserva activa abans de 30 minuts des del moment en què es va efectuar la reserva.';

  @override
  String get settingsFaqAnswer3 =>
      'Pots usar una plaça durant un màxim de 14 hores. Després d\'este temps, la plaça s\'alliberarà automàticament.';

  @override
  String get settingsFaqAnswer4 =>
      'Si no obris la porta en 30 minuts, la teua reserva es cancel·larà automàticament i la plaça quedarà disponible.';

  @override
  String get settingsFaqAnswer5 =>
      'No, només pots tindre una reserva activa alhora. Has de finalitzar el teu ús actual abans de fer una nova reserva.';

  @override
  String get settingsFaqQuestion1 => 'Com reserve una plaça?';

  @override
  String get settingsFaqQuestion2 => 'Puc cancel·lar la meua reserva?';

  @override
  String get settingsFaqQuestion3 => 'Quant de temps puc usar una plaça?';

  @override
  String get settingsFaqQuestion4 => 'Què passa si no arribe a temps?';

  @override
  String get settingsFaqQuestion5 => 'Puc tindre múltiples reserves?';

  @override
  String get settingsFaqSubtitle => 'Troba respostes a dubtes comuns';

  @override
  String get settingsHelpSection => 'Ajuda i suport';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageValue => 'Valencià';

  @override
  String get settingsNotifications => 'Notificacions';

  @override
  String get settingsNotificationsSubtitle =>
      'Rebre notificacions de reserves i recordatoris';

  @override
  String get settingsPrivacy => 'Política de privacitat';

  @override
  String get settingsPrivacyInDevelopment =>
      'Política de privacitat - Funcionalitat en desenvolupament';

  @override
  String get settingsPrivacySubtitle =>
      'Informació sobre el tractament de les teues dades';

  @override
  String get settingsTerms => 'Termes de servei';

  @override
  String get settingsTermsInDevelopment =>
      'Termes de servei - Funcionalitat en desenvolupament';

  @override
  String get settingsTermsSubtitle => 'Llig els nostres termes i condicions';

  @override
  String get settingsTutorial => 'Tutorial';

  @override
  String get settingsTutorialSubtitle => 'Aprén a usar l\'aplicació';

  @override
  String get settingsVersion => 'Versió';

  @override
  String get splashDescription =>
      'Sistema de reserva de places\nintel·ligents per a bicicletes';

  @override
  String get splashInitializing => 'Inicialitzant...';
}
