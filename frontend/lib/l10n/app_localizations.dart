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
  /// **'Vendaqui'**
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

  /// No description provided for @back.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get back;

  /// No description provided for @cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @continueAction.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get continueAction;

  /// No description provided for @decimalSeparatorKey.
  ///
  /// In pt, this message translates to:
  /// **'Vírgula'**
  String get decimalSeparatorKey;

  /// No description provided for @splashLoading.
  ///
  /// In pt, this message translates to:
  /// **'Abrindo o Vendaqui…'**
  String get splashLoading;

  /// No description provided for @welcomeHeadline.
  ///
  /// In pt, this message translates to:
  /// **'Venda rápido,\nlucre mais'**
  String get welcomeHeadline;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Vendas, estoque e fiado do seu comércio num só lugar, em poucos toques.'**
  String get welcomeSubtitle;

  /// No description provided for @welcomeStart.
  ///
  /// In pt, this message translates to:
  /// **'Começar agora'**
  String get welcomeStart;

  /// No description provided for @welcomeHaveAccount.
  ///
  /// In pt, this message translates to:
  /// **'Já tenho conta · '**
  String get welcomeHaveAccount;

  /// No description provided for @welcomeSignIn.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get welcomeSignIn;

  /// No description provided for @welcomeImageLabel.
  ///
  /// In pt, this message translates to:
  /// **'Ilustração de uma feirante sorrindo na sua banca de frutas e verduras'**
  String get welcomeImageLabel;

  /// No description provided for @loginTitle.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Use seu telefone e seu PIN.'**
  String get loginSubtitle;

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

  /// No description provided for @pinFieldLabel.
  ///
  /// In pt, this message translates to:
  /// **'PIN (4 a 6 números)'**
  String get pinFieldLabel;

  /// No description provided for @loginForgotPin.
  ///
  /// In pt, this message translates to:
  /// **'Esqueci meu PIN'**
  String get loginForgotPin;

  /// No description provided for @loginCreateAccount.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get loginCreateAccount;

  /// No description provided for @loginSubmit.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get loginSubmit;

  /// No description provided for @loginMissingFields.
  ///
  /// In pt, this message translates to:
  /// **'Preencha o telefone e o PIN.'**
  String get loginMissingFields;

  /// No description provided for @loginWelcome.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo! Você continua conectado até sair.'**
  String get loginWelcome;

  /// No description provided for @registerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Cadastro'**
  String get registerTitle;

  /// No description provided for @registerStepOne.
  ///
  /// In pt, this message translates to:
  /// **'Etapa 1 de 2'**
  String get registerStepOne;

  /// No description provided for @registerStepTwo.
  ///
  /// In pt, this message translates to:
  /// **'Etapa 2 de 2 · PIN'**
  String get registerStepTwo;

  /// No description provided for @registerBusinessTitle.
  ///
  /// In pt, this message translates to:
  /// **'Dados do comércio'**
  String get registerBusinessTitle;

  /// No description provided for @registerBusinessSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Como seus clientes conhecem você.'**
  String get registerBusinessSubtitle;

  /// No description provided for @registerNameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nome do comércio ou vendedor'**
  String get registerNameLabel;

  /// No description provided for @registerNameHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Banca do Seu João'**
  String get registerNameHint;

  /// No description provided for @registerPhoneLabel.
  ///
  /// In pt, this message translates to:
  /// **'Telefone (WhatsApp)'**
  String get registerPhoneLabel;

  /// No description provided for @registerPhoneHint.
  ///
  /// In pt, this message translates to:
  /// **'Você vai usar este número para entrar no app.'**
  String get registerPhoneHint;

  /// No description provided for @registerNameRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe o nome do comércio ou vendedor.'**
  String get registerNameRequired;

  /// No description provided for @registerPhoneInvalid.
  ///
  /// In pt, this message translates to:
  /// **'Informe um telefone válido com DDD.'**
  String get registerPhoneInvalid;

  /// No description provided for @registerPhoneTaken.
  ///
  /// In pt, this message translates to:
  /// **'Este telefone já está cadastrado.'**
  String get registerPhoneTaken;

  /// No description provided for @registerCreatePinTitle.
  ///
  /// In pt, this message translates to:
  /// **'Crie seu PIN'**
  String get registerCreatePinTitle;

  /// No description provided for @registerCreatePinSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Escolha de 4 a 6 números. Você vai usar para entrar no app.'**
  String get registerCreatePinSubtitle;

  /// No description provided for @registerRepeatPinTitle.
  ///
  /// In pt, this message translates to:
  /// **'Repita o PIN'**
  String get registerRepeatPinTitle;

  /// No description provided for @registerRepeatPinSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Digite o mesmo PIN mais uma vez.'**
  String get registerRepeatPinSubtitle;

  /// No description provided for @registerPinTooShort.
  ///
  /// In pt, this message translates to:
  /// **'Use pelo menos 4 números.'**
  String get registerPinTooShort;

  /// No description provided for @registerPinMismatch.
  ///
  /// In pt, this message translates to:
  /// **'Os PINs não conferem. Tente de novo.'**
  String get registerPinMismatch;

  /// No description provided for @registerDone.
  ///
  /// In pt, this message translates to:
  /// **'Cadastro concluído. Você já está conectado.'**
  String get registerDone;

  /// No description provided for @recoverTitle.
  ///
  /// In pt, this message translates to:
  /// **'Recuperar PIN'**
  String get recoverTitle;

  /// No description provided for @recoverStep.
  ///
  /// In pt, this message translates to:
  /// **'Passo {step} de 3'**
  String recoverStep(int step);

  /// No description provided for @recoverPhoneTitle.
  ///
  /// In pt, this message translates to:
  /// **'Qual é o seu telefone?'**
  String get recoverPhoneTitle;

  /// No description provided for @recoverPhoneSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Vamos enviar um código pelo WhatsApp.'**
  String get recoverPhoneSubtitle;

  /// No description provided for @recoverSendCode.
  ///
  /// In pt, this message translates to:
  /// **'Enviar código'**
  String get recoverSendCode;

  /// No description provided for @recoverCodeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Digite o código'**
  String get recoverCodeTitle;

  /// No description provided for @recoverCodeSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Código de 6 dígitos enviado para {phone}.'**
  String recoverCodeSubtitle(String phone);

  /// No description provided for @recoverResendCode.
  ///
  /// In pt, this message translates to:
  /// **'Reenviar código'**
  String get recoverResendCode;

  /// No description provided for @recoverCodeSent.
  ///
  /// In pt, this message translates to:
  /// **'Código enviado pelo WhatsApp.'**
  String get recoverCodeSent;

  /// No description provided for @recoverNewPinTitle.
  ///
  /// In pt, this message translates to:
  /// **'Crie um novo PIN'**
  String get recoverNewPinTitle;

  /// No description provided for @recoverNewPinSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'De 4 a 6 números.'**
  String get recoverNewPinSubtitle;

  /// No description provided for @recoverSaveNewPin.
  ///
  /// In pt, this message translates to:
  /// **'Salvar novo PIN'**
  String get recoverSaveNewPin;

  /// No description provided for @recoverPhoneInvalid.
  ///
  /// In pt, this message translates to:
  /// **'Digite o telefone com DDD.'**
  String get recoverPhoneInvalid;

  /// No description provided for @recoverPinTooShort.
  ///
  /// In pt, this message translates to:
  /// **'O PIN precisa ter de 4 a 6 números.'**
  String get recoverPinTooShort;

  /// No description provided for @recoverDone.
  ///
  /// In pt, this message translates to:
  /// **'PIN alterado. Você já está conectado.'**
  String get recoverDone;

  /// No description provided for @navHome.
  ///
  /// In pt, this message translates to:
  /// **'Início'**
  String get navHome;

  /// No description provided for @navStock.
  ///
  /// In pt, this message translates to:
  /// **'Estoque'**
  String get navStock;

  /// No description provided for @dashboardSettings.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get dashboardSettings;

  /// No description provided for @settingsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In pt, this message translates to:
  /// **'Aparência'**
  String get settingsAppearance;

  /// No description provided for @settingsAccount.
  ///
  /// In pt, this message translates to:
  /// **'Conta'**
  String get settingsAccount;

  /// No description provided for @settingsLogout.
  ///
  /// In pt, this message translates to:
  /// **'Sair da conta'**
  String get settingsLogout;

  /// No description provided for @themeSystem.
  ///
  /// In pt, this message translates to:
  /// **'Igual ao celular'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In pt, this message translates to:
  /// **'Claro'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In pt, this message translates to:
  /// **'Escuro'**
  String get themeDark;

  /// No description provided for @themeHint.
  ///
  /// In pt, this message translates to:
  /// **'A escolha fica salva neste aparelho.'**
  String get themeHint;

  /// No description provided for @settingsLoggedOut.
  ///
  /// In pt, this message translates to:
  /// **'Você saiu. Entre com seu PIN.'**
  String get settingsLoggedOut;

  /// No description provided for @greetingMorning.
  ///
  /// In pt, this message translates to:
  /// **'Bom dia'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In pt, this message translates to:
  /// **'Boa tarde'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In pt, this message translates to:
  /// **'Boa noite'**
  String get greetingEvening;

  /// No description provided for @greetingLine.
  ///
  /// In pt, this message translates to:
  /// **'{greeting},'**
  String greetingLine(String greeting);

  /// No description provided for @greetingLineWithName.
  ///
  /// In pt, this message translates to:
  /// **'{greeting}, {name},'**
  String greetingLineWithName(String greeting, String name);

  /// No description provided for @greetingCallToAction.
  ///
  /// In pt, this message translates to:
  /// **'bora vender?'**
  String get greetingCallToAction;

  /// No description provided for @dashboardStockCardTitle.
  ///
  /// In pt, this message translates to:
  /// **'Seu estoque'**
  String get dashboardStockCardTitle;

  /// No description provided for @dashboardProductCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{Nenhum produto} =1{1 produto} other{{count} produtos}}'**
  String dashboardProductCount(int count);

  /// No description provided for @dashboardLowCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 com estoque baixo} other{{count} com estoque baixo}}'**
  String dashboardLowCount(int count);

  /// No description provided for @dashboardOutCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 esgotado} other{{count} esgotados}}'**
  String dashboardOutCount(int count);

  /// No description provided for @dashboardAllGood.
  ///
  /// In pt, this message translates to:
  /// **'Tudo em dia'**
  String get dashboardAllGood;

  /// No description provided for @shortcutsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Atalhos'**
  String get shortcutsTitle;

  /// No description provided for @shortcutRestock.
  ///
  /// In pt, this message translates to:
  /// **'Repor estoque'**
  String get shortcutRestock;

  /// No description provided for @shortcutNewProduct.
  ///
  /// In pt, this message translates to:
  /// **'Novo produto'**
  String get shortcutNewProduct;

  /// No description provided for @shortcutStock.
  ///
  /// In pt, this message translates to:
  /// **'Ver estoque'**
  String get shortcutStock;

  /// No description provided for @stockAlertsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Atenção ao estoque'**
  String get stockAlertsTitle;

  /// No description provided for @seeAll.
  ///
  /// In pt, this message translates to:
  /// **'Ver todos'**
  String get seeAll;

  /// No description provided for @restockAction.
  ///
  /// In pt, this message translates to:
  /// **'Repor'**
  String get restockAction;

  /// No description provided for @stockRemaining.
  ///
  /// In pt, this message translates to:
  /// **'Restam {quantity}'**
  String stockRemaining(String quantity);

  /// No description provided for @dashboardNoProducts.
  ///
  /// In pt, this message translates to:
  /// **'Cadastre seu primeiro produto para começar.'**
  String get dashboardNoProducts;

  /// No description provided for @stockTitle.
  ///
  /// In pt, this message translates to:
  /// **'Estoque'**
  String get stockTitle;

  /// No description provided for @stockSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 produto} other{{count} produtos}} · estoque baixo: até {threshold} unid./kg'**
  String stockSubtitle(int count, int threshold);

  /// No description provided for @searchProductHint.
  ///
  /// In pt, this message translates to:
  /// **'Buscar produto pelo nome'**
  String get searchProductHint;

  /// No description provided for @stockFilterAll.
  ///
  /// In pt, this message translates to:
  /// **'Todos {count}'**
  String stockFilterAll(int count);

  /// No description provided for @stockFilterLow.
  ///
  /// In pt, this message translates to:
  /// **'Baixo {count}'**
  String stockFilterLow(int count);

  /// No description provided for @stockFilterOut.
  ///
  /// In pt, this message translates to:
  /// **'Esgotado {count}'**
  String stockFilterOut(int count);

  /// No description provided for @stockEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum produto aqui.'**
  String get stockEmpty;

  /// No description provided for @stockEndOfList.
  ///
  /// In pt, this message translates to:
  /// **'Fim da lista'**
  String get stockEndOfList;

  /// No description provided for @stockAddProduct.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar Produto'**
  String get stockAddProduct;

  /// No description provided for @stockSalePrice.
  ///
  /// In pt, this message translates to:
  /// **'Venda {price}'**
  String stockSalePrice(String price);

  /// No description provided for @stockCostPrice.
  ///
  /// In pt, this message translates to:
  /// **' · Custo {price}'**
  String stockCostPrice(String price);

  /// No description provided for @stockLevelOk.
  ///
  /// In pt, this message translates to:
  /// **'Normal'**
  String get stockLevelOk;

  /// No description provided for @stockLevelLow.
  ///
  /// In pt, this message translates to:
  /// **'Baixo'**
  String get stockLevelLow;

  /// No description provided for @stockLevelOut.
  ///
  /// In pt, this message translates to:
  /// **'Esgotado'**
  String get stockLevelOut;

  /// No description provided for @unitKg.
  ///
  /// In pt, this message translates to:
  /// **'kg'**
  String get unitKg;

  /// No description provided for @unitPiece.
  ///
  /// In pt, this message translates to:
  /// **'un'**
  String get unitPiece;

  /// No description provided for @quantityWithUnit.
  ///
  /// In pt, this message translates to:
  /// **'{quantity} {unit}'**
  String quantityWithUnit(String quantity, String unit);

  /// No description provided for @productNewTitle.
  ///
  /// In pt, this message translates to:
  /// **'Novo produto'**
  String get productNewTitle;

  /// No description provided for @productEditTitle.
  ///
  /// In pt, this message translates to:
  /// **'Editar produto'**
  String get productEditTitle;

  /// No description provided for @productPhotoPick.
  ///
  /// In pt, this message translates to:
  /// **'tirar ou escolher foto'**
  String get productPhotoPick;

  /// No description provided for @productPhotoChange.
  ///
  /// In pt, this message translates to:
  /// **'foto do produto · tocar para trocar'**
  String get productPhotoChange;

  /// No description provided for @productPhotoFromCamera.
  ///
  /// In pt, this message translates to:
  /// **'Tirar foto'**
  String get productPhotoFromCamera;

  /// No description provided for @productPhotoFromGallery.
  ///
  /// In pt, this message translates to:
  /// **'Escolher da galeria'**
  String get productPhotoFromGallery;

  /// No description provided for @productPhotoTooLarge.
  ///
  /// In pt, this message translates to:
  /// **'A foto passa de 5 MB. Escolha outra.'**
  String get productPhotoTooLarge;

  /// No description provided for @productPhotoUnsupported.
  ///
  /// In pt, this message translates to:
  /// **'Use uma foto JPEG, PNG ou WebP.'**
  String get productPhotoUnsupported;

  /// No description provided for @productPhotoUploadFailed.
  ///
  /// In pt, this message translates to:
  /// **'O produto foi salvo, mas a foto não foi enviada. Tente trocar a foto de novo.'**
  String get productPhotoUploadFailed;

  /// No description provided for @productNameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nome do produto'**
  String get productNameLabel;

  /// No description provided for @productNameHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Tomate'**
  String get productNameHint;

  /// No description provided for @productSalePriceLabel.
  ///
  /// In pt, this message translates to:
  /// **'Preço de venda'**
  String get productSalePriceLabel;

  /// No description provided for @productCostPriceLabel.
  ///
  /// In pt, this message translates to:
  /// **'Preço de custo'**
  String get productCostPriceLabel;

  /// No description provided for @currencySymbol.
  ///
  /// In pt, this message translates to:
  /// **'R\$'**
  String get currencySymbol;

  /// No description provided for @moneyHint.
  ///
  /// In pt, this message translates to:
  /// **'0,00'**
  String get moneyHint;

  /// No description provided for @productMargin.
  ///
  /// In pt, this message translates to:
  /// **'Lucro por {unit}: {profit} ({percent}%)'**
  String productMargin(String unit, String profit, int percent);

  /// No description provided for @productMarginNegative.
  ///
  /// In pt, this message translates to:
  /// **'O custo está maior ou igual ao preço de venda.'**
  String get productMarginNegative;

  /// No description provided for @productInitialQuantity.
  ///
  /// In pt, this message translates to:
  /// **'Quantidade inicial'**
  String get productInitialQuantity;

  /// No description provided for @productStockQuantity.
  ///
  /// In pt, this message translates to:
  /// **'Quantidade em estoque'**
  String get productStockQuantity;

  /// No description provided for @quantityHint.
  ///
  /// In pt, this message translates to:
  /// **'0'**
  String get quantityHint;

  /// No description provided for @productSoldByWeight.
  ///
  /// In pt, this message translates to:
  /// **'Vendido por peso (kg)'**
  String get productSoldByWeight;

  /// No description provided for @productSoldByWeightHint.
  ///
  /// In pt, this message translates to:
  /// **'Na venda, segure o produto para digitar o peso.'**
  String get productSoldByWeightHint;

  /// No description provided for @productSave.
  ///
  /// In pt, this message translates to:
  /// **'Salvar produto'**
  String get productSave;

  /// No description provided for @productNameRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe o nome do produto.'**
  String get productNameRequired;

  /// No description provided for @productSalePriceRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe o preço de venda.'**
  String get productSalePriceRequired;

  /// No description provided for @productCostPriceRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe o preço de custo.'**
  String get productCostPriceRequired;

  /// No description provided for @productQuantityInvalid.
  ///
  /// In pt, this message translates to:
  /// **'Informe a quantidade. Por unidade, use número inteiro; por peso, até 3 casas.'**
  String get productQuantityInvalid;

  /// No description provided for @productCreated.
  ///
  /// In pt, this message translates to:
  /// **'Produto cadastrado.'**
  String get productCreated;

  /// No description provided for @productUpdated.
  ///
  /// In pt, this message translates to:
  /// **'Produto atualizado.'**
  String get productUpdated;

  /// No description provided for @productLoadFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar o produto.'**
  String get productLoadFailed;

  /// No description provided for @restockTitle.
  ///
  /// In pt, this message translates to:
  /// **'Repor estoque'**
  String get restockTitle;

  /// No description provided for @restockCurrent.
  ///
  /// In pt, this message translates to:
  /// **'Atual: {quantity}'**
  String restockCurrent(String quantity);

  /// No description provided for @restockAmountLabel.
  ///
  /// In pt, this message translates to:
  /// **'Quantidade a adicionar'**
  String get restockAmountLabel;

  /// No description provided for @restockAmountSign.
  ///
  /// In pt, this message translates to:
  /// **'+'**
  String get restockAmountSign;

  /// No description provided for @restockAmountHint.
  ///
  /// In pt, this message translates to:
  /// **'0'**
  String get restockAmountHint;

  /// No description provided for @restockNewTotal.
  ///
  /// In pt, this message translates to:
  /// **'Novo total: {quantity}'**
  String restockNewTotal(String quantity);

  /// No description provided for @restockConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar reposição'**
  String get restockConfirm;

  /// No description provided for @restockDone.
  ///
  /// In pt, this message translates to:
  /// **'Estoque atualizado.'**
  String get restockDone;
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
