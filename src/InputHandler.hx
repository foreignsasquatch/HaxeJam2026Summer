import raylib.Raymath.*;
import raylib.Types;
import raylib.Raylib;

class InputHandler {
    public static var mouseSensitivity:Vector2;
    public static var lookRotation:Vector2;

    public static function getLookRotation():Vector2 {
        var mdt = Raylib.GetMouseDelta();
        lookRotation.x = lookRotation.x - mdt.x * mouseSensitivity.x;
        lookRotation.y = lookRotation.y + mdt.y * mouseSensitivity.y;
        return lookRotation;
    }

    public static function getStrafeDirection():Int {
        var sideways = 0;
        if(Raylib.IsKeyDown(KEY_D)) sideways =  1;
        else if(Raylib.IsKeyDown(KEY_A)) sideways = -1;
        else if(Raylib.IsKeyDown(KEY_D) && Raylib.IsKeyDown(KEY_A)) sideways = 0;
        return sideways;
    }

    public static function getForwardDirection():Int {
        var forward = 0;
        if(Raylib.IsKeyDown(KEY_W)) forward =  1;
        else if(Raylib.IsKeyDown(KEY_S)) forward = -1;
        else if(Raylib.IsKeyDown(KEY_W) && Raylib.IsKeyDown(KEY_S)) forward = 0;
        return forward;
    }

    public static function getJump():Bool {
        return Raylib.IsKeyDown(KEY_SPACE);
    }

    public static function getShoot():Bool {
        return Raylib.IsMouseButtonPressed(MOUSE_BUTTON_LEFT);
    }

    /*
        if(false && Raylib.IsGamepadAvailable(0)) {
            lookRotation.x = lookRotation.x - (Raylib.GetGamepadAxisMovement(0, GAMEPAD_AXIS_RIGHT_X)*10) * mouseSensitivity.x;
            lookRotation.y = lookRotation.y + (Raylib.GetGamepadAxisMovement(0, GAMEPAD_AXIS_RIGHT_Y)*10) * mouseSensitivity.y;

            if(Raylib.GetGamepadAxisMovement(0, GAMEPAD_AXIS_LEFT_X) >= 0.25) sideways = 1;
            else if(Raylib.GetGamepadAxisMovement(0, GAMEPAD_AXIS_LEFT_X) <= -0.25) sideways = -1;
            
            if(Raylib.GetGamepadAxisMovement(0, GAMEPAD_AXIS_LEFT_Y) >= 0.25) forward = -1;
            else if(Raylib.GetGamepadAxisMovement(0, GAMEPAD_AXIS_LEFT_Y) <= -0.25) forward = 1;
        }

    */
}
