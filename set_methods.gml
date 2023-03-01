// api_set_active()
function sc_mod_api_set_active(inst_id) {
  if (inst_id != undefined) { 
    try { 
      instance_activate_object(inst_id) 
    } catch(ex) {
      // nope
    }; 
  }
}


// api_set_devmode()
// set devmod on or off
function sc_mod_api_set_devmode(boo) {
  global.MODE_DEV = boo;
}


// api_set_player_position()
// set the player position
function sc_mod_api_set_player_position(px, py) {
  global.PLAYER.x = px;
  global.PLAYER.y = py;
  sc_player_camera(global.PLAYER);
  sc_player_move(); // update cam
  sc_player_move_update(); // update activation/deactivation
}


// api_set_spawn()
// set the player spawn position
function sc_mod_api_set_spawn(px, py) {
  global.PLAYER.spawn_x = px;
  global.PLAYER.spawn_y = py;
}


// api_set_time()
// set the current time
function sc_mod_api_set_time(time, raw) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  try {
    if (raw != undefined) {
      global.TIME = raw + 0;
    } else {
      var val = variable_global_get("TIME_" + string_upper(time));
      global.TIME = val + 0;
    }
  } catch(ex) {
    sc_mod_log(mod_name, "sc_mod_api_set_time", "Error: Invalid Time Value", ex.longMessage);
  }
}


// api_set_weather()
// set the current weather
function sc_mod_api_set_weather(start_time, end_time) {
  global.WEATHER_START = start_time;
  global.WEATHER_END = end_time;
}


// api_set_notification()
// set a notification
function sc_mod_api_set_notification(notification_type, item_id, title, msg) {
  sc_notification_set(variable_struct_get(global.NOTIFICATION_MAP, notification_type), {
    item: item_id,
    title: title,
    msg: msg
  }, notification_type);
}


// api_set_ground()
// set the ground id at the given position
function sc_mod_api_set_ground(tile_id, tx, ty) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  var tile_index = global.DICTIONARY[? tile_id][? "tile_index"];
  if (tile_index != undefined) {
    
    // get point on grid 
    var gx = pointile(tx);
    var gy = pointile(ty);
    
    // set tile map
    tilemap_set(global.WORLD_TILES, tile_index, gx, gy);
    global.FILE_STORE_TEMP.world_tilemap[gy][gx] = tile_index;
    
    // update surroundings
    sc_util_update_grounds(global.WORLD_TILES, gx, gy);
    sc_util_update_ground(global.WORLD_TILES, gx, gy, true, true);
    sc_check_reflections(tx, ty);
    
    // update map
    if (!surface_exists(global.MAP_TILES)) {
      global.MAP_TILES = surface_create(global.GAME_SIZE, global.GAME_SIZE);
      buffer_set_surface(global.BUFFER_MAP_TILES, global.MAP_TILES, 0);
    }  
    if (surface_exists(global.MAP_TILES)) {
      surface_set_target(global.MAP_TILES);
      sc_world_update_map_pixel(gx, gy);
      surface_reset_target();
    }  
    
  } else {
    sc_mod_log(mod_name, "sc_mod_api_set_ground", "Error: Invalid Tile ID", undefined);
  }
}


// api_set_floor()
// set the floor id at the given position
function sc_mod_api_set_floor(floor_id, tx, ty) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  var gx = pointile(tx);
  var gy = pointile(ty);
  var tile_index = global.DICTIONARY[? floor_id][? "tile_index"];
  if (tile_index != undefined) {
    
    // update floor + surroundings
    tilemap_set(global.WORLD_FLOORING, tile_index, gx, gy);
    sc_util_update_tile(global.WORLD_FLOORING, gx, gy, true);
    global.FILE_STORE_TEMP.floor_tilemap[gy][gx] = tile_index;
    
    // update map
    if (!surface_exists(global.MAP_TILES)) {
      global.MAP_TILES = surface_create(global.GAME_SIZE, global.GAME_SIZE);
      buffer_set_surface(global.BUFFER_MAP_TILES, global.MAP_TILES, 0);
    }  
    if (surface_exists(global.MAP_TILES)) {
      surface_set_target(global.MAP_TILES);
      sc_world_update_map_pixel(gx, gy);
      surface_reset_target();
    }  
    
  } else {
    sc_mod_log(mod_name, "sc_mod_api_set_floor", "Error: Invalid Floor ID", undefined);
  }
}


