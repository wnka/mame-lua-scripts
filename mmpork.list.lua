cpu = manager.machine.devices[":maincpu"];
p = cpu.spaces["program"];
ENEMIES_ADDR = 0xc4b7c9c;
ENEMIES_COUNT = 256; -- In pinkswts this is 256, however I get a weirdo entry showing up at 244 so something is off.
ENEMY_SIZE = 200;

local BOSSES = {
    [73] = {[13] = {4,160,{[1] = 3600}} }, -- midboss 1 "mshipa"
    [80] = {[22] = {4,160,{[1] = 3600}} },  -- boss 1 "st1boss" phase one = part_id 22
    [74] = {[0] = {4,160,{[1] = 3600}} }, -- midboss 2 "mshipa"
    [81] = {[0] = {4,160,{[1] = 3600}} }, -- boss 2 "mshipa" part 31, then 5
}

function list_enemies()
  boss_hp = -1;
  boss_part_hp_override = -1;
  for enemy_idx=0,ENEMIES_COUNT-1 do
    enemy_ptr = ENEMIES_ADDR + (enemy_idx * ENEMY_SIZE);
    enemy_type = p:read_u32(enemy_ptr + 8);
    enemy_part_id = p:read_u32(enemy_ptr + 12);
    enemy_part_id2 = p:read_u32(enemy_ptr + 16);
    enemy_status = p:read_u32(enemy_ptr);
    enemy_hitpoints = p:read_u16(enemy_ptr + 68); -- this is right, I blew up midboss1 when the HP (on some enemy) hit zero
    --enemy_phase = p:read_u8(enemy_ptr + 180);
    enemy_phase = p:read_u8(enemy_ptr + 192);
    if enemy_status & 0x80000000 ~= 0 and enemy_status & 0x4000 == 0 and enemy_hitpoints > 0 then
      print(enemy_idx .. " base: " .. enemy_status .. " t: " .. enemy_type .. " part_id: " .. enemy_part_id .. " part_id2: " .. enemy_part_id2 .. " hp: " .. enemy_hitpoints .. " phase: " .. enemy_phase);
    end
    if BOSSES[enemy_type] then
      if BOSSES[enemy_type]['hp_overrides'] then
        boss_part_hp_override = BOSSES[enemy_type]['hp_overrides'][enemy_phase];
      end
      if BOSSES[enemy_type]['hp_overrides'] and enemy_part_id == boss_part_hp_override then
        boss_hp = enemy_hitpoints;
      elseif BOSSES[enemy_type][enemy_part_id] then
        boss_hp = enemy_hitpoints;
      end
    end
  end
  print("BOSS HP: " .. boss_hp);
  print("----");
end
emu.register_frame_done(list_enemies, "frame");
