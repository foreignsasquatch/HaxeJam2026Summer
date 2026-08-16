import raylib.Raymath;
import raylib.Types;
import raylib.Raylib;

var camera:Camera3DImpl;
var movementSpeed = 5.4;
var mouseSensitivity = 0.003;

function getCameraForward(camera:Camera3DImpl):Vector3 {
    return Raymath.Vector3Normalize(Raymath.Vector3Subtract(camera.target, camera.position));
}

function getCameraUp(camera:Camera3DImpl):Vector3 {
    return Raymath.Vector3Normalize(camera.up);
}

function getCameraRight(camera:Camera3DImpl):Vector3 {
    var forward = getCameraForward(camera);
    var up = getCameraUp(camera);
    return Raymath.Vector3Normalize(Raymath.Vector3CrossProduct(forward, up));
}

function cameraMoveForward(camera:Camera3DImpl, distance:Float, moveInWorldPlane:Bool) {
    var forward = getCameraForward(camera);

    if(moveInWorldPlane) {
        forward.y = 0;
        forward = Raymath.Vector3Normalize(forward);
    }

    forward = Raymath.Vector3Scale(forward, distance);
    camera.position = Raymath.Vector3Add(camera.position, forward);
    camera.target = Raymath.Vector3Add(camera.target, forward);
}

function cameraMoveRight(camera:Camera3DImpl, distance:Float, moveInWorldPlane:Bool) {
    var right = getCameraRight(camera);

    if(moveInWorldPlane) {
        right.y = 0;
        right = Raymath.Vector3Normalize(right);
    }

    right = Raymath.Vector3Scale(right, distance);

    camera.position = Raymath.Vector3Add(camera.position, right);
    camera.target =  Raymath.Vector3Add(camera.target, right);
}

function cameraYaw(camera:Camera3DImpl, angle:Float, rotateAroundTarget:Bool) {
    var up = getCameraUp(camera);
    var targetPosition = Raymath.Vector3Subtract(camera.target, camera.position);
    targetPosition = Raymath.Vector3RotateByAxisAngle(targetPosition, up, angle);

    if(rotateAroundTarget) camera.position = Raymath.Vector3Subtract(camera.target, targetPosition);
    else camera.target = Raymath.Vector3Add(camera.position, targetPosition);
}

function cameraPitch(camer:Camera3DImpl, angle:Float, lockView:Bool, rotateAroundTarget:Bool, rotateUp:Bool) {
    var up = getCameraUp(camera);
    var targetPosition = Raymath.Vector3Subtract(camera.target, camera.position);

    if(lockView) {
        var maxAngleUp = Raymath.Vector3Angle(up, targetPosition);
        maxAngleUp -= 0.001;
        if(angle > maxAngleUp) angle = maxAngleUp;
    
    
        var maxAngleDown = Raymath.Vector3Angle(Raymath.Vector3Negate(up), targetPosition);
        maxAngleDown *= -1;
        maxAngleDown += 0.001;
        if(angle < maxAngleDown) angle = maxAngleDown;
    }

    var right = getCameraRight(camera);
    var targetPosition = Raymath.Vector3RotateByAxisAngle(targetPosition, right, angle);

    if(rotateAroundTarget) camera.position = Raymath.Vector3Subtract(camera.target, targetPosition);
    else camera.target =  Raymath.Vector3Add(camera.position, targetPosition);

    if(rotateUp) camera.up = Raymath.Vector3RotateByAxisAngle(camera.up, right, angle);
}

function updateCamera() {
    var mvSpd = movementSpeed * Raylib.GetFrameTime();
    var mDelta = Raylib.GetMouseDelta();

    cameraYaw(camera, mDelta.x * mouseSensitivity, false);
    cameraPitch(camera, -mDelta.y * mouseSensitivity, true, false, false);


    trace('${camera.target.x} ${camera.target.y} ${camera.target.z}');
    trace('${camera.position.x} ${camera.position.y} ${camera.position.z}');

    if(Raylib.IsKeyDown(KEY_W)) cameraMoveForward(camera, mvSpd, true);
    if(Raylib.IsKeyDown(KEY_S)) cameraMoveForward(camera, -mvSpd, true);
    if(Raylib.IsKeyDown(KEY_A)) cameraMoveRight(camera, -mvSpd, true);
    if(Raylib.IsKeyDown(KEY_D)) cameraMoveRight(camera, mvSpd, true);

    if(Raylib.IsGamepadAvailable(0)) {
    }
}

function main() {
    Raylib.InitWindow(800, 600, "horse");
    Raylib.SetTargetFPS(60);

    camera = new Camera3D();
    camera.position = new Vector3(0, 1, 0);
    camera.target = new Vector3(0, 1, 1);
    camera.up = new Vector3(0, 1, 0);
    camera.fovy = 45;
    camera.projection = CAMERA_PERSPECTIVE;

    Raylib.DisableCursor();

    while(!Raylib.WindowShouldClose()) {
        updateCamera();

        Raylib.BeginDrawing();
        {
            Raylib.ClearBackground(Raylib.BLACK);

            Raylib.BeginMode3D(camera);
            Raylib.DrawPlane(new Vector3(0, 0, 0),  new Vector2(5, 5), Raylib.WHITE);
            Raylib.EndMode3D();
        }
        Raylib.EndDrawing();
    }

    Raylib.CloseWindow();
}
