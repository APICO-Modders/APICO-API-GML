// api_create_log()
// creates a log to the modding console
function sc_mod_api_create_log(func, msg) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  sc_mod_log(mod_name, func, msg, undefined);
}


// api_create_counter()
// create a custom counter
function sc_mod_api_create_counter(key, interval, start_val, end_val, increment) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  try {
    var counter = instance_create_layer(0, 0, "Objects", ob_counter);
    counter.interval = interval;
    counter.value = start_val;
    counter.start_i = start_val;
    counter.end_i = end_val;
    counter.increment = increment;
    global.MOD_COUNTERS[? mod_name + "_" + key] = counter;
    counter.alarm[0] = room_speed * interval;
  } catch(ex) {
    sc_mod_log(mod_name, "api_create_counter", "Error: Failed To Create Counter", ex.longMessage);  
  }
}


// api_create_effect()
// create a particle FX
function sc_mod_api_create_effect(px, py, ptype, amount, col) {
  if (global.PARTICLES[? ptype] != undefined) {
    var c = global.COLORS[? col] == undefined ? c_white : global.COLORS[? col];
    for (var a = 0; a < amount; a++) {
      part_particles_create_color(global.PBS, px, py, global.PARTICLES[? ptype], c, 1);
    }
  }
}

                               
// api_create_item()
// create an item at the position given
function sc_mod_api_create_item(item, count, ix, iy, stats) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  try {
    var def = sc_util_create_item_data(item, count, stats == undefined ? {} : stats);
    var inst = sc_util_spawn_at(def.item, def.total, def.durability, def.durability, def.stats, ix, iy);
    return inst.id;
  } catch(ex) {
    sc_mod_log(mod_name, "api_create_item", "Error: Failed To Create Item", ex.longMessage);  
    return undefined;
  }
}


// api_create_obj()
// create a specific object at the position given
function sc_mod_api_create_object_pls(oid, ix, iy) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  try {
    if (global.DICTIONARY[? oid] != undefined) {
      var def = global.DICTIONARY[? oid];
      var inst = sc_object_create(ix, iy, ob_generic, oid, false); // sc_object_create changes the class if it needs
      var inst_id = real(inst.id) + 0;
      inst.in_view = true;
      if (inst.object_index == ob_menu_object) {
        inst.man_made = true;  
        inst.menu.in_view = true;
        inst.menu.alarm[9] = room_speed * 0.1;
        inst.menu.alarm[11] = room_speed * 1;
      }
      if (contains(oid, "hive")) {
        inst.hive_activated = true;
        inst.menu.hive_activated = true;
      }
      return inst_id; // TODO why does this not work ffs
    } else {
      sc_mod_log(mod_name, "api_create_object", "Error: Object OID Not Defined (" + oid + ")", undefined);
      return undefined;
    }
  } catch(ex) {
    sc_mod_log(mod_name, "api_create_object", "Error: Failed To Create Object (" + oid + ")", ex.longMessage);  
    return undefined;
  }
}


// api_create_timer()
// create a custom timer
function sc_mod_api_create_timer(func, seconds, arg1, arg2, arg3) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  try {
    var timer = instance_create_layer(0, 0, "Objects", ob_timer);
    timer.mod_name = mod_name;
    timer.state = global.MOD_STATES[? mod_name];
    timer.func = func;
    timer.arg1 = arg1;
    timer.arg2 = arg2;
    timer.arg3 = arg3;
    timer.alarm[0] = room_speed * seconds;
  } catch(ex) {
    sc_mod_log(mod_name, "api_create_timer", "Error: Failed To Create Timer", ex.longMessage);
  }
}


// api_create_bee_stats()
// creates a set of stats for a given bee
function sc_mod_api_create_bee_stats(species, queen) {
  return sc_bee_create_drone(species, queen);
}
