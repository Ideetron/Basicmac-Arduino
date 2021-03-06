// Copyright (C) 2016-2019 Semtech (International) AG. All rights reserved.
//
// This file is subject to the terms and conditions defined in file 'LICENSE',
// which is part of this source code package.

//#include "bootloader.h"

#define LPTIM_ISR       0x00
#define LPTIM_ICR       0x04

#define LPTIM_ARRM_BIT  1

#define LPTIM1_IRQn_BIT 13

#define MASK(n) (1 << (n ## _BIT))      // bit mask


    // --------------------------------------------
    // assembler settings
    .syntax unified
    .thumb


    // --------------------------------------------
    // u4_t sleep_htt (u4_t hticks, u4_t htt);
    //
    //.section .fastcode.tim22_sync,"ax",%progbits
    .section .fastcode.sleep_htt,"ax",%progbits
    .thumb_func
sleep_htt:
        push {r4-r6,lr}

        // r0 - hticks
        // r1 - htt
        // r2 - LPTIM1 base
        ldr r2, .L_LPTIM1_BASE
        // r3 - ARRM mask
        movs r3, #MASK(LPTIM_ARRM)
        // r4 - NVIC ICPR
        ldr r4, .L_NVIC_ICPR
        // r5 - LPTIM1_IRQn mask
        movs r5, #1
        lsls r5, #LPTIM1_IRQn_BIT
        // r6 - scratch
        
        b 3f

        // zzz
    1:  wfi

        // read and check ISR
        ldr r6, [r2, #LPTIM_ISR]
        tst r6, r3
        beq 4f

        // clear ISR
        str r3, [r2, #LPTIM_ICR]
    2:  ldr r6, [r2, #LPTIM_ISR]
        tst r6, r3
        bne 2b

        // clear NVIC
        str r5, [r4, #0]

        // increment hticks
        adds r0, #1

        // compare hticks to htt
    3:  cmp r0, r1
        bmi 1b

    4:  pop {r4-r6,pc}

    .p2align(2)
.L_LPTIM1_BASE:
    .word 0x40007c00
.L_NVIC_ICPR:
    .word 0xE000E100+0x180

    .size sleep_htt, .-sleep_htt
    .global sleep_htt