// api_set_blueprint()
// override the world gen blueprint
function sc_mod_api_set_blueprint(blueprints, blank) {
  var new_config = ds_list_create();
  
  // process blueprints
  for (var a = 0; a < array_length(blueprints); a++) {
    var item = blueprints[a];
    // add blueprint only if it's value
    if (item.width != undefined &&  item.height != undefined && item.x != undefined && item.y != undefined && 
      (item.type == "forest" || item.type == "snow" || item.type == "swamp" || item.type == "hallow" || item.type == "dream")) {
      var map = ds_map_create();
      map[? "width"] = item.width;
      map[? "height"] = item.height;
      map[? "x"] = item.x;
      map[? "y"] = item.y;
      map[? "type"] = item.type;
      map[? "dye"] = item.dye;
      ds_list_add(new_config, map);
    }
  }
  
  // if we have at least 1 blueprint, set it
  if (ds_list_size(new_config) > 0) {
    ds_map_delete(global._BLUEPRINTS, "configuration");
    global._BLUEPRINTS[? "configuration"] = new_config;
    global.BLUEPRINT_CUSTOM = true;
    
    // if specified, ignore object creation in worldgen
    if (blank == true) {
      global.BLUEPRINT_BLANK = true;  
    }
    
  }
}


// api_set_data()
// set the mods json data
function sc_mod_api_set_data(json_data) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  try {
    
    // check valid json
    var check = json_stringify(json_data);

    // setup group
    var folder = os_type == os_ps4 || os_type == os_ps5 ? "apicomods" : "mods";
    buffer_async_group_begin(folder);
    buffer_async_group_option("showdialog",0);
    buffer_async_group_option("slottitle", "modsfile" + mod_name);
    
    log("mod data:", mod_name, json_data, check);
    
    // create buffer
    if (buffer_exists(global.BUFFER_REF[? mod_name])) buffer_delete(global.BUFFER_REF[? mod_name]);
    global.BUFFER_REF[? mod_name] = buffer_create(1,buffer_grow,1);
    buffer_write(global.BUFFER_REF[? mod_name], buffer_string, check);
      
    // setup mod folder settings
    var path = mod_name + "/data.json";
    log("[co_core] Saving file to: ", folder, path);
    buffer_save_async(global.BUFFER_REF[? mod_name], path, 0, buffer_get_size(global.BUFFER_REF[? mod_name]));
    global.MODS_SAVE_FILE[? mod_name] = buffer_async_group_end();
    
    return "Success";
    
  } catch(ex) {
    sc_mod_log(mod_name, "api_set_data", "Error: Invalid JSON String", ex.longMessage);
    return undefined;
  }
  
}


// api_set_position()
// set the position of a given obj
function sc_mod_api_set_position(inst_id, ix, iy) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  sc_mod_api_set_active(inst_id);
  if (inst_id != undefined && instance_exists(inst_id)) {
    inst_id.x = ix;
    inst_id.y = iy;
    return "Success";
  } else {
    sc_mod_log(mod_name, "api_set_position", "Error: Instance Doesn't Exist", undefined);
    return undefined;
  }
}


// api_set_property()
// set a property on a given instance
function sc_mod_api_set_property(inst_id, prop_name, prop_value) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  sc_mod_api_set_active(inst_id);
  if (inst_id != undefined && instance_exists(inst_id)) {
    if (variable_instance_exists(inst_id, prop_name)) {
      try {
        variable_instance_set(inst_id, prop_name, prop_value);
        return "Success";
      } catch(ex) {
        sc_mod_log(mod_name, "api_set_property", "Error: Invalid Value For Property (" + prop_name + ")", ex.longMessage);
        return undefined;
      }
    } else {
      sc_mod_log(mod_name, "api_set_property", "Error: Instance Property Doesn't Exist (" + prop_name + ")", undefined);
      return undefined;  
    }
  } else {
    sc_mod_log(mod_name, "api_set_property", "Error: Instance Doesn't Exist", undefined);
    return undefined;  
  }
}


/// api_set_immortal()
// set a menu object as being immortal
function sc_mod_api_set_immortal(inst_id, boo) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  sc_mod_api_set_active(inst_id);
  if (inst_id != undefined && instance_exists(inst_id)) {
    if (inst_id.object_index == ob_menu_object) {
      inst_id.immortal = boo;
      return "Success";
    } else {
      sc_mod_log(mod_name, "api_set_immortal", "Error: Instance Is Not A Menu Object", undefined);
      return undefined;
    }
  } else {
    sc_mod_log(mod_name, "api_set_immortal", "Error: Instance Doesn't Exist", undefined);
    return undefined;  
  }
}


// api_set_menu_position()
// set a menu position
function sc_mod_api_set_menu_position(menu_id, mx, my) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  sc_mod_api_set_active(menu_id);
  if (menu_id != undefined && instance_exists(menu_id) && menu_id.object_index == ob_menu) {
    menu_id.x = mx;
    menu_id.y = my;
    sc_menu_move(menu_id); // run move logic to update gui/buttons
    return "Success";
  } else {
    sc_mod_log(mod_name, "api_set_immortal", "Error: Menu Instance Doesn't Exist", undefined);
    return undefined;  
  }
}


// api_set_tooltip()
// changes the tooltip for a given oid
function sc_mod_api_set_tooltip(oid, tooltip) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  if (global.DICTIONARY[? oid] != undefined) {
    global.DICTIONARY[? oid][? "tooltip"] = tooltip;  
    return "Success";
  } else {
    sc_mod_log(mod_name, "api_set_tooltip", "Error: Definition For OID Doesn't Exist", undefined);
    return undefined;  
  }
}
