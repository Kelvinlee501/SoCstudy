#!/bin/csh -f
iverilog -g2012 -o output/I2C_IF.out -f vcode.abs.f -v | tee compile.log
