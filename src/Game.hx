import jam.EntityFactory;
import raylib.Types;
import raylib.Raylib;
import jam.GameState;
import jam.App;

class Game implements GameState {
    var factory:EntityFactory;
    var entities:Array<jam.Entity> = [];

    var player:entity.Player;
    var camera:FPSCamera;    
    var currentLevel:Level;

    var paused = false;

    public function new() {
        Raylib.DisableCursor();

        currentLevel = new Level("content/level1/data.json", "content/level1/Tileset.ase", new Vector3(3,4,3));
        factory = new EntityFactory();
        loadEntities();
        
        camera = new FPSCamera();

        InputHandler.mouseSensitivity = new Vector2(0.003, 0.003);
        InputHandler.lookRotation = new Vector2(0, 0);
    }

    public function update(dt:Float) {
        if(!Raylib.IsCursorHidden()) {
            Raylib.DisableCursor();
        }

        var look = InputHandler.getLookRotation();
        var forward = InputHandler.getForwardDirection();
        var strafe = InputHandler.getStrafeDirection();

        var oldPos = player.position;

        player.update(true, look.x, strafe, forward, InputHandler.getJump(), dt);
        camera.update(player.isGrounded, player.position, player.height, look, forward, strafe, dt);

        if(currentLevel.isWall(Std.int(player.position.x+0.5), Std.int(player.position.z+0.5))) {
            player.position.x = oldPos.x;
            player.position.z = oldPos.z;
        }

        for(e in entities) e.update(dt);
    }

    public function draw() {
        camera.begin();
        currentLevel.draw(camera.camera);
        for(e in entities) e.draw();
        camera.end(); 

        player.draw();
        Raylib.DrawFPS(0, 0);
    }

    public function unload() {
        player.unload();
        unloadEntities();
        currentLevel.unload();
    }

    function loadEntities() {
        for(room in currentLevel.data.rooms) {
            for(e in room.entities) {
                // the stored entity positions are not properly scaled to match the map
                e.x = Std.int(Std.int(e.x/16) * currentLevel.size.x);
                e.y = Std.int(Std.int(e.y/16) * currentLevel.size.z);

                if(e.id == "player") player = new entity.Player(e);
                else entities.push(factory.createEntity(e.id, e)); 
            }
        }
    }

    function unloadEntities() {
        for(e in entities) {
            entities.remove(e);
            e = null;
        }
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
