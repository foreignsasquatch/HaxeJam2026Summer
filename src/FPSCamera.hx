import raylib.Raymath.*;
import raylib.Types;
import raylib.Raylib;

class FPSCamera {
    public var camera:Camera3DImpl;
  
    var headTiltTimer:Float = 0;
    var headLerp:Float;
    var walkLerp = 0.;
    var lean:Vector2;

    public function new() {
        camera = new Camera3D();
        camera.position = new Vector3(0, 0, 0);
        camera.target = new Vector3(0, 0, 0);
        camera.up = new Vector3(0, 1, 0);
        camera.fovy = 60;
        camera.projection = CAMERA_PERSPECTIVE;

        lean = new Vector2(0,0);
    }

    public function update(isPlayerGrounded:Bool, playerPosition:Vector3, playerHeight:Float, lookRotation:Vector2, forward:Int, sideways:Int, dt:Float) {
        var dt=Raylib.GetFrameTime();
        headLerp = Lerp(headLerp, playerHeight, 20.0 * dt);
        camera.position = new Vector3(playerPosition.x, playerPosition.y + headLerp, playerPosition.z);

        if(isPlayerGrounded && (forward != 0 || sideways != 0)) {
            headTiltTimer += dt * 3;
            walkLerp = Lerp(walkLerp, 1, 10 * dt);
            camera.fovy = Lerp(camera.fovy, 55, 5 * dt);
        } else {
            walkLerp = Lerp(walkLerp, 0, 10 * dt);
            camera.fovy = Lerp(camera.fovy, 55, 5 * dt);
        }

        lean.x = Lerp(lean.x, sideways * 0.001, 10 * dt);
        lean.y = Lerp(lean.y , forward * 0.001, 10 * dt);

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

        var bobSide = 0.1;
        var bobUp = 0.1;
        var bobbing = Vector3Scale(right, headSin * bobSide);
        bobbing.y = Math.abs(headCos*bobUp);

        camera.position = Vector3Add(camera.position, Vector3Scale(bobbing, walkLerp));
        camera.target = Vector3Add(camera.position, pitch);
    }

    public function begin() {
        Raylib.BeginMode3D(camera);
    }

    public function end() {
        Raylib.EndMode3D();
    }

    public function getForward():Vector3 {
        return Vector3Normalize(Vector3Subtract(camera.target, camera.position));
    }
}
