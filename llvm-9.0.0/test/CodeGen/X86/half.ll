; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-linux-gnu -mattr=-f16c -fixup-byte-word-insts=1 \
; RUN:   | FileCheck %s -check-prefixes=CHECK,CHECK-LIBCALL,BWON,BWON-NOF16C
; RUN: llc < %s -mtriple=x86_64-unknown-linux-gnu -mattr=-f16c  -fixup-byte-word-insts=0 \
; RUN:   | FileCheck %s -check-prefixes=CHECK,CHECK-LIBCALL,BWOFF
; RUN: llc < %s -mtriple=x86_64-unknown-linux-gnu -mattr=+f16c -fixup-byte-word-insts=1 \
; RUN:    | FileCheck %s -check-prefixes=CHECK,BWON,BWON-F16C
; RUN: llc < %s -mtriple=i686-unknown-linux-gnu -mattr +sse2 -fixup-byte-word-insts=0  \
; RUN:    | FileCheck %s -check-prefixes=CHECK-I686

define void @test_load_store(half* %in, half* %out) #0 {
; BWON-LABEL: test_load_store:
; BWON:       # %bb.0:
; BWON-NEXT:    movzwl (%rdi), %eax
; BWON-NEXT:    movw %ax, (%rsi)
; BWON-NEXT:    retq
;
; BWOFF-LABEL: test_load_store:
; BWOFF:       # %bb.0:
; BWOFF-NEXT:    movw (%rdi), %ax
; BWOFF-NEXT:    movw %ax, (%rsi)
; BWOFF-NEXT:    retq
;
; CHECK-I686-LABEL: test_load_store:
; CHECK-I686:       # %bb.0:
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; CHECK-I686-NEXT:    movw (%ecx), %cx
; CHECK-I686-NEXT:    movw %cx, (%eax)
; CHECK-I686-NEXT:    retl
  %val = load half, half* %in
  store half %val, half* %out
  ret void
}

define i16 @test_bitcast_from_half(half* %addr) #0 {
; BWON-LABEL: test_bitcast_from_half:
; BWON:       # %bb.0:
; BWON-NEXT:    movzwl (%rdi), %eax
; BWON-NEXT:    retq
;
; BWOFF-LABEL: test_bitcast_from_half:
; BWOFF:       # %bb.0:
; BWOFF-NEXT:    movw (%rdi), %ax
; BWOFF-NEXT:    retq
;
; CHECK-I686-LABEL: test_bitcast_from_half:
; CHECK-I686:       # %bb.0:
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-I686-NEXT:    movw (%eax), %ax
; CHECK-I686-NEXT:    retl
  %val = load half, half* %addr
  %val_int = bitcast half %val to i16
  ret i16 %val_int
}

define void @test_bitcast_to_half(half* %addr, i16 %in) #0 {
; CHECK-LABEL: test_bitcast_to_half:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movw %si, (%rdi)
; CHECK-NEXT:    retq
;
; CHECK-I686-LABEL: test_bitcast_to_half:
; CHECK-I686:       # %bb.0:
; CHECK-I686-NEXT:    movw {{[0-9]+}}(%esp), %ax
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; CHECK-I686-NEXT:    movw %ax, (%ecx)
; CHECK-I686-NEXT:    retl
  %val_fp = bitcast i16 %in to half
  store half %val_fp, half* %addr
  ret void
}

define float @test_extend32(half* %addr) #0 {
; CHECK-LIBCALL-LABEL: test_extend32:
; CHECK-LIBCALL:       # %bb.0:
; CHECK-LIBCALL-NEXT:    movzwl (%rdi), %edi
; CHECK-LIBCALL-NEXT:    jmp __gnu_h2f_ieee # TAILCALL
;
; BWON-F16C-LABEL: test_extend32:
; BWON-F16C:       # %bb.0:
; BWON-F16C-NEXT:    movswl (%rdi), %eax
; BWON-F16C-NEXT:    vmovd %eax, %xmm0
; BWON-F16C-NEXT:    vcvtph2ps %xmm0, %xmm0
; BWON-F16C-NEXT:    retq
;
; CHECK-I686-LABEL: test_extend32:
; CHECK-I686:       # %bb.0:
; CHECK-I686-NEXT:    subl $12, %esp
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-I686-NEXT:    movzwl (%eax), %eax
; CHECK-I686-NEXT:    movl %eax, (%esp)
; CHECK-I686-NEXT:    calll __gnu_h2f_ieee
; CHECK-I686-NEXT:    addl $12, %esp
; CHECK-I686-NEXT:    retl
  %val16 = load half, half* %addr
  %val32 = fpext half %val16 to float
  ret float %val32
}

define double @test_extend64(half* %addr) #0 {
; CHECK-LIBCALL-LABEL: test_extend64:
; CHECK-LIBCALL:       # %bb.0:
; CHECK-LIBCALL-NEXT:    pushq %rax
; CHECK-LIBCALL-NEXT:    movzwl (%rdi), %edi
; CHECK-LIBCALL-NEXT:    callq __gnu_h2f_ieee
; CHECK-LIBCALL-NEXT:    cvtss2sd %xmm0, %xmm0
; CHECK-LIBCALL-NEXT:    popq %rax
; CHECK-LIBCALL-NEXT:    retq
;
; BWON-F16C-LABEL: test_extend64:
; BWON-F16C:       # %bb.0:
; BWON-F16C-NEXT:    movswl (%rdi), %eax
; BWON-F16C-NEXT:    vmovd %eax, %xmm0
; BWON-F16C-NEXT:    vcvtph2ps %xmm0, %xmm0
; BWON-F16C-NEXT:    vcvtss2sd %xmm0, %xmm0, %xmm0
; BWON-F16C-NEXT:    retq
;
; CHECK-I686-LABEL: test_extend64:
; CHECK-I686:       # %bb.0:
; CHECK-I686-NEXT:    subl $12, %esp
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-I686-NEXT:    movzwl (%eax), %eax
; CHECK-I686-NEXT:    movl %eax, (%esp)
; CHECK-I686-NEXT:    calll __gnu_h2f_ieee
; CHECK-I686-NEXT:    addl $12, %esp
; CHECK-I686-NEXT:    retl
  %val16 = load half, half* %addr
  %val32 = fpext half %val16 to double
  ret double %val32
}

define void @test_trunc32(float %in, half* %addr) #0 {
; CHECK-LIBCALL-LABEL: test_trunc32:
; CHECK-LIBCALL:       # %bb.0:
; CHECK-LIBCALL-NEXT:    pushq %rbx
; CHECK-LIBCALL-NEXT:    movq %rdi, %rbx
; CHECK-LIBCALL-NEXT:    callq __gnu_f2h_ieee
; CHECK-LIBCALL-NEXT:    movw %ax, (%rbx)
; CHECK-LIBCALL-NEXT:    popq %rbx
; CHECK-LIBCALL-NEXT:    retq
;
; BWON-F16C-LABEL: test_trunc32:
; BWON-F16C:       # %bb.0:
; BWON-F16C-NEXT:    vcvtps2ph $4, %xmm0, %xmm0
; BWON-F16C-NEXT:    vmovd %xmm0, %eax
; BWON-F16C-NEXT:    movw %ax, (%rdi)
; BWON-F16C-NEXT:    retq
;
; CHECK-I686-LABEL: test_trunc32:
; CHECK-I686:       # %bb.0:
; CHECK-I686-NEXT:    pushl %esi
; CHECK-I686-NEXT:    subl $8, %esp
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %esi
; CHECK-I686-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-I686-NEXT:    movss %xmm0, (%esp)
; CHECK-I686-NEXT:    calll __gnu_f2h_ieee
; CHECK-I686-NEXT:    movw %ax, (%esi)
; CHECK-I686-NEXT:    addl $8, %esp
; CHECK-I686-NEXT:    popl %esi
; CHECK-I686-NEXT:    retl
  %val16 = fptrunc float %in to half
  store half %val16, half* %addr
  ret void
}

