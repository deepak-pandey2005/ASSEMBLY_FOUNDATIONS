#!/usr/bin/env bash
# ==============================================================================
# Assembly Foundations - Master Tutorial Modules Verification Suite
# Runs automated end-to-end self-tests across all 41 guided tutorial modules.
# ==============================================================================

set -e

# Terminal Colors
C_RESET="\033[0m"
C_BOLD="\033[1m"
C_GREEN="\033[1;32m"
C_RED="\033[1;31m"
C_CYAN="\033[1;36m"
C_YELLOW="\033[1;33m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${C_CYAN}======================================================================${C_RESET}"
echo -e "${C_BOLD}     ASSEMBLY FOUNDATIONS - ALL 41 TUTORIAL MODULES TEST SUITE        ${C_RESET}"
echo -e "${C_CYAN}======================================================================${C_RESET}"
echo ""

MODULE_DIRS=()
for d in "$SCRIPT_DIR"/*/; do
    [ -d "$d" ] || continue
    MODULE_DIRS+=("$(basename "$d")")
done

TOTAL=${#MODULE_DIRS[@]}
PASSED=0
FAILED=0

for dir in "${MODULE_DIRS[@]}"; do
    MOD_PATH="$SCRIPT_DIR/$dir"

    echo -e "${C_BOLD}[*] Testing Module [${dir}]...${C_RESET}"

    if [ ! -f "$MOD_PATH/Makefile" ]; then
        echo -e "${C_RED}[FAIL] No Makefile found in $MOD_PATH!${C_RESET}"
        FAILED=$((FAILED + 1))
        continue
    fi

    if (cd "$MOD_PATH" && make clean >/dev/null 2>&1 && make test); then
        echo -e "${C_GREEN}[PASS] Module ${dir} passed verification!${C_RESET}"
        PASSED=$((PASSED + 1))
    else
        echo -e "${C_RED}[FAIL] Module ${dir} failed verification!${C_RESET}"
        FAILED=$((FAILED + 1))
    fi
    echo -e "${C_CYAN}----------------------------------------------------------------------${C_RESET}"
done

echo ""
echo -e "${C_CYAN}======================================================================${C_RESET}"
echo -e "${C_BOLD}                     MODULES TEST SUMMARY                             ${C_RESET}"
echo -e "${C_CYAN}======================================================================${C_RESET}"
echo -e " Total Modules Evaluated : ${C_BOLD}${TOTAL}${C_RESET}"
echo -e " Successfully Passed     : ${C_GREEN}${PASSED}${C_RESET}"
echo -e " Failed                  : ${C_RED}${FAILED}${C_RESET}"
echo -e "${C_CYAN}======================================================================${C_RESET}"

if [ "$FAILED" -eq 0 ]; then
    echo -e "${C_GREEN}${C_BOLD}[+] ALL 41 TUTORIAL MODULES VERIFIED AND WORKING PROPERLY!${C_RESET}"
    exit 0
else
    echo -e "${C_RED}${C_BOLD}[-] SOME MODULES FAILED VERIFICATION!${C_RESET}"
    exit 1
fi
