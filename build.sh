echo -e "\nStarting compilation...\n"
# ENV

# Some general variables
ANYKERNEL3_DIR=$PWD/AnyKernel3/
FINAL_KERNEL_ZIP=PornX-vayu-miui.zip

CONFIG=nethunter_defconfig
KERNEL_DIR=$(pwd)
PARENT_DIR="$(dirname "$KERNEL_DIR")"
KERN_IMG="$KERNEL_DIR/out/arch/arm64/boot/Image"
export KBUILD_BUILD_USER="MNoxx74"
export KBUILD_BUILD_HOST="Dev_TH"
export KBUILD_BUILD_TIMESTAMP="$(TZ=Asia/Kuala_Lumpur date)"
export PATH="$HOME/android/toolchains/clang-15/bin:$PATH"
export LD_LIBRARY_PATH="$HOME/android/toolchains/clang-15/lib:$LD_LIBRARY_PATH"
export KBUILD_COMPILER_STRING="$($HOME/android/toolchains/clang-15/bin/clang --version | head -n 1 | perl -pe 's/\((?:http|git).*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//' -e 's/^.*clang/clang/')"
# export CROSS_COMPILE=$HOME/android/toolchains/gcc64/aarch64-linux-android-4.9/bin/aarch64-linux-android-
# export CROSS_COMPILE_ARM32=$HOME/android/toolchains/gcc32/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-
export out=out

# let's clean the output first before building
if [ -d $out ]; then
 echo -e "Cleaning out leftovers...\n"
 rm -rf $out
fi;

mkdir -p $out

# Functions
clang_build () {
    make -j$(nproc --all) O=$out \
                          ARCH=arm64 \
                          CC="clang" \
                          AR="llvm-ar" \
                          NM="llvm-nm" \
                          LD="ld.lld" \
                          AS="llvm-as" \
                          STRIP="llvm-strip" \
                          OBJCOPY="llvm-objcopy" \
                          OBJDUMP="llvm-objdump" \
                          CROSS_COMPILE=aarch64-linux-gnu- \
                          CROSS_COMPILE_ARM32=arm-linux-gnueabi-
}

# Build kernel
make O=$out ARCH=arm64 $CONFIG > /dev/null

make O=$out ARCH=arm64 menuconfig

echo -e "${bold}Compiling with CLANG${normal}\n$KBUILD_COMPILER_STRING"
clang_build

echo -e "$yellow**** Verify Image & dtbo.img & dtb ****$nocol"
ls $PWD/out/arch/arm64/boot/Image
ls $PWD/out/arch/arm64/boot/dtbo.img
ls $PWD/out/arch/arm64/boot/dts/qcom/dtb

echo -e "$yellow**** Verifying AnyKernel3 Directory ****$nocol"
ls $ANYKERNEL3_DIR/

echo -e "$yellow**** Removing leftovers ****$nocol"
rm -rf $ANYKERNEL3_DIR/Image
rm -rf $ANYKERNEL3_DIR/dtbo.img
rm -rf $ANYKERNEL3_DIR/dtb
rm -rf $ANYKERNEL3_DIR/$FINAL_KERNEL_ZIP

cd $PWD/out/arch/arm64/boot/dts/qcom/
find . -name '*.dtb' -exec cat {} + > dtb
cd /home/mnoxx74/android/kernel/vayu-test/

echo -e "$yellow**** Copying Image & dtbo.img & dtb ****$nocol"
cp $PWD/out/arch/arm64/boot/Image $ANYKERNEL3_DIR/
cp $PWD/out/arch/arm64/boot/dtbo.img $ANYKERNEL3_DIR/
cp $PWD/out/arch/arm64/boot/dts/qcom/dtb $ANYKERNEL3_DIR/

echo -e "$yellow**** Time to zip up! ****$nocol"
cd $ANYKERNEL3_DIR/
zip -r9 $FINAL_KERNEL_ZIP * -x README $FINAL_KERNEL_ZIP
cd ..

echo -e "\nKernel compiled succesfully!\n"
echo -e "\nCompleted in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) !"
exit 0
