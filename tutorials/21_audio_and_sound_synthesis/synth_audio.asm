; ==============================================================================
; Program: synth_audio.asm
; Description: Generates a genuine 44-byte RIFF/WAVE 8kHz mono audio file (sound.wav)
; Architecture: x86-64 Linux
; Assembler: NASM
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
    jl  .high_wave

.low_wave:
    mov byte [rdi], 64                  ; Low amplitude (quiet baseline)
    jmp .next_sample

.high_wave:
    mov byte [rdi], 192                 ; High amplitude

.next_sample:
    inc rdi
    inc rcx
    jmp .synth_loop

.done_synth:
    ; --------------------------------------------------------------------------
    ; 2. WRITE WAV FILE TO DISK: sys_open("sound.wav", O_CREAT|O_WRONLY|O_TRUNC, 0644)
    ; --------------------------------------------------------------------------
    mov rax, 2                          ; sys_open
    lea rdi, [filename]
    mov rsi, 577                        ; O_CREAT | O_WRONLY | O_TRUNC
    mov rdx, 420                        ; 0644
    syscall

    cmp rax, 0
    jl  .error
    mov [fd], rax

    ; Write 44-byte WAV header
    mov rax, 1                          ; sys_write
    mov rdi, [fd]
    lea rsi, [wav_header]
    mov rdx, wav_hdr_len
    syscall

    ; Write synthesized PCM audio data
    mov rax, 1                          ; sys_write
    mov rdi, [fd]
    lea rsi, [audio_buf]
    mov rdx, TOTAL_SAMPLES
    syscall

    ; Close file
    mov rax, 3                          ; sys_close
    mov rdi, [fd]
    syscall

    ; Print success message
    mov rax, 1
    mov rdi, 1
    lea rsi, [msg_done]
    mov rdx, len_done
    syscall

    ; Clean exit
    mov rax, 60
    xor rdi, rdi
    syscall

.error:
    mov rax, 60
    mov rdi, 1
    syscall
