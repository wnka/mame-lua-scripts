cpu = manager.machine.devices[":maincpu"]
mem = cpu.spaces["program"]
s = manager.machine.screens[":screen"]

function draw_hud()
 cnt = string.format("FRAME : %d", mem:read_u32(0x0C4857C4));
 s:draw_text(225, 3, cnt);
 medal_val = mem:read_u8(0xC53F4A7) + 1;
 medal_display = medal_val * 100;
 if medal_val > 10 then
   medal_display = (medal_val - 9) * 1000;
 end
 medal = string.format("NEXT MEDAL : %d", medal_display);
 s:draw_text(225, 10, medal);
end
emu.register_frame_done(draw_hud, "frame")
