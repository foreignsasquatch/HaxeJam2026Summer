import jam.Aseprite;
import raylib.Types;
import raylib.Raylib;

class Level {
    public var height1:ModelImpl;
    public var height2:ModelImpl;
    public var height3:ModelImpl;

    public var solids:Array<Array<Int>> = [];
    public var ground:Array<Array<Int>> = [];
    public var multiplyFactor = 3;

    public var playerPosition:Vector3;

    var texture:Aseprite;

    var a:Aseprite;

    public function new(file:String, tex:String, m:Int) {    
        a = new Aseprite(file);
        multiplyFactor = m;
 
        // generate cubic map
        var t1 = a.genTexture(0, a.ase.frames[0]); 
        var img = Raylib.LoadImageFromTexture(t1);
        var mesh = Raylib.GenMeshCubicmap(img, new Vector3(multiplyFactor, multiplyFactor+4, multiplyFactor));
        height1 = Raylib.LoadModelFromMesh(mesh); 
        Raylib.UnloadImage(img);
        Raylib.UnloadTexture(t1);

        // set texture of cubic map
        texture = new Aseprite(tex);
        untyped __cpp__("height1.materials[0].maps[MATERIAL_MAP_ALBEDO].texture = {0}", texture.spritesheet); 

        // generate solids
        var t = a.genTexture(0, a.ase.frames[0]);
        var img = Raylib.LoadImageFromTexture(t);
        for(i in 0...img.width) {
            for(j in 0...img.height) {
                var c = Raylib.GetImageColor(img, i, j);
                if(c.r == 255 && c.g == 255 && c.b == 255) solids.push([i, j]); 
                if(c.a == 0) ground.push([i, j]);
            }
        }
        Raylib.UnloadImage(img);
        Raylib.UnloadTexture(t);

        // entities
        var t = a.genTexture(1, a.ase.frames[0]);
        var img = Raylib.LoadImageFromTexture(t);
        for(i in 0...img.width) {
            for(j in 0...img.height) {
                var c = Raylib.GetImageColor(img, i, j);
                if(c.r == 0 && c.g == 0 && c.b == 255) {
                    playerPosition = new Vector3(i*multiplyFactor, 0, j*multiplyFactor);
                }
            }
        }
        Raylib.UnloadImage(img);
        Raylib.UnloadTexture(t);
        a.unload();
    }

    public function isWall(x:Int, y:Int):Bool {
        for(i in solids) {
            var tx = i[0]*multiplyFactor;
            var ty = i[1]*multiplyFactor;
            if(Raylib.CheckCollisionRecs(new Rectangle(x, y, multiplyFactor, multiplyFactor), new Rectangle(tx, ty , multiplyFactor, multiplyFactor))) return true;
        }
        return false;
    }

    public function isGround(x:Int, y:Int):Bool {
        for(i in ground) {
            var tx = i[0]*multiplyFactor;
            var ty = i[1]*multiplyFactor;
            if(Raylib.CheckCollisionRecs(new Rectangle(x, y, multiplyFactor, multiplyFactor), new Rectangle(tx, ty , multiplyFactor, multiplyFactor))) return false;
        }
        return true;
    }

    public function draw() {
        Raylib.DrawModel(height1, new Vector3(0, 0, 0), 1, Raylib.WHITE);
    }

    public function unload() {
        Raylib.UnloadModel(height1);
        a.unload();
        texture.unload();
    }
}
