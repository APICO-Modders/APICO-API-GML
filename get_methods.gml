// api_get_player_position()
// get the player position
function sc_mod_api_get_player_position() {
  return {
    x: global.PLAYER.x,
    y: global.PLAYER.y
  }
}


// api_get_player_instance()
// get player instance
function sc_mod_api_get_player_instance() {
  return global.PLAYER.id;  
}


// api_get_player_tile_position()
// get the player tile position
function sc_mod_api_get_player_tile_position() {
  return {
    x: floor((global.PLAYER.x) / 16) * 16,
    y: floor((global.PLAYER.y + 16) / 16) * 16
  }
}


// api_get_mouse_position()
// get the mouse position
function sc_mod_api_get_mouse_position() {
  return {
    x: global.MOUSE.x,
    y: global.MOUSE.y
  }
}


// api_get_mouse_tile_position()
// get the mouse tile position
function sc_mod_api_get_mouse_tile_position() {
  return {
    x: global.MOUSE.tx,
    y: global.MOUSE.ty
  }
}


// api_get_camera_position()
// get the current camera position / view offset
function sc_mod_api_get_camera_position() {
  return {
    x: global.CAMERA.x,
    y: global.CAMERA.y
  }
}


// api_get_highlighted()
// gets the highlighted instance for the given type, if any
function sc_mod_api_get_highlighted(instance_type) {
  if (instance_type == "item") return global.HIGHLIGHTED_ITEM == "" ? undefined : global.HIGHLIGHTED_ITEM;
  if (instance_type == "obj") return global.HIGHLIGHTED_OBJ == "" ? undefined : global.HIGHLIGHTED_OBJ;
  if (instance_type == "menu_obj") return global.HIGHLIGHTED_OBJ == "" ? undefined : (global.HIGHLIGHTED_OBJ.object_index == ob_menu_object ? global.HIGHLIGHTED_OBJ : undefined);
  if (instance_type == "menu") return global.HIGHLIGHTED_MENU == "" ? undefined : global.HIGHLIGHTED_MENU;
  if (instance_type == "slot") return global.HIGHLIGHTED_SLOT == "" ? undefined : global.HIGHLIGHTED_SLOT;
  if (instance_type == "ui") return global.HIGHLIGHTED_UI == "" ? undefined : global.HIGHLIGHTED_UI;
  if (instance_type == "wall") return global.HIGHLIGHTED_WALL == "" ? undefined : global.HIGHLIGHTED_WALL;
  if (instance_type == "carpet") return global.HIGHLIGHTED_CARPET == "" ? undefined : global.HIGHLIGHTED_CARPET;
  if (instance_type == "ground") return global.HIGHLIGHTED_GROUND == "" ? undefined : global.HIGHLIGHTED_GROUND;
  return undefined;
}


// api_get_counter()
// get the value of a counter
function sc_mod_api_get_counter(key) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  var counter = global.MOD_COUNTERS[? mod_name + "_" + key];
  if (counter != undefined) {
    return counter.value;
  } else {
    sc_mod_log(mod_name, "api_create_counter", "Error: Counter Does Not Exists (" + key + ")", undefined);  
    return undefined;  
  }
}


// api_get_time()
// get the current time values
function sc_mod_api_get_time() {
  return {
    time: global.TIME,
    day: global.DAY,
    name: global.TIME_NAME,
    clock: global.TIME_CLOCK
  }
}


// api_get_weather()
// get the current weather values
function sc_mod_api_get_weather() {
  return {
    active: global.WEATHER,
    start_time: global.WEATHER_START,
    end_time: global.WEATHER_END
  }
}


// api_get_equipped()
// get the item either in the mouse or in the highlighted hotbar
function sc_mod_api_get_equipped() {
  if (global.MOUSE.item != "") return global.MOUSE.item;
  return global.PLAYER.slots[| global.PLAYER.hotbar].item;
}


