echo "Populating /boot files"
BOOT_DIR="boot_output"
pmon-boot-cfg "$storeDir" "$BOOT_DIR" "(wd0,0)" "$topLevel"

echo "Preparing output image..."
BOOT_SIZE=$bootSizeMiB
ROOT_SIZE=$rootSizeMiB
TOTAL_SIZE=$((BOOT_SIZE + ROOT_SIZE))
OUTPUT_IMG="$outputImage"

BOOT_IMG="boot.img"
ROOT_IMG="$rootImage"

echo "Creating boot partition image..."
genext2fs -U -L "$bootLabel" -b $((BOOT_SIZE * 1024)) -d "$BOOT_DIR" "$BOOT_IMG"

echo "Creating final disk image..."
dd if=/dev/zero of="$OUTPUT_IMG" bs=1M count="$TOTAL_SIZE" status=progress

echo "Creating partition table..."
cat > partitioning.fdisk << EOF
o
n
p
1
2048
+${BOOT_SIZE}M
n
p
2
$((2048 + BOOT_SIZE * 2048))
$((TOTAL_SIZE * 2048 - 1))
a
1
w
EOF

fdisk "$OUTPUT_IMG" < partitioning.fdisk || true

echo "Writing boot partition to image..."
dd if="$BOOT_IMG" of="$OUTPUT_IMG" bs=512 seek=2048 conv=notrunc status=progress

echo "Writing root partition to image..."
dd if="$ROOT_IMG" of="$OUTPUT_IMG" bs=512 seek=$((2048 + BOOT_SIZE * 2048)) conv=notrunc status=progress

rm -f "$BOOT_IMG" partitioning.fdisk

cp "$OUTPUT_IMG" "$out"
