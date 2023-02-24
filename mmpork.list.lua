cpu = manager.machine.devices[":maincpu"];
p = cpu.spaces["program"];
ENEMIES_ADDR = 0xc4b7c9c;
ENEMIES_COUNT = 256; -- In pinkswts this is 256, however I get a weirdo entry showing up at 244 so something is off.
ENEMY_SIZE = 200;

local BOSSES = {
  [73] = {[0] = {4,160,{[1] = 3600}}, ['hps_for_phase'] = {[1] = {13}} }, -- midboss 1 "mshipa"
  [80] = {[0] = {4,160,{[1] = 3600}}, ['hps_for_phase'] = {[1] = {[1] = 22, [2] = 0}} },  -- boss 1 "st1boss" phase one = part_id 22
  [74] = {[0] = {4,160,{[1] = 3600}} }, -- midboss 2 "mshipa"
  [81] = {[0] = {4,160,{[1] = 3600}} }, -- boss 2 "mshipa" part 31, then 5
  [75] = {[0] = {4,160,{[1] = 3600}} }, -- midboss 3 "mshipa"
  [82] = {[0] = {4,160,{[1] = 3600}} }, -- boss 3 "mshipa" part_id 0 for 1st phase, then part_id 1 for second phase. phase value stays at 1.
  [76] = {[0] = {4,160,{[1] = 3600}} }, -- midboss 4.1 "mshipa" part_id 45 then part_id 0
  [77] = {[0] = {4,160,{[1] = 3600}} }, -- midboss 4.2 "mshipa" just part_id 0
  [83] = {[0] = {4,160,{[1] = 3600}} }, -- boss 4 62 -> 48 (phase 3 on 0, on 48 phase = 4?) -> 0 (phase = 5)
  [79] = {[0] = {4,160,{[1] = 3600}} }, -- midboss 5.1 seems like it's just 0
  [78] = {[0] = {4,160,{[1] = 3600}} }, -- midboss 5.2 seems like it's just 0
  [21] = {[0] = {4,160,{[1] = 3600}} }, -- stage 5 THE PAINTING part_id 3
  [84] = {[0] = {4,160,{[1] = 3600}} }, -- boss 5 phase 1 = part_id 56, phase 3 part_id 26, phase 5 = part_id 0, phase 2 = part_id 42
}

function list_enemies()
  boss_hp = -1;
  boss_part_hp_override = -1;
  enemy_phase = -1
  for enemy_idx=0,ENEMIES_COUNT-1 do
    enemy_ptr = ENEMIES_ADDR + (enemy_idx * ENEMY_SIZE);
    enemy_type = p:read_u32(enemy_ptr + 8);
    enemy_part_id = p:read_u32(enemy_ptr + 12);
    enemy_part_id2 = p:read_u32(enemy_ptr + 16);
    enemy_status = p:read_u32(enemy_ptr);
    enemy_hitpoints = p:read_u16(enemy_ptr + 68); -- this is right, I blew up midboss1 when the HP (on some enemy) hit zero
    --enemy_phase = p:read_u8(enemy_ptr + 192);
    if enemy_status & 0x80000000 ~= 0 and enemy_status & 0x4000 == 0 and enemy_hitpoints > 0 then
      print(enemy_idx .. " base: " .. enemy_status .. " t: " .. enemy_type .. " part_id: " .. enemy_part_id .. " part_id2: " .. enemy_part_id2 .. " hp: " .. enemy_hitpoints .. " phase: " .. enemy_phase);
    end
    if BOSSES[enemy_type] then
      if BOSSES[enemy_type][enemy_part_id] then
        enemy_phase = p:read_u8(enemy_ptr + 180);
      else
        break
      end
      hps_for_phase = BOSSES[enemy_type]['hps_for_phase'][enemy_phase]
      print('HPs for phase ' .. enemy_phase .. ': ' .. hps_for_phase[1]);
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
