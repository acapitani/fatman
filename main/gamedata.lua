-- Put functions in this file to use them in several other scripts.
-- To get access to the functions, you need to put:
-- require "my_directory.my_file"
-- in any script using the functions
local M = {}

M.paused = false
M.in_game = false

M.state_home = 0
M.state_ingame = 1
M.state_gameover = 2

M.game_state = nil

function M.new()
	M.home()
	M.paused = false
end

function M.home()
	M.in_game = false
	M.game_state = M.state_home
end

function M.ingame()
	M.in_game = true
	M.game_state = M.state_ingame
end

function M.gameover()
	M.in_game = false
	M.game_state = M.state_gameover
end

return M
