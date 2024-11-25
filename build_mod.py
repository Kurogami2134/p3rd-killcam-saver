from struct import pack
with open("bin/main", "rb") as file, open("bin/hook", "rb") as hook, open("bin/0068P", "wb") as mod:
    data = file.read()
    mod.write(pack("2i", 0x99D0000, len(data)))
    mod.write(data)

    data = hook.read()
    mod.write(pack("2i", 0x09DC5A74, len(data)))
    mod.write(data)

    mod.write(pack("2i", -1, 0))
