; ==============================================================================
; Project: synth.asm
; Description: 16-bit stereo PCM audio synthesizer with decay envelope in pure assembly
; Architecture: x86-64 Linux
; Assembler: NASM
; ==============================================================================

section .data
    filename: db "output.wav", 0

    ; Audio Specifications:
    ; Sample Rate = 44100 Hz, Channels = 2 (Stereo), Bits = 16 (Signed PCM)
    ; Duration = 2 seconds -> Total Frames = 88200
    ; 1 Frame = 2 channels * 2 bytes = 4 bytes
    TOTAL_FRAMES   equ 88200
    TOTAL_PCM_DATA equ TOTAL_FRAMES * 4
    FILE_SIZE_SUB8 equ 44 - 8 + TOTAL_PCM_DATA

    align 4
    wav_header:
        db "RIFF"
        dd FILE_SIZE_SUB8               ; Total Size - 8
        db "WAVE"
        db "fmt "
        dd 16                           ; Subchunk1Size (16 for PCM)
        dw 1                            ; Format: PCM
        dw 2                            ; NumChannels: 2 (Stereo)
        dd 44100                        ; SampleRate
        dd 176400                       ; ByteRate: 44100 * 2 * 2
        dw 4                            ; BlockAlign: 4 bytes per frame
        dw 16                           ; BitsPerSample: 16-bit
        db "data"
        dd TOTAL_PCM_DATA               ; Subchunk2Size: Total PCM bytes
    wav_hdr_len equ $ - wav_header

    msg_done: db "[+] Generated 44.1kHz 16-bit Stereo WAV file: output.wav", 10
    len_done: equ $ - msg_done

section .bss
    fd:        resq 1
    pcm_buffer:resb TOTAL_PCM_DATA

section .text
global _start

_start:
    ; --------------------------------------------------------------------------
    ; 1. GENERATE SYNTHESIZED AUDIO SAMPLES
    ; Channel 1 (Left): ~440 Hz (Period ~100 samples)
    ; Channel 2 (Right): ~660 Hz (Period ~67 samples, Perfect Fifth harmony)
    ; Envelope: Exponential amplitude decay over 88,200 samples
    ; --------------------------------------------------------------------------
    lea rdi, [pcm_buffer]
    xor rcx, rcx                        ; frame index = 0

.synth_loop:
    cmp rcx, TOTAL_FRAMES
    jge .done_synth

    ; Calculate linear decay factor: amp = 16000 * (TOTAL_FRAMES - rcx) / TOTAL_FRAMES
    mov rax, TOTAL_FRAMES
    sub rax, rcx
    imul rax, 14000
    xor rdx, rdx
    mov rbx, TOTAL_FRAMES
    div rbx                             ; rax = current amplitude (0..14000)
    mov r8, rax                         ; r8 = amp

    ; Left Channel: 440 Hz Square Wave (Period = 100)
    mov rax, rcx
    xor rdx, rdx
    mov rbx, 100
    div rbx                             ; rdx = rcx % 100
    cmp rdx, 50
    jl .left_high
    mov r9w, -8000                      ; Negative phase
    jmp .compute_right
.left_high:
    mov r9w, 8000                       ; Positive phase

.compute_right:
    ; Right Channel: 660 Hz (Period = 67)
    mov rax, rcx
    xor rdx, rdx
    mov rbx, 67
    div rbx                             ; rdx = rcx % 67
    cmp rdx, 33
    jl .right_high
    mov r10w, -6000
    jmp .store_frame
.right_high:
    mov r10w, 6000

.store_frame:
    ; Scale with envelope decay: sample = (phase * amp) / 14000
    movsx eax, r9w
    imul eax, r8d
    cdq
    mov ebx, 14000
    idiv ebx
    mov [rdi], ax                       ; Left channel 16-bit sample

    movsx eax, r10w
    imul eax, r8d
    cdq
    mov ebx, 14000
    idiv ebx
    mov [rdi + 2], ax                   ; Right channel 16-bit sample

    add rdi, 4                          ; Next stereo frame (4 bytes)
    inc rcx
    jmp .synth_loop

.done_synth:
    ; --------------------------------------------------------------------------
    ; 2. WRITE WAV FILE TO DISK: sys_open("output.wav", O_CREAT|O_WRONLY|O_TRUNC, 0644)
    ; --------------------------------------------------------------------------
    mov rax, 2                          ; sys_open
    lea rdi, [filename]
    mov rsi, 577                        ; O_CREAT | O_WRONLY | O_TRUNC
    mov rdx, 420                        ; 0644 permissions
    syscall

    cmp rax, 0
    jl .error
    mov [fd], rax

    ; Write Header
    mov rax, 1                          ; sys_write
    mov rdi, [fd]
    lea rsi, [wav_header]
    mov rdx, wav_hdr_len
    syscall

    ; Write Audio Buffer
    mov rax, 1                          ; sys_write
    mov rdi, [fd]
    lea rsi, [pcm_buffer]
    mov rdx, TOTAL_PCM_DATA
    syscall

    ; Close File
    mov rax, 3                          ; sys_close
    mov rdi, [fd]
    syscall

    ; Print Done
    mov rax, 1                          ; sys_write
    mov rdi, 1                          ; stdout
    lea rsi, [msg_done]
    mov rdx, len_done
    syscall

    ; Clean Exit
    mov rax, 60
    xor rdi, rdi
    syscall

.error:
    mov rax, 60
    mov rdi, 1
    syscall
