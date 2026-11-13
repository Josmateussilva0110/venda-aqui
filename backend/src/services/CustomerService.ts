import { supabase } from "../config/supabase"
import { CUSTOMER_COLUMNS } from "../constants/columns"
import {
  CUSTOMER_CREATE_FAILED_ERROR,
  CUSTOMER_DELETE_FAILED_ERROR,
  CUSTOMER_DUE_DATE_FAILED_ERROR,
  CUSTOMER_DUE_DATE_INVALID_ERROR,
  CUSTOMER_FETCH_FAILED_ERROR,
  CUSTOMER_HAS_HISTORY_ERROR,
  CUSTOMER_LIST_FAILED_ERROR,
  CUSTOMER_NOT_FOUND_ERROR,
  CUSTOMER_NOT_OWING_ERROR,
  CUSTOMER_OPEN_ACCOUNT_FAILED_ERROR,
  CUSTOMER_PAYMENT_EXCEEDS_BALANCE_ERROR,
  CUSTOMER_PAYMENT_FAILED_ERROR,
  CUSTOMER_PHONE_TAKEN_ERROR,
  CUSTOMER_REMINDER_FAILED_ERROR,
  CUSTOMER_REMINDERS_FAILED_ERROR,
  CUSTOMER_STATEMENT_FAILED_ERROR,
  CUSTOMER_UPDATE_FAILED_ERROR,
} from "../errors/customers"
import { OPEN_ACCOUNT_PURCHASE_LIMIT } from "../constants/customers"
import { SALE_DB_ERRORS } from "../constants/sales"
import type { CustomerDTO } from "../schemas/customers/customer"
import type { DueDateDTO } from "../schemas/customers/dueDate"
import type { ListRemindersDTO } from "../schemas/customers/listReminders"
import type { ListCustomersDTO } from "../schemas/customers/listCustomers"
import type { PaymentDTO } from "../schemas/customers/payment"
import type { StatementDTO } from "../schemas/customers/statement"
import type {
  CreditReminder,
  CreditReminderList,
  CreditReminderListRow,
  CreditReminderRow,
  CreditSummary,
  CreditSummaryRow,
  Customer,
  CustomerList,
  CustomerResult,
  CustomerRow,
  CustomerStatement,
  DueDateSaved,
  OpenAccount,
  OpenAccountRow,
  PaymentSaved,
  StatementEntry,
  StatementEntryRow,
  StatementRow,
} from "../types/customers"
import type { PaymentMethod } from "../types/sales"
import { escapeLikePattern, isForeignKeyViolation, isUniqueViolation } from "../utils/database"

class CustomerService {

  async list(merchantId: string, filters: ListCustomersDTO): CustomerResult<CustomerList> {
    try {
      let query = supabase
        .from("customers")
        .select(CUSTOMER_COLUMNS, { count: "exact" })
        .eq("merchant_id", merchantId)

      if (filters.search) {
        const phoneDigits = this.phoneDigitsOf(filters.search)
        query = phoneDigits
          ? query.ilike("phone", `%${phoneDigits}%`)
          : query.ilike("name", `%${escapeLikePattern(filters.search)}%`)
      }
      if (filters.balance === "owing") {
        query = query.gt("balance_cents", 0)
      }

      // O id desempata nomes iguais, senão um cliente pode repetir ou sumir entre as páginas
      const [page, summary] = await Promise.all([
        query
          .order("name", { ascending: true })
          .order("id", { ascending: true })
          .range(filters.offset, filters.offset + filters.limit - 1)
          .returns<CustomerRow[]>(),
        // O resumo não muda entre as páginas: só a primeira paga essa consulta
        filters.offset === 0
          ? supabase.rpc("customer_credit_summary", { p_merchant_id: merchantId }).single<CreditSummaryRow>()
          : null,
      ])

      const { data, count, error } = page
      if (error || summary?.error || (summary && !summary.data)) {
        console.error("[CustomerService.list]", error ?? summary?.error)
        return { status: false, error: CUSTOMER_LIST_FAILED_ERROR }
      }

      return {
        status: true,
        data: {
          items: data.map((row) => this.toCustomer(row)),
          total: count ?? 0,
          limit: filters.limit,
          offset: filters.offset,
          ...(summary?.data ? { summary: this.toCreditSummary(summary.data) } : {}),
        },
      }
    } catch (error) {
      console.error("[CustomerService.list] error:", error)
      return { status: false, error: CUSTOMER_LIST_FAILED_ERROR }
    }
  }

