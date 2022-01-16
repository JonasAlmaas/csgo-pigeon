
::new_base_entity <- function() {

    local entity = {
        ref = null,
        is_disabled = false,

        function reset() { enable(); }
        function enable() {
            is_disabled = false;
            show();
        }
        function disable() {
            is_disabled = true;
            hide();
        }
        function teleport(pos=null, ang=null) {
            if (pos) { ref.SetOrigin(pos); }
            if (ang) { ref.SetAngles(ang.x, ang.y, ang.z); }
        }

        function get_pos() { return ref.GetOrigin(); }
        function get_ang() { return ref.GetAngles(); }

        function show() { EntFireByHandle(ref, "Enable", "", 0.0, null, null); }
        function hide() { EntFireByHandle(ref, "Disable", "", 0.0, null, null); }
    }

    return entity;
}

::new_prop_dynamic <- function () {

    foreach (prop in custom_entities.prop_dynamic) {
        if (prop.is_disabled) {
            prop.reset();
            return prop;
        }
    }
    
    local prop = new_prop_dynamic_from_handle(Entities.CreateByClassname("prop_dynamic"));

    return prop;
}

::new_prop_dynamic_from_handle <- function (ref, add_to_custom_entities = true) {
    local prop = new_base_entity();
    prop.ref = ref;

    prop.reset <- function () {
        enable();
        set_scale(1);
        enable_shadows();
        set_color([255,255,255]);
        teleport(Vector(), Vector());
    }

    prop.enable_shadows <- function () { ref.__KeyValueFromInt("disableshadowdepth", 0); }
    prop.disable_shadows <- function () { ref.__KeyValueFromInt("disableshadowdepth", 1); }

    prop.set_color <- function (color) { EntFireByHandle(ref, "Color", convertion.list_to_string(color), 0.0, null, null); }
    prop.set_model <- function (path) { ref.SetModel(path); }
    prop.set_scale <- function (scale) { ref.__KeyValueFromFloat("modelscale", scale); }
    prop.set_animation <- function (animation_name) { EntFireByHandle(ref, "SetAnimation", animation_name, 0.0, null, null); }

    if (add_to_custom_entities)
        custom_entities.prop_dynamic.append(prop);

    return prop;
}

::new_prop_dynamic_glow <- function () {

    foreach (prop in custom_entities.prop_dynamic_glow) {
        if (prop.is_disabled) {
            prop.reset();
            return prop;
        }
    }

    local prop = new_base_entity();
    prop.ref = Entities.CreateByClassname("prop_dynamic_glow");

    prop.reset <- function () {
        enable();
        set_scale(1);
        enable_shadows();
        set_color([255,255,255]);
        set_glow_color([255,255,255]);
        teleport(Vector(), Vector());
    }

    prop.enable_shadows <- function () { ref.__KeyValueFromInt("disableshadowdepth", 0); }
    prop.disable_shadows <- function () { ref.__KeyValueFromInt("disableshadowdepth", 1); }
    prop.enable_glow <- function () { EntFireByHandle(ref, "SetGlowEnabled", "", 0.0, null, null); }
    prop.disable_glow <- function () { EntFireByHandle(ref, "SetGlowDisabled", "", 0.0, null, null); }

    prop.set_color <- function (color) { EntFireByHandle(ref, "Color", convertion.list_to_string(color), 0.0, null, null); }
    prop.set_glow_color <- function (color) { EntFireByHandle(ref, "SetGlowColor", convertion.list_to_string(color), 0.0, null, null); }
    prop.set_glow_distance <- function (distance) { ref.__KeyValueFromInt("glowdist", distance); }
    prop.set_model <- function (path) { ref.SetModel(path); }
    prop.set_scale <- function (scale) { ref.__KeyValueFromFloat("modelscale", scale); }

    prop.enable_glow();

    custom_entities.prop_dynamic_glow.append(prop);

    return prop;
}
