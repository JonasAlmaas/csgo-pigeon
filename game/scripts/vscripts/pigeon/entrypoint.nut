::MODULE_EXT <- ".nut";
::BASE_FOLDER <- "pigeon/";

::custom_entities <- {
    prop_dynamic = [],
    prop_dynamic_glow = [],
}

/*
    Entity group
*/
::entity_maker <- EntityGroup[0].GetScriptScope();

::HOT_RELOAD <- function () {

    reset_session();

    printl("Reloading scripts...");
    DoIncludeScript(BASE_FOLDER + "main" + MODULE_EXT, null);
    printl(" ...successful");
}
DoIncludeScript(BASE_FOLDER + "main" + MODULE_EXT, null);

function Precache() {
    
}
