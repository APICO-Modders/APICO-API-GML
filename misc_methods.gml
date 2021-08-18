// api_choose()
// choose randomly from a list of items
function sc_mod_api_choose(items) {
  var choice = irandom(array_length(items)-1);
  return items[choice];
}


// api_random_range()
// choose a random number between a range
function sc_mod_api_random_range(sn, en) {
  return irandom_range(sn, en);
}


// api_random()
// choose a random number between 0 and x
function sc_mod_api_random(sn) {
  return irandom(sn);  
}


// api_toggle_menu()
// toggle a menu to be open or closed
function sc_mod_api_toggle_menu(menu_id, toggle) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  if (menu_id != undefined && instance_exists(menu_id) && menu_id.object_index == ob_menu) {
    sc_menu_object_toggle(menu_id.obj, toggle);
    return "Success";
  } else {
    sc_mod_log(mod_name, "api_toggle_menu", "Error: Invalid Menu Instance", undefined);  
    return undefined;
  }
}


// api_destroy_inst()
// destroy a given inst
function sc_mod_api_destroy_instance(inst_id) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  if (inst_id != undefined) {
    if (inst_id == global.PLAYER) {
      sc_mod_log(mod_name, "api_destroy_inst", "Error: Why Would You Even Try That? :(", undefined);  
      return undefined;
    } else if (inst_id.oid == "scenery1") {
      sc_mod_log(mod_name, "api_destroy_inst", "Error: Why Would You Do That To Poor Skipper? :(", undefined);  
      return undefined;
    } else {
      instance_destroy(inst_id);  
      return "Success";
    }
  } else {
    sc_mod_log(mod_name, "api_destroy_inst", "Error: Invalid Instance ID", undefined);  
    return undefined;
  }
}  


// api_check_discovery()
// check for discovery of a iven oid
function sc_mod_api_check_discovery(oid) {
  return ds_list_find_index(global.DISCOVERED, oid) != -1;
}
