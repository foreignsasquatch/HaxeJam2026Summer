import raylib.Types;
import raylib.Raylib;
import jam.GameState;
import jam.App;

class Game implements GameState {
    var player:Player;
    var camera:FPSCamera;

    var texture:Texture;
    var model:ModelImpl;

    public function new() {
        Raylib.DisableCursor();

        player = new Player();
        camera = new FPSCamera();

        Input.mouseSensitivity = new Vector2(0.003, 0.003);
        Input.lookRotation = new Vector2(0, 0);

        var map = Raylib.LoadImage("content/TestMap.png");
        var mesh = Raylib.GenMeshCubicmap(map, new Vector3(5, 5, 5));
        model =  Raylib.LoadModelFromMesh(mesh);
        Raylib.UnloadImage(map);

        texture = Raylib.LoadTexture("content/CubeAtlas.png");
        untyped __cpp__("model.materials[0].maps[MATERIAL_MAP_ALBEDO].texture = texture"); 
    }

    public function update(dt:Float) {
        var look = Input.getLookRotation();
        var forward = Input.getForwardDirection();
        var strafe = Input.getStrafeDirection();

        player.update(look.x, strafe, forward, Input.getJump(), dt);
        camera.update(player.isGrounded, player.position, player.height, look, forward, strafe, dt);
    }

    public function draw() {
        camera.begin();
        Raylib.DrawPlane(new Vector3(0, 0, 0),  new Vector2(5, 5), Raylib.WHITE);
        Raylib.DrawCube(new Vector3(10, 10, 0), 5, 20, 5, Raylib.RED); 
        Raylib.DrawModel(model, new Vector3(0, 0, 0), 1, Raylib.WHITE); 
        camera.end(); 

        Raylib.DrawFPS(0, 0);
    }

    public function unload() {
        Raylib.UnloadModel(model);
        Raylib.UnloadTexture(texture);
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
