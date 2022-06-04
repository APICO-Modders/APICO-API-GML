// api_slot_clear()
// clear slot, setting item to "" count + health to 0 and resetting stats to empty
function sc_mod_api_slot_clear(slot_id) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  sc_mod_api_set_active(slot_id);
  try {
    if (slot_id != undefined && instance_exists(slot_id)) {
      sc_slot_clear(slot_id);
      return "Success";
    }
  } catch(ex) {
    sc_mod_log(mod_name, "api_slot_clear", "Error: Failed To Clear Slot", ex.longMessage);
    return undefined;
  }
}


// api_slot_incr()
// add to slot amount, capped at 99
function sc_mod_api_slot_incr(slot_id, amount) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  sc_mod_api_set_active(slot_id);
  try {
    if (slot_id != undefined && instance_exists(slot_id)) {
      if (amount == undefined) amount = 1;
      slot_id.count += amount;
      if (slot_id.count > 99) slot_id.count = 99;
      return "Success";
    }
  } catch(ex) {
    sc_mod_log(mod_name, "api_slot_incr", "Error: Failed To Increase Slot", ex.longMessage);
    return undefined;
  }
}


// api_slot_decr()
// remove from slot amount, clearing if 0 is left
function sc_mod_api_slot_decr(slot_id, amount) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  sc_mod_api_set_active(slot_id);
  try {
    if (slot_id != undefined && instance_exists(slot_id)) {
      if (amount == undefined) amount = 1;
      slot_id.count -= amount;
      if (slot_id.count <= 0) {
        sc_slot_clear(slot_id);  
      }
      return "Success";
    }
  } catch(ex) {
    sc_mod_log(mod_name, "api_slot_incr", "Error: Failed To Descrease Slot", ex.longMessage);
    return undefined;
  }
}


// api_slot_set()
// set a given slot with a given item
function sc_mod_api_slot_set(slot_id, item, amount, stats) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  sc_mod_api_set_active(slot_id);
  try {
    if (slot_id != undefined && instance_exists(slot_id)) {
      var data = sc_util_create_item_data(item, amount, stats == undefined ? {} : stats);
      sc_slot_set(slot_id, data.item, data.total, data.durability, data.durability, stats == undefined ? data.stats : stats);
      return "Success";
    }
  } catch(ex) {
    sc_mod_log(mod_name, "api_slot_set", "Error: Failed To Set Slot", ex.longMessage);
    return undefined;
  }
}


// api_slot_match()
// get the first slot with a match in the match list
function sc_mod_api_slot_match(menu_id, match, first) {
  sc_mod_api_set_active(menu_id);
  if (menu_id != undefined && instance_exists(menu_id) && variable_instance_exists(menu_id, "slots")) {
    var slots = [];
    
    // convert datatype from array to list
    var matches = ds_list_create();
    for (var m = 0; m < array_length(match); m++) {
      ds_list_add(matches, match[m]);  
    }
    
    // check for ANY as match option
    var match_any = ds_list_find_index(matches, "ANY") != -1;
    for (var s = 0; s < ds_list_size(menu_id.slots); s++) {
      var slot = menu_id.slots[| s];
      
      // check match
      if (match_any == true && slot.item != "" || ds_list_find_index(matches, slot.item) != -1) {
        if (first == true) { // return first match if specified
          ds_list_destroy(matches);
          return {
            id: slot.id,
            index: slot.index+1,
            item: slot.item,
            count: slot.count,
            current_health: slot.current_health,
            total_health: slot.total_health,
            stats: slot.stats
          };
        } else {
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
      }
      
    }
    ds_list_destroy(matches);
    if (first == true) return undefined;
    return slots;
  } else {
    return undefined;
  }  
}


// api_slot_match_range()
// get the first slot with a match from a range
function sc_mod_api_slot_match_range(menu_id, match, range, first) {
  sc_mod_api_set_active(menu_id);
  if (menu_id != undefined && instance_exists(menu_id) && variable_instance_exists(menu_id, "slots")) {
    var slots = [];
    
    // convert datatypes
    var matches = ds_list_create();
    for (var m = 0; m < array_length(match); m++) {
      ds_list_add(matches, match[m]);  
    }
    var match_any = ds_list_find_index(matches, "ANY") != -1;
    var ranges = ds_list_create();
    for (var r = 0; r < array_length(range); r++) {
      ds_list_add(ranges, range[r]);  
    }
    
    // check slots
    for (var s = 0; s < ds_list_size(menu_id.slots); s++) {
      var slot = menu_id.slots[| s];
      if (ds_list_find_index(ranges, slot.index+1) != -1) {
        if (match_any == true && slot.item != "" || ds_list_find_index(matches, slot.item) != -1) {
          if (first == true) { // return first if specified
            ds_list_destroy(matches);
            ds_list_destroy(ranges);
            return {
              id: slot.id,
              index: slot.index+1,
              item: slot.item,
              count: slot.count,
              current_health: slot.current_health,
              total_health: slot.total_health,
              stats: slot.stats
            };
           } else {
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
        }
      }
    }
    
    // destroy temp data + return slots
    ds_list_destroy(matches);
    ds_list_destroy(ranges);
    if (first == true) return undefined;
    return slots;
  } else {
    return undefined;
  }  
}


// api_slot_fill()
// automatically start a slot fill event
function sc_mod_api_slot_fill(menu_id, slot_index) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  sc_mod_api_set_active(menu_id);
  if (menu_id != undefined && instance_exists(menu_id)) {
    menu_id.filling = true;
    menu_id.mod_fill = slot_index-1;
    sc_menu_fill(menu_id, slot_index-1, 0);
    return "Success";
  } else {
    sc_mod_log(mod_name, "api_slot_fill", "Error: Menu Instance Doesn't Exist", undefined);
    return undefined;
  }
}


// api_slot_drain()
// automatically start a slot drain event
function sc_mod_api_slot_drain(menu_id, slot_index) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  sc_mod_api_set_active(menu_id);
  if (menu_id != undefined && instance_exists(menu_id)) {
    menu_id.draining = true;
    menu_id.mod_drain = slot_index-1;
    sc_menu_drain(menu_id, slot_index-1, 1);
    return "Success"
  } else {
    sc_mod_log(mod_name, "api_slot_drain", "Error: Menu Instance Doesn't Exist", undefined);
    return undefined;
  }
}


