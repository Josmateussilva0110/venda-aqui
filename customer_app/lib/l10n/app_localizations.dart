import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_pt.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('pt')];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'Vendaqui Cliente'**
  String get appTitle;

  /// No description provided for @brandPrefix.
  ///
  /// In pt, this message translates to:
  /// **'Vend'**
  String get brandPrefix;

  /// No description provided for @brandSuffix.
  ///
  /// In pt, this message translates to:
  /// **'aqui'**
  String get brandSuffix;

  /// No description provided for @genericNetworkError.
  ///
  /// In pt, this message translates to:
  /// **'Sem conexão com o servidor. Confira a internet e tente de novo.'**
  String get genericNetworkError;

  /// No description provided for @genericServerError.
  ///
  /// In pt, this message translates to:
  /// **'Algo deu errado do nosso lado. Tente de novo em instantes.'**
  String get genericServerError;

  /// No description provided for @genericSessionExpired.
  ///
  /// In pt, this message translates to:
  /// **'Sua sessão terminou. Entre de novo com seu PIN.'**
  String get genericSessionExpired;

  /// No description provided for @retry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar de novo'**
  String get retry;

  /// No description provided for @splashLoading.
  ///
  /// In pt, this message translates to:
  /// **'Abrindo o Vendaqui…'**
  String get splashLoading;

  /// No description provided for @loginTitle.
  ///
  /// In pt, this message translates to:
  /// **'Suas compras'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Veja o que você comprou e quanto deve em cada loja.'**
  String get loginSubtitle;

  /// No description provided for @loginByPhone.
  ///
  /// In pt, this message translates to:
  /// **'Telefone'**
  String get loginByPhone;

  /// No description provided for @loginByCpf.
  ///
  /// In pt, this message translates to:
  /// **'CPF'**
  String get loginByCpf;

  /// No description provided for @loginMethodLabel.
  ///
  /// In pt, this message translates to:
  /// **'Entrar com'**
  String get loginMethodLabel;

  /// No description provided for @phoneFieldLabel.
  ///
  /// In pt, this message translates to:
  /// **'Telefone / WhatsApp'**
  String get phoneFieldLabel;

  /// No description provided for @phonePlaceholder.
  ///
  /// In pt, this message translates to:
  /// **'(00) 00000-0000'**
  String get phonePlaceholder;

  /// No description provided for @cpfFieldLabel.
  ///
  /// In pt, this message translates to:
  /// **'CPF'**
  String get cpfFieldLabel;

  /// No description provided for @cpfPlaceholder.
  ///
  /// In pt, this message translates to:
  /// **'000.000.000-00'**
  String get cpfPlaceholder;

  /// No description provided for @pinFieldLabel.
  ///
  /// In pt, this message translates to:
  /// **'PIN (4 a 6 números)'**
  String get pinFieldLabel;

  /// No description provided for @loginSubmit.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get loginSubmit;

  /// No description provided for @loginMissingFields.
  ///
  /// In pt, this message translates to:
  /// **'Preencha o telefone ou CPF e o PIN.'**
  String get loginMissingFields;

  /// No description provided for @loginInvalidCpf.
  ///
  /// In pt, this message translates to:
  /// **'CPF inválido. Confira os 11 números.'**
  String get loginInvalidCpf;

  /// No description provided for @loginNoAccessHint.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não tem acesso ou esqueceu o PIN? Peça o link de acesso para a loja onde você compra. Ele chega pelo WhatsApp: copie a mensagem e cole aqui no app.'**
  String get loginNoAccessHint;

  /// No description provided for @loginHaveInvite.
  ///
  /// In pt, this message translates to:
  /// **'Tenho um link de acesso'**
  String get loginHaveInvite;

  /// No description provided for @inviteTitle.
  ///
  /// In pt, this message translates to:
  /// **'Acesso às suas compras'**
  String get inviteTitle;

  /// No description provided for @inviteFrom.
  ///
  /// In pt, this message translates to:
  /// **'Link enviado por {merchant} para o número terminado em {ending}.'**
  String inviteFrom(String merchant, String ending);

  /// No description provided for @inviteCreatePinIntro.
  ///
  /// In pt, this message translates to:
  /// **'Crie um PIN para entrar quando quiser. Você vai usar o seu telefone ou CPF e este PIN.'**
  String get inviteCreatePinIntro;

  /// No description provided for @inviteCurrentPinIntro.
  ///
  /// In pt, this message translates to:
  /// **'Você já tem acesso em outra loja. Digite o seu PIN para juntar esta loja às outras.'**
  String get inviteCurrentPinIntro;

  /// No description provided for @inviteResetPinIntro.
  ///
  /// In pt, this message translates to:
  /// **'Ao criar um PIN novo, as outras lojas saem da sua consulta até cada uma enviar um link novo. Isso protege as suas compras.'**
  String get inviteResetPinIntro;

  /// No description provided for @inviteNewPinLabel.
  ///
  /// In pt, this message translates to:
  /// **'PIN novo (4 a 6 números)'**
  String get inviteNewPinLabel;

  /// No description provided for @inviteConfirmPinLabel.
  ///
  /// In pt, this message translates to:
  /// **'Repita o PIN'**
  String get inviteConfirmPinLabel;

  /// No description provided for @inviteCurrentPinLabel.
  ///
  /// In pt, this message translates to:
  /// **'Seu PIN'**
  String get inviteCurrentPinLabel;

  /// No description provided for @inviteForgotPin.
  ///
  /// In pt, this message translates to:
  /// **'Esqueci o PIN, criar um novo'**
  String get inviteForgotPin;

  /// No description provided for @inviteKnowPin.
  ///
  /// In pt, this message translates to:
  /// **'Lembrei o PIN'**
  String get inviteKnowPin;

  /// No description provided for @inviteSubmit.
  ///
  /// In pt, this message translates to:
  /// **'Liberar acesso'**
  String get inviteSubmit;

  /// No description provided for @invitePinsDiffer.
  ///
  /// In pt, this message translates to:
  /// **'Os PINs não conferem.'**
  String get invitePinsDiffer;

  /// No description provided for @invitePinTooShort.
  ///
  /// In pt, this message translates to:
  /// **'O PIN deve ter de 4 a 6 números.'**
  String get invitePinTooShort;

  /// No description provided for @inviteInvalidTitle.
  ///
  /// In pt, this message translates to:
  /// **'Este link não vale mais'**
  String get inviteInvalidTitle;

  /// No description provided for @inviteInvalidBody.
  ///
  /// In pt, this message translates to:
  /// **'O link de acesso vale por 24 horas e só pode ser usado uma vez. Peça um link novo para a loja.'**
  String get inviteInvalidBody;

  /// No description provided for @inviteGoToLogin.
  ///
  /// In pt, this message translates to:
  /// **'Já tenho PIN, entrar'**
  String get inviteGoToLogin;

  /// No description provided for @inviteAccepted.
  ///
  /// In pt, this message translates to:
  /// **'Acesso liberado.'**
  String get inviteAccepted;

  /// No description provided for @pasteInviteTitle.
  ///
  /// In pt, this message translates to:
  /// **'Link de acesso'**
  String get pasteInviteTitle;

  /// No description provided for @pasteInviteSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Na conversa com a loja no WhatsApp, toque e segure a mensagem com o link, escolha Copiar e cole aqui.'**
  String get pasteInviteSubtitle;

  /// No description provided for @pasteInviteFieldLabel.
  ///
  /// In pt, this message translates to:
  /// **'Link ou mensagem da loja'**
  String get pasteInviteFieldLabel;

  /// No description provided for @pasteInvitePaste.
  ///
  /// In pt, this message translates to:
  /// **'Colar'**
  String get pasteInvitePaste;

  /// No description provided for @pasteInviteContinue.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get pasteInviteContinue;

  /// No description provided for @pasteInviteNotFound.
  ///
  /// In pt, this message translates to:
  /// **'Não achamos um link de acesso nesse texto. Copie a mensagem da loja de novo.'**
  String get pasteInviteNotFound;

  /// No description provided for @storesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Minhas lojas'**
  String get storesTitle;

  /// No description provided for @storesSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Toque numa loja para ver as compras e os pagamentos.'**
  String get storesSubtitle;

  /// No description provided for @storesEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma loja ligada ao seu acesso. Peça o link de acesso para a loja onde você compra.'**
  String get storesEmpty;

  /// No description provided for @storesLogout.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get storesLogout;

  /// No description provided for @storesAddStore.
  ///
  /// In pt, this message translates to:
  /// **'Colar link de outra loja'**
  String get storesAddStore;

  /// No description provided for @storeOwes.
  ///
  /// In pt, this message translates to:
  /// **'Você deve'**
  String get storeOwes;

  /// No description provided for @storeNothingOwed.
  ///
  /// In pt, this message translates to:
  /// **'Nada em aberto'**
  String get storeNothingOwed;

  /// No description provided for @storeDueOn.
  ///
  /// In pt, this message translates to:
  /// **'Vence em {date}'**
  String storeDueOn(String date);

  /// No description provided for @storeOpenStatement.
  ///
  /// In pt, this message translates to:
  /// **'Ver movimentações de {merchant}'**
  String storeOpenStatement(String merchant);

  /// No description provided for @statementEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma compra fiado ou pagamento nesta loja ainda.'**
  String get statementEmpty;

  /// No description provided for @statementPurchase.
  ///
  /// In pt, this message translates to:
  /// **'Compra fiado'**
  String get statementPurchase;

  /// No description provided for @statementPayment.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento'**
  String get statementPayment;

  /// No description provided for @statementPaymentWith.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento em {method}'**
  String statementPaymentWith(String method);

  /// No description provided for @paymentMethodCash.
  ///
  /// In pt, this message translates to:
  /// **'dinheiro'**
  String get paymentMethodCash;

  /// No description provided for @paymentMethodPix.
  ///
  /// In pt, this message translates to:
  /// **'Pix'**
  String get paymentMethodPix;

  /// No description provided for @paymentMethodCard.
  ///
  /// In pt, this message translates to:
  /// **'cartão'**
  String get paymentMethodCard;

  /// No description provided for @back.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get back;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
