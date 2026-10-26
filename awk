BEGIN {
    src = 0
    dst = 2
    bandwidth = 10000000
}

$1 == "+" && $3 == src && !($12 in start) {
    start[$12] = $2
    sent++

    if (sent == 1) {
        first_start = $2
    }
}

$1 == "r" && $4 == dst && ($12 in start) && !($12 in done) {
    done[$12] = 1
    received++
    total_delay += $2 - start[$12]
    bits += $6 * 8
    last_end = $2
}

END {
    duration = last_end - first_start
    throughput = bits / duration

    printf "Frames sent:              %d\n", sent
    printf "Frames received:          %d\n", received
    printf "PDR:                      %.2f %%\n", received / sent * 100
    printf "First frame start:        %.6f s\n", first_start
    printf "Last frame end:           %.6f s\n", last_end
    printf "Average end-to-end delay: %.3f ms\n", total_delay / received * 1000
    printf "Throughput:               %.2f bits/sec\n", throughput
    printf "Link utilization:         %.2f %%\n", throughput / bandwidth * 100
}
