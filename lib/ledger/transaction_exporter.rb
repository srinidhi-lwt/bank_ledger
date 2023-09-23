module Ledger
	class TransactionExporter
		attr_reader :ledger_type

		def initialize(ledger_type)
			@ledger_type = ledger_type
		end

		def call
			@transactions = sorted_uniq_transactions
			valid_transactions_with_order
		end

		private

		def fetch_transactions
      file_contents = File.read(file_path)
      JSON.parse(file_contents)
		end

		def sorted_uniq_transactions
			transactions = fetch_transactions.sort_by { |txn| DateTime.parse(txn["date"]) }
			transactions.uniq {|x| x['activity_id']}
		end

		def file_path
			"#{Rails.root}/lib/assets/#{ledger_type}_ledger.json"
		end

		def valid_transactions_with_order
			running_balance = 0
			valid_transactions = []
			out_of_order_transactions = []

			@transactions.each do |txn|
				running_balance += txn['amount']

				if running_balance < 0
					out_of_order_transactions << txn
					running_balance -= txn['amount']
				elsif out_of_order_transactions.present?
					ofr_txn = out_of_order_transactions.shift
					running_balance += ofr_txn['amount']
					valid_transactions << txn
					valid_transactions << ofr_txn
				else
					valid_transactions << txn
				end
			end

			valid_transactions.reverse
		end
	end
end