// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Vendaqui Cliente';

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
  String get splashLoading => 'Abrindo o Vendaqui…';

  @override
  String get loginTitle => 'Suas compras';

  @override
  String get loginSubtitle => 'Veja o que você comprou e quanto deve em cada loja.';

  @override
  String get loginByPhone => 'Telefone';

  @override
  String get loginByCpf => 'CPF';

  @override
  String get loginMethodLabel => 'Entrar com';

  @override
  String get phoneFieldLabel => 'Telefone / WhatsApp';

  @override
  String get phonePlaceholder => '(00) 00000-0000';

  @override
  String get cpfFieldLabel => 'CPF';

  @override
  String get cpfPlaceholder => '000.000.000-00';

  @override
  String get pinFieldLabel => 'PIN (4 a 6 números)';

  @override
  String get loginSubmit => 'Entrar';

  @override
  String get loginMissingFields => 'Preencha o telefone ou CPF e o PIN.';

  @override
  String get loginInvalidCpf => 'CPF inválido. Confira os 11 números.';

  @override
  String get loginNoAccessHint =>
      'Ainda não tem acesso ou esqueceu o PIN? Peça o link de acesso para a loja onde você compra. Ele chega pelo WhatsApp: copie a mensagem e cole aqui no app.';

  @override
  String get loginHaveInvite => 'Tenho um link de acesso';

  @override
  String get inviteTitle => 'Acesso às suas compras';

  @override
  String inviteFrom(String merchant, String ending) {
    return 'Link enviado por $merchant para o número terminado em $ending.';
  }

  @override
  String get inviteCreatePinIntro => 'Crie um PIN para entrar quando quiser. Você vai usar o seu telefone ou CPF e este PIN.';

  @override
  String get inviteCurrentPinIntro => 'Você já tem acesso em outra loja. Digite o seu PIN para juntar esta loja às outras.';

  @override
  String get inviteResetPinIntro =>
      'Ao criar um PIN novo, as outras lojas saem da sua consulta até cada uma enviar um link novo. Isso protege as suas compras.';

  @override
  String get inviteNewPinLabel => 'PIN novo (4 a 6 números)';

  @override
  String get inviteConfirmPinLabel => 'Repita o PIN';

  @override
  String get inviteCurrentPinLabel => 'Seu PIN';

  @override
  String get inviteForgotPin => 'Esqueci o PIN, criar um novo';

  @override
  String get inviteKnowPin => 'Lembrei o PIN';

  @override
  String get inviteSubmit => 'Liberar acesso';

  @override
  String get invitePinsDiffer => 'Os PINs não conferem.';

  @override
  String get invitePinTooShort => 'O PIN deve ter de 4 a 6 números.';

  @override
  String get inviteInvalidTitle => 'Este link não vale mais';

  @override
  String get inviteInvalidBody => 'O link de acesso vale por 24 horas e só pode ser usado uma vez. Peça um link novo para a loja.';

  @override
  String get inviteGoToLogin => 'Já tenho PIN, entrar';

  @override
  String get inviteAccepted => 'Acesso liberado.';

  @override
  String get pasteInviteTitle => 'Link de acesso';

  @override
  String get pasteInviteSubtitle => 'Na conversa com a loja no WhatsApp, toque e segure a mensagem com o link, escolha Copiar e cole aqui.';

  @override
  String get pasteInviteFieldLabel => 'Link ou mensagem da loja';

  @override
  String get pasteInvitePaste => 'Colar';

  @override
  String get pasteInviteContinue => 'Continuar';

  @override
  String get pasteInviteNotFound => 'Não achamos um link de acesso nesse texto. Copie a mensagem da loja de novo.';

  @override
  String get storesTitle => 'Minhas lojas';

  @override
  String get storesSubtitle => 'Toque numa loja para ver as compras e os pagamentos.';

  @override
  String get storesEmpty => 'Nenhuma loja ligada ao seu acesso. Peça o link de acesso para a loja onde você compra.';

  @override
  String get storesLogout => 'Sair';

  @override
  String get storesAddStore => 'Colar link de outra loja';

  @override
  String get storeOwes => 'Você deve';

  @override
  String get storeNothingOwed => 'Nada em aberto';

  @override
  String storeDueOn(String date) {
    return 'Vence em $date';
  }

  @override
  String storeOpenStatement(String merchant) {
    return 'Ver movimentações de $merchant';
  }

  @override
  String get statementEmpty => 'Nenhuma compra fiado ou pagamento nesta loja ainda.';

  @override
  String get statementPurchase => 'Compra fiado';

  @override
  String get statementPayment => 'Pagamento';

  @override
  String statementPaymentWith(String method) {
    return 'Pagamento em $method';
  }

  @override
  String get paymentMethodCash => 'dinheiro';

  @override
  String get paymentMethodPix => 'Pix';

  @override
  String get paymentMethodCard => 'cartão';

  @override
  String get back => 'Voltar';
}
