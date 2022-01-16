
::new_pigeon_factory <- function() {

    local factory = {
        MIN_PIGEON_COUNT = 5,
        MAX_PIGEON_COUNT = 10,

        pigeons = [],
        flight_targets = [],

        function setup() {
            local target = null;
            while (target = Entities.FindByName(target, "pigeon_target")) {
                flight_targets.append(new_flight_target(target.GetOrigin()));
            }

            if (MIN_PIGEON_COUNT > flight_targets.len()) MIN_PIGEON_COUNT = flight_targets.len();
            if (MAX_PIGEON_COUNT > flight_targets.len()) MAX_PIGEON_COUNT = flight_targets.len();
            local pigeon_count = RandomInt(MIN_PIGEON_COUNT, MAX_PIGEON_COUNT);

            for (local i = 0; i < pigeon_count; i++) {
                local flight_target_count = flight_targets.len();

                local loops = 0;
                while (loops < flight_target_count) {
                    local index = RandomInt(0, flight_target_count - 1);
                
                    if (!flight_targets[index].is_used) {
                        flight_targets[index].is_used = true;
                        pigeons.append(new_pigeon(flight_targets[index], flight_targets));
                        break;
                    }
                    loops++;
                }
            }
        }

        function update() {
            foreach (pigeon in pigeons) {
                pigeon.update();
            }
        }
    }

    factory.setup();
    return factory;
}