// api_slot_set_inactive
// set a slot to be inactive, making it unable to be highlighted or clicked
function sc_mod_api_slot_set_inactive(slot_id, inactive) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  sc_mod_api_set_active(slot_id);
	if (slot_id != undefined && instance_exists(slot_id)) {
		slot_id.inactive = inactive;	
		return "Success";
	} else {
    sc_mod_log(mod_name, "api_slot_set_inactive", "Error: Slot Instance Doesn't Exist", undefined);
    return undefined;
	}
}


// api_slot_set_modded
// set a slot to be modded, making it able to be highlighted but cant be clicked
function sc_mod_api_slot_set_modded(slot_id, modded) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  sc_mod_api_set_active(slot_id);
	if (slot_id != undefined && instance_exists(slot_id)) {
		slot_id.modded = modded;
		return "Success";
	} else {
    sc_mod_log(mod_name, "api_slot_set_modded", "Error: Slot Instance Doesn't Exist", undefined);
    return undefined;
	}
}


// api_slot_validate
// checks a slot can take a given item w/ stats
function sc_mod_api_slot_validate(slot_id, item, stats) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  sc_mod_api_set_active(slot_id);
	if (slot_id != undefined && instance_exists(slot_id)) {
    return sc_slot_validate(slot_id, item, stats);
  } else {
    sc_mod_log(mod_name, "api_slot_validate", "Error: Slot Instance Doesn't Exist", undefined);
    return false; 
  }
}


// api_slot_item_id
// gets a slot item as a : id, i.e. bee:common or frame1:filled or axe1 etc
function sc_mod_api_slot_item_id(menu_id, slot_index) {
  sc_mod_api_set_active(menu_id);
  if (menu_id != undefined && instance_exists(menu_id) && variable_instance_exists(menu_id, "slots")) {
    var slot = menu_id.slots[| slot_index-1];
    var item = slot.item;
    if (item == "bee" && slot.stats != undefined) item += ":" + slot.stats.species;
    if (contains(item, "frame")) {
      if (slot.stats.uncapped == true) {
        item += ":uncapped";
      } else if (slot.stats.filled == true) {
        item += ":filled";
      }
    }
    return item;
  } else {
    return undefined;
  }  
}


// api_slot_draw
// re-draws a specific slot
function sc_mod_api_slot_redraw(slot_id) {
  sc_mod_api_set_active(slot_id);
  if (slot_id != undefined && instance_exists(slot_id)) {
    sc_slot_draw(slot_id);
  }
} 
