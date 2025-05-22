import type { Transaction } from "sequelize"
import type { Sequelize } from "sequelize-typescript"

/**
 * Executes a callback within a transaction and handles commit/rollback
 *
 * @param sequelize The Sequelize instance
 * @param callback The callback function to execute within the transaction
 * @returns The result of the callback function
 */
export async function withTransaction<T>(
  sequelize: Sequelize,
  callback: (transaction: Transaction) => Promise<T>,
): Promise<T> {
  const transaction = await sequelize.transaction()

  try {
    const result = await callback(transaction)
    await transaction.commit()
    return result
  } catch (error) {
    await transaction.rollback()
    throw error
  }
}
