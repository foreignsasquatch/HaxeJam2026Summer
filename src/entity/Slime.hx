package entity;

import raylib.Raylib;
import raylib.Types;
import jam.Serializables.EntityData;

class Slime extends Enemy {
    public function new(e:EntityData) {
        super(e);
        drawdebug = true;
    }

    override function update(dt:Float) { 
        super.update(dt);
    }

    override function draw(c:Camera3D) {
        super.draw(c);
    }
}