  async get(merchantId: string, customerId: string): CustomerResult<Customer> {
    try {
      const { data, error } = await supabase
        .from("customers")
        .select(CUSTOMER_COLUMNS)
        .eq("id", customerId)
        .eq("merchant_id", merchantId)
        .maybeSingle<CustomerRow>()

      if (error) {
        console.error("[CustomerService.get]", error)
        return { status: false, error: CUSTOMER_FETCH_FAILED_ERROR }
      }
      if (!data) return { status: false, error: CUSTOMER_NOT_FOUND_ERROR }

      return { status: true, data: this.toCustomer(data) }
    } catch (error) {
      console.error("[CustomerService.get] error:", error)
      return { status: false, error: CUSTOMER_FETCH_FAILED_ERROR }
    }
  }

  async create(merchantId: string, input: CustomerDTO): CustomerResult<{ id: string }> {
    try {
      const { data, error } = await supabase
        .from("customers")
        .insert({ merchant_id: merchantId, ...this.toRow(input) })
        .select("id")
        .single<{ id: string }>()

      if (isUniqueViolation(error)) return { status: false, error: CUSTOMER_PHONE_TAKEN_ERROR }
      if (error || !data) {
        console.error("[CustomerService.create]", error)
        return { status: false, error: CUSTOMER_CREATE_FAILED_ERROR }
      }

      return { status: true, data: { id: data.id } }
    } catch (error) {
      console.error("[CustomerService.create] error:", error)
      return { status: false, error: CUSTOMER_CREATE_FAILED_ERROR }
    }
  }

  async update(merchantId: string, customerId: string, input: CustomerDTO): CustomerResult<{ id: string }> {
    try {
      const { data, error } = await supabase
        .from("customers")
        .update(this.toRow(input))
        .eq("id", customerId)
        .eq("merchant_id", merchantId)
        .select("id")
        .maybeSingle<{ id: string }>()

      if (isUniqueViolation(error)) return { status: false, error: CUSTOMER_PHONE_TAKEN_ERROR }
      if (error) {
        console.error("[CustomerService.update]", error)
        return { status: false, error: CUSTOMER_UPDATE_FAILED_ERROR }
      }
      if (!data) return { status: false, error: CUSTOMER_NOT_FOUND_ERROR }

      return { status: true, data: { id: data.id } }
    } catch (error) {
      console.error("[CustomerService.update] error:", error)
      return { status: false, error: CUSTOMER_UPDATE_FAILED_ERROR }
    }
  }

  async delete(merchantId: string, customerId: string): CustomerResult<{ id: string }> {
    try {
      // O filtro pelo comerciante garante que um id de outro comércio não apaga nada (vira 404)
      const { data, error } = await supabase
        .from("customers")
        .delete()
        .eq("id", customerId)
        .eq("merchant_id", merchantId)
        .select("id")
        .maybeSingle<{ id: string }>()

      // A chave estrangeira com restrict barra cliente com venda fiado ou pagamento registrado
      if (isForeignKeyViolation(error)) return { status: false, error: CUSTOMER_HAS_HISTORY_ERROR }
      if (error) {
        console.error("[CustomerService.delete]", error)
        return { status: false, error: CUSTOMER_DELETE_FAILED_ERROR }
      }
      if (!data) return { status: false, error: CUSTOMER_NOT_FOUND_ERROR }

      return { status: true, data: { id: data.id } }
    } catch (error) {
      console.error("[CustomerService.delete] error:", error)
      return { status: false, error: CUSTOMER_DELETE_FAILED_ERROR }
    }
  }

  async registerPayment(merchantId: string, customerId: string, input: PaymentDTO): CustomerResult<PaymentSaved> {
    try {
      const { data, error } = await supabase
        .rpc("register_customer_payment", {
          p_merchant_id: merchantId,
          p_customer_id: customerId,
          p_amount_cents: input.amountCents,
          p_payment_method: input.paymentMethod,
        })
        .single<{ id: string; balance_cents: number }>()

      if (error?.code === SALE_DB_ERRORS.customerNotFound) return { status: false, error: CUSTOMER_NOT_FOUND_ERROR }
      if (error?.code === SALE_DB_ERRORS.negativeBalance) return { status: false, error: CUSTOMER_PAYMENT_EXCEEDS_BALANCE_ERROR }
      if (error || !data) {
        console.error("[CustomerService.registerPayment]", error)
        return { status: false, error: CUSTOMER_PAYMENT_FAILED_ERROR }
      }

      return { status: true, data: { id: data.id, balanceCents: data.balance_cents } }
    } catch (error) {
      console.error("[CustomerService.registerPayment] error:", error)
      return { status: false, error: CUSTOMER_PAYMENT_FAILED_ERROR }
    }
  }

