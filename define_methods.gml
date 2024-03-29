// api_define_item()
// defines a new item and adds it to the dictionary
function sc_mod_api_define_item(item, sprite_image, special) {
  
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  
  try {
    
    // check required keys in the item_def
    var req = ["id", "name", "category", "tooltip"];
    for (var r = 0; r < array_length(req); r++) {
      if (!variable_struct_exists(item, req[r])) {
        sc_mod_log(mod_name, "api_define_item", "Error: Missing Required Key (" + req[r] + ")", undefined);
        return undefined;
      }
    }
    if (variable_struct_exists(item, "placeable") && !variable_struct_exists(item, "obj")) {
      sc_mod_log(mod_name, "api_define_item", "Error: Item Marked Placeable But No Object Specified", undefined);
      return undefined;
    }
    
    // "special" called by api_define_flower to remove mod_name identifier
    var item_id = special != undefined ? item.id : mod_name + "_" + item.id;
    
    // handle unique
    if (global.DICTIONARY[? item_id] != undefined) {
      sc_mod_log(mod_name, "api_define_item", "Error: ID Already Defined (" + item_id + ")", undefined);
      return undefined;
    }
    
    // setup dictionary definition
    var def = ds_map_create();
    def[? "id"] = item_id;
    def[? "name"] = item.name;
    def[? "category"] = item.category;
    def[? "tooltip"] = item.tooltip;
    
    var cost = ds_map_create();
    if (variable_struct_exists(item, "shop_key") == true) cost[? "key"] = item.shop_key;
    cost[? "buy"] = variable_struct_exists(item, "shop_buy") == true ? item.shop_buy : 0;
    cost[? "sell"] = variable_struct_exists(item, "shop_sell") == true ? item.shop_sell : 0;
    ds_map_add_map(def, "cost", cost);
    var machines = ds_list_create();  
    if (variable_struct_exists(item, "machines")) {
      for (var a = 0; a < array_length(item.machines); a++) {
        ds_list_add(machines, item.machines[a]);
      }
    }
    ds_map_add_list(def, "machines", machines);
    ds_map_add_list(def, "tools", ds_list_create());
    def[? "placeable"] = variable_struct_exists(item, "placeable") ? item.placeable : false;
    if (def[? "placeable"] == true && variable_struct_exists(item, "place_grass")) def[? "nature"] = item.place_grass;
    if (def[? "placeable"] == true && variable_struct_exists(item, "place_water")) def[? "aquatic"] = item.place_water;
    if (def[? "placeable"] == true && variable_struct_exists(item, "place_deep")) def[? "deep"] = item.place_deep;
    if (variable_struct_exists(item, "durability")) def[? "durability"] = item.durability;
    if (variable_struct_exists(item, "singular")) def[? "singular"] = item.singular;
    if (variable_struct_exists(item, "obj")) def[? "obj"] = item.obj;
    if (variable_struct_exists(item, "honeycore")) def[? "honeycore"] = item.honeycore;
    
    if (variable_struct_exists(item, "bee_lore")) {
      var lore = ds_list_create();
      var text = ds_map_create();
      text[? "color"] = "FONT_BOOK";
      text[? "text"] = item.bee_lore;
      ds_list_add(lore, text);
      def[? "lore"] = lore;
    }
    
    // try loading sprite
    try {
      global.DICTIONARY[? item_id] = def;
      global.MODDED_DICTIONARY[$ mod_name][$ item_id] = json_parse(json_encode(def));
      
      var spr = sprite_add(working_directory + "mods/" + mod_name + "/" + sprite_image, 4, true, false, 0, 0);
      if (spr == -1) {
        sc_mod_log(mod_name, "api_define_item", "Error: Item Sprite Not Found (" + sprite_image + ")", "");
        return undefined;
      } else {
        var spr_name = "sp_" + item_id;
        global.MOD_SPRITES[? spr_name] = spr;
        global.SPRITE_REFERENCE[? spr_name] = spr;
        return "Success";
      }
    } catch(ex) {
      sc_mod_log(mod_name, "api_define_item", "Error: Failed To Add Sprite", ex.longMessage);
      return undefined;
    }
  
  // not sure why this would be called but rather safe than sorry
  } catch(ex) {
    sc_mod_log(mod_name, "api_define_item", "Error: Failed To Map Keys", ex.longMessage);
    return undefined;
  }
  
}


// api_define_item_stats()
// defines the default "stats" for a given oid when created
function sc_mod_api_define_item_stats(oid, stats) {
  global.MOD_ITEM_STATS[$ oid] = stats; 
}


// api_define_color()
// define a new color and add to the global.COLORS to use later
function sc_mod_api_define_color(name, col) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  if (global.COLORS[? name] == undefined) {
    global.COLORS[? name] = make_color_rgb(col.r, col.g, col.b);
    return "Success";
  } else {
    sc_mod_log(mod_name, "api_define_color", "Error: Color Name Already Exists", undefined);
    return undefined;
  }
}


// api_define_sprite()
// define a new sprite and add to the sprite reference, returning the ID
function sc_mod_api_define_sprite(sprite_name, sprite_image, frames) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  try {
    
    // try loading the sprite given
    var path = working_directory + "mods/" + mod_name + "/" + sprite_image;
    var spr = sprite_add(path, frames, true, false, 0, 0);
    if (spr == -1) {
      sc_mod_log(mod_name, "api_define_sprite", "Error: Failed To Find Path (" + path + ")", undefined);  
      return undefined;
    } else {
      
      // add to references
      var spr_name = "sp_" + sprite_name;
      if (global.MOD_SPRITES[? spr_name] == undefined && global.SPRITE_REFERENCE[? spr_name] == undefined) {
        global.MOD_SPRITES[? spr_name] = spr;
        global.SPRITE_REFERENCE[? spr_name] = spr;
        sc_mod_log(mod_name, "api_define_sprite", "Sprite Defined (" + spr_name + ")", undefined);  
        return spr;
      } else {
        sc_mod_log(mod_name, "api_define_sprite", "Error: Sprite Name Already Exists", undefined);  
        return undefined;
      }
    }
    
  // not sure why it might be called but hey ho
  } catch(ex) {
    sc_mod_log(mod_name, "api_define_sprite", "Error: Failed To Define Sprite", ex.longMessage);  
    return undefined;
  }
}


// api_define_gif()
// define a new gif and add to the sprite reference, returning the ID
function sc_mod_api_define_gif(gif_name, gif_image, frames) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  try {
    
    // try loading the sprite given
    var path = working_directory + "mods/" + mod_name + "/" + gif_image;
    var spr = sprite_add(path, frames, true, false, 0, 0);
    if (spr == -1) {
      sc_mod_log(mod_name, "api_define_gif", "Error: Failed To Find Path (" + path + ")", undefined);  
      return undefined;
    } else {
      
      // add to references
      var spr_name = "gif_" + gif_name;
      if (global.MOD_SPRITES[? spr_name] == undefined && global.SPRITE_REFERENCE[? spr_name] == undefined) {
        global.MOD_SPRITES[? spr_name] = spr;
        global.SPRITE_REFERENCE[? spr_name] = spr;
        sc_mod_log(mod_name, "api_define_gif", "GIF Defined (" + spr_name + ")", undefined);  
        return spr;
      } else {
        sc_mod_log(mod_name, "api_define_gif", "Error: GIF Name Already Exists", undefined);  
        return undefined;
      }
    }
    
  // not sure why it might be called but hey ho
  } catch(ex) {
    sc_mod_log(mod_name, "api_define_gif", "Error: Failed To Define GIF", ex.longMessage);  
    return undefined;
  }
}


// api_define_workbench()
// define the name + tabs for your mod in the mod workbench
function sc_mod_api_define_workbench(name, tabs) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  global.MOD_WORKBENCH[$ mod_name] = {
    name: name,
    tabs: {
      t1: !variable_struct_exists(tabs, "t1") ? "" : tabs.t1, 
      t2: !variable_struct_exists(tabs, "t2") ? "" : tabs.t2, 
      t3: !variable_struct_exists(tabs, "t3") ? "" : tabs.t3, 
      t4: !variable_struct_exists(tabs, "t4") ? "" : tabs.t4, 
      t5: !variable_struct_exists(tabs, "t5") ? "" : tabs.t5, 
    }
  }
  return "Success";
}


// api_define_recipe()
// define a new recipe for the workbench
function sc_mod_api_define_recipe(tab, item, recipe, total) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  
  if (global.MOD_WORKBENCH_RECIPES[$ mod_name] == undefined) {
    global.MOD_WORKBENCH_RECIPES[$ mod_name] = {
      t1: [],
      t2: [],
      t3: [],
      t4: [],
      t5: []
    }
  }
  
  tab = string(tab);
  if (tab == "crafting") tab = "t1";
  if (tab == "tools") tab = "t2";
  if (tab == "beekeeping") tab = "t3";
  if (tab == "decoration") tab = "t4";
  if (tab == "painting") tab = "t5";
  
  var new_recipe = {
    item: item,
    recipe: recipe
  }
  if (total > 1) new_recipe[$ "total"] = total;
  
  array_push(global.MOD_WORKBENCH_RECIPES[$ mod_name][$ tab], new_recipe);
  array_push(global.MODDED_RECIPES[$ mod_name][$ tab], new_recipe);
  return "Success";
  
}


// api_define_object()
// defines a new object and adds it to the dictionary
function sc_mod_api_define_object(obj, sprite_image, draw_script, special) {
  
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  
  try {
    
    // check required fields
    var req = ["id", "name", "category", "tooltip"];
    for (var r = 0; r < array_length(req); r++) {
      if (variable_struct_exists(obj, req[r]) == false) {
        sc_mod_log(mod_name, "api_define_object", "Error: Missing Required Key (" + req[r] + ")", undefined);
        return undefined;
      }
    }
    
    // used by api_define_flower to remove mod_name
    var obj_id = special != undefined ? obj.id : mod_name + "_" + obj.id;
    
    // check unique
    if (global.DICTIONARY[? obj_id] != undefined) {
      sc_mod_log(mod_name, "api_define_object", "Error: ID Already Defined (" + obj_id + ")", undefined);
      return undefined;
    }
    
    // setup dictionary definition
    var def = ds_map_create();
    def[? "id"] = obj_id;
    def[? "name"] = obj.name;
    def[? "category"] = obj.category;
    def[? "tooltip"] = obj.tooltip;
    var cost = ds_map_create();
    if (variable_struct_exists(obj, "shop_key") == true) cost[? "key"] = obj.shop_key;
    cost[? "buy"] = variable_struct_exists(obj, "shop_buy") == true ? obj.shop_buy : 0;
    cost[? "sell"] = variable_struct_exists(obj, "shop_sell") == true ? obj.shop_sell : 0;
    ds_map_add_map(def, "cost", cost);
    def[? "menu"] = false;
    var machines = ds_list_create();  
    if (variable_struct_exists(obj, "machines")) {
      for (var a = 0; a < array_length(obj.machines); a++) {
        ds_list_add(machines, obj.machines[a]);
      }
    }
    ds_map_add_list(def, "machines", machines);
    var tools = ds_list_create();
    if (variable_struct_exists(obj, "tools")) {
      for (var a = 0; a < array_length(obj.tools); a++) {
        ds_list_add(tools, obj.tools[a]);
      }
    }
    ds_map_add_list(def, "tools", tools);
    if (variable_struct_exists(obj, "drops")) {
      var drops = ds_list_create();
      for (var d = 0; d < array_length(obj.drops); d++) {
        ds_list_add(drops, obj.drops[d]);
      }
      ds_map_add_list(def, "drops", drops);
    }
    def[? "placeable"] = true;
    def[? "obj"] = obj_id;
    def[? "chance"] = 100;
    if (def[? "placeable"] == true && variable_struct_exists(obj, "place_grass")) def[? "nature"] = obj.place_grass;
    if (def[? "placeable"] == true && variable_struct_exists(obj, "place_water")) def[? "aquatic"] = obj.place_water;
    if (def[? "placeable"] == true && variable_struct_exists(obj, "place_deep")) def[? "deep"] = obj.place_deep;
    if (variable_struct_exists(obj, "durability")) def[? "durability"] = obj.durability;
    if (variable_struct_exists(obj, "singular")) def[? "singular"] = obj.singular;
    if (variable_struct_exists(obj, "honeycore")) def[? "honeycore"] = obj.honeycore;
    if (variable_struct_exists(obj, "has_shadow")) def[? "shadow"] = obj.has_shadow;
    if (variable_struct_exists(obj, "has_lighting")) def[? "lighting"] = obj.has_lighting;
    if (variable_struct_exists(obj, "pickable")) def[? "pickable"] = obj.pickable;
    if (variable_struct_exists(obj, "variants")) def[? "variants"] = obj.variants;
    if (variable_struct_exists(obj, "nature")) def[? "nature"] = obj.nature;
    if (variable_struct_exists(obj, "growth")) def[? "growth"] = obj.growth;
    if (variable_struct_exists(obj, "invisible")) def[? "invisible"] = obj.invisible;
    if (variable_struct_exists(obj, "bench")) def[? "is_bench"] = obj.bench;
    if (variable_struct_exists(obj, "bed")) def[? "is_bed"] = obj.bed;
    if (variable_struct_exists(obj, "depth")) def[? "depth"] = obj.depth;
    if (variable_struct_exists(obj, "hp")) def[? "mhp"] = obj.hp;
    
    if (variable_struct_exists(obj, "item_sprite")) {
      var ispr = sprite_add(working_directory + "mods/" + mod_name + "/" + obj.item_sprite, 4, true, false, 0, 0);
      if (ispr == -1) {
        sc_mod_log(mod_name, "api_define_object", "Error: Object Sprite Not Found (item_sprite)", undefined);
        return undefined;  
      } else {
        var ispr_name = "sp_" + obj_id + "_item";
        global.MOD_SPRITES[? ispr_name] = ispr
        global.SPRITE_REFERENCE[? ispr_name] = ispr;
      }
    }
    
    // add custom draw script if any
    if (draw_script != undefined) {
      global.MOD_OBJ_STATES[? obj_id] = lua_current;
      global.MOD_OBJ_SCRIPTS[? obj_id] = draw_script;
    }    
    
    try {
      
      // add to dictionary
      global.DICTIONARY[? obj_id] = def;
      global.MODDED_DICTIONARY[$ mod_name][$ obj_id] = json_parse(json_encode(def));
      
      var spr_name = "sp_" + obj_id;
      if (special == "flower") spr_name += "_item"; // flower object sprites need a _item
      var spr = undefined;
      if (sprite_image == undefined && special == "seedling") {
        spr = sp_seedling; // all seedlings are the same sprite
      } else {
        var obj_frames = variable_struct_exists(obj, "bed") && obj.bed == true ? 5 : 4;
        if (variable_struct_exists(obj, "variants")) obj_frames = obj.variants * 2;
        spr = sprite_add(working_directory + "mods/" + mod_name + "/" + sprite_image, obj_frames, true, false, 0, 0);
      }
      
      // add sprite ref if loaded
      if (spr == -1) {
        sc_mod_log(mod_name, "api_define_object", "Error: Object Sprite Not Found", undefined);
        return undefined;  
      } else {        
        global.MOD_SPRITES[? spr_name] = spr;
        global.SPRITE_REFERENCE[? spr_name] = spr;
        return "Success";
      }
      
    // prob wouldn't be called
    } catch(ex) {
      sc_mod_log(mod_name, "api_define_object", "Error: Failed To Add Sprite", ex.longMessage);
      return undefined;
    }
  
  // would happen if bad datatypes in given obj_def
  } catch(ex) {
    sc_mod_log(mod_name, "api_define_object", "Error: Failed To Map Keys", ex.longMessage);
    return undefined;
  }
    
}


