// api_take_money()
// take some money from the player, stopping at 0
function sc_mod_api_take_money(amount) {
  global.PLAYER.money -= amount;
  if (global.PLAYER.money <= 0) global.PLAYER.money = 0;
}


// api_take_honeycore()
// take some honeycore from the player, stopping at 0
function sc_mod_api_take_honeycore(amount) {
  global.PLAYER.honeycore -= amount;
  if (global.PLAYER.honeycore <= 0) global.PLAYER.honeycore = 0;
}
