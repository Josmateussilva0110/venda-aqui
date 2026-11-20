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
  String get dashboardReminders => 'Lembretes do fiado';

  @override
  String dashboardRemindersPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Lembretes do fiado: $count para enviar',
      one: 'Lembretes do fiado: 1 para enviar',
    );
    return '$_temp0';
  }

  @override
  String badgeOverflow(int max) {
    return '$max+';
  }

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
  String get productDelete => 'Remover produto';

  @override
  String get productDeleteConfirmTitle => 'Remover produto?';

  @override
  String productDeleteConfirmMessage(String name) {
    return '\"$name\" sai do estoque. As vendas já feitas com ele continuam no histórico. Não dá para desfazer.';
  }

  @override
  String get productDeleteConfirm => 'Remover';

  @override
  String get productDeleted => 'Produto removido.';

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

  @override
  String get navSell => 'Vender';

  @override
  String get dashboardRegisterSale => 'Registrar venda';

  @override
  String get shortcutSalesHistory => 'Vendas';

  @override
  String get sellTitle => 'Nova venda';

  @override
  String get sellHint => 'Toque para somar 1 · segure para pesar';

  @override
  String get sellClear => 'Limpar';

  @override
  String get sellSearchHint => 'Buscar produto pelo nome';

  @override
  String get sellEmpty => 'Nenhum produto encontrado.';

  @override
  String get sellByWeight => 'por peso';

  @override
  String get sellOutOfStock => 'Esgotado';

  @override
  String sellStock(String quantity) {
    return 'Estoque: $quantity';
  }

  @override
  String get sellNoStock => 'Sem estoque';

  @override
  String sellUnitPrice(String price, String unit) {
    return '$price /$unit';
  }

  @override
  String get sellViewSummary => 'Ver resumo';

  @override
  String sellInCart(String quantity) {
    return '$quantity no carrinho';
  }

  @override
  String cartItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count itens', one: '1 item');
    return '$_temp0';
  }

  @override
  String cartOutOfStock(String name) {
    return '$name está esgotado.';
  }

  @override
  String cartInsufficientStock(String quantity) {
    return 'Estoque insuficiente: $quantity';
  }

  @override
  String get cartInvalidQuantity => 'Este produto é vendido por unidade: use um número inteiro.';

  @override
  String get weightTitle => 'Vender por peso';

  @override
  String get weightRequired => 'Digite o peso.';

  @override
  String weightAvailable(String quantity) {
    return 'Estoque disponível: $quantity';
  }

  @override
  String get weightAdd => 'Adicionar';

  @override
  String get weightUpdate => 'Atualizar';

  @override
  String get weightQuick250 => '250 g';

  @override
  String get weightQuick500 => '500 g';

  @override
  String get weightQuick1kg => '1 kg';

  @override
  String get summaryTitle => 'Resumo da venda';

  @override
  String get summaryEmpty => 'A venda está vazia.';

  @override
  String get summaryAddMore => '+ Adicionar mais itens';

  @override
  String get summaryItems => 'Itens';

  @override
  String get summaryTotal => 'Total';

  @override
  String get summaryFinish => 'Finalizar venda';

  @override
  String get summaryRemove => 'Remover';

  @override
  String summaryEditWeight(String quantity) {
    return '$quantity · editar';
  }

  @override
  String get summaryDecrease => 'Diminuir';

  @override
  String get summaryIncrease => 'Aumentar';

  @override
  String get paymentTitle => 'Pagamento';

  @override
  String get paymentTotal => 'Total a receber';

  @override
  String get paymentQuestion => 'Como o cliente vai pagar?';

  @override
  String get paymentHint => 'Um toque na forma de pagamento conclui a venda e dá baixa no estoque.';

  @override
  String get paymentCash => 'Dinheiro';

  @override
  String get paymentCashDetail => 'Em espécie';

  @override
  String get paymentPix => 'PIX';

  @override
  String get paymentPixDetail => 'Transferência na hora';

  @override
  String get paymentCard => 'Cartão';

  @override
  String get paymentCardDetail => 'Débito ou crédito';

  @override
  String get saleDoneTitle => 'Venda registrada!';

  @override
  String get saleDoneBackHome => 'Voltar ao início';

  @override
  String get saleDoneNewSale => 'Nova venda';

  @override
  String saleDoneCountdown(int seconds) {
    return 'Voltando ao início em ${seconds}s';
  }

  @override
  String get historyTitle => 'Histórico de vendas';

  @override
  String historySaleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count vendas', one: '1 venda', zero: 'Nenhuma venda');
    return '$_temp0';
  }

  @override
  String historySummary(String count, String total) {
    return '$count · $total';
  }

  @override
  String get historyToday => 'Hoje';

  @override
  String get historyYesterday => 'Ontem';

  @override
  String get historyWeek => '7 dias';

  @override
  String get historyMonth => '30 dias';

  @override
  String get historyCustom => 'Período';

  @override
  String get historyFrom => 'De';

  @override
  String get historyTo => 'Até';

  @override
  String get historyInvalidRange => 'A data inicial precisa ser antes da final.';

  @override
  String get historySearchHint => 'Buscar produto';

  @override
  String get historyAllMethods => 'Todas';

  @override
  String get historyEmpty => 'Nenhuma venda encontrada.';

  @override
  String historyProductCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count produtos', one: '1 produto');
    return '$_temp0';
  }

  @override
  String get saleDetailTitle => 'Detalhe da venda';

  @override
  String get saleDetailTotal => 'Total da venda';

  @override
  String get saleDetailPayment => 'Pagamento';

  @override
  String get saleDetailItems => 'Itens';

  @override
  String get saleDetailProducts => 'Produtos';

  @override
  String saleDetailEdited(String date) {
    return 'Editada em $date';
  }

  @override
  String get saleDetailEdit => 'Editar venda';

  @override
  String saleLine(String quantity, String price) {
    return '$quantity × $price';
  }

  @override
  String get saleLoadFailed => 'Não foi possível carregar a venda.';

  @override
  String get saleEditTitle => 'Editar venda';

  @override
  String get saleEditMethod => 'Forma de pagamento';

  @override
  String get saleEditNewTotal => 'Novo total';

  @override
  String get saleEditSave => 'Salvar alterações';

  @override
  String get saleEditNoItems => 'A venda precisa ter pelo menos um produto.';

  @override
  String get saleEditSaved => 'Venda atualizada.';

  @override
  String get paymentCredit => 'Fiado';

  @override
  String get paymentCreditDetail => 'Cliente paga depois';

  @override
  String saleDoneCredit(String name) {
    return 'Fiado · $name';
  }

  @override
  String get creditPickerTitle => 'Venda no fiado';

  @override
  String get creditPickerAmount => 'Valor a anotar';

  @override
  String get creditPickerQuestion => 'Para qual cliente?';

  @override
  String get creditPickerEmpty => 'Nenhum cliente encontrado. Cadastre um novo.';

  @override
  String creditPickerConfirm(String name) {
    return 'Anotar para $name';
  }

  @override
  String get creditPickerSelect => 'Selecione um cliente';

  @override
  String get creditPickerHint => 'A venda entra no caixa do dia e fica pendente na conta do cliente.';

  @override
  String get customerSearchHint => 'Buscar por nome ou telefone';

  @override
  String get customerNewButton => 'Cadastrar novo cliente';

  @override
  String get customerNewTitle => 'Novo cliente';

  @override
  String get customerNameLabel => 'Nome';

  @override
  String get customerNamePlaceholder => 'Ex.: Dona Maria';

  @override
  String get customerPhoneLabel => 'Telefone (WhatsApp)';

  @override
  String get customerNameInvalid => 'Use pelo menos 2 letras.';

  @override
  String get customerPhoneInvalid => 'Telefone inválido. Use DDD + número.';

  @override
  String get customerCpfLabel => 'CPF (opcional)';

  @override
  String get customerCpfPlaceholder => '000.000.000-00';

  @override
  String get customerCpfInvalid => 'CPF inválido. Confira os 11 números.';

  @override
  String get customerSave => 'Salvar cliente';

  @override
  String get customerSaved => 'Cliente cadastrado.';

  @override
  String get customerEditTitle => 'Editar cliente';

  @override
  String get customerUpdate => 'Salvar alterações';

  @override
  String get customerUpdated => 'Cliente atualizado.';

  @override
  String get customerEditHint => 'Saldo, vencimento e histórico continuam com o cliente.';

  @override
  String get customerDelete => 'Excluir cliente';

  @override
  String get customerDeleteConfirmTitle => 'Excluir cliente?';

  @override
  String customerDeleteConfirmMessage(String name) {
    return '\"$name\" sai da sua lista de clientes. Não dá para desfazer.';
  }

  @override
  String get customerDeleteConfirm => 'Excluir';

  @override
  String get customerDeleted => 'Cliente excluído.';

  @override
  String customerOwes(String amount) {
    return 'Deve $amount';
  }

  @override
  String get customerUpToDate => 'Em dia';

  @override
  String get debtorsTitle => 'Fiado';

  @override
  String get debtorsSubtitle => 'Clientes que compraram para pagar depois';

  @override
  String get debtorsTotal => 'Total a receber';

  @override
  String debtorsOwingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count clientes devendo',
      one: '1 cliente devendo',
      zero: 'Ninguém devendo',
    );
    return '$_temp0';
  }

  @override
  String get debtorsSearchHint => 'Buscar cliente';

  @override
  String get debtorsFilterOwing => 'Devendo';

  @override
  String get debtorsFilterAll => 'Todos';

  @override
  String get debtorsEmptyOwing => 'Ninguém devendo.';

  @override
  String get debtorsEmpty => 'Nenhum cliente encontrado.';

  @override
  String get accountTitle => 'Conta do cliente';

  @override
  String get accountBalance => 'Valor devendo';

  @override
  String get accountClear => 'Nenhuma conta em aberto';

  @override
  String get accountReceivePart => 'Receber parte';

  @override
  String get accountReceiveAll => 'Receber tudo';

  @override
  String get receiveAmountQuestion => 'Quanto o cliente está pagando?';

  @override
  String get receiveHalf => 'Metade';

  @override
  String receiveCurrentDebt(String amount) {
    return 'Dívida atual: $amount';
  }

  @override
  String receiveRemaining(String amount) {
    return 'Restará $amount';
  }

  @override
  String get receiveSettles => 'Quita a dívida';

  @override
  String get receiveMethodQuestion => 'Como o cliente pagou?';

  @override
  String get receiveConfirm => 'Confirmar pagamento';

  @override
  String get receiveInvalidAmount => 'Informe um valor maior que zero.';

  @override
  String get receiveExceedsBalance => 'O valor passa da dívida do cliente.';

  @override
  String get receiveDone => 'Pagamento registrado.';

  @override
  String get whatsAppChat => 'Conversar no WhatsApp';

  @override
  String get whatsAppCharge => 'Cobrar no WhatsApp';

  @override
  String reminderGreeting(String name) {
    return 'Olá, $name. Tudo bem?';
  }

  @override
  String reminderOpeningUpcoming(String amount, String date) {
    return 'Gostaria de lembrar que o seu saldo em aberto conosco é de *$amount*, com vencimento em *$date*.';
  }

  @override
  String reminderOpeningDue(String amount) {
    return 'Lembramos que hoje vence o seu saldo de *$amount*.';
  }

  @override
  String reminderOpeningOverdue(String amount, String date) {
    return 'Identificamos que o saldo de *$amount*, vencido em *$date*, ainda está em aberto.';
  }

  @override
  String get reminderClosingHelp => 'Em caso de dúvida, estou à disposição.';

  @override
  String get reminderClosingNewTerm => 'Caso precise de um novo prazo, é só responder esta mensagem.';

  @override
  String get reminderPurchasesTitle => '*Compras:*';

  @override
  String reminderPurchaseItem(String item) {
    return '• $item';
  }

  @override
  String reminderPurchaseMoreItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '• Mais $count itens', one: '• Mais 1 item');
    return '$_temp0';
  }

  @override
  String reminderPurchasesEarlier(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '• +$count compras', one: '• +1 compra');
    return '$_temp0';
  }

  @override
  String reminderPaid(String amount) {
    return '*Já pago:* $amount';
  }

  @override
  String get reminderLoadFailed => 'Não foi possível carregar as compras do cliente. Tente de novo.';

  @override
  String reminderSignature(String merchant) {
    return 'Atenciosamente, $merchant.';
  }

  @override
  String get reminderSignatureAnonymous => 'Atenciosamente.';

  @override
  String get reminderAlertTitle => 'Lembretes do fiado';

  @override
  String get reminderAlertBody => 'Há clientes para lembrar hoje. Abra o Vendaqui para enviar pelo WhatsApp.';

  @override
  String get reminderChannelName => 'Lembretes do fiado';

  @override
  String get reminderChannelDescription => 'Avisa no dia de lembrar os clientes do fiado.';

  @override
  String dueDateLabel(String date) {
    return 'Vence em $date';
  }

  @override
  String get dueDateToday => 'Vence hoje';

  @override
  String dueDateOverdue(String date) {
    return 'Venceu em $date';
  }

  @override
  String get dueDateExtend => 'Prolongar';

  @override
  String get dueDateHelp => 'Novo vencimento';

  @override
  String get dueDateSaved => 'Vencimento alterado.';

  @override
  String get remindersTitle => 'Lembretes de hoje';

  @override
  String get remindersSubtitle => 'Toque em enviar para abrir o WhatsApp com a mensagem pronta.';

  @override
  String get remindersEmpty => 'Nenhum lembrete para enviar agora.';

  @override
  String get remindersSend => 'Enviar lembrete';

  @override
  String get remindersSendAgain => 'Enviar de novo';

  @override
  String get remindersSent => 'Lembrete enviado';

  @override
  String remindersBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lembretes de fiado para enviar',
      one: '1 lembrete de fiado para enviar',
    );
    return '$_temp0';
  }

  @override
  String get creditSettingsTitle => 'Prazo e lembretes';

  @override
  String get creditSettingsSection => 'Fiado';

  @override
  String get creditSettingsTerm => 'Prazo para pagar';

  @override
  String get creditSettingsTermHint => 'Contado a partir da primeira compra no fiado.';

  @override
  String get creditSettingsReminders => 'Lembretes pelo WhatsApp';

  @override
  String get creditSettingsRemindersHint => 'O app avisa no dia e você envia a mensagem pelo seu WhatsApp.';

  @override
  String get creditSettingsBefore => 'Antes do vencimento';

  @override
  String get creditSettingsOnDue => 'No dia do vencimento';

  @override
  String get creditSettingsOverdue => 'Depois de vencido, a cada';

  @override
  String get creditSettingsHour => 'Horário do aviso';

  @override
  String get creditSettingsSave => 'Salvar';

  @override
  String get creditSettingsSaved => 'Configurações salvas.';

  @override
  String get creditSettingsOff => 'Não lembrar';

  @override
  String creditSettingsHourValue(int hour) {
    return '${hour}h';
  }

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count dias', one: '1 dia');
    return '$_temp0';
  }

  @override
  String get stepperDecrease => 'Diminuir';

  @override
  String get stepperIncrease => 'Aumentar';

  @override
  String get whatsAppUnavailable => 'Não foi possível abrir o WhatsApp.';

  @override
  String get portalAccessSend => 'Enviar acesso ao app';

  @override
  String get portalAccessHint =>
      'O cliente vê as compras e os pagamentos desta loja no app Vendaqui Cliente. O link vale por 24 horas e só uma vez; mandar de novo cancela o anterior.';

  @override
  String portalAccessMessage(String customerName, String merchantName, String link) {
    return 'Olá, $customerName! Agora você pode ver suas compras e pagamentos na $merchantName pelo app Vendaqui Cliente.\n\n1. Abra o app Vendaqui Cliente.\n2. Toque em \"Tenho um link de acesso\" e cole esta mensagem.\n3. Crie o seu PIN.\n\n$link\n\nO link vale por 24 horas e só pode ser usado uma vez.';
  }

  @override
  String portalAccessMessageNoStore(String customerName, String link) {
    return 'Olá, $customerName! Agora você pode ver suas compras e pagamentos aqui da loja pelo app Vendaqui Cliente.\n\n1. Abra o app Vendaqui Cliente.\n2. Toque em \"Tenho um link de acesso\" e cole esta mensagem.\n3. Crie o seu PIN.\n\n$link\n\nO link vale por 24 horas e só pode ser usado uma vez.';
  }

  @override
  String get statementTitle => 'Movimentações';

  @override
  String get statementSale => 'Compra no fiado';

  @override
  String statementPayment(String method) {
    return 'Pagamento · $method';
  }

  @override
  String get statementEmpty => 'Nenhuma movimentação ainda.';

  @override
  String get saleDetailCustomer => 'Cliente';

  @override
  String get saleEditCustomer => 'Cliente do fiado';

  @override
  String get saleEditChooseCustomer => 'Escolher cliente';

  @override
  String get saleEditChangeCustomer => 'Trocar';

  @override
  String get saleEditMissingCustomer => 'Escolha o cliente do fiado.';

  @override
  String get saleEditDeletedProduct => 'Um produto desta venda foi excluído do estoque. Remova-o para salvar.';

  @override
  String get dashboardCreditTitle => 'Fiado a receber';

  @override
  String get dashboardRevenueTitle => 'Faturamento do dia';

  @override
  String get navReports => 'Relatórios';

  @override
  String get reportsTitle => 'Relatórios';

  @override
  String get reportsToday => 'Hoje';

  @override
  String get reportsWeek => 'Semana';

  @override
  String get reportsMonth => 'Mês';

  @override
  String get reportsCustom => 'Período';

  @override
  String reportsRangeToday(String date) {
    return 'Hoje, $date';
  }

  @override
  String reportsRange(String from, String to) {
    return '$from – $to';
  }

  @override
  String get reportsRangeSwapped => 'A data inicial é depois da final: invertemos para calcular.';

  @override
  String get reportsProfit => 'Lucro líquido real';

  @override
  String reportsMargin(int percent) {
    return 'Margem de $percent% sobre o total vendido';
  }

  @override
  String get reportsNoSales => 'Sem vendas no período';

  @override
  String get reportsRevenue => 'Total vendido';

  @override
  String reportsSaleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vendas concluídas',
      one: '1 venda concluída',
      zero: 'Nenhuma venda concluída',
    );
    return '$_temp0';
  }

  @override
  String get reportsCost => 'Custo dos produtos';

  @override
  String get reportsCostHint => 'Preço de custo no momento da venda';

  @override
  String reportsCostValue(String amount) {
    return '− $amount';
  }

  @override
  String get reportsProfitLine => '= Lucro';

  @override
  String get reportsRankingTitle => 'Produtos que mais dão lucro';

  @override
  String get reportsRankingHint => 'Ordenado pelo lucro gerado, não pela quantidade.';

  @override
  String reportsRankingLine(String quantity, String revenue) {
    return '$quantity vendidos · $revenue';
  }

  @override
  String get reportsRankingEmpty => 'Sem vendas no período.';

  @override
  String get reportsFootnote => 'Considera só vendas concluídas e o preço de custo registrado no momento de cada venda.';

  @override
  String get dashboardTodaySalesTitle => 'Vendas de hoje';

  @override
  String get dashboardSeeHistory => 'Ver histórico';

  @override
  String get dashboardNoSalesToday => 'Nenhuma venda hoje ainda.';

  @override
  String offlineSavedToday(String time) {
    return 'Sem internet · dados das $time';
  }

  @override
  String offlineSavedOn(String date, String time) {
    return 'Sem internet · dados de $date, $time';
  }

  @override
  String get saleDonePendingSync => 'Sem internet: a venda ficou guardada no aparelho e será enviada sozinha quando a conexão voltar.';

  @override
  String get pendingChangesSent => 'O que foi feito sem internet já foi enviado.';

  @override
  String pendingSaleShortfall(String when, String products) {
    return 'Venda de $when enviada, mas faltou estoque: $products. O estoque desses produtos ficou em zero.';
  }

  @override
  String pendingSaleRejected(String when, String reason) {
    return 'A venda de $when não foi aceita: $reason';
  }

  @override
  String get pendingChangeRejectedFallback => 'o servidor recusou.';

  @override
  String get logoutPendingTitle => 'Alterações não enviadas';

  @override
  String logoutPendingMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alterações feitas sem internet ainda não foram enviadas. Se sair agora, elas serão perdidas.',
      one: '1 alteração feita sem internet ainda não foi enviada. Se sair agora, ela será perdida.',
    );
    return '$_temp0';
  }

  @override
  String get logoutPendingConfirm => 'Sair e perder';

  @override
  String get restockSavedOffline => 'Sem internet: a reposição ficou guardada e será enviada quando a conexão voltar.';

  @override
  String get receiveSavedOffline => 'Sem internet: o pagamento ficou guardado e será enviado quando a conexão voltar.';

  @override
  String pendingRestockRejected(String quantity, String product, String reason) {
    return 'A reposição de $quantity de $product não foi aceita: $reason';
  }

  @override
  String pendingPaymentRejected(String amount, String customer, String reason) {
    return 'O pagamento de $amount de $customer não foi aceito: $reason';
  }

  @override
  String get settingsOfflineSection => 'Sem internet';

  @override
  String get pendingChangesTitle => 'Alterações não enviadas';

  @override
  String get pendingChangesEmpty => 'Tudo enviado. Nada esperando internet.';

  @override
  String get pendingChangesStillOffline => 'Ainda sem internet. Tudo continua guardado e sobe sozinho quando a conexão voltar.';

  @override
  String get pendingChangesSendNow => 'Enviar agora';

  @override
  String pendingChangesWaitingSection(int count) {
    return 'Esperando internet ($count)';
  }

  @override
  String get pendingChangesWaitingHint => 'Sobem sozinhas, nesta ordem, quando a conexão voltar.';

  @override
  String pendingChangesRejectedSection(int count) {
    return 'Recusadas pelo servidor ($count)';
  }

  @override
  String get pendingChangesRejectedHint => 'Confira o motivo. Depois de corrigir, tente de novo; se não fizer mais sentido, descarte.';

  @override
  String pendingChangesBannerWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alterações esperando internet',
      one: '1 alteração esperando internet',
    );
    return '$_temp0';
  }

  @override
  String pendingChangesBannerRejected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alterações recusadas: toque para ver',
      one: '1 alteração recusada: toque para ver',
    );
    return '$_temp0';
  }

  @override
  String get pendingChangeRetry => 'Tentar de novo';

  @override
  String get pendingChangeDiscard => 'Descartar';

  @override
  String get pendingChangeDiscardTitle => 'Descartar alteração?';

  @override
  String pendingChangeDiscardMessage(String change) {
    return '$change não vai para o servidor e some deste aparelho. Isso não pode ser desfeito.';
  }

  @override
  String get pendingChangeUnknown => 'Alteração';

  @override
  String pendingSaleTitle(String total) {
    return 'Venda de $total';
  }

  @override
  String get pendingSaleTitleUnknown => 'Venda';

  @override
  String pendingPaymentTitle(String amount) {
    return 'Pagamento de fiado de $amount';
  }

  @override
  String pendingRestockTitle(String product) {
    return 'Reposição de $product';
  }

  @override
  String pendingRestockDetail(String quantity) {
    return '+$quantity no estoque';
  }

  @override
  String pendingCustomerTitle(String name) {
    return 'Cadastro de $name';
  }

  @override
  String pendingCustomerRejected(String change, String reason) {
    return '$change não foi aceito: $reason';
  }

  @override
  String dashboardPendingSales(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Inclui $count vendas feitas sem internet, ainda não enviadas',
      one: 'Inclui 1 venda feita sem internet, ainda não enviada',
    );
    return '$_temp0';
  }

  @override
  String get dashboardPendingSaleTooltip => 'Feita sem internet, ainda não enviada';

  @override
  String get historyOnlyPending => 'Sem internet: mostrando só as vendas feitas neste aparelho que ainda não foram enviadas.';
}
