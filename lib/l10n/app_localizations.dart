import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ca.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('es'),
    Locale('ca'),
  ];

  /// Boton para cancelar la reserva
  ///
  /// In es, this message translates to:
  /// **'Cancelar reserva'**
  String get activeCancelReservation;

  /// SnackBar de error al cancelar la reserva
  ///
  /// In es, this message translates to:
  /// **'Error al cancelar la reserva'**
  String get activeCancelReservationError;

  /// Error cuando la pasarela no consigue abrir la puerta
  ///
  /// In es, this message translates to:
  /// **'No se ha podido abrir la puerta'**
  String get activeDoorOpenError;

  /// SnackBar de exito al abrir la puerta
  ///
  /// In es, this message translates to:
  /// **'Puerta abierta correctamente'**
  String get activeDoorOpenedSuccess;

  /// Modo degradado: la pasarela hardware no responde (RF-4.7)
  ///
  /// In es, this message translates to:
  /// **'La puerta no responde. Inténtalo de nuevo o contacta con soporte.'**
  String get activeDoorUnavailable;

  /// Titulo del modal de finalizacion
  ///
  /// In es, this message translates to:
  /// **'Instrucciones finales'**
  String get activeFinalInstructions;

  /// Boton para finalizar el uso
  ///
  /// In es, this message translates to:
  /// **'Finalizar uso'**
  String get activeFinishUsage;

  /// SnackBar de error al finalizar el uso
  ///
  /// In es, this message translates to:
  /// **'Error al finalizar el uso'**
  String get activeFinishUsageError;

  /// Paso 2 de finalizacion
  ///
  /// In es, this message translates to:
  /// **'Cierre la puerta'**
  String get activeInstructionCloseDoor;

  /// Paso 1 de finalizacion
  ///
  /// In es, this message translates to:
  /// **'Retire todas sus pertenencias'**
  String get activeInstructionRemoveBelongings;

  /// Paso 3 de finalizacion
  ///
  /// In es, this message translates to:
  /// **'La plaza quedará disponible\npara otros usuarios'**
  String get activeInstructionSpotAvailable;

  /// Instrucciones cuando la plaza esta en uso
  ///
  /// In es, this message translates to:
  /// **'Puedes abrir y cerrar la puerta tantas veces como necesites durante tu uso.'**
  String get activeInstructionsInUse;

  /// Instrucciones cuando la reserva esta activa
  ///
  /// In es, this message translates to:
  /// **'Abre la puerta para comenzar a usar la plaza. Tienes 30 minutos para llegar.'**
  String get activeInstructionsReserved;

  /// Tiempo maximo de uso permitido, ya formateado
  ///
  /// In es, this message translates to:
  /// **'Tiempo máximo: {time}'**
  String activeMaxTime(String time);

  /// Boton para abrir la puerta
  ///
  /// In es, this message translates to:
  /// **'Abrir puerta'**
  String get activeOpenDoor;

  /// SnackBar informativo al cancelar la reserva
  ///
  /// In es, this message translates to:
  /// **'Reserva cancelada'**
  String get activeReservationCancelled;

  /// Titulo del temporizador de reserva
  ///
  /// In es, this message translates to:
  /// **'Tiempo restante de reserva'**
  String get activeReservationTimeLeft;

  /// Insignia de estado: plaza en uso
  ///
  /// In es, this message translates to:
  /// **'En uso'**
  String get activeStatusInUse;

  /// Insignia de estado: reserva activa sin usar todavia
  ///
  /// In es, this message translates to:
  /// **'Reservada'**
  String get activeStatusReserved;

  /// Indicacion para cerrar el modal
  ///
  /// In es, this message translates to:
  /// **'Toca en cualquier parte para\ncontinuar'**
  String get activeTapToContinue;

  /// SnackBar de exito al finalizar el uso
  ///
  /// In es, this message translates to:
  /// **'Uso finalizado correctamente'**
  String get activeUsageFinishedSuccess;

  /// Titulo del temporizador de uso
  ///
  /// In es, this message translates to:
  /// **'Tiempo de uso'**
  String get activeUsageTime;

  /// Nombre de la aplicación
  ///
  /// In es, this message translates to:
  /// **'Aparcabicis'**
  String get appName;

  /// Botón para activar la biometría
  ///
  /// In es, this message translates to:
  /// **'Activar'**
  String get biometricEnableAccept;

  /// Explicación del diálogo de alta de biometría
  ///
  /// In es, this message translates to:
  /// **'La próxima vez podrás restaurar tu sesión con huella o Face ID, sin escribir la contraseña.'**
  String get biometricEnableMessage;

  /// Botón para posponer la activación de biometría
  ///
  /// In es, this message translates to:
  /// **'Ahora no'**
  String get biometricEnableSkip;

  /// Título del diálogo que ofrece activar la biometría
  ///
  /// In es, this message translates to:
  /// **'¿Activar acceso biométrico?'**
  String get biometricEnableTitle;

  /// Confirmación de biometría activada
  ///
  /// In es, this message translates to:
  /// **'Acceso biométrico activado'**
  String get biometricEnabledSuccess;

  /// Mensaje de fallback cuando la biometría falla
  ///
  /// In es, this message translates to:
  /// **'No se pudo verificar tu identidad. Inicia sesión con tu contraseña.'**
  String get biometricFallbackMessage;

  /// Motivo mostrado en el diálogo biométrico del sistema
  ///
  /// In es, this message translates to:
  /// **'Confirma tu identidad para acceder a Aparcabicis'**
  String get biometricPromptReason;

  /// Aviso de dispositivo sin biometría
  ///
  /// In es, this message translates to:
  /// **'Este dispositivo no tiene biometría configurada'**
  String get biometricUnavailable;

  /// Botón cancelar en cambiar contraseña
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get changePasswordCancelButton;

  /// Placeholder del campo confirmar nueva contraseña
  ///
  /// In es, this message translates to:
  /// **'Repite la nueva contraseña'**
  String get changePasswordConfirmNewHint;

  /// Etiqueta del campo confirmar nueva contraseña
  ///
  /// In es, this message translates to:
  /// **'Confirmar nueva contraseña'**
  String get changePasswordConfirmNewLabel;

  /// Validación: confirmación de nueva contraseña vacía
  ///
  /// In es, this message translates to:
  /// **'Por favor confirma tu nueva contraseña'**
  String get changePasswordConfirmNewRequired;

  /// Placeholder del campo contraseña actual
  ///
  /// In es, this message translates to:
  /// **'Tu contraseña actual'**
  String get changePasswordCurrentHint;

  /// Etiqueta del campo contraseña actual
  ///
  /// In es, this message translates to:
  /// **'Contraseña actual'**
  String get changePasswordCurrentLabel;

  /// Validación: contraseña actual vacía
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa tu contraseña actual'**
  String get changePasswordCurrentRequired;

  /// Placeholder del campo email en cambiar contraseña
  ///
  /// In es, this message translates to:
  /// **'Tu email actual'**
  String get changePasswordEmailHint;

  /// Validación: email inválido en cambiar contraseña
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa un email válido'**
  String get changePasswordEmailInvalid;

  /// Etiqueta del campo email en cambiar contraseña
  ///
  /// In es, this message translates to:
  /// **'Email'**
  String get changePasswordEmailLabel;

  /// Validación: email vacío en cambiar contraseña
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa tu email'**
  String get changePasswordEmailRequired;

  /// SnackBar de error al cambiar contraseña
  ///
  /// In es, this message translates to:
  /// **'Error al cambiar la contraseña'**
  String get changePasswordError;

  /// Validación: nuevas contraseñas no coinciden
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas nuevas no coinciden'**
  String get changePasswordMismatch;

  /// Placeholder del campo nueva contraseña
  ///
  /// In es, this message translates to:
  /// **'Mínimo 8 caracteres'**
  String get changePasswordNewHint;

  /// Etiqueta del campo nueva contraseña
  ///
  /// In es, this message translates to:
  /// **'Nueva contraseña'**
  String get changePasswordNewLabel;

  /// Validación: nueva contraseña vacía
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa una nueva contraseña'**
  String get changePasswordNewRequired;

  /// Validación: nueva contraseña igual a la actual
  ///
  /// In es, this message translates to:
  /// **'La nueva contraseña debe ser diferente a la actual'**
  String get changePasswordSameAsCurrent;

  /// Botón enviar en cambiar contraseña
  ///
  /// In es, this message translates to:
  /// **'Cambiar contraseña'**
  String get changePasswordSubmitButton;

  /// Título de la pantalla cambiar contraseña
  ///
  /// In es, this message translates to:
  /// **'Cambiar Contraseña'**
  String get changePasswordTitle;

  /// Validación: nueva contraseña demasiado corta
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos {count} caracteres'**
  String changePasswordTooShort(int count);

  /// Botón cancelar en crear usuario
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get createUserCancelButton;

  /// Placeholder del campo confirmar contraseña en crear usuario
  ///
  /// In es, this message translates to:
  /// **'Repite la contraseña'**
  String get createUserConfirmPasswordHint;

  /// Etiqueta del campo confirmar contraseña en crear usuario
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get createUserConfirmPasswordLabel;

  /// Validación: confirmación vacía en crear usuario
  ///
  /// In es, this message translates to:
  /// **'Por favor confirma tu contraseña'**
  String get createUserConfirmPasswordRequired;

  /// Placeholder del campo email en crear usuario
  ///
  /// In es, this message translates to:
  /// **'ejemplo@correo.com'**
  String get createUserEmailHint;

  /// Validación: email inválido en crear usuario
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa un email válido'**
  String get createUserEmailInvalid;

  /// Etiqueta del campo email en crear usuario
  ///
  /// In es, this message translates to:
  /// **'Email'**
  String get createUserEmailLabel;

  /// Validación: email vacío en crear usuario
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa tu email'**
  String get createUserEmailRequired;

  /// SnackBar de error al crear usuario
  ///
  /// In es, this message translates to:
  /// **'Error al crear el usuario'**
  String get createUserError;

  /// Placeholder del campo contraseña en crear usuario
  ///
  /// In es, this message translates to:
  /// **'Mínimo 8 caracteres'**
  String get createUserPasswordHint;

  /// Etiqueta del campo contraseña en crear usuario
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get createUserPasswordLabel;

  /// Validación: contraseñas no coinciden en crear usuario
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get createUserPasswordMismatch;

  /// Validación: contraseña vacía en crear usuario
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa una contraseña'**
  String get createUserPasswordRequired;

  /// Validación: contraseña demasiado corta en crear usuario
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos {count} caracteres'**
  String createUserPasswordTooShort(int count);

  /// Botón enviar en crear usuario
  ///
  /// In es, this message translates to:
  /// **'Crear usuario'**
  String get createUserSubmitButton;

  /// Título de la pantalla crear usuario
  ///
  /// In es, this message translates to:
  /// **'Crear Usuario'**
  String get createUserTitle;

  /// Botón cancelar (diálogo y formulario) de eliminar cuenta
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get deleteUserCancelButton;

  /// Botón confirmar del diálogo de eliminar cuenta
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get deleteUserConfirmButton;

  /// Contenido del diálogo de confirmación de eliminar cuenta
  ///
  /// In es, this message translates to:
  /// **'Esta acción eliminará permanentemente tu cuenta y no se puede deshacer.'**
  String get deleteUserConfirmContent;

  /// Placeholder del campo confirmar contraseña en eliminar cuenta
  ///
  /// In es, this message translates to:
  /// **'Repite tu contraseña'**
  String get deleteUserConfirmPasswordHint;

  /// Etiqueta del campo confirmar contraseña en eliminar cuenta
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get deleteUserConfirmPasswordLabel;

  /// Validación: confirmación vacía en eliminar cuenta
  ///
  /// In es, this message translates to:
  /// **'Por favor confirma tu contraseña'**
  String get deleteUserConfirmPasswordRequired;

  /// Título del diálogo de confirmación de eliminar cuenta
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro?'**
  String get deleteUserConfirmTitle;

  /// Validación: texto de confirmación incorrecto
  ///
  /// In es, this message translates to:
  /// **'Debes escribir exactamente \"ELIMINAR\"'**
  String get deleteUserConfirmationInvalid;

  /// Etiqueta del campo de texto de confirmación de borrado
  ///
  /// In es, this message translates to:
  /// **'Escribir \"ELIMINAR\" para confirmar'**
  String get deleteUserConfirmationLabel;

  /// Validación: texto de confirmación vacío
  ///
  /// In es, this message translates to:
  /// **'Por favor escribe ELIMINAR para confirmar'**
  String get deleteUserConfirmationRequired;

  /// Placeholder del campo email en eliminar cuenta
  ///
  /// In es, this message translates to:
  /// **'Tu email actual'**
  String get deleteUserEmailHint;

  /// Validación: email inválido en eliminar cuenta
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa un email válido'**
  String get deleteUserEmailInvalid;

  /// Etiqueta del campo email en eliminar cuenta
  ///
  /// In es, this message translates to:
  /// **'Email'**
  String get deleteUserEmailLabel;

  /// Validación: email vacío en eliminar cuenta
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa tu email'**
  String get deleteUserEmailRequired;

  /// SnackBar de error al eliminar cuenta
  ///
  /// In es, this message translates to:
  /// **'Error al eliminar la cuenta'**
  String get deleteUserError;

  /// Placeholder del campo contraseña en eliminar cuenta
  ///
  /// In es, this message translates to:
  /// **'Tu contraseña actual'**
  String get deleteUserPasswordHint;

  /// Etiqueta del campo contraseña en eliminar cuenta
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get deleteUserPasswordLabel;

  /// Validación: contraseñas no coinciden en eliminar cuenta
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get deleteUserPasswordMismatch;

  /// Validación: contraseña vacía en eliminar cuenta
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa tu contraseña'**
  String get deleteUserPasswordRequired;

  /// Botón enviar en eliminar cuenta
  ///
  /// In es, this message translates to:
  /// **'Eliminar cuenta'**
  String get deleteUserSubmitButton;

  /// Título de la pantalla eliminar cuenta
  ///
  /// In es, this message translates to:
  /// **'Eliminar Cuenta'**
  String get deleteUserTitle;

  /// Aviso destacado en eliminar cuenta
  ///
  /// In es, this message translates to:
  /// **'Esta acción es permanente y no se puede deshacer'**
  String get deleteUserWarning;

  /// Explicación del estado de reserva activa
  ///
  /// In es, this message translates to:
  /// **'Cuando tengas una reserva activa:\n\n• Estado \"Reservada\": Tienes 30 minutos para llegar\n• Estado \"En uso\": Puedes usar la plaza hasta 2 horas\n• Puedes abrir la puerta tantas veces como necesites\n• Finaliza tu uso cuando termines'**
  String get helpActiveContent;

  /// Título de la sección de reserva activa
  ///
  /// In es, this message translates to:
  /// **'Reserva activa'**
  String get helpActiveTitle;

  /// Botón cancelar
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get helpCancel;

  /// Descripción del chat en vivo
  ///
  /// In es, this message translates to:
  /// **'Respuesta inmediata durante horario laboral'**
  String get helpContactChatDesc;

  /// Título del método de contacto por chat
  ///
  /// In es, this message translates to:
  /// **'Chat en vivo'**
  String get helpContactChatTitle;

  /// Horario del chat en vivo
  ///
  /// In es, this message translates to:
  /// **'Disponible de 9:00 a 18:00'**
  String get helpContactChatValue;

  /// Descripción del email de soporte
  ///
  /// In es, this message translates to:
  /// **'Para problemas técnicos y consultas generales'**
  String get helpContactEmailDesc;

  /// Título del método de contacto por email
  ///
  /// In es, this message translates to:
  /// **'Email de soporte'**
  String get helpContactEmailTitle;

  /// Dirección de email de soporte (dato fijo)
  ///
  /// In es, this message translates to:
  /// **'soporte@aparcabicis.com'**
  String get helpContactEmailValue;

  /// Descripción del teléfono de emergencia
  ///
  /// In es, this message translates to:
  /// **'Disponible 24/7 para emergencias'**
  String get helpContactPhoneDesc;

  /// Título del método de contacto por teléfono
  ///
  /// In es, this message translates to:
  /// **'Teléfono de emergencia'**
  String get helpContactPhoneTitle;

  /// Número de teléfono de emergencia (dato fijo)
  ///
  /// In es, this message translates to:
  /// **'+34 900 123 456'**
  String get helpContactPhoneValue;

  /// Descripción de redes sociales
  ///
  /// In es, this message translates to:
  /// **'Síguenos para novedades y actualizaciones'**
  String get helpContactSocialDesc;

  /// Título del método de contacto por redes sociales
  ///
  /// In es, this message translates to:
  /// **'Redes sociales'**
  String get helpContactSocialTitle;

  /// Usuario de redes sociales (dato fijo)
  ///
  /// In es, this message translates to:
  /// **'@AparcabicisApp'**
  String get helpContactSocialValue;

  /// Título de la sección de contacto
  ///
  /// In es, this message translates to:
  /// **'Contacta con nosotros'**
  String get helpContactTitle;

  /// Contenido del diálogo de demo interactivo
  ///
  /// In es, this message translates to:
  /// **'El demo interactivo te guiará paso a paso por todas las funciones de la aplicación.'**
  String get helpDemoContent;

  /// SnackBar demo en desarrollo
  ///
  /// In es, this message translates to:
  /// **'Demo interactivo - Funcionalidad en desarrollo'**
  String get helpDemoInDevelopment;

  /// Título del diálogo de demo interactivo
  ///
  /// In es, this message translates to:
  /// **'Demo interactivo'**
  String get helpDemoTitle;

  /// Respuesta FAQ 10
  ///
  /// In es, this message translates to:
  /// **'El servicio básico es gratuito. Solo pagas si excedes el tiempo máximo de uso o por servicios premium adicionales.'**
  String get helpFaq10Answer;

  /// Pregunta FAQ 10
  ///
  /// In es, this message translates to:
  /// **'¿Hay algún coste por usar el servicio?'**
  String get helpFaq10Question;

  /// Respuesta FAQ 1
  ///
  /// In es, this message translates to:
  /// **'Ve a la sección de Aparcamientos, selecciona un aparcamiento disponible y presiona \"Reservar\". Tendrás 30 minutos para llegar y abrir la puerta.'**
  String get helpFaq1Answer;

  /// Pregunta FAQ 1
  ///
  /// In es, this message translates to:
  /// **'¿Cómo reservo una plaza?'**
  String get helpFaq1Question;

  /// Respuesta FAQ 2
  ///
  /// In es, this message translates to:
  /// **'Sí, puedes cancelar tu reserva desde la pantalla de reserva activa presionando \"Cancelar reserva\". Esto liberará la plaza para otros usuarios.'**
  String get helpFaq2Answer;

  /// Pregunta FAQ 2
  ///
  /// In es, this message translates to:
  /// **'¿Puedo cancelar mi reserva?'**
  String get helpFaq2Question;

  /// Respuesta FAQ 3
  ///
  /// In es, this message translates to:
  /// **'Puedes usar una plaza por un máximo de 2 horas. El timer comenzará cuando abras la puerta por primera vez.'**
  String get helpFaq3Answer;

  /// Pregunta FAQ 3
  ///
  /// In es, this message translates to:
  /// **'¿Cuánto tiempo puedo usar una plaza?'**
  String get helpFaq3Question;

  /// Respuesta FAQ 4
  ///
  /// In es, this message translates to:
  /// **'Si no abres la puerta en 30 minutos, tu reserva se cancelará automáticamente y la plaza quedará disponible para otros usuarios.'**
  String get helpFaq4Answer;

  /// Pregunta FAQ 4
  ///
  /// In es, this message translates to:
  /// **'¿Qué pasa si no llego a tiempo?'**
  String get helpFaq4Question;

  /// Respuesta FAQ 5
  ///
  /// In es, this message translates to:
  /// **'No, solo puedes tener una reserva activa a la vez. Debes finalizar tu uso actual antes de hacer una nueva reserva.'**
  String get helpFaq5Answer;

  /// Pregunta FAQ 5
  ///
  /// In es, this message translates to:
  /// **'¿Puedo tener múltiples reservas?'**
  String get helpFaq5Question;

  /// Respuesta FAQ 6
  ///
  /// In es, this message translates to:
  /// **'Presiona el icono de estrella en cualquier aparcamiento para marcarlo como favorito. Luego puedes filtrar para ver solo tus favoritos.'**
  String get helpFaq6Answer;

  /// Pregunta FAQ 6
  ///
  /// In es, this message translates to:
  /// **'¿Cómo marco un aparcamiento como favorito?'**
  String get helpFaq6Question;

  /// Respuesta FAQ 7
  ///
  /// In es, this message translates to:
  /// **'Sí, ve a la pestaña \"Historial\" para ver todas tus reservas anteriores, estadísticas de uso y filtrar por estado.'**
  String get helpFaq7Answer;

  /// Pregunta FAQ 7
  ///
  /// In es, this message translates to:
  /// **'¿Puedo ver mi historial de reservas?'**
  String get helpFaq7Question;

  /// Respuesta FAQ 8
  ///
  /// In es, this message translates to:
  /// **'Necesitas conexión a internet para hacer reservas y abrir puertas. Sin embargo, puedes ver tu historial y configuración sin conexión.'**
  String get helpFaq8Answer;

  /// Pregunta FAQ 8
  ///
  /// In es, this message translates to:
  /// **'¿La aplicación funciona sin internet?'**
  String get helpFaq8Question;

  /// Respuesta FAQ 9
  ///
  /// In es, this message translates to:
  /// **'Ve a Perfil > Configuración de cuenta > Cambiar contraseña, o desde Ajustes > Cuenta > Cambiar contraseña.'**
  String get helpFaq9Answer;

  /// Pregunta FAQ 9
  ///
  /// In es, this message translates to:
  /// **'¿Cómo cambio mi contraseña?'**
  String get helpFaq9Question;

  /// Ciudad de la oficina (dato fijo, sin traducir)
  ///
  /// In es, this message translates to:
  /// **'28001 Madrid, España'**
  String get helpOfficeCity;

  /// Nombre de la empresa (nombre propio, sin traducir)
  ///
  /// In es, this message translates to:
  /// **'Aparcabicis S.L.'**
  String get helpOfficeName;

  /// Horario de sábados
  ///
  /// In es, this message translates to:
  /// **'Sábados: 10:00 - 14:00'**
  String get helpOfficeSaturday;

  /// Etiqueta del horario de atención
  ///
  /// In es, this message translates to:
  /// **'Horario de atención:'**
  String get helpOfficeScheduleLabel;

  /// Dirección de la oficina (dato fijo, sin traducir)
  ///
  /// In es, this message translates to:
  /// **'Calle Mayor, 123'**
  String get helpOfficeStreet;

  /// Horario de domingos
  ///
  /// In es, this message translates to:
  /// **'Domingos: Cerrado'**
  String get helpOfficeSunday;

  /// Título del bloque de oficinas
  ///
  /// In es, this message translates to:
  /// **'Oficinas centrales'**
  String get helpOfficeTitle;

  /// Horario de lunes a viernes
  ///
  /// In es, this message translates to:
  /// **'Lunes a Viernes: 9:00 - 18:00'**
  String get helpOfficeWeekdays;

  /// Título de la sección de acciones rápidas
  ///
  /// In es, this message translates to:
  /// **'Acciones rápidas'**
  String get helpQuickActionsTitle;

  /// Descripción de la acción de valorar la app
  ///
  /// In es, this message translates to:
  /// **'Ayúdanos dejando una reseña en la tienda'**
  String get helpRateDesc;

  /// SnackBar valorar app en desarrollo
  ///
  /// In es, this message translates to:
  /// **'Valorar app - Funcionalidad en desarrollo'**
  String get helpRateInDevelopment;

  /// Título de la acción de valorar la app
  ///
  /// In es, this message translates to:
  /// **'Valorar la app'**
  String get helpRateTitle;

  /// Descripción de la acción de reportar problema
  ///
  /// In es, this message translates to:
  /// **'Informa sobre aparcamientos dañados o problemas técnicos'**
  String get helpReportDesc;

  /// SnackBar reportar problema en desarrollo
  ///
  /// In es, this message translates to:
  /// **'Reportar problema - Funcionalidad en desarrollo'**
  String get helpReportInDevelopment;

  /// Título de la acción de reportar problema
  ///
  /// In es, this message translates to:
  /// **'Reportar un problema'**
  String get helpReportTitle;

  /// Pasos para hacer una reserva
  ///
  /// In es, this message translates to:
  /// **'1. Ve a la sección \"Aparcamientos\"\n2. Selecciona un aparcamiento disponible\n3. Presiona \"Reservar\"\n4. Tienes 30 minutos para llegar\n5. Abre la puerta para comenzar a usar la plaza'**
  String get helpReserveContent;

  /// Título de la sección de reserva
  ///
  /// In es, this message translates to:
  /// **'Cómo hacer una reserva'**
  String get helpReserveTitle;

  /// Botón iniciar
  ///
  /// In es, this message translates to:
  /// **'Iniciar'**
  String get helpStart;

  /// Botón para iniciar el demo interactivo
  ///
  /// In es, this message translates to:
  /// **'Iniciar demo interactivo'**
  String get helpStartDemo;

  /// Descripción de la acción de sugerir mejora
  ///
  /// In es, this message translates to:
  /// **'Comparte tus ideas para mejorar la aplicación'**
  String get helpSuggestDesc;

  /// SnackBar sugerir mejora en desarrollo
  ///
  /// In es, this message translates to:
  /// **'Sugerir mejora - Funcionalidad en desarrollo'**
  String get helpSuggestInDevelopment;

  /// Título de la acción de sugerir mejora
  ///
  /// In es, this message translates to:
  /// **'Sugerir mejora'**
  String get helpSuggestTitle;

  /// Pestaña de contacto
  ///
  /// In es, this message translates to:
  /// **'Contacto'**
  String get helpTabContact;

  /// Pestaña de preguntas frecuentes
  ///
  /// In es, this message translates to:
  /// **'FAQ'**
  String get helpTabFaq;

  /// Pestaña de tutorial
  ///
  /// In es, this message translates to:
  /// **'Tutorial'**
  String get helpTabTutorial;

  /// Lista de consejos útiles
  ///
  /// In es, this message translates to:
  /// **'• Marca como favoritos los aparcamientos que uses frecuentemente\n• Revisa tu historial para ver estadísticas de uso\n• Activa las notificaciones para recordatorios\n• Usa los filtros para encontrar aparcamientos más rápido\n• Cancela tu reserva si no vas a usarla'**
  String get helpTipsContent;

  /// Título de la sección de consejos
  ///
  /// In es, this message translates to:
  /// **'Consejos útiles'**
  String get helpTipsTitle;

  /// Título de la pantalla de ayuda
  ///
  /// In es, this message translates to:
  /// **'Ayuda y Tutorial'**
  String get helpTitle;

  /// Descripción de las funciones de la app
  ///
  /// In es, this message translates to:
  /// **'• Lista: Ve todos los aparcamientos en formato lista\n• Mapa: Visualiza los aparcamientos en un mapa interactivo\n• Favoritos: Marca tus aparcamientos preferidos\n• Filtros: Busca por disponibilidad o favoritos\n• Historial: Revisa tus reservas anteriores'**
  String get helpUsingContent;

  /// Título de la sección de uso de la app
  ///
  /// In es, this message translates to:
  /// **'Usando la aplicación'**
  String get helpUsingTitle;

  /// Texto de bienvenida
  ///
  /// In es, this message translates to:
  /// **'Tu aplicación para reservar plazas de aparcamiento para bicicletas de forma inteligente.'**
  String get helpWelcomeContent;

  /// Título de la sección de bienvenida
  ///
  /// In es, this message translates to:
  /// **'Bienvenido a Aparcabicis'**
  String get helpWelcomeTitle;

  /// Opcion de filtro: todos los estados
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get historyAll;

  /// Estado de reserva cancelada
  ///
  /// In es, this message translates to:
  /// **'Cancelada'**
  String get historyCardCancelled;

  /// Estado de reserva completada
  ///
  /// In es, this message translates to:
  /// **'Completada'**
  String get historyCardCompleted;

  /// Coste de la reserva con símbolo de euro
  ///
  /// In es, this message translates to:
  /// **'€{cost}'**
  String historyCardCost(String cost);

  /// Estado de reserva expirada
  ///
  /// In es, this message translates to:
  /// **'Expirada'**
  String get historyCardExpired;

  /// Texto para duración sin finalizar
  ///
  /// In es, this message translates to:
  /// **'Sin finalizar'**
  String get historyCardUnfinished;

  /// Boton para cerrar el panel de detalles
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get historyClose;

  /// Titulo de tarjeta: reservas completadas
  ///
  /// In es, this message translates to:
  /// **'Completadas'**
  String get historyCompleted;

  /// Etiqueta de detalle: coste
  ///
  /// In es, this message translates to:
  /// **'Coste'**
  String get historyLabelCost;

  /// Etiqueta de detalle: fecha
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get historyLabelDate;

  /// Etiqueta de detalle: duracion
  ///
  /// In es, this message translates to:
  /// **'Duración'**
  String get historyLabelDuration;

  /// Etiqueta de detalle: nombre del aparcamiento
  ///
  /// In es, this message translates to:
  /// **'Aparcamiento'**
  String get historyLabelParking;

  /// Estado vacio sin filtro
  ///
  /// In es, this message translates to:
  /// **'No hay reservas en el historial'**
  String get historyNoReservations;

  /// Estado vacio con filtro aplicado; status es el estado en minusculas
  ///
  /// In es, this message translates to:
  /// **'No hay reservas {status}'**
  String historyNoReservationsFiltered(String status);

  /// Titulo del panel de detalles
  ///
  /// In es, this message translates to:
  /// **'Detalles de la reserva'**
  String get historyReservationDetails;

  /// Sugerencia en estado vacio sin filtro
  ///
  /// In es, this message translates to:
  /// **'Tus reservas aparecerán aquí una vez que las completes'**
  String get historyReservationsWillAppear;

  /// Contador de reservas filtradas encontradas
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{{count} reserva encontrada} other{{count} reservas encontradas}}'**
  String historyResultsCount(int count);

  /// Boton para quitar el filtro
  ///
  /// In es, this message translates to:
  /// **'Mostrar todas'**
  String get historyShowAll;

  /// Opcion de orden: menor duracion
  ///
  /// In es, this message translates to:
  /// **'- Duración'**
  String get historySortDurationAsc;

  /// Opcion de orden: mayor duracion
  ///
  /// In es, this message translates to:
  /// **'+ Duración'**
  String get historySortDurationDesc;

  /// Etiqueta del desplegable de ordenacion
  ///
  /// In es, this message translates to:
  /// **'Ordenar'**
  String get historySortLabel;

  /// Opcion de orden: mas antiguo primero
  ///
  /// In es, this message translates to:
  /// **'Antiguo'**
  String get historySortOldest;

  /// Opcion de orden: mas reciente primero
  ///
  /// In es, this message translates to:
  /// **'Reciente'**
  String get historySortRecent;

  /// Titulo de la seccion de estadisticas
  ///
  /// In es, this message translates to:
  /// **'Estadísticas'**
  String get historyStatistics;

  /// Etiqueta de estado (filtro y detalle)
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get historyStatus;

  /// Texto de estado: canceladas
  ///
  /// In es, this message translates to:
  /// **'Canceladas'**
  String get historyStatusCancelled;

  /// Texto de estado: completadas
  ///
  /// In es, this message translates to:
  /// **'Completadas'**
  String get historyStatusCompleted;

  /// Texto de estado: expiradas
  ///
  /// In es, this message translates to:
  /// **'Expiradas'**
  String get historyStatusExpired;

  /// Subtitulo de tarjeta: porcentaje de exito
  ///
  /// In es, this message translates to:
  /// **'{rate}% éxito'**
  String historySuccessRate(Object rate);

  /// Titulo de tarjeta: total de reservas
  ///
  /// In es, this message translates to:
  /// **'Total reservas'**
  String get historyTotalReservations;

  /// Titulo de tarjeta: tiempo total de uso
  ///
  /// In es, this message translates to:
  /// **'Tiempo total'**
  String get historyTotalTime;

  /// Sugerencia en estado vacio con filtro
  ///
  /// In es, this message translates to:
  /// **'Intenta cambiar el filtro para ver más reservas'**
  String get historyTryChangeFilter;

  /// Mensaje de la pantalla de bloqueo
  ///
  /// In es, this message translates to:
  /// **'Desbloquea con tu huella o Face ID para continuar'**
  String get lockMessage;

  /// Botón para reintentar el desbloqueo biométrico
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get lockRetry;

  /// Título de la pantalla de bloqueo biométrico
  ///
  /// In es, this message translates to:
  /// **'App bloqueada'**
  String get lockTitle;

  /// Botón para salir del bloqueo e iniciar sesión con contraseña
  ///
  /// In es, this message translates to:
  /// **'Usar contraseña'**
  String get lockUsePassword;

  /// Placeholder del campo email en login
  ///
  /// In es, this message translates to:
  /// **'ejemplo@correo.com'**
  String get loginEmailHint;

  /// Validación: email inválido en login
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa un email válido'**
  String get loginEmailInvalid;

  /// Etiqueta del campo email en login
  ///
  /// In es, this message translates to:
  /// **'Email'**
  String get loginEmailLabel;

  /// Validación: email vacío en login
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa tu email'**
  String get loginEmailRequired;

  /// SnackBar de error genérico al iniciar sesión
  ///
  /// In es, this message translates to:
  /// **'Error al iniciar sesión'**
  String get loginError;

  /// SnackBar de credenciales inválidas
  ///
  /// In es, this message translates to:
  /// **'Email o contraseña incorrectos'**
  String get loginInvalidCredentials;

  /// Opción de menú: cambiar contraseña
  ///
  /// In es, this message translates to:
  /// **'Cambiar contraseña'**
  String get loginMenuChangePassword;

  /// Opción de menú: crear usuario
  ///
  /// In es, this message translates to:
  /// **'Crear usuario'**
  String get loginMenuCreateUser;

  /// Opción de menú: eliminar usuario
  ///
  /// In es, this message translates to:
  /// **'Eliminar usuario'**
  String get loginMenuDeleteUser;

  /// Opción de menú: recuperar contraseña
  ///
  /// In es, this message translates to:
  /// **'Recuperar contraseña'**
  String get loginMenuRecoverPassword;

  /// Placeholder del campo contraseña en login
  ///
  /// In es, this message translates to:
  /// **'Mínimo 8 caracteres'**
  String get loginPasswordHint;

  /// Etiqueta del campo contraseña en login
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get loginPasswordLabel;

  /// Validación: contraseña vacía en login
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa tu contraseña'**
  String get loginPasswordRequired;

  /// Validación: contraseña demasiado corta en login
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos {count} caracteres'**
  String loginPasswordTooShort(int count);

  /// Etiqueta del checkbox recordar sesión
  ///
  /// In es, this message translates to:
  /// **'Recuérdame'**
  String get loginRememberMe;

  /// Botón principal de login
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get loginSignInButton;

  /// SnackBar de éxito al iniciar sesión
  ///
  /// In es, this message translates to:
  /// **'Inicio de sesión exitoso'**
  String get loginSuccess;

  /// Insignia en la barra superior cuando hay una reserva en curso
  ///
  /// In es, this message translates to:
  /// **'Reserva activa'**
  String get mainActiveReservation;

  /// Tooltip del botón de cerrar sesión
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get mainLogout;

  /// Etiqueta de pestaña inferior de historial
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get mainTabHistory;

  /// Etiqueta de la pestaña de vista en lista
  ///
  /// In es, this message translates to:
  /// **'Lista'**
  String get mainTabList;

  /// Etiqueta de la pestaña de vista en mapa
  ///
  /// In es, this message translates to:
  /// **'Mapa'**
  String get mainTabMap;

  /// Etiqueta de pestaña inferior de aparcamientos
  ///
  /// In es, this message translates to:
  /// **'Aparcamientos'**
  String get mainTabParkings;

  /// Etiqueta de pestaña inferior de perfil
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get mainTabProfile;

  /// Etiqueta de pestaña inferior de ajustes
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get mainTabSettings;

  /// Mensaje al marcar un aparcamiento como favorito
  ///
  /// In es, this message translates to:
  /// **'{name} añadido a favoritos'**
  String mapAddedToFavorites(String name);

  /// Error cuando ya existe una reserva activa
  ///
  /// In es, this message translates to:
  /// **'Ya tienes una reserva activa'**
  String get mapAlreadyActiveReservation;

  /// Mensaje al recentrar el mapa en la ciudad
  ///
  /// In es, this message translates to:
  /// **'Centrando en {city}'**
  String mapCenteringOn(String city);

  /// Cancelar la reserva tras el aviso de ETA
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get mapEtaWarningCancel;

  /// Explicación del aviso de ETA (HU-4)
  ///
  /// In es, this message translates to:
  /// **'Tardarías unos {minutes} min en llegar, y la reserva solo se mantiene {window} min. ¿Quieres reservar igualmente?'**
  String mapEtaWarningMessage(int minutes, int window);

  /// Confirmar reserva pese al aviso de ETA
  ///
  /// In es, this message translates to:
  /// **'Reservar igualmente'**
  String get mapEtaWarningReserve;

  /// Título del aviso de ETA mayor que la ventana
  ///
  /// In es, this message translates to:
  /// **'Puede que no llegues a tiempo'**
  String get mapEtaWarningTitle;

  /// Fragmento del marcador con plazas libres
  ///
  /// In es, this message translates to:
  /// **'{count} plazas libres'**
  String mapFreeSpots(int count);

  /// Aviso mientras se obtiene la posición del usuario
  ///
  /// In es, this message translates to:
  /// **'Obteniendo tu ubicación...'**
  String get mapLocating;

  /// Permiso de ubicación denegado
  ///
  /// In es, this message translates to:
  /// **'Necesitamos tu ubicación para centrar el mapa'**
  String get mapLocationDenied;

  /// Permiso denegado permanentemente
  ///
  /// In es, this message translates to:
  /// **'Permiso de ubicación bloqueado. Actívalo en los ajustes del sistema.'**
  String get mapLocationDeniedForever;

  /// Servicio de localización apagado
  ///
  /// In es, this message translates to:
  /// **'La ubicación del dispositivo está desactivada'**
  String get mapLocationServiceDisabled;

  /// Error genérico al obtener la posición
  ///
  /// In es, this message translates to:
  /// **'No se ha podido obtener tu ubicación'**
  String get mapLocationUnavailable;

  /// Título del panel de aparcamientos cercanos
  ///
  /// In es, this message translates to:
  /// **'Aparcamientos cercanos'**
  String get mapNearbyTitle;

  /// Error cuando no quedan plazas para reservar
  ///
  /// In es, this message translates to:
  /// **'No hay plazas disponibles en este aparcamiento'**
  String get mapNoSpotsAvailable;

  /// Botón deshabilitado cuando no hay plazas
  ///
  /// In es, this message translates to:
  /// **'No disponible'**
  String get mapNotAvailable;

  /// Acción para abrir los ajustes del sistema
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get mapOpenSettings;

  /// Mensaje al desmarcar un aparcamiento como favorito
  ///
  /// In es, this message translates to:
  /// **'{name} eliminado de favoritos'**
  String mapRemovedFromFavorites(String name);

  /// Mensaje de éxito al crear la reserva
  ///
  /// In es, this message translates to:
  /// **'Reserva creada exitosamente en {name}'**
  String mapReservationCreated(String name);

  /// Error genérico al crear la reserva
  ///
  /// In es, this message translates to:
  /// **'Error al crear la reserva'**
  String get mapReservationError;

  /// Botón de reservar en la tarjeta del mapa
  ///
  /// In es, this message translates to:
  /// **'Reservar'**
  String get mapReserve;

  /// ETA y distancia de la ruta
  ///
  /// In es, this message translates to:
  /// **'{minutes} min en bici · {distance}'**
  String mapRouteEta(int minutes, String distance);

  /// ETA aproximado cuando no hay ruta real de Google
  ///
  /// In es, this message translates to:
  /// **'~{minutes} min en bici · {distance} (estimado)'**
  String mapRouteEtaEstimated(int minutes, String distance);

  /// Falta la ubicación para trazar la ruta
  ///
  /// In es, this message translates to:
  /// **'Activa tu ubicación para ver la ruta'**
  String get mapRouteNeedsLocation;

  /// Error al calcular la ruta
  ///
  /// In es, this message translates to:
  /// **'No se ha podido calcular la ruta'**
  String get mapRouteUnavailable;

  /// Etiqueta de disponibilidad en la tarjeta del aparcamiento
  ///
  /// In es, this message translates to:
  /// **'{available} de {total} disponibles'**
  String mapSpotsAvailable(int available, int total);

  /// Texto del botón cuando hay una reserva activa
  ///
  /// In es, this message translates to:
  /// **'Reserva activa'**
  String get parkingCardActiveReservation;

  /// Tooltip para agregar a favoritos
  ///
  /// In es, this message translates to:
  /// **'Agregar a favoritos'**
  String get parkingCardAddFavorite;

  /// SnackBar al añadir un aparcamiento a favoritos
  ///
  /// In es, this message translates to:
  /// **'{name} añadido a favoritos'**
  String parkingCardAddedToFavorites(String name);

  /// Error cuando ya existe una reserva activa
  ///
  /// In es, this message translates to:
  /// **'Ya tienes una reserva activa'**
  String get parkingCardAlreadyReserved;

  /// Texto del botón cuando no hay plazas
  ///
  /// In es, this message translates to:
  /// **'Sin plazas'**
  String get parkingCardNoSpots;

  /// Error cuando no hay plazas disponibles
  ///
  /// In es, this message translates to:
  /// **'No hay plazas disponibles en este aparcamiento'**
  String get parkingCardNoSpotsAvailable;

  /// Tooltip para quitar de favoritos
  ///
  /// In es, this message translates to:
  /// **'Quitar de favoritos'**
  String get parkingCardRemoveFavorite;

  /// SnackBar al eliminar un aparcamiento de favoritos
  ///
  /// In es, this message translates to:
  /// **'{name} eliminado de favoritos'**
  String parkingCardRemovedFromFavorites(String name);

  /// SnackBar de reserva creada con éxito
  ///
  /// In es, this message translates to:
  /// **'Reserva creada exitosamente en {name}'**
  String parkingCardReservationCreated(String name);

  /// Error al crear la reserva
  ///
  /// In es, this message translates to:
  /// **'Error al crear la reserva'**
  String get parkingCardReservationError;

  /// Texto del botón para reservar
  ///
  /// In es, this message translates to:
  /// **'Reservar'**
  String get parkingCardReserve;

  /// Insignia de reserva activa en la lista
  ///
  /// In es, this message translates to:
  /// **'Reserva activa'**
  String get parkingsListActiveReservation;

  /// Botón para aplicar filtros y cerrar el diálogo
  ///
  /// In es, this message translates to:
  /// **'Aplicar filtros'**
  String get parkingsListApplyFilters;

  /// Botón para restablecer todos los filtros del diálogo
  ///
  /// In es, this message translates to:
  /// **'Limpiar todo'**
  String get parkingsListClearAll;

  /// Botón para limpiar filtros en el estado vacío
  ///
  /// In es, this message translates to:
  /// **'Limpiar filtros'**
  String get parkingsListClearFilters;

  /// Subtítulo del estado vacío
  ///
  /// In es, this message translates to:
  /// **'Intenta ajustar los filtros de búsqueda'**
  String get parkingsListEmptySubtitle;

  /// Título del estado vacío de la lista
  ///
  /// In es, this message translates to:
  /// **'No se encontraron aparcamientos'**
  String get parkingsListEmptyTitle;

  /// Botón/título de filtros sin filtros activos
  ///
  /// In es, this message translates to:
  /// **'Filtros'**
  String get parkingsListFilters;

  /// Botón de filtros con número de filtros activos
  ///
  /// In es, this message translates to:
  /// **'Filtros ({count})'**
  String parkingsListFiltersWithCount(int count);

  /// Título del filtro de solo disponibles
  ///
  /// In es, this message translates to:
  /// **'Solo disponibles'**
  String get parkingsListOnlyAvailable;

  /// Subtítulo del filtro de solo disponibles
  ///
  /// In es, this message translates to:
  /// **'Mostrar solo aparcamientos con plazas libres'**
  String get parkingsListOnlyAvailableSubtitle;

  /// Título del filtro de solo favoritos
  ///
  /// In es, this message translates to:
  /// **'Solo favoritos'**
  String get parkingsListOnlyFavorites;

  /// Subtítulo del filtro de solo favoritos
  ///
  /// In es, this message translates to:
  /// **'Mostrar solo aparcamientos marcados como favoritos'**
  String get parkingsListOnlyFavoritesSubtitle;

  /// Número de aparcamientos encontrados
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{{count} aparcamiento encontrado} other{{count} aparcamientos encontrados}}'**
  String parkingsListResultsCount(int count);

  /// Texto de sugerencia del campo de búsqueda
  ///
  /// In es, this message translates to:
  /// **'Buscar aparcamientos...'**
  String get parkingsListSearchHint;

  /// Opción de orden: por disponibilidad
  ///
  /// In es, this message translates to:
  /// **'Disponibilidad (más a menos)'**
  String get parkingsListSortAvailability;

  /// Encabezado de opciones de orden
  ///
  /// In es, this message translates to:
  /// **'Ordenar por'**
  String get parkingsListSortBy;

  /// Opción de orden por distancia
  ///
  /// In es, this message translates to:
  /// **'Distancia (más cercano)'**
  String get parkingsListSortDistance;

  /// Opción de orden: por nombre
  ///
  /// In es, this message translates to:
  /// **'Nombre (A-Z)'**
  String get parkingsListSortName;

  /// Opción de orden: ninguno
  ///
  /// In es, this message translates to:
  /// **'Sin ordenar'**
  String get parkingsListSortNone;

  /// Título de la sección de acciones de cuenta
  ///
  /// In es, this message translates to:
  /// **'Configuración de cuenta'**
  String get profileAccountSettings;

  /// Título de la tarjeta de estadísticas rápidas
  ///
  /// In es, this message translates to:
  /// **'Resumen de actividad'**
  String get profileActivitySummary;

  /// Título de tarjeta de tiempo promedio por reserva
  ///
  /// In es, this message translates to:
  /// **'Tiempo promedio'**
  String get profileAverageTime;

  /// Subtítulo de reservas expiradas por tiempo agotado
  ///
  /// In es, this message translates to:
  /// **'Por timeout'**
  String get profileByTimeout;

  /// Botón de cancelar en el diálogo de cierre de sesión
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get profileCancel;

  /// Porcentaje de reservas canceladas respecto al total
  ///
  /// In es, this message translates to:
  /// **'{rate}% del total'**
  String profileCancellationRate(String rate);

  /// Título de tarjeta de reservas canceladas
  ///
  /// In es, this message translates to:
  /// **'Canceladas'**
  String get profileCancelled;

  /// Acción para cambiar la contraseña
  ///
  /// In es, this message translates to:
  /// **'Cambiar contraseña'**
  String get profileChangePassword;

  /// Subtítulo de la acción cambiar contraseña
  ///
  /// In es, this message translates to:
  /// **'Actualiza tu contraseña de acceso'**
  String get profileChangePasswordSubtitle;

  /// Título de tarjeta de reservas completadas
  ///
  /// In es, this message translates to:
  /// **'Completadas'**
  String get profileCompleted;

  /// Nombre por defecto cuando el usuario no tiene email
  ///
  /// In es, this message translates to:
  /// **'Usuario'**
  String get profileDefaultUser;

  /// Acción para eliminar la cuenta
  ///
  /// In es, this message translates to:
  /// **'Eliminar cuenta'**
  String get profileDeleteAccount;

  /// Subtítulo de la acción eliminar cuenta
  ///
  /// In es, this message translates to:
  /// **'Eliminar permanentemente tu cuenta'**
  String get profileDeleteAccountSubtitle;

  /// Título de la sección de estadísticas detalladas
  ///
  /// In es, this message translates to:
  /// **'Estadísticas detalladas'**
  String get profileDetailedStats;

  /// Título de tarjeta de reservas expiradas
  ///
  /// In es, this message translates to:
  /// **'Expiradas'**
  String get profileExpired;

  /// Título de tarjeta de aparcamientos favoritos
  ///
  /// In es, this message translates to:
  /// **'Favoritos'**
  String get profileFavorites;

  /// Acción y botón para cerrar sesión
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get profileLogout;

  /// Contenido del diálogo de confirmación de cierre de sesión
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres cerrar tu sesión?'**
  String get profileLogoutConfirmContent;

  /// Título del diálogo de confirmación de cierre de sesión
  ///
  /// In es, this message translates to:
  /// **'¿Cerrar sesión?'**
  String get profileLogoutConfirmTitle;

  /// Mensaje de error al fallar el cierre de sesión
  ///
  /// In es, this message translates to:
  /// **'Error al cerrar sesión'**
  String get profileLogoutError;

  /// Subtítulo de la acción cerrar sesión
  ///
  /// In es, this message translates to:
  /// **'Salir de tu cuenta'**
  String get profileLogoutSubtitle;

  /// Subtítulo de aparcamientos favoritos
  ///
  /// In es, this message translates to:
  /// **'Aparcamientos marcados'**
  String get profileMarkedParkings;

  /// Fecha de alta del usuario en el perfil
  ///
  /// In es, this message translates to:
  /// **'Miembro desde {date}'**
  String profileMemberSince(String date);

  /// Subtítulo del tiempo promedio por reserva
  ///
  /// In es, this message translates to:
  /// **'Por reserva'**
  String get profilePerReservation;

  /// Porcentaje de reservas completadas con éxito
  ///
  /// In es, this message translates to:
  /// **'{rate}% éxito'**
  String profileSuccessRate(String rate);

  /// Etiqueta de estadística de reservas totales
  ///
  /// In es, this message translates to:
  /// **'Reservas totales'**
  String get profileTotalReservations;

  /// Etiqueta de estadística de tiempo total de uso
  ///
  /// In es, this message translates to:
  /// **'Tiempo total'**
  String get profileTotalTime;

  /// Título de la lista de instrucciones adicionales
  ///
  /// In es, this message translates to:
  /// **'Instrucciones adicionales:'**
  String get sendPasswordAdditionalTitle;

  /// Botón para volver a la pantalla de login
  ///
  /// In es, this message translates to:
  /// **'Volver al login'**
  String get sendPasswordBackToLoginButton;

  /// Botón cancelar en recuperar contraseña
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get sendPasswordCancelButton;

  /// Mensaje de confirmación de envío
  ///
  /// In es, this message translates to:
  /// **'Hemos enviado las instrucciones para restablecer tu contraseña a:'**
  String get sendPasswordConfirmationMessage;

  /// Placeholder del campo email en recuperar contraseña
  ///
  /// In es, this message translates to:
  /// **'ejemplo@correo.com'**
  String get sendPasswordEmailHint;

  /// Validación: email inválido en recuperar contraseña
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa un email válido'**
  String get sendPasswordEmailInvalid;

  /// Etiqueta del campo email en recuperar contraseña
  ///
  /// In es, this message translates to:
  /// **'Email'**
  String get sendPasswordEmailLabel;

  /// Validación: email vacío en recuperar contraseña
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa tu email'**
  String get sendPasswordEmailRequired;

  /// SnackBar de error al enviar email de recuperación
  ///
  /// In es, this message translates to:
  /// **'Error al enviar el email'**
  String get sendPasswordError;

  /// Instrucciones del formulario de recuperar contraseña
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu email y te enviaremos instrucciones para restablecer tu contraseña.'**
  String get sendPasswordInstructions;

  /// Botón para reenviar el email de recuperación
  ///
  /// In es, this message translates to:
  /// **'Enviar de nuevo'**
  String get sendPasswordSendAgainButton;

  /// Botón enviar email de recuperación
  ///
  /// In es, this message translates to:
  /// **'Recibir email'**
  String get sendPasswordSubmitButton;

  /// Aviso de éxito tras enviar email de recuperación
  ///
  /// In es, this message translates to:
  /// **'Email enviado exitosamente'**
  String get sendPasswordSuccessAlert;

  /// Instrucción adicional 1
  ///
  /// In es, this message translates to:
  /// **'• Revisa tu bandeja de entrada'**
  String get sendPasswordTip1;

  /// Instrucción adicional 2
  ///
  /// In es, this message translates to:
  /// **'• Si no encuentras el email, revisa la carpeta de spam'**
  String get sendPasswordTip2;

  /// Instrucción adicional 3
  ///
  /// In es, this message translates to:
  /// **'• El enlace expirará en 24 horas'**
  String get sendPasswordTip3;

  /// Instrucción adicional 4
  ///
  /// In es, this message translates to:
  /// **'• Si no recibes el email, puedes enviarlo de nuevo'**
  String get sendPasswordTip4;

  /// Título de la pantalla recuperar contraseña
  ///
  /// In es, this message translates to:
  /// **'Recuperar Contraseña'**
  String get sendPasswordTitle;

  /// Encabezado de la sección acerca de
  ///
  /// In es, this message translates to:
  /// **'Acerca de'**
  String get settingsAboutSection;

  /// Encabezado de la sección de cuenta
  ///
  /// In es, this message translates to:
  /// **'Cuenta'**
  String get settingsAccountSection;

  /// Encabezado de la sección de ajustes de la app
  ///
  /// In es, this message translates to:
  /// **'Configuración de la aplicación'**
  String get settingsAppSection;

  /// Título del conmutador de biometría en Ajustes
  ///
  /// In es, this message translates to:
  /// **'Acceso biométrico'**
  String get settingsBiometric;

  /// Confirmación al desactivar la biometría
  ///
  /// In es, this message translates to:
  /// **'Acceso biométrico desactivado'**
  String get settingsBiometricDisabled;

  /// Subtítulo del conmutador de biometría
  ///
  /// In es, this message translates to:
  /// **'Desbloquear la app con huella o Face ID'**
  String get settingsBiometricSubtitle;

  /// Título de la acción de llamar a soporte
  ///
  /// In es, this message translates to:
  /// **'Llamar a soporte'**
  String get settingsCallSupport;

  /// Error al no poder abrir el marcador telefónico
  ///
  /// In es, this message translates to:
  /// **'No se puede abrir el marcador automáticamente.\nPor favor llama manualmente al {phone}'**
  String settingsCallSupportError(String phone);

  /// Subtítulo de la acción de llamar a soporte
  ///
  /// In es, this message translates to:
  /// **'Contactar con nuestro equipo de soporte'**
  String get settingsCallSupportSubtitle;

  /// Título de la acción cambiar contraseña
  ///
  /// In es, this message translates to:
  /// **'Cambiar contraseña'**
  String get settingsChangePassword;

  /// Subtítulo de la acción cambiar contraseña
  ///
  /// In es, this message translates to:
  /// **'Actualizar tu contraseña de acceso'**
  String get settingsChangePasswordSubtitle;

  /// Título del ajuste de modo oscuro
  ///
  /// In es, this message translates to:
  /// **'Modo oscuro'**
  String get settingsDarkMode;

  /// Subtítulo del ajuste de modo oscuro
  ///
  /// In es, this message translates to:
  /// **'Usar tema oscuro en la aplicación'**
  String get settingsDarkModeSubtitle;

  /// Título de la acción eliminar cuenta
  ///
  /// In es, this message translates to:
  /// **'Eliminar cuenta'**
  String get settingsDeleteAccount;

  /// Subtítulo de la acción eliminar cuenta
  ///
  /// In es, this message translates to:
  /// **'Eliminar permanentemente tu cuenta'**
  String get settingsDeleteAccountSubtitle;

  /// Título de la sección de preguntas frecuentes
  ///
  /// In es, this message translates to:
  /// **'Preguntas frecuentes'**
  String get settingsFaq;

  /// Respuesta FAQ 1
  ///
  /// In es, this message translates to:
  /// **'Ve a la sección de Aparcamientos, selecciona un aparcamiento disponible y presiona \"Reservar\". Tendrás 30 minutos para llegar.'**
  String get settingsFaqAnswer1;

  /// Respuesta FAQ 2
  ///
  /// In es, this message translates to:
  /// **'Sí, puedes cancelar tu reserva desde la pantalla de reserva activa antes de 30 minutos desde el momento en que se efectuó la reserva.'**
  String get settingsFaqAnswer2;

  /// Respuesta FAQ 3
  ///
  /// In es, this message translates to:
  /// **'Puedes usar una plaza por un máximo de 14 horas. Después de este tiempo, la plaza se liberará automáticamente.'**
  String get settingsFaqAnswer3;

  /// Respuesta FAQ 4
  ///
  /// In es, this message translates to:
  /// **'Si no abres la puerta en 30 minutos, tu reserva se cancelará automáticamente y la plaza quedará disponible.'**
  String get settingsFaqAnswer4;

  /// Respuesta FAQ 5
  ///
  /// In es, this message translates to:
  /// **'No, solo puedes tener una reserva activa a la vez. Debes finalizar tu uso actual antes de hacer una nueva reserva.'**
  String get settingsFaqAnswer5;

  /// Pregunta FAQ 1
  ///
  /// In es, this message translates to:
  /// **'¿Cómo reservo una plaza?'**
  String get settingsFaqQuestion1;

  /// Pregunta FAQ 2
  ///
  /// In es, this message translates to:
  /// **'¿Puedo cancelar mi reserva?'**
  String get settingsFaqQuestion2;

  /// Pregunta FAQ 3
  ///
  /// In es, this message translates to:
  /// **'¿Cuánto tiempo puedo usar una plaza?'**
  String get settingsFaqQuestion3;

  /// Pregunta FAQ 4
  ///
  /// In es, this message translates to:
  /// **'¿Qué pasa si no llego a tiempo?'**
  String get settingsFaqQuestion4;

  /// Pregunta FAQ 5
  ///
  /// In es, this message translates to:
  /// **'¿Puedo tener múltiples reservas?'**
  String get settingsFaqQuestion5;

  /// Subtítulo de la acción de preguntas frecuentes
  ///
  /// In es, this message translates to:
  /// **'Encuentra respuestas a dudas comunes'**
  String get settingsFaqSubtitle;

  /// Encabezado de la sección de ayuda y soporte
  ///
  /// In es, this message translates to:
  /// **'Ayuda y soporte'**
  String get settingsHelpSection;

  /// Título del ajuste de idioma
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get settingsLanguage;

  /// Valor mostrado del idioma seleccionado
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get settingsLanguageValue;

  /// Título del ajuste de notificaciones
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get settingsNotifications;

  /// Subtítulo del ajuste de notificaciones
  ///
  /// In es, this message translates to:
  /// **'Recibir notificaciones de reservas y recordatorios'**
  String get settingsNotificationsSubtitle;

  /// Título de la acción de política de privacidad
  ///
  /// In es, this message translates to:
  /// **'Política de privacidad'**
  String get settingsPrivacy;

  /// Aviso de que la política de privacidad está en desarrollo
  ///
  /// In es, this message translates to:
  /// **'Política de privacidad - Funcionalidad en desarrollo'**
  String get settingsPrivacyInDevelopment;

  /// Subtítulo de la acción de política de privacidad
  ///
  /// In es, this message translates to:
  /// **'Información sobre el manejo de tus datos'**
  String get settingsPrivacySubtitle;

  /// Título de la acción de términos de servicio
  ///
  /// In es, this message translates to:
  /// **'Términos de servicio'**
  String get settingsTerms;

  /// Aviso de que los términos de servicio están en desarrollo
  ///
  /// In es, this message translates to:
  /// **'Términos de servicio - Funcionalidad en desarrollo'**
  String get settingsTermsInDevelopment;

  /// Subtítulo de la acción de términos de servicio
  ///
  /// In es, this message translates to:
  /// **'Lee nuestros términos y condiciones'**
  String get settingsTermsSubtitle;

  /// Título de la acción tutorial
  ///
  /// In es, this message translates to:
  /// **'Tutorial'**
  String get settingsTutorial;

  /// Subtítulo de la acción tutorial
  ///
  /// In es, this message translates to:
  /// **'Aprende a usar la aplicación'**
  String get settingsTutorialSubtitle;

  /// Etiqueta de la versión de la aplicación
  ///
  /// In es, this message translates to:
  /// **'Versión'**
  String get settingsVersion;

  /// Descripción de la app en la pantalla splash
  ///
  /// In es, this message translates to:
  /// **'Sistema de reserva de plazas\ninteligentes para bicicletas'**
  String get splashDescription;

  /// Mensaje mostrado en el arranque mientras se inicializa
  ///
  /// In es, this message translates to:
  /// **'Inicializando...'**
  String get splashInitializing;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ca', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ca':
      return AppLocalizationsCa();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
