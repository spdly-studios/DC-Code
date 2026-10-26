BEGIN {
    source = 0
    destination = 2
    bandwidth = 10000000
    traffic = "all"

    event_col = 1
    time_col = 2
    from_col = 3
    to_col = 4
    type_col = 5
    size_col = 6
    id_col = 12

    send_event = "+"
    receive_event = "r"

    first = last = -1
}

NF >= id_col && $event_col !~ /^#/ {
    e = $event_col
    t = $time_col
    s = $from_col
    d = $to_col
    type = $type_col
    size = $size_col
    id = $id_col

    if (traffic != "all" && type != traffic) next

    if (e == send_event && s == source && !(id in start)) {
        start[id] = t
        sent++
        if (first < 0 || t < first) first = t
    }

    if (e == receive_event && d == destination &&
        (id in start) && !(id in end)) {
        end[id] = t
        bytes += size
        received++
        if (last < 0 || t > last) {
            last = t
            lastid = id
        }
    }
}

END {
    for (id in end) {
        delay = end[id] - start[id]
        if (delay >= 0) {
            total += delay
            n++
        }
    }

    duration = (first >= 0 && last >= first) ? last - first : 0
    pdr = sent ? received / sent * 100 : 0
    avg = n ? total / n : 0
    throughput = duration ? bytes * 8 / duration : 0
    utilization = bandwidth ? throughput / bandwidth * 100 : 0
    lastdelay = (lastid in start) ? last - start[lastid] : 0

    printf "Sent frames: %d\nReceived frames: %d\nPDR: %.2f%%\n", sent, received, pdr
    printf "First frame start: %.6f s\nLast frame delivered: %.6f s\n", first, last
    printf "Last frame delay: %.3f ms\nAverage delay: %.3f ms\n", lastdelay * 1000, avg * 1000
    printf "Duration: %.6f s\nThroughput: %.2f bits/sec (%.6f Mbps)\n", duration, throughput, throughput / 1000000
    printf "Link utilization: %.2f%%\n", utilization
}