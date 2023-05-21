#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2020 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

function blob_fixup() {
    case "${1}" in
        vendor/lib/hw/camera.sdm660.so)
            for LIBCAMERA_SDM660_SHIM in $(grep -L "libcamera_sdm660_shim.so" "${2}"); do
                "${PATCHELF}" --add-needed "libcamera_sdm660_shim.so" "$LIBCAMERA_SDM660_SHIM"
            done
            ;;
        vendor/lib/libMiWatermark.so)
            "${PATCHELF}" --add-needed "libmiwatermark_shim.so" "${2}"
            ;;
        vendor/lib64/libgf_ca.so)
            sed -i 's|/system/etc/firmware|/vendor/firmware\x0\x0\x0\x0|g' "${2}"
            ;;
                system_ext/etc/init/dpmd.rc)
            sed -i "s|/system/product/bin/|/system/system_ext/bin/|g" "${2}"
            ;;
        system_ext/etc/permissions/com.qti.dpmframework.xml | system_ext/etc/permissions/dpmapi.xml | system_ext/etc/permissions/telephonyservice.xml)
            sed -i "s|/system/product/framework/|/system/system_ext/framework/|g" "${2}"
            ;;
        system_ext/etc/permissions/qcrilhook.xml)
            sed -i 's|/product/framework/qcrilhook.jar|/system_ext/framework/qcrilhook.jar|g' "${2}"
            ;;
        system_ext/lib64/libdpmframework.so)
            for LIBSHIM_DPMFRAMEWORK in $(grep -L "libshim_dpmframework.so" "${2}"); do
                "${PATCHELF}" --add-needed "libshim_dpmframework.so" "$LIBSHIM_DPMFRAMEWORK"
            done
            ;;
        vendor/bin/mlipayd@1.1)
           "${PATCHELF}" --remove-needed vendor.xiaomi.hardware.mtdservice@1.0.so "${2}"
            ;;
        vendor/lib64/libmlipay.so | vendor/lib64/libmlipay@1.1.so)
            "${PATCHELF}" --remove-needed vendor.xiaomi.hardware.mtdservice@1.0.so "${2}"
            sed -i "s|/system/etc/firmware|/vendor/firmware\x0\x0\x0\x0|g" "${2}"
            ;;
    esac
}

# If we're being sourced by the common script that we called,
# stop right here. No need to go down the rabbit hole.
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    return
fi

set -e

export DEVICE=whyred
export VENDOR=xiaomi
