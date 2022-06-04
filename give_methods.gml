// api_give_item()
// give an item to a player
function sc_mod_api_give_item(item_id, amount, stats) {
  var data = sc_util_create_item_data(item_id, amount, stats == undefined ? {} : stats);
  sc_util_spawn(data.item, data.total, data.durability, data.durability, data.stats);
}


// api_give_money()
// give some money to a player
function sc_mod_api_give_money(amount) {
  global.PLAYER.money += amount;
}


// api_give_honeycore()
// give some honeycore to a player
function sc_mod_api_give_honeycore(amount) {
  global.PLAYER.honeycore += amount;
}