define void @test_trunc64(double %in, half* %addr) #0 {
; CHECK-LABEL: test_trunc64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    pushq %rbx
; CHECK-NEXT:    movq %rdi, %rbx
; CHECK-NEXT:    callq __truncdfhf2
; CHECK-NEXT:    movw %ax, (%rbx)
; CHECK-NEXT:    popq %rbx
; CHECK-NEXT:    retq
;
; CHECK-I686-LABEL: test_trunc64:
; CHECK-I686:       # %bb.0:
; CHECK-I686-NEXT:    pushl %esi
; CHECK-I686-NEXT:    subl $8, %esp
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %esi
; CHECK-I686-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-I686-NEXT:    movsd %xmm0, (%esp)
; CHECK-I686-NEXT:    calll __truncdfhf2
; CHECK-I686-NEXT:    movw %ax, (%esi)
; CHECK-I686-NEXT:    addl $8, %esp
; CHECK-I686-NEXT:    popl %esi
; CHECK-I686-NEXT:    retl
  %val16 = fptrunc double %in to half
  store half %val16, half* %addr
  ret void
}

define i64 @test_fptosi_i64(half* %p) #0 {
; CHECK-LIBCALL-LABEL: test_fptosi_i64:
; CHECK-LIBCALL:       # %bb.0:
; CHECK-LIBCALL-NEXT:    pushq %rax
; CHECK-LIBCALL-NEXT:    movzwl (%rdi), %edi
; CHECK-LIBCALL-NEXT:    callq __gnu_h2f_ieee
; CHECK-LIBCALL-NEXT:    cvttss2si %xmm0, %rax
; CHECK-LIBCALL-NEXT:    popq %rcx
; CHECK-LIBCALL-NEXT:    retq
;
; BWON-F16C-LABEL: test_fptosi_i64:
; BWON-F16C:       # %bb.0:
; BWON-F16C-NEXT:    movswl (%rdi), %eax
; BWON-F16C-NEXT:    vmovd %eax, %xmm0
; BWON-F16C-NEXT:    vcvtph2ps %xmm0, %xmm0
; BWON-F16C-NEXT:    vcvttss2si %xmm0, %rax
; BWON-F16C-NEXT:    retq
;
; CHECK-I686-LABEL: test_fptosi_i64:
; CHECK-I686:       # %bb.0:
; CHECK-I686-NEXT:    subl $12, %esp
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-I686-NEXT:    movzwl (%eax), %eax
; CHECK-I686-NEXT:    movl %eax, (%esp)
; CHECK-I686-NEXT:    calll __gnu_h2f_ieee
; CHECK-I686-NEXT:    fstps (%esp)
; CHECK-I686-NEXT:    calll __fixsfdi
; CHECK-I686-NEXT:    addl $12, %esp
; CHECK-I686-NEXT:    retl
  %a = load half, half* %p, align 2
  %r = fptosi half %a to i64
  ret i64 %r
}

