const structs = @import("structs.zig");
pub const get_local_player_t = *const fn () ?*structs.player;
pub var get_local_player: get_local_player_t = undefined;
