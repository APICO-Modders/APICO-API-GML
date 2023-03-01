// api_draw_sprite()
// draws a given sprite at a certain position
function sc_mod_api_draw_sprite(sprite_ref, frame, sx, sy) {
  if (sprite_ref != undefined) draw_sprite(sprite_ref, frame, sx, sy);
}


// api_draw_sprite_part()
// draws part of a given sprite at a certain position
function sc_mod_api_draw_sprite_part(sprite_ref, frame, sl, st, sw, sh, sx, sy) {
  if (sprite_ref != undefined) draw_sprite_part(sprite_ref, frame, sl, st, sw, sh, sx, sy);  
}


// api_draw_sprite_ext()
// draws a sprite with transformations / color blend / alpha at a certain position
function sc_mod_api_draw_sprite_ext(sprite_ref, frame, sx, sy, x_scale, y_scale, rot, col, alp) {
  var c = global.COLORS[? col] == undefined ? c_white : global.COLORS[? col];
  if (sprite_ref != undefined) draw_sprite_ext(sprite_ref, frame, sx, sy, x_scale, y_scale, rot, c, alp);
}


// api_draw_text()
// draws text at a given position
function sc_mod_api_draw_text(tx, ty, text, card, col, tw) {
  if (tw == undefined) {
    sc_text_draw_s(tx, ty, text, card, col);
  } else {
    sc_text_draw_s_alt(tx, ty, text, card, col, tw);
  }
}


// api_draw_number()
// draws numbers at a given position using the slot number font
function sc_mod_api_draw_number(tx, ty, amount, col) {
	draw_set_halign(fa_right);
  draw_set_valign(fa_bottom);
	draw_set_font(global.FONT7_WHITE);
	draw_set_color(global.COLORS[? col] == undefined ? global.COLORS[? "FONT_WHITE"] : global.COLORS[? col]);
	draw_text(tx, ty, string(amount));	
}


// api_draw_line()
// draws a line primitive between 2 points
function sc_mod_api_draw_line(x1, y1, x2, y2, col, alpha) {
  var c = global.COLORS[? col] == undefined ? c_white : global.COLORS[? col];
  if (alpha == undefined) {
    draw_line_color(x1, y1, x2, y2, c, c);
  } else {
    draw_set_alpha(alpha);
    draw_line_color(x1, y1, x2, y2, c, c);
    draw_set_alpha(1);
  }
}


// api_draw_rectangle()
// draws a rectangle at a given position
function sc_mod_api_draw_rectangle(x1, y1, x2, y2, col, outline, alpha) {
  var c = global.COLORS[? col] == undefined ? c_white : global.COLORS[? col];
  if (alpha == undefined) { 
    draw_rectangle_color(x1, y1, x2+global.PIXEL_OFFSET, y2+global.PIXEL_OFFSET, c, c, c, c, outline);
  } else {
    draw_set_alpha(alpha);
    draw_rectangle_color(x1, y1, x2+global.PIXEL_OFFSET, y2+global.PIXEL_OFFSET, c, c, c, c, outline);
    draw_set_alpha(1);
  }
}


// api_draw_circle()
// draws a circle at a given position
function sc_mod_api_draw_circle(cx, cy, rad, col, outline, alpha) {
  var c = global.COLORS[? col] == undefined ? c_white : global.COLORS[? col];
  if (alpha == undefined) { 
    draw_circle_color(cx, cy, rad, c, c, outline);
  } else {
    draw_set_alpha(alpha);
    draw_circle_color(cx, cy, rad, c, c, outline);
    draw_set_alpha(1);
  }
}


// api_draw_button()
// helper to draw a menu button, setting highlight + scale effect when clicked
function sc_mod_api_draw_button(btn_id, show_text) {
  if (btn_id != undefined && instance_exists(btn_id)) {
    sc_button_draw(btn_id, show_text);
  }
}


// api_draw_tank()
// helper to draw a tank along with it's contents, color, texture + highlight
function sc_mod_api_draw_tank(tank_gui) {
  
  // get variables
  var menu_id = tank_gui.menu;
  var tank_amount = menu_id.tank_amount;
  var tank_max = menu_id.tank_max;
  var tank_type = menu_id.tank_type;
  
  // draw tank liquid amount
  var tw = tank_gui.sprite_width - 9;
  var th = tank_gui.sprite_height - 8;
  var progressC = (tank_amount / tank_max) * th;
  var offset = th - progressC;
  var c = sc_util_get_liquid_color(tank_type);
  var ox = tank_gui.rx + 4;
  var oy = tank_gui.ry + 4;
  draw_rectangle_color(ox, oy + offset, ox + tw, oy + th - 1, c, c, c, c, false);
  
  // TODO custom
  // liquid texture
  if (tank_type != "") {
    if (global.MOD_LIQUIDS[$ tank_type] != undefined) {
      var tank_width = 8;
      var tank_height = 14;
      if (tank_gui.sprite_index == sp_gui_tank2) {
        tank_width = 31;
        tank_height = 34;
      } else
      if (tank_gui.sprite_index == sp_gui_tank3) {
        tank_width = 8;
        tank_height = 34;
      } else
      if (tank_gui.sprite_index == sp_gui_tank4) {
        tank_width = 37;
        tank_height = 34;
      }
      draw_sprite_part(global.MOD_LIQUIDS[$ tank_type].texture, 0, 0, 0, tank_width, tank_height, tank_gui.rx+4, tank_gui.ry+4);
    } else {
      draw_sprite(tank_gui.sprite_index, sc_util_get_liquid_texture(tank_type), tank_gui.rx, tank_gui.ry);
    }
  }
  
  // highlight
  if (global.HIGHLIGHTED_UI == tank_gui.id) {
    draw_sprite(tank_gui.sprite_index, 0, tank_gui.rx, tank_gui.ry);
  }
    
}


// api_draw_slots
// re-draws all slots for a given menu
function sc_mod_api_draw_slots(menu_id) {
  if (menu_id != undefined && instance_exists(menu_id) && variable_instance_exists(menu_id, "slots")) {
    for (var s = 0; s < ds_list_size(menu_id.slots); s++) {
      sc_slot_draw(menu_id.slots[| s], false); 
    }
  }
} 
