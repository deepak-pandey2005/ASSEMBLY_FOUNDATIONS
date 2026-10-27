#!/usr/bin/env bash
# ==============================================================================
# Assembly Foundations - Master Standalone Projects Verification Suite
# Runs automated end-to-end self-tests across all 12 standalone real-world projects.
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
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${C_CYAN}======================================================================${C_RESET}"
echo -e "${C_BOLD}   ASSEMBLY FOUNDATIONS - STANDALONE REAL-WORLD PROJECTS TEST SUITE   ${C_RESET}"
echo -e "${C_CYAN}======================================================================${C_RESET}"
echo ""

PROJECTS=(
    "01_interactive_snake_game:Terminal Snake Game Engine"
    "02_http_server_daemon:HTTP/1.1 Web Server Daemon"
    "03_wav_audio_generator:16-bit Stereo WAV Audio Synthesizer"
    "04_raytracer_ppm:3D Sphere Raytracer & PPM Generator"
    "05_base64_file_converter:Streaming Base64 File Converter CLI"
    "06_sha256_hasher:NIST FIPS 180-4 SHA-256 Hasher"
    "07_mmap_key_value_store:Persistent Memory-Mapped Key-Value Store"
    "08_json_parser:RFC 8259 JSON Lexer & Parser"
    "09_chip8_emulator:CHIP-8 Virtual Machine & CPU Interpreter"
    "10_dns_client:RFC 1035 UDP DNS Client Query Tool"
    "11_tar_archiver:POSIX ustar tar Archiver & Extractor"
    "12_brainfuck_jit:Pure Assembly Brainfuck JIT Compiler"
)

TOTAL=${#PROJECTS[@]}
PASSED=0
FAILED=0

for item in "${PROJECTS[@]}"; do
    DIR_NAME="${item%%:*}"
    TITLE="${item##*:}"
    PROJ_PATH="$SCRIPT_DIR/$DIR_NAME"

    echo -e "${C_BOLD}[*] Testing Project [${DIR_NAME}]: ${TITLE}...${C_RESET}"

    if [ ! -d "$PROJ_PATH" ]; then
        echo -e "${C_RED}[FAIL] Directory $PROJ_PATH does not exist!${C_RESET}"
        FAILED=$((FAILED + 1))
        continue
    fi

    # Run clean build and test in subshell
    if (cd "$PROJ_PATH" && make clean >/dev/null 2>&1 && make test); then
        echo -e "${C_GREEN}[PASS] Project ${DIR_NAME} passed verification!${C_RESET}"
        PASSED=$((PASSED + 1))
    else
        echo -e "${C_RED}[FAIL] Project ${DIR_NAME} failed verification!${C_RESET}"
        FAILED=$((FAILED + 1))
    fi
    echo -e "${C_CYAN}----------------------------------------------------------------------${C_RESET}"
done

echo ""
echo -e "${C_CYAN}======================================================================${C_RESET}"
echo -e "${C_BOLD}                       FINAL TEST SUMMARY                             ${C_RESET}"
echo -e "${C_CYAN}======================================================================${C_RESET}"
echo -e " Total Projects Evaluated : ${C_BOLD}${TOTAL}${C_RESET}"
echo -e " Successfully Passed      : ${C_GREEN}${PASSED}${C_RESET}"
echo -e " Failed                   : ${C_RED}${FAILED}${C_RESET}"
echo -e "${C_CYAN}======================================================================${C_RESET}"

if [ "$FAILED" -eq 0 ]; then
    echo -e "${C_GREEN}${C_BOLD}[+] ALL 12 STANDALONE PROJECTS VERIFIED AND WORKING PROPERLY!${C_RESET}"
    exit 0
else
    echo -e "${C_RED}${C_BOLD}[-] SOME PROJECTS FAILED VERIFICATION!${C_RESET}"
    exit 1
fi