// api_define_quest()
// adds a new quest to the book
function sc_mod_api_define_quest(quest, page1, page2, claim_script) {
  
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  
  try {
    
    // check required
    var req = ["id", "title", "reqs", "icon", "reward", "unlock"];
    for (var r = 0; r < array_length(req); r++) {
      if (!variable_struct_exists(quest, req[r])) {
        sc_mod_log(mod_name, "api_define_quest", "Error: Missing Required Key (" + req[r] + ")", undefined);
        return undefined;
      }
    }
    
    // check unique
    if (global.QUESTS[? quest.id] != undefined) {
      sc_mod_log(mod_name, "api_define_quest", "Error: Quest With ID Already Defined (" + quest.id + ")", undefined);
      return undefined;  
    } else {
      
      // setup quest definition to add
      var nq = ds_map_create();
      nq[? "id"] = quest.id;
      nq[? "title"] = quest.title;
      nq[? "requirements"] = ds_list_create();
      for (var r = 0; r < array_length(quest.reqs); r++) {
        ds_list_add(nq[? "requirements"], quest.reqs[r]);  
      }
      nq[? "section"] = 6;
      nq[? "icon"] = quest.icon;
      nq[? "reward"] = quest.reward;
      nq[? "unlock"] = ds_list_create();
      for (var r = 0; r < array_length(quest.unlock); r++) {
        ds_list_add(nq[? "unlock"], quest.unlock[r]);  
      }
      
      // page1
      nq[? "page1"] = ds_list_create();
      for (var p = 0; p < array_length(page1); p++) {
        var line = page1[p];
        var l = ds_map_create();
        if (!variable_struct_exists(line, "gif")) l[? "color"] = variable_struct_exists(line, "color") ? line.color : "FONT_BOOK";
        if (!variable_struct_exists(line, "gif")) l[? "text"] = variable_struct_exists(line, "text") ? line.text : "\n";
        if (variable_struct_exists(line, "gif")) l[? "gif"] = line.gif;
        if (variable_struct_exists(line, "height")) l[? "height"] = line.height;
        ds_list_add(nq[? "page1"], l);
      }
      
      //page 2
      nq[? "page2"] = ds_list_create();
      for (var p = 0; p < array_length(page2); p++) {
        var line = page2[p];
        var l = ds_map_create();
        l[? "color"] = variable_struct_exists(line, "color") ? line.color : "FONT_BOOK";
        l[? "text"] = variable_struct_exists(line, "text") ? line.text : "\n";
        if (variable_struct_exists(line, "gif")) l[? "gif"] = line.gif;
        if (variable_struct_exists(line, "height")) l[? "height"] = line.height;
        ds_list_add(nq[? "page2"], l);
      }
      
      // add to quests + quest ref 
      ds_list_add(global.QUESTS[? "default"], nq);
      if (global.MOD_QUEST_REFERENCE[? quest.id] == undefined) {
        global.MOD_QUEST_REFERENCE[? quest.id] = nq;
      }
      if (global.QUEST_REFERENCE[? quest.id] == undefined) {
        global.QUEST_REFERENCE[? quest.id] = nq;
      }
      global.MOD_CUSTOM_QUESTS = true;
      ds_list_add(global.MOD_CUSTOM_QUEST_CHECK, nq);
      
      if (claim_script != undefined) {
        global.MOD_QUEST_SCRIPTS[$ quest.id] = {
          state: lua_current,
          script: claim_script
        }
      }
      
      return "Success";
      
    }
  
  // would get called if bad datatypes
  } catch(ex) {
    sc_mod_log(mod_name, "api_define_quest", "Error: Failed To Define Quest", ex.longMessage);
    return undefined;
  }
  
}


// api_define_flower()
// defines a new flower obj, flower item, seed item, and seedling obj, plus adds to flower book
function sc_mod_api_define_flower(flower, flower_sprite_image, flower_variants_image, flower_seed_image, flower_hd_image, flower_color) {
  
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  
  try {
    
    // check required
    var req = ["id", "species", "title", "latin", "hint", "desc", "aquatic"];
    for (var r = 0; r < array_length(req); r++) {
      if (!variable_struct_exists(flower, req[r])) {
        sc_mod_log(mod_name, "api_define_flower", "Error: Missing Required Key (" + req[r] + ")", undefined);
        return undefined;
      }
    }
    
    // no mod name for flower
    var flower_id = "flower" + flower.id;
    
    // check unique
    if (global.FLOWERS[? flower.id] != undefined || global.DICTIONARY[? flower_id] != undefined || global.QUEST_PROGRESS[? flower.species] != undefined) {
      sc_mod_log(mod_name, "api_define_flower", "Error: Flower With This ID Exists", undefined);
      return undefined;
    } else {
      
      // define a flower item
      var item_def = {};
      item_def.id = flower_id;
      item_def.name = flower.species;
      item_def.category = global.DICTIONARY[? "flower1"][? "category"];
      item_def.tooltip = global.DICTIONARY[? "flower1"][? "tooltip"];
      item_def.shop_key = false;
      item_def.shop_buy = variable_struct_exists(flower, "shop_buy") ? flower.shop_buy : 0;
      item_def.shop_sell = variable_struct_exists(flower, "shop_sell") ? flower.shop_sell : 0;
      item_def.machines = variable_struct_exists(flower, "machines") ? flower.machines : ["workbench", "pot1", "smoker"];
      item_def.tools = variable_struct_exists(flower, "tools") ? flower.tools : ["mouse1"];
      item_def.placeable = true;
      item_def.pickable = true;
      item_def.place_grass = true;
      item_def.variants = variable_struct_exists(flower, "variants") ? flower.variants : 1;
      item_def.chance = variable_struct_exists(flower, "chance") ? flower.chance : 100;
      item_def.drops = [flower_id + " 1"];
      item_def.obj = flower_id;
      if (flower.aquatic == true) item_def.place_water = flower.aquatic;
      if (variable_struct_exists(flower, "deep")) item_def.place_deep = flower.deep;
      if (variable_struct_exists(flower, "has_lighting")) item_def.has_lighting = flower.has_lighting;
      var obj_create = sc_mod_api_define_object(item_def, flower_sprite_image, undefined, "flower");
      
      // define a seed item
      var seed_def = {};
      seed_def.id = "seed" + flower.id;
      seed_def.name = flower.species + " Seeds";
      seed_def.category = global.DICTIONARY[? "seed1"][? "category"];
      seed_def.tooltip = global.DICTIONARY[? "seed1"][? "tooltip"];
      var cost = ds_map_create();
      cost[? "key"] = false;
      cost[? "buy"] = 1;
      cost[? "sell"] = 0;
      ds_map_add_map(seed_def, "cost", cost);
      seed_def.tools = [];
      seed_def.machines = [];
      seed_def.placeable = true;
      if (flower.aquatic == false) seed_def.nature = true;
      if (flower.aquatic == true) seed_def.place_water = true;
      if (flower.deep == true) seed_def.place_deep = true;
      seed_def.obj = "seedling" + flower.id;
      var seed_create = sc_mod_api_define_item(seed_def, flower_seed_image, "seed");
      
      // define a seedling definition
      var seedling_def = {};
      seedling_def.id = "seedling" + flower.id;
      seedling_def.name = flower.species + " Seedling";
      seedling_def.category = global.DICTIONARY[? "seedling1"][? "category"];
      seedling_def.tooltip = global.DICTIONARY[? "seedling1"][? "tooltip"];
      seedling_def.growth = "flower" + flower.id + " 240 480";
      seedling_def.variants = 8;
      seedling_def.chance = 100;
      seedling_def.shop_key = false;
      seedling_def.shop_buy = 0;
      seedling_def.shop_sell = 0;
      seedling_def.tools = ["mouse1", "spade1"];
      seedling_def.machines = [];
      seedling_def.drops = ["seed" + flower.id + " 1"];
      seedling_def.placeable = false;
      var seedling_create = sc_mod_api_define_object(seedling_def, undefined, undefined, "seedling");
      
      // check all 3 worked first
      if (obj_create == undefined || seed_create == undefined || seedling_create == undefined) {
        var e_type = "obj";
        if (seed_create == undefined) e_type = "seed";
        if (seedling_create == undefined) e_type = "seedling";
        sc_mod_log(mod_name, "api_define_flower", "Error: Flower Item Creation Failed (" + e_type + ")", undefined);
        return undefined;
      } else {
        
        // setup flower definition for the book
        var nf = ds_map_create();
        nf[? "id"] = flower.id;
        nf[? "species"] = flower.species;
        nf[? "title"] = flower.title;
        nf[? "latin"] = flower.latin;
        nf[? "hint"] = ds_list_create();
        var hint = ds_map_create();
        hint[? "color"] = "FONT_BOOK";
        hint[? "text"] = flower.hint;
        ds_list_add(nf[? "hint"], hint);
        nf[? "desc"] = ds_list_create();
        var desc = ds_map_create();
        desc[? "color"] = "FONT_BOOK";
        desc[? "text"] = flower.desc;
        ds_list_add(nf[? "desc"], desc);
        nf[? "aquatic"] = flower.aquatic;
        nf[? "effect"] = variable_struct_exists(flower, "effect") ? flower.effect : "No special effect";
        nf[? "effect_desc"] = ds_list_create();
        var effect_desc = ds_map_create();
        effect_desc[? "color"] = "FONT_BOOK";
        effect_desc[? "text"] = variable_struct_exists(flower, "effect_desc") ? flower.effect_desc : global.FLOWERS[? "1"][? "effect_desc"][| 0][? "text"];
        ds_list_add(nf[? "effect_desc"], effect_desc);
        nf[? "recipes"] = ds_list_create();
        if (variable_struct_exists(flower, "recipes")) {
          for (var r = 0; r < array_length(flower.recipes); r++) {
            var rmap = ds_map_create();
            rmap[? "a"] = flower.recipes[r].a;
            rmap[? "b"] = flower.recipes[r].b;
            rmap[? "s"] = flower.recipes[r].s;
            ds_list_add(nf[? "recipes"], rmap);
          }
        }
        nf[? "smoker"] = ds_list_create();
        if (variable_struct_exists(flower, "smoker")) {
          for (var r = 0; r < array_length(flower.smoker); r++) {
            ds_list_add(nf[? "smoker"], flower.smoker[r]);
          }
        }
        nf[? "tier"] = 4;
        
        // add flower item
        var fspr = sprite_add(working_directory + "mods/" + mod_name + "/" + flower_sprite_image, 4, true, false, 0, 0);
        global.MOD_SPRITES[? "sp_" + flower_id + "_item"] = fspr;
        global.SPRITE_REFERENCE[? "sp_" + flower_id + "_item"] = fspr;
        
        // add flower variants
        var vspr = sprite_add(working_directory + "mods/" + mod_name + "/" + flower_variants_image, item_def.variants*2, true, false, 0, 0);
        global.MOD_SPRITES[? "sp_" + flower_id] = vspr;
        global.SPRITE_REFERENCE[? "sp_" + flower_id] = vspr;
        
        // add big flower sprite
        var hspr = sprite_add(working_directory + "mods/" + mod_name + "/" + flower_hd_image, 2, true, false, 0, 0);
        global.MOD_SPRITES[? "sp_" + flower_id + "_hd"] = hspr;
        global.SPRITE_REFERENCE[? "sp_" + flower_id + "_hd"] = hspr;
        
        // check both sprites were loaded
        if (vspr == -1 || hspr == -1) {
          sc_mod_log(mod_name, "api_define_flower", "Error: Flower Sprites Not Found", undefined);
          return undefined;  
        } else {
        
          // add to flower list
          global.MOD_CUSTOM_FLOWERS = true;
          global.FLOWERS[? flower.id] = nf;
          global.COLORS[? string_upper(flower_id)] = make_color_rgb(flower_color.r, flower_color.g, flower_color.b);
          ds_list_add(global.FLOWERS[? "_species"], flower.id);
          return "Success";
          
        }
        
      }      
      
    }
    
  // datatype mismatch, probably
  } catch(ex) {
    sc_mod_log(mod_name, "api_define_flower", "Error: Failed To Map Keys", ex.longMessage);
    return undefined;
  }
  
}


