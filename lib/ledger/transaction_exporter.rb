module Ledger
	 # TransactionExporter class handles the export and processing of ledger transactions.
	class TransactionExporter
		attr_reader :ledger_type
		attr_accessor :running_balance

		# Initializes a new TransactionExporter with the given ledger_type.
		# The type of ledger (e.g., "complicated" or "simple" or "duplicate")
		def initialize(ledger_type)
			@ledger_type = ledger_type
			@running_balance = 0
		end

		# returns valid_transactions_with_order after
		# sorting and filtering duplicates, to controller
		def call
			@transactions = sorted_uniq_transactions
			valid_transactions_with_order
		end

		private

		# Reads and parses transactions from the ledger file
		# based on type ("simple" or "duplicate" or "complicated")
		def fetch_transactions
      file_contents = File.read(file_path)
      JSON.parse(file_contents)
		end

		# Sorts transactions by date and filters out duplicates based on activity_id
		def sorted_uniq_transactions
			transactions = fetch_transactions.sort_by { |txn| DateTime.parse(txn["date"]) }
			transactions.uniq {|x| x['activity_id']}
		end

		# The file path to the ledger data file.
		def file_path
			"#{Rails.root}/lib/assets/#{ledger_type}_ledger.json"
		end

		# Validates transactions and orders them based on running balance.

		# If the running balance becomes negative after processing a transaction,
		# it means that the transaction is "out of order" since it causes a negative balance.
		# The transaction amount is subtracted from the running balance to revert it.
		# If the running balance is not negative after processing a transaction, it's considered in order.
		# If there are out-of-order transactions, one is taken from the queue and its amount is added back to the balance.
		# Both the in-order and out-of-order transactions are added to the valid_transactions array.

		def valid_transactions_with_order
			valid_transactions = []
			out_of_order_transactions = []

			@transactions.each do |txn|
				@running_balance += txn['amount']

				if @running_balance < 0
					out_of_order_transactions << txn
					@running_balance -= txn['amount']
				elsif out_of_order_transactions.present?
					ofr_txn = out_of_order_transactions.shift
					@running_balance += ofr_txn['amount']
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