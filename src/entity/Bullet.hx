package entity;

import jam.Assets;
import raylib.Types;
import raylib.Raylib;

class Bullet {
    public static var playerBullets:Array<Bullet> = [];
    public static var enemyBullets:Array<Bullet> = [];

    public var x:Float;
    public var z:Float;
    public var y:Float;
    public var speed:Float = 160;
    public var direction:Vector2;

    public function new(x:Float, y:Float, z:Float, look:Vector2) {
        direction = look;
        this.x = x;
        this.z = z;
        this.y = y;
    }

    public function update(dt:Float) {
        x = x - speed * Math.sin(direction.x) * dt; 
        z = z - speed * Math.cos(direction.x) * dt;
        y = y - speed * Math.sin(direction.y) * dt;
    }

    // TODO: bullet not centered
    public function draw(camera:Camera3D) {
        Raylib.DrawBillboard(camera, A.bullet, new Vector3(x, y, z), 1, Raylib.WHITE);
    }
}