// api_get_ground()
// gets the ground oid at the given position
function sc_mod_api_get_ground(tx, ty) {
  return sc_util_get_ground_oid(tilemap_get_at_pixel(global.WORLD_TILES, tx, ty));
}


// api_get_floor()
// gets the floor oid at the given position
function sc_mod_api_get_floor(tx, ty) {
  return sc_util_get_tile_oid(tilemap_get_at_pixel(global.WORLD_FLOORING, tx, ty));
}


// api_get_definition()
// gets the definition for a given oid
function sc_mod_api_get_definition(oid) {
  var def = global.DICTIONARY[? oid];
  if (def == undefined) return undefined;
  return json_parse(json_encode(def));
}


// api_get_key_down()
// gets if a key is currently down
function sc_mod_api_get_key_down(key_label) {
  if (key_label == "LEFT") return keyboard_check(vk_left);
  if (key_label == "RIGHT") return keyboard_check(vk_right);
  if (key_label == "UP") return keyboard_check(vk_up);
  if (key_label == "DOWN") return keyboard_check(vk_down);
  if (key_label == "ENTER") return keyboard_check(vk_enter);
  if (key_label == "ESC") return keyboard_check(vk_escape);
  if (key_label == "SPACE") return keyboard_check(vk_space);
  if (key_label == "SHFT") return keyboard_check(vk_shift);
  if (key_label == "CTRL") return keyboard_check(vk_control);
  if (key_label == "ALT") return keyboard_check(vk_alt);
  if (key_label == "TAB") return keyboard_check(vk_tab);
  return keyboard_check(ord(key_label));
}


// api_get_key_pressed()
// gets if a key has been pressed
function sc_mod_api_get_key_pressed(key_label) {
  if (key_label == "LEFT") return keyboard_check_pressed(vk_left);
  if (key_label == "RIGHT") return keyboard_check_pressed(vk_right);
  if (key_label == "UP") return keyboard_check_pressed(vk_up);
  if (key_label == "DOWN") return keyboard_check_pressed(vk_down);
  if (key_label == "ENTER") return keyboard_check_pressed(vk_enter);
  if (key_label == "ESC") return keyboard_check_pressed(vk_escape);
  if (key_label == "SPACE") return keyboard_check_pressed(vk_space);
  if (key_label == "SHFT") return keyboard_check_pressed(vk_shift);
  if (key_label == "CTRL") return keyboard_check_pressed(vk_control);
  if (key_label == "ALT") return keyboard_check_pressed(vk_alt);
  if (key_label == "TAB") return keyboard_check_pressed(vk_tab);
  return keyboard_check_pressed(ord(key_label));
}


// api_get_sprite()
// get the sprite ref ID for a given oid
function sc_mod_api_get_sprite(oid) {
  return global.SPRITE_REFERENCE[? oid];
}


// api_get_data()
// get the mods data file
function sc_mod_api_get_data() {
  
  // get mod
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  
  // setup buffer for this load
  if (buffer_exists(global.BUFFER_REF[? mod_name])) buffer_delete(global.BUFFER_REF[? mod_name]);
  global.BUFFER_REF[? mod_name] = buffer_create(1, buffer_grow, 1);
  
  // run load
  global.MODS_LOAD_FILE[? mod_name] = buffer_load_async(global.BUFFER_REF[? mod_name], "mods/" + mod_name + "/data.json", 0, -1);
  
}


// api_get_property() or api_gp()
// get a property from an instance
function sc_mod_api_get_property(inst_id, prop_name) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  if (inst_id != undefined && instance_exists(inst_id)) {
    if (variable_instance_exists(inst_id, prop_name)) {
      return variable_instance_get(inst_id, prop_name);
    } else {
      sc_mod_log(mod_name, "api_get_property", "Error: Instance Property Doesn't Exist", undefined);
      return undefined;  
    }
  } else {
    sc_mod_log(mod_name, "api_get_property", "Error: Instance Doesn't Exist", undefined);
    return undefined;
  }
}


