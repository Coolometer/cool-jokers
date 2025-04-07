--- STEAMODDED HEADER
--- MOD_NAME: Cool Jokers
--- MOD_ID: CoolJokers
--- MOD_AUTHOR: [Coolometer]
--- MOD_DESCRIPTION: Coolometer's cool jokers

SMODS.Atlas {
	-- Key for code to find it with
	key = "Lenticular",
	-- The name of the file, for the code to pull the atlas from
	path = "lenticular.png",
	-- Width of each sprite in 1x size
	px = 71,
	-- Height of each sprite in 1x size
	py = 95
}

local jokers = {
    impactjoker ={
        name = "Heavy Impact!",
        text = {
            "{C:mult}X4{} Mult",
            "if played hand ",
            "contains a single ",
            "{C:attention}stone{} card",
        },
        rarity = 3,
        cost = 7,
        bluepront_compat = true,
        eternal_compat = true,
        unlocked = true,
        discovered = true,
        atlas = nil,
        soul_pos = nil,
        
        tooltip = function(card, info_queue)
            info_queue[#info_queue+1] = G.P_CENTERS.m_stone
        end,
        calculate = function(self, context, card)
            if context.before then
                if #G.play.cards == 1 then
                    for _,otherCard in ipairs(G.play.cards) do
                        if SMODS.has_enhancement(otherCard, "m_stone") then
                            return {
                                x_mult = 4
                            }
                        end
                    end
                    
                end
            end
        end
    },
    lenticularjoker ={
        name = "Lenticular",
        text = {
            "{C:chips}+100{} Chips or {C:mult}+20{} Mult,",
            "{S:0.8}effect changes every {C:attention}hand{}{}",
            "{S:0.8}played{}",
            "{C:inactive}(Currently #1#){}",
        },
        rarity = 3,
        cost = 7,
        bluepront_compat = false,
        eternal_compat = true,
        unlocked = true,
        discovered = true,
        atlas = "Lenticular",
        pos = { x = 0, y = 0 },
        soul_pos = nil,
        config = 
        {
            extra = 
            {
                mult = 20, 
                chips = 100,
                lentstate = 0,
                text_mult = "{C:mult}+20{} Mult",
                text_chips = "{C:chip}+100{} Chips",
                curr_text = text_chips,
            }
        },

        --back = SMODS.Sprite:new("lenticular", SMODS.findModByID("CoolJokers").path, "j_" .. "lenticular" .. ".png", 71, 95, "asset_atli"):register(),


        loc_vars = function(self, info_queue, card)
            return { vars = { card.ability.extra.curr_text } }
        end,

        calculate = function(self, context, card)
            --if context.after and context.cardarea == G.play then
            if context.joker_main then
                if self.ability.extra.lentstate == 1 then
                    
                    return {
                        mult_mod = self.ability.extra.mult,
                        message = localize { type = 'variable', key = 'a_mult', vars = {"20"} },
                    }
                    
                else 
                                        
                    return{
                        chip_mod = self.ability.extra.chips,
                        message = localize { type = 'variable', key = 'a_chips', vars = {"100"} }
                    
                    }
                    
                end
            elseif context.after and context.cardarea == G.jokers then
                if self.ability.extra.lentstate == 1 then
                    self.ability.extra.lentstate = 0
                    curr_text = text_chips
                    self:flip()
                else
                    self.ability.extra.lentstate = 1
                    curr_text = text_mult
                    self:flip()
                end
                self.facing = "front"
                return{
                    message = localize { text = 'Flip!', color = G.C.CHIPS }
                
                }

            --this triggers effect when flipped by amber acorn. could be implemented into the main calculation too:
            elseif self.facing == "back" and context.first_hand_drawn then 
                if self.ability.extra.lentstate == 1 then
                    curr_text = text_chips
                    self.ability.extra.lentstate = 0
                else 
                    curr_text = text_mult
                    self.ability.extra.lentstate = 1
                end
                self.facing = "front"
                --self:flip()
                return{
                    message = localize { text = 'Flip!', color = G.C.CHIPS },
                }
            end
        end,
    },
    sniperjoker = {
        name = "Sharpshooter",
        text = {
            "Earn {C:money}$10{} if {C:attention}Blind{} is cleared",
            "within {C:attention}115%{} of required chips",
        },
        config = { extra = { mult = 0, x_mult = 0 } },
        pos = { x = 0, y = 0 },  
        rarity = 2,
        cost = 5,
        blueprint_compat = true,
        eternal_compat = true,
        unlocked = false,
        discovered = false, 
        effect = 'Money',
        atlas = nil,
        soul_pos = nil,
    
        calculate = function(self, context, card)
            if context.pre_cash then
                if G.GAME.chips/G.GAME.blind.chips <= 11.25 or true then
                    local pitch = 0.95
                    play_sound('timpani')
                    --self.juice_up()
                    card_eval_status_text(self, 'extra', nil, nil, nil, {message = '$10', colour = G.C.MONEY})
                    add_round_eval_row({dollars = 10, name='blind1', pitch = pitch, card = self})
                    ease_dollars(10)
                end
            end
        end,
    },
    strikejoker = {
        --return {
        --    message = localize('k_saved_ex'),
        --    saved = true,
        --    colour = G.C.RED
        --}
        name = "Strike!",
        text = {
            "When a 10 scores,",
            "Retrigger next hand",
            "{C:inactive}#1#",
        },
        --config = { extra = { mult = 2, x_mult = 0 } },
        pos = { x = 0, y = 0 },  
        rarity = 3,
        cost = 8,
        blueprint_compat = true,
        eternal_compat = true,
        unlocked = false,
        discovered = false, 
        effect = 'Retrigger',
        atlas = nil,
        soul_pos = nil,
        
        config = { active = 0},
        
        calculate = function(self, context, card)
            if self.config.active == nil then
                self.config.active = 0
            end
            if context.individual and context.cardarea == G.play then
                if context.other_card:get_id() == 10 then
                    self.config.active = 2
            --for index, value in ipairs(context.scoring_hand) do 
            --    if 
                end
            end
            

            local eval = function()
                return self.config.active > 0
            end

            juice_card_until(self, eval, true)
        end,

        loc_def = function(self, info_queue)
            return{
                    self.config.active,
                    --message = localize { type = 'variable', key = 'a_mult', vars = { card.config.active } },
            }
        end
    },
}

function SMODS.INIT.BBBalatro()
    --localization for the info queue key
    G.localization.descriptions.Other["your_key"] = {
        name = "Example", --tooltip name
        text = {
            "TEXT L1",   --tooltip text.		
            "TEXT L2",   --you can add as many lines as you want
            "TEXT L3"    --more than 5 lines look odd
        }
    }
    init_localization()

    --Create and register jokers
    for k, v in pairs(jokers) do --for every object in 'jokers'
        local joker = SMODS.Joker:new(v.name, k, v.config, v.pos, { name = v.name, text = v.text }, v.rarity, v.cost,
            v.unlocked, v.discovered, v.blueprint_compat, v.eternal_compat, v.effect, v.atlas, v.soul_pos)
        joker.calculate_dollar_bonus = function()
            return 10
        end
        joker:register()
        joker.calculate_dollar_bonus = function()
            return 10
        end
        if not v.atlas then --if atlas=nil then use single sprites. In this case you have to save your sprite as slug.png (for example j_examplejoker.png)
            SMODS.Sprite:new("j_" .. k, SMODS.findModByID("CoolJokers").path, "j_" .. k .. ".png", 71, 95, "asset_atli")
                :register()
        end
        --add jokers calculate function:
        SMODS.Jokers[joker.slug].calculate = v.calculate
        SMODS.Jokers[joker.slug].calculate_dollar_bonus = function()
            return 10
        end
        --add jokers loc_def:
        SMODS.Jokers[joker.slug].loc_def = v.loc_def
        --if tooltip is present, add jokers tooltip
        if (v.tooltip ~= nil) then
            SMODS.Jokers[joker.slug].tooltip = v.tooltip
        end
    end
    --Create sprite atlas
    SMODS.Sprite:new("youratlasname", SMODS.findModByID("CoolJokers").path, "example.png", 71, 95, "asset_atli")
        :register()
    
end
