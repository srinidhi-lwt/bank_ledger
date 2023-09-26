module LedgersHelper
	def ledger_types
		['simple', 'duplicate', 'complicated']
	end

	def datetime_in_ist(transaction)
		datetime = transaction['date'].to_datetime.in_time_zone("Asia/Kolkata")

	  "#{datetime.strftime('%b')} #{datetime.day.ordinalize} #{datetime.strftime('%Y %I:%M %p')}"
	end

	def transaction_date_range
		return '1/10/2014 to 4/10/2014' if params['type'] == 'complicated'
		'1/10/2014 to 1/10/2014'
	end
end
