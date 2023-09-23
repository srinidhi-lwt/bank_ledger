class LedgersController < ApplicationController
	def index
		ledger_type = params[:type]

		@transactions = Ledger::TransactionExporter.new(ledger_type).call
	end
end