// api_define_bee()
// defines a new bee and adds to the book
function sc_mod_api_define_bee(bee, bee_sprite_image, bee_shiny_image, bee_hd_image, bee_color, bee_mag_image, bee_mag_headline, bee_mag_body) {
  
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  
  try {
    
    // check required keys
    var req = ["id", "title", "latin", "hint", "desc", "lifespan", "productivity", "fertility", "stability", "behaviour", "climate",
      "rainlover", "snowlover", "grumpy", "produce", "chance", "requirement", "bid"];
    for (var r = 0; r < array_length(req); r++) {
      if (!variable_struct_exists(bee, req[r])) {
        sc_mod_log(mod_name, "api_define_bee", "Error: Missing Required Key (" + req[r] + ")", undefined);
        return undefined;
      }
    }
    
    // bee id doesnt have mod name 
    var bee_id = bee.id;
    
    // check valid BID
    var is_num = false;
    try {
      real(bee.bid);
      is_num = true;
    } catch(ex) {
      is_num = false;  
    }
    
    // handle unique + bid
    if (global.BEES[? bee_id] != undefined) {
      sc_mod_log(mod_name, "api_define_bee", "Error: Bee With This ID Exists", undefined);
      return undefined;
    } else if (global.DICTIONARY[? bee.produce] == undefined) {
      sc_mod_log(mod_name, "api_define_bee", "Error: Bee Produce Item Not Defined", undefined);
      return undefined;
    } else if (is_num == true) {
      sc_mod_log(mod_name, "api_define_bee", "Error: BID Chars Cannot Both Be Numeric", undefined);
      return undefined;
    } else {
  
      // create bee definition
      var nf = ds_map_create();
      nf[? "id"] = bee_id;
      nf[? "species"] = bee_id;
      nf[? "title"] = bee.title;
      nf[? "latin"] = bee.latin;
      nf[? "hint"] = ds_list_create();
      var hint = ds_map_create();
      hint[? "color"] = "FONT_BOOK";
      hint[? "text"] = bee.hint;
      ds_list_add(nf[? "hint"], hint);
      nf[? "desc"] = ds_list_create();
      var desc = ds_map_create();
      desc[? "color"] = "FONT_BOOK";
      desc[? "text"] = bee.desc;
      ds_list_add(nf[? "desc"], desc);
      nf[? "lifespan"] = ds_list_create();
      for (var i = 0; i < array_length(bee.lifespan); i++) { ds_list_add(nf[? "lifespan"], bee.lifespan[i]); }
      nf[? "productivity"] = ds_list_create();
      for (var i = 0; i < array_length(bee.productivity); i++) { ds_list_add(nf[? "productivity"], bee.productivity[i]); }
      nf[? "fertility"] = ds_list_create();
      for (var i = 0; i < array_length(bee.fertility); i++) { ds_list_add(nf[? "fertility"], bee.fertility[i]); }
      nf[? "stability"] = ds_list_create();
      for (var i = 0; i < array_length(bee.stability); i++) { ds_list_add(nf[? "stability"], bee.stability[i]); }
      nf[? "behaviour"] = ds_list_create();
      for (var i = 0; i < array_length(bee.behaviour); i++) { ds_list_add(nf[? "behaviour"], bee.behaviour[i]); }
      nf[? "climate"] = ds_list_create();
      for (var i = 0; i < array_length(bee.climate); i++) { ds_list_add(nf[? "climate"], bee.climate[i]); }
      nf[? "pluviophile"] = bee.rainlover;
      nf[? "chionophile"] = bee.snowlover;
      nf[? "aggressive"] = bee.grumpy;
      nf[? "product"] = bee.produce;
      nf[? "recipes"] = ds_list_create();
      if (variable_struct_exists(bee, "recipes")) {
        for (var r = 0; r < array_length(bee.recipes); r++) {
          var rmap = ds_map_create();
          rmap[? "a"] = bee.recipes[r].a;
          rmap[? "b"] = bee.recipes[r].b;
          rmap[? "s"] = bee.recipes[r].s;
          ds_list_add(nf[? "recipes"], rmap);
        }
      }
      nf[? "calming"] = ds_list_create();
      if (variable_struct_exists(bee, "calming")) {
        for (var r = 0; r < array_length(bee.calming); r++) {
          ds_list_add(nf[? "calming"], bee.calming[r]);
        }
      }
      nf[? "chance"] = bee.chance;
      nf[? "requirement"] = bee.requirement;
      nf[? "solitary"] = false;
      
      var insert_index = 0;
      
      // check tier preference and try our darn best
      var tiers = sc_tier_count("_species");
      if (variable_struct_exists(bee, "tier")) {
        var tier = bee.tier;
        if (tier == 1 && tiers.t1 >= 6) tier = 2;
        if (tier == 2 && tiers.t2 >= 12) tier = 3;
        if (tier == 3 && tiers.t3 >= 30) tier = 4;
        if (tier == 4 && tiers.t4 >= 12) tier = 5;
        switch(tier) {
          case 1: insert_index = tiers.t1i; break;
          case 2: insert_index = tiers.t2i; break;
          case 3: insert_index = tiers.t3i; break;
          case 4: insert_index = tiers.t4i; break;
          case 5: insert_index = tiers.t5i - 1; break; // account for glitched
        }
        nf[? "tier"] = tier;
      } else {
        var insert_index = tiers.t5i - 1; // account for glitched
        nf[? "tier"] = 5;
      }
      
      nf[? "bid"] = bee.bid;
      
      // set default progress vals
      var defo = ds_map_create();
      defo[? "discovered"] = false;
      defo[? "microscoped"] = 0;
      defo[? "status"] = 0;
      nf[? "def"] = defo;
      
      // bee name for sprites
      var bn = "sp_bee_" + bee.id;
      
      // add normal bee
      var spr = sprite_add(working_directory + "mods/" + mod_name + "/" + bee_sprite_image, 4, true, false, 0, 0);
      global.MOD_SPRITES[? bn] = spr;
      global.SPRITE_REFERENCE[? bn] = spr;
        
      // add bee shiny
      var vspr = sprite_add(working_directory + "mods/" + mod_name + "/" + bee_shiny_image, 20, true, false, 0, 0);
      global.MOD_SPRITES[? bn + "_shiny"] = vspr;
      global.SPRITE_REFERENCE[? bn + "_shiny"] = vspr;
        
      // add big bee
      var hspr = sprite_add(working_directory + "mods/" + mod_name + "/" + bee_hd_image, 2, true, false, 0, 0);
      global.MOD_SPRITES[? bn + "_hd"] = hspr;
      global.SPRITE_REFERENCE[? bn + "_hd"] = hspr;
      
      // add bee magazine
      var mspr = sprite_add(working_directory + "mods/" + mod_name + "/" + bee_mag_image, 2, true, false, 0, 0);
      global.MOD_SPRITES[? "sp_magazine_" + bee.id] = mspr;
      global.SPRITE_REFERENCE[? "sp_magazine_" + bee.id] = mspr;
      
      // add mag item
      var mag_def = ds_map_create();
      mag_def[? "name"] = string_replace(global.DICTIONARY[? "magazine_common"][? "name"], " 1", "") + " " + bee.bid;
      mag_def[? "category"] = global.DICTIONARY[? "magazine_common"][? "category"];
      mag_def[? "tooltip"] = global.DICTIONARY[? "magazine_uncommon"][? "tooltip"];
      var cost = ds_map_create();
      cost[? "key"] = true;
      cost[? "buy"] = 0;
      cost[? "sell"] = 0;
      ds_map_add_map(mag_def, "cost", cost);
      ds_map_add_list(mag_def, "tools", ds_list_create());
      ds_map_add_list(mag_def, "machines", ds_list_create());
      mag_def[? "placeable"] = false;
      mag_def[? "singular"] = true;
      
      // check sprites loaded
      if (spr == -1 || vspr == -1 || hspr == -1) {
        sc_mod_log(mod_name, "api_define_bee", "Error: Bee Sprites Not Found", undefined);
        return undefined;
      } else {
      
        // add mag
        ds_map_add(global.DIALOGUE[? "magazine"], bee.id, ds_list_create());
        ds_list_add(global.DIALOGUE[? "magazine"][? bee.id], bee_mag_headline);
        ds_list_add(global.DIALOGUE[? "magazine"][? bee.id], bee_mag_body);
        global.DICTIONARY[? "magazine_" + bee.id] = mag_def;
      
        // add references
        global.MOD_CUSTOM_BEES = true;
        global.BEES[? bee.id] = nf;
        global.MOD_BEES[? bee.id] = true;
        global.MOD_BIDS[? bee.bid] = bee.id;
        global.MODDED_BEES[$ mod_name][$ bee.id] = json_parse(json_encode(nf));
        global.COLORS[? "BEE_" + string_upper(bee.id)] = make_color_rgb(bee_color.r, bee_color.g, bee_color.b);
        
        if (insert_index == 0) {
          ds_list_add(global.BEES[? "_species"], bee.id);
        } else {
          ds_list_insert(global.BEES[? "_species"], insert_index+1, bee.id); 
        }
        
        return "Success";
        
      }
      
    }
      
  // bad datatypes passed in dictionary
  } catch(ex) {
    sc_mod_log(mod_name, "api_define_bee", "Error: Failed To Map Keys", ex.longMessage);
    return undefined;      
  }
  
}


// api_define_property() or api_dp()
// define a new property on a menu object
function sc_mod_api_define_property(menu_id, prop_name, prop_val) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  if (menu_id != undefined && instance_exists(menu_id)) {
    variable_instance_set(menu_id, prop_name, prop_val);
    return "Success";
  } else {
    sc_mod_log(mod_name, "api_define_property", "Error: Instance Doesn't Exist", undefined);
    return undefined;  
  }
}


// api_define_menu_object()
// define a new menu object
function sc_mod_api_define_menu_object(obj, sprite_image, menu_image, scripts, draw_script) {

  var mod_name = global.MOD_STATE_IDS[? lua_current];
  
  try {
    
    sc_mod_log("MOD_API", "WARNING!", "api_define_menu_object() has been deprecated in favor of api_define_menu_object2(), you should upgrade when you can!", undefined);
    
    // check reqs
    var req = ["id", "name", "category", "tooltip", "layout", "info", "buttons"];
    for (var r = 0; r < array_length(req); r++) {
      if (variable_struct_exists(obj, req[r]) == false) {
        sc_mod_log(mod_name, "api_define_menu_object", "Error: Missing Required Key (" + req[r] + ")", undefined);
        return undefined;
      }
    }
    
    // make unique name for obj
    var obj_id = mod_name + "_" + obj.id;
    
    // check unique
    if (global.DICTIONARY[? obj_id] != undefined) {
      sc_mod_log(mod_name, "api_define_menu_object", "Error: ID Already Defined (" + obj_id + ")", undefined);
      return undefined;
    }
    
    // create menu obj dictionary definition
    var def = ds_map_create();
    def[? "id"] = obj_id;
    def[? "name"] = obj.name;
    def[? "category"] = obj.category;
    def[? "tooltip"] = obj.tooltip;
    var cost = ds_map_create();
    if (variable_struct_exists(obj, "shop_key") == true) cost[? "key"] = obj.shop_key;
    cost[? "buy"] = variable_struct_exists(obj, "shop_buy") ? obj.shop_buy : 0;
    cost[? "sell"] = variable_struct_exists(obj, "shop_sell") ? obj.shop_sell : 0;
    ds_map_add_map(def, "cost", cost);
    def[? "menu"] = true;
    def[? "layout"] = ds_list_create();   // gotta love converting datatypes eh?
    if (variable_struct_exists(obj, "layout")) {
      for (var a = 0; a < array_length(obj.layout); a++) {
        var row = obj.layout[a];
        var lrow = ds_list_create();
        for (var r = 0; r < array_length(row); r++) {
          if (r == 3) {
            var allowed = ds_list_create();
            for (var i = 0; i < array_length(row[r]); i++) {
              ds_list_add(allowed, row[r][i]);
            }
            ds_list_add(lrow, allowed);
          } else {
            ds_list_add(lrow, row[r]);
          }
        }
        ds_list_add(def[? "layout"], lrow);
      }
    }
    def[? "buttons"] = ds_list_create();  
    if (variable_struct_exists(obj, "buttons")) {
      for (var a = 0; a < array_length(obj.buttons); a++) {
        ds_list_add(def[? "buttons"], obj.buttons[a]);
      }
    }
    def[? "info"] = ds_list_create();  
    if (variable_struct_exists(obj, "info")) {
      for (var a = 0; a < array_length(obj.info); a++) {
        var row = obj.info[a];
        var lrow = ds_list_create();
        for (var r = 0; r < array_length(row); r++) {
          ds_list_add(lrow, row[r]);
        }
        ds_list_add(def[? "info"], lrow);
      }
    }
    var machines = ds_list_create();  
    if (variable_struct_exists(obj, "machines")) {
      for (var a = 0; a < array_length(obj.machines); a++) {
        ds_list_add(machines, obj.machines[a]);
      }
    }
    ds_map_add_list(def, "machines", machines);
    var tools = ds_list_create();
    if (variable_struct_exists(obj, "tools")) {
      for (var a = 0; a < array_length(obj.tools); a++) {
        ds_list_add(tools, obj.tools[a]);
      }
    }
    ds_map_add_list(def, "tools", tools);
    def[? "placeable"] = true;
    if (variable_struct_exists(obj, "singular")) def[? "singular"] = obj.singular;
    if (def[? "placeable"] == true && variable_struct_exists(obj, "place_grass")) def[? "nature"] = obj.place_grass;
    if (def[? "placeable"] == true && variable_struct_exists(obj, "place_water")) def[? "aquatic"] = obj.place_water;
    if (def[? "placeable"] == true && variable_struct_exists(obj, "place_deep")) def[? "deep"] = obj.place_deep;
    def[? "obj"] = obj_id;
    def[? "modded"] = true; // needed for script calls
    def[? "state"] = lua_current; // needed for script calls
    if (variable_struct_exists(obj, "honeycore")) def[? "honeycore"] = obj.honeycore;
    if (variable_struct_exists(obj, "invisible")) def[? "invisible"] = obj.invisible;
    if (variable_struct_exists(obj, "center")) def[? "center"] = obj.center;
    if (variable_struct_exists(obj, "depth")) def[? "depth"] = obj.depth;
    
    if (variable_struct_exists(obj, "item_sprite")) {
      var ispr = sprite_add(working_directory + "mods/" + mod_name + "/" + obj.item_sprite, 4, true, false, 0, 0);
      if (ispr == -1) {
        sc_mod_log(mod_name, "api_define_menu_object", "Error: Menu Object Sprite Not Found (item_sprite)", undefined);
        return undefined;  
      } else {
        var ispr_name = "sp_" + obj_id + "_item";
        global.MOD_SPRITES[? ispr_name] = ispr
        global.SPRITE_REFERENCE[? ispr_name] = ispr;
      }
    }
    
    // add custom draw script if any
    if (draw_script != undefined) {
      log("adding draw script?", obj_id);
      global.MOD_OBJ_STATES[? obj_id] = lua_current;
      global.MOD_OBJ_SCRIPTS[? obj_id] = draw_script;
    }  
    
    
    try {
      
      // load sprites
      global.DICTIONARY[? obj_id] = def;
      global.MODDED_DICTIONARY[$ mod_name][$ obj_id] = json_parse(json_encode(def));
      
      var spr_name = "sp_" + obj_id;
      var spr = sprite_add(working_directory + "mods/" + mod_name + "/" + sprite_image, 4, true, false, 0, 0);
      var mspr = sprite_add(working_directory + "mods/" + mod_name + "/" + menu_image, 4, true, false, 0, 0);
      
      // check loaded
      if (spr == -1 || mspr == -1) {
        sc_mod_log(mod_name, "api_define_menu_object", "Error: Object Sprite Not Found", undefined);
        return undefined;  
      } else {        
        
        // add references
        global.MOD_SPRITES[? spr_name] = spr;
        global.SPRITE_REFERENCE[? spr_name] = spr;
        global.MOD_SPRITES[? spr_name + "_menu"] = mspr;
        global.SPRITE_REFERENCE[? spr_name + "_menu"] = mspr;
        
        // add script references to call later
        if (variable_struct_exists(scripts, "define")) global.MOD_MENU_DEFINE[? obj_id] = scripts.define;
        if (variable_struct_exists(scripts, "tick")) global.MOD_MENU_TICK[? obj_id] = scripts.tick;
        if (variable_struct_exists(scripts, "change")) global.MOD_MENU_CHANGE[? obj_id] = scripts.change;
        if (variable_struct_exists(scripts, "draw")) global.MOD_MENU_DRAW[? obj_id] = scripts.draw;
        
        return "Success";
      }
    } catch(ex) {
      sc_mod_log(mod_name, "api_define_menu_object", "Error: Failed To Add Sprite", ex.longMessage);
      return undefined;
    }
  
  // bad datatypes in menu definition
  } catch(ex) {
    sc_mod_log(mod_name, "api_define_menu_object", "Error: Failed To Map Keys", ex.longMessage);
    return undefined;
  }

}


