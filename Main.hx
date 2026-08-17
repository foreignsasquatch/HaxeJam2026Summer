// I think most of this code is stolen from raylib examples
// I'm too sleepy to think of new ideas
// And to do math as well
import raylib.Raymath.*;
import raylib.Types;
import raylib.Raylib;

var gravity = 32.;
var maxSpeed = 15.;
var jumpForce = 12.;
var maxAcceleration = 150.;
var friction = 0.86;
var airDrag = 0.98;
var control = 15.;
var height = 1.;

var playerPosition:Vector3;
var playerVelocity:Vector3;
var playerDir:Vector3;
var isPlayerGrounded:Bool = true;

var camera:Camera3DImpl;
var mouseSensitivity:Vector2;
var lookRotation:Vector2;
var headTiltTimer:Float = 0;
var headLerp:Float;
var walkLerp = 0.;
var lean:Vector2;

function updatePlayer(rot:Float, side:Int, forward:Int, jump:Bool) {
    var input = new Vector2(side, -forward);
    if(side != 0 && forward != 0) input = Vector2Normalize(input);

    var dt = Raylib.GetFrameTime();
    
    if(!isPlayerGrounded) playerVelocity.y = playerVelocity.y - gravity * dt;

    if(isPlayerGrounded && jump) {
        playerVelocity.y = jumpForce;
        isPlayerGrounded = false;
    }

    // TODO: Understand how it works
    var front = new Vector3(Math.sin(rot), 0, Math.cos(rot));
    var right = new Vector3(Math.cos(-rot), 0, Math.sin(-rot)); 

    var desiredDir = new Vector3(input.x * right.x + input.y * front.x, 0.0, input.x * right.z + input.y * front.z);
    playerDir = Vector3Lerp(playerDir, desiredDir, control * dt);
    
    var decel = isPlayerGrounded ? friction : airDrag;
    var hvel = new Vector3(playerVelocity.x * decel, 0, playerVelocity.z * decel);

    var hvelLength = Vector3Length(hvel);
    if(hvelLength < (maxSpeed * 0.01)) hvel = new Vector3(0, 0, 0);

    // strafing
    var speed = Vector3DotProduct(hvel, playerDir);

    var maxSpeed = maxSpeed;
    var acceleration = Clamp(maxSpeed - speed, 0., maxAcceleration * dt);
    hvel.x = hvel.x + playerDir.x * acceleration;
    hvel.z = hvel.z + playerDir.z * acceleration;

    playerVelocity.x = hvel.x;
    playerVelocity.z = hvel.z;

    playerPosition.x = playerPosition.x + playerVelocity.x * dt;
    playerPosition.y = playerPosition.y + playerVelocity.y * dt;
    playerPosition.z = playerPosition.z + playerVelocity.z * dt;

    if(playerPosition.y <= 0) {
        playerPosition.y = 0;
        playerPosition.y = 0;
        isPlayerGrounded = true;
    }
}

function updateCamera() {
    var up = new Vector3(0, 1, 0);
    var targetOffset = new Vector3(0, 0, -1);

    var yaw = Vector3RotateByAxisAngle(targetOffset, up, lookRotation.x);

    // clamp up
    var maxAngleUp = Vector3Angle(up, yaw);
    maxAngleUp -= 0.001; // apparently this is to avoid numerical errors
    if(-lookRotation.y > maxAngleUp) lookRotation.y = -maxAngleUp;

    // clamp down
    var maxAngleDown = Vector3Angle(Vector3Negate(up), yaw);
    maxAngleDown *= -1;
    maxAngleDown += 0.001;
    if(-lookRotation.y < maxAngleDown) lookRotation.y = -maxAngleDown;

    var right = Vector3Normalize(Vector3CrossProduct(yaw, up));
    
    var pitchAngle = -lookRotation.y - lean.y;
    pitchAngle =  Clamp(pitchAngle, -3.14159/2 + 0.0001, 3.14159/2 - 0.0001);
    var pitch = Vector3RotateByAxisAngle(yaw, right, pitchAngle);

    var headSin = Math.sin(headTiltTimer * 3.14159);
    var headCos = Math.cos(headTiltTimer * 3.14159);
    var stepRotation = 0.01;
    camera.up = Vector3RotateByAxisAngle(up, pitch, headSin*stepRotation + lean.x);

    var bobSide = 0.01;
    var bobUp = 0.01;
    var bobbing = Vector3Scale(right, headSin * bobSide);
    bobbing.y = Math.abs(headCos*bobUp);

    camera.position = Vector3Add(camera.position, Vector3Scale(bobbing, walkLerp));
    camera.target = Vector3Add(camera.position, pitch);
}

