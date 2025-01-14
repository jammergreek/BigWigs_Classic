
--------------------------------------------------------------------------------
-- Module declaration
--

local mod, CL = BigWigs:NewBoss("Battleguard Sartura", 531, 1544)
if not mod then return end
mod:RegisterEnableMob(15516, 15984) -- Battleguard Sartura, Sartura's Royal Guard
mod:SetEncounterID(711)

--------------------------------------------------------------------------------
-- Locals
--

local addsLeft = 3

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		26083, -- Whirlwind
		8269, -- Frenzy
		"stages",
		"berserk",
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "Whirlwind", 26083)
	self:Log("SPELL_AURA_REMOVED", "WhirlwindOver", 26083)
	self:Log("SPELL_AURA_APPLIED", "Frenzy", 8269)

	self:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", nil, "target", "focus")

	self:Death("AddDies", 15984)
end

function mod:OnEngage()
	self:Berserk(600)
	addsLeft = 3
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:Frenzy(args)
	self:UnregisterUnitEvent("UNIT_HEALTH_FREQUENT", "target", "focus")
	self:Message(8269, "orange", CL.percent:format(25, args.spellName))
	self:PlaySound(8269, "long")
end

function mod:Whirlwind(args)
	self:Message(26083, "red")
	self:PlaySound(26083, "alert")
	self:Bar(26083, 15)
end

function mod:WhirlwindOver(args)
	self:Message(26083, "green",  CL.over:format(args.spellName))
end

function mod:UNIT_HEALTH_FREQUENT(event, unit)
	if self:MobId(self:UnitGUID(unit)) == 15516 then
		local hp = self:GetHealth(unit)
		if hp < 31 then
			self:UnregisterUnitEvent(event, "target", "focus")
			self:Message(8269, "yellow", CL.soon:format(self:SpellName(8269)), false)
		end
	end
end

function mod:AddDies()
	addsLeft = addsLeft - 1
	self:Message("stages", "green", CL.add_remaining:format(addsLeft), false)
end