// api_define_menu_object()
// define a new menu object
function sc_mod_api_define_menu_object2(obj, sprite_image, menu_image, scripts, draw_script) {

  var mod_name = global.MOD_STATE_IDS[? lua_current];
  
  try {
    
    // check reqs
    var req = ["id", "name", "category", "tooltip", "layout", "info", "buttons"];
    for (var r = 0; r < array_length(req); r++) {
      if (variable_struct_exists(obj, req[r]) == false) {
        sc_mod_log(mod_name, "api_define_menu_object", "Error: Missing Required Key (" + req[r] + ")", undefined);
        return undefined;
      }
    }
    
    // make unique name for obj
    var obj_id = mod_name + "_" + obj.id;
    
    // check unique
    if (global.DICTIONARY[? obj_id] != undefined) {
      sc_mod_log(mod_name, "api_define_menu_object", "Error: ID Already Defined (" + obj_id + ")", undefined);
      return undefined;
    }
    
    // create menu obj dictionary definition
    var def = ds_map_create();
    def[? "id"] = obj_id;
    def[? "title"] = variable_struct_exists(obj, "title") == true ? obj.title : "";
    def[? "name"] = obj.name;
    def[? "category"] = obj.category;
    def[? "tooltip"] = obj.tooltip;
    var cost = ds_map_create();
    if (variable_struct_exists(obj, "shop_key") == true) cost[? "key"] = obj.shop_key;
    cost[? "buy"] = variable_struct_exists(obj, "shop_buy") ? obj.shop_buy : 0;
    cost[? "sell"] = variable_struct_exists(obj, "shop_sell") ? obj.shop_sell : 0;
    ds_map_add_map(def, "cost", cost);
    def[? "menu"] = true;
    def[? "layout"] = ds_list_create();   // gotta love converting datatypes eh?
    if (variable_struct_exists(obj, "layout")) {
      for (var a = 0; a < array_length(obj.layout); a++) {
        var row = obj.layout[a];
        var lrow = ds_list_create();
        for (var r = 0; r < array_length(row); r++) {
          if (r == 3) {
            var allowed = ds_list_create();
            for (var i = 0; i < array_length(row[r]); i++) {
              ds_list_add(allowed, row[r][i]);
            }
            ds_list_add(lrow, allowed);
          } else {
            ds_list_add(lrow, row[r]);
          }
        }
        ds_list_add(def[? "layout"], lrow);
      }
    }
    def[? "buttons"] = ds_list_create();  
    if (variable_struct_exists(obj, "buttons")) {
      for (var a = 0; a < array_length(obj.buttons); a++) {
        ds_list_add(def[? "buttons"], obj.buttons[a]);
      }
    }
    def[? "info"] = ds_list_create();  
    if (variable_struct_exists(obj, "info")) {
      for (var a = 0; a < array_length(obj.info); a++) {
        var row = obj.info[a];
        var lrow = ds_list_create();
        for (var r = 0; r < array_length(row); r++) {
          ds_list_add(lrow, row[r]);
        }
        ds_list_add(def[? "info"], lrow);
      }
    }
    var machines = ds_list_create();  
    if (variable_struct_exists(obj, "machines")) {
      for (var a = 0; a < array_length(obj.machines); a++) {
        ds_list_add(machines, obj.machines[a]);
      }
    }
    ds_map_add_list(def, "machines", machines);
    var tools = ds_list_create();
    if (variable_struct_exists(obj, "tools")) {
      for (var a = 0; a < array_length(obj.tools); a++) {
        ds_list_add(tools, obj.tools[a]);
      }
    }
    ds_map_add_list(def, "tools", tools);
    def[? "placeable"] = true;
    if (variable_struct_exists(obj, "singular")) def[? "singular"] = obj.singular;
    if (def[? "placeable"] == true && variable_struct_exists(obj, "place_grass")) def[? "nature"] = obj.place_grass;
    if (def[? "placeable"] == true && variable_struct_exists(obj, "place_water")) def[? "aquatic"] = obj.place_water;
    if (def[? "placeable"] == true && variable_struct_exists(obj, "place_deep")) def[? "deep"] = obj.place_deep;
    def[? "obj"] = obj_id;
    def[? "modded"] = true; // needed for script calls
    def[? "state"] = lua_current; // needed for script calls
    if (variable_struct_exists(obj, "honeycore")) def[? "honeycore"] = obj.honeycore;
    if (variable_struct_exists(obj, "invisible")) def[? "invisible"] = obj.invisible;
    if (variable_struct_exists(obj, "center")) def[? "center"] = obj.center;
    if (variable_struct_exists(obj, "depth")) def[? "depth"] = obj.depth;
    
    if (variable_struct_exists(obj, "item_sprite")) {
      var ispr = sprite_add(working_directory + "mods/" + mod_name + "/" + obj.item_sprite, 4, true, false, 0, 0);
      if (ispr == -1) {
        sc_mod_log(mod_name, "api_define_menu_object", "Error: Menu Object Sprite Not Found (item_sprite)", undefined);
        return undefined;  
      } else {
        var ispr_name = "sp_" + obj_id + "_item";
        global.MOD_SPRITES[? ispr_name] = ispr
        global.SPRITE_REFERENCE[? ispr_name] = ispr;
      }
    }
    
    // add custom draw script if any
    if (draw_script != undefined) {
      log("adding draw script?", obj_id);
      global.MOD_OBJ_STATES[? obj_id] = lua_current;
      global.MOD_OBJ_SCRIPTS[? obj_id] = draw_script;
    }  
    
    
    try {
      
      // load sprites
      global.DICTIONARY[? obj_id] = def;
      global.MODDED_DICTIONARY[$ mod_name][$ obj_id] = json_parse(json_encode(def));
      
      var spr_name = "sp_" + obj_id;
      var spr = sprite_add(working_directory + "mods/" + mod_name + "/" + sprite_image, 4, true, false, 0, 0);
      var mspr = sprite_add(working_directory + "mods/" + mod_name + "/" + menu_image, 2, true, false, 0, 0);
      
      // check loaded
      if (spr == -1 || mspr == -1) {
        sc_mod_log(mod_name, "api_define_menu_object", "Error: Object Sprite Not Found", undefined);
        return undefined;  
      } else {        
        
        // add references
        global.MOD_SPRITES[? spr_name] = spr;
        global.SPRITE_REFERENCE[? spr_name] = spr;
        global.MOD_SPRITES[? spr_name + "_menu"] = mspr;
        global.SPRITE_REFERENCE[? spr_name + "_menu"] = mspr;
        
        // add script references to call later
        if (variable_struct_exists(scripts, "define")) global.MOD_MENU_DEFINE[? obj_id] = scripts.define;
        if (variable_struct_exists(scripts, "tick")) global.MOD_MENU_TICK[? obj_id] = scripts.tick;
        if (variable_struct_exists(scripts, "change")) global.MOD_MENU_CHANGE[? obj_id] = scripts.change;
        if (variable_struct_exists(scripts, "draw")) global.MOD_MENU_DRAW[? obj_id] = scripts.draw;
        
        return "Success";
      }
    } catch(ex) {
      sc_mod_log(mod_name, "api_define_menu_object", "Error: Failed To Add Sprite", ex.longMessage);
      return undefined;
    }
  
  // bad datatypes in menu definition
  } catch(ex) {
    sc_mod_log(mod_name, "api_define_menu_object", "Error: Failed To Map Keys", ex.longMessage);
    return undefined;
  }

}


// api_define_button()
// defines a new button for a given menu, with custom button script
function sc_mod_api_define_button(menu_id, button_key, button_ox, button_oy, button_text, button_script, sprite_image) {
  
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  
  // check valid menu inst
  if (menu_id != undefined && instance_exists(menu_id) && menu_id.object_index == ob_menu) {
    
    // try loading sprite
    var spr = sprite_add(working_directory + "mods/" + mod_name + "/" + sprite_image, 2, true, false, 0, 0);
    if (spr == -1) {
      sc_mod_log(mod_name, "api_define_menu_button", "Error: Button Sprite Not Found", undefined);
      return undefined;  
    } else {
      
      // add sprite ref
      var spr_name = mod_name + "_" + button_key;
      global.MOD_SPRITES[? spr_name] = spr;
      global.SPRITE_REFERENCE[? spr_name] = spr;
        
      // create button and add to menu
      var gui = instance_create_layer(menu_id.x + button_ox, menu_id.y + button_oy, "Menus", ob_button);
      gui.sprite_index = spr;
      gui.ox = button_ox;
      gui.oy = button_oy;
      gui.type = "MODDED";
      gui.text = button_text;
      gui.script_click = button_script;
      gui.modded = true;
      gui.menu = menu_id;
      array_push(menu_id.automove, gui);
      variable_instance_set(menu_id, button_key, gui);
      return "Success";
      
    }
    
  } else {
    sc_mod_log(mod_name, "api_define_menu_button", "Error: Menu Instance Not Found", undefined);
    return undefined;    
  }

}


// api_define_gui()
// define a generic gui and add it to a menu, with click script
function sc_mod_api_define_gui(menu_id, gui_key, gui_ox, gui_oy, gui_script, sprite_image, gui_click) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  
  // check valid menu inst
  if (menu_id != undefined && instance_exists(menu_id) && menu_id.object_index == ob_menu) {
    
    // handle multiple gui defines on multiple objs
    var spr_name = "sp_" + mod_name + "_" + gui_key;
    var spr = global.MOD_SPRITES[? spr_name];
    
    if (global.MOD_SPRITES[? spr_name] == undefined) {
      spr = sprite_add(working_directory + "mods/" + mod_name + "/" + sprite_image, 3, true, false, 0, 0);
    }
    
    log(spr_name, spr, global.MOD_SPRITES[? spr_name]);
    
    // try load sprite
    if (spr == -1) {
      sc_mod_log(mod_name, "api_define_menu_gui", "Error: GUI Sprite Not Found", undefined);
      return undefined;  
    } else {
      
      // add sprite reference
      global.MOD_SPRITES[? spr_name] = spr;
      global.SPRITE_REFERENCE[? spr_name] = spr;
        
      // create gui inst and add it to menu
      var gui = instance_create_layer(menu_id.x + gui_ox, menu_id.y + gui_oy, "Menus", ob_gui);
      gui.sprite_index = spr;
      gui.ox = gui_ox;
      gui.oy = gui_oy;
      gui.type = "MODDED";
      gui.script_tooltip = gui_script;
      if (gui_click != undefined) {
        gui.state = lua_current;
        gui.script_click = gui_click;
      }
      gui.modded = true;
      gui.menu = menu_id;
      array_push(menu_id.automove, gui);
      variable_instance_set(menu_id, gui_key, gui);
      return "Success";
      
    }
    
  } else {
    sc_mod_log(mod_name, "api_define_menu_gui", "Error: Menu Instance Not Found", undefined);
    return undefined;    
  }
}


