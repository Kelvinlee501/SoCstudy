#!/bin/tcsh -f

#====================================
# Argument
#====================================
set only_comp = 0 
set only_elab = 0 

if ($#argv < 1) then
    echo "[arun] You have to execute this arun script with argument."
    echo "[arun] Please check available argument by using '-help' option"
    exit
else
    if ($argv[1] == "-help") then
        echo "=========================================="
        echo " arun usage                               "
        echo " options :                                "
        echo "     compile : compile design             "
        echo "      => ex) arun compile                 "
        echo "     elab    : elaborate design           "
        echo "      => ex) arun elab                    "
        echo "     sim     : simulation                 "
        echo "      => ex) arun sim <test_name>         "
        echo "=========================================="
    else if ($argv[1] == "compile") then
        set only_comp = 1
    else
        echo "[arun] Illegal argument."
        echo "[arun] Please check availabel argument by using '-help' opeion"
    endif
endif

#====================================
# Set variable for simulation
#====================================
set VCODE_PATH = ${PRJ_DESIGN}/IP/I2C_IF/RTL/vcode.f 
set WORKING_NAME = compile

if ($argv[3] == "Questasim") then
    set USING_TOOL = "Questasim" 
    set EXE = ".exe"
    set VLIB_SCR     = "vlib${EXE} ${WORKING_NAME}"
    set VLOG_LIB_SCR = "vlog${EXE} -work ${WORKING_NAME} -f ./${WORKING_NAME}/dut_vcode.f -logfile ./${WORKING_NAME}/comp.lib.log +define+${USING_TOOL}"
else
    set USING_TOOL = "iverilog"
    set IVLOG_COMP_SCR  = "iverilog -g2012 -o ./${WORKING_NAME}/output/testoutput.out -f ./${WORKING_NAME}/dut_vcode.f -v | tee ./${WORKING_NAME}/compile.log"
endif

#====================================
# Compile
#====================================
if($argv[1] == "compile" && $only_comp == 1) then
    if ($USING_TOOL == "Questasim") then
        $VLIB_SCR
        cp -rpf ${VCODE_PATH} ./${WORKING_NAME}/dut_vcode.f
        sed -i 's/\$//g' ./${WORKING_NAME}/dut_vcode.f
        sed -i "s|PRJ_DESIGN|$PRJ_DESIGN|g" ./${WORKING_NAME}/dut_vcode.f
        $VLOG_LIB_SCR
    else
        if (! -d ./${WORKING_NAME}) then
            mkdir ./${WORKING_NAME}
        endif

        if (! -d ./${WORKING_NAME}/output) then
            mkdir ./${WORKING_NAME}/output
        endif
        cp -rpf ${VCODE_PATH} ./${WORKING_NAME}/dut_vcode.f
        sed -i 's/\$//g' ./${WORKING_NAME}/dut_vcode.f
        sed -i "s|PRJ_DESIGN|$PRJ_DESIGN|g" ./${WORKING_NAME}/dut_vcode.f
        iverilog -g2012 -o ./${WORKING_NAME}/output/testoutput.out -f ./${WORKING_NAME}/dut_vcode.f -v | tee ./${WORKING_NAME}/compile.log
    endif
endif
