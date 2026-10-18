#include <stdio.h>
#include <stdint.h>

// Declare external functions implemented in pure assembly (asm_math.asm)
extern int64_t fast_multiply_add(int64_t a, int64_t b, int64_t c);
extern int64_t fast_factorial(int64_t n);

int main() {
    int64_t fma_res = fast_multiply_add(10, 5, 7);
    int64_t fact_res = fast_factorial(5);

    printf("[C host] fast_multiply_add(10, 5, 7) = %ld (Expected: 57)\n", fma_res);
    printf("[C host] fast_factorial(5) = %ld (Expected: 120)\n", fact_res);

    if (fma_res == 57 && fact_res == 120) {
        printf("[+] C to Assembly FFI verification PASSED!\n");
        return 0;
    }
    return 1;
}
