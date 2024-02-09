--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Electrocutioner 6000 Discovery", 90, -2927)
if not mod then return end
mod:RegisterEnableMob(220072) -- Electrocutioner 6000
mod:SetEncounterID(2927)

--------------------------------------------------------------------------------
-- Locals
--

local knockbackCount = 1

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bossName = "Electrocutioner 6000"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{433359, "SAY", "ME_ONLY_EMPHASIZE"}, -- Magnetic Pulse
		{433398, "COUNTDOWN"}, -- Discombobulation Protocol
		{433251, "CASTBAR", "SAY", "ICON", "ME_ONLY_EMPHASIZE"}, -- Static Arc
	},nil,{
		[433398] = CL.knockback, -- Discombobulation Protocol (Knockback)
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "MagneticPulseApplied", 433359)
	self:Log("SPELL_AURA_REMOVED", "MagneticPulseRemoved", 433359)
	self:Log("SPELL_CAST_SUCCESS", "DiscombobulationProtocol", 433398)
	self:Log("SPELL_CAST_START", "StaticArcStart", 433251)
	self:Log("SPELL_CAST_SUCCESS", "StaticArc", 433251)
end

function mod:OnEngage()
	knockbackCount = 1
	self:CDBar(433251, 6.2) -- Static Arc
	self:Bar(433398, 30.5, CL.count:format(CL.knockback, knockbackCount)) -- Discombobulation Protocol
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:MagneticPulseApplied(args)
	self:TargetMessage(args.spellId, "yellow", args.destName)
	self:TargetBar(args.spellId, 12, args.destName)
	if self:Me(args.destGUID) then
		self:Say(args.spellId, nil, nil, "Magnetic Pulse")
		self:PlaySound(args.spellId, "alarm", nil, args.destName)
	end
end

function mod:MagneticPulseRemoved(args)
	self:StopBar(args.spellName, args.destName)
end

function mod:DiscombobulationProtocol(args)
	self:Message(args.spellId, "orange", CL.count:format(CL.knockback, knockbackCount))
	knockbackCount = knockbackCount + 1
	self:Bar(args.spellId, 30.7, CL.count:format(CL.knockback, knockbackCount))
	self:PlaySound(args.spellId, "info")
end

do
	local function printTarget(self, name, guid)
		self:PrimaryIcon(433251, name)
		self:TargetMessage(433251, "red", name)
		if self:Me(guid) then
			self:Say(433251, nil, nil, "Static Arc")
			self:PlaySound(433251, "warning", nil, name)
		end
	end

	function mod:StaticArcStart(args)
		self:GetUnitTarget(printTarget, 0.1, args.sourceGUID)
		self:CastBar(args.spellId, 3.5)
		self:CDBar(args.spellId, 14.5)
	end
end

function mod:StaticArc(args)
	self:PrimaryIcon(args.spellId)
end