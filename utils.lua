--utils module, used if without dfhack...



local _ENV=setmetatable({},{__index=_G})
DEFAULT_NIL={}
local function recurse_init(class,obj,args)
	if class.super then
		recurse_init(class.super,obj,args)
	end
	if rawget(class,'init')then
		class.init(obj,args)
	end
end
local function make_object(new_class,args,obj,no_init)
	local o=obj or {}
	if new_class.super then
		new_class.super:__make(args,o,true)
	end
	if new_class.ATTRS then
		for k,v in pairs(new_class.ATTRS) do
			if args[k] then
				print("setting",k,"for",o)
				o[k]=args[k]
			else
				if v~=DEFAULT_NIL then
					o[k]=v
				end
			end
		end
	end
	setmetatable(o,{__index=rawget(new_class, '__index') or new_class})
	if not no_init then
		recurse_init(new_class,o,args)
	end
	return o
end

-- make a class, not as powerful as dfhack one though
function makeclass(parent)
	local new_class={}
	--new_class.__parent=parent
	new_class.super=parent
	new_class.__make=make_object
	local meta={}
	meta.__index=parent
	meta.__call=make_object
	setmetatable(new_class,meta)
	return new_class
end

game_object=makeclass()
game_object.ATTRS={
	game=DEFAULT_NIL,
	type='unknown',
	rules={},
	in_play=false
}
function game_object:init(args)
	print("go init",self)
	local rules=self.rules
	self.rules={}
	for k,v in pairs(rules) do
		self:add_rule(k,v)
	end
end
function game_object:get_type()
	return self.type
end
function game_object:add_rule(rule)
	self.game:register_rule(self,rule)
	table.insert(self.rules,rule)
end
function game_object:add_to_play()
	self.game:add_object(self)
	self.in_play=true
end
function game_object:remove_from_play()
	self.game:remove_object(self)
	self.in_play=false
end
return _ENV