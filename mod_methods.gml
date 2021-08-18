// api_mod_exists()
// check if a given mod exists and is loaded
function sc_mod_api_mod_exists(mod_name) {
  return global.MOD_STATES[? mod_name] != undefined;  
}


// api_mod_call()
// call a method from another mod with a list of args
function sc_mod_api_mod_call(mod_name, method_name, args) {
  var this_name = global.MOD_STATE_IDS[? lua_current];
  try {
    if (args == undefined) args = [];
    return lua_call_w(global.MOD_STATES[? mod_name], method_name, args);
  } catch(ex) {
    sc_mod_log(this_name, "api_mod_call", "Error: Failed To Invoke Method (" + mod_name + "." + method_name + ")", ex.longMessage);
    return undefined;
  }
}
