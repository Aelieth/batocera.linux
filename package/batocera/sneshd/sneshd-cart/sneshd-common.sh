# Shared helpers for SNES-HD cart scripts. Source only.

SNESHD_LOG="${SNESHD_LOG:-/tmp/sneshd-cart.log}"
SNESHD_HEALTH="${SNESHD_HEALTH:-/tmp/cart_health}"
SNESHD_RUN="${SNESHD_RUN:-/run/sneshd}"
SNESHD_SESSION="${SNESHD_SESSION:-$SNESHD_RUN/session}"
SNESHD_USB_WAIT="${SNESHD_USB_WAIT:-3}"

SHARE_OPTS="noatime,nodiratime,autodefrag"
SAVES_OPTS="rw,noatime,nodiratime,autodefrag"

log_msg() {
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $1" >> "$SNESHD_LOG"
}

block_parent() {
    local dev="$1"
    local name="${dev#/dev/}"
    local parent
    parent=$(lsblk -no PKNAME "$dev" 2>/dev/null | head -n1)
    if [ -n "$parent" ]; then
        echo "$parent"
        return
    fi
    echo "$name" | sed -e 's/p[0-9][0-9]*$//' -e 's/[0-9][0-9]*$//'
}

tune_block() {
    local dev="$1"
    local ra="${2:-256}"
    local parent
    parent=$(block_parent "$dev")
    [ -z "$parent" ] && return
    if [ -w "/sys/block/${parent}/queue/read_ahead_kb" ]; then
        echo "$ra" > "/sys/block/${parent}/queue/read_ahead_kb" 2>/dev/null || true
    fi
    if [ -w "/sys/block/${parent}/queue/scheduler" ]; then
        echo none > "/sys/block/${parent}/queue/scheduler" 2>/dev/null || true
    fi
}

umount_dev() {
    local device="$1"
    local name="${device#/dev/}"
    local mp attempt
    sync
    lsblk -nrpo NAME,MOUNTPOINT | awk -v n="$name" '$1 ~ n && $2 ~ /^\// {print $2}' | sort -u | while read -r mp; do
        [ -z "$mp" ] && continue
        attempt=1
        while [ "$attempt" -le 3 ]; do
            if umount "$mp" 2>/dev/null; then
                break
            fi
            if [ "$attempt" -eq 3 ]; then
                umount -l "$mp" 2>/dev/null || true
            fi
            attempt=$((attempt + 1))
        done
    done
}

bind_over() {
    local source="$1"
    local target="$2"
    local options="$3"
    mkdir -p "$target"
    if mountpoint -q "$target" 2>/dev/null; then
        umount "$target" 2>/dev/null || umount -l "$target" 2>/dev/null || true
    fi
    mount -o "bind,${options}" "$source" "$target"
}

write_session() {
    mkdir -p "$SNESHD_RUN"
    {
        echo "MODE=$1"
        echo "CART_LABEL=${cart_label:-}"
        echo "CART_ID=${cart_id:-}"
        echo "CART_UUID=${cart_uuid:-}"
        echo "CART_RAID=${cart_raid:-0}"
        echo "SHARE_UUID=${share_uuid:-}"
        echo "SNES_UUID=${snes_uuid:-}"
        echo "SAVES_UUID=${saves_uuid:-}"
        echo "YANK=1"
    } > "$SNESHD_SESSION"
}

session_mode() {
    [ -f "$SNESHD_SESSION" ] || { echo admin; return; }
    awk -F= '/^MODE=/ {print $2; exit}' "$SNESHD_SESSION"
}

yank_enabled() {
    [ -f "$SNESHD_SESSION" ] || return 1
    grep -q '^MODE=cart$' "$SNESHD_SESSION" || return 1
    grep -q '^YANK=1$' "$SNESHD_SESSION"
}

# Populate share_*/snes_*/cart_*/saves_* from BTRFS labels. No /dev/sd* tests.
# Use blkid (superblock). lsblk udev labels can be empty right after resize.
discover_volumes() {
    share_label=""; share_uuid=""; share_dev=""
    snes_label=""; snes_uuid=""; snes_dev=""
    cart_label=""; cart_uuid=""; cart_dev=""; cart_id=""; cart_raid=0
    saves_label=""; saves_uuid=""; saves_dev=""

    local dev label uuid fstype
    while IFS= read -r line; do
        case "$line" in
            /dev/*:*) ;;
            *) continue ;;
        esac
        dev="${line%%:*}"
        fstype=$(blkid -s TYPE -o value "$dev" 2>/dev/null)
        [ "$fstype" = "btrfs" ] || continue
        label=$(blkid -s LABEL -o value "$dev" 2>/dev/null)
        uuid=$(blkid -s UUID -o value "$dev" 2>/dev/null)
        [ -n "$label" ] || continue
        case "$label" in
            SHARE)
                share_label="$label"; share_uuid="$uuid"; share_dev="$dev"
                ;;
            SNES)
                snes_label="$label"; snes_uuid="$uuid"; snes_dev="$dev"
                ;;
            SNES-*)
                if [ -z "$cart_label" ]; then
                    cart_label="$label"
                    cart_uuid="$uuid"
                    cart_dev="$dev"
                    cart_id="${label#SNES-}"
                elif [ "$uuid" = "$cart_uuid" ]; then
                    cart_dev="$cart_dev $dev"
                    cart_raid=1
                else
                    log_msg "Ignoring extra cart $label on $dev (already using $cart_label)"
                fi
                ;;
            SAVES)
                saves_label="$label"; saves_uuid="$uuid"; saves_dev="$dev"
                ;;
        esac
    done < <(blkid 2>/dev/null)

    # S11 may already have SHARE at /userdata before udev refreshes labels.
    if [ -z "$share_dev" ] && mountpoint -q /userdata 2>/dev/null; then
        dev=$(findmnt -n -o SOURCE /userdata 2>/dev/null)
        if [ -n "$dev" ] && [ "$(blkid -s LABEL -o value "$dev" 2>/dev/null)" = "SHARE" ]; then
            share_dev="$dev"
            share_uuid=$(blkid -s UUID -o value "$dev" 2>/dev/null)
            share_label="SHARE"
        fi
    fi
}
