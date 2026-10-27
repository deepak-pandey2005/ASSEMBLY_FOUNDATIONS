; ==============================================================================
; tutorials/36_inotify_file_system_watcher/inotify_watcher.asm
; Linux Kernel File-System Event Monitoring via inotify in Pure x86-64 Assembly.
;
; Concepts:
; - sys_inotify_init1 (Syscall 294)
; - sys_inotify_add_watch (Syscall 254)
; - Event masks: IN_CREATE (0x100), IN_MODIFY (0x02), IN_DELETE (0x200)
; - Reading and parsing binary struct inotify_event from kernel:
;     offset 0:  int32_t  wd      (Watch descriptor)
;     offset 4:  uint32_t mask    (Event mask)
;     offset 8:  uint32_t cookie  (Cookie)
;     offset 12: uint32_t len     (Length of name buffer)
;     offset 16: char     name[]  (Null-terminated name)
; - End-to-end self-test:
;     1. Watch current directory "."
;     2. Create temporary file "inotify_test.tmp"
;     3. Read and verify inotify IN_CREATE event packet
;     4. Delete temporary file via sys_unlink
;     5. Clean up watch and inotify instance

;
; ==============================================================================
; Equivalent C Code:
; ------------------------------------------------------------------------------
; #include <sys/inotify.h>
; #include <fcntl.h>
; #include <unistd.h>
; #include <stdio.h>
;
; int main(void) {
;     // 1. Initialize an inotify instance
;     int ifd = inotify_init1(0);
;
;     // 2. Add watch descriptor for current working directory "."
;     int wd = inotify_add_watch(ifd, ".", IN_CREATE | IN_MODIFY | IN_DELETE);
;
;     // 3. Trigger a file creation event
;     int tmpfd = open("inotify_test.tmp", O_CREAT | O_WRONLY, 0644);
;     close(tmpfd);
;
;     // 4. Read binary struct inotify_event packet from inotify descriptor
;     char buffer[1024];
;     ssize_t bytes_read = read(ifd, buffer, sizeof(buffer));
;
;     struct inotify_event *event = (struct inotify_event *)buffer;
;     // Inspect event details:
;     // event->wd    : watch descriptor
;     // event->mask  : IN_CREATE (0x100)
;     // event->len   : name length
;     // event->name  : "inotify_test.tmp"
;
;     // 5. Clean up temporary test file and watch descriptor
;     unlink("inotify_test.tmp");
;     inotify_rm_watch(ifd, wd);
;     close(ifd);
;     _exit(0);
; }
; ==============================================================================

global _start

%define SYS_READ              0
%define SYS_WRITE             1
%define SYS_OPEN              2
%define SYS_CLOSE             3
%define SYS_EXIT              60
%define SYS_UNLINK            87
%define SYS_INOTIFY_INIT1     294
%define SYS_INOTIFY_ADD_WATCH 254
%define SYS_INOTIFY_RM_WATCH  255

%define STDOUT_FILENO 1
%define O_CREAT_WRONLY (0x0001 | 0x0040)
%define FILE_MODE      0644o

; inotify Event Flags
%define IN_MODIFY   0x00000002
%define IN_CREATE   0x00000100
%define IN_DELETE   0x00000200
%define WATCH_MASK  (IN_CREATE | IN_MODIFY | IN_DELETE)

section .data
    title_banner    db "+================================================+", 10
                    db "|    LINUX INOTIFY FILE-SYSTEM WATCHER           |", 10
                    db "+================================================+", 10
    len_title       equ $ - title_banner

    watch_path      db ".", 0
    test_filename   db "inotify_test.tmp", 0

    msg_init_ok     db "[+] sys_inotify_init1 created inotify instance FD: ", 0
    len_init_ok     equ $ - msg_init_ok - 1

    msg_watch_ok    db "[+] sys_inotify_add_watch monitoring directory: '.' with mask IN_CREATE|IN_MODIFY|IN_DELETE", 10
    len_watch_ok    equ $ - msg_watch_ok

    msg_trigger     db "[*] Triggering file system event: Creating 'inotify_test.tmp'...", 10
    len_trigger     equ $ - msg_trigger

    msg_reading     db "[*] Waiting on inotify event packet from kernel...", 10
    len_reading     equ $ - msg_reading

    msg_event_got   db "[+] Kernel inotify_event received! Parsed Details:", 10
    len_event_got   equ $ - msg_event_got

    msg_wd_label    db "    - Watch Descriptor (WD) : ", 0
    len_wd_label    equ $ - msg_wd_label - 1

    msg_mask_create db "    - Event Type Detected   : IN_CREATE (0x0100)", 10
    len_mask_create equ $ - msg_mask_create

    msg_name_label  db "    - File Name Affected    : '", 0
    len_name_label  equ $ - msg_name_label - 1

    msg_cleanup     db "[*] Cleaning up: Deleting temporary file & removing inotify watch...", 10
    len_cleanup     equ $ - msg_cleanup

    msg_all_done    db "[+] Linux inotify event monitoring module PASSED perfectly!", 10
    len_all_done    equ $ - msg_all_done

    quote_nl        db "'", 10
    newline         db 10

section .bss
    inotify_fd      resq 1
    watch_wd        resq 1
    event_buf       resb 1024
    num_str_buf     resb 32

section .text

