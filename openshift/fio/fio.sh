#!/bin/sh

echo "###"
echo "### Performing USECASE db-randwrite 4K"
echo "###"
export USECASE=db-randwrite-4k
for X in 0; do  \
cmp="${USECASE}"; rbd="fio_bench.${X}.img"; oper="randwrite"; time=120; bs=4K; size=20g; depth=64; jobs=1; rrw=100;  \
file="/fio-test-dir/$(date +'%Y%m%d.%Hh%M')-fio-bench-cmp=${cmp}-rbd=${rbd}-op=${oper}-rrw=${rrw}-t=${time}-bs=${bs}-s=${size}-d=${depth}-j=${jobs}.txt";  \
echo "### output in ${file} ###";  \
fio --name=fiotst_${X} --ioengine=libaio --direct=1 --time_based --group_reporting=1 --readwrite=${oper} --rwmixread=${rrw} --bs=${bs} --size=${size} --iodepth=${depth} --numjobs=${jobs} --runtime=${time} --filename=/fio-test-dir/fio_bench_${X}/fiotst_${X}.img |& tee "${file}"; \
done


echo "###"
echo "### Performing USECASE db-randread 4K"
echo "###"
export USECASE=db-randread-4k
for X in 0; do  \
cmp="${USECASE}"; rbd="fio_bench.${X}.img"; oper="randread"; time=120; bs=4K; size=20g; depth=64; jobs=1; rrw=100;  \
file="/fio-test-dir/$(date +'%Y%m%d.%Hh%M')-fio-bench-cmp=${cmp}-rbd=${rbd}-op=${oper}-rrw=${rrw}-t=${time}-bs=${bs}-s=${size}-d=${depth}-j=${jobs}.txt";  \
echo "### output in ${file} ###";  \
fio --name=fiotst_${X} --ioengine=libaio --direct=1 --time_based --group_reporting=1 --readwrite=${oper} --rwmixread=${rrw} --bs=${bs} --size=${size} --iodepth=${depth} --numjobs=${jobs} --runtime=${time} --filename=/fio-test-dir/fio_bench_${X}/fiotst_${X}.img |& tee "${file}"; \
done


echo "###"
echo "### Performing USECASE db-randwrite 8K"
echo "###"
export USECASE=db-randwrite-8k
for X in 0; do  \
cmp="${USECASE}"; rbd="fio_bench.${X}.img"; oper="randwrite"; time=120; bs=8k; size=20g; depth=64; jobs=1; rrw=100;  \
file="/fio-test-dir/$(date +'%Y%m%d.%Hh%M')-fio-bench-cmp=${cmp}-rbd=${rbd}-op=${oper}-rrw=${rrw}-t=${time}-bs=${bs}-s=${size}-d=${depth}-j=${jobs}.txt";  \
echo "### output in ${file} ###";  \
fio --name=fiotst_${X} --ioengine=libaio --direct=1 --time_based --group_reporting=1 --readwrite=${oper} --rwmixread=${rrw} --bs=${bs} --size=${size} --iodepth=${depth} --numjobs=${jobs} --runtime=${time} --filename=/fio-test-dir/fio_bench_${X}/fiotst_${X}.img |& tee "${file}"; \
done


echo "###"
echo "### Performing USECASE db-randread 8K"
echo "###"
export USECASE=db-randread-8k
for X in 0; do  \
cmp="${USECASE}"; rbd="fio_bench.${X}.img"; oper="randread"; time=120; bs=8k; size=20g; depth=64; jobs=1; rrw=100;  \
file="/fio-test-dir/$(date +'%Y%m%d.%Hh%M')-fio-bench-cmp=${cmp}-rbd=${rbd}-op=${oper}-rrw=${rrw}-t=${time}-bs=${bs}-s=${size}-d=${depth}-j=${jobs}.txt";  \
echo "### output in ${file} ###";  \
fio --name=fiotst_${X} --ioengine=libaio --direct=1 --time_based --group_reporting=1 --readwrite=${oper} --rwmixread=${rrw} --bs=${bs} --size=${size} --iodepth=${depth} --numjobs=${jobs} --runtime=${time} --filename=/fio-test-dir/fio_bench_${X}/fiotst_${X}.img |& tee "${file}"; \
done


echo "###"
echo "### Performing USECASE Backupto-write"
echo "###"
export USECASE=Backupto-write-1m
for X in 0; do  \
cmp="${USECASE}"; rbd="fio_bench.${X}.img"; oper="write"; time=120; bs=1M; size=50g; depth=64; jobs=1; rrw=0;  \
file="/fio-test-dir/$(date +'%Y%m%d.%Hh%M')-fio-bench-cmp=${cmp}-rbd=${rbd}-op=${oper}-rrw=${rrw}-t=${time}-bs=${bs}-s=${size}-d=${depth}-j=${jobs}.txt";  \
echo "### output in ${file} ###";  \
fio --name=fiotst_${X} --ioengine=libaio --direct=1 --time_based --group_reporting=1 --readwrite=${oper} --rwmixread=${rrw} --bs=${bs} --size=${size} --iodepth=${depth} --numjobs=${jobs} --runtime=${time} --filename=/fio-test-dir/fio_bench_${X}/fiotst_${X}.img |& tee "${file}"; \
done