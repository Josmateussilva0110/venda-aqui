import { z } from "zod"
import { nameField } from "../fields/name"
import { clientIdField } from "../fields/offline"
import { phoneField } from "../fields/phone"

export const CustomerSchema = z.object({
  name: nameField("o nome do cliente", 2, 80),
  phone: phoneField,
})

export type CustomerDTO = z.infer<typeof CustomerSchema>

// Cadastro. Feito sem internet, o aparelho já escolhe o id (clientId): a venda fiado offline para esse
// cliente aponta para ele, e reenviar o cadastro não cria o cliente duas vezes
export const CreateCustomerSchema = CustomerSchema.extend({
  clientId: clientIdField,
})

export type CreateCustomerDTO = z.infer<typeof CreateCustomerSchema>
