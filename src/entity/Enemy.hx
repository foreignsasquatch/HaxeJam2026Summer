package entity;

import raylib.Raylib;
import jam.Assets;
import jam.Serializables.EntityData;
import raylib.Types;

class Enemy extends jam.Entity {
    public var health:Int = 10;
    public var position:Vector3;
    public var sprite:String;
    public var sizeX = 1;
    public var sizeY = 1;
    public var sizeZ = 1;
    public var drawdebug = false;
    public var tint = Raylib.WHITE;
    public var gotHit=false;

    public function new(e:EntityData) {
        super(e);
        this.position = new Vector3(x, 0.5, y);
        this.sprite = Assets.entities[e.id]["sprite"];
    }

    override function update(dt:Float) {
        gotHit=false;
        for(b in Bullet.playerBullets) {
            if(Raylib.CheckCollisionRecs(new Rectangle(x, y, sizeX, sizeZ), new Rectangle(b.x, b.z, 1, 1)) && ((b.y > 0) && (b.y < sizeY))) {
                if(health!=0)health -=1;
                gotHit = true;
                Bullet.playerBullets.remove(b);
            }
        }
    }

    override function draw(camera:Camera3D) {
        Raylib.DrawBillboard(camera, Assets.ase[sprite].spritesheet, position, 1, tint);
        debugDraw();
    }

    public function debugDraw() {
        if(drawdebug) Raylib.DrawCubeWiresV(position, new Vector3(sizeX, sizeY, sizeZ), Raylib.GREEN);
    }
}
