local mod	= DBM:NewMod(1980, "DBM-Party-Legion", 13, 945)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 16714 $"):sub(12, -3))
mod:SetCreatureID(124872)
mod:SetEncounterID(2066)
mod:SetZone()

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 245802 248831",
	"SPELL_CAST_SUCCESS 247245",
	"SPELL_AURA_APPLIED 247245",
--	"SPELL_AURA_REMOVED 247245",
--	"CHAT_MSG_RAID_BOSS_EMOTE",
	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--TODO, see if swoop/screech target can be identified
--TODO, Fix umbral flanking timer for longer pull
--TODO, mythic timers
--Void Hunter
local warnUmbralFlanking				= mod:NewTargetAnnounce(247245, 3)
local warnRavagingDarkness				= mod:NewSpellAnnounce(245802, 3)
local warnDreadScreech					= mod:NewCastAnnounce(248831, 2)

--local specWarnHuntersRush				= mod:NewSpecialWarningDefensive(247145, "Tank", nil, nil, 1, 2)
local specWarnOverloadTrap				= mod:NewSpecialWarningDodge(247206, nil, nil, nil, 2, 2)
local specWarnUmbralFlanking			= mod:NewSpecialWarningMoveAway(247245, nil, nil, nil, 1, 2)
local yellUmbralFlanking				= mod:NewYell(247245)
--local specWarnRavagingDarkness			= mod:NewSpecialWarningMove(245802, nil, nil, nil, 1, 2)
--local yellRavagingDarkness				= mod:NewYell(245802)

local timerVoidTrapCD					= mod:NewCDTimer(15.8, 246026, nil, nil, nil, 3)
local timerOverloadTrapCD				= mod:NewCDTimer(20.6, 247206, nil, nil, nil, 3)
local timerRavagingDarknessCD			= mod:NewCDTimer(8.8, 245802, nil, nil, nil, 3)
local timerUmbralFlankingCD				= mod:NewCDTimer(8.8, 247245, nil, nil, nil, 3)
local timerScreechCD					= mod:NewAITimer(8.8, 248831, nil, nil, nil, 3, nil, DBM_CORE_HEROIC_ICON)

--local countdownBreath					= mod:NewCountdown(22, 227233)

--local voiceHuntersRush					= mod:NewVoice(247145)--defensive
local voiceOverloadTrap					= mod:NewVoice(247206)--watchstep
local voiceUmbralFlanking				= mod:NewVoice(247245)--scatter
local voiceRavagingDarkness				= mod:NewVoice(245802)--runaway

function mod:OnCombatStart(delay)
	timerRavagingDarknessCD:Start(5.5-delay)
	timerVoidTrapCD:Start(8.8-delay)
	timerOverloadTrapCD:Start(12.5-delay)
	timerUmbralFlankingCD:Start(21.0-delay)
	if self:IsMythic() then
		--Stuff
		timerScreechCD:Start(1-delay)
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 245802 then
		warnRavagingDarkness:Show()
		timerRavagingDarknessCD:Start()
	elseif spellId == 248831 then
		warnDreadScreech:Show()
		timerScreechCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 247245 then
		--timerUmbralFlankingCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 247245 then
		warnUmbralFlanking:CombinedShow(0.3, args.destName)
		if args:IsPlayer() then
			specWarnUmbralFlanking:Show()
			voiceUmbralFlanking:Play("scatter")
			yellUmbralFlanking:Yell()
		end
--	elseif spellId == 247145 then
--		specWarnHuntersRush:Show()
--		voiceHuntersRush:Play("defensive")
	end
end

--[[
function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 247245 then
		
	end
end

function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg)
	if msg:find("inv_misc_monsterhorn_03") then

	end
end
--]]

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, _, _, spellId)
	if spellId == 247175 then--Void Trap
		timerVoidTrapCD:Start()
	elseif spellId == 247206 then--Overload Trap
		specWarnOverloadTrap:Show()
		voiceOverloadTrap:Play("watchstep")
		timerOverloadTrapCD:Start()
	end
end