define void @test_sitofp_i64(i64 %a, half* %p) #0 {
; CHECK-LIBCALL-LABEL: test_sitofp_i64:
; CHECK-LIBCALL:       # %bb.0:
; CHECK-LIBCALL-NEXT:    pushq %rbx
; CHECK-LIBCALL-NEXT:    movq %rsi, %rbx
; CHECK-LIBCALL-NEXT:    cvtsi2ss %rdi, %xmm0
; CHECK-LIBCALL-NEXT:    callq __gnu_f2h_ieee
; CHECK-LIBCALL-NEXT:    movw %ax, (%rbx)
; CHECK-LIBCALL-NEXT:    popq %rbx
; CHECK-LIBCALL-NEXT:    retq
;
; BWON-F16C-LABEL: test_sitofp_i64:
; BWON-F16C:       # %bb.0:
; BWON-F16C-NEXT:    vcvtsi2ss %rdi, %xmm0, %xmm0
; BWON-F16C-NEXT:    vcvtps2ph $4, %xmm0, %xmm0
; BWON-F16C-NEXT:    vmovd %xmm0, %eax
; BWON-F16C-NEXT:    movw %ax, (%rsi)
; BWON-F16C-NEXT:    retq
;
; CHECK-I686-LABEL: test_sitofp_i64:
; CHECK-I686:       # %bb.0:
; CHECK-I686-NEXT:    pushl %esi
; CHECK-I686-NEXT:    subl $24, %esp
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %esi
; CHECK-I686-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-I686-NEXT:    movlps %xmm0, {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    fildll {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    fstps {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-I686-NEXT:    movss %xmm0, (%esp)
; CHECK-I686-NEXT:    calll __gnu_f2h_ieee
; CHECK-I686-NEXT:    movw %ax, (%esi)
; CHECK-I686-NEXT:    addl $24, %esp
; CHECK-I686-NEXT:    popl %esi
; CHECK-I686-NEXT:    retl
  %r = sitofp i64 %a to half
  store half %r, half* %p
  ret void
}

define i64 @test_fptoui_i64(half* %p) #0 {
; CHECK-LIBCALL-LABEL: test_fptoui_i64:
; CHECK-LIBCALL:       # %bb.0:
; CHECK-LIBCALL-NEXT:    pushq %rax
; CHECK-LIBCALL-NEXT:    movzwl (%rdi), %edi
; CHECK-LIBCALL-NEXT:    callq __gnu_h2f_ieee
; CHECK-LIBCALL-NEXT:    movss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; CHECK-LIBCALL-NEXT:    movaps %xmm0, %xmm2
; CHECK-LIBCALL-NEXT:    subss %xmm1, %xmm2
; CHECK-LIBCALL-NEXT:    cvttss2si %xmm2, %rax
; CHECK-LIBCALL-NEXT:    movabsq $-9223372036854775808, %rcx # imm = 0x8000000000000000
; CHECK-LIBCALL-NEXT:    xorq %rax, %rcx
; CHECK-LIBCALL-NEXT:    cvttss2si %xmm0, %rax
; CHECK-LIBCALL-NEXT:    ucomiss %xmm1, %xmm0
; CHECK-LIBCALL-NEXT:    cmovaeq %rcx, %rax
; CHECK-LIBCALL-NEXT:    popq %rcx
; CHECK-LIBCALL-NEXT:    retq
;
; BWON-F16C-LABEL: test_fptoui_i64:
; BWON-F16C:       # %bb.0:
; BWON-F16C-NEXT:    movswl (%rdi), %eax
; BWON-F16C-NEXT:    vmovd %eax, %xmm0
; BWON-F16C-NEXT:    vcvtph2ps %xmm0, %xmm0
; BWON-F16C-NEXT:    vmovss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; BWON-F16C-NEXT:    vsubss %xmm1, %xmm0, %xmm2
; BWON-F16C-NEXT:    vcvttss2si %xmm2, %rax
; BWON-F16C-NEXT:    movabsq $-9223372036854775808, %rcx # imm = 0x8000000000000000
; BWON-F16C-NEXT:    xorq %rax, %rcx
; BWON-F16C-NEXT:    vcvttss2si %xmm0, %rax
; BWON-F16C-NEXT:    vucomiss %xmm1, %xmm0
; BWON-F16C-NEXT:    cmovaeq %rcx, %rax
; BWON-F16C-NEXT:    retq
;
; CHECK-I686-LABEL: test_fptoui_i64:
; CHECK-I686:       # %bb.0:
; CHECK-I686-NEXT:    subl $12, %esp
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-I686-NEXT:    movzwl (%eax), %eax
; CHECK-I686-NEXT:    movl %eax, (%esp)
; CHECK-I686-NEXT:    calll __gnu_h2f_ieee
; CHECK-I686-NEXT:    fstps (%esp)
; CHECK-I686-NEXT:    calll __fixunssfdi
; CHECK-I686-NEXT:    addl $12, %esp
; CHECK-I686-NEXT:    retl
  %a = load half, half* %p, align 2
  %r = fptoui half %a to i64
  ret i64 %r
}

define void @test_uitofp_i64(i64 %a, half* %p) #0 {
; CHECK-LIBCALL-LABEL: test_uitofp_i64:
; CHECK-LIBCALL:       # %bb.0:
; CHECK-LIBCALL-NEXT:    pushq %rbx
; CHECK-LIBCALL-NEXT:    movq %rsi, %rbx
; CHECK-LIBCALL-NEXT:    testq %rdi, %rdi
; CHECK-LIBCALL-NEXT:    js .LBB10_1
; CHECK-LIBCALL-NEXT:  # %bb.2:
; CHECK-LIBCALL-NEXT:    cvtsi2ss %rdi, %xmm0
; CHECK-LIBCALL-NEXT:    jmp .LBB10_3
; CHECK-LIBCALL-NEXT:  .LBB10_1:
; CHECK-LIBCALL-NEXT:    movq %rdi, %rax
; CHECK-LIBCALL-NEXT:    shrq %rax
; CHECK-LIBCALL-NEXT:    andl $1, %edi
; CHECK-LIBCALL-NEXT:    orq %rax, %rdi
; CHECK-LIBCALL-NEXT:    cvtsi2ss %rdi, %xmm0
; CHECK-LIBCALL-NEXT:    addss %xmm0, %xmm0
; CHECK-LIBCALL-NEXT:  .LBB10_3:
; CHECK-LIBCALL-NEXT:    callq __gnu_f2h_ieee
; CHECK-LIBCALL-NEXT:    movw %ax, (%rbx)
; CHECK-LIBCALL-NEXT:    popq %rbx
; CHECK-LIBCALL-NEXT:    retq
;
; BWON-F16C-LABEL: test_uitofp_i64:
; BWON-F16C:       # %bb.0:
; BWON-F16C-NEXT:    testq %rdi, %rdi
; BWON-F16C-NEXT:    js .LBB10_1
; BWON-F16C-NEXT:  # %bb.2:
; BWON-F16C-NEXT:    vcvtsi2ss %rdi, %xmm0, %xmm0
; BWON-F16C-NEXT:    jmp .LBB10_3
; BWON-F16C-NEXT:  .LBB10_1:
; BWON-F16C-NEXT:    movq %rdi, %rax
; BWON-F16C-NEXT:    shrq %rax
; BWON-F16C-NEXT:    andl $1, %edi
; BWON-F16C-NEXT:    orq %rax, %rdi
; BWON-F16C-NEXT:    vcvtsi2ss %rdi, %xmm0, %xmm0
; BWON-F16C-NEXT:    vaddss %xmm0, %xmm0, %xmm0
; BWON-F16C-NEXT:  .LBB10_3:
; BWON-F16C-NEXT:    vcvtps2ph $4, %xmm0, %xmm0
; BWON-F16C-NEXT:    vmovd %xmm0, %eax
; BWON-F16C-NEXT:    movw %ax, (%rsi)
; BWON-F16C-NEXT:    retq
;
; CHECK-I686-LABEL: test_uitofp_i64:
; CHECK-I686:       # %bb.0:
; CHECK-I686-NEXT:    pushl %esi
; CHECK-I686-NEXT:    subl $24, %esp
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %esi
; CHECK-I686-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-I686-NEXT:    movlps %xmm0, {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    xorl %eax, %eax
; CHECK-I686-NEXT:    cmpl $0, {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    setns %al
; CHECK-I686-NEXT:    fildll {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    fadds {{\.LCPI.*}}(,%eax,4)
; CHECK-I686-NEXT:    fstps (%esp)
; CHECK-I686-NEXT:    calll __gnu_f2h_ieee
; CHECK-I686-NEXT:    movw %ax, (%esi)
; CHECK-I686-NEXT:    addl $24, %esp
; CHECK-I686-NEXT:    popl %esi
; CHECK-I686-NEXT:    retl
  %r = uitofp i64 %a to half
  store half %r, half* %p
  ret void
}

define <4 x float> @test_extend32_vec4(<4 x half>* %p) #0 {
; CHECK-LIBCALL-LABEL: test_extend32_vec4:
; CHECK-LIBCALL:       # %bb.0:
; CHECK-LIBCALL-NEXT:    pushq %rbx
; CHECK-LIBCALL-NEXT:    subq $48, %rsp
; CHECK-LIBCALL-NEXT:    movq %rdi, %rbx
; CHECK-LIBCALL-NEXT:    movzwl (%rdi), %edi
; CHECK-LIBCALL-NEXT:    callq __gnu_h2f_ieee
; CHECK-LIBCALL-NEXT:    movaps %xmm0, {{[-0-9]+}}(%r{{[sb]}}p) # 16-byte Spill
; CHECK-LIBCALL-NEXT:    movzwl 2(%rbx), %edi
; CHECK-LIBCALL-NEXT:    callq __gnu_h2f_ieee
; CHECK-LIBCALL-NEXT:    movaps %xmm0, {{[-0-9]+}}(%r{{[sb]}}p) # 16-byte Spill
; CHECK-LIBCALL-NEXT:    movzwl 4(%rbx), %edi
; CHECK-LIBCALL-NEXT:    callq __gnu_h2f_ieee
; CHECK-LIBCALL-NEXT:    movaps %xmm0, (%rsp) # 16-byte Spill
; CHECK-LIBCALL-NEXT:    movzwl 6(%rbx), %edi
; CHECK-LIBCALL-NEXT:    callq __gnu_h2f_ieee
; CHECK-LIBCALL-NEXT:    movaps (%rsp), %xmm1 # 16-byte Reload
; CHECK-LIBCALL-NEXT:    unpcklps {{.*#+}} xmm1 = xmm1[0],xmm0[0],xmm1[1],xmm0[1]
; CHECK-LIBCALL-NEXT:    movaps {{[-0-9]+}}(%r{{[sb]}}p), %xmm0 # 16-byte Reload
; CHECK-LIBCALL-NEXT:    unpcklps {{[-0-9]+}}(%r{{[sb]}}p), %xmm0 # 16-byte Folded Reload
; CHECK-LIBCALL-NEXT:    # xmm0 = xmm0[0],mem[0],xmm0[1],mem[1]
; CHECK-LIBCALL-NEXT:    movlhps {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; CHECK-LIBCALL-NEXT:    addq $48, %rsp
; CHECK-LIBCALL-NEXT:    popq %rbx
; CHECK-LIBCALL-NEXT:    retq
;
; BWON-F16C-LABEL: test_extend32_vec4:
; BWON-F16C:       # %bb.0:
; BWON-F16C-NEXT:    movswl 6(%rdi), %eax
; BWON-F16C-NEXT:    vmovd %eax, %xmm0
; BWON-F16C-NEXT:    vcvtph2ps %xmm0, %xmm0
; BWON-F16C-NEXT:    movswl 4(%rdi), %eax
; BWON-F16C-NEXT:    vmovd %eax, %xmm1
; BWON-F16C-NEXT:    vcvtph2ps %xmm1, %xmm1
; BWON-F16C-NEXT:    movswl (%rdi), %eax
; BWON-F16C-NEXT:    vmovd %eax, %xmm2
; BWON-F16C-NEXT:    vcvtph2ps %xmm2, %xmm2
; BWON-F16C-NEXT:    movswl 2(%rdi), %eax
; BWON-F16C-NEXT:    vmovd %eax, %xmm3
; BWON-F16C-NEXT:    vcvtph2ps %xmm3, %xmm3
; BWON-F16C-NEXT:    vinsertps {{.*#+}} xmm2 = xmm2[0],xmm3[0],xmm2[2,3]
; BWON-F16C-NEXT:    vinsertps {{.*#+}} xmm1 = xmm2[0,1],xmm1[0],xmm2[3]
; BWON-F16C-NEXT:    vinsertps {{.*#+}} xmm0 = xmm1[0,1,2],xmm0[0]
; BWON-F16C-NEXT:    retq
;
; CHECK-I686-LABEL: test_extend32_vec4:
; CHECK-I686:       # %bb.0:
; CHECK-I686-NEXT:    pushl %esi
; CHECK-I686-NEXT:    subl $56, %esp
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %esi
; CHECK-I686-NEXT:    movzwl 4(%esi), %eax
; CHECK-I686-NEXT:    movl %eax, (%esp)
; CHECK-I686-NEXT:    calll __gnu_h2f_ieee
; CHECK-I686-NEXT:    fstpt {{[-0-9]+}}(%e{{[sb]}}p) # 10-byte Folded Spill
; CHECK-I686-NEXT:    movzwl 2(%esi), %eax
; CHECK-I686-NEXT:    movl %eax, (%esp)
; CHECK-I686-NEXT:    calll __gnu_h2f_ieee
; CHECK-I686-NEXT:    fstpt {{[-0-9]+}}(%e{{[sb]}}p) # 10-byte Folded Spill
; CHECK-I686-NEXT:    movzwl (%esi), %eax
; CHECK-I686-NEXT:    movl %eax, (%esp)
; CHECK-I686-NEXT:    calll __gnu_h2f_ieee
; CHECK-I686-NEXT:    movzwl 6(%esi), %eax
; CHECK-I686-NEXT:    movl %eax, (%esp)
; CHECK-I686-NEXT:    fstps {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    fldt {{[-0-9]+}}(%e{{[sb]}}p) # 10-byte Folded Reload
; CHECK-I686-NEXT:    fstps {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    fldt {{[-0-9]+}}(%e{{[sb]}}p) # 10-byte Folded Reload
; CHECK-I686-NEXT:    fstps {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    calll __gnu_h2f_ieee
; CHECK-I686-NEXT:    fstps {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-I686-NEXT:    movss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; CHECK-I686-NEXT:    unpcklps {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; CHECK-I686-NEXT:    movss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; CHECK-I686-NEXT:    movss {{.*#+}} xmm2 = mem[0],zero,zero,zero
; CHECK-I686-NEXT:    unpcklps {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1]
; CHECK-I686-NEXT:    movlhps {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; CHECK-I686-NEXT:    addl $56, %esp
; CHECK-I686-NEXT:    popl %esi
; CHECK-I686-NEXT:    retl
  %a = load <4 x half>, <4 x half>* %p, align 8
  %b = fpext <4 x half> %a to <4 x float>
  ret <4 x float> %b
}

define <4 x double> @test_extend64_vec4(<4 x half>* %p) #0 {
; CHECK-LIBCALL-LABEL: test_extend64_vec4:
; CHECK-LIBCALL:       # %bb.0:
; CHECK-LIBCALL-NEXT:    pushq %rbx
; CHECK-LIBCALL-NEXT:    subq $16, %rsp
; CHECK-LIBCALL-NEXT:    movq %rdi, %rbx
; CHECK-LIBCALL-NEXT:    movzwl 4(%rdi), %edi
; CHECK-LIBCALL-NEXT:    callq __gnu_h2f_ieee
; CHECK-LIBCALL-NEXT:    movss %xmm0, {{[-0-9]+}}(%r{{[sb]}}p) # 4-byte Spill
; CHECK-LIBCALL-NEXT:    movzwl 6(%rbx), %edi
; CHECK-LIBCALL-NEXT:    callq __gnu_h2f_ieee
; CHECK-LIBCALL-NEXT:    movss %xmm0, {{[-0-9]+}}(%r{{[sb]}}p) # 4-byte Spill
; CHECK-LIBCALL-NEXT:    movzwl (%rbx), %edi
; CHECK-LIBCALL-NEXT:    callq __gnu_h2f_ieee
; CHECK-LIBCALL-NEXT:    movss %xmm0, {{[-0-9]+}}(%r{{[sb]}}p) # 4-byte Spill
; CHECK-LIBCALL-NEXT:    movzwl 2(%rbx), %edi
; CHECK-LIBCALL-NEXT:    callq __gnu_h2f_ieee
; CHECK-LIBCALL-NEXT:    cvtss2sd %xmm0, %xmm1
; CHECK-LIBCALL-NEXT:    movss {{[-0-9]+}}(%r{{[sb]}}p), %xmm0 # 4-byte Reload
; CHECK-LIBCALL-NEXT:    # xmm0 = mem[0],zero,zero,zero
; CHECK-LIBCALL-NEXT:    cvtss2sd %xmm0, %xmm0
; CHECK-LIBCALL-NEXT:    movlhps {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; CHECK-LIBCALL-NEXT:    movss {{[-0-9]+}}(%r{{[sb]}}p), %xmm1 # 4-byte Reload
; CHECK-LIBCALL-NEXT:    # xmm1 = mem[0],zero,zero,zero
; CHECK-LIBCALL-NEXT:    cvtss2sd %xmm1, %xmm2
; CHECK-LIBCALL-NEXT:    movss {{[-0-9]+}}(%r{{[sb]}}p), %xmm1 # 4-byte Reload
; CHECK-LIBCALL-NEXT:    # xmm1 = mem[0],zero,zero,zero
; CHECK-LIBCALL-NEXT:    cvtss2sd %xmm1, %xmm1
; CHECK-LIBCALL-NEXT:    movlhps {{.*#+}} xmm1 = xmm1[0],xmm2[0]
; CHECK-LIBCALL-NEXT:    addq $16, %rsp
; CHECK-LIBCALL-NEXT:    popq %rbx
; CHECK-LIBCALL-NEXT:    retq
;
; BWON-F16C-LABEL: test_extend64_vec4:
; BWON-F16C:       # %bb.0:
; BWON-F16C-NEXT:    movswl (%rdi), %eax
; BWON-F16C-NEXT:    vmovd %eax, %xmm0
; BWON-F16C-NEXT:    vcvtph2ps %xmm0, %xmm0
; BWON-F16C-NEXT:    movswl 2(%rdi), %eax
; BWON-F16C-NEXT:    vmovd %eax, %xmm1
; BWON-F16C-NEXT:    vcvtph2ps %xmm1, %xmm1
; BWON-F16C-NEXT:    movswl 4(%rdi), %eax
; BWON-F16C-NEXT:    vmovd %eax, %xmm2
; BWON-F16C-NEXT:    vcvtph2ps %xmm2, %xmm2
; BWON-F16C-NEXT:    movswl 6(%rdi), %eax
; BWON-F16C-NEXT:    vmovd %eax, %xmm3
; BWON-F16C-NEXT:    vcvtph2ps %xmm3, %xmm3
; BWON-F16C-NEXT:    vcvtss2sd %xmm3, %xmm3, %xmm3
; BWON-F16C-NEXT:    vcvtss2sd %xmm2, %xmm2, %xmm2
; BWON-F16C-NEXT:    vmovlhps {{.*#+}} xmm2 = xmm2[0],xmm3[0]
; BWON-F16C-NEXT:    vcvtss2sd %xmm1, %xmm1, %xmm1
; BWON-F16C-NEXT:    vcvtss2sd %xmm0, %xmm0, %xmm0
; BWON-F16C-NEXT:    vmovlhps {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; BWON-F16C-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; BWON-F16C-NEXT:    retq
;
; CHECK-I686-LABEL: test_extend64_vec4:
; CHECK-I686:       # %bb.0:
; CHECK-I686-NEXT:    pushl %esi
; CHECK-I686-NEXT:    subl $88, %esp
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %esi
; CHECK-I686-NEXT:    movzwl 6(%esi), %eax
; CHECK-I686-NEXT:    movl %eax, (%esp)
; CHECK-I686-NEXT:    calll __gnu_h2f_ieee
; CHECK-I686-NEXT:    fstpt {{[-0-9]+}}(%e{{[sb]}}p) # 10-byte Folded Spill
; CHECK-I686-NEXT:    movzwl 4(%esi), %eax
; CHECK-I686-NEXT:    movl %eax, (%esp)
; CHECK-I686-NEXT:    calll __gnu_h2f_ieee
; CHECK-I686-NEXT:    fstpt {{[-0-9]+}}(%e{{[sb]}}p) # 10-byte Folded Spill
; CHECK-I686-NEXT:    movzwl 2(%esi), %eax
; CHECK-I686-NEXT:    movl %eax, (%esp)
; CHECK-I686-NEXT:    calll __gnu_h2f_ieee
; CHECK-I686-NEXT:    fstpt {{[-0-9]+}}(%e{{[sb]}}p) # 10-byte Folded Spill
; CHECK-I686-NEXT:    movzwl (%esi), %eax
; CHECK-I686-NEXT:    movl %eax, (%esp)
; CHECK-I686-NEXT:    calll __gnu_h2f_ieee
; CHECK-I686-NEXT:    fstpl {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    fldt {{[-0-9]+}}(%e{{[sb]}}p) # 10-byte Folded Reload
; CHECK-I686-NEXT:    fstpl {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    fldt {{[-0-9]+}}(%e{{[sb]}}p) # 10-byte Folded Reload
; CHECK-I686-NEXT:    fstpl {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    fldt {{[-0-9]+}}(%e{{[sb]}}p) # 10-byte Folded Reload
; CHECK-I686-NEXT:    fstpl {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-I686-NEXT:    movhpd {{.*#+}} xmm0 = xmm0[0],mem[0]
; CHECK-I686-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; CHECK-I686-NEXT:    movhpd {{.*#+}} xmm1 = xmm1[0],mem[0]
; CHECK-I686-NEXT:    addl $88, %esp
; CHECK-I686-NEXT:    popl %esi
; CHECK-I686-NEXT:    retl
  %a = load <4 x half>, <4 x half>* %p, align 8
  %b = fpext <4 x half> %a to <4 x double>
  ret <4 x double> %b
}

define void @test_trunc32_vec4(<4 x float> %a, <4 x half>* %p) #0 {
; BWON-NOF16C-LABEL: test_trunc32_vec4:
; BWON-NOF16C:       # %bb.0:
; BWON-NOF16C-NEXT:    pushq %rbp
; BWON-NOF16C-NEXT:    pushq %r15
; BWON-NOF16C-NEXT:    pushq %r14
; BWON-NOF16C-NEXT:    pushq %rbx
; BWON-NOF16C-NEXT:    subq $24, %rsp
; BWON-NOF16C-NEXT:    movq %rdi, %rbx
; BWON-NOF16C-NEXT:    movaps %xmm0, (%rsp) # 16-byte Spill
; BWON-NOF16C-NEXT:    shufps {{.*#+}} xmm0 = xmm0[1,1,2,3]
; BWON-NOF16C-NEXT:    callq __gnu_f2h_ieee
; BWON-NOF16C-NEXT:    movl %eax, %r14d
; BWON-NOF16C-NEXT:    movaps (%rsp), %xmm0 # 16-byte Reload
; BWON-NOF16C-NEXT:    movhlps {{.*#+}} xmm0 = xmm0[1,1]
; BWON-NOF16C-NEXT:    callq __gnu_f2h_ieee
; BWON-NOF16C-NEXT:    movl %eax, %r15d
; BWON-NOF16C-NEXT:    movaps (%rsp), %xmm0 # 16-byte Reload
; BWON-NOF16C-NEXT:    shufps {{.*#+}} xmm0 = xmm0[3,1,2,3]
; BWON-NOF16C-NEXT:    callq __gnu_f2h_ieee
; BWON-NOF16C-NEXT:    movl %eax, %ebp
; BWON-NOF16C-NEXT:    movaps (%rsp), %xmm0 # 16-byte Reload
; BWON-NOF16C-NEXT:    callq __gnu_f2h_ieee
; BWON-NOF16C-NEXT:    movw %ax, (%rbx)
; BWON-NOF16C-NEXT:    movw %bp, 6(%rbx)
; BWON-NOF16C-NEXT:    movw %r15w, 4(%rbx)
; BWON-NOF16C-NEXT:    movw %r14w, 2(%rbx)
; BWON-NOF16C-NEXT:    addq $24, %rsp
; BWON-NOF16C-NEXT:    popq %rbx
; BWON-NOF16C-NEXT:    popq %r14
; BWON-NOF16C-NEXT:    popq %r15
; BWON-NOF16C-NEXT:    popq %rbp
; BWON-NOF16C-NEXT:    retq
;
; BWOFF-LABEL: test_trunc32_vec4:
; BWOFF:       # %bb.0:
; BWOFF-NEXT:    pushq %rbp
; BWOFF-NEXT:    pushq %r15
; BWOFF-NEXT:    pushq %r14
; BWOFF-NEXT:    pushq %rbx
; BWOFF-NEXT:    subq $24, %rsp
; BWOFF-NEXT:    movq %rdi, %rbx
; BWOFF-NEXT:    movaps %xmm0, (%rsp) # 16-byte Spill
; BWOFF-NEXT:    shufps {{.*#+}} xmm0 = xmm0[1,1,2,3]
; BWOFF-NEXT:    callq __gnu_f2h_ieee
; BWOFF-NEXT:    movw %ax, %r14w
; BWOFF-NEXT:    movaps (%rsp), %xmm0 # 16-byte Reload
; BWOFF-NEXT:    movhlps {{.*#+}} xmm0 = xmm0[1,1]
; BWOFF-NEXT:    callq __gnu_f2h_ieee
; BWOFF-NEXT:    movw %ax, %r15w
; BWOFF-NEXT:    movaps (%rsp), %xmm0 # 16-byte Reload
; BWOFF-NEXT:    shufps {{.*#+}} xmm0 = xmm0[3,1,2,3]
; BWOFF-NEXT:    callq __gnu_f2h_ieee
; BWOFF-NEXT:    movw %ax, %bp
; BWOFF-NEXT:    movaps (%rsp), %xmm0 # 16-byte Reload
; BWOFF-NEXT:    callq __gnu_f2h_ieee
; BWOFF-NEXT:    movw %ax, (%rbx)
; BWOFF-NEXT:    movw %bp, 6(%rbx)
; BWOFF-NEXT:    movw %r15w, 4(%rbx)
; BWOFF-NEXT:    movw %r14w, 2(%rbx)
; BWOFF-NEXT:    addq $24, %rsp
; BWOFF-NEXT:    popq %rbx
; BWOFF-NEXT:    popq %r14
; BWOFF-NEXT:    popq %r15
; BWOFF-NEXT:    popq %rbp
; BWOFF-NEXT:    retq
;
; BWON-F16C-LABEL: test_trunc32_vec4:
; BWON-F16C:       # %bb.0:
; BWON-F16C-NEXT:    vmovshdup {{.*#+}} xmm1 = xmm0[1,1,3,3]
; BWON-F16C-NEXT:    vcvtps2ph $4, %xmm1, %xmm1
; BWON-F16C-NEXT:    vmovd %xmm1, %eax
; BWON-F16C-NEXT:    vpermilpd {{.*#+}} xmm1 = xmm0[1,0]
; BWON-F16C-NEXT:    vcvtps2ph $4, %xmm1, %xmm1
; BWON-F16C-NEXT:    vmovd %xmm1, %ecx
; BWON-F16C-NEXT:    vpermilps {{.*#+}} xmm1 = xmm0[3,1,2,3]
; BWON-F16C-NEXT:    vcvtps2ph $4, %xmm1, %xmm1
; BWON-F16C-NEXT:    vmovd %xmm1, %edx
; BWON-F16C-NEXT:    vcvtps2ph $4, %xmm0, %xmm0
; BWON-F16C-NEXT:    vmovd %xmm0, %esi
; BWON-F16C-NEXT:    movw %si, (%rdi)
; BWON-F16C-NEXT:    movw %dx, 6(%rdi)
; BWON-F16C-NEXT:    movw %cx, 4(%rdi)
; BWON-F16C-NEXT:    movw %ax, 2(%rdi)
; BWON-F16C-NEXT:    retq
;
; CHECK-I686-LABEL: test_trunc32_vec4:
; CHECK-I686:       # %bb.0:
; CHECK-I686-NEXT:    pushl %ebp
; CHECK-I686-NEXT:    pushl %ebx
; CHECK-I686-NEXT:    pushl %edi
; CHECK-I686-NEXT:    pushl %esi
; CHECK-I686-NEXT:    subl $44, %esp
; CHECK-I686-NEXT:    movaps %xmm0, {{[-0-9]+}}(%e{{[sb]}}p) # 16-byte Spill
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %ebp
; CHECK-I686-NEXT:    movaps %xmm0, %xmm1
; CHECK-I686-NEXT:    shufps {{.*#+}} xmm1 = xmm1[1,1],xmm0[2,3]
; CHECK-I686-NEXT:    movss %xmm1, (%esp)
; CHECK-I686-NEXT:    calll __gnu_f2h_ieee
; CHECK-I686-NEXT:    movw %ax, %si
; CHECK-I686-NEXT:    movaps {{[-0-9]+}}(%e{{[sb]}}p), %xmm0 # 16-byte Reload
; CHECK-I686-NEXT:    movhlps {{.*#+}} xmm0 = xmm0[1,1]
; CHECK-I686-NEXT:    movss %xmm0, (%esp)
; CHECK-I686-NEXT:    calll __gnu_f2h_ieee
; CHECK-I686-NEXT:    movw %ax, %di
; CHECK-I686-NEXT:    movaps {{[-0-9]+}}(%e{{[sb]}}p), %xmm0 # 16-byte Reload
; CHECK-I686-NEXT:    shufps {{.*#+}} xmm0 = xmm0[3,1,2,3]
; CHECK-I686-NEXT:    movss %xmm0, (%esp)
; CHECK-I686-NEXT:    calll __gnu_f2h_ieee
; CHECK-I686-NEXT:    movw %ax, %bx
; CHECK-I686-NEXT:    movaps {{[-0-9]+}}(%e{{[sb]}}p), %xmm0 # 16-byte Reload
; CHECK-I686-NEXT:    movss %xmm0, (%esp)
; CHECK-I686-NEXT:    calll __gnu_f2h_ieee
; CHECK-I686-NEXT:    movw %ax, (%ebp)
; CHECK-I686-NEXT:    movw %bx, 6(%ebp)
; CHECK-I686-NEXT:    movw %di, 4(%ebp)
; CHECK-I686-NEXT:    movw %si, 2(%ebp)
; CHECK-I686-NEXT:    addl $44, %esp
; CHECK-I686-NEXT:    popl %esi
; CHECK-I686-NEXT:    popl %edi
; CHECK-I686-NEXT:    popl %ebx
; CHECK-I686-NEXT:    popl %ebp
; CHECK-I686-NEXT:    retl
  %v = fptrunc <4 x float> %a to <4 x half>
  store <4 x half> %v, <4 x half>* %p
  ret void
}

define void @test_trunc64_vec4(<4 x double> %a, <4 x half>* %p) #0 {
; BWON-NOF16C-LABEL: test_trunc64_vec4:
; BWON-NOF16C:       # %bb.0:
; BWON-NOF16C-NEXT:    pushq %rbp
; BWON-NOF16C-NEXT:    pushq %r15
; BWON-NOF16C-NEXT:    pushq %r14
; BWON-NOF16C-NEXT:    pushq %rbx
; BWON-NOF16C-NEXT:    subq $40, %rsp
; BWON-NOF16C-NEXT:    movq %rdi, %rbx
; BWON-NOF16C-NEXT:    movaps %xmm1, (%rsp) # 16-byte Spill
; BWON-NOF16C-NEXT:    movaps %xmm0, {{[-0-9]+}}(%r{{[sb]}}p) # 16-byte Spill
; BWON-NOF16C-NEXT:    movhlps {{.*#+}} xmm0 = xmm0[1,1]
; BWON-NOF16C-NEXT:    callq __truncdfhf2
; BWON-NOF16C-NEXT:    movl %eax, %r14d
; BWON-NOF16C-NEXT:    movaps (%rsp), %xmm0 # 16-byte Reload
; BWON-NOF16C-NEXT:    movhlps {{.*#+}} xmm0 = xmm0[1,1]
; BWON-NOF16C-NEXT:    callq __truncdfhf2
; BWON-NOF16C-NEXT:    movl %eax, %r15d
; BWON-NOF16C-NEXT:    movaps {{[-0-9]+}}(%r{{[sb]}}p), %xmm0 # 16-byte Reload
; BWON-NOF16C-NEXT:    callq __truncdfhf2
; BWON-NOF16C-NEXT:    movl %eax, %ebp
; BWON-NOF16C-NEXT:    movaps (%rsp), %xmm0 # 16-byte Reload
; BWON-NOF16C-NEXT:    callq __truncdfhf2
; BWON-NOF16C-NEXT:    movw %ax, 4(%rbx)
; BWON-NOF16C-NEXT:    movw %bp, (%rbx)
; BWON-NOF16C-NEXT:    movw %r15w, 6(%rbx)
; BWON-NOF16C-NEXT:    movw %r14w, 2(%rbx)
; BWON-NOF16C-NEXT:    addq $40, %rsp
; BWON-NOF16C-NEXT:    popq %rbx
; BWON-NOF16C-NEXT:    popq %r14
; BWON-NOF16C-NEXT:    popq %r15
; BWON-NOF16C-NEXT:    popq %rbp
; BWON-NOF16C-NEXT:    retq
;
; BWOFF-LABEL: test_trunc64_vec4:
; BWOFF:       # %bb.0:
; BWOFF-NEXT:    pushq %rbp
; BWOFF-NEXT:    pushq %r15
; BWOFF-NEXT:    pushq %r14
; BWOFF-NEXT:    pushq %rbx
; BWOFF-NEXT:    subq $40, %rsp
; BWOFF-NEXT:    movq %rdi, %rbx
; BWOFF-NEXT:    movaps %xmm1, (%rsp) # 16-byte Spill
; BWOFF-NEXT:    movaps %xmm0, {{[-0-9]+}}(%r{{[sb]}}p) # 16-byte Spill
; BWOFF-NEXT:    movhlps {{.*#+}} xmm0 = xmm0[1,1]
; BWOFF-NEXT:    callq __truncdfhf2
; BWOFF-NEXT:    movw %ax, %r14w
; BWOFF-NEXT:    movaps (%rsp), %xmm0 # 16-byte Reload
; BWOFF-NEXT:    movhlps {{.*#+}} xmm0 = xmm0[1,1]
; BWOFF-NEXT:    callq __truncdfhf2
; BWOFF-NEXT:    movw %ax, %r15w
; BWOFF-NEXT:    movaps {{[-0-9]+}}(%r{{[sb]}}p), %xmm0 # 16-byte Reload
; BWOFF-NEXT:    callq __truncdfhf2
; BWOFF-NEXT:    movw %ax, %bp
; BWOFF-NEXT:    movaps (%rsp), %xmm0 # 16-byte Reload
; BWOFF-NEXT:    callq __truncdfhf2
; BWOFF-NEXT:    movw %ax, 4(%rbx)
; BWOFF-NEXT:    movw %bp, (%rbx)
; BWOFF-NEXT:    movw %r15w, 6(%rbx)
; BWOFF-NEXT:    movw %r14w, 2(%rbx)
; BWOFF-NEXT:    addq $40, %rsp
; BWOFF-NEXT:    popq %rbx
; BWOFF-NEXT:    popq %r14
; BWOFF-NEXT:    popq %r15
; BWOFF-NEXT:    popq %rbp
; BWOFF-NEXT:    retq
;
; BWON-F16C-LABEL: test_trunc64_vec4:
; BWON-F16C:       # %bb.0:
; BWON-F16C-NEXT:    pushq %rbp
; BWON-F16C-NEXT:    pushq %r15
; BWON-F16C-NEXT:    pushq %r14
; BWON-F16C-NEXT:    pushq %rbx
; BWON-F16C-NEXT:    subq $88, %rsp
; BWON-F16C-NEXT:    movq %rdi, %rbx
; BWON-F16C-NEXT:    vmovupd %ymm0, {{[-0-9]+}}(%r{{[sb]}}p) # 32-byte Spill
; BWON-F16C-NEXT:    vpermilpd {{.*#+}} xmm0 = xmm0[1,0]
; BWON-F16C-NEXT:    vzeroupper
; BWON-F16C-NEXT:    callq __truncdfhf2
; BWON-F16C-NEXT:    movl %eax, %r14d
; BWON-F16C-NEXT:    vmovups {{[-0-9]+}}(%r{{[sb]}}p), %ymm0 # 32-byte Reload
; BWON-F16C-NEXT:    vextractf128 $1, %ymm0, %xmm0
; BWON-F16C-NEXT:    vmovapd %xmm0, {{[-0-9]+}}(%r{{[sb]}}p) # 16-byte Spill
; BWON-F16C-NEXT:    vpermilpd {{.*#+}} xmm0 = xmm0[1,0]
; BWON-F16C-NEXT:    vzeroupper
; BWON-F16C-NEXT:    callq __truncdfhf2
; BWON-F16C-NEXT:    movl %eax, %r15d
; BWON-F16C-NEXT:    vmovups {{[-0-9]+}}(%r{{[sb]}}p), %ymm0 # 32-byte Reload
; BWON-F16C-NEXT:    # kill: def $xmm0 killed $xmm0 killed $ymm0
; BWON-F16C-NEXT:    vzeroupper
; BWON-F16C-NEXT:    callq __truncdfhf2
; BWON-F16C-NEXT:    movl %eax, %ebp
; BWON-F16C-NEXT:    vmovaps {{[-0-9]+}}(%r{{[sb]}}p), %xmm0 # 16-byte Reload
; BWON-F16C-NEXT:    callq __truncdfhf2
; BWON-F16C-NEXT:    movw %ax, 4(%rbx)
; BWON-F16C-NEXT:    movw %bp, (%rbx)
; BWON-F16C-NEXT:    movw %r15w, 6(%rbx)
; BWON-F16C-NEXT:    movw %r14w, 2(%rbx)
; BWON-F16C-NEXT:    addq $88, %rsp
; BWON-F16C-NEXT:    popq %rbx
; BWON-F16C-NEXT:    popq %r14
; BWON-F16C-NEXT:    popq %r15
; BWON-F16C-NEXT:    popq %rbp
; BWON-F16C-NEXT:    retq
;
; CHECK-I686-LABEL: test_trunc64_vec4:
; CHECK-I686:       # %bb.0:
; CHECK-I686-NEXT:    pushl %ebp
; CHECK-I686-NEXT:    pushl %ebx
; CHECK-I686-NEXT:    pushl %edi
; CHECK-I686-NEXT:    pushl %esi
; CHECK-I686-NEXT:    subl $60, %esp
; CHECK-I686-NEXT:    movaps %xmm1, {{[-0-9]+}}(%e{{[sb]}}p) # 16-byte Spill
; CHECK-I686-NEXT:    movaps %xmm0, {{[-0-9]+}}(%e{{[sb]}}p) # 16-byte Spill
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %ebp
; CHECK-I686-NEXT:    movlps %xmm0, (%esp)
; CHECK-I686-NEXT:    calll __truncdfhf2
; CHECK-I686-NEXT:    movw %ax, %si
; CHECK-I686-NEXT:    movapd {{[-0-9]+}}(%e{{[sb]}}p), %xmm0 # 16-byte Reload
; CHECK-I686-NEXT:    movhpd %xmm0, (%esp)
; CHECK-I686-NEXT:    calll __truncdfhf2
; CHECK-I686-NEXT:    movw %ax, %di
; CHECK-I686-NEXT:    movaps {{[-0-9]+}}(%e{{[sb]}}p), %xmm0 # 16-byte Reload
; CHECK-I686-NEXT:    movlps %xmm0, (%esp)
; CHECK-I686-NEXT:    calll __truncdfhf2
; CHECK-I686-NEXT:    movw %ax, %bx
; CHECK-I686-NEXT:    movapd {{[-0-9]+}}(%e{{[sb]}}p), %xmm0 # 16-byte Reload
; CHECK-I686-NEXT:    movhpd %xmm0, (%esp)
; CHECK-I686-NEXT:    calll __truncdfhf2
; CHECK-I686-NEXT:    movw %ax, 6(%ebp)
; CHECK-I686-NEXT:    movw %bx, 4(%ebp)
; CHECK-I686-NEXT:    movw %di, 2(%ebp)
; CHECK-I686-NEXT:    movw %si, (%ebp)
; CHECK-I686-NEXT:    addl $60, %esp
; CHECK-I686-NEXT:    popl %esi
; CHECK-I686-NEXT:    popl %edi
; CHECK-I686-NEXT:    popl %ebx
; CHECK-I686-NEXT:    popl %ebp
; CHECK-I686-NEXT:    retl
  %v = fptrunc <4 x double> %a to <4 x half>
  store <4 x half> %v, <4 x half>* %p
  ret void
}

declare float @test_floatret();

; On i686, if SSE2 is available, the return value from test_floatret is loaded
; to f80 and then rounded to f32.  The DAG combiner should not combine this
; fp_round and the subsequent fptrunc from float to half.
define half @test_f80trunc_nodagcombine() #0 {
; CHECK-LIBCALL-LABEL: test_f80trunc_nodagcombine:
; CHECK-LIBCALL:       # %bb.0:
; CHECK-LIBCALL-NEXT:    pushq %rax
; CHECK-LIBCALL-NEXT:    callq test_floatret
; CHECK-LIBCALL-NEXT:    callq __gnu_f2h_ieee
; CHECK-LIBCALL-NEXT:    movzwl %ax, %edi
; CHECK-LIBCALL-NEXT:    callq __gnu_h2f_ieee
; CHECK-LIBCALL-NEXT:    popq %rax
; CHECK-LIBCALL-NEXT:    retq
;
; BWON-F16C-LABEL: test_f80trunc_nodagcombine:
; BWON-F16C:       # %bb.0:
; BWON-F16C-NEXT:    pushq %rax
; BWON-F16C-NEXT:    callq test_floatret
; BWON-F16C-NEXT:    vcvtps2ph $4, %xmm0, %xmm0
; BWON-F16C-NEXT:    vcvtph2ps %xmm0, %xmm0
; BWON-F16C-NEXT:    popq %rax
; BWON-F16C-NEXT:    retq
;
; CHECK-I686-LABEL: test_f80trunc_nodagcombine:
; CHECK-I686:       # %bb.0:
; CHECK-I686-NEXT:    subl $12, %esp
; CHECK-I686-NEXT:    calll test_floatret
; CHECK-I686-NEXT:    fstps (%esp)
; CHECK-I686-NEXT:    calll __gnu_f2h_ieee
; CHECK-I686-NEXT:    movzwl %ax, %eax
; CHECK-I686-NEXT:    movl %eax, (%esp)
; CHECK-I686-NEXT:    calll __gnu_h2f_ieee
; CHECK-I686-NEXT:    addl $12, %esp
; CHECK-I686-NEXT:    retl
  %1 = call float @test_floatret()
  %2 = fptrunc float %1 to half
  ret half %2
}




define float @test_sitofp_fadd_i32(i32 %a, half* %b) #0 {
; CHECK-LIBCALL-LABEL: test_sitofp_fadd_i32:
; CHECK-LIBCALL:       # %bb.0:
; CHECK-LIBCALL-NEXT:    pushq %rbx
; CHECK-LIBCALL-NEXT:    subq $16, %rsp
; CHECK-LIBCALL-NEXT:    movl %edi, %ebx
; CHECK-LIBCALL-NEXT:    movzwl (%rsi), %edi
; CHECK-LIBCALL-NEXT:    callq __gnu_h2f_ieee
; CHECK-LIBCALL-NEXT:    movss %xmm0, {{[-0-9]+}}(%r{{[sb]}}p) # 4-byte Spill
; CHECK-LIBCALL-NEXT:    cvtsi2ss %ebx, %xmm0
; CHECK-LIBCALL-NEXT:    callq __gnu_f2h_ieee
; CHECK-LIBCALL-NEXT:    movzwl %ax, %edi
; CHECK-LIBCALL-NEXT:    callq __gnu_h2f_ieee
; CHECK-LIBCALL-NEXT:    addss {{[-0-9]+}}(%r{{[sb]}}p), %xmm0 # 4-byte Folded Reload
; CHECK-LIBCALL-NEXT:    addq $16, %rsp
; CHECK-LIBCALL-NEXT:    popq %rbx
; CHECK-LIBCALL-NEXT:    retq
;
; BWON-F16C-LABEL: test_sitofp_fadd_i32:
; BWON-F16C:       # %bb.0:
; BWON-F16C-NEXT:    movswl (%rsi), %eax
; BWON-F16C-NEXT:    vmovd %eax, %xmm0
; BWON-F16C-NEXT:    vcvtph2ps %xmm0, %xmm0
; BWON-F16C-NEXT:    vcvtsi2ss %edi, %xmm1, %xmm1
; BWON-F16C-NEXT:    vcvtps2ph $4, %xmm1, %xmm1
; BWON-F16C-NEXT:    vcvtph2ps %xmm1, %xmm1
; BWON-F16C-NEXT:    vaddss %xmm1, %xmm0, %xmm0
; BWON-F16C-NEXT:    retq
;
; CHECK-I686-LABEL: test_sitofp_fadd_i32:
; CHECK-I686:       # %bb.0:
; CHECK-I686-NEXT:    subl $28, %esp
; CHECK-I686-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-I686-NEXT:    movzwl (%eax), %eax
; CHECK-I686-NEXT:    movl %eax, (%esp)
; CHECK-I686-NEXT:    calll __gnu_h2f_ieee
; CHECK-I686-NEXT:    fstps {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-I686-NEXT:    movss %xmm0, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Spill
; CHECK-I686-NEXT:    xorps %xmm0, %xmm0
; CHECK-I686-NEXT:    cvtsi2ssl {{[0-9]+}}(%esp), %xmm0
; CHECK-I686-NEXT:    movss %xmm0, (%esp)
; CHECK-I686-NEXT:    calll __gnu_f2h_ieee
; CHECK-I686-NEXT:    movzwl %ax, %eax
; CHECK-I686-NEXT:    movl %eax, (%esp)
; CHECK-I686-NEXT:    calll __gnu_h2f_ieee
; CHECK-I686-NEXT:    fstps {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    movss {{[-0-9]+}}(%e{{[sb]}}p), %xmm0 # 4-byte Reload
; CHECK-I686-NEXT:    # xmm0 = mem[0],zero,zero,zero
; CHECK-I686-NEXT:    addss {{[0-9]+}}(%esp), %xmm0
; CHECK-I686-NEXT:    movss %xmm0, {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    flds {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    addl $28, %esp
; CHECK-I686-NEXT:    retl
  %tmp0 = load half, half* %b
  %tmp1 = sitofp i32 %a to half
  %tmp2 = fadd half %tmp0, %tmp1
  %tmp3 = fpext half %tmp2 to float
  ret float %tmp3
}

define half @PR40273(half) #0 {
; CHECK-LIBCALL-LABEL: PR40273:
; CHECK-LIBCALL:       # %bb.0:
; CHECK-LIBCALL-NEXT:    pushq %rax
; CHECK-LIBCALL-NEXT:    callq __gnu_f2h_ieee
; CHECK-LIBCALL-NEXT:    movzwl %ax, %edi
; CHECK-LIBCALL-NEXT:    callq __gnu_h2f_ieee
; CHECK-LIBCALL-NEXT:    xorps %xmm1, %xmm1
; CHECK-LIBCALL-NEXT:    ucomiss %xmm1, %xmm0
; CHECK-LIBCALL-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-LIBCALL-NEXT:    jne .LBB17_3
; CHECK-LIBCALL-NEXT:  # %bb.1:
; CHECK-LIBCALL-NEXT:    jp .LBB17_3
; CHECK-LIBCALL-NEXT:  # %bb.2:
; CHECK-LIBCALL-NEXT:    xorps %xmm0, %xmm0
; CHECK-LIBCALL-NEXT:  .LBB17_3:
; CHECK-LIBCALL-NEXT:    popq %rax
; CHECK-LIBCALL-NEXT:    retq
;
; BWON-F16C-LABEL: PR40273:
; BWON-F16C:       # %bb.0:
; BWON-F16C-NEXT:    vcvtps2ph $4, %xmm0, %xmm0
; BWON-F16C-NEXT:    vcvtph2ps %xmm0, %xmm0
; BWON-F16C-NEXT:    vxorps %xmm1, %xmm1, %xmm1
; BWON-F16C-NEXT:    vucomiss %xmm1, %xmm0
; BWON-F16C-NEXT:    vmovss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; BWON-F16C-NEXT:    jne .LBB17_3
; BWON-F16C-NEXT:  # %bb.1:
; BWON-F16C-NEXT:    jp .LBB17_3
; BWON-F16C-NEXT:  # %bb.2:
; BWON-F16C-NEXT:    vxorps %xmm0, %xmm0, %xmm0
; BWON-F16C-NEXT:  .LBB17_3:
; BWON-F16C-NEXT:    retq
;
; CHECK-I686-LABEL: PR40273:
; CHECK-I686:       # %bb.0:
; CHECK-I686-NEXT:    subl $12, %esp
; CHECK-I686-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-I686-NEXT:    movss %xmm0, (%esp)
; CHECK-I686-NEXT:    calll __gnu_f2h_ieee
; CHECK-I686-NEXT:    movzwl %ax, %eax
; CHECK-I686-NEXT:    movl %eax, (%esp)
; CHECK-I686-NEXT:    calll __gnu_h2f_ieee
; CHECK-I686-NEXT:    fstps {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-I686-NEXT:    xorps %xmm1, %xmm1
; CHECK-I686-NEXT:    ucomiss %xmm1, %xmm0
; CHECK-I686-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-I686-NEXT:    jne .LBB17_3
; CHECK-I686-NEXT:  # %bb.1:
; CHECK-I686-NEXT:    jp .LBB17_3
; CHECK-I686-NEXT:  # %bb.2:
; CHECK-I686-NEXT:    xorps %xmm0, %xmm0
; CHECK-I686-NEXT:  .LBB17_3:
; CHECK-I686-NEXT:    movss %xmm0, {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    flds {{[0-9]+}}(%esp)
; CHECK-I686-NEXT:    addl $12, %esp
; CHECK-I686-NEXT:    retl
  %2 = fcmp une half %0, 0xH0000
  %3 = uitofp i1 %2 to half
  ret half %3
}

attributes #0 = { nounwind }