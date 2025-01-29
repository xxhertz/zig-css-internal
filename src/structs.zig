pub const hook_state = struct {
    original_ptr: usize,
    vtable: [*]align(1) usize,
    index: u32,
};

pub const c_usercmd = struct {
    _: u32, // padding for destructor, 4bytes
    command_number: c_int, //4
    tick_count: c_int, //8
    viewangles: vec3, //C
    forwardmove: f32, //18
    sidemove: f32, //1C
    upmove: f32, //20
    buttons: user_buttons, //24
    impulse: u8, //28
    weaponselect: c_int, //2C
    weaponsubtype: c_int, //30
    random_seed: c_int, //34
    mousedx: c_short, //38
    mousedy: c_short, //3A
    hasbeenpredicted: bool, //3C;
};

pub const user_buttons = packed struct(u23) {
    IN_ATTACK: bool = false,
    IN_JUMP: bool = false,
    IN_DUCK: bool = false,
    IN_FORWARD: bool = false,
    IN_BACK: bool = false,
    IN_USE: bool = false,
    IN_CANCEL: bool = false,
    IN_LEFT: bool = false,
    IN_RIGHT: bool = false,
    IN_MOVELEFT: bool = false,
    IN_MOVERIGHT: bool = false,
    IN_ATTACK2: bool = false,
    IN_RUN: bool = false,
    IN_RELOAD: bool = false,
    IN_ALT1: bool = false,
    IN_ALT2: bool = false,
    IN_SCORE: bool = false,
    IN_SPEED: bool = false,
    IN_WALK: bool = false,
    IN_ZOOM: bool = false,
    IN_WEAPON1: bool = false,
    IN_WEAPON2: bool = false,
    IN_BULLRUSH: bool = false,
};

pub const flags = packed struct(u32) {
    FL_ONGROUND: bool = false,
    FL_DUCKING: bool = false,
    FL_WATERJUMP: bool = false,
    FL_ONTRAIN: bool = false,
    FL_INRAIN: bool = false,
    FL_FROZEN: bool = false,
    FL_ATCONTROLS: bool = false,
    FL_CLIENT: bool = false,
    FL_FAKECLIENT: bool = false,
    FL_INWATER: bool = false,
    FL_FLY: bool = false,
    FL_SWIM: bool = false,
    FL_CONVEYOR: bool = false,
    FL_NPC: bool = false,
    FL_GODMODE: bool = false,
    FL_NOTARGET: bool = false,
    FL_AIMTARGET: bool = false,
    FL_PARTIALGROUND: bool = false,
    FL_STATICPROP: bool = false,
    FL_GRAPHED: bool = false,
    FL_GRENADE: bool = false,
    FL_STEPMOVEMENT: bool = false,
    FL_DONTTOUCH: bool = false,
    FL_BASEVELOCITY: bool = false,
    FL_WORLDBRUSH: bool = false,
    FL_OBJECT: bool = false,
    FL_KILLME: bool = false,
    FL_ONFIRE: bool = false,
    FL_DISSOLVING: bool = false,
    FL_TRANSRAGDOLL: bool = false,
    FL_UNBLOCKABLE_BY_PLAYER: bool = false,
    _: bool = false,
};

pub const player = extern struct {
    _1: [0x94]u8,
    m_iHealth: c_int, // health: 0x94 checked
    _2: [0x4]u8,
    m_iTeam: c_int, // team: 0x9c unchecked
    _3: [0xE2]u8,
    m_bDormant: bool, // dormant: 0x17e unchecked
    _4: [0x1CA]u8,
    m_iFlags: flags, // checked
    _5: [0x228]u8,
    m_iBoneMatrix: usize, // bonematrix: 0x578

    // m_iObserverMode: c_int,
    // m_hObserverTarget: u32,
    // m_flObserverChaseDistance: f32,
    // m_vecFreezeFrameStart: vec3,
    // m_flFreezeFrameStartTime: f32,
    // m_flFreezeFrameDistance: f32,
    // m_bWasFreezeFraming: bool,
    // m_flDeathTime: f32,
    // m_flStepSoundTime: f32,
    // m_IsFootprintOnLeft: bool,

    // m_iFOV: c_int,
    // m_iFOVStart: c_int,
    // m_flFOVTime: f32,
    // m_iDefaultFOV: c_int,
    // m_hZoomOwner: u32,
    // m_fOnTarget: bool,
    // m_szAnimExtension: [32]c_char,
    // m_afButtonLast: c_int,
    // m_afButtonPressed: c_int,
    // m_afButtonReleased: c_int,
    // m_nButtons: c_int,
    // m_pCurrentCommand: *c_usercmd,
    // m_hConstraintEntity: u32,
    // m_vecConstraintCenter: vec3,
    // m_flConstraintRadius: f32,
    // m_flConstraintWidth: f32,
    // m_flConstraintSpeedFactor: f32,

    // m_hVehicle: u32,
    // m_hOldVehicle: u32,
    // m_hUseEntity: u32,
    // m_flMaxspeed: f32,
    // m_iBonusProgress: c_int,
    // m_iBonusChallenge: c_int,
    // m_vecWaterJumpVel: vec3,
    // m_flWaterJumpTime: f32,
    // m_nImpulse: c_int,
    // m_flSwimSoundTime: f32,
    // m_vecLadderNormal: vec3,
    // m_vecOldViewAngles: vec3,
    // m_bWasFrozen: bool,
    // m_flPhysics: c_int,
    // m_nTickBase: c_int,
    // m_nFinalPredictedTick: c_int,
    // m_pCurrentVguiScreen: u32,
    // m_bFiredWeapon: bool,
};

pub const vec3 = struct {
    x: f32,
    y: f32,
    z: f32,
};
