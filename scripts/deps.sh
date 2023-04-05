paths='/data/data/com.termux/files/usr/lib/libprotobuf.so
/system/lib64/libc.so
/data/data/com.termux/files/usr/lib/libbrotlidec.so
/data/data/com.termux/files/usr/lib/libbrotlienc.so
/data/data/com.termux/files/usr/lib/liblz4.so
/data/data/com.termux/files/usr/lib/libusb-1.0.so
/data/data/com.termux/files/usr/lib/libz.so.1
/data/data/com.termux/files/usr/lib/libzstd.so.1
/data/data/com.termux/files/usr/lib/libc++_shared.so
/system/lib64/libdl.so
/data/data/com.termux/files/usr/lib/libabsl_die_if_null.so
/data/data/com.termux/files/usr/lib/libabsl_statusor.so
/data/data/com.termux/files/usr/lib/libabsl_log_internal_check_op.so
/data/data/com.termux/files/usr/lib/libabsl_log_internal_message.so
/data/data/com.termux/files/usr/lib/libabsl_log_internal_nullguard.so
/data/data/com.termux/files/usr/lib/libabsl_hash.so
/data/data/com.termux/files/usr/lib/libabsl_raw_hash_set.so
/data/data/com.termux/files/usr/lib/libabsl_status.so
/data/data/com.termux/files/usr/lib/libabsl_cord.so
/data/data/com.termux/files/usr/lib/libabsl_synchronization.so
/data/data/com.termux/files/usr/lib/libabsl_time.so
/data/data/com.termux/files/usr/lib/libabsl_time_zone.so
/data/data/com.termux/files/usr/lib/libabsl_str_format_internal.so
/data/data/com.termux/files/usr/lib/libabsl_bad_variant_access.so
/data/data/com.termux/files/usr/lib/libabsl_strings.so
/data/data/com.termux/files/usr/lib/libabsl_throw_delegate.so
/data/data/com.termux/files/usr/lib/libabsl_spinlock_wait.so
/system/lib64/ld-android.so
/data/data/com.termux/files/usr/lib/libabsl_examine_stack.so
/data/data/com.termux/files/usr/lib/libabsl_log_internal_format.so
/data/data/com.termux/files/usr/lib/libabsl_log_internal_proto.so
/data/data/com.termux/files/usr/lib/libabsl_strerror.so
/data/data/com.termux/files/usr/lib/libabsl_log_internal_log_sink_set.so
/data/data/com.termux/files/usr/lib/libabsl_log_internal_globals.so
/data/data/com.termux/files/usr/lib/libabsl_log_globals.so
/data/data/com.termux/files/usr/lib/libabsl_base.so
/data/data/com.termux/files/usr/lib/libabsl_raw_logging_internal.so
/data/data/com.termux/files/usr/lib/libabsl_stacktrace.so
/data/data/com.termux/files/usr/lib/libabsl_symbolize.so
/data/data/com.termux/files/usr/lib/libabsl_int128.so
/system/lib64/libm.so
/data/data/com.termux/files/usr/lib/libabsl_strings_internal.so
/data/data/com.termux/files/usr/lib/libabsl_log_sink.so
/system/lib64/liblog.so
/data/data/com.termux/files/usr/lib/libabsl_city.so
/data/data/com.termux/files/usr/lib/libabsl_low_level_hash.so
/data/data/com.termux/files/usr/lib/libabsl_malloc_internal.so
/system/lib64/libc++.so
/data/data/com.termux/files/usr/lib/libabsl_cordz_info.so
/data/data/com.termux/files/usr/lib/libabsl_cord_internal.so
/data/data/com.termux/files/usr/lib/libabsl_crc_cord_state.so
/data/data/com.termux/files/usr/lib/libabsl_cordz_functions.so
/data/data/com.termux/files/usr/lib/libabsl_cordz_handle.so
/data/data/com.termux/files/usr/lib/libabsl_crc32c.so
/data/data/com.termux/files/usr/lib/libabsl_crc_internal.so
/data/data/com.termux/files/usr/lib/libabsl_exponential_biased.so
/data/data/com.termux/files/usr/lib/libbrotlicommon.so'
function pull() {
    for i in $paths; do
        name=$(basename $i)
        scp -P 8022 android/app/src/main/jniLibs/arm64-v8a/$name.so nightmare@192.168.0.101:/data/data/com.nightmare.termare/files/usr/lib/$name
        # scp -P 8022 nightmare@192.168.0.101:$i android/app/src/main/jniLibs/arm64-v8a/
        # mv android/app/src/main/jniLibs/arm64-v8a/$name android/app/src/main/jniLibs/arm64-v8a/$name.so
        echo "$i"
    done
}
pull