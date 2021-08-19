// api_draw_sprite()
// draws a given sprite at a certain position
function sc_mod_api_draw_sprite(sprite_ref, frame, sx, sy) {
  draw_sprite(sprite_ref, frame, sx, sy);
}


// api_draw_sprite_part()
// draws part of a given sprite at a certain position
function sc_mod_api_draw_sprite_part(sprite_ref, frame, sl, st, sw, sh, sx, sy) {
  draw_sprite_part(sprite_ref, frame, sl, st, sw, sh, sx, sy);  
}


// api_draw_sprite_ext()
// draws a sprite with transformations / color blend / alpha at a certain position
function sc_mod_api_draw_sprite_ext(sprite_ref, frame, sx, sy, x_scale, y_scale, rot, col, alp) {
  var c = global.COLORS[? col] == undefined ? c_white : global.COLORS[? col];
  draw_sprite_ext(sprite_ref, frame, sx, sy, x_scale, y_scale, rot, c, alp);
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
    draw_rectangle_color(x1, y1, x2, y2, c, c, c, c, outline);
  } else {
    draw_set_alpha(alpha);
    draw_rectangle_color(x1, y1, x2, y2, c, c, c, c, outline);
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
  sc_button_draw(btn_id, show_text);
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
  var tx = floor(tank_gui.x - global.CAMERA.x);
  var ty = floor(tank_gui.y - global.CAMERA.y);
  var tw = tank_gui.sprite_width - 9;
  var th = tank_gui.sprite_height - 8;
  var progressC = (tank_amount / tank_max) * th;
  var offset = th - progressC;
  var c = sc_util_get_liquid_color(tank_type);
  var ox = tx + 4;
  var oy = ty + 4;
  draw_rectangle_color(ox, oy + offset, ox + tw, oy + th - 1, c, c, c, c, false);
  
  // liquid texture
  if (tank_type != "") {
    draw_sprite(tank_gui.sprite_index, sc_util_get_liquid_texture(tank_type), tx, ty);
  }
  
  // highlight
  if (global.HIGHLIGHTED_UI == tank_gui.id) {
    draw_sprite(tank_gui.sprite_index, 0, tx, ty);
  }
    
}
