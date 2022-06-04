// api_choose()
// choose randomly from a list of items
function sc_mod_api_choose(items) {
  var choice = irandom(array_length(items)-1);
  return items[choice];
}


// api_is_game_paused()
// is game paused y/n
function sc_mod_api_is_game_paused() {
  return global.PAUSED; 
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
  sc_mod_api_set_active(menu_id);
  if (menu_id != undefined && instance_exists(menu_id) && menu_id.object_index == ob_menu) {
    sc_menu_object_toggle(menu_id.obj, toggle, true);
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
  sc_mod_api_set_active(inst_id);
  if (inst_id != undefined) {
    if (inst_id == global.PLAYER) {
      sc_mod_log(mod_name, "api_destroy_inst", "Error: Why Would You Even Try That? :(", undefined);  
      return undefined;
    } else if (inst_id.oid == "scenery1") {
      sc_mod_log(mod_name, "api_destroy_inst", "Error: Why Would You Do That To Poor Skipper? :(", undefined);  
      return undefined;
    } else {
			if (global.HIGHLIGHTED_OBJ == inst_id) global.HIGHLIGHTED_OBJ = "";
			if (global.HIGHLIGHTED_ITEM == inst_id) global.HIGHLIGHTED_ITEM = "";
			if (global.HIGHLIGHTED_MENU == inst_id) global.HIGHLIGHTED_MENU = "";
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


// api_play_sound()
// plays a sound effect from the base game
function sc_mod_api_play_sound(name) {
	var vol = 0;
	switch(name) {
		case "break": vol = 0.2; break;
		case "click": vol = 0.1; break;
		case "confetti": vol = 0.2; break;
		case "error": vol = 0.2; break;
		case "jingle": vol = 0.3; break;
		case "open": vol = 0.1; break;
		case "plop": vol = 0.1; break;
		case "pop": vol = 0.1; break;
		case "rollover": vol = 0.1; break;
	}
	if (vol != 0) sc_play_sound(name, vol);
}


// api_unlock_quest()
// unlocks a quest based on the quest id
function sc_mod_api_unlock_quest(quest_id) {
	var progress = global.QUEST_PROGRESS[? quest_id];
	if (progress == undefined) return undefined;
	global.QUEST_PROGRESS[? quest_id].unlocked = true;
  global.PLAYER.book1_ref.defined = false;
  sc_book_define(global.PLAYER.book1_ref, 0, true);
	return "Success";
}


// api_blacklist_input()
// blacklists input for a given menu oid so vanilla key inputs are ignored while the menu is highlighted 
function sc_mod_api_blacklist_input(menu_oid) {
  if (ds_list_find_index(global.MOD_BLACKLIST, menu_oid) == -1) {
    ds_list_add(global.MOD_BLACKLIST, menu_oid); 
  }
}


// api_remove_gui()
// lets you delete a gui you defined with api_define_gui()
function sc_mod_api_remove_gui(menu_id, gui_key) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  sc_mod_api_set_active(menu_id);
  if (menu_id != undefined && instance_exists(menu_id) && menu_id.object_index == ob_menu) {
    var existing = variable_instance_get(menu_id, gui_key); 
    if (existing != undefined && instance_exists(existing)) { 
      instance_destroy(existing);
      variable_instance_set(menu_id, gui_key, undefined);
      return "Success";
    } else {
      sc_mod_log(mod_name, "api_remove_gui", "Error: GUI Key Empty/Undefined", undefined);
    }
  } else {
    sc_mod_log(mod_name, "api_remove_gui", "Error: Menu Instance Not Found", undefined);
    return undefined;    
  }
}


// api_library_add_book()
// lets you add a book icon to the bottom library menu which can call a script you define when clicked
// this doesnt add any book functionality, you must provide that yourself (see the Sample Mod for an example book)
function sc_mod_api_library_add_book(book_name, book_script, book_sprite) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  var spr = sprite_add(working_directory + "mods/" + mod_name + "/" + book_sprite, 2, true, false, 0, 0);
  if (spr == -1) {
    sc_mod_log(mod_name, "api_library_add_book", "Error: Book Sprite Not Found", undefined);
    return undefined;  
  } else {
    if (global.MOD_BOOKS[? book_name] == undefined) {
      global.MOD_BOOKS[? book_name] = book_script;
      array_push(global.MOD_BOOK_LIST, book_name);
      
      // add book gui to library
      var b = array_length(global.MOD_BOOK_LIST) + 3;
      var menu = global.PLAYER.menu_book;
	    var oid = "book" + string(b+1);
		  var book = instance_create_layer(menu.x + 5 + (b*18), menu.y + 4, "Menus", ob_button);
		  book.sprite_index = spr;
		  book.ox = 5 + (b*18)
		  book.oy = 4;
		  book.type = "BookMod";
		  book.text = book_name;
      book.index = lua_current;
		  book.menu = menu.id;
		  variable_struct_set(menu.books, oid, book);
      
      // update library
      sc_library_update(menu);
      
      return "Success";
    } else {
      sc_mod_log(mod_name, "api_library_add_book", "Error: Book Name Already Used", undefined);
      return undefined; 
    }
  }
}


// api_add_slot_to_menu()
// lets you add the contents of a slot to a given menu
// if there is room the slot is cleared, otherwise the remainder is left in the slot
function sc_mod_api_add_slot_to_menu(slot_id, menu_id) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  sc_mod_api_set_active(slot_id);
  sc_mod_api_set_active(menu_id);
  if (instance_exists(slot_id) && instance_exists(menu_id)) {
    sc_menu_add(menu_id, slot_id);
    return "Success";
  } else {
    sc_mod_log(mod_name, "api_add_slot_to_menu", "Error: Menu/Slot Instance Doesn't Exists", undefined);
    return undefined;
  }
}

// api_inst_exists()
// lets you check if a instance exists
// NB will return false if the instance is deactivated too!
function sc_mod_api_inst_exists(inst_id) {
  sc_mod_api_set_active(inst_id);
  return instance_exists(inst_id);
}



// api_http_request()
// lets you send a http request
function sc_mod_api_http_request(url, method_type, header_keys, body, callback) {
  
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  
  try {
  
    var headers = ds_map_create();
    var keys = variable_struct_get_names(header_keys);
    for (var k = 0; k < array_length(keys); k++) {
      ds_map_set(headers, keys[k], header_keys[$ keys[k]]); 
    }
    
    var req = http_request(url, method_type, headers, body);
    
    global.MOD_HTTP_API[$ mod_name + "_" + callback] = {
      id: req,
      name: mod_name,
      state: lua_current,
      callback: callback
    }
    
    ds_map_destroy(headers);
    
    sc_mod_log(mod_name, "api_http_request", "Sent Request (" + url + ")", undefined);
    return "Success";
  
  } catch(ex) {
    sc_mod_log(mod_name, "api_http_request", "Error: Failed To Send Request", ex.longMessage);
    return undefined;
  }
  
  
}
