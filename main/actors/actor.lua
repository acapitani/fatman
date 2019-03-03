-- Put functions in this file to use them in several other scripts.
-- To get access to the functions, you need to put:
-- require "my_directory.my_file"
-- in any script using the functions.
local M = {}

M.state_idle = 0
M.state_walk = 1
M.state_approach = 2
M.state_out = 3
M.state_hit = 4
M.state_bound = 5
M.state_dance = 6

M.walk_speed = 48
M.direction_right = true
M.direction_left = false

M.xmin = 32
M.ymin = 38 
M.xmax = 300
M.ymax = 82

function M.init(self, name)
	self.name = name
	self.direction = M.direction_left
	self.current_animation = nil
	self.speed = vmath.vector3(0, 0, 0)
	self.target = vmath.vector3(0, 0, 0)
	self.timer = 0
	M.set_state(self, M.state_idle)
end

function M.timer_reset(self)
	self.timer = 0
end

function M.timer_update(self, dt)
	self.timer = self.timer + dt
end

function M.timer_elapsed(self, timeout)
	if self.timer>=timeout then
		return true
	end
	return false
end

function M.calc_z(self, pos)
	local d = 1/44 -- 82-38
	local y = 82-(pos.y-38)
	local z = 0.2 + (y*d*0.1)
	return z
end

function M.calc_z_offset(self, pos, offset)
	local d = 1/44 -- 82-38
	local y = 82-(pos.y+offset-38)
	local z = 0.2 + (y*d*0.1)
	return z
end

function M.distance_to(self, my_pos, other_pos)
	return vmath.length(my_pos - other_pos)
end

function M.approach(self)
	local tx = math.random(-32, 32)
	local ty = math.random(-16, 16)
	self.target = vmath.vector3(heropos.x+tx, heropos.y+ty, heropos.z)
	if self.target.x<M.xmin then
		self.target.x = M.xmin
	elseif self.target.x>M.xmax then
		self.target.x = M.xmax
	end
	if self.target.y<M.ymin then
		self.target.y = M.ymin
	elseif self.target.y > M.ymax then
		self.target.y = M.ymax
	end
	M.set_state(self, M.state_approach)
end

function M.approach_far(self)
	local tx = math.random(-64, 64)
	local ty = math.random(-32, 32)
	self.target = vmath.vector3(heropos.x+tx, heropos.y+ty, heropos.z)
	if self.target.x<M.xmin then
		self.target.x = M.xmin
	elseif self.target.x>M.xmax then
		self.target.x = M.xmax
	end
	if self.target.y<M.ymin then
		self.target.y = M.ymin
	elseif self.target.y > M.ymax then
		self.target.y = M.ymax
	end
	M.set_state(self, M.state_approach)
end

function M.approach_to_target(self, pos, dt)
	if math.abs(pos.x-self.target.x)>2 then
		if pos.x<self.target.x then
			M.set_direction(self, M.direction_right)
			pos.x = pos.x + dt*self.speed.x
		elseif pos.x>self.target.x then
			M.set_direction(self, M.direction_left)
			pos.x = pos.x - dt*self.speed.x
		end
	end
	if math.abs(pos.y-self.target.y)>2 then
		if pos.y<self.target.y then
			pos.y = pos.y + dt*self.speed.y
		elseif pos.y>self.target.y then
			pos.y = pos.y - dt*self.speed.y
		end
	end
	return vmath.vector3(pos.x, pos.y, pos.z)
end

function M.idle(self, pos)
	M.timer_reset(self)
	if pos.x<heropos.x then
		M.set_direction(self, M.direction_right)
	elseif pos.x>heropos.x then
		M.set_direction(self, M.direction_left)
	end
	M.set_state(self, M.state_idle)
end

function M.set_state(self, state)
	if state~=self.state then
		if state==M.state_idle then
			self.speed = vmath.vector3(0, 0, 0)
			M.play_animation(self, "idle")
		elseif state==M.state_walk or state==M.state_approach then
			self.speed = vmath.vector3(M.walk_speed, M.walk_speed, 0)
			M.play_animation(self, "walk")
		elseif state==M.state_out then
			self.speed = vmath.vector3(0, 0, 0)
			M.play_animation(self, "out")
		elseif state==M.state_bound then
			M.play_animation(self, "bound")
		end
		self.state = state
	end
end

function M.set_direction(self, direction)
	sprite.set_hflip("#sprite", direction)
	self.direction = direction
end

function M.play_animation(self, animation)
	local animation_id = hash(self.name .. "_" .. animation)
	if self.current_animation~=animation_id then
		msg.post("#sprite", "play_animation", {id = animation_id})
		self.current_animation = animation_id
	end
end

function M.update(self, dt)
	M.timer_update(self, dt)
end

return M
