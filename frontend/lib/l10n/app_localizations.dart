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

  /// No description provided for @navSell.
  ///
  /// In pt, this message translates to:
  /// **'Vender'**
  String get navSell;

  /// No description provided for @dashboardRegisterSale.
  ///
  /// In pt, this message translates to:
  /// **'Registrar venda'**
  String get dashboardRegisterSale;

  /// No description provided for @shortcutSalesHistory.
  ///
  /// In pt, this message translates to:
  /// **'Vendas'**
  String get shortcutSalesHistory;

  /// No description provided for @sellTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nova venda'**
  String get sellTitle;

  /// No description provided for @sellHint.
  ///
  /// In pt, this message translates to:
  /// **'Toque para somar 1 · segure para pesar'**
  String get sellHint;

  /// No description provided for @sellClear.
  ///
  /// In pt, this message translates to:
  /// **'Limpar'**
  String get sellClear;

  /// No description provided for @sellSearchHint.
  ///
  /// In pt, this message translates to:
  /// **'Buscar produto pelo nome'**
  String get sellSearchHint;

  /// No description provided for @sellEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum produto encontrado.'**
  String get sellEmpty;

  /// No description provided for @sellByWeight.
  ///
  /// In pt, this message translates to:
  /// **'por peso'**
  String get sellByWeight;

  /// No description provided for @sellOutOfStock.
  ///
  /// In pt, this message translates to:
  /// **'Esgotado'**
  String get sellOutOfStock;

  /// No description provided for @sellStock.
  ///
  /// In pt, this message translates to:
  /// **'Estoque: {quantity}'**
  String sellStock(String quantity);

  /// No description provided for @sellNoStock.
  ///
  /// In pt, this message translates to:
  /// **'Sem estoque'**
  String get sellNoStock;

  /// No description provided for @sellUnitPrice.
  ///
  /// In pt, this message translates to:
  /// **'{price} /{unit}'**
  String sellUnitPrice(String price, String unit);

  /// No description provided for @sellViewSummary.
  ///
  /// In pt, this message translates to:
  /// **'Ver resumo'**
  String get sellViewSummary;

  /// No description provided for @sellInCart.
  ///
  /// In pt, this message translates to:
  /// **'{quantity} no carrinho'**
  String sellInCart(String quantity);

  /// No description provided for @cartItemCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} itens}}'**
  String cartItemCount(int count);

  /// No description provided for @cartOutOfStock.
  ///
  /// In pt, this message translates to:
  /// **'{name} está esgotado.'**
  String cartOutOfStock(String name);

  /// No description provided for @cartInsufficientStock.
  ///
  /// In pt, this message translates to:
  /// **'Estoque insuficiente: {quantity}'**
  String cartInsufficientStock(String quantity);

  /// No description provided for @cartInvalidQuantity.
  ///
  /// In pt, this message translates to:
  /// **'Este produto é vendido por unidade: use um número inteiro.'**
  String get cartInvalidQuantity;

  /// No description provided for @weightTitle.
  ///
  /// In pt, this message translates to:
  /// **'Vender por peso'**
  String get weightTitle;

  /// No description provided for @weightRequired.
  ///
  /// In pt, this message translates to:
  /// **'Digite o peso.'**
  String get weightRequired;

  /// No description provided for @weightAvailable.
  ///
  /// In pt, this message translates to:
  /// **'Estoque disponível: {quantity}'**
  String weightAvailable(String quantity);

  /// No description provided for @weightAdd.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar'**
  String get weightAdd;

  /// No description provided for @weightUpdate.
  ///
  /// In pt, this message translates to:
  /// **'Atualizar'**
  String get weightUpdate;

  /// No description provided for @weightQuick250.
  ///
  /// In pt, this message translates to:
  /// **'250 g'**
  String get weightQuick250;

  /// No description provided for @weightQuick500.
  ///
  /// In pt, this message translates to:
  /// **'500 g'**
  String get weightQuick500;

  /// No description provided for @weightQuick1kg.
  ///
  /// In pt, this message translates to:
  /// **'1 kg'**
  String get weightQuick1kg;

  /// No description provided for @summaryTitle.
  ///
  /// In pt, this message translates to:
  /// **'Resumo da venda'**
  String get summaryTitle;

  /// No description provided for @summaryEmpty.
  ///
  /// In pt, this message translates to:
  /// **'A venda está vazia.'**
  String get summaryEmpty;

  /// No description provided for @summaryAddMore.
  ///
  /// In pt, this message translates to:
  /// **'+ Adicionar mais itens'**
  String get summaryAddMore;

  /// No description provided for @summaryItems.
  ///
  /// In pt, this message translates to:
  /// **'Itens'**
  String get summaryItems;

  /// No description provided for @summaryTotal.
  ///
  /// In pt, this message translates to:
  /// **'Total'**
  String get summaryTotal;

  /// No description provided for @summaryFinish.
  ///
  /// In pt, this message translates to:
  /// **'Finalizar venda'**
  String get summaryFinish;

  /// No description provided for @summaryRemove.
  ///
  /// In pt, this message translates to:
  /// **'Remover'**
  String get summaryRemove;

  /// No description provided for @summaryEditWeight.
  ///
  /// In pt, this message translates to:
  /// **'{quantity} · editar'**
  String summaryEditWeight(String quantity);

  /// No description provided for @summaryDecrease.
  ///
  /// In pt, this message translates to:
  /// **'Diminuir'**
  String get summaryDecrease;

  /// No description provided for @summaryIncrease.
  ///
  /// In pt, this message translates to:
  /// **'Aumentar'**
  String get summaryIncrease;

  /// No description provided for @paymentTitle.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento'**
  String get paymentTitle;

  /// No description provided for @paymentTotal.
  ///
  /// In pt, this message translates to:
  /// **'Total a receber'**
  String get paymentTotal;

  /// No description provided for @paymentQuestion.
  ///
  /// In pt, this message translates to:
  /// **'Como o cliente vai pagar?'**
  String get paymentQuestion;

  /// No description provided for @paymentHint.
  ///
  /// In pt, this message translates to:
  /// **'Um toque na forma de pagamento conclui a venda e dá baixa no estoque.'**
  String get paymentHint;

  /// No description provided for @paymentCash.
  ///
  /// In pt, this message translates to:
  /// **'Dinheiro'**
  String get paymentCash;

  /// No description provided for @paymentCashDetail.
  ///
  /// In pt, this message translates to:
  /// **'Em espécie'**
  String get paymentCashDetail;

  /// No description provided for @paymentPix.
  ///
  /// In pt, this message translates to:
  /// **'PIX'**
  String get paymentPix;

  /// No description provided for @paymentPixDetail.
  ///
  /// In pt, this message translates to:
  /// **'Transferência na hora'**
  String get paymentPixDetail;

  /// No description provided for @paymentCard.
  ///
  /// In pt, this message translates to:
  /// **'Cartão'**
  String get paymentCard;

  /// No description provided for @paymentCardDetail.
  ///
  /// In pt, this message translates to:
  /// **'Débito ou crédito'**
  String get paymentCardDetail;

  /// No description provided for @saleDoneTitle.
  ///
  /// In pt, this message translates to:
  /// **'Venda registrada!'**
  String get saleDoneTitle;

  /// No description provided for @saleDoneBackHome.
  ///
  /// In pt, this message translates to:
  /// **'Voltar ao início'**
  String get saleDoneBackHome;

  /// No description provided for @saleDoneNewSale.
  ///
  /// In pt, this message translates to:
  /// **'Nova venda'**
  String get saleDoneNewSale;

  /// No description provided for @saleDoneCountdown.
  ///
  /// In pt, this message translates to:
  /// **'Voltando ao início em {seconds}s'**
  String saleDoneCountdown(int seconds);

  /// No description provided for @historyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Histórico de vendas'**
  String get historyTitle;

  /// No description provided for @historySaleCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{Nenhuma venda} =1{1 venda} other{{count} vendas}}'**
  String historySaleCount(int count);

  /// No description provided for @historySummary.
  ///
  /// In pt, this message translates to:
  /// **'{count} · {total}'**
  String historySummary(String count, String total);

  /// No description provided for @historyToday.
  ///
  /// In pt, this message translates to:
  /// **'Hoje'**
  String get historyToday;

  /// No description provided for @historyYesterday.
  ///
  /// In pt, this message translates to:
  /// **'Ontem'**
  String get historyYesterday;

  /// No description provided for @historyWeek.
  ///
  /// In pt, this message translates to:
  /// **'7 dias'**
  String get historyWeek;

  /// No description provided for @historyMonth.
  ///
  /// In pt, this message translates to:
  /// **'30 dias'**
  String get historyMonth;

  /// No description provided for @historyCustom.
  ///
  /// In pt, this message translates to:
  /// **'Período'**
  String get historyCustom;

  /// No description provided for @historyFrom.
  ///
  /// In pt, this message translates to:
  /// **'De'**
  String get historyFrom;

  /// No description provided for @historyTo.
  ///
  /// In pt, this message translates to:
  /// **'Até'**
  String get historyTo;

  /// No description provided for @historyInvalidRange.
  ///
  /// In pt, this message translates to:
  /// **'A data inicial precisa ser antes da final.'**
  String get historyInvalidRange;

  /// No description provided for @historySearchHint.
  ///
  /// In pt, this message translates to:
  /// **'Buscar produto'**
  String get historySearchHint;

  /// No description provided for @historyAllMethods.
  ///
  /// In pt, this message translates to:
  /// **'Todas'**
  String get historyAllMethods;

  /// No description provided for @historyEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma venda encontrada.'**
  String get historyEmpty;

  /// No description provided for @historyProductCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 produto} other{{count} produtos}}'**
  String historyProductCount(int count);

  /// No description provided for @saleDetailTitle.
  ///
  /// In pt, this message translates to:
  /// **'Detalhe da venda'**
  String get saleDetailTitle;

  /// No description provided for @saleDetailTotal.
  ///
  /// In pt, this message translates to:
  /// **'Total da venda'**
  String get saleDetailTotal;

  /// No description provided for @saleDetailPayment.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento'**
  String get saleDetailPayment;

  /// No description provided for @saleDetailItems.
  ///
  /// In pt, this message translates to:
  /// **'Itens'**
  String get saleDetailItems;

  /// No description provided for @saleDetailProducts.
  ///
  /// In pt, this message translates to:
  /// **'Produtos'**
  String get saleDetailProducts;

  /// No description provided for @saleDetailEdited.
  ///
  /// In pt, this message translates to:
  /// **'Editada em {date}'**
  String saleDetailEdited(String date);

  /// No description provided for @saleDetailEdit.
  ///
  /// In pt, this message translates to:
  /// **'Editar venda'**
  String get saleDetailEdit;

  /// No description provided for @saleLine.
  ///
  /// In pt, this message translates to:
  /// **'{quantity} × {price}'**
  String saleLine(String quantity, String price);

  /// No description provided for @saleLoadFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar a venda.'**
  String get saleLoadFailed;

  /// No description provided for @saleEditTitle.
  ///
  /// In pt, this message translates to:
  /// **'Editar venda'**
  String get saleEditTitle;

  /// No description provided for @saleEditMethod.
  ///
  /// In pt, this message translates to:
  /// **'Forma de pagamento'**
  String get saleEditMethod;

  /// No description provided for @saleEditNewTotal.
  ///
  /// In pt, this message translates to:
  /// **'Novo total'**
  String get saleEditNewTotal;

  /// No description provided for @saleEditSave.
  ///
  /// In pt, this message translates to:
  /// **'Salvar alterações'**
  String get saleEditSave;

  /// No description provided for @saleEditNoItems.
  ///
  /// In pt, this message translates to:
  /// **'A venda precisa ter pelo menos um produto.'**
  String get saleEditNoItems;

  /// No description provided for @saleEditSaved.
  ///
  /// In pt, this message translates to:
  /// **'Venda atualizada.'**
  String get saleEditSaved;

  /// No description provided for @paymentCredit.
  ///
  /// In pt, this message translates to:
  /// **'Fiado'**
  String get paymentCredit;

  /// No description provided for @paymentCreditDetail.
  ///
  /// In pt, this message translates to:
  /// **'Cliente paga depois'**
  String get paymentCreditDetail;

  /// No description provided for @saleDoneCredit.
  ///
  /// In pt, this message translates to:
  /// **'Fiado · {name}'**
  String saleDoneCredit(String name);

  /// No description provided for @creditPickerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Venda no fiado'**
  String get creditPickerTitle;

  /// No description provided for @creditPickerAmount.
  ///
  /// In pt, this message translates to:
  /// **'Valor a anotar'**
  String get creditPickerAmount;

  /// No description provided for @creditPickerQuestion.
  ///
  /// In pt, this message translates to:
  /// **'Para qual cliente?'**
  String get creditPickerQuestion;

  /// No description provided for @creditPickerEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum cliente encontrado. Cadastre um novo.'**
  String get creditPickerEmpty;

  /// No description provided for @creditPickerConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Anotar para {name}'**
  String creditPickerConfirm(String name);

  /// No description provided for @creditPickerSelect.
  ///
  /// In pt, this message translates to:
  /// **'Selecione um cliente'**
  String get creditPickerSelect;

  /// No description provided for @creditPickerHint.
  ///
  /// In pt, this message translates to:
  /// **'A venda entra no caixa do dia e fica pendente na conta do cliente.'**
  String get creditPickerHint;

  /// No description provided for @customerSearchHint.
  ///
  /// In pt, this message translates to:
  /// **'Buscar por nome ou telefone'**
  String get customerSearchHint;

  /// No description provided for @customerNewButton.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar novo cliente'**
  String get customerNewButton;

  /// No description provided for @customerNewTitle.
  ///
  /// In pt, this message translates to:
  /// **'Novo cliente'**
  String get customerNewTitle;

  /// No description provided for @customerNameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get customerNameLabel;

  /// No description provided for @customerNamePlaceholder.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Dona Maria'**
  String get customerNamePlaceholder;

  /// No description provided for @customerPhoneLabel.
  ///
  /// In pt, this message translates to:
  /// **'Telefone (WhatsApp)'**
  String get customerPhoneLabel;

  /// No description provided for @customerNameInvalid.
  ///
  /// In pt, this message translates to:
  /// **'Use pelo menos 2 letras.'**
  String get customerNameInvalid;

  /// No description provided for @customerPhoneInvalid.
  ///
  /// In pt, this message translates to:
  /// **'Telefone inválido. Use DDD + número.'**
  String get customerPhoneInvalid;

  /// No description provided for @customerSave.
  ///
  /// In pt, this message translates to:
  /// **'Salvar cliente'**
  String get customerSave;

  /// No description provided for @customerSaved.
  ///
  /// In pt, this message translates to:
  /// **'Cliente cadastrado.'**
  String get customerSaved;

  /// No description provided for @customerOwes.
  ///
  /// In pt, this message translates to:
  /// **'Deve {amount}'**
  String customerOwes(String amount);

  /// No description provided for @customerUpToDate.
  ///
  /// In pt, this message translates to:
  /// **'Em dia'**
  String get customerUpToDate;

  /// No description provided for @debtorsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Fiado'**
  String get debtorsTitle;

  /// No description provided for @debtorsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Clientes que compraram para pagar depois'**
  String get debtorsSubtitle;

  /// No description provided for @debtorsTotal.
  ///
  /// In pt, this message translates to:
  /// **'Total a receber'**
  String get debtorsTotal;

  /// No description provided for @debtorsOwingCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{Ninguém devendo} =1{1 cliente devendo} other{{count} clientes devendo}}'**
  String debtorsOwingCount(int count);

  /// No description provided for @debtorsSearchHint.
  ///
  /// In pt, this message translates to:
  /// **'Buscar cliente'**
  String get debtorsSearchHint;

  /// No description provided for @debtorsFilterOwing.
  ///
  /// In pt, this message translates to:
  /// **'Devendo'**
  String get debtorsFilterOwing;

  /// No description provided for @debtorsFilterAll.
  ///
  /// In pt, this message translates to:
  /// **'Todos'**
  String get debtorsFilterAll;

  /// No description provided for @debtorsEmptyOwing.
  ///
  /// In pt, this message translates to:
  /// **'Ninguém devendo.'**
  String get debtorsEmptyOwing;

  /// No description provided for @debtorsEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum cliente encontrado.'**
  String get debtorsEmpty;

  /// No description provided for @accountTitle.
  ///
  /// In pt, this message translates to:
  /// **'Conta do cliente'**
  String get accountTitle;

  /// No description provided for @accountBalance.
  ///
  /// In pt, this message translates to:
  /// **'Valor devendo'**
  String get accountBalance;

  /// No description provided for @accountClear.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma conta em aberto'**
  String get accountClear;

  /// No description provided for @accountReceivePart.
  ///
  /// In pt, this message translates to:
  /// **'Receber parte'**
  String get accountReceivePart;

  /// No description provided for @accountReceiveAll.
  ///
  /// In pt, this message translates to:
  /// **'Receber tudo'**
  String get accountReceiveAll;

  /// No description provided for @receiveAmountQuestion.
  ///
  /// In pt, this message translates to:
  /// **'Quanto o cliente está pagando?'**
  String get receiveAmountQuestion;

  /// No description provided for @receiveHalf.
  ///
  /// In pt, this message translates to:
  /// **'Metade'**
  String get receiveHalf;

  /// No description provided for @receiveCurrentDebt.
  ///
  /// In pt, this message translates to:
  /// **'Dívida atual: {amount}'**
  String receiveCurrentDebt(String amount);

  /// No description provided for @receiveRemaining.
  ///
  /// In pt, this message translates to:
  /// **'Restará {amount}'**
  String receiveRemaining(String amount);

  /// No description provided for @receiveSettles.
  ///
  /// In pt, this message translates to:
  /// **'Quita a dívida'**
  String get receiveSettles;

  /// No description provided for @receiveMethodQuestion.
  ///
  /// In pt, this message translates to:
  /// **'Como o cliente pagou?'**
  String get receiveMethodQuestion;

  /// No description provided for @receiveConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar pagamento'**
  String get receiveConfirm;

  /// No description provided for @receiveInvalidAmount.
  ///
  /// In pt, this message translates to:
  /// **'Informe um valor maior que zero.'**
  String get receiveInvalidAmount;

  /// No description provided for @receiveExceedsBalance.
  ///
  /// In pt, this message translates to:
  /// **'O valor passa da dívida do cliente.'**
  String get receiveExceedsBalance;

  /// No description provided for @receiveDone.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento registrado.'**
  String get receiveDone;

  /// No description provided for @statementTitle.
  ///
  /// In pt, this message translates to:
  /// **'Movimentações'**
  String get statementTitle;

  /// No description provided for @statementSale.
  ///
  /// In pt, this message translates to:
  /// **'Compra no fiado'**
  String get statementSale;

  /// No description provided for @statementPayment.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento · {method}'**
  String statementPayment(String method);

  /// No description provided for @statementEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma movimentação ainda.'**
  String get statementEmpty;

  /// No description provided for @saleDetailCustomer.
  ///
  /// In pt, this message translates to:
  /// **'Cliente'**
  String get saleDetailCustomer;

  /// No description provided for @saleEditCustomer.
  ///
  /// In pt, this message translates to:
  /// **'Cliente do fiado'**
  String get saleEditCustomer;

  /// No description provided for @saleEditChooseCustomer.
  ///
  /// In pt, this message translates to:
  /// **'Escolher cliente'**
  String get saleEditChooseCustomer;

  /// No description provided for @saleEditChangeCustomer.
  ///
  /// In pt, this message translates to:
  /// **'Trocar'**
  String get saleEditChangeCustomer;

  /// No description provided for @saleEditMissingCustomer.
  ///
  /// In pt, this message translates to:
  /// **'Escolha o cliente do fiado.'**
  String get saleEditMissingCustomer;

  /// No description provided for @saleEditDeletedProduct.
  ///
  /// In pt, this message translates to:
  /// **'Um produto desta venda foi excluído do estoque. Remova-o para salvar.'**
  String get saleEditDeletedProduct;

  /// No description provided for @dashboardCreditTitle.
  ///
  /// In pt, this message translates to:
  /// **'Fiado a receber'**
  String get dashboardCreditTitle;

  /// No description provided for @dashboardRevenueTitle.
  ///
  /// In pt, this message translates to:
  /// **'Faturamento do dia'**
  String get dashboardRevenueTitle;

  /// No description provided for @navReports.
  ///
  /// In pt, this message translates to:
  /// **'Relatórios'**
  String get navReports;

  /// No description provided for @reportsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Relatórios'**
  String get reportsTitle;

  /// No description provided for @reportsToday.
  ///
  /// In pt, this message translates to:
  /// **'Hoje'**
  String get reportsToday;

  /// No description provided for @reportsWeek.
  ///
  /// In pt, this message translates to:
  /// **'Semana'**
  String get reportsWeek;

  /// No description provided for @reportsMonth.
  ///
  /// In pt, this message translates to:
  /// **'Mês'**
  String get reportsMonth;

  /// No description provided for @reportsCustom.
  ///
  /// In pt, this message translates to:
  /// **'Período'**
  String get reportsCustom;

  /// No description provided for @reportsRangeToday.
  ///
  /// In pt, this message translates to:
  /// **'Hoje, {date}'**
  String reportsRangeToday(String date);

  /// No description provided for @reportsRange.
  ///
  /// In pt, this message translates to:
  /// **'{from} – {to}'**
  String reportsRange(String from, String to);

  /// No description provided for @reportsRangeSwapped.
  ///
  /// In pt, this message translates to:
  /// **'A data inicial é depois da final: invertemos para calcular.'**
  String get reportsRangeSwapped;

  /// No description provided for @reportsProfit.
  ///
  /// In pt, this message translates to:
  /// **'Lucro líquido real'**
  String get reportsProfit;

  /// No description provided for @reportsMargin.
  ///
  /// In pt, this message translates to:
  /// **'Margem de {percent}% sobre o total vendido'**
  String reportsMargin(int percent);

  /// No description provided for @reportsNoSales.
  ///
  /// In pt, this message translates to:
  /// **'Sem vendas no período'**
  String get reportsNoSales;

  /// No description provided for @reportsRevenue.
  ///
  /// In pt, this message translates to:
  /// **'Total vendido'**
  String get reportsRevenue;

  /// No description provided for @reportsSaleCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{Nenhuma venda concluída} =1{1 venda concluída} other{{count} vendas concluídas}}'**
  String reportsSaleCount(int count);

  /// No description provided for @reportsCost.
  ///
  /// In pt, this message translates to:
  /// **'Custo dos produtos'**
  String get reportsCost;

  /// No description provided for @reportsCostHint.
  ///
  /// In pt, this message translates to:
  /// **'Preço de custo no momento da venda'**
  String get reportsCostHint;

  /// No description provided for @reportsCostValue.
  ///
  /// In pt, this message translates to:
  /// **'− {amount}'**
  String reportsCostValue(String amount);

  /// No description provided for @reportsProfitLine.
  ///
  /// In pt, this message translates to:
  /// **'= Lucro'**
  String get reportsProfitLine;

  /// No description provided for @reportsRankingTitle.
  ///
  /// In pt, this message translates to:
  /// **'Produtos que mais dão lucro'**
  String get reportsRankingTitle;

  /// No description provided for @reportsRankingHint.
  ///
  /// In pt, this message translates to:
  /// **'Ordenado pelo lucro gerado, não pela quantidade.'**
  String get reportsRankingHint;

  /// No description provided for @reportsRankingLine.
  ///
  /// In pt, this message translates to:
  /// **'{quantity} vendidos · {revenue}'**
  String reportsRankingLine(String quantity, String revenue);

  /// No description provided for @reportsRankingEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Sem vendas no período.'**
  String get reportsRankingEmpty;

  /// No description provided for @reportsFootnote.
  ///
  /// In pt, this message translates to:
  /// **'Considera só vendas concluídas e o preço de custo registrado no momento de cada venda.'**
  String get reportsFootnote;

  /// No description provided for @dashboardTodaySalesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Vendas de hoje'**
  String get dashboardTodaySalesTitle;

  /// No description provided for @dashboardSeeHistory.
  ///
  /// In pt, this message translates to:
  /// **'Ver histórico'**
  String get dashboardSeeHistory;

  /// No description provided for @dashboardNoSalesToday.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma venda hoje ainda.'**
  String get dashboardNoSalesToday;
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
