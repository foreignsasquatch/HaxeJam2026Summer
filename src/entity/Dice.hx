package entity;

import raylib.Raylib;
import raylib.Types;
import jam.Serializables.EntityData;

class Dice extends Enemy {
    var number = 1;

    public function new(e:EntityData) {
        super(e);
        drawdebug = true;
    }

    override function update(dt:Float) {
        super.update(dt);
        if(gotHit) number = Raylib.GetRandomValue(1,6);  
    }

    override function draw(c:Camera3D) {
        Raylib.DrawBillboardRec(c, jam.Assets.ase[sprite].spritesheet, new Rectangle(number*32, 0, 32, 32),position, new Vector2(1,1), tint);
        debugDraw();
    }
}
