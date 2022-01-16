// TODO
// Add line trace offset at start and end

animation <- {
    idle = "Idle01",
    eat01 = "Eat_A",
    eat02 = "Eat_B",
    walk = "Walk",
    run = "Run",
    hop = "Hop",
    takeoff = "Takeoff"
    fly = "Fly01",
    soar = "Soar",
    land01 = "Land",
    land02 = "Land_b"
}

::new_pigeon <- function(spawn_target, flight_targets) {

    local pigeon = {

        MIN_SCALE = 1,
        MAX_SCALE = 1.25,

        MIN_ESCAPE_DISTANCE = 250.0,
        MAX_ESCAPE_DISTANCE = 550.0,
        
        MIN_IDLE_TIME = 5.0,
        MAX_IDLE_TIME = 25.0,

        FLIGHT_DURATION_FACTOR = 0.002,

        _escape_distance = 0,
        _idle_time = 0,

        _ecape_start_pos = null,
        _ecape_end_pos = null,

        _active_target = spawn_target,
        _flight_targets = flight_targets,

        _is_escaping = false,

        _time_start_escape = 0,
        _time_last_escape = 0,

        _anim_state = null,

        _sorted_bezier_points = [],

        _ang = null,

        _prop = null,

        function setup() {
            entity_maker.Spawn("pigeon_template",  _active_target.pos, Vector());

            local handle = null;
            handle = Entities.FindByNameNearest("spawned_pigeon_mdl",  _active_target.pos, 0);

            _prop = new_prop_dynamic_from_handle(handle, false);
            _prop.set_animation(animation.idle);

            update_random_variables();
        }

        function update() {
            if (!_is_escaping) {
                local player = null;
                player = Entities.FindByClassnameWithin(player, "player", _active_target.pos, _escape_distance);

                if (player || Time() - _time_last_escape > _idle_time) {
                    start_escape();
                }
            }
            else {
                local previous_pos = _prop.get_pos();
                local pos = update_and_get_flight_position(Time() - _time_start_escape);

                if (pos == null) {
                    _is_escaping = false;
                }
                else {
                    if (previous_pos != null && (pos - previous_pos).Length() > 0.01) {
                        local temp_ang = math.vec_angle_from_pos(previous_pos, pos);
                        if (temp_ang.y < 360 && temp_ang.y > -360) {
                            _ang = temp_ang;
                            _ang.x = math.abs(_ang.x) * 1 * -1;
                        }
                    } else if (_ang != null) {
                        _ang.x = 0
                    }
                }
                _prop.teleport(pos, _ang);
            }
        }

        function update_and_get_flight_position(elapsed_time) {
            local flight_duration = _anim_state.get_sequence_duration();

            local percent = elapsed_time / flight_duration;
            if (percent >= 1){
                // flight done, exit early
                _prop.set_animation(animation.idle);
                return null
            }
            local animation_end_time = _anim_state.idle.duration;
            if (_anim_state.idle.started && !_anim_state.takeoff.started){
                // check if takeoff should be started
                if(elapsed_time > animation_end_time){
                    end_anim_segment("idle")
                    start_anim_segment("takeoff")
                }
            }
            animation_end_time += _anim_state.takeoff.duration;
            if(_anim_state.takeoff.started && !_anim_state.fly.started){
                // check if fly should be started
                if(elapsed_time > animation_end_time){
                    end_anim_segment("takeoff")
                    start_anim_segment("fly")
                }
            }
            animation_end_time += _anim_state.fly.duration;
            if(_anim_state.fly.started && !_anim_state.land.started){
                // check if land should be started
                if(elapsed_time > animation_end_time){
                    end_anim_segment("fly")
                    start_anim_segment("land")
                }
            }
            if(_anim_state.takeoff.started || _anim_state.fly.started || _anim_state.land.started){
                // get position
                local percent = (elapsed_time - _anim_state.idle.duration) / (flight_duration - _anim_state.idle.duration);
                percent = math.interpolate_smooth(percent);
                return math.get_bezier_point(_sorted_bezier_points, percent);
            }
            return _ecape_start_pos;
        }

        function update_random_variables() {
            _escape_distance = RandomFloat(MIN_ESCAPE_DISTANCE, MAX_ESCAPE_DISTANCE);
            _idle_time = RandomFloat(MIN_IDLE_TIME, MAX_IDLE_TIME);
        }

        function start_escape() {
            local new_target = get_valid_flight_target();
            if (new_target == null) {
                return;
            }

            update_random_variables();

            _is_escaping = true;
            
            _active_target.is_used = false;

            _ecape_start_pos = _active_target.pos;
            _ecape_end_pos = new_target.pos;

            _active_target = new_target;
            _active_target.is_used = true;

            _sorted_bezier_points = get_bezier_points(_ecape_start_pos, _ecape_end_pos);

            local v_rel = _ecape_end_pos - _ecape_start_pos;
            local v_len = v_rel.Length();
            local flight_duration = v_len * FLIGHT_DURATION_FACTOR;

            _time_start_escape = Time();
            _time_last_escape = _time_start_escape + flight_duration;

            _anim_state = create_animation_sequence(_ecape_start_pos, flight_duration);

            start_anim_segment("idle");
        }

        function get_bezier_points(v_start, v_end) {
            local high_start = Vector(v_start.x, v_start.y, v_end.z);
            local low_end = Vector(v_end.x, v_end.y, v_start.z);
            local distance = (v_start - low_end).Length();
            local xy_normal_offset = math.vec_mul(math.vec_orthogonal_XY(math.vec_normalize_XYZ(v_start - low_end)), RandomFloat(0, 0.2) * distance);
            return [v_start, math.vec_lerp(v_start, low_end, 0.2) + xy_normal_offset, math.vec_lerp(high_start, v_end, 0.6) + Vector(0, 0, distance / 5.0) - xy_normal_offset, math.vec_lerp(high_start, v_end, 0.8), v_end];
        }

        function get_valid_flight_target() {
            local flight_target_count = _flight_targets.len();

            local loops = 0;
            while (loops < flight_target_count) {
                local index = RandomInt(0, flight_target_count - 1);
                if (!_flight_targets[index].is_used) {
                    local trace_distance = TraceLine(_active_target.pos, _flight_targets[index].pos, null);
                    if (trace_distance == 1) {
                        return _flight_targets[index];
                    }
                }
                loops++;
            }

            return null;
        }

        function start_anim_segment(segment_name) {
            _anim_state[segment_name].started = true;
            _anim_state[segment_name].start_time = Time();
            _prop.set_animation(_anim_state[segment_name].animation);
        }

        function end_anim_segment(segment_name) {
            _anim_state[segment_name].completed = true;
        }

        function create_animation_sequence(start_pos, flight_duration) {
            local aState = {
                get_sequence_duration = function() {
                    return this.idle.duration + this.takeoff.duration + this.fly.duration + this.land.duration
                }
                idle = {
                    animation = animation.idle,
                    started = false,
                    start_pos = start_pos,
                    start_time = -1,
                    completed = false,
                    duration = 0,
                },
                takeoff = {
                    animation = animation.takeoff,
                    started = false,
                    start_pos = start_pos,
                    start_time = -1,
                    completed = false,
                    duration = 1.33,
                },
                fly = {
                    animation = animation.fly,
                    started = false,
                    start_pos = null,
                    start_time = -1,
                    completed = false,
                    duration = flight_duration,
                },
                land = {
                    animation = animation.land01,
                    started = false,
                    start_pos = null,
                    start_time = -1,
                    completed = false,
                    duration = 1.4,
                }
            }
            return aState
        }
    }

    pigeon.setup();
    return pigeon;
}
