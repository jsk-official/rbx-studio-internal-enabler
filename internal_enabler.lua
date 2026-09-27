local string_matches = AOBScan("49 6E 74 65 72 6E 61 6C 20 50 65 72 6D 69 73 73 69 6F 6E 20 69 73 20 72 65 71 75 69 72 65 64 20 66 6F 72 20 74 68 69 73 20 66 65 61 74 75 72 65")
local lea_matches = AOBScan("48 8D 15 ?? ?? ?? ??")

if string_matches ~= nil and lea_matches ~= nil then
   local string_addr = getAddress(string_matches[0])

   for i = 0, lea_matches.Count - 1 do
       local instr = getAddress(lea_matches[i])
       local target = instr + 7 + readInteger(instr + 3, true)

       if target == string_addr then
          -- This is wack
          -- I mean, I think it'll survive an update? Hopefully should not change too much
          -- It's not difficult to update this offset anyways

          local RBX_grantInternalPermission = instr - 347
          local bytes = readBytes(RBX_grantInternalPermission, 6, true)

          if bytes[1] == 72 and bytes[2] == 131 and bytes[3] == 236 and bytes[4] == 40 and bytes[5] == 128 and bytes[6] == 61 then
             print("Attempting to call RBX::grantInternalPermission")

             local mem = allocateMemory(4096)
             local built_code = string.format([[
             %s:
             jmp %s
             ]], string.format("%x", mem), string.format("%x", RBX_grantInternalPermission))

             autoAssemble(built_code)
             createRemoteThread(mem)

             print("Done. Close and re-open the current place if nothing happened.")

             break
          else
            print("Bytes do not match. Roblox probably broke something.")
          end
       end
   end
else
    print("Cannot find matches. Roblox probably broke something. Do not know how to find RBX::grantInternalPermission")
end
