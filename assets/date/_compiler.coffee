###*
 * Compile date patterns
###
compileDatePattern= do ->
	# REGEX
	FORMAT_SPLIT_REGEX= /(?:\b)/
	# padding
	zero= (v)-> if v < 10 then "0#{v}" else v
	_milliseconds= (date, len)->
		v= date.getMilliseconds().toString()
		l= v.length
		if l < len
			len-=l
			v= "#{if len is 1 then '0' else '00'}#{v}"
		else if l > len
			v= v.substr(0, len)
		return v
	# Replacers
	FORMAT_METHODS=
		d:		(date)-> date.getDate()			# Day of month. Example: 2
		dd:		(date)-> zero date.getDate()	# Day of month. Example: 02
		dw:		(date)-> date.getDay()+1		# Day of the week
		ddw:	(date)-> zero date.getDay()+1	# Day of the week
		D:		(date)-> i18n.days[date.getDay()]# Day of week abbreviation. Example: Mon
		DD:		(date)-> i18n.days[date.getDay()+7]# Day of week. Example: Monday
		DDD:	(date)-> i18n.days[date.getDay()+14]# Day of week. Example: Monday

		m:		(date)-> date.getMonth()+1		# Month. Example: 4
		mm:		(date)-> zero date.getMonth()+1	# Month. Example: 04
		M:		(date)-> i18n.months[date.getMonth()]	# Month abbreviation. Example: Apr
		MM:		(date)-> i18n.months[date.getMonth()+12]	# Month name. Example: April

		w:		(date)-> Core.getWeekOfMonth(date)	# Week of the month. Example: 4
		ww:		(date)-> zero Core.getWeekOfMonth(date)	# Week of the month. Example: 04
		W:		(date)-> Core.getWeekOfYear(date)	# Week of the year. Example: 4
		WW:		(date)-> zero Core.getWeekOfYear(date)	# Week of the year. Example: 04

		yy:		(date)-> date.getYear().toString().slice(-2)	# The year. Example: 20
		yyyy:	(date)-> date.getFullYear()		# The year. Example: 2020

		h:		(date)-> # Hour 12. Example: 3
			v= date.getHours()
			v-=12 if v > 12
			return v
		hh:		(date)-> # Hour 12. Example: 03
			v= date.getHours()
			v-=12 if v > 12
			return zero v
		H:		(date)-> date.getHours()		# Hour 24. Example: 3
		HH:		(date)-> zero date.getHours()	# Hour 24. Example: 03

		i:		(date)-> date.getMinutes()	# Minutes. Example: 4
		ii:		(date)-> zero date.getMinutes()	# Minutes. Example: 04

		s:		(date)-> date.getSeconds()	# Seconds. Example: 5
		ss:		(date)-> zero date.getSeconds()	# Seconds. Example: 05

		S:		(date)-> _milliseconds date, 1	# Milliseconds. Example: .2
		SS:		(date)-> _milliseconds date, 2	# Milliseconds. Example: .22
		SSS:	(date)-> _milliseconds date, 3	# Milliseconds. Example: .225

		t:		(date)-> if date.getHours() < 12 then 'a' else 'p'	# a or p
		tt:		(date)-> if date.getHours() < 12 then 'am' else 'pm'	# am or pm
		T:		(date)-> if date.getHours() < 12 then 'A' else 'P'	# A or P
		TT:		(date)-> if date.getHours() < 12 then 'AM' else 'PM'	# AM or PM

		z:		(date)-> date.getTimezoneOffset()	# time zone offset
		Z:		(date)-> # time zone
			v= date.getTimezoneOffset()
			if v is 0 then v= "UTC"
			else if v < 0 then v= "UTC#{v}"
			else v= "UTC+#{v}"
			return v
	# formater
	_formater= (date)->
		result= []
		for el in @parts
			if typeof el is 'function' then result.push el date
			else result.push el
		return result.join ''
	# Interface
	(oFormat)->
		throw new Error "Illegal arguments" unless arguments.length is 1 and typeof oFormat is 'string'
		# check for named formats
		format= if v= i18n.datePatterns[oFormat] then v else oFormat
		# Compile
		format= format.split FORMAT_SPLIT_REGEX
		parts= []
		patterns= [] # Date patterns
		cum= []
		for v in format
			if fx= FORMAT_METHODS[v]
				# add cum
				if cum.length
					parts.push cum.join ''
					cum.length= 0
				# add new format
				patterns.push v unless v in patterns
				parts.push fx
			else
				cum.push v
		# add cum
		if cum.length
			parts.push cum.join ''
			cum.length= 0
		# return
		return
			source:		oFormat
			patterns:	patterns
			parts:		parts
			format:		_formater


###*
 * Date cache
###
_dateCache= new FastLRU 20, compileDatePattern


###*
 * Convert string to Milliseconds
###

###*
 * Convert string to milliseconds
 * @example	2152152
 * @example	15415ms
 * @example	85s
 * @example	85d 20s
 * @example	85d 3h 20s
###
_strToMillisecondsRegex= /^(\d+)([dhms]|ms)$/
_strToMilliseconds= (str)->
	return null unless str
	if isNaN str
		total= (new Date(str)).getTime()
		if isNaN total
			total= 0
			for s in str.trim().toLowerCase().split /\s+/
				if r= _strToMillisecondsRegex.exec s
					vl= parseFloat r[1]
					switch r[2]
						when 'd'
							total+= vl * 24 * 3600 * 1000
						when 'h'
							total+= vl * 3600 * 1000
						when 'm'
							total+= vl * 60 * 1000
						when 's'
							total+= vl * 1000
						when 'ms'
							total+= vl
						else
							throw new Error "String contains unsupported unit: #{str}"
				else throw new Error "Fail to convert to ms: #{str}"
		return total
	else
		return parseInt str

###* Parse date ###
_parseDate= (expr)->
	# String expression
	if typeof expr is 'string'
		expr= expr.trim()
		# Now - expr
		c= expr.charAt(0)
		if c is '-'
			result= new Date Date.now() - _strToMilliseconds expr.substr 1
		else if c is '+'
			result= new Date Date.now() + _strToMilliseconds expr.substr 1
		else if expr is 'now'
			result= new Date()
		else if expr
			result= new Date expr
			if isNaN result.getTime()
				result= _strToMilliseconds expr
				result= if result? then new Date result else null
		else
			result= null
	# Number expression
	else if typeof expr is 'number'
		result= if Number.isFinite expr then new Date(expr) else null
	# Date
	else if expr instanceof Date
		result= expr
	else if expr?
		throw new Error "Unsupported argument"
	else
		result= null
	return result
###* Convert date to timestamp ###
_toTimeStamp= (date, defaultV)->
	try
		return _parseDate(date).getTime()
	catch error
		return defaultV
