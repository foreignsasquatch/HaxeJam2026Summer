package jam;

import jam.Serializables.EntityData;

class Entity {
    public var x:Int;
    public var y:Int;
    public function new(e:EntityData) {
        x = e.x;
        y = e.y;
    }

    public function update(dt:Float) {}
    public function draw(c:raylib.Types.Camera3D) {}
}