function main() {
    Raylib.InitWindow(1024, 768, "horse");
    Raylib.SetTargetFPS(60);

    mouseSensitivity = new Vector2(0.003, 0.003);

    playerPosition = new Vector3(0, 0, 0);
    playerVelocity = new Vector3(0, 0, 0);
    playerDir = new Vector3(0, 0, 0);

    camera = new Camera3D();
    camera.position = new Vector3(playerPosition.x, playerPosition.y + height, playerPosition.z);
    camera.target = new Vector3(0, 1, 1);
    camera.up = new Vector3(0, 1, 0);
    camera.fovy = 60;
    camera.projection = CAMERA_PERSPECTIVE;

    lookRotation = new Vector2(0, 0);
    lean = new Vector2(0,0);
    headLerp = height;

    var map = Raylib.LoadImage("content/TestMap.png");
    var mesh = Raylib.GenMeshCubicmap(map, new Vector3(5, 5, 5));
    var model =  Raylib.LoadModelFromMesh(mesh);
    Raylib.UnloadImage(map);

    var texture = Raylib.LoadTexture("content/CubeAtlas.png");
    untyped __cpp__("model.materials[0].maps[MATERIAL_MAP_ALBEDO].texture = texture");

    updateCamera();

    Raylib.SetExitKey(0);
    Raylib.DisableCursor();

    while(!Raylib.WindowShouldClose()) {
        var mdt = Raylib.GetMouseDelta();
        lookRotation.x = lookRotation.x - mdt.x * mouseSensitivity.x;
        lookRotation.y = lookRotation.y + mdt.y * mouseSensitivity.y;

        var sideways = 0;
        if(Raylib.IsKeyDown(KEY_D)) sideways =  1;
        else if(Raylib.IsKeyDown(KEY_A)) sideways = -1;
        else if(Raylib.IsKeyDown(KEY_D) && Raylib.IsKeyDown(KEY_A)) sideways = 0;

        var forward = 0;
        if(Raylib.IsKeyDown(KEY_W)) forward =  1;
        else if(Raylib.IsKeyDown(KEY_S)) forward = -1;
        else if(Raylib.IsKeyDown(KEY_W) && Raylib.IsKeyDown(KEY_S)) forward = 0;

        // TODO: Deadzones
        if(false && Raylib.IsGamepadAvailable(0)) {
            lookRotation.x = lookRotation.x - (Raylib.GetGamepadAxisMovement(0, GAMEPAD_AXIS_RIGHT_X)*10) * mouseSensitivity.x;
            lookRotation.y = lookRotation.y + (Raylib.GetGamepadAxisMovement(0, GAMEPAD_AXIS_RIGHT_Y)*10) * mouseSensitivity.y;

            if(Raylib.GetGamepadAxisMovement(0, GAMEPAD_AXIS_LEFT_X) >= 0.25) sideways = 1;
            else if(Raylib.GetGamepadAxisMovement(0, GAMEPAD_AXIS_LEFT_X) <= -0.25) sideways = -1;
            
            if(Raylib.GetGamepadAxisMovement(0, GAMEPAD_AXIS_LEFT_Y) >= 0.25) forward = -1;
            else if(Raylib.GetGamepadAxisMovement(0, GAMEPAD_AXIS_LEFT_Y) <= -0.25) forward = 1;
        }

        updatePlayer(lookRotation.x, sideways, forward, Raylib.IsKeyPressed(KEY_SPACE));

        var dt=Raylib.GetFrameTime();
        headLerp = Lerp(headLerp, height, 20.0 * dt);
        camera.position = new Vector3(playerPosition.x, playerPosition.y + headLerp, playerPosition.z);

        if(isPlayerGrounded && (forward != 0 || sideways != 0)) {
            headTiltTimer += dt * 3;
            walkLerp = Lerp(walkLerp, 1, 10 * dt);
            camera.fovy = Lerp(camera.fovy, 55, 5 * dt);
        } else {
            walkLerp = Lerp(walkLerp, 0, 10 * dt);
            camera.fovy = Lerp(camera.fovy, 60, 5 * dt);
        }

        lean.x = Lerp(lean.x, sideways * 0.001, 10 * dt);
        lean.y = Lerp(lean.y , forward * 0.001, 10 * dt);

        updateCamera();

        Raylib.BeginDrawing();
        {
            Raylib.ClearBackground(Raylib.BLACK);

            Raylib.BeginMode3D(camera);
            Raylib.DrawPlane(new Vector3(0, 0, 0),  new Vector2(5, 5), Raylib.WHITE);
            Raylib.DrawCube(new Vector3(10, 10, 0), 5, 20, 5, Raylib.RED); 
            Raylib.DrawModel(model, new Vector3(0, 0, 0), 1, Raylib.WHITE);
            Raylib.EndMode3D();
        
            Raylib.DrawFPS(0,0);
        }
        Raylib.EndDrawing(); 
    }

    Raylib.UnloadModel(model);
    Raylib.UnloadTexture(texture);
    Raylib.CloseWindow();
}
