import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vendaqui/core/offline/local_database.dart';

void main() {
  // Quem instalou a versão com o banco v1 (só a cópia) recebe a fila de vendas sem perder a cópia
  test('banco v1 ganha a fila na atualização e mantém a cópia', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

    // O esquema v1 é o atual sem a fila: tirado do próprio banco para não divergir do código gerado
    final current = LocalDatabase(NativeDatabase.memory());
    final rows = await current.customSelect("SELECT sql FROM sqlite_master WHERE sql IS NOT NULL AND name NOT LIKE 'outbox%'").get();
    final v1Schema = rows.map((row) => row.read<String>('sql')).toList();
    await current.close();

    final upgraded = LocalDatabase(
      NativeDatabase.memory(
        setup: (raw) {
          for (final statement in v1Schema) {
            raw.execute(statement);
          }
          raw.execute(
            'INSERT INTO local_products (id, name, search_key, sale_price_cents, cost_price_cents, quantity, sold_by_weight) '
            "VALUES ('p1', 'Arroz', 'arroz', 500, 300, 2, 0)",
          );
          raw.execute('PRAGMA user_version = 1');
        },
      ),
    );

    expect((await upgraded.select(upgraded.localProducts).getSingle()).name, 'Arroz');
    await upgraded
        .into(upgraded.outboxEntries)
        .insert(OutboxEntriesCompanion.insert(id: 'v1', ownerId: 'm1', kind: 'sale', payload: '{}', createdAt: DateTime(2026, 11, 15)));
    expect(await upgraded.select(upgraded.outboxEntries).get(), hasLength(1));
    final indexes = await upgraded
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'index' AND name = 'outbox_owner_created'")
        .get();
    expect(indexes, hasLength(1));
    await upgraded.close();
  });

  // Quem testou as etapas 2 e 3 tem a fila v2 (sem o desempate): ela não pode se perder na atualização
  test('banco v2 ganha o desempate da fila sem perder o que estava esperando', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final current = LocalDatabase(NativeDatabase.memory());
    final rows = await current.customSelect("SELECT sql FROM sqlite_master WHERE sql IS NOT NULL AND name NOT LIKE 'outbox%'").get();
    final copySchema = rows.map((row) => row.read<String>('sql')).toList();
    await current.close();

    final upgraded = LocalDatabase(
      NativeDatabase.memory(
        setup: (raw) {
          for (final statement in copySchema) {
            raw.execute(statement);
          }
          // A tabela como a v2 criou (sem "sequence")
          raw.execute(
            'CREATE TABLE "outbox_entries" ("id" TEXT NOT NULL, "owner_id" TEXT NOT NULL, "kind" TEXT NOT NULL, '
            '"payload" TEXT NOT NULL, "created_at" INTEGER NOT NULL, "attempts" INTEGER NOT NULL DEFAULT 0, '
            '"rejected" INTEGER NOT NULL DEFAULT 0 CHECK ("rejected" IN (0, 1)), "last_error" TEXT NULL, PRIMARY KEY ("id"))',
          );
          raw.execute('CREATE INDEX outbox_owner_created ON outbox_entries (owner_id, created_at)');
          raw.execute(
            "INSERT INTO outbox_entries (id, owner_id, kind, payload, created_at) VALUES ('venda-v2', 'm1', 'sale', '{}', 1763200000)",
          );
          raw.execute('PRAGMA user_version = 2');
        },
      ),
    );

    final entry = await upgraded.select(upgraded.outboxEntries).getSingle();
    expect((entry.id, entry.sequence), ('venda-v2', 0));
    await upgraded.close();
  });
}
