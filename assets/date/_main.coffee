# Core Date
###*
 * Return formated date
###
formatDate: (date, pattern)->
	throw new Error "Illegal arguments" unless arguments.length is 2 and typeof pattern is 'string'
	return _dateCache.upsert(pattern).format date

###* Compile date format ###
compileDatePattern: compileDatePattern

###* Get week of year ###
getWeekOfYear: (date)->
	try
		d		= new Date Date.UTC date.getFullYear(), date.getMonth(), date.getDate()
		dayNum	= d.getUTCDay() || 7
		d.setUTCDate d.getUTCDate() + 4 - dayNum
		yearStart = new Date Date.UTC d.getUTCFullYear(), 0, 1
		return Math.ceil (((d - yearStart) / 86400000) + 1) / 7
	catch err
		throw err if date instanceof Date
		date= new Date(date)
		throw new Error 'Invalid date' if isNaN date.getFullYear()
		return @getWeekOfYear date
###* Week of month ###
getWeekOfMonth: (date)->
	try
		d= new Date date.getFullYear(), date.getMonth(), 1
		Math.ceil (d.getDay() + date.getDate()) / 7
	catch err
		throw err if date instanceof Date
		date= new Date(date)
		throw new Error 'Invalid date' if isNaN date.getFullYear()
		return @getWeekOfMonth date

###* Day of year ###
getDayOfYear: (date)->
	try
		d	= new Date date.getFullYear(), 0, 0
		Math.floor (this - d) / 86400000
	catch err
		throw err if date instanceof Date
		date= new Date(date)
		throw new Error 'Invalid date' if isNaN date.getFullYear()
		return @getDayOfYear date

###* GET MIDNIGHT ###
getMidnight: (targetDate)-> new Date targetDate - ( targetDate % (1000 * 3600 * 24) )

###*
 * Date relaxed
###
dateRelaxed: (date, relativeDate, pattern)->
	try
		# Relative date
		relativeDate= Date.now() unless relativeDate?
		# Prepare
		targetTime = if typeof date is 'number' then date else date.getTime()
		relativeMidnight= relativeDate - ( relativeDate % (1000 * 3600 * 24) )
		# Calc
		# range= ~~((relativeDate - targetTime) / 1000)
		value= i18nDatePatterns.relaxed relativeDate, targetTime, relativeMidnight
		if value is false
			value= Core.formatDate datetime, pattern
		return value
	catch error
		throw error if i18n? and (idp=i18n.datePatterns) and typeof idp.relaxed is 'function'
		throw new Error "Expected i18n.datePatterns.relaxed function"

###*
 * Apply relaxed date to HTML element
 * <time datetime="2018-07-07">
###
applyDateTo: do ->
	_relaxe_stop_class= '_core-dt-stp'
	_timeTagsSelector= "time[d-pattern]:not(.#{_relaxe_stop_class})"
	_interv= null
	# Format date
	_formatdate= (htmlElements)->
		relativeDate= Date.now()
		relativeMidnight= relativeDate - ( relativeDate % (1000 * 3600 * 24) )
		i18nDatePatterns= i18n.datePatterns
		for element in htmlElements
			try
				# Get date time attribute
				continue unless datetime= element.getAttribute 'datetime'
				if isNaN(datetime)
					datetime= (new Date datetime).getTime()
					continue if isNaN(datetime)
				else
					datetime= parseInt datetime
				# Calc relaxed value
				if element.hasAttribute 'd-relaxed'
					value= i18nDatePatterns.relaxed relativeDate, datetime, relativeMidnight
					if value is false
						value= Core.formatDate datetime, element.getAttribute 'd-pattern'
						element.classList.add _relaxe_stop_class
				else
					value= Core.formatDate datetime, element.getAttribute 'd-pattern'
					element.classList.add _relaxe_stop_class
				element.innerHTML= value
			catch error
				Core.fatalError 'DATE', error
		return
	# Run interval
	_intervExec= ->
		requestAnimationFrame ->
			elements= document.querySelectorAll _timeTagsSelector
			if elements.length then _formatdate elements
			else
				clearInterval _interv
				_interv= null
			return
		return
	# Interface
	return (htmlElement)->
		try
			# List <time>
			unless htmlElement
				htmlElement= document.querySelectorAll _timeTagsSelector
			else if (htmlElement.tagName is 'TIME')
				htmlElement= if htmlElement.matches(_timeTagsSelector) then [htmlElement] else []
			else
				htmlElement= htmlElement.querySelectorAll _timeTagsSelector
				# Format each tag
				requestAnimationFrame ->
					_formatdate htmlElement
					return
				# Run interval
				_interv= setInterval _intervExec, 60000 unless _interv
		catch error
			throw error if i18n? and (idp=i18n.datePatterns) and typeof idp.relaxed is 'function'
			throw new Error "Expected i18n.datePatterns.relaxed function"
		return
