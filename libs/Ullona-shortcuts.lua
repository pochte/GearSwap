
-------------------------------------------------------------------------------------------------------------------
-- ULLONA'S ULTIMATE SHORTCUTS
-- GearSwap / Windower
--
-- Purpose:
--   Short aliases for GearSwap modes, spells, abilities, and common typos.
--
-- Notes:
--   "input" passes the command directly to FFXI.
--   <t>      = current target
--   <stnpc>  = selectable NPC/enemy target
--   <me>     = yourself
-------------------------------------------------------------------------------------------------------------------

function setup_command_shortcuts()

    -------------------------------------------------------------------------------------------------------------------
    -- MODE SHORTCUTS
    -------------------------------------------------------------------------------------------------------------------

    send_command('alias melee gs c melee')
    send_command('alias ranged gs c ranged')
    send_command('alias caster gs c caster')
    send_command('alias pet gs c pet')
    send_command('alias idle gs c idle')
    send_command('alias dt gs c dt')
    send_command('alias engage gs c engage')
    send_command('alias nuke gs c nuke')
    send_command('alias burst gs c burst')
    send_command('alias kite gs c kite')
    send_command('alias lock gs c lock')
    send_command('alias unlock gs c unlock')


    -------------------------------------------------------------------------------------------------------------------
    -- TELEPORT SHORTCUTS + TYPO VARIATIONS
    -------------------------------------------------------------------------------------------------------------------

    send_command('alias holla input /ma "Teleport-Holla" <me>')
    send_command('alias hola input /ma "Teleport-Holla" <me>')
    send_command('alias hlla input /ma "Teleport-Holla" <me>')

    send_command('alias dem input /ma "Teleport-Dem" <me>')
    send_command('alias dme input /ma "Teleport-Dem" <me>')

    send_command('alias mea input /ma "Teleport-Mea" <me>')
    send_command('alias mae input /ma "Teleport-Mea" <me>')

    send_command('alias altep input /ma "Teleport-Altep" <me>')
    send_command('alias altap input /ma "Teleport-Altep" <me>')
    send_command('alias atlap input /ma "Teleport-Altep" <me>')
    send_command('alias altop input /ma "Teleport-Altep" <me>')

    send_command('alias yhoat input /ma "Teleport-Yhoat" <me>')
    send_command('alias yhot input /ma "Teleport-Yhoat" <me>')
    send_command('alias yoat input /ma "Teleport-Yhoat" <me>')

    send_command('alias vahzl input /ma "Teleport-Vahzl" <me>')
    send_command('alias vazhl input /ma "Teleport-Vahzl" <me>')
    send_command('alias vaz input /ma "Teleport-Vahzl" <me>')
    send_command('alias vazl input /ma "Teleport-Vahzl" <me>')
    send_command('alias valz input /ma "Teleport-Vahzl" <me>')
    send_command('alias zhalvl input /ma "Teleport-Vahzl" <me>')

    send_command('alias hell input /ma "Teleport-Yhoat" <me>')


    -------------------------------------------------------------------------------------------------------------------
    -- RECALL SHORTCUTS + TYPO VARIATIONS
    -------------------------------------------------------------------------------------------------------------------

    send_command('alias pash input /ma "Recall-Pashh" <me>')
    send_command('alias pashh input /ma "Recall-Pashh" <me>')
    send_command('alias passh input /ma "Recall-Pashh" <me>')

    send_command('alias meri input /ma "Recall-Meriph" <me>')
    send_command('alias meriph input /ma "Recall-Meriph" <me>')
    send_command('alias merp input /ma "Recall-Meriph" <me>')

    send_command('alias jugner input /ma "Recall-Jugner" <me>')
    send_command('alias junger input /ma "Recall-Jugner" <me>')
    send_command('alias jugn input /ma "Recall-Jugner" <me>')


    -------------------------------------------------------------------------------------------------------------------
    -- WARP SHORTCUTS
    -------------------------------------------------------------------------------------------------------------------

    send_command('alias warp gs c warp')
    send_command('alias return gs c warp')
    send_command('alias warp2 gs c warp2')

    send_command('alias warpring gs c warpring')
    send_command('alias wrp gs c warpring')
    send_command('alias wpr gs c warpring')
    send_command('alias werp gs c warpring')
    send_command('alias wert gs c warpring')
    send_command('alias wrpring gs c warpring')
    send_command('alias warprng gs c warpring')
    send_command('alias wraprng gs c warpring')

    send_command('alias asdf input /echo You found the easter egg!')


    -------------------------------------------------------------------------------------------------------------------
    -- BLIZZARD / ICE
    -------------------------------------------------------------------------------------------------------------------

    send_command('alias bliz input /ma "Blizzard" <t>')
    send_command('alias bliz2 input /ma "Blizzard II" <t>')
    send_command('alias bliz3 input /ma "Blizzard III" <t>')
    send_command('alias bliz4 input /ma "Blizzard IV" <t>')
    send_command('alias bliz5 input /ma "Blizzard V" <t>')

    send_command('alias blizz input /ma "Blizzard" <t>')
    send_command('alias blizz2 input /ma "Blizzard II" <t>')
    send_command('alias blizz3 input /ma "Blizzard III" <t>')
    send_command('alias blizz4 input /ma "Blizzard IV" <t>')
    send_command('alias blizz5 input /ma "Blizzard V" <t>')

    send_command('alias bilzz input /ma "Blizzard" <t>')
    send_command('alias bilzz2 input /ma "Blizzard II" <t>')
    send_command('alias bilzz3 input /ma "Blizzard III" <t>')
    send_command('alias bilzz4 input /ma "Blizzard IV" <t>')
    send_command('alias bilzz5 input /ma "Blizzard V" <t>')

    send_command('alias ice input /ma "Blizzard" <t>')
    send_command('alias ice2 input /ma "Blizzard II" <t>')
    send_command('alias ice3 input /ma "Blizzard III" <t>')
    send_command('alias ice4 input /ma "Blizzard IV" <t>')
    send_command('alias ice5 input /ma "Blizzard V" <t>')

    send_command('alias icega input /ma "Blizzaga" <t>')
    send_command('alias icega2 input /ma "Blizzaga II" <t>')
    send_command('alias icega3 input /ma "Blizzaga III" <t>')
    send_command('alias icega4 input /ma "Blizzara" <t>')
    send_command('alias icega5 input /ma "Blizzara II" <t>')

    send_command('alias blizga input /ma "Blizzaga" <t>')
    send_command('alias blizga2 input /ma "Blizzaga II" <t>')
    send_command('alias blizga3 input /ma "Blizzaga III" <t>')
    send_command('alias blizga4 input /ma "Blizzara" <t>')
    send_command('alias blizga5 input /ma "Blizzara II" <t>')


    -------------------------------------------------------------------------------------------------------------------
    -- AERO / WIND
    -------------------------------------------------------------------------------------------------------------------

    send_command('alias Airo input /ma "Aero" <t>')
    send_command('alias Airo2 input /ma "Aero II" <t>')
    send_command('alias Airo3 input /ma "Aero III" <t>')
    send_command('alias Airo4 input /ma "Aero IV" <t>')
    send_command('alias Airo5 input /ma "Aero V" <t>')

    send_command('alias Aero input /ma "Aero" <t>')
    send_command('alias Aero2 input /ma "Aero II" <t>')
    send_command('alias Aero3 input /ma "Aero III" <t>')
    send_command('alias Aero4 input /ma "Aero IV" <t>')
    send_command('alias Aero5 input /ma "Aero V" <t>')

    send_command('alias areo input /ma "Aero" <t>')
    send_command('alias areo2 input /ma "Aero II" <t>')
    send_command('alias areo3 input /ma "Aero III" <t>')
    send_command('alias areo4 input /ma "Aero IV" <t>')
    send_command('alias areo5 input /ma "Aero V" <t>')

    send_command('alias wind input /ma "Aero" <t>')
    send_command('alias wind2 input /ma "Aero II" <t>')
    send_command('alias wind3 input /ma "Aero III" <t>')
    send_command('alias wind4 input /ma "Aero IV" <t>')
    send_command('alias wind5 input /ma "Aero V" <t>')

    send_command('alias air input /ma "Aero" <t>')
    send_command('alias air2 input /ma "Aero II" <t>')
    send_command('alias air3 input /ma "Aero III" <t>')
    send_command('alias air4 input /ma "Aero IV" <t>')
    send_command('alias air5 input /ma "Aero V" <t>')


    -------------------------------------------------------------------------------------------------------------------
    -- AEROGA / AERORA
    -------------------------------------------------------------------------------------------------------------------

    send_command('alias Airoga input /ma "Aeroga" <t>')
    send_command('alias Airoga2 input /ma "Aeroga II" <t>')
    send_command('alias Airoga3 input /ma "Aeroga III" <t>')
    send_command('alias Airoga4 input /ma "Aerora" <t>')
    send_command('alias Airoga5 input /ma "Aerora II" <t>')

    send_command('alias Aeroga input /ma "Aeroga" <t>')
    send_command('alias Aeroga2 input /ma "Aeroga II" <t>')
    send_command('alias Aeroga3 input /ma "Aeroga III" <t>')
    send_command('alias Aeroga4 input /ma "Aerora" <t>')
    send_command('alias Aeroga5 input /ma "Aerora II" <t>')

    send_command('alias areoga input /ma "Aeroga" <t>')
    send_command('alias areoga2 input /ma "Aeroga II" <t>')
    send_command('alias areoga3 input /ma "Aeroga III" <t>')
    send_command('alias areoga4 input /ma "Aerora" <t>')
    send_command('alias areoga5 input /ma "Aerora II" <t>')


    -------------------------------------------------------------------------------------------------------------------
    -- FIRE
    -------------------------------------------------------------------------------------------------------------------

    send_command('alias fir input /ma "Fire" <t>')
    send_command('alias fir2 input /ma "Fire II" <t>')
    send_command('alias fir3 input /ma "Fire III" <t>')
    send_command('alias fir4 input /ma "Fire IV" <t>')
    send_command('alias fir5 input /ma "Fire V" <t>')

    send_command('alias frie input /ma "Fire" <t>')
    send_command('alias frie2 input /ma "Fire II" <t>')


    -------------------------------------------------------------------------------------------------------------------
    -- STONE
    -------------------------------------------------------------------------------------------------------------------

    send_command('alias stne input /ma "Stone" <t>')
    send_command('alias stne2 input /ma "Stone II" <t>')
    send_command('alias stne3 input /ma "Stone III" <t>')
    send_command('alias stne4 input /ma "Stone IV" <t>')
    send_command('alias stne5 input /ma "Stone V" <t>')
    send_command('alias stn input /ma "Stone" <t>')


    -------------------------------------------------------------------------------------------------------------------
    -- THUNDER
    -------------------------------------------------------------------------------------------------------------------

    send_command('alias thnd input /ma "Thunder" <t>')
    send_command('alias thnd2 input /ma "Thunder II" <t>')
    send_command('alias thnd3 input /ma "Thunder III" <t>')
    send_command('alias thnd4 input /ma "Thunder IV" <t>')
    send_command('alias thnd5 input /ma "Thunder V" <t>')

    send_command('alias thun input /ma "Thunder" <t>')
    send_command('alias thun2 input /ma "Thunder II" <t>')
    send_command('alias thun3 input /ma "Thunder III" <t>')


    -------------------------------------------------------------------------------------------------------------------
    -- WATER
    -------------------------------------------------------------------------------------------------------------------

    send_command('alias wtr input /ma "Water" <t>')
    send_command('alias wtr2 input /ma "Water II" <t>')
    send_command('alias wtr3 input /ma "Water III" <t>')
    send_command('alias wtr4 input /ma "Water IV" <t>')
    send_command('alias wtr5 input /ma "Water V" <t>')
    send_command('alias watr input /ma "Water" <t>')


    -------------------------------------------------------------------------------------------------------------------
    -- CURE
    -------------------------------------------------------------------------------------------------------------------

    send_command('alias c input /ma "Cure" <t>')
    send_command('alias c2 input /ma "Cure II" <t>')
    send_command('alias c3 input /ma "Cure III" <t>')
    send_command('alias c4 input /ma "Cure IV" <t>')
    send_command('alias c5 input /ma "Cure V" <t>')
    send_command('alias c6 input /ma "Cure VI" <t>')

    send_command('alias cur input /ma "Cure" <t>')
    send_command('alias cur2 input /ma "Cure II" <t>')
    send_command('alias cur3 input /ma "Cure III" <t>')
    send_command('alias cur4 input /ma "Cure IV" <t>')
    send_command('alias cur5 input /ma "Cure V" <t>')
    send_command('alias cur6 input /ma "Cure VI" <t>')

    send_command('alias cru input /ma "Cure" <t>')
    send_command('alias cru2 input /ma "Cure II" <t>')
    send_command('alias cru3 input /ma "Cure III" <t>')
    send_command('alias cru4 input /ma "Cure IV" <t>')


    -------------------------------------------------------------------------------------------------------------------
    -- RAISE / RERAISE
    -------------------------------------------------------------------------------------------------------------------

    send_command('alias rr input /ma "Reraise" <me>')
    send_command('alias rr2 input /ma "Reraise II" <me>')
    send_command('alias rr3 input /ma "Reraise III" <me>')
    send_command('alias rr4 input /ma "Reraise IV" <me>')

    send_command('alias reraise input /ma "Reraise" <me>')
    send_command('alias reraise2 input /ma "Reraise II" <me>')
    send_command('alias reraise3 input /ma "Reraise III" <me>')
    send_command('alias reraise4 input /ma "Reraise IV" <me>')

    send_command('alias r input /ma "Raise" <st>')
    send_command('alias r2 input /ma "Raise II" <st>')
    send_command('alias r3 input /ma "Raise III" <st>')
    send_command('alias r4 input /ma "Arise" <st>')

    send_command('alias arize input /ma "Arise" <st>')
    send_command('alias arise input /ma "Arise" <st>')
    send_command('alias arz input /ma "Arise" <st>')
    send_command('alias ars input /ma "Arise" <st>')
    send_command('alias airs input /ma "Arise" <st>')


    -------------------------------------------------------------------------------------------------------------------
    -- CURAGA
    -------------------------------------------------------------------------------------------------------------------

    send_command('alias cga input /ma "Curaga" <t>')
    send_command('alias cga2 input /ma "Curaga II" <t>')
    send_command('alias cga3 input /ma "Curaga III" <t>')
    send_command('alias cga4 input /ma "Curaga IV" <t>')
    send_command('alias cga5 input /ma "Curaga V" <t>')

    send_command('alias crga input /ma "Curaga" <t>')
    send_command('alias crga2 input /ma "Curaga II" <t>')
    send_command('alias crga3 input /ma "Curaga III" <t>')


    -------------------------------------------------------------------------------------------------------------------
    -- SLEEP
    -------------------------------------------------------------------------------------------------------------------

    send_command('alias z input /ma "Sleep" <stnpc>')
    send_command('alias z2 input /ma "Sleep II" <stnpc>')

    send_command('alias zz input /ma "Sleep" <stnpc>')
    send_command('alias zz2 input /ma "Sleep II" <stnpc>')

    send_command('alias zzz input /ma "Sleep" <stnpc>')
    send_command('alias zzz2 input /ma "Sleep II" <stnpc>')

    send_command('alias zzzz input /ma "Sleep II" <stnpc>')
    send_command('alias zzzzz input /ma "Sleep II" <stnpc>')

    send_command('alias slep input /ma "Sleep" <stnpc>')
    send_command('alias slep2 input /ma "Sleep II" <stnpc>')
    send_command('alias seelp input /ma "Sleep" <stnpc>')


    -------------------------------------------------------------------------------------------------------------------
    -- SLEEPGA
    -------------------------------------------------------------------------------------------------------------------

    send_command('alias zga input /ma "Sleepga" <t>')
    send_command('alias zga2 input /ma "Sleepga II" <t>')

    send_command('alias zzga input /ma "Sleepga" <t>')
    send_command('alias zzga2 input /ma "Sleepga II" <t>')

    send_command('alias zzzga input /ma "Sleepga" <t>')
    send_command('alias zzzga2 input /ma "Sleepga II" <t>')

    send_command('alias zzzzga input /ma "Sleepga II" <t>')

    send_command('alias slpga input /ma "Sleepga" <t>')
    send_command('alias slpga2 input /ma "Sleepga II" <t>')

    send_command('alias sleepaga input /ma "Sleepga" <t>')
    send_command('alias sleepaga2 input /ma "Sleepga II" <t>')

    send_command('alias slpaga input /ma "Sleepga" <t>')
    send_command('alias slpaga2 input /ma "Sleepga II" <t>')

    send_command('alias slepga input /ma "Sleepga" <t>')
    send_command('alias slepga2 input /ma "Sleepga II" <t>')


    -------------------------------------------------------------------------------------------------------------------
    -- BREAK
    -------------------------------------------------------------------------------------------------------------------

    send_command('alias brk input /ma "Break" <stnpc>')
    send_command('alias brak input /ma "Break" <stnpc>')

    send_command('alias brkga input /ma "Breakga" <t>')
    send_command('alias brakga input /ma "Breakga" <t>')


    -------------------------------------------------------------------------------------------------------------------
    -- BIND
    -------------------------------------------------------------------------------------------------------------------

    send_command('alias bnd input /ma "Bind" <stnpc>')
    send_command('alias bin input /ma "Bind" <stnpc>')


    -------------------------------------------------------------------------------------------------------------------
    -- GRAVITY
    -------------------------------------------------------------------------------------------------------------------

    send_command('alias grav input /ma "Gravity" <stnpc>')
    send_command('alias grav2 input /ma "Gravity II" <stnpc>')

    send_command('alias garv input /ma "Gravity" <stnpc>')
    send_command('alias garv2 input /ma "Gravity II" <stnpc>')

    send_command('alias grv input /ma "Gravity" <stnpc>')
    send_command('alias grv2 input /ma "Gravity II" <stnpc>')


    -------------------------------------------------------------------------------------------------------------------
    -- SLOW
    -------------------------------------------------------------------------------------------------------------------

    send_command('alias slow input /ma "Slow" <stnpc>')
    send_command('alias slow2 input /ma "Slow II" <stnpc>')

    send_command('alias solw input /ma "Slow" <stnpc>')
    send_command('alias solw2 input /ma "Slow II" <stnpc>')


    -------------------------------------------------------------------------------------------------------------------
    -- PARALYZE
    -------------------------------------------------------------------------------------------------------------------

    send_command('alias para input /ma "Paralyze" <stnpc>')
    send_command('alias para2 input /ma "Paralyze II" <stnpc>')

    send_command('alias pralaze input /ma "Paralyze" <stnpc>')
    send_command('alias prlz input /ma "Paralyze" <stnpc>')


    -------------------------------------------------------------------------------------------------------------------
    -- BLIND
    -------------------------------------------------------------------------------------------------------------------

    send_command('alias blind input /ma "Blind" <stnpc>')
    send_command('alias blind2 input /ma "Blind II" <stnpc>')
    send_command('alias bilnd input /ma "Blind" <stnpc>')


    -------------------------------------------------------------------------------------------------------------------
    -- DISPEL
    -------------------------------------------------------------------------------------------------------------------

    send_command('alias disp input /ma "Dispel" <stnpc>')
    send_command('alias dsippel input /ma "Dispel" <stnpc>')
    send_command('alias dsp input /ma "Dispel" <stnpc>')


    -------------------------------------------------------------------------------------------------------------------
    -- RDM / BUFFS
    -------------------------------------------------------------------------------------------------------------------

    -- Composure
    send_command('alias rdmbuff /ja "Composure" <me>')
    send_command('alias comp /ja "Composure" <me>')
    send_command('alias compo /ja "Composure" <me>')
    send_command('alias compos /ja "Composure" <me>')
    send_command('alias compsoer /ja "Composure" <me>')
    send_command('alias composer /ja "Composure" <me>')
    send_command('alias cmposuer /ja "Composure" <me>')

    -- Saboteur
    send_command('alias sabo /ja "Saboteur" <me>')
    send_command('alias sab /ja "Saboteur" <me>')
    send_command('alias saboteur /ja "Saboteur" <me>')
    send_command('alias saboer /ja "Saboteur" <me>')
    send_command('alias sabotuer /ja "Saboteur" <me>')
    send_command('alias sabter /ja "Saboteur" <me>')

    -- Spontaneity
    send_command('alias spnt /ja "Spontaneity" <me>')
    send_command('alias spont /ja "Spontaneity" <me>')
    send_command('alias spy /ja "Spontaneity" <me>')
    send_command('alias spon /ja "Spontaneity" <me>')
    send_command('alias sp /ja "Spontaneity" <me>')
    send_command('alias sponte /ja "Spontaneity" <me>')
    send_command('alias sponteity /ja "Spontaneity" <me>')
    send_command('alias spantiety /ja "Spontaneity" <me>')

    -- Stymie
    send_command('alias sty /ja "Stymie" <me>')
    send_command('alias st /ja "Stymie" <me>')
    send_command('alias stymi /ja "Stymie" <me>')
    send_command('alias stmi /ja "Stymie" <me>')
    send_command('alias stme /ja "Stymie" <me>')
    send_command('alias stmy /ja "Stymie" <me>')
    send_command('alias stymee /ja "Stymie" <me>')
    send_command('alias stym /ja "Stymie" <me>')


    -------------------------------------------------------------------------------------------------------------------
    -- BAR SPELLS
    -------------------------------------------------------------------------------------------------------------------

    send_command('alias bpara input /ma "Barparalyzra" <me>')
    send_command('alias bprala input /ma "Barparalyzra" <me>')
    send_command('alias bpar input /ma "Barparalyzra" <me>')

    send_command('alias bsilence input /ma "Barsilencera" <me>')
    send_command('alias bsil input /ma "Barsilencera" <me>')

    send_command('alias bpetri input /ma "Barpetra" <me>')
    send_command('alias bpet input /ma "Barpetra" <me>')


    -------------------------------------------------------------------------------------------------------------------
    -- SEALS
    -------------------------------------------------------------------------------------------------------------------

    send_command('alias es input /ja "Elemental Seal" <me>')
    send_command('alias eseal input /ja "Elemental Seal" <me>')

    send_command('alias ds input /ja "Divine Seal" <me>')
    send_command('alias dseal input /ja "Divine Seal" <me>')


    -------------------------------------------------------------------------------------------------------------------
    -- SNEAK / INVISIBLE
    -------------------------------------------------------------------------------------------------------------------

    send_command('alias snk input /ma "Sneak" <t>')
    send_command('alias snek input /ma "Sneak" <t>')
    send_command('alias senak input /ma "Sneak" <t>')

    send_command('alias invis input /ma "Invisible" <t>')
    send_command('alias invs input /ma "Invisible" <t>')
    send_command('alias inv input /ma "Invisible" <t>')
    send_command('alias invisi input /ma "Invisible" <t>')

end


setup_command_shortcuts()