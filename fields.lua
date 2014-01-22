-- a list of possible fields for object to be in


local _ENV=setmetatable({},{__index=_G})

local utils=require 'utils'

field=utils.makeclass(utils.game_object)
field.ATTRS={
	objects={},
	type='field'
}
function field:init(args)

	--fields automatically enter play, unless args.no_play is set
	if not args.no_play then
		self:add_to_play()
	end
end
function field:addobject(obj)
	table.insert(self.objects,obj)
end
stack=utils.makeclass(field)
stack.ATTRS={
	actions={draw_object},
	type='stack'
}
function stack:shuffle()
	local tbl=self.objects
	self.objects={}
	for k,v in ipairs(tbl) do
		self:addobject(v)
	end
end
function stack:size()
	return #self.objects
end

function stack:draw_object()
	 --actually would be more efficient to reverse the stack...
	local obj=table.remove(self.obj,1)
	self.game.event("stack.draw."..obj:get_type(),self,obj)
	return obj
end

function stack:addobject(obj,where)
	if where=='top' then
		table.insert(self.objects,1,obj)
		self.game.event("stack.put.top."..obj:get_type(),self,obj)
	elseif where=='bottom' then
		table.insert(self.objects,obj)
		self.game.event("stack.put.bottom."..obj:get_type(),self,obj)
	else
		table.insert(self.objects,math.random(#self.objects),obj)
		self.game.event("stack.put."..obj:get_type(),self,obj)
	end
end

hand=utils.makeclass(field)
hand.ATTRS={
	type='hand'
}
playfield=utils.makeclass(field)
playfield.ATTRS={
	max_size=5
}
function playfield:addobject(obj,where)
	if where>5 then
		error("invalid location")
	end
	if self.objects[where] then
		error("field place occupied")
	end
	self.objects[where]=obj
	self.game.event("field.put."..obj:get_type(),self,obj)
end
return _ENV