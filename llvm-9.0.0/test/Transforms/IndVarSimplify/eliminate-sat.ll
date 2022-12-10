; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -S -indvars | FileCheck %s

declare i32 @llvm.uadd.sat.i32(i32, i32)
declare i32 @llvm.sadd.sat.i32(i32, i32)
declare i32 @llvm.usub.sat.i32(i32, i32)
declare i32 @llvm.ssub.sat.i32(i32, i32)

define void @uadd_sat(i32* %p) {
; CHECK-LABEL: @uadd_sat(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[I_INC:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[SAT:%.*]] = call i32 @llvm.uadd.sat.i32(i32 [[I]], i32 1)
; CHECK-NEXT:    store volatile i32 [[SAT]], i32* [[P:%.*]]
; CHECK-NEXT:    [[I_INC]] = add nuw nsw i32 [[I]], 1
; CHECK-NEXT:    [[CMP:%.*]] = icmp ne i32 [[I_INC]], 100
; CHECK-NEXT:    br i1 [[CMP]], label [[LOOP]], label [[END:%.*]]
; CHECK:       end:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %i = phi i32 [ 0, %entry ], [ %i.inc, %loop ]
  %sat = call i32 @llvm.uadd.sat.i32(i32 %i, i32 1)
  store volatile i32 %sat, i32* %p
  %i.inc = add nuw nsw i32 %i, 1
  %cmp = icmp ne i32 %i.inc, 100
  br i1 %cmp, label %loop, label %end

end:
  ret void
}

define void @sadd_sat(i32* %p) {
; CHECK-LABEL: @sadd_sat(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[I_INC:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[SAT:%.*]] = call i32 @llvm.sadd.sat.i32(i32 [[I]], i32 1)
; CHECK-NEXT:    store volatile i32 [[SAT]], i32* [[P:%.*]]
; CHECK-NEXT:    [[I_INC]] = add nuw nsw i32 [[I]], 1
; CHECK-NEXT:    [[CMP:%.*]] = icmp ne i32 [[I_INC]], 100
; CHECK-NEXT:    br i1 [[CMP]], label [[LOOP]], label [[END:%.*]]
; CHECK:       end:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %i = phi i32 [ 0, %entry ], [ %i.inc, %loop ]
  %sat = call i32 @llvm.sadd.sat.i32(i32 %i, i32 1)
  store volatile i32 %sat, i32* %p
  %i.inc = add nuw nsw i32 %i, 1
  %cmp = icmp ne i32 %i.inc, 100
  br i1 %cmp, label %loop, label %end

end:
  ret void
}

define void @usub_sat(i32* %p) {
; CHECK-LABEL: @usub_sat(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ 1, [[ENTRY:%.*]] ], [ [[I_INC:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[SAT:%.*]] = call i32 @llvm.usub.sat.i32(i32 [[I]], i32 1)
; CHECK-NEXT:    store volatile i32 [[SAT]], i32* [[P:%.*]]
; CHECK-NEXT:    [[I_INC]] = add nuw nsw i32 [[I]], 1
; CHECK-NEXT:    [[CMP:%.*]] = icmp ne i32 [[I_INC]], 100
; CHECK-NEXT:    br i1 [[CMP]], label [[LOOP]], label [[END:%.*]]
; CHECK:       end:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %i = phi i32 [ 1, %entry ], [ %i.inc, %loop ]
  %sat = call i32 @llvm.usub.sat.i32(i32 %i, i32 1)
  store volatile i32 %sat, i32* %p
  %i.inc = add nuw nsw i32 %i, 1
  %cmp = icmp ne i32 %i.inc, 100
  br i1 %cmp, label %loop, label %end

end:
  ret void
}

define void @ssub_sat(i32* %p) {
; CHECK-LABEL: @ssub_sat(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[I_INC:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[SAT:%.*]] = call i32 @llvm.ssub.sat.i32(i32 [[I]], i32 1)
; CHECK-NEXT:    store volatile i32 [[SAT]], i32* [[P:%.*]]
; CHECK-NEXT:    [[I_INC]] = add nuw nsw i32 [[I]], 1
; CHECK-NEXT:    [[CMP:%.*]] = icmp ne i32 [[I_INC]], 100
; CHECK-NEXT:    br i1 [[CMP]], label [[LOOP]], label [[END:%.*]]
; CHECK:       end:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %i = phi i32 [ 0, %entry ], [ %i.inc, %loop ]
  %sat = call i32 @llvm.ssub.sat.i32(i32 %i, i32 1)
  store volatile i32 %sat, i32* %p
  %i.inc = add nuw nsw i32 %i, 1
  %cmp = icmp ne i32 %i.inc, 100
  br i1 %cmp, label %loop, label %end

end:
  ret void
}