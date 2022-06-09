// api_describe_mods()
// get a list of all mod names loaded
function sc_mod_api_describe_mods() {
  return global.MOD_LIST; 
}

// api_describe_oids()
// get a list of all oids either in the base game or mods
function sc_mod_api_describe_oids(modded) {
  if (modded == true) {
    var oids = {};
    var mods = variable_struct_get_names(global.MODDED_DICTIONARY);
    for (var m = 0; m < array_length(mods); m++) {
      var mod_oids = variable_struct_get_names(global.MODDED_DICTIONARY[$ mods[m]]);
      array_sort(mod_oids, true);
      oids[$ mods[m]] = mod_oids;
    }
    return oids;
  } else {
    var keys = ds_map_keys_to_array(global.MOD_DICTIONARY_BACKUP);
    var filtered_keys = [];
    var hidden_keys = ds_list_create();
    var hidden = [
      "font_map_note", "font_map", "font_map_s",
      "font_symbols_notes", "font_symbols", "bottle_indices",
      "messages", "tool_reference", "player", "home", "start",
      "creator", "postcard", "disco", "settingsm", "settingsh",
      "controlsm", "controlsh", "accessm", "accessh", "library",
      "modding", "ems", "bn"
    ];
    for (var h = 0; h < array_length(hidden); h++) {
      ds_list_add(hidden_keys, hidden[h]); 
    }
    for (var k = 0; k < array_length(keys); k++) {
      var key = keys[k];
      if (ds_list_find_index(hidden_keys, key) == -1) {
        var cat = global.DICTIONARY[? key][? "category"];
        if (cat != undefined && cat != "" && 
          string_pos("button_", key) == 0 && 
          string_pos("tab_", key) == 0 && 
          string_pos("mechanism_", key) == 0
        ) {
          array_push(filtered_keys, key);
        }
      }
    }
    array_push(filtered_keys, "grass1");
    array_sort(filtered_keys, true);
    return filtered_keys;
  }
}

// api_describe_dictionary()
// return the full dictionary for either the base game or mods
function sc_mod_api_describe_dictionary(modded) {
  if (modded == true) return global.MODDED_DICTIONARY;
  return json_parse(json_encode(global.MOD_DICTIONARY_BACKUP)); 
}

// api_describe_bees()
// return the bee list for either the base game or mods
function sc_mod_api_describe_bees(modded) {
  if (modded == true) return global.MODDED_BEES;
  return json_parse(json_encode(global.MOD_BEES_BACKUP)); 
}

// api_describe_recipes()
// return the workshop recipe list for either the base game or mods
function sc_mod_api_describe_recipes(modded) {
  if (modded == true) return global.MODDED_RECIPES;
  return json_parse(json_encode(global.MOD_RECIPES_BACKUP)); 
}

// api_describe_commands()
// return the command list for either the base game or mods
function sc_mod_api_describe_commands(modded) {
  if (modded == true) return global.MODDED_COMMANDS;
  return [
    "/gimme", "/time", "/weather", "/debug", "/fps", "/tp", "/disco", 
    "/devland", "/bees", "/door", "/dream", "/ready", "/buff"
  ];
}
