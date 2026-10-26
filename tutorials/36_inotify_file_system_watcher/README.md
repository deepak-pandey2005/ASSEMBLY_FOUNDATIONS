# Module 36: Linux Kernel Inotify File-System Watcher (`sys_inotify`)

## 🎯 Objectives
- Understand the Linux kernel **inotify** subsystem:
  - An event-driven mechanism for monitoring file-system changes (file creation, modification, deletion, attribute updates, directory access) directly from kernel space.
  - Replaces inefficient, high-CPU user-space polling loops with zero-overhead kernel wait events.
- Master the inotify system call trio in pure x86-64 assembly:
  - **`sys_inotify_init1`** (Syscall 294): Creates an inotify instance and returns a file descriptor.
    - Flags: `IN_NONBLOCK` (`0x00000800`), `IN_CLOEXEC` (`0x00080000`).
  - **`sys_inotify_add_watch`** (Syscall 254): Attaches a file or directory path to the watch list with specific event masks.
    - Event masks:
      - `IN_CREATE` (`0x00000100`): File/directory created in watched directory.
      - `IN_MODIFY` (`0x00000002`): File was modified.
      - `IN_DELETE` (`0x00000200`): File/directory deleted from watched directory.
      - `IN_ALL_EVENTS`: Bitwise combination of all events.
  - **`sys_inotify_rm_watch`** (Syscall 255): Removes an active watch descriptor.
- Parse the binary **`struct inotify_event`** from `sys_read`:
  ```c
  struct inotify_event {
      int      wd;       /* Watch descriptor (4 bytes) */
      uint32_t mask;     /* Mask of events (4 bytes) */
      uint32_t cookie;   /* Unique cookie associating related events (4 bytes) */
      uint32_t len;      /* Length of name field including null bytes (4 bytes) */
      char     name[];   /* Optional null-terminated filename */
  };
  ```
- Implement an automated end-to-end watcher demonstration:
  - Initializes inotify, watches a target directory, triggers file creation via assembly syscalls, reads the binary inotify event packet, parses the filename and event mask, and outputs the result in ANSI formatted text.

---

## 1. The inotify Event Loop Lifecycle

```text
 1. inotify_fd = sys_inotify_init1(0)
 2. wd = sys_inotify_add_watch(inotify_fd, "./watch_dir", IN_CREATE | IN_MODIFY | IN_DELETE)
 3. [Kernel Event Occurs: File "test.txt" created]
 4. num_bytes = sys_read(inotify_fd, buffer, sizeof(buffer))
 5. Parse struct inotify_event { wd, mask, cookie, len, name }
 6. sys_inotify_rm_watch(inotify_fd, wd)
 7. sys_close(inotify_fd)
```

---

## 2. Hands-on Code Files in this Module
- [`inotify_watcher.asm`](file:///home/deepak/OPENSOURCE/ASSEMBLY_FOUNDATIONS/tutorials/36_inotify_file_system_watcher/inotify_watcher.asm) - Complete file system event monitoring engine in pure x86-64 assembly with zero external dependencies.