// api_define_notification()
// define a new notification type with custom dismiss script
function sc_mod_api_define_notification(notification_type, notification_script) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  var notification_name = mod_name + "_" + notification_type;
  if (!variable_struct_exists(global.NOTIFICATION_MAP, notification_name)) {
    variable_struct_set(global.NOTIFICATION_MAP, notification_name, undefined);
    global.MOD_NOTIF_SCRIPTS[? notification_name] = notification_script;
    global.MOD_NOTIF_STATES[? notification_name] = lua_current;
    return "Success";
  } else {
    sc_mod_log(mod_name, "api_define_notification", "Error: Notification Type Already Defined", undefined);
    return undefined;    
  }
}


// api_define_trait()
// define a new trait used by all bee species
function sc_mod_api_define_trait(trait_key, trait_map, default_value) {
  
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  
  try {
    
    // make name custom
    var trait_name = mod_name + "_" + trait_key;
    
    // check unique
    var existing = false;
    for (var t = 0; t < array_length(global.BEE_TRAITS); t++) {
      if (global.BEE_TRAITS[t] == trait_name) {
        existing = true;
        break;
      }
    }
    if (existing == true) {
      sc_mod_log(mod_name, "api_define_trait", "Error: Trait Already Defined", undefined);
      return undefined;
    } else {
      
      // go through each bee species
      for (var s = 0; s < ds_list_size(global.BEES[? "_species"]); s++) {
      
        // add mapping for each species or use default if none
        var species = global.BEES[? "_species"][| s];
        var val = ds_list_create();
        var match = variable_struct_exists(trait_map, species);
        if (match == false) {
          for (var v = 0; v < array_length(default_value); v++) {
            ds_list_add(val, default_value[v]);
          }
        } else {
          var vals = variable_struct_get(trait_map, species);
          for (var v = 0; v < array_length(vals); v++) {
            ds_list_add(val, vals[v]);  
          }
        }
        
        // add to bee dictionary
        global.BEES[? species][? trait_name] = val;
      
      }
      
      // actually add the trait to the list
      array_push(global.BEE_TRAITS, trait_name);
      return "Success";
      
    }
    
  // not sure why would be called, bad data probably
  } catch(ex) {
    sc_mod_log(mod_name, "api_define_trait", "Error: Trait Couldn't Be Defined", ex.longMessage);
    return undefined;
  }

}


// api_define_tank()
// defines a tank type gui and adds it to the given menu
function sc_mod_api_define_tank(menu_id, gui_amount, gui_max, gui_type, gui_ox, gui_oy, tank_size, gui_click) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  
  // check valid menu inst
  if (menu_id != undefined && instance_exists(menu_id) && menu_id.object_index == ob_menu) {
    
    // set sprite based on size
    var spr = sp_gui_tank1;
    if (tank_size == "medium") spr = sp_gui_tank2;
    if (tank_size == "large") spr = sp_gui_tank3;
    if (tank_size == "xlarge") spr = sp_gui_tank4;
    
    // set menu properties for the tank to use in tank_draw, slot_fill, and slot_drain
    variable_instance_set(menu_id, "tank_type", gui_type);
    variable_instance_set(menu_id, "tank_amount", gui_amount);
    variable_instance_set(menu_id, "tank_max", gui_max);
        
    // create the gui and add to the menu
    var gui = instance_create_layer(menu_id.x + gui_ox, menu_id.y + gui_oy, "Menus", ob_gui);
    gui.sprite_index = spr;
    gui.ox = gui_ox;
    gui.oy = gui_oy;
    gui.type = "tank";
    if (gui_click != undefined) {
      gui.state = lua_current;
      gui.script_click = gui_click;
    }
    gui.modded = true;
    gui.menu = menu_id;
    array_push(menu_id.automove, gui);
    variable_instance_set(menu_id, "tank_gui", gui);
    return "Success";
    
  } else {
    sc_mod_log(mod_name, "api_define_menu_gui", "Error: Menu Instance Not Found", undefined);
    return undefined;    
  }
}


// define_bee_recipe()
// defines a new bee hybrid recipe and mutation chance script
function sc_mod_api_define_bee_recipe(species_a, species_b, species_s, mutation_script) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  
  // check all given species exist
  if (global.BEES[? species_a] != undefined && global.BEES[? species_b] != undefined && global.BEES[? species_s] != undefined) {
  
    // get current recipes and check there is space
    var recipes_a = global.BEES[? species_a][? "recipes"];
    var recipes_b = global.BEES[? species_b][? "recipes"];
    if (ds_list_size(recipes_a) < 3 && ds_list_size(recipes_b) < 3) {
    
      // create new recipe
      var recipe = ds_map_create();
      recipe[? "a"] = species_a;
      recipe[? "b"] = species_b;
      recipe[? "s"] = species_s;
      
      // add to both species
      ds_list_add(recipes_a, recipe);
      ds_list_add(recipes_b, recipe);
      
      // add mutation script reference
      global.MOD_MUTATIONS[? species_a + "-" + species_b] = {
        state: lua_current,
        script: mutation_script
      }
      global.MOD_MUTATIONS[? species_b + "-" + species_a] = {
        state: lua_current,
        script: mutation_script
      }
      
      return "Success";
      
    } else {
      var spec = species_a;
      if (ds_list_size(recipes_b) >= 3) spec = species_b;
      sc_mod_log(mod_name, "api_define_bee_recipe", "Error: Bee/s Already Has 3 Recipes (" + spec + ")", undefined);
      return undefined;
    }
  
  } else {
    var spec = species_a;
    if (global.BEES[? species_b] == undefined) spec = species_b;
    if (global.BEES[? species_s] == undefined) spec = species_s;
    sc_mod_log(mod_name, "api_define_bee_recipe", "Error: Species Given Are Not Defined (" + spec + ")", undefined);
    return undefined;
  }
  
}


// api_define_command()
// adds new command for the in-line console
function sc_mod_api_define_command(name, run_script) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  
  // check unique
  if (global.MOD_COMMANDS[? name] == undefined) {
    global.MOD_COMMANDS[? name] = {
      state: lua_current,
      script: run_script
    }
    
    array_push(global.MODDED_COMMANDS[$ mod_name], name);
    
    log("defined", name, run_script);
    
    return "Success";
  } else {
    sc_mod_log(mod_name, "api_define_command", "Error: Command With That Name Already Exists", undefined);
    return undefined;
  }
  
}


// api_define_flower_recipe()
// defines a new flower hybrid recipe
function sc_mod_api_define_flower_recipe(species_a, species_b, species_s) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  
  // check all 3 flowers are defined
  var def_a = string_replace(species_a, "flower", "");
  var def_b = string_replace(species_b, "flower", "");
  var def_s = string_replace(species_s, "flower", "");
  if (global.FLOWERS[? def_a] != undefined && global.FLOWERS[? def_b] != undefined && global.FLOWERS[? def_s] != undefined) {
  
    // check space on both flowers
    var recipes_a = global.FLOWERS[? def_a][? "recipes"];
    var recipes_b = global.FLOWERS[? def_b][? "recipes"];
    if (ds_list_size(recipes_a) < 3 && ds_list_size(recipes_b) < 3) {
    
      // create recipe
      var recipe = ds_map_create();
      recipe[? "a"] = species_a;
      recipe[? "b"] = species_b;
      recipe[? "s"] = species_s;
      
      // add to both flowers
      ds_list_add(recipes_a, recipe);
      ds_list_add(recipes_b, recipe);
      
      log("FLOWERS", json_encode(global.FLOWERS[? def_a][? "recipes"]));
      
      return "Success";
    
    } else {
      sc_mod_log(mod_name, "api_define_bee_recipe", "Error: Flower/s Already Has 3 Recipes", undefined);
      return undefined;
    }
  
  
  } else {
    sc_mod_log(mod_name, "api_define_bee_recipe", "Error: Species Given Are Not Defined", undefined);
    return undefined;
  }
  
}


