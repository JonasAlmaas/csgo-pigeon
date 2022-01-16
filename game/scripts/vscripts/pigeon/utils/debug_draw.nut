
::debug_draw <- {
    function line(p1, p2, RGB=[255,0,255], noDepthTest=true, duration=0) {
        DebugDrawLine(p1, p2, RGB[0], RGB[1], RGB[2], noDepthTest, duration);
    }
    function square_outline(p1, p2, p3, p4, RGB=[255,255,255], noDepthTest=true, duration=0) {
        line(p1, p2, RGB, noDepthTest, duration);
        line(p2, p3, RGB, noDepthTest, duration);
        line(p3, p4, RGB, noDepthTest, duration);
        line(p1, p4, RGB, noDepthTest, duration);
    }
    function box(p, min=Vector(-1,-1,-1), max=Vector(1,1,1), RGB=[255, 0, 0, 255], draw_time=0) {
        DebugDrawBox(p, min, max, RGB[0], RGB[1], RGB[2], RGB[3], draw_time);
    }
    function box_angles(p, min=Vector(-1,-1,-1), max=Vector(1,1,1), angles=Vector(0, 0, 0), RGB=[255, 0, 0, 255], draw_time=0) {
        DebugDrawBoxAngles(p, min, max, angles, RGB[0], RGB[1], RGB[2], RGB[3], draw_time);
    }
}