// api_get_inst()
// get the main properties for a given inst
function sc_mod_api_get_inst(inst_id) {
  if (inst_id != undefined && instance_exists(inst_id)) {
    return {
      id: inst_id.id,
      sprite_index: inst_id.sprite_index,
      image_index: inst_id.image_index,
      menu_id: inst_id.object_index == ob_menu_object ? inst_id.menu : undefined,
      oid: variable_instance_exists(inst_id, "oid") ? inst_id.oid : undefined,
      x: inst_id.x,
      y: inst_id.y,
      slots: undefined
    }
  } else {
    return undefined;
  }  
}

// api_get_objects()
// get all nearby generic obj instances
function sc_mod_api_get_objects(radius) {
  var data = [];
  if (radius != undefined) {
    var nearby = ds_list_create();
    collision_circle_list(global.PLAYER.x, global.PLAYER.y+8, radius, ob_generic, false, false, nearby, false);
    for (var n = 0; n < ds_list_size(nearby); n++) {
      var near = nearby[| n];
      array_push(data, {
        id: near.id,
        sprite_index: near.sprite_index,
        image_index: near.image_index,
        menu_id: undefined,
        oid: near.oid,
        x: near.x,
        y: near.y,
        slots: undefined
      });
    }
    ds_list_destroy(nearby);
  } else {
    with (ob_generic) { 
      array_push(data, {
        id: self.id,
        sprite_index: self.sprite_index,
        image_index: self.image_index,
        menu_id: undefined,
        oid: self.oid,
        x: self.x,
        y: self.y,
        slots: undefined
      });
    }
  }
  return data;
}


// api_get_menu_objects()
// get all nearby or working menu object instances
function sc_mod_api_get_menu_objects(radius) {
  var data = [];
  if (radius != undefined) {
    var nearby = ds_list_create();
    collision_circle_list(global.PLAYER.x, global.PLAYER.y+8, radius, ob_menu_object, false, false, nearby, false);
    for (var n = 0; n < ds_list_size(nearby); n++) {
      var near = nearby[| n];
      var slots = [];
      for (var s = 0; s < ds_list_size(near.slots); s++) {
        array_push(slots, {
          id: slot.id,
          index: slot.index+1,
          item: slot.item,
          count: slot.count,
          current_health: slot.current_health,
          total_health: slot.total_health,
          stats: slot.stats
        });
      }
      array_push(data, {
        id: near.id,
        sprite_index: near.sprite_index,
        image_index: near.image_index,
        menu_id: undefined,
        oid: near.oid,
        x: near.x,
        y: near.y,
        slots: slots
      });  
    }
    ds_list_destroy(nearby);
  } else {
    with (ob_menu_object) {
      var slots = [];
      for (var s = 0; s < ds_list_size(self.slots); s++) {
        array_push(slots, {
          id: slot.id,
          index: slot.index+1,
          item: slot.item,
          count: slot.count,
          current_health: slot.current_health,
          total_health: slot.total_health,
          stats: slot.stats
        });
      }
      array_push(data, {
        id: self.id,
        sprite_index: self.sprite_index,
        image_index: self.image_index,
        menu_id: undefined,
        oid: self.oid,
        x: self.x,
        y: self.y,
        slots: slots
      });  
    }
  }
  return data;
}


// api_get_slots()
// gets all slots for a given menu
function sc_mod_api_get_slots(menu_id) {
  if (menu_id != undefined && instance_exists(menu_id) && variable_instance_exists(menu_id, "slots")) {
    var slots = [];
    for (var s = 0; s < ds_list_size(menu_id.slots); s++) {
      var slot = menu_id.slots[| s];
      array_push(slots, {
        id: slot.id,
        index: slot.index+1,
        item: slot.item,
        count: slot.count,
        current_health: slot.current_health,
        total_health: slot.total_health,
        stats: slot.stats
      });
    }
    return slots;
  } else {
    return undefined;
  }  
}