  async statement(merchantId: string, customerId: string, filters: StatementDTO): CustomerResult<CustomerStatement> {
    try {
      // Extrato de cliente inexistente viria vazio; o 404 avisa o app que o cliente sumiu
      const [exists, page] = await Promise.all([
        this.belongsToMerchant(merchantId, customerId),
        supabase
          .rpc("customer_statement", {
            p_merchant_id: merchantId,
            p_customer_id: customerId,
            p_limit: filters.limit,
            p_offset: filters.offset,
          })
          .single<StatementRow>(),
      ])

      if (!exists) return { status: false, error: CUSTOMER_NOT_FOUND_ERROR }
      if (page.error || !page.data) {
        console.error("[CustomerService.statement]", page.error)
        return { status: false, error: CUSTOMER_STATEMENT_FAILED_ERROR }
      }

      return {
        status: true,
        data: {
          items: page.data.items.map((row) => this.toStatementEntry(row)),
          total: page.data.total,
          limit: filters.limit,
          offset: filters.offset,
        },
      }
    } catch (error) {
      console.error("[CustomerService.statement] error:", error)
      return { status: false, error: CUSTOMER_STATEMENT_FAILED_ERROR }
    }
  }

  async setDueDate(merchantId: string, customerId: string, input: DueDateDTO): CustomerResult<DueDateSaved> {
    try {
      const { data, error } = await supabase.rpc("set_customer_due_date", {
        p_merchant_id: merchantId,
        p_customer_id: customerId,
        p_due_date: input.dueDate,
      })

      if (error?.code === SALE_DB_ERRORS.customerNotFound) return { status: false, error: CUSTOMER_NOT_FOUND_ERROR }
      if (error?.code === SALE_DB_ERRORS.customerNotOwing) return { status: false, error: CUSTOMER_NOT_OWING_ERROR }
      if (error?.code === SALE_DB_ERRORS.invalidDueDate) return { status: false, error: CUSTOMER_DUE_DATE_INVALID_ERROR }
      if (error || typeof data !== "string") {
        console.error("[CustomerService.setDueDate]", error)
        return { status: false, error: CUSTOMER_DUE_DATE_FAILED_ERROR }
      }

      return { status: true, data: { id: customerId, creditDueDate: data } }
    } catch (error) {
      console.error("[CustomerService.setDueDate] error:", error)
      return { status: false, error: CUSTOMER_DUE_DATE_FAILED_ERROR }
    }
  }

  async listReminders(merchantId: string, filters: ListRemindersDTO): CustomerResult<CreditReminderList> {
    try {
      const { data, error } = await supabase
        .rpc("list_credit_reminders", { p_merchant_id: merchantId, p_limit: filters.limit, p_offset: filters.offset })
        .single<CreditReminderListRow>()

      if (error || !data) {
        console.error("[CustomerService.listReminders]", error)
        return { status: false, error: CUSTOMER_REMINDERS_FAILED_ERROR }
      }

      return {
        status: true,
        data: {
          items: data.items.map((row) => this.toCreditReminder(row)),
          total: data.total,
          limit: filters.limit,
          offset: filters.offset,
        },
      }
    } catch (error) {
      console.error("[CustomerService.listReminders] error:", error)
      return { status: false, error: CUSTOMER_REMINDERS_FAILED_ERROR }
    }
  }

