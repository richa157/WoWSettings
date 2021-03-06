local mod	= DBM:NewMod(1981, "DBM-Party-Legion", 13, 945)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 16714 $"):sub(12, -3))
mod:SetCreatureID(124874)
mod:SetEncounterID(2067)
mod:SetZone()

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 246324 248736",
--	"SPELL_AURA_APPLIED",
--	"SPELL_AURA_REMOVED",
	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--TODO, power gain rate consistent
--TODO, special warning to switch to tentacles once know for sure how to tell empowered apart from non empowered
--TODO, mythic timer updates and some heroic timer updates
--TODO, mythic only mechanic warnings like guards.
local warnEternalTwilight				= mod:NewCastAnnounce(248736, 4)

local specWarnHowlingDark				= mod:NewSpecialWarningInterrupt(244751, "HasInterrupt", nil, nil, 1, 2)
local specWarnEntropicForce				= mod:NewSpecialWarningSpell(246324, nil, nil, nil, 1, 2)

local timerUmbralTentaclesCD			= mod:NewCDTimer(12, 244769, nil, nil, nil, 1)
local timerHowlingDarkCD				= mod:NewCDTimer(9.7, 244751, nil, nil, nil, 4, nil, DBM_CORE_INTERRUPT_ICON)
local timerEntropicForceCD				= mod:NewCDTimer(12, 244751, nil, nil, nil, 2)
local timerEternalTwilight				= mod:NewCastTimer(10, 248736, nil, nil, nil, 2, nil, DBM_CORE_DEADLY_ICON)

local countdownEternalTwilight			= mod:NewCountdown("AltTwo10", 248736)

local voiceHowlingDark					= mod:NewVoice(244751, "HasInterrupt")--kickcast
local voiceEntropicForce				= mod:NewVoice(246324)--keepmove

function mod:OnCombatStart(delay)
	timerUmbralTentaclesCD:Start(11.8-delay)
	timerHowlingDarkCD:Start(15.5-delay)
	timerEntropicForceCD:Start(30-delay)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 246324 then
		specWarnEntropicForce:Show()
		voiceEntropicForce:Play("keepmove")
		--timerEntropicForceCD:Start()
	elseif spellId == 244751 then
		--timerHowlingDarkCD:Start()
		if self:CheckInterruptFilter(args.sourceGUID) then
			specWarnHowlingDark:Show(args.sourceName)
			voiceHowlingDark:Play("kickcast")
		end
	elseif spellId == 248736 and self:AntiSpam(3, 1) then
		warnEternalTwilight:Show()
		timerEternalTwilight:Start()
		countdownEternalTwilight:Start()
	end
end

--[[
function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 196947 then

	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 196947 then
	end
end
--]]

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, _, spellGUID)
	local spellId = tonumber(select(5, strsplit("-", spellGUID)), 10)
	if spellId == 245038 then
		--timerUmbralTentaclesCD:Start()
	end
end
