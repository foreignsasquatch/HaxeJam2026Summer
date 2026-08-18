import imgui.ImGui;
import raylib.Types;
import raylib.Raylib;
import jam.GameState;
import jam.App;

class Game implements GameState {
    var player:Player;
    var camera:FPSCamera;
    
    var testLevel:Level;

    var paused = false;

    public function new() {
        Raylib.DisableCursor();
        RlImGui.rlImGuiSetup(true);

        testLevel = new Level("content/TestLevel.ase", "content/Tileset.ase", 2);

        player = new Player();
        player.position = testLevel.playerPosition;
        camera = new FPSCamera();

        InputHandler.mouseSensitivity = new Vector2(0.003, 0.003);
        InputHandler.lookRotation = new Vector2(0, 0);
    }

    public function update(dt:Float) {
        if(Raylib.IsKeyPressed(KEY_F5)) paused = !paused;
        if(paused && Raylib.IsCursorHidden()) Raylib.EnableCursor();

        if(paused) return;

        if(!Raylib.IsCursorHidden()) {
            Raylib.DisableCursor();
        }

        var look = InputHandler.getLookRotation();
        var forward = InputHandler.getForwardDirection();
        var strafe = InputHandler.getStrafeDirection();

        var oldPos = player.position;

        var groundExists = testLevel.isGround(Std.int(player.position.x), Std.int(player.position.z));
        player.update(groundExists, look.x, strafe, forward, InputHandler.getJump(), dt);
        camera.update(player.isGrounded, player.position, player.height, look, forward, strafe, dt);

        if(testLevel.isWall(Std.int(player.position.x+0.5), Std.int(player.position.z+0.5))) {
            player.position.x = oldPos.x;
            player.position.z = oldPos.z;
        }
    }

    public function draw() {
        camera.begin();
        testLevel.draw();
        camera.end(); 
       
        if(!paused) return;

        RlImGui.rlImGuiBegin();
        ImGui.begin("stuff");
        {
        }
        ImGui.end();
        RlImGui.rlImGuiEnd();
    }

    public function unload() {
        testLevel.unload();
        RlImGui.rlImGuiShutdown();
    }

    public static function main() {
        var width = 1024;
        var height = 768;
#if emscripten
        width = 800;
        height = 600;
#end
        App.run(width, height, "horse", Game);
    }
}