  // O app chama depois de abrir o WhatsApp; o lembrete sai da lista até a próxima data de lembrete
  async markReminded(merchantId: string, customerId: string): CustomerResult<{ id: string }> {
    try {
      const { data, error } = await supabase.rpc("mark_customer_reminded", { p_merchant_id: merchantId, p_customer_id: customerId })

      if (error) {
        console.error("[CustomerService.markReminded]", error)
        return { status: false, error: CUSTOMER_REMINDER_FAILED_ERROR }
      }
      // Nulo: o cliente não existe ou já quitou; para o app, nos dois casos não há o que lembrar
      if (typeof data !== "string") return { status: false, error: CUSTOMER_NOT_OWING_ERROR }

      return { status: true, data: { id: data } }
    } catch (error) {
      console.error("[CustomerService.markReminded] error:", error)
      return { status: false, error: CUSTOMER_REMINDER_FAILED_ERROR }
    }
  }

  async openAccount(merchantId: string, customerId: string): CustomerResult<OpenAccount> {
    try {
      const { data, error } = await supabase.rpc("customer_open_account", {
        p_merchant_id: merchantId,
        p_customer_id: customerId,
        p_limit: OPEN_ACCOUNT_PURCHASE_LIMIT,
      })

      if (error) {
        console.error("[CustomerService.openAccount]", error)
        return { status: false, error: CUSTOMER_OPEN_ACCOUNT_FAILED_ERROR }
      }
      // Nulo: o cliente não existe ou é de outro comerciante
      if (!data) return { status: false, error: CUSTOMER_NOT_FOUND_ERROR }

      return { status: true, data: this.toOpenAccount(data as OpenAccountRow) }
    } catch (error) {
      console.error("[CustomerService.openAccount] error:", error)
      return { status: false, error: CUSTOMER_OPEN_ACCOUNT_FAILED_ERROR }
    }
  }

  private async belongsToMerchant(merchantId: string, customerId: string): Promise<boolean> {
    const { count, error } = await supabase
      .from("customers")
      .select("id", { count: "exact", head: true })
      .eq("id", customerId)
      .eq("merchant_id", merchantId)
    if (error) throw error
    return (count ?? 0) > 0
  }

  // Busca só com dígitos e pontuação de telefone ("(86) 9999-") procura no telefone; o resto, no nome.
  // Decidir aqui evita montar um filtro .or() com texto do cliente, que o PostgREST interpretaria
  private phoneDigitsOf(search: string): string | null {
    if (!/^[\d\s()+-]+$/.test(search)) return null
    const digits = search.replace(/\D/g, "")
    return digits.length > 0 ? digits : null
  }

  private toRow(input: CustomerDTO) {
    return {
      name: input.name,
      phone: input.phone,
    }
  }

  private toCustomer(row: CustomerRow): Customer {
    return {
      id: row.id,
      name: row.name,
      phone: row.phone,
      balanceCents: row.balance_cents,
      creditDueDate: row.credit_due_date,
      createdAt: row.created_at,
      updatedAt: row.updated_at,
    }
  }

  // bigint chega como texto ou número conforme o tamanho; o saldo somado cabe com folga num number
  private toCreditSummary(row: CreditSummaryRow): CreditSummary {
    return {
      owingCount: row.owing_count,
      owedCents: Number(row.owed_cents),
      reminders: row.reminders_enabled
        ? { dueCount: row.reminders_due, nextOn: row.next_reminder_on, hour: row.reminder_hour }
        : null,
    }
  }

  private toOpenAccount(row: OpenAccountRow): OpenAccount {
    return {
      balanceCents: row.balance_cents,
      creditDueDate: row.credit_due_date,
      paidCents: Number(row.paid_cents),
      purchases: row.purchases.map((purchase) => ({
        id: purchase.id,
        createdAt: purchase.created_at,
        totalCents: purchase.total_cents,
        items: purchase.items.map((item) => ({
          name: item.name,
          quantity: Number(item.quantity),
          soldByWeight: item.sold_by_weight,
          subtotalCents: item.subtotal_cents,
        })),
      })),
      earlierCount: Number(row.earlier_count),
      earlierCents: Number(row.earlier_cents),
    }
  }

  private toCreditReminder(row: CreditReminderRow): CreditReminder {
    return {
      id: row.id,
      name: row.name,
      phone: row.phone,
      balanceCents: row.balance_cents,
      creditDueDate: row.credit_due_date,
      kind: row.reminder_kind,
    }
  }

  private toStatementEntry(row: StatementEntryRow): StatementEntry {
    return {
      kind: row.kind,
      id: row.id,
      amountCents: row.amount_cents,
      paymentMethod: row.payment_method as PaymentMethod,
      createdAt: row.created_at,
    }
  }
}

export default new CustomerService()
