cpu = manager.machine.devices[":maincpu"];
p = cpu.spaces["program"];
ENEMIES_ADDR = 0xc416968;
ENEMIES_COUNT = 256;
ENEMY_SIZE = 204;

function list_enemies()
  for enemy_idx=0,ENEMIES_COUNT-1 do
    enemy_ptr = ENEMIES_ADDR + (enemy_idx * ENEMY_SIZE);
    enemy_type = p:read_u32(enemy_ptr + 4);
    enemy_part_id = p:read_u32(enemy_ptr + 8);
    enemy_status = p:read_u32(enemy_ptr);
    enemy_hitpoints = p:read_u16(enemy_ptr + 68); -- this is right, I blew up midboss1 when the HP (on some enemy) hit zero
    if enemy_status & 0x80000000 ~= 0 and enemy_status & 0x4000 == 0 and enemy_hitpoints > 0 then
      print(enemy_idx .. " base: " .. enemy_status .. " t: " .. enemy_type .. " part_id: " .. enemy_part_id .. " hp: " .. enemy_hitpoints);
    end
  end
  print("----");
end
emu.register_frame_done(list_enemies, "frame");
