import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'local_database.g.dart';

/// Cópia dos produtos do comércio para consultar sem internet. Quem manda é o servidor:
/// a cópia é substituída a cada sincronização e nunca é enviada de volta.
@DataClassName('LocalProduct')
@TableIndex(name: 'local_products_search_key', columns: {#searchKey})
class LocalProducts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  /// Nome em minúsculas, para a busca sem diferenciar maiúsculas (como o `ilike` do servidor).
  TextColumn get searchKey => text()();
  TextColumn get photoUrl => text().nullable()();
  TextColumn get thumbUrl => text().nullable()();
  IntColumn get salePriceCents => integer()();
  IntColumn get costPriceCents => integer()();
  RealColumn get quantity => real()();
  BoolColumn get soldByWeight => boolean()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Cópia dos clientes e do saldo do fiado na última sincronização.
@DataClassName('LocalCustomer')
@TableIndex(name: 'local_customers_search_key', columns: {#searchKey})
class LocalCustomers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get searchKey => text()();
  TextColumn get phone => text()();
  IntColumn get balanceCents => integer()();

  /// "AAAA-MM-DD", como a API manda: guardar como data mudaria o dia em outro fuso.
  TextColumn get creditDueDate => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Valores soltos da sincronização (quando foi a última, limite de estoque baixo).
class SyncMarks extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

/// Alterações feitas sem internet, esperando para ir ao servidor na ordem em que aconteceram.
/// Ao contrário da cópia, isto é dado que só existe no aparelho: nunca é apagado sem o comerciante saber.
@DataClassName('OutboxEntry')
@TableIndex(name: 'outbox_owner_created', columns: {#ownerId, #createdAt, #sequence})
class OutboxEntries extends Table {
  /// Gerado no aparelho e enviado ao servidor: reenviar a mesma alteração não a duplica.
  TextColumn get id => text()();

  /// Comércio que fez a alteração: com outra conta no aparelho, ela espera o dono voltar.
  TextColumn get ownerId => text()();

  /// Que tipo de alteração é (ex.: venda); decide quem envia.
  TextColumn get kind => text()();

  /// Corpo da requisição, em JSON, exatamente como vai ao servidor.
  TextColumn get payload => text()();
  DateTimeColumn get createdAt => dateTime()();

  /// Desempate da ordem: [createdAt] é guardado em segundos, e uma venda fiado seguida do pagamento do
  /// mesmo cliente no mesmo segundo não pode subir invertida (o pagamento seria recusado).
  IntColumn get sequence => integer().withDefault(const Constant(0))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();

  /// Recusada pelo servidor (ex.: produto apagado): não é tentada de novo sozinha.
  BoolColumn get rejected => boolean().withDefault(const Constant(false))();

  /// Motivo da recusa, já pronto para mostrar ao comerciante.
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [LocalProducts, LocalCustomers, SyncMarks, OutboxEntries])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase(super.executor);

  /// Arquivo no diretório privado do app; as consultas rodam fora da thread da interface.
  factory LocalDatabase.open() => LocalDatabase(driftDatabase(name: _fileName));

  static const _fileName = 'vendaqui_offline';

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(outboxEntries);
        await migrator.createIndex(outboxOwnerCreated);
      } else if (from < 3) {
        // Na v2 a fila já existia sem o desempate; as que estão nela ficam com 0 e desempatam pelo id.
        // O índice passa a cobrir a ordem inteira: o envio pega a próxima sem ordenar a fila toda a cada item
        await migrator.addColumn(outboxEntries, outboxEntries.sequence);
        await migrator.drop(outboxOwnerCreated);
        await migrator.createIndex(outboxOwnerCreated);
      }
    },
  );

  /// Apaga a cópia do servidor (saída da conta ou troca de comércio). A fila de alterações fica:
  /// ela só sai depois de enviada ou quando o comerciante aceita perdê-la.
  Future<void> clearCopy() {
    return transaction(() async {
      for (final table in <TableInfo<Table, Object?>>[localProducts, localCustomers, syncMarks]) {
        await delete(table).go();
      }
    });
  }
}
