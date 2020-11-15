###*
 * Router
###
<% var Core= false; %>
do->
	"use strict"
	#=include _utils.coffee
	#=include ../../fast-lru/assets/cache/_main.coffee
	#=include date/_compiler.coffee
	CoreDate=
		#=include date/_main.coffee

	# Export interface
	if module? then module.exports= CoreDate
	else if window? then window.CoreDate= CoreDate
	else
		throw new Error "Unsupported environement"
	return
