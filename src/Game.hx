import entity.Dice;
import entity.Player;
import entity.Slime;
import jam.Assets;
import entity.Bullet;
import jam.EntityFactory;
import raylib.Types;
import raylib.Raylib;
import jam.GameState;
import jam.App;
import raylib.Raymath.*;

// TODO: Dialogue box with options
class Game implements GameState {
    var factory:EntityFactory;
    public static var entities:Array<jam.Entity> = [];

    var player:entity.Player;
    var camera:FPSCamera;    
    var currentLevel:Level;

    var paused = false;

    public function new() {
        Raylib.DisableCursor();

        currentLevel = new Level("content/level1/data.json", "content/level1/Tileset.ase", new Vector3(3,4,3));
        factory = new EntityFactory();
        factory.registerEntityType("slime", Slime.new);
        loadEntities();

        A.load();

        camera = new FPSCamera();

        InputHandler.mouseSensitivity = new Vector2(0.003, 0.003);
        InputHandler.lookRotation = new Vector2(0, 0);
    }

    public function update(dt:Float) {
        if(!Raylib.IsCursorHidden()) {
            Raylib.HideCursor();
        }

        if(paused) return;

        var look = InputHandler.getLookRotation();
        var forward = InputHandler.getForwardDirection();
        var strafe = InputHandler.getStrafeDirection();

        for(b in Bullet.playerBullets) {
            b.update(dt);
            if(currentLevel.isWall(Std.int(b.x), Std.int(b.z))) Bullet.playerBullets.remove(b);
        }
        for(b in Bullet.enemyBullets) {
            b.update(dt);
            if(currentLevel.isWall(Std.int(b.x), Std.int(b.z))) Bullet.enemyBullets.remove(b);
        }

        var oldPos = player.position;

        player.update(true, look, strafe, forward, InputHandler.getJump(), dt);
        camera.update(player.isGrounded, player.position, player.height, look, forward, strafe, dt);

        if(currentLevel.isWall(Std.int(player.position.x+0.5), Std.int(player.position.z+0.5))) {
            player.position.x = oldPos.x;
            player.position.z = oldPos.z;
        }

        for(e in entities) e.update(dt);
    }

    public static function drawExplosion(x:Float, y:Float, z:Float, intensity:Float, color:Color) {
    }

    public function draw() {
        camera.begin();
        currentLevel.draw(camera.camera);
        player.draw();
        for(b in Bullet.playerBullets) {
            var t = 2;
            var p = Vector3Add(new Vector3(player.position.x, player.position.y + player.height - 0.5, player.position.z), Vector3Scale(camera.getForward(), t));
            if(Vector3Distance(new Vector3(b.x, b.y, b.z), p) > 5) b.draw(camera.camera);
        }
        for(b in Bullet.enemyBullets) b.draw(camera.camera);
        for(e in entities) e.draw(camera.camera);
        camera.end(); 

        player.drawUI(); 
//        gamble();
//        Raylib.DrawFPS(0,0);
    }

    /*
        Player speed increase/decrease
        Player bullet fire rate
        Player fire 1-10 bullets
        Player more damage resistance
        Bigger enemies
        Faster enemies
    
        The player buys a dice instead of milk because thats all the money they had
        dice roll determines outcome
     */
    var gambleLevel = 1;
    var oldMoney = Player.money;
    public static var isGamble = false;
    var dice:Dice;
    function gamble() {
        if((Player.money-oldMoney) >= 100 * gambleLevel) {
            isGamble = true;

            // spawn dice
            if(Raylib.IsKeyPressed(KEY_G)) {
                var p = Vector3Add(player.position, Vector3Scale(camera.getForward(), 3)); 
                var x = p.x;
                var z = p.z;
                dice =  (new Dice({x: Std.int(x), y: Std.int(z), id: "dice"}));
                entities.push(dice);
            }
        }

        if(paused) {
        }
       
        // TODO: Fix gamble meter
        if(!paused) Raylib.DrawRectangle(Std.int((Std.int(Raylib.GetScreenWidth()/2) - 200)), 20, Std.int(400 * ((Player.money-oldMoney)/(100*gambleLevel))), 20, new Color(255, 209, 0, 255));
    }

    public function unload() {
        player.unload();
        unloadEntities();
        currentLevel.unload();
        A.unload();
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
        width = 800;
        height = 600;
        App.run(width, height, "Oops, I Forgot the Milk.", Game);
    }
}
