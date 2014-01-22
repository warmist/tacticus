--[[		
		if_ - e.g. if you have 0 units, this spell costs 0
		when_ - like if but for instant/optional/triggers, gets called with some action if returns true triggers:
			when other player puts an creature do 1 dmg to it
		may_ - optional action, ask player: player may sacrifice his creature to gain 1 life
		target_ - accepts filter, ask player for target returns target(s) e.g.:  remove up-to 5 units from hand
			filters:
				friendly
				enemy - !friendly
				my 
				unit
				item
				--other objects?
				count-- somehow add up-to
				in_hand -- only ones you have in hand?(pocket does it exist at all?)
--]]
--[[
	rule:
		readable string
		flags: when to trigger, what targets it needs
		action
	triggers:
		action: invoked by player
		damage: on receiving dmg
]]
local NOOP_TBL={}
setmetatable(NOOP_TBL,{__index=function() return NOOP_TBL end,__call=function() return NOOP_TBL end})
function spell_sth( env )
	local _ENV=env
	desc="if you have 0 units this spell costs 0. Do 5 damage to target player"
	if #player.units==0 then
		cost=0
	else
		cost=3
	end
	getTarget('player'):damage(5,spell_sth)
end
function spell_sth2( env )
	local _ENV=env
	desc="Do X damage to target player where X is number of creatures"
	cost=5	
	local player=getTarget('player')
	local dmg=#player:getCreatures()
	player:damage(dmg,spell_sth2)
end
function spell_link(env)
	local _ENV=env
	desc="Links 3 units to share damage. Rounding is done upwards"
	cost=5
	local units=getTarget('unit',3)
	function share_dmg(env)
		local _ENV=env
		desc="Unit shares damage with other units"			
		trigger="damage"
		if org_trigger.args[2]==share_dmg then --todo see if function is not generated new each time...
			return --no endless loops
		end

		local dmg=org_trigger.args[1] -- trigger-> :damage(num,source)
		dmg=math.ceil(dmg/3)
		for _,u in ipairs(units) do
			u:damage(dmg,share_dmg)
		end
	end
	for k,v in ipairs(units) do
		units:addRule(share_dmg)
	end
end
function spell_draw(env)
	local _ENV=env
	desc="when other player uses a card you may draw a card"
	cost=1
	trigger="action.card"
	if player:ask("Do you want to draw a card") then
		player:draw_card(1)
	end
end
function printall(t,tabs)
	if tabs==nil then
		tabs=""
	else
		tabs=tabs..'\t'
	end
	for k,v in pairs(t) do
		print(tabs..k,v)
		if type(v)=='table' then
			printall(v,tabs)
		end
	end
end
function getInfo(f,player)
	local env={ipairs=ipairs,pairs=pairs,table=table}
	local info={targets={}}
	function getTarget_fake(trg_type,count)
		count=count or 1
		table.insert(info.targets,{trg_type,count})
		return NOOP_TBL
	end
	env.getTarget=getTarget_fake
	if player then
		env.player=player --replace with real player
	end

	setmetatable(env,{__index=function(tbl,key) return rawget(tbl,key) or NOOP_TBL  end}) --skip all unknown stuff
	f(env)
	setmetatable(env,nil)

	info.cost=env.cost or 0
	info.desc=env.desc or ""
	info.trigger=env.trigger or "action"
	printall(info)
end
getInfo(spell_sth)
getInfo(spell_sth2)
getInfo(spell_link)
getInfo(spell_draw)