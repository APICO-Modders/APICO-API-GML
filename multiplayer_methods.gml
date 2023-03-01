// api_multiplayer_is_mp() 
// returns whether we are in a MP game
function sc_mod_api_multiplayer_is_mp() {
  return sc_mod_api_multiplayer_is_joined() || sc_mod_api_multiplayer_is_hosting();
}


// api_multiplayer_is_joining()
// returns whether we have joined a MP game
function sc_mod_api_multiplayer_is_joined() {
  return global.CONTROLLER_EMS.ready == true && global.EMS_JOINED == true;
}


// api_multiplayer_is_hosting()
// returns whether we are currently hosting a game
function sc_mod_api_multiplayer_is_hosting() {
  return global.CONTROLLER_EMS.ready == true && global.EMS_HKEY != "" && global.EMS_JOINED == false;
}


// api_multiplayer_get_host_uuid()
// returns the host game uuid if we have joined a game
// this is a unique value we can identify the host with, i.e. to store host game specific mod data when we rejoin the same host world
function sc_mod_api_multiplayer_get_host_uuid() {
  return global.EMS_HOST_UUID; 
}
