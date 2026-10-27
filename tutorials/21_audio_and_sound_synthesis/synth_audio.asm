; ==============================================================================
; Program: synth_audio.asm
; Description: Generates a genuine 44-byte RIFF/WAVE 8kHz mono audio file (sound.wav)
; Architecture: x86-64 Linux
; Assembler: NASM
;
; ==============================================================================
; Equivalent C Code:
; ------------------------------------------------------------------------------
; #include <fcntl.h>
; #include <stdint.h>
; #include <unistd.h>
;
; #pragma pack(push, 1)
; struct WavHeader {
;     char     riff[4];        // "RIFF"
;     uint32_t chunk_size;     // total_size - 8
;     char     wave[4];        // "WAVE"
;     char     fmt[4];         // "fmt "
;     uint32_t subchunk1_size; // 16 for PCM
;     uint16_t audio_format;   // 1 for PCM
;     uint16_t num_channels;   // 1 for Mono
;     uint32_t sample_rate;    // 8000 Hz
;     uint32_t byte_rate;      // 8000 * 1 * 1 = 8000
;     uint16_t block_align;    // 1
;     uint16_t bits_per_sample;// 8
;     char     data[4];        // "data"
;     uint32_t subchunk2_size; // 16000
; };
; #pragma pack(pop)
;
; int main(void) {
;     // 1. Synthesize square wave (440 Hz concert pitch at 8kHz)
;     uint8_t audio_buf[16000];
;     for (int i = 0; i < 16000; i++) {
;         audio_buf[i] = (i % 18 < 9) ? 200 : 50; // Square wave
;     }
;
;     // 2. Open sound.wav and write WAV header + audio buffer
;     int fd = open("sound.wav", O_CREAT | O_WRONLY | O_TRUNC, 0644);
;     // ... write header and audio_buf ...
;     close(fd);
;     write(STDOUT_FILENO, "[+] Generated 2-second synthetic audio file: sound.wav\n", 55);
;     _exit(0);
; }
; ==============================================================================

section .data
    filename: db "sound.wav", 0

    ; 8000 samples/sec * 2 seconds = 16,000 bytes of audio data
    TOTAL_SAMPLES equ 16000
    FILE_SIZE_MINUS_8 equ 44 - 8 + TOTAL_SAMPLES

    ; 44-byte standard RIFF/WAVE Header
    wav_header:
        db "RIFF"
        dd FILE_SIZE_MINUS_8            ; ChunkSize: Total File Size - 8
        db "WAVE"
        db "fmt "
        dd 16                           ; Subchunk1Size (16 for PCM)
        dw 1                            ; AudioFormat (1 = PCM)
        dw 1                            ; NumChannels (1 = Mono)
        dd 8000                         ; SampleRate (8000 Hz)
        dd 8000                         ; ByteRate (8000 * 1 * 1)
        dw 1                            ; BlockAlign (1 byte per sample)
        dw 8                            ; BitsPerSample (8-bit unsigned PCM)
        db "data"
        dd TOTAL_SAMPLES                ; Subchunk2Size (16,000 bytes)
    wav_hdr_len: equ $ - wav_header

    msg_done: db "[+] Generated 2-second synthetic audio file: sound.wav", 10
    len_done: equ $ - msg_done

section .bss
    fd:        resq 1
    audio_buf: resb TOTAL_SAMPLES

section .text
global _start

_start:
    ; --------------------------------------------------------------------------
    ; 1. SYNTHESIZE AUDIO WAVEFORM (Square Wave at ~440 Hz concert pitch A)
    ; Period = 8000 / 440 ≈ 18 samples per cycle (9 samples high, 9 samples low)
    ; C equivalent:
    ;   for (int i = 0; i < 16000; i++) {
    ;       audio_buf[i] = (i % 18 < 9) ? 200 : 50;
    ;   }
    ; --------------------------------------------------------------------------
    lea rdi, [audio_buf]
    xor rcx, rcx                        ; Sample counter = 0

.synth_loop:
    cmp rcx, TOTAL_SAMPLES
    jge .done_synth

    ; rcx % 18
    mov rax, rcx
    xor rdx, rdx
    mov rbx, 18
    div rbx                             ; remainder is in RDX (0..17)

    cmp rdx, 9
    jl .wave_high

.wave_low:
    mov byte [rdi], 50                  ; Low amplitude phase (value 50)
    jmp .sample_written

.wave_high:
    mov byte [rdi], 200                 ; High amplitude phase (value 200)

.sample_written:
    inc rdi
    inc rcx
    jmp .synth_loop

.done_synth:
    ; --------------------------------------------------------------------------
    ; 2. CREATE AND WRITE sound.wav
    ; C equivalent: int fd = open("sound.wav", O_CREAT|O_WRONLY|O_TRUNC, 0644);
    ; --------------------------------------------------------------------------
    mov rax, 2                          ; sys_open
    lea rdi, [filename]
    mov rsi, 577                        ; O_CREAT(64) | O_WRONLY(1) | O_TRUNC(512)
    mov rdx, 0644o
    syscall

    cmp rax, 0
    jl .error
    mov [fd], rax

    ; --------------------------------------------------------------------------
    ; 3. WRITE 44-BYTE WAV HEADER
    ; C equivalent: write(fd, &wav_header, 44);
    ; --------------------------------------------------------------------------
    mov rax, 1                          ; sys_write
    mov rdi, [fd]
    lea rsi, [wav_header]
    mov rdx, wav_hdr_len
    syscall

    ; --------------------------------------------------------------------------
    ; 4. WRITE 16,000 SAMPLES OF AUDIO DATA
    ; C equivalent: write(fd, audio_buf, 16000);
    ; --------------------------------------------------------------------------
    mov rax, 1                          ; sys_write
    mov rdi, [fd]
    lea rsi, [audio_buf]
    mov rdx, TOTAL_SAMPLES
    syscall

    ; Close file
    mov rax, 3
    mov rdi, [fd]
    syscall

    ; Print success
    mov rax, 1
    mov rdi, 1
    lea rsi, [msg_done]
    mov rdx, len_done
    syscall

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall

.error:
    mov rax, 60
    mov rdi, 1
    syscall
