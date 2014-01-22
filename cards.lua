--a card collection and the card object itself
--[[ a card has

]]

local _ENV=setmetatable({},{__index=_G})

local utils=require 'utils'
card=utils.makeclass(utils.game_object)

card.ATTRS={
	name="unnamed card",
	type='card'
}

return _ENV