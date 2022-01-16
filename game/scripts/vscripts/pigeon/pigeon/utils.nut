
::new_flight_target <- function(pos) {
    local flight_target = {
        pos = pos,
        is_used = false,
    }
    return flight_target;
}
