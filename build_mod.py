from struct import pack
with open("bin/main", "rb") as file, open("bin/killcamsv.bin", "wb") as mod:
    data = file.read()
    mod.write(pack("2i", 0x99D0000, len(data)))
    mod.write(data)
    mod.write(pack("2i", -1, 0))
