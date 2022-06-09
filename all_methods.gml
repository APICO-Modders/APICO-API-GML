// api_all_trees()
// gets all the tree instance ids in the world - intended for worldgen messin, use sparingly
function sc_mod_api_all_trees() {
  var ids = [];
  instance_activate_object(ob_tree);
  with (ob_tree) {
    array_push(ids, id);
  }
  sc_player_camera(global.PLAYER);
  sc_player_move();
  sc_player_move_update();
  return ids;
}


// api_all_flowers()
// gets all the flower inst ids in the world - intended for worldgen messin, use sparingly
function sc_mod_api_all_flowers(filter_oid) {
  var ids = [];
  instance_activate_object(ob_flower);
  with (ob_flower) {
    if (filter_oid == undefined || filter_oid == oid) array_push(ids, id);
  }
  sc_player_camera(global.PLAYER);
  sc_player_move();
  sc_player_move_update();
  return ids;
}

// api_all_objects()
// gets all the generic objs inst ids in the world - intended for worldgen messin, use sparingly
function sc_mod_api_all_objects(filter_oid) {
  var ids = [];
  instance_activate_object(ob_generic);
  with (ob_generic) {
    if (filter_oid == undefined || filter_oid == oid) array_push(ids, id);
  }
  sc_player_camera(global.PLAYER);
  sc_player_move();
  sc_player_move_update();
  return ids;
}

// api_all_menu_objects()
// gets all the flower inst ids in the world - intended for worldgen messin, use sparingly
function sc_mod_api_all_menu_objects(filter_oid) {
  var ids = [];
  instance_activate_object(ob_menu_object);
  with (ob_menu_object) {
    if (filter_oid == undefined || filter_oid == oid) array_push(ids, id);
  }
  sc_player_camera(global.PLAYER);
  sc_player_move();
  sc_player_move_update();
  return ids;
}