// api_define_npc()
// define a new npc along with dialogue and shop stock
function sc_mod_api_define_npc(npc, standing_sprite, standing_sprite_h, walking_sprite, walking_sprite_h, head_sprite, bust_sprite, item_sprite, dialogue_menu_sprite, shop_menu_sprite) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  
  try {
    
    sc_mod_log("MOD_API", "WARNING!", "api_define_npc() has been deprecated in favor of api_define_npc2(), you should upgrade when you can!", undefined);
  
    // required
    var req = ["id", "name", "pronouns", "tooltip", "stock", "greeting", "dialogue", "specials"];
    for (var r = 0; r < array_length(req); r++) {
      if (!variable_struct_exists(npc, req[r])) {
        sc_mod_log(mod_name, "api_define_menu_npc", "Error: Missing Required Key (" + req[r] + ")", undefined);
        return undefined;
      }
    }
    
    // valid npc id
    var num = false;
    try {
      real(npc.id);
      num = true;
    } catch(ex) {
      num = false;
    }
    if (num == false) {
      sc_mod_log(mod_name, "api_define_menu_npc", "Error: NPC ID Must Be A Number", undefined);
      return undefined;  
    }
    
    var npc_id = "npc" + string(npc.id);
    if (global.DICTIONARY[? npc_id] != undefined || global.MOD_NPCS[? npc_id] != undefined) {
      sc_mod_log(mod_name, "api_define_menu_npc", "Error: NPC With This ID Already Defined", undefined);
      return undefined;  
    }
    
    // need 3 speciasl
    if (array_length(npc.specials) < 3) {
      sc_mod_log(mod_name, "api_define_menu_npc", "Error: Need To Specify At Least 3 Specials", undefined);
      return undefined;  
    }
    
    // try making the objs we need
    var nn = ds_map_create();
    var ns = undefined;
    
    var has_shop = variable_struct_exists(npc, "shop") == true && npc.shop == true;
    var has_walk = variable_struct_exists(npc, "walking") == true && npc.walking == true;
    
    // create npc definition
    nn[? "name"] = npc.name;
    nn[? "category"] = global.DICTIONARY[? "npc1"][? "category"];
    nn[? "tooltip"] = npc.tooltip;
    nn[? "tooltip_item"] = global.DICTIONARY[? "npc1"][? "tooltip_item"];
    nn[? "menu"] = true;
    nn[? "layout"] = ds_list_create();
    nn[? "buttons"] = ds_list_create();
    nn[? "info"] = ds_list_create();
    nn[? "tools"] = ds_list_create();
    ds_list_add(nn[? "tools"], "mouse1");
    ds_list_add(nn[? "tools"], "hammer1");
    ds_map_add_list(nn, "machines", ds_list_create());
    nn[? "placeable"] = true;
    nn[? "singular"] = true;
    if (variable_struct_exists(npc, "shop")) nn[? "shop"] = npc.shop;
    if (variable_struct_exists(npc, "walking")) nn[? "walking"] = npc.walking;
    var cost = ds_map_create();
    cost[? "key"] = true;
    cost[? "buy"] = 0;
    cost[? "sell"] = 0;
    ds_map_add_map(nn, "cost", cost);
    nn[? "obj"] = npc_id;
    
    // create shop definition
    if (has_shop) {
      ns = ds_map_create();
      ns[? "name"] = npc.name;
      ns[? "category"] = global.DICTIONARY[? "npc1"][? "category"];
      ns[? "tooltip"] = npc.tooltip;
      ns[? "tooltip_item"] = global.DICTIONARY[? "npc1"][? "tooltip_item"];
      ns[? "menu"] = true;
      ns[? "layout"] = ds_list_create();
      var lay = [
      [76, 22, "Buy"],
      [99, 22, "Buy"],
      [7, 63, "Buy"],
      [30, 63, "Buy"],
      [53, 63, "Buy"],
      [76, 63, "Buy"],
      [99, 63, "Buy"],
      [122, 63, "Buy"],
      [7, 86, "Buy"],
      [30, 86, "Buy"],
      [53, 86, "Buy"],
      [76, 86, "Buy"],
      [99, 86, "Buy"],
      [122, 86, "Buy"],
      [7, 112, "Sell"],
      [30, 112, "Sell"],
      [53, 112, "Sell"],
      [76, 112, "Sell"],
      [99, 112, "Sell"],
      [122, 112, "Sell"],
      [7, 135, "Sell"],
      [30, 135, "Sell"],
      [53, 135, "Sell"],
      [76, 135, "Sell"],
      [99, 135, "Sell"],
      [122, 135, "Sell"]
      ];
      for (var l = 0; l < array_length(lay); l++) {
        var row = ds_list_create();
        for (r = 0; r < array_length(lay[l]); r++) {
          ds_list_add(row, lay[l][r]);  
        }
        ds_list_add(ns[? "layout"], row);
      }
      ns[? "buttons"] = ds_list_create();
      ds_list_add(ns[? "buttons"], "Help");
      ds_list_add(ns[? "buttons"], "Move");
      ds_list_add(ns[? "buttons"], "Target");
      ds_list_add(ns[? "buttons"], "Close");
      ns[? "info"] = ds_list_create();
      var row1 = ds_list_create();
      ds_list_add(row1, "1. Item of the Day");
      ds_list_add(row1, "GREEN");
      var row2 = ds_list_create();
      ds_list_add(row2, "2. Items for Sale");
      ds_list_add(row2, "BLUE");
      var row3 = ds_list_create();
      ds_list_add(row3, "3. Items to Sell");
      ds_list_add(row3, "RED");
      ds_list_add(ns[? "info"], row1);
      ds_list_add(ns[? "info"], row2);
      ds_list_add(ns[? "info"], row3);
      
      var tools = ds_list_create();
      ds_list_add(tools, "mouse1");
      ds_list_add(tools, "hammer1");
      ds_map_add_list(ns, "machines", ds_list_create());
      ds_map_add_list(ns, "tools", tools);
      ns[? "placeable"] = true;
      ns[? "singular"] = true;
      ns[? "shop"] = true;
      var cost = ds_map_create();
      cost[? "key"] = true;
      cost[? "buy"] = 0;
      cost[? "sell"] = 0;
      ds_map_add_map(ns, "cost", cost);
      ns[? "obj"] = npc_id;
    }
    
    // add dialogue lines
    var dialogue = [];
    for (var d = 0; d < array_length(npc.dialogue); d++) {
      var line = {
        text: npc.dialogue[d],
        action: d == array_length(npc.dialogue) - 1 ? "$action20" : "$action01"
      }
      array_push(dialogue, line);
    }
    
    // shop menu
    var spr1 = 1;
    if (has_shop == true) {
      spr1 = sprite_add(working_directory + "mods/" + mod_name + "/" + shop_menu_sprite, 4, true, false, 0, 0);
      global.MOD_SPRITES[? "sp_" + npc_id + "s_menu"] = spr1;
      global.SPRITE_REFERENCE[? "sp_" + npc_id + "s_menu"] = spr1;
    }
    
    // dialogue menu
    var spr2 = sprite_add(working_directory + "mods/" + mod_name + "/" + dialogue_menu_sprite, 2, true, false, 0, 0);
    global.MOD_SPRITES[? "sp_" + npc_id + "_menu"] = spr2;
    global.SPRITE_REFERENCE[? "sp_" + npc_id + "_menu"] = spr2;
    
    // item sprite
    var spr3 = sprite_add(working_directory + "mods/" + mod_name + "/" + item_sprite, 2, true, false, 0, 0);
    global.MOD_SPRITES[? "sp_" + npc_id] = spr3;
    global.SPRITE_REFERENCE[? "sp_" + npc_id] = spr3;
    
    // bust sprite
    var spr4 = sprite_add(working_directory + "mods/" + mod_name + "/" + bust_sprite, 2, true, false, 0, 0);
    global.MOD_SPRITES[? "sp_" + npc_id + "_bust"] = spr4;
    global.SPRITE_REFERENCE[? "sp_" + npc_id + "_bust"] = spr4;
    
    // standing
    var spr5 = sprite_add(working_directory + "mods/" + mod_name + "/" + standing_sprite, 2, true, false, 0, 0);
    global.MOD_SPRITES[? "sp_" + npc_id + "_standing"] = spr5;
    global.SPRITE_REFERENCE[? "sp_" + npc_id + "_standing"] = spr5;
    var spr6 = sprite_add(working_directory + "mods/" + mod_name + "/" + standing_sprite_h, 2, true, false, 0, 0);
    global.MOD_SPRITES[? "sp_" + npc_id + "_standing_h"] = spr6;
    global.SPRITE_REFERENCE[? "sp_" + npc_id + "_standing_h"] = spr6;
    
    // walking
    var spr7 = 1;
    var spr8 = 1;
    if (has_walk == true) {
      spr7 = sprite_add(working_directory + "mods/" + mod_name + "/" + walking_sprite, 4, true, false, 0, 0);
      global.MOD_SPRITES[? "sp_" + npc_id + "_walking"] = spr7;
      global.SPRITE_REFERENCE[? "sp_" + npc_id + "_walking"] = spr7;
      spr8 = sprite_add(working_directory + "mods/" + mod_name + "/" + walking_sprite_h, 4, true, false, 0, 0);
      global.MOD_SPRITES[? "sp_" + npc_id + "_walking_h"] = spr8;
      global.SPRITE_REFERENCE[? "sp_" + npc_id + "_walking_h"] = spr8;
    }
    
    var spr9 = sprite_add(working_directory + "mods/" + mod_name + "/" + head_sprite, 1, true, false, 0, 0);
    global.MOD_SPRITES[? "sp_" + npc_id + "_head"] = spr9;
    global.SPRITE_REFERENCE[? "sp_" + npc_id + "_head"] = spr9;
    
    if (spr1 != -1 && spr2 != -1 && spr3 != -1 && spr4 != -1 && spr5 != -1 && spr6 != -1 && spr7 != -1 && spr8 != -1 && spr9 != 1) {

      // offset sprites
      sprite_set_offset(spr5, 8, 0);
      sprite_set_offset(spr6, 8, 0);
      sprite_set_offset(spr7, 8, 0);
      sprite_set_offset(spr8, 8, 0);
      
      // change sprite speed
      sprite_set_speed(spr5, 2, spritespeed_framespersecond);
      sprite_set_speed(spr6, 2, spritespeed_framespersecond);
      sprite_set_speed(spr7, 2, spritespeed_framespersecond);
      sprite_set_speed(spr8, 2, spritespeed_framespersecond);

      // add definitions
      global.DICTIONARY[? npc_id] = nn;
      global.MODDED_DICTIONARY[$ mod_name][$ npc_id] = json_parse(json_encode(nn));
      
      if (has_shop == true) {
        global.DICTIONARY[? npc_id + "s"] = ns;
        global.MODDED_DICTIONARY[$ mod_name][$ npc_id] = json_parse(json_encode(ns));
      }
      
      var new_dialogue = ds_map_create();
      new_dialogue[? "_G"] = npc.greeting;
      var new_line = ds_map_create();
      new_line[? "P"] = "Hello " + npc.name + "!";
      var actual_lines = ds_list_create();
      var actual_actions = ds_list_create();
      for (var d = 0; d < array_length(dialogue); d++) {
        ds_list_add(actual_lines, dialogue[d][$ "text"]);  
        ds_list_add(actual_actions, d < array_length(dialogue)-1 ? "$action01" : "$action49");
      }
      
      ds_map_add_list(new_line, "D", actual_lines);
      ds_map_add_list(new_line, "A", actual_actions);
      ds_map_add_map(new_dialogue, "A", new_line);
      
      global.MOD_NPCS[? npc_id] = {
        name: npc.name,
        shop: variable_struct_exists(npc, "shop") && npc.shop == true,
        pronouns: npc.pronouns,
        stock: npc.stock,
        specials: npc.specials,
        dialogue: dialogue,
        state: global.MOD_STATES[? mod_name],
        check_dialogue: undefined,
        greeting: npc.greeting,
        new_dialogue: new_dialogue
      }
      
      return "Success";
      
    } else {
      var failed_spr = "(";
      if (spr1 == -1) failed_spr += "shop_menu, ";
      if (spr2 == -1) failed_spr += "dialogue_menu, ";
      if (spr3 == -1) failed_spr += "item, ";
      if (spr4 == -1) failed_spr += "bust, ";
      if (spr5 == -1) failed_spr += "standing, ";
      if (spr6 == -1) failed_spr += "standing_h, ";
      if (spr7 == -1) failed_spr += "walking, ";
      if (spr8 == -1) failed_spr += "walking_h, ";
      if (spr9 == -1) failed_spr += "head, ";
      failed_spr += ")";
      sc_mod_log(mod_name, "api_define_menu_npc", "Error: Failed To Load Sprite/s" + failed_spr, undefined);
      return undefined;
    }
    
  } catch(ex) {
    sc_mod_log(mod_name, "api_define_menu_npc", "Error: Failed To Define NPC", ex.longMessage);
    return undefined;
  }
  
  
}



// api_define_npc2()
// define a new npc along with dialogue and shop stock (2.0+)
function sc_mod_api_define_npc2(npc, standing_sprite, standing_sprite_h, walking_sprite, walking_sprite_h, head_sprite, bust_sprite, item_sprite, dialogue_bg_sprite, shop_bg_sprite, dialogue_check) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  
  try {
  
    // required
    var req = ["id", "name", "pronouns", "tooltip", "stock", "dialogue", "specials"];
    for (var r = 0; r < array_length(req); r++) {
      if (!variable_struct_exists(npc, req[r])) {
        sc_mod_log(mod_name, "api_define_menu_npc", "Error: Missing Required Key (" + req[r] + ")", undefined);
        return undefined;
      }
    }
    
    // valid npc id
    var num = false;
    try {
      real(npc.id);
      num = true;
    } catch(ex) {
      num = false;
    }
    if (num == false) {
      sc_mod_log(mod_name, "api_define_menu_npc", "Error: NPC ID Must Be A Number", undefined);
      return undefined;  
    }
    
    var npc_id = "npc" + string(npc.id);
    if (global.DICTIONARY[? npc_id] != undefined || global.MOD_NPCS[? npc_id] != undefined) {
      sc_mod_log(mod_name, "api_define_menu_npc", "Error: NPC With This ID Already Defined", undefined);
      return undefined;  
    }
    
    // need 3 speciasl
    if (array_length(npc.specials) < 3) {
      sc_mod_log(mod_name, "api_define_menu_npc", "Error: Need To Specify At Least 3 Specials", undefined);
      return undefined;  
    }
    
    // try making the objs we need
    var nn = ds_map_create();
    var ns = undefined;
    
    var has_shop = variable_struct_exists(npc, "shop") == true && npc.shop == true;
    var has_walk = variable_struct_exists(npc, "walking") == true && npc.walking == true;
    
    // create npc definition
    nn[? "name"] = npc.name;
    nn[? "category"] = global.DICTIONARY[? "npc1"][? "category"];
    nn[? "tooltip"] = npc.tooltip;
    nn[? "tooltip_item"] = global.DICTIONARY[? "npc1"][? "tooltip_item"];
    nn[? "menu"] = true;
    nn[? "layout"] = ds_list_create();
    nn[? "buttons"] = ds_list_create();
    nn[? "info"] = ds_list_create();
    nn[? "tools"] = ds_list_create();
    ds_list_add(nn[? "tools"], "mouse1");
    ds_list_add(nn[? "tools"], "hammer1");
    ds_map_add_list(nn, "machines", ds_list_create());
    nn[? "placeable"] = true;
    nn[? "singular"] = true;
    if (variable_struct_exists(npc, "shop")) nn[? "shop"] = npc.shop;
    if (variable_struct_exists(npc, "walking")) nn[? "walking"] = npc.walking;
    var cost = ds_map_create();
    cost[? "key"] = true;
    cost[? "buy"] = 0;
    cost[? "sell"] = 0;
    ds_map_add_map(nn, "cost", cost);
    nn[? "obj"] = npc_id;
    
    // create shop definition
    if (has_shop) {
      ns = ds_map_create();
      ns[? "name"] = npc.name;
      ns[? "category"] = global.DICTIONARY[? "npc1"][? "category"];
      ns[? "tooltip"] = npc.tooltip;
      ns[? "tooltip_item"] = global.DICTIONARY[? "npc1"][? "tooltip_item"];
      ns[? "menu"] = true;
      ns[? "layout"] = ds_list_create();
      var lay = [
      [76, 22, "Buy"],
      [99, 22, "Buy"],
      [7, 63, "Buy"],
      [30, 63, "Buy"],
      [53, 63, "Buy"],
      [76, 63, "Buy"],
      [99, 63, "Buy"],
      [122, 63, "Buy"],
      [7, 86, "Buy"],
      [30, 86, "Buy"],
      [53, 86, "Buy"],
      [76, 86, "Buy"],
      [99, 86, "Buy"],
      [122, 86, "Buy"],
      [7, 112, "Sell"],
      [30, 112, "Sell"],
      [53, 112, "Sell"],
      [76, 112, "Sell"],
      [99, 112, "Sell"],
      [122, 112, "Sell"],
      [7, 135, "Sell"],
      [30, 135, "Sell"],
      [53, 135, "Sell"],
      [76, 135, "Sell"],
      [99, 135, "Sell"],
      [122, 135, "Sell"]
      ];
      for (var l = 0; l < array_length(lay); l++) {
        var row = ds_list_create();
        for (r = 0; r < array_length(lay[l]); r++) {
          ds_list_add(row, lay[l][r]);  
        }
        ds_list_add(ns[? "layout"], row);
      }
      ns[? "buttons"] = ds_list_create();
      ds_list_add(ns[? "buttons"], "Help");
      ds_list_add(ns[? "buttons"], "Move");
      ds_list_add(ns[? "buttons"], "Target");
      ds_list_add(ns[? "buttons"], "Close");
      ns[? "info"] = ds_list_create();
      var row1 = ds_list_create();
      ds_list_add(row1, "1. Item of the Day");
      ds_list_add(row1, "GREEN");
      var row2 = ds_list_create();
      ds_list_add(row2, "2. Items for Sale");
      ds_list_add(row2, "BLUE");
      var row3 = ds_list_create();
      ds_list_add(row3, "3. Items to Sell");
      ds_list_add(row3, "RED");
      ds_list_add(ns[? "info"], row1);
      ds_list_add(ns[? "info"], row2);
      ds_list_add(ns[? "info"], row3);
      
      var tools = ds_list_create();
      ds_list_add(tools, "mouse1");
      ds_list_add(tools, "hammer1");
      ds_map_add_list(ns, "machines", ds_list_create());
      ds_map_add_list(ns, "tools", tools);
      ns[? "placeable"] = true;
      ns[? "singular"] = true;
      ns[? "shop"] = true;
      var cost = ds_map_create();
      cost[? "key"] = true;
      cost[? "buy"] = 0;
      cost[? "sell"] = 0;
      ds_map_add_map(ns, "cost", cost);
      ns[? "obj"] = npc_id;
    }
    
    // shop menu
    var spr1 = 1;
    if (has_shop == true) {
      spr1 = sprite_add(working_directory + "mods/" + mod_name + "/" + shop_bg_sprite, 1, true, false, 0, 0);
      global.MOD_SPRITES[? "sp_" + npc_id + "s_menu"] = spr1;
      global.SPRITE_REFERENCE[? "sp_" + npc_id + "s_menu"] = spr1;
    }
    
    // dialogue menu
    var spr2 = sprite_add(working_directory + "mods/" + mod_name + "/" + dialogue_bg_sprite, 1, true, false, 0, 0);
    global.MOD_SPRITES[? "sp_" + npc_id + "_menu"] = spr2;
    global.SPRITE_REFERENCE[? "sp_" + npc_id + "_menu"] = spr2;
    
    // item sprite
    var spr3 = sprite_add(working_directory + "mods/" + mod_name + "/" + item_sprite, 2, true, false, 0, 0);
    global.MOD_SPRITES[? "sp_" + npc_id] = spr3;
    global.SPRITE_REFERENCE[? "sp_" + npc_id] = spr3;
    
    // bust sprite
    var spr4 = sprite_add(working_directory + "mods/" + mod_name + "/" + bust_sprite, 2, true, false, 0, 0);
    global.MOD_SPRITES[? "sp_" + npc_id + "_bust"] = spr4;
    global.SPRITE_REFERENCE[? "sp_" + npc_id + "_bust"] = spr4;
    
    // standing
    var spr5 = sprite_add(working_directory + "mods/" + mod_name + "/" + standing_sprite, 2, true, false, 0, 0);
    global.MOD_SPRITES[? "sp_" + npc_id + "_standing"] = spr5;
    global.SPRITE_REFERENCE[? "sp_" + npc_id + "_standing"] = spr5;
    var spr6 = sprite_add(working_directory + "mods/" + mod_name + "/" + standing_sprite_h, 2, true, false, 0, 0);
    global.MOD_SPRITES[? "sp_" + npc_id + "_standing_h"] = spr6;
    global.SPRITE_REFERENCE[? "sp_" + npc_id + "_standing_h"] = spr6;
    
    // walking
    var spr7 = 1;
    var spr8 = 1;
    if (has_walk == true) {
      spr7 = sprite_add(working_directory + "mods/" + mod_name + "/" + walking_sprite, 4, true, false, 0, 0);
      global.MOD_SPRITES[? "sp_" + npc_id + "_walking"] = spr7;
      global.SPRITE_REFERENCE[? "sp_" + npc_id + "_walking"] = spr7;
      spr8 = sprite_add(working_directory + "mods/" + mod_name + "/" + walking_sprite_h, 4, true, false, 0, 0);
      global.MOD_SPRITES[? "sp_" + npc_id + "_walking_h"] = spr8;
      global.SPRITE_REFERENCE[? "sp_" + npc_id + "_walking_h"] = spr8;
    }
    
    var spr9 = sprite_add(working_directory + "mods/" + mod_name + "/" + head_sprite, 1, true, false, 0, 0);
    global.MOD_SPRITES[? "sp_" + npc_id + "_head"] = spr9;
    global.SPRITE_REFERENCE[? "sp_" + npc_id + "_head"] = spr9;
    
    if (spr1 != -1 && spr2 != -1 && spr3 != -1 && spr4 != -1 && spr5 != -1 && spr6 != -1 && spr7 != -1 && spr8 != -1 && spr9 != 1) {

      // offset sprites
      sprite_set_offset(spr5, 8, 0);
      sprite_set_offset(spr6, 8, 0);
      sprite_set_offset(spr7, 8, 0);
      sprite_set_offset(spr8, 8, 0);
      
      // change sprite speed
      sprite_set_speed(spr5, 2, spritespeed_framespersecond);
      sprite_set_speed(spr6, 2, spritespeed_framespersecond);
      sprite_set_speed(spr7, 2, spritespeed_framespersecond);
      sprite_set_speed(spr8, 2, spritespeed_framespersecond);

      // add definitions
      global.DICTIONARY[? npc_id] = nn;
      global.MODDED_DICTIONARY[$ mod_name][$ npc_id] = json_parse(json_encode(nn));
      
      if (has_shop == true) {
        global.DICTIONARY[? npc_id + "s"] = ns;
        global.MODDED_DICTIONARY[$ mod_name][$ npc_id] = json_parse(json_encode(ns));
      }
      
      npc.dialogue[$ "_G"] = npc.greeting;
      var new_dialogue = json_decode(json_stringify(npc.dialogue));
      
      global.MOD_NPCS[? npc_id] = {
        name: npc.name,
        shop: variable_struct_exists(npc, "shop") && npc.shop == true,
        pronouns: npc.pronouns,
        stock: npc.stock,
        specials: npc.specials,
        dialogue: [],
        state: global.MOD_STATES[? mod_name],
        check_dialogue: dialogue_check,
        greeting: npc.greeting,
        new_dialogue: new_dialogue
      }
      
      log(global.MOD_NPCS[? npc_id].new_dialogue[? "A"]);
      
      log(json_encode(npc.dialogue));
      
      return "Success";
      
    } else {
      var failed_spr = "(";
      if (spr1 == -1) failed_spr += "shop_menu, ";
      if (spr2 == -1) failed_spr += "dialogue_menu, ";
      if (spr3 == -1) failed_spr += "item, ";
      if (spr4 == -1) failed_spr += "bust, ";
      if (spr5 == -1) failed_spr += "standing, ";
      if (spr6 == -1) failed_spr += "standing_h, ";
      if (spr7 == -1) failed_spr += "walking, ";
      if (spr8 == -1) failed_spr += "walking_h, ";
      if (spr9 == -1) failed_spr += "head, ";
      failed_spr += ")";
      sc_mod_log(mod_name, "api_define_menu_npc", "Error: Failed To Load Sprite/s" + failed_spr, undefined);
      return undefined;
    }
    
  } catch(ex) {
    sc_mod_log(mod_name, "api_define_menu_npc", "Error: Failed To Define NPC", ex.longMessage);
    return undefined;
  }
  
  
}