// api_get_slot_inst()
// get a slots properties from just the slot inst id
function sc_mod_api_get_slot_inst(slot_id) {
  if (slot_id != undefined && instance_exists(slot_id) && slot_id.object_index == ob_slot) {
    var slot = slot_id;
    return {
      id: slot.id,
      index: slot.index+1,
      item: slot.item,
      count: slot.count,
      current_health: slot.current_health,
      total_health: slot.total_health,
      stats: slot.stats
    }
  } else {
    return undefined;  
  }
}

// api_get_slot()
// get a slot for a given menu and index
function sc_mod_api_get_slot(menu_id, slot_index) {
  if (menu_id != undefined && instance_exists(menu_id) && variable_instance_exists(menu_id, "slots")) {
    log(menu_id, menu_id.slots, menu_id.slots[| slot_index-1]);
    var slot = menu_id.slots[| slot_index-1];
    return {
      id: slot.id,
      index: slot.index+1,
      item: slot.item,
      count: slot.count,
      current_health: slot.current_health,
      total_health: slot.total_health,
      stats: slot.stats
    }
  } else {
    return undefined;
  }  
}


// api_get_trees()
// get all nearby tree instances
function sc_mod_api_get_trees(radius) {
  var data = [];
  if (radius != undefined) {
    var nearby = ds_list_create();
    collision_circle_list(global.PLAYER.x, global.PLAYER.y+8, radius, ob_tree, false, false, nearby, false);
    for (var n = 0; n < ds_list_size(nearby); n++) {
      var near = nearby[| n];
      array_push(data, {
        id: near.id,
        sprite_index: near.sprite_index,
        image_index: near.image_index,
        menu_id: undefined,
        oid: near.oid,
        x: near.x,
        y: near.y,
        slots: undefined
      });
    }
    ds_list_destroy(nearby);
  } else {
    with (ob_tree) { 
      array_push(data, {
        id: self.id,
        sprite_index: self.sprite_index,
        image_index: self.image_index,
        oid: self.oid,
        x: self.x,
        y: self.y
      });
    }
  }
  return data;
}


// api_get_flowers()
// get all nearby flower instances
function sc_mod_api_get_flowers(radius) {
  var data = [];
  if (radius != undefined) {
    var nearby = ds_list_create();
    collision_circle_list(global.PLAYER.x, global.PLAYER.y+8, radius, ob_flower, false, false, nearby, false);
    for (var n = 0; n < ds_list_size(nearby); n++) {
      var near = nearby[| n];
      array_push(data, {
        id: near.id,
        sprite_index: near.sprite_index,
        image_index: near.image_index,
        menu_id: undefined,
        oid: near.oid,
        x: near.x,
        y: near.y,
        slots: undefined
      });
    }
    ds_list_destroy(nearby);
  } else {
    with (ob_flower) { 
      array_push(data, {
        id: self.id,
        sprite_index: self.sprite_index,
        image_index: self.image_index,
        menu_id: undefined,
        oid: self.oid,
        x: self.x,
        y: self.y,
        slots: undefined
      });  
    }
  }
  return data;
}


// api_get_boundary()
// get the boundary for a given instance
function sc_mod_api_get_boundary(inst_id) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  try {
    if (instance_exists(inst_id)) {
      return {
        top: inst_id.bbox_top,
        left: inst_id.bbox_left,
        right: inst_id.bbox_right,
        bottom: inst_id.bbox_bottom
      }
    } else {
      sc_mod_log(mod_name, "api_get_boundary", "Error: Instance Not Active", undefined);
      return undefined;
    }
  } catch(ex) {
    sc_mod_log(mod_name, "api_get_boundary", "Error: Invalid Instance ID", ex.longMessage);
    return undefined;
  }
}


// api_get_filename()
// get uuid for current game
function sc_mod_api_get_filename() {
  return global._FILE_LOADED;  
}