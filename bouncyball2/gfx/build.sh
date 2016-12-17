#!/bin/sh
lwasm -l -9 -b -o gfx.bin gfx.asm && writecocofile --verbose gfx.dsk gfx.bin