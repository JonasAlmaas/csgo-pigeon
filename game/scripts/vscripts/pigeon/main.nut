/*
    Global constants
*/
::IS_DEBUGGING <- true;

/*
    Global includes
*/
::SCRIPTS_MANIFEST_UTILITIES <- [
    "utils/console",
    "utils/convertion",
    "utils/custom_entities",
    "utils/debug_draw",
    "utils/entity_maker",
    "utils/math",
    "utils/utils",
]

::SCRIPTS_MANIFEST_PIGEON <- [
    "pigeon/flight_target",
    "pigeon/pigeon_factory",
    "pigeon/pigeon",
]

::include_scripts <- function() {

    local include_manifest = function(manifest) {
        foreach(script in manifest){
            DoIncludeScript(BASE_FOLDER + script + MODULE_EXT, null);
        }
    }
    include_manifest(SCRIPTS_MANIFEST_UTILITIES)
    include_manifest(SCRIPTS_MANIFEST_PIGEON)
}
include_scripts();

/*
    Global variables
*/
::pigeon_factory <- null;

::initialized <- false;

::update <- function () {

    calculate_tickrate();

    if (!initialized) {
        
        pigeon_factory = new_pigeon_factory();

        initialized = true;
    }

    pigeon_factory.update();
}

::reset_session <- function () {
    utils.remove_decals();

    console.run("clear_debug_overlays");
}

/*
    TICKRATE
*/
::TICKS <- 0;
::TICKRATE <- -1;
::TICKTIME <- -1;
::calculate_tickrate <- function() {

    if(TICKRATE == -1) {
        TICKS += 1;
        if(TICKTIME == -1) {
            TICKTIME = Time();
        }
        if(Time() - TICKTIME > 1) {
            if(TICKS > 96) {
                TICKRATE = 128;
            } else {
                TICKRATE = 64;
            }
        }
    }
}
