// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Vendaqui';

  @override
  String get brandPrefix => 'Vend';

  @override
  String get brandSuffix => 'aqui';

  @override
  String get genericNetworkError => 'Sem conexão com o servidor. Confira a internet e tente de novo.';

  @override
  String get genericServerError => 'Algo deu errado do nosso lado. Tente de novo em instantes.';

  @override
  String get genericSessionExpired => 'Sua sessão terminou. Entre de novo com seu PIN.';

  @override
  String get retry => 'Tentar de novo';

  @override
  String get back => 'Voltar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get continueAction => 'Continuar';

  @override
  String get decimalSeparatorKey => 'Vírgula';

  @override
  String get splashLoading => 'Abrindo o Vendaqui…';

  @override
  String get welcomeHeadline => 'Venda rápido,\nlucre mais';

  @override
  String get welcomeSubtitle => 'Vendas, estoque e fiado do seu comércio num só lugar, em poucos toques.';

  @override
  String get welcomeStart => 'Começar agora';

  @override
  String get welcomeHaveAccount => 'Já tenho conta · ';

  @override
  String get welcomeSignIn => 'Entrar';

  @override
  String get welcomeImageLabel => 'Ilustração de uma feirante sorrindo na sua banca de frutas e verduras';

  @override
  String get loginTitle => 'Entrar';

  @override
  String get loginSubtitle => 'Use seu telefone e seu PIN.';

  @override
  String get phoneFieldLabel => 'Telefone / WhatsApp';

  @override
  String get phonePlaceholder => '(00) 00000-0000';

  @override
  String get pinFieldLabel => 'PIN (4 a 6 números)';

  @override
  String get loginForgotPin => 'Esqueci meu PIN';

  @override
  String get loginCreateAccount => 'Criar conta';

  @override
  String get loginSubmit => 'Entrar';

  @override
  String get loginMissingFields => 'Preencha o telefone e o PIN.';

  @override
  String get loginWelcome => 'Bem-vindo! Você continua conectado até sair.';

  @override
  String get registerTitle => 'Cadastro';

  @override
  String get registerStepOne => 'Etapa 1 de 2';

  @override
  String get registerStepTwo => 'Etapa 2 de 2 · PIN';

  @override
  String get registerBusinessTitle => 'Dados do comércio';

  @override
  String get registerBusinessSubtitle => 'Como seus clientes conhecem você.';

  @override
  String get registerNameLabel => 'Nome do comércio ou vendedor';

  @override
  String get registerNameHint => 'Ex.: Banca do Seu João';

  @override
  String get registerPhoneLabel => 'Telefone (WhatsApp)';

  @override
  String get registerPhoneHint => 'Você vai usar este número para entrar no app.';

  @override
  String get registerNameRequired => 'Informe o nome do comércio ou vendedor.';

  @override
  String get registerPhoneInvalid => 'Informe um telefone válido com DDD.';

  @override
  String get registerPhoneTaken => 'Este telefone já está cadastrado.';

  @override
  String get registerCreatePinTitle => 'Crie seu PIN';

  @override
  String get registerCreatePinSubtitle => 'Escolha de 4 a 6 números. Você vai usar para entrar no app.';

  @override
  String get registerRepeatPinTitle => 'Repita o PIN';

  @override
  String get registerRepeatPinSubtitle => 'Digite o mesmo PIN mais uma vez.';

  @override
  String get registerPinTooShort => 'Use pelo menos 4 números.';

  @override
  String get registerPinMismatch => 'Os PINs não conferem. Tente de novo.';

  @override
  String get registerDone => 'Cadastro concluído. Você já está conectado.';

  @override
  String get recoverTitle => 'Recuperar PIN';

  @override
  String recoverStep(int step) {
    return 'Passo $step de 3';
  }

  @override
  String get recoverPhoneTitle => 'Qual é o seu telefone?';

  @override
  String get recoverPhoneSubtitle => 'Vamos enviar um código pelo WhatsApp.';

  @override
  String get recoverSendCode => 'Enviar código';

  @override
  String get recoverCodeTitle => 'Digite o código';

  @override
  String recoverCodeSubtitle(String phone) {
    return 'Código de 6 dígitos enviado para $phone.';
  }

  @override
  String get recoverResendCode => 'Reenviar código';

  @override
  String get recoverCodeSent => 'Código enviado pelo WhatsApp.';

  @override
  String get recoverNewPinTitle => 'Crie um novo PIN';

  @override
  String get recoverNewPinSubtitle => 'De 4 a 6 números.';

  @override
  String get recoverSaveNewPin => 'Salvar novo PIN';

  @override
  String get recoverPhoneInvalid => 'Digite o telefone com DDD.';

  @override
  String get recoverPinTooShort => 'O PIN precisa ter de 4 a 6 números.';

  @override
  String get recoverDone => 'PIN alterado. Você já está conectado.';

  @override
  String get navHome => 'Início';

  @override
  String get navStock => 'Estoque';

  @override
  String get dashboardSettings => 'Configurações';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsAppearance => 'Aparência';

  @override
  String get settingsAccount => 'Conta';

  @override
  String get settingsLogout => 'Sair da conta';

  @override
  String get themeSystem => 'Igual ao celular';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get themeHint => 'A escolha fica salva neste aparelho.';

  @override
  String get settingsLoggedOut => 'Você saiu. Entre com seu PIN.';

  @override
  String get greetingMorning => 'Bom dia';

  @override
  String get greetingAfternoon => 'Boa tarde';

  @override
  String get greetingEvening => 'Boa noite';

  @override
  String greetingLine(String greeting) {
    return '$greeting,';
  }

  @override
  String greetingLineWithName(String greeting, String name) {
    return '$greeting, $name,';
  }

  @override
  String get greetingCallToAction => 'bora vender?';

  @override
  String get dashboardStockCardTitle => 'Seu estoque';

  @override
  String dashboardProductCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count produtos', one: '1 produto', zero: 'Nenhum produto');
    return '$_temp0';
  }

  @override
  String dashboardLowCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count com estoque baixo', one: '1 com estoque baixo');
    return '$_temp0';
  }

  @override
  String dashboardOutCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count esgotados', one: '1 esgotado');
    return '$_temp0';
  }

  @override
  String get dashboardAllGood => 'Tudo em dia';

  @override
  String get shortcutsTitle => 'Atalhos';

  @override
  String get shortcutRestock => 'Repor estoque';

  @override
  String get shortcutNewProduct => 'Novo produto';

  @override
  String get shortcutStock => 'Ver estoque';

  @override
  String get stockAlertsTitle => 'Atenção ao estoque';

  @override
  String get seeAll => 'Ver todos';

  @override
  String get restockAction => 'Repor';

  @override
  String stockRemaining(String quantity) {
    return 'Restam $quantity';
  }

  @override
  String get dashboardNoProducts => 'Cadastre seu primeiro produto para começar.';

  @override
  String get stockTitle => 'Estoque';

  @override
  String stockSubtitle(int count, int threshold) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count produtos', one: '1 produto');
    return '$_temp0 · estoque baixo: até $threshold unid./kg';
  }

  @override
  String get searchProductHint => 'Buscar produto pelo nome';

  @override
  String stockFilterAll(int count) {
    return 'Todos $count';
  }

  @override
  String stockFilterLow(int count) {
    return 'Baixo $count';
  }

  @override
  String stockFilterOut(int count) {
    return 'Esgotado $count';
  }

  @override
  String get stockEmpty => 'Nenhum produto aqui.';

  @override
  String get stockEndOfList => 'Fim da lista';

  @override
  String get stockAddProduct => 'Adicionar Produto';

  @override
  String stockSalePrice(String price) {
    return 'Venda $price';
  }

  @override
  String stockCostPrice(String price) {
    return ' · Custo $price';
  }

  @override
  String get stockLevelOk => 'Normal';

  @override
  String get stockLevelLow => 'Baixo';

  @override
  String get stockLevelOut => 'Esgotado';

  @override
  String get unitKg => 'kg';

  @override
  String get unitPiece => 'un';

  @override
  String quantityWithUnit(String quantity, String unit) {
    return '$quantity $unit';
  }

  @override
  String get productNewTitle => 'Novo produto';

  @override
  String get productEditTitle => 'Editar produto';

  @override
  String get productPhotoPick => 'tirar ou escolher foto';

  @override
  String get productPhotoChange => 'foto do produto · tocar para trocar';

  @override
  String get productPhotoFromCamera => 'Tirar foto';

  @override
  String get productPhotoFromGallery => 'Escolher da galeria';

  @override
  String get productPhotoTooLarge => 'A foto passa de 5 MB. Escolha outra.';

  @override
  String get productPhotoUnsupported => 'Use uma foto JPEG, PNG ou WebP.';

  @override
  String get productPhotoUploadFailed => 'O produto foi salvo, mas a foto não foi enviada. Tente trocar a foto de novo.';

  @override
  String get productNameLabel => 'Nome do produto';

  @override
  String get productNameHint => 'Ex.: Tomate';

  @override
  String get productSalePriceLabel => 'Preço de venda';

  @override
  String get productCostPriceLabel => 'Preço de custo';

  @override
  String get currencySymbol => 'R\$';

  @override
  String get moneyHint => '0,00';

  @override
  String productMargin(String unit, String profit, int percent) {
    return 'Lucro por $unit: $profit ($percent%)';
  }

  @override
  String get productMarginNegative => 'O custo está maior ou igual ao preço de venda.';

  @override
  String get productInitialQuantity => 'Quantidade inicial';

  @override
  String get productStockQuantity => 'Quantidade em estoque';

  @override
  String get quantityHint => '0';

  @override
  String get productSoldByWeight => 'Vendido por peso (kg)';

  @override
  String get productSoldByWeightHint => 'Na venda, segure o produto para digitar o peso.';

  @override
  String get productSave => 'Salvar produto';

  @override
  String get productNameRequired => 'Informe o nome do produto.';

  @override
  String get productSalePriceRequired => 'Informe o preço de venda.';

  @override
  String get productCostPriceRequired => 'Informe o preço de custo.';

  @override
  String get productQuantityInvalid => 'Informe a quantidade. Por unidade, use número inteiro; por peso, até 3 casas.';

  @override
  String get productCreated => 'Produto cadastrado.';

  @override
  String get productUpdated => 'Produto atualizado.';

  @override
  String get productLoadFailed => 'Não foi possível carregar o produto.';

  @override
  String get restockTitle => 'Repor estoque';

  @override
  String restockCurrent(String quantity) {
    return 'Atual: $quantity';
  }

  @override
  String get restockAmountLabel => 'Quantidade a adicionar';

  @override
  String get restockAmountSign => '+';

  @override
  String get restockAmountHint => '0';

  @override
  String restockNewTotal(String quantity) {
    return 'Novo total: $quantity';
  }

  @override
  String get restockConfirm => 'Confirmar reposição';

  @override
  String get restockDone => 'Estoque atualizado.';
}