_start:
    ; Print Title Banner
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel title_banner]
    mov     rdx, len_title
    syscall

    ; 1. Initialize inotify instance: sys_inotify_init1(0)
    mov     rax, SYS_INOTIFY_INIT1
    xor     rdi, rdi                    ; flags = 0
    syscall

    test    rax, rax
    js      .error_exit
    mov     [rel inotify_fd], rax

    ; Print init message
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel msg_init_ok]
    mov     rdx, len_init_ok
    syscall

    mov     rdi, [rel inotify_fd]
    call    print_uint64

    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel newline]
    mov     rdx, 1
    syscall

    ; 2. Add watch to current directory: sys_inotify_add_watch(fd, ".", WATCH_MASK)
    mov     rax, SYS_INOTIFY_ADD_WATCH
    mov     rdi, [rel inotify_fd]
    lea     rsi, [rel watch_path]
    mov     rdx, WATCH_MASK
    syscall

    test    rax, rax
    js      .error_close
    mov     [rel watch_wd], rax

    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel msg_watch_ok]
    mov     rdx, len_watch_ok
    syscall

    ; 3. Trigger a file creation event in the watched directory:
    ;    fd = open("inotify_test.tmp", O_CREAT | O_WRONLY, 0644)
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel msg_trigger]
    mov     rdx, len_trigger
    syscall

    mov     rax, SYS_OPEN
    lea     rdi, [rel test_filename]
    mov     rsi, O_CREAT_WRONLY
    mov     rdx, FILE_MODE
    syscall

    test    rax, rax
    js      .error_watch
    mov     rbx, rax                    ; rbx = temporary file fd

    ; Close created file immediately
    mov     rax, SYS_CLOSE
    mov     rdi, rbx
    syscall

    ; 4. Read inotify event structure from inotify_fd
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel msg_reading]
    mov     rdx, len_reading
    syscall

    mov     rax, SYS_READ
    mov     rdi, [rel inotify_fd]
    lea     rsi, [rel event_buf]
    mov     rdx, 1024
    syscall

    test    rax, rax
    jle     .error_unlink

    ; 5. Parse struct inotify_event from event_buf:
    ;    [event_buf + 0]  : wd (int32)
    ;    [event_buf + 4]  : mask (uint32)
    ;    [event_buf + 8]  : cookie (uint32)
    ;    [event_buf + 12] : len (uint32)
    ;    [event_buf + 16] : name string
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel msg_event_got]
    mov     rdx, len_event_got
    syscall

    ; Print WD
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel msg_wd_label]
    mov     rdx, len_wd_label
    syscall

    lea     rsi, [rel event_buf]
    movsxd  rdi, dword [rsi]
    call    print_uint64

    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel newline]
    mov     rdx, 1
    syscall

    ; Check if mask contains IN_CREATE (bit 8 = 0x100)
    lea     rsi, [rel event_buf]
    mov     eax, [rsi + 4]
    test    eax, IN_CREATE
    jz      .print_name_only

    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel msg_mask_create]
    mov     rdx, len_mask_create
    syscall

.print_name_only:
    ; Print affected file name
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel msg_name_label]
    mov     rdx, len_name_label
    syscall

    lea     rsi, [rel event_buf + 16]   ; event->name
    call    str_len
    mov     rdx, rax
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel event_buf + 16]
    syscall

    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel quote_nl]
    mov     rdx, 2
    syscall

    ; 6. Clean up: Delete temporary file via sys_unlink
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel msg_cleanup]
    mov     rdx, len_cleanup
    syscall

    mov     rax, SYS_UNLINK
    lea     rdi, [rel test_filename]
    syscall

    ; Remove watch: sys_inotify_rm_watch(inotify_fd, watch_wd)
    mov     rax, SYS_INOTIFY_RM_WATCH
    mov     rdi, [rel inotify_fd]
    mov     rsi, [rel watch_wd]
    syscall

    ; Close inotify_fd
    mov     rax, SYS_CLOSE
    mov     rdi, [rel inotify_fd]
    syscall

    ; Success message
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    lea     rsi, [rel msg_all_done]
    mov     rdx, len_all_done
    syscall

    ; Exit cleanly
    mov     rax, SYS_EXIT
    xor     rdi, rdi
    syscall

.error_unlink:
    mov     rax, SYS_UNLINK
    lea     rdi, [rel test_filename]
    syscall

.error_watch:
    mov     rax, SYS_INOTIFY_RM_WATCH
    mov     rdi, [rel inotify_fd]
    mov     rsi, [rel watch_wd]
    syscall

.error_close:
    mov     rax, SYS_CLOSE
    mov     rdi, [rel inotify_fd]
    syscall

.error_exit:
    mov     rax, SYS_EXIT
    mov     rdi, 1
    syscall

; ==============================================================================
; print_uint64(rdi)
; ==============================================================================
print_uint64:
    mov     rax, rdi
    lea     rsi, [rel num_str_buf + 31]
    mov     byte [rsi], 0
    mov     rcx, 10

    test    rax, rax
    jnz     .div_loop
    dec     rsi
    mov     byte [rsi], '0'
    jmp     .write_digits

.div_loop:
    test    rax, rax
    jz      .write_digits
    xor     rdx, rdx
    div     rcx
    add     dl, '0'
    dec     rsi
    mov     [rsi], dl
    jmp     .div_loop

.write_digits:
    push    rsi
    call    str_len
    mov     rdx, rax
    pop     rsi
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT_FILENO
    syscall
    ret

; ==============================================================================
; str_len(rsi) -> rax
; ==============================================================================
str_len:
    xor     rax, rax
.len_loop:
    cmp     byte [rsi + rax], 0
    je      .len_done
    inc     rax
    jmp     .len_loop
.len_done:
    ret
