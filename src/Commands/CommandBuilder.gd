
extends Object

const Command = preload('Command.gd')
const ArgumentB = preload('ArgumentBuilder.gd')


# @param  string      alias
# @param  Dictionary  params
static func build(alias, params):  # Command
	# Warn
	if params.has('type'):
		Console.Log.warn(\
			'Using deprecated argument [b]type[/b] in [b]' + alias + '[/b].', \
			'CommandBuilder: build')
	if params.has('name'):
		Console.Log.warn(\
			'Using deprecated argument [b]name[/b] in [b]' + alias + '[/b].', \
			'CommandBuilder: build')

	# Check target
	if !params.has('target') or !params.target:
		Console.Log.error(\
			'Failed to register [b]' + alias + '[/b] command. Missing [b]target[/b] parametr.', \
			'CommandBuilder: build')
		return

	# Create target if old style used
	if typeof(params.target) != TYPE_OBJECT or \
			!(params.target is Console.Callback):

		var target = params.target
		if typeof(params.target) == TYPE_ARRAY:
			target = params.target[0]

		var name = alias

		if typeof(params.target) == TYPE_ARRAY and \
				params.target.size() > 1 and \
				typeof(params.target[1]) == TYPE_STRING:
			name = params.target[1]
		elif params.has('name'):
			name = params.name

		if Console.Callback.canCreate(target, name):
			params.target = Console.Callback.new(target, name)
		else:
			params.target = null

	if params.target:
		if not params.target is Console.Callback:
			Console.Log.error(\
				'Failed to register [b]' + alias + \
					'[/b] command. Failed to create callback to target', \
				'CommandBuilder: build')
			return
	else:
		Console.Log.error(\
			'Failed to register [b]' + alias + \
				'[/b] command. Failed to create callback to target', \
			'CommandBuilder: build')
		return

	# Set arguments
	if params.target._type == Console.Callback.VARIABLE and params.has('args'):
		# Ignore all arguments except first cause variable takes only one arg
		params.args = [params.args[0]]

	if params.has('arg'):
		params.args = ArgumentB.buildAll([ params.arg ])
		params.erase('arg')
	elif params.has('args'):
		params.args = ArgumentB.buildAll(params.args)
	else:
		params.args = []

	if typeof(params.args) == TYPE_INT:
		Console.Log.error(\
			'Failed to register [b]' + alias + \
				'[/b] command. Wrong [b]arguments[/b] parametr.', \
			'CommandBuilder: build')
		return

	if !params.has('description'):
		params.description = null

	return Command.new(alias, params.target, params.args, params.description)