// api_define_wall()
// define a new wall type
function sc_mod_api_define_wall(wall, wall_sprite) {
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  
  try {
    
    // required
    var req = ["id", "name"];
    for (var r = 0; r < array_length(req); r++) {
      if (!variable_struct_exists(wall, req[r])) {
        sc_mod_log(mod_name, "api_define_menu_wall", "Error: Missing Required Key (" + req[r] + ")", undefined);
        return undefined;
      }
    }
  
    var wall_id = "wall" + string(wall.id);
    if (global.DICTIONARY[? wall_id] != undefined) {
      sc_mod_log(mod_name, "api_define_menu_wall", "Error: Wall ID Already Defined (" + wall_id + ")", undefined);
      return undefined;
    }
    
    var nw = ds_map_create();
    nw[? "name"] = wall.name;
    nw[? "category"] = global.DICTIONARY[? "wall1"][? "category"];
    nw[? "tooltip"] = global.DICTIONARY[? "wall1"][? "tooltip"];
    nw[? "tooltip_item"] = global.DICTIONARY[? "wall1"][? "tooltip_item"];
    nw[? "menu"] = false;
    var cost = ds_map_create();
    cost[? "buy"] = variable_struct_exists(wall, "shop_buy") == true ? wall.shop_buy : 0;
    cost[? "sell"] = variable_struct_exists(wall, "shop_sell") == true ? wall.shop_sell : 0;
    ds_map_add_map(nw, "cost", cost);
    var tools = ds_list_create();
    ds_list_add(tools, "hammer1");
    ds_map_add_list(nw, "tools", tools);
    ds_map_add_list(nw, "machines", ds_list_create());
    nw[? "placeable"] = true;
    nw[? "wall"] = wall_id;
    
    var spr = sprite_add(working_directory + "mods/" + mod_name + "/" + wall_sprite, 55, true, false, 0, 0);
    if (spr == -1) {
      sc_mod_log(mod_name, "api_define_menu_wall", "Error: Wall Sprite Not Found (" + wall_sprite + ")", undefined);
      return undefined;
    }
    global.MOD_SPRITES[? "sp_" + wall_id] = spr;
    global.SPRITE_REFERENCE[? "sp_" + wall_id] = spr;
    
    global.DICTIONARY[? wall_id] = nw;
    global.MODDED_DICTIONARY[$ mod_name][$ wall_id] = json_parse(json_encode(nw));
    
    return "Success";
    
  } catch(ex) {
   
    sc_mod_log(mod_name, "api_define_wall", "Error: Failed To Define Wall", ex.longMessage);
   
  }
  
}



function sc_mod_api_define_validation_icon(validation, item_sprite) {
  
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  
  var spr = sprite_add(working_directory + "mods/" + mod_name + "/" + item_sprite, 1, true, false, 0, 0);
  if (spr == -1) {
    
    sc_mod_log(mod_name, "api_define_validation_icon", "Error: Sprite Not Found (" + item_sprite + ")", undefined);
    return undefined;
    
  } else {
    
    if (global.SPRITE_REFERENCE[? "sp_" + validation] == undefined) {
      global.MOD_SPRITES[? "sp_" + validation] = spr;
      global.SPRITE_REFERENCE[? "sp_" + validation] = spr;
      return "Success";
    } else {
      sc_mod_log(mod_name, "api_define_validation_icon", "Error: Sprite Already Defined (" + validation + ")", undefined);
      return undefined; 
    }
    
  }
  
}


// api_define_window()
// defines a new window item and adds it to the dictionary
function sc_mod_api_define_window(window, sprite_image) {
  
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  
  try {
    
    // check required keys in the item_def
    var req = ["id", "name"];
    for (var r = 0; r < array_length(req); r++) {
      if (!variable_struct_exists(window, req[r])) {
        sc_mod_log(mod_name, "api_define_window", "Error: Missing Required Key (" + req[r] + ")", undefined);
        return undefined;
      }
    }
    
    // "special" called by api_define_flower to remove mod_name identifier
    var window_id = "window" + string(window.id);
    
    // handle unique
    if (global.DICTIONARY[? window_id] != undefined) {
      sc_mod_log(mod_name, "api_define_item", "Error: ID Already Defined (" + window_id + ")", undefined);
      return undefined;
    }
    
    // setup dictionary definition
    var def = ds_map_create();
    def[? "id"] = window_id;
    def[? "name"] = window.name;
    def[? "category"] = global.DICTIONARY[? "window1"][? "category"];
    def[? "tooltip"] = global.DICTIONARY[? "window1"][? "tooltip"];
    def[? "tooltip_item"] = "Can be placed on walls!";
    
    var cost = ds_map_create();
    if (variable_struct_exists(window, "shop_key") == true) cost[? "key"] = window.shop_key;
    cost[? "buy"] = variable_struct_exists(window, "shop_buy") == true ? window.shop_buy : 0;
    cost[? "sell"] = variable_struct_exists(window, "shop_sell") == true ? window.shop_sell : 0;
    ds_map_add_map(def, "cost", cost);
    var machines = ds_list_create();
    ds_map_add_list(def, "machines", machines);
    var tools = ds_list_create();
    ds_list_add(tools, "hammer1");
    ds_map_add_list(def, "tools", tools);
    def[? "placeable"] = false;
    def[? "window"] = window_id;
    
    // try loading sprite
    try {
      global.DICTIONARY[? window_id] = def;
      global.MODDED_DICTIONARY[$ mod_name][$ window_id] = json_parse(json_encode(def));
      
      var spr = sprite_add(working_directory + "mods/" + mod_name + "/" + sprite_image, 5, true, false, 0, 0);
      if (spr == -1) {
        sc_mod_log(mod_name, "api_define_window", "Error: Window Sprite Not Found (" + sprite_image + ")", "");
        return undefined;
      } else {
        var spr_name = "sp_" + window_id;
        global.MOD_SPRITES[? spr_name] = spr;
        global.SPRITE_REFERENCE[? spr_name] = spr;
        return "Success";
      }
    } catch(ex) {
      sc_mod_log(mod_name, "api_define_window", "Error: Window To Add Sprite", ex.longMessage);
      return undefined;
    }
  
  // not sure why this would be called but rather safe than sorry
  } catch(ex) {
    sc_mod_log(mod_name, "api_define_window", "Error: Failed To Map Keys", ex.longMessage);
    return undefined;
  }
  
}



function sc_mod_api_define_liquid(name, color, texture_sprite, preview_sprite) {
  
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  
  if (global.MOD_LIQUIDS[$ name] != undefined) {
    sc_mod_log(mod_name, "api_define_liquid", "Error: Liquid Already Defined (" + name + ")", "");
    return undefined;
  }
  
  if (global.COLORS[? color] == undefined) {
    sc_mod_log(mod_name, "api_define_liquid", "Error: Color Not Defined (" + color + ")", "");
    return undefined;
  }
  
  var txt_spr = sprite_add(working_directory + "mods/" + mod_name + "/" + texture_sprite, 1, true, false, 0, 0);
  if (txt_spr == -1) {
    sc_mod_log(mod_name, "api_define_liquid", "Error: Texture Sprite Not Found (" + texture_sprite + ")", "");
    return undefined;
  }
  
  var preview_spr = sprite_add(working_directory + "mods/" + mod_name + "/" + preview_sprite, 1, false, false, 0, 0);
  if (preview_spr == -1) {
    sc_mod_log(mod_name, "api_define_liquid", "Error: Texture Sprite Not Found (" + preview_sprite + ")", "");
    return undefined;
  }
  
  global.MOD_LIQUIDS[$ name] = {
    color: color,
    preview: preview_spr,
    texture: txt_spr
  }
  
  return "Success";
  
}


