class LedgersController < ApplicationController
	def index
		ledger_type = params[:type] || 'simple'

		transaction_exporter = Ledger::TransactionExporter.new(ledger_type)
		@transactions = transaction_exporter.call
		@current_balance = transaction_exporter.running_balance
	end
end
