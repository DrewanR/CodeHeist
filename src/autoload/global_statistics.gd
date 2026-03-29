extends Node


## Scopes
enum SCOPE { GLOBAL, LEVEL }


## Scources of errors
enum SOURCES { PLAYER, ENEMY, ENVIRONMENT, OTHER}


## Signal emitted whenever error count is updated
signal error_count_updated(level :int, global :int)


## Signal emitted whenever player error count is updated
signal player_error_count_updated(level :int, global :int)


## The error count of the this run of the game. [br]
## WARNING: Try to avoid accessing this variable directly.
##          Instead use [increment_error()], [level_refresh()] or [get_error_count()]
var global_error_count :int = 0:
	set(value):
		global_error_count = value
		error_count_updated.emit(
			get_error_count(SCOPE.LEVEL),
			get_error_count(SCOPE.GLOBAL)
		)


## The error count of the this run of the level
## WARNING: Try to avoid accessing this variable directly.
##          Instead use [increment_error()], [level_refresh()] or [get_error_count()]
var level_error_count :int = 0:
	set(value):
		level_error_count = value
		error_count_updated.emit(
			get_error_count(SCOPE.LEVEL),
			get_error_count(SCOPE.GLOBAL)
		)


## The player error count of this run of the game
## WARNING: Try to avoid accessing this variable directly.
##          Instead use [increment_error()], [level_refresh()] or [get_player_error_count()]
var global_player_error_count :int = 0:
	set(value):
		global_player_error_count = value
		player_error_count_updated.emit(
			get_player_error_count(SCOPE.LEVEL),
			get_player_error_count(SCOPE.GLOBAL)
		)


## The player error count of this run of the level
## WARNING: Try to avoid accessing this variable directly.
##          Instead use [increment_error()], [level_refresh()] or [get_player_error_count()]
var level_player_error_count :int = 0:
	set(value):
		level_player_error_count = value
		player_error_count_updated.emit(
			get_player_error_count(SCOPE.LEVEL),
			get_player_error_count(SCOPE.GLOBAL)
		)


# ErrorCount

## Increments the error count. [br]
## The behaviour of this method varies depending on [param source]
func incrment_error(source :SOURCES, value :int = 1):
	match source:
		SOURCES.PLAYER:
			change_player_error_count(value, true)
			change_error_count(value, true)
		_:
			change_error_count(value, true)


## Returns the current error count based on scope specified in [param scope]
func get_error_count(scope :SCOPE = SCOPE.GLOBAL) -> int:
	match scope:
		SCOPE.GLOBAL:
			return global_error_count
		SCOPE.LEVEL:
			return level_error_count
		_:
			return -1


## Sets the error count, scope based on [param scope]. [br]
## If [param send_signal] is [false], the signal will be supressed. [br]
## WARNING: This method should not be used unless absolutely necessary.
##          Instead use [increment_error()] or [level_refresh()]
func set_error_count(value :int, scope :SCOPE = SCOPE.GLOBAL, send_signal :bool = true):
	match scope:
		SCOPE.GLOBAL:
			global_error_count = value
		SCOPE.LEVEL:
			level_error_count = value
	
	if send_signal: error_count_updated.emit(
		get_error_count(SCOPE.LEVEL),
		get_error_count(SCOPE.GLOBAL)
	)


## Increments the player error count. [br]
## If [param send_signal] is [false], the signal will be supressed. [br]
## WARNING: This method should not be used unless absolutely necessary. Instead use
##          [increment_error()]
func change_error_count(value :int, send_signal :bool = true):
	set_error_count(get_error_count(SCOPE.GLOBAL)+value, SCOPE.GLOBAL, false)
	set_error_count(get_error_count(SCOPE.LEVEL)+value, SCOPE.LEVEL, false)
	
	if send_signal: error_count_updated.emit(
		get_error_count(SCOPE.LEVEL),
		get_error_count(SCOPE.GLOBAL)
	)


## Returns the current player error count based on scope specified in [param scope]
func get_player_error_count(scope :SCOPE = SCOPE.GLOBAL) -> int:
	match scope:
		SCOPE.GLOBAL:
			return global_player_error_count
		SCOPE.LEVEL:
			return level_player_error_count
		_:
			return -1


## Sets the error count, scope based on [param scope]. [br]
## If [param send_signal] is [true], the signal will be supressed. [br]
## WARNING: This method should not be used unless absolutely necessary. Instead use
##          [increment_error()] or [level_refresh()]
func set_player_error_count(value :int, scope :SCOPE = SCOPE.GLOBAL, send_signal :bool = true):
	match scope:
		SCOPE.GLOBAL:
			global_player_error_count = value
		SCOPE.LEVEL:
			level_player_error_count = value
	
	if send_signal: player_error_count_updated.emit(
		get_player_error_count(SCOPE.LEVEL),
		get_player_error_count(SCOPE.GLOBAL)
	)


## Increments the player error count. [br]
## If [param send_signal] is [false], the signal will be supressed. [br]
## WARNING: This method should not be used unless absolutely necessary. Instead use
##          [increment_error()]
func change_player_error_count(value :int, send_signal :bool = true):
	set_player_error_count(get_player_error_count(SCOPE.GLOBAL)+value, SCOPE.GLOBAL, false)
	set_player_error_count(get_player_error_count(SCOPE.LEVEL)+value, SCOPE.LEVEL, false)
	
	if send_signal: player_error_count_updated.emit(
		get_player_error_count(SCOPE.LEVEL),
		get_player_error_count(SCOPE.GLOBAL)
	)