// api_define_solitary()
// defines a new solitary bee and adds to the book
function sc_mod_api_define_solitary(bee, bee_sprite_image, bee_shiny_image, bee_hd_image, bee_color, bee_letter_image, bee_letter_para) {
  
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  
  try {
    
    // check required keys
    var req = ["id", "title", "latin", "hint", "desc", "biome", "behaviour", "climate",
      "rainlover", "snowlover", "produce", "specials", "chance"];
    for (var r = 0; r < array_length(req); r++) {
      if (!variable_struct_exists(bee, req[r])) {
        sc_mod_log(mod_name, "api_define_solitary", "Error: Missing Required Key (" + req[r] + ")", undefined);
        return undefined;
      }
    }
    
    // bee id doesnt have mod name 
    var bee_id = bee.id;
    
    // valid biome
    var valid_biome = false;
    bee.biome = string_lower(bee.biome);
    if (bee.biome == "forest" || bee.biome == "swamp" || bee.biome == "snow" || bee.biome == "hallow" || bee.biome == "devland") valid_biome = true;
    
    // handle unique + bid
    if (global.BEES[? bee_id] != undefined) {
      sc_mod_log(mod_name, "api_define_solitary", "Error: Bee With This ID Exists", undefined);
      return undefined;
    } else if (global.DICTIONARY[? bee.produce] == undefined) {
      sc_mod_log(mod_name, "api_define_solitary", "Error: Bee Produce Item Not Defined", undefined);
      return undefined;
    } else if (valid_biome == false) {
      sc_mod_log(mod_name, "api_define_solitary", "Error: Biome specified is not valid (" + bee.biome + ")", undefined);
      return undefined;
    } else {
  
      // create bee definition
      var nf = ds_map_create();
      nf[? "id"] = bee_id;
      nf[? "species"] = bee_id;
      nf[? "title"] = bee.title;
      nf[? "latin"] = bee.latin;
      nf[? "hint"] = ds_list_create();
      var hint = ds_map_create();
      hint[? "color"] = "FONT_BOOK";
      hint[? "text"] = bee.hint;
      ds_list_add(nf[? "hint"], hint);
      nf[? "desc"] = ds_list_create();
      var desc = ds_map_create();
      desc[? "color"] = "FONT_BOOK";
      desc[? "text"] = bee.desc;
      ds_list_add(nf[? "desc"], desc);
      nf[? "biome"] = bee.biome;
      nf[? "behaviour"] = bee.behaviour;
      nf[? "climate"] = bee.climate;
      nf[? "pluviophile"] = bee.rainlover;
      nf[? "chionophile"] = bee.snowlover;
      nf[? "product"] = bee.produce;
      nf[? "flora"] = ds_list_create();
      if (bee.biome == "forest") { ds_list_add(nf[? "flora"], "flora1"); ds_list_add(nf[? "flora"], "flora2"); }
      if (bee.biome == "swamp") { ds_list_add(nf[? "flora"], "flora3"); ds_list_add(nf[? "flora"], "flora4"); }
      if (bee.biome == "snow") { ds_list_add(nf[? "flora"], "flora5"); ds_list_add(nf[? "flora"], "flora6"); }
      if (bee.biome == "hallow" || bee.biome == "devland") { ds_list_add(nf[? "flora"], "flora7"); ds_list_add(nf[? "flora"], "flora8"); }
      nf[? "specials"] = ds_list_create();
      for (var i = 0; i < array_length(bee.specials); i++) { ds_list_add(nf[? "specials"], bee.specials[i]); }
      nf[? "chance"] = bee.chance;
      nf[? "solitary"] = true;
      
      var insert_index = 0;
      
      // check tier preference and try our darn best
      var tiers = sc_tier_count("_species_s");
      var tier = 1;
      if (bee.biome == "swamp") tier = 2;
      if (bee.biome == "snow") tier = 3;
      if (bee.biome == "hallow") tier = 4;
      if (bee.biome == "devland") tier = 5;
      if (tier == 1 && tiers.t1 >= 6) tier = 2;
      if (tier == 2 && tiers.t2 >= 12) tier = 3;
      if (tier == 3 && tiers.t3 >= 30) tier = 4;
      if (tier == 4 && tiers.t4 >= 12) tier = 5;
      switch(tier) {
        case 1: insert_index = tiers.t1i; break;
        case 2: insert_index = tiers.t2i; break;
        case 3: insert_index = tiers.t3i; break;
        case 4: insert_index = tiers.t4i; break;
        case 5: insert_index = tiers.t5i - 1; break; // account for glitched
      }
      nf[? "tier"] = tier;
      
      log("new bee", bee.id, bee.biome, tiers, tier);
            
      // bee name for sprites
      var bn = "sp_bee_" + bee.id;
      
      // add normal bee
      var spr = sprite_add(working_directory + "mods/" + mod_name + "/" + bee_sprite_image, 4, true, false, 0, 0);
      global.MOD_SPRITES[? bn] = spr;
      global.SPRITE_REFERENCE[? bn] = spr;
        
      // add bee shiny
      var vspr = sprite_add(working_directory + "mods/" + mod_name + "/" + bee_shiny_image, 20, true, false, 0, 0);
      global.MOD_SPRITES[? bn + "_shiny"] = vspr;
      global.SPRITE_REFERENCE[? bn + "_shiny"] = vspr;
        
      // add big bee
      var hspr = sprite_add(working_directory + "mods/" + mod_name + "/" + bee_hd_image, 2, true, false, 0, 0);
      global.MOD_SPRITES[? bn + "_hd"] = hspr;
      global.SPRITE_REFERENCE[? bn + "_hd"] = hspr;
      
      // add bee magazine
      var mspr = sprite_add(working_directory + "mods/" + mod_name + "/" + bee_letter_image, 2, true, false, 0, 0);
      global.MOD_SPRITES[? "sp_magazine_" + bee.id] = mspr;
      global.SPRITE_REFERENCE[? "sp_magazine_" + bee.id] = mspr;
      
      // add mag item
      var mag_def = ds_map_create();
      mag_def[? "name"] = string_replace(global.DICTIONARY[? "magazine_common"][? "name"], " 1", "");
      mag_def[? "category"] = global.DICTIONARY[? "magazine_common"][? "category"];
      mag_def[? "tooltip"] = global.DICTIONARY[? "magazine_cutter"][? "tooltip"];
      var cost = ds_map_create();
      cost[? "key"] = true;
      cost[? "buy"] = 0;
      cost[? "sell"] = 0;
      ds_map_add_map(mag_def, "cost", cost);
      ds_map_add_list(mag_def, "tools", ds_list_create());
      ds_map_add_list(mag_def, "machines", ds_list_create());
      mag_def[? "placeable"] = false;
      mag_def[? "singular"] = true;
      
      // check sprites loaded
      if (spr == -1 || vspr == -1 || hspr == -1) {
        sc_mod_log(mod_name, "api_define_solitary", "Error: Bee Sprites Not Found", undefined);
        return undefined;
      } else {
      
        // add mag
        ds_map_add(global.DIALOGUE[? "magazine"], bee.id, bee_letter_para);
        global.DICTIONARY[? "magazine_" + bee.id] = mag_def;
      
        // add references
        global.MOD_CUSTOM_BEES = true;
        global.BEES[? bee.id] = nf;
        global.MOD_BEES[? bee.id] = true;
        global.MODDED_BEES[$ mod_name][$ bee.id] = json_parse(json_encode(nf));
        global.COLORS[? "BEE_" + string_upper(bee.id)] = make_color_rgb(bee_color.r, bee_color.g, bee_color.b);
        
        if (insert_index == 0) {
          ds_list_add(global.BEES[? "_species_s"], bee.id);
        } else {
          ds_list_insert(global.BEES[? "_species_s"], insert_index+1, bee.id); 
        }
        
        return "Success";
        
      }
      
    }
      
  // bad datatypes passed in dictionary
  } catch(ex) {
    sc_mod_log(mod_name, "api_define_solitary", "Error: Failed To Map Keys", ex.longMessage);
    return undefined;      
  }
  
}


// api_define_butterfly()
// defines a new butterfly and adds to the book
function sc_mod_api_define_butterfly(butt, butt_sprite_image, butt_shiny_image, butt_cat_image, butt_hd_image, butt_color) {
  
  var mod_name = global.MOD_STATE_IDS[? lua_current];
  
  try {
    
    // check required keys
    var req = ["id", "title", "latin", "hint", "desc", "lifespan", "climate", "biome", 
      "behaviour", "rainlover", "snowlover", "flora", "flowers", "chance", "named"
    ];
    for (var r = 0; r < array_length(req); r++) {
      if (!variable_struct_exists(butt, req[r])) {
        sc_mod_log(mod_name, "api_define_butterfly", "Error: Missing Required Key (" + req[r] + ")", undefined);
        return undefined;
      }
    }
    
    // butt id doesnt have mod name 
    var butt_id = butt.id;
    
    // valid biome
    var valid_biome = false;
    butt.biome = string_lower(butt.biome);
    if (butt.biome == "forest" || butt.biome == "swamp" || butt.biome == "snow" || butt.biome == "hallow" || butt.biome == "devland") valid_biome = true;
    
    // handle unique + bid
    if (global.BEES[? butt_id] != undefined) {
      sc_mod_log(mod_name, "api_define_butterfly", "Error: Butterfly With This ID Exists", undefined);
      return undefined;
    } else if (valid_biome == false) {
      sc_mod_log(mod_name, "api_define_butterfly", "Error: Biome specified is not valid (" + butt.biome + ")", undefined);
      return undefined;
    } else {
  
      // create bee definition
      var nf = ds_map_create();
      nf[? "id"] = butt_id;
      nf[? "species"] = butt_id;
      nf[? "title"] = butt.title;
      nf[? "latin"] = butt.latin;
      nf[? "hint"] = ds_list_create();
      var hint = ds_map_create();
      hint[? "color"] = "FONT_BOOK";
      hint[? "text"] = butt.hint;
      ds_list_add(nf[? "hint"], hint);
      nf[? "desc"] = ds_list_create();
      var desc = ds_map_create();
      desc[? "color"] = "FONT_BOOK";
      desc[? "text"] = butt.desc;
      ds_list_add(nf[? "desc"], desc);
      nf[? "biome"] = butt.biome;
      nf[? "lifespan"] = butt.lifespan;
      nf[? "behaviour"] = butt.behaviour;
      nf[? "climate"] = butt.climate;
      nf[? "pluviophile"] = butt.rainlover;
      nf[? "chionophile"] = butt.snowlover;
      nf[? "flora"] = butt.flora;
      nf[? "flowers"] = ds_list_create();
      for (var i = 0; i < array_length(butt.flowers); i++) { ds_list_add(nf[? "flowers"], butt.flowers[i]); }
      nf[? "chance"] = butt.chance;
      nf[? "named"] = butt.named;
      
      // effect if any
      nf[? "effect_desc"] = ds_list_create();
      var eff = ds_map_create();
      eff[? "color"] = "FONT_BOOK";
      eff[? "text"] = variable_struct_exists(butt, "effect") == true ? butt.effect : "$generic_effect";
      ds_list_add(nf[? "effect_desc"], eff);
      
      
      var insert_index = 0;
      
      // check tier preference and try our darn best
      var tiers = sc_tier_count_butts();
      var tier = 1;
      if (butt.biome == "swamp") tier = 2;
      if (butt.biome == "snow") tier = 3;
      if (butt.biome == "hallow") tier = 4;
      if (butt.biome == "devland") tier = 5;
      if (tier == 1 && tiers.t1 >= 6) tier = 2;
      if (tier == 2 && tiers.t2 >= 12) tier = 3;
      if (tier == 3 && tiers.t3 >= 30) tier = 4;
      if (tier == 4 && tiers.t4 >= 12) tier = 5;
      switch(tier) {
        case 1: insert_index = tiers.t1i; break;
        case 2: insert_index = tiers.t2i; break;
        case 3: insert_index = tiers.t3i; break;
        case 4: insert_index = tiers.t4i; break;
        case 5: insert_index = tiers.t5i - 1; break; // account for glitched
      }
      nf[? "tier"] = tier;
            
      // bee name for sprites
      var bn = "sp_butterfly_" + butt.id;
      
      insert_index += 3; // account for intro chapters
      
      log("adding butt", butt.id, tier, tiers, insert_index);
      
      // add normal bee
      var spr = sprite_add(working_directory + "mods/" + mod_name + "/" + butt_sprite_image, 4, true, false, 0, 0);
      global.MOD_SPRITES[? bn] = spr;
      global.SPRITE_REFERENCE[? bn] = spr;
        
      // add bee shiny
      var vspr = sprite_add(working_directory + "mods/" + mod_name + "/" + butt_shiny_image, 20, true, false, 0, 0);
      global.MOD_SPRITES[? bn + "_shiny"] = vspr;
      global.SPRITE_REFERENCE[? bn + "_shiny"] = vspr;
      
      // add butt caterpiller
      var bspr = sprite_add(working_directory + "mods/" + mod_name + "/" + butt_cat_image, 1, true, false, 0, 0);
      global.MOD_SPRITES[? "sp_caterpiller_" + butt.id] = bspr;
      global.SPRITE_REFERENCE[? "sp_caterpiller_" + butt.id] = bspr;
        
      // add big bee
      var hspr = sprite_add(working_directory + "mods/" + mod_name + "/" + butt_hd_image, 2, true, false, 0, 0);
      global.MOD_SPRITES[? bn + "_hd"] = hspr;
      global.SPRITE_REFERENCE[? bn + "_hd"] = hspr;
      
      // check sprites loaded
      if (spr == -1 || vspr == -1 || hspr == -1 || bspr == -1) {
        var not_found = "Normal Sprite";
        if (vspr == -1) not_found = "Shiny Sprite";
        if (hspr == -1) not_found = "HD Sprite";
        if (bspr == -1) not_found = "Caterpiller Sprite";
        sc_mod_log(mod_name, "api_define_butterfly", "Error: Butterfly Sprites Not Found (" + not_found + ")", undefined);
        return undefined;
      } else {
      
        // add references
        global.MOD_CUSTOM_BUTTERFLIES = true;
        global.BUTTERFLIES[? butt.id] = nf;
        global.MOD_BUTTERFLIES[? butt.id] = true;
        global.MODDED_BUTTERFLIES[$ mod_name][$ butt.id] = json_parse(json_encode(nf));
        global.COLORS[? "BUTTERFLY_" + string_upper(butt.id)] = make_color_rgb(butt_color.r, butt_color.g, butt_color.b);
        
        if (insert_index == 0) {
          ds_list_add(global.BUTTERFLIES[? "_species"], butt.id);
        } else {
          ds_list_insert(global.BUTTERFLIES[? "_species"], insert_index+1, butt.id); 
        }
        
        return "Success";
        
      }
      
    }
      
  // bad datatypes passed in dictionary
  } catch(ex) {
    sc_mod_log(mod_name, "api_define_butterfly", "Error: Failed To Map Keys", ex.longMessage);
    return undefined;      
  }
  
}


// api_define_incense()
// defines a new incense item + recipe (not effect)
function sc_mod_api_define_incense(item, sprite_image, incense_func) {
  
  var mod_name = global.MOD_STATE_IDS[? lua_current];

  // first try and define an item for the incense
  var define_item = sc_mod_api_define_item(item, sprite_image, true);
  if (define_item == "Success") {
    
    // if worked then add the recipe method
    array_push(global.MODDED_INCENSE, {
      state: global.MOD_STATES[? mod_name],
      func: incense_func
    });
    
    return "Success";
    
  } else {
    sc_mod_log(mod_name, "api_define_incense", "Error: Failed To Define Item", undefined);
    return undefined;
  }

}
