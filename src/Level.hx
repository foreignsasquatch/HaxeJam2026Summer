import haxe.ds.Vector;
import jam.Aseprite;
import raylib.Types;
import raylib.Raylib;
import jam.Serializables;

class Level {
    public var data:LevelData;

    public var width:Int;
    public var height:Int;

    public var solidSpritesheet:Aseprite;
    public var decorationsSpritesheet:Aseprite;

    public var size:Vector3;

    var tileset:String;
    var grid:Array<Array<Int>> = [];
    var defModels:Vector<ModelImpl>;
    var models:Vector<{x:Int, y:Int, i:Int, m:ModelImpl}>;

    var tilesetMap:Map<String, Map<Int, Rectangle>> = [];

    public function new(file:String, tileset:String, size:Vector3) {
        this.size = size; 
        data = haxe.Json.parse(sys.io.File.getContent(file));

        solidSpritesheet = new Aseprite(tileset);
        decorationsSpritesheet = new Aseprite(data.rooms[0].tileset);

        defModels = new Vector(data.rooms.length);
        models = new Vector(64);

        for(r in 0...data.rooms.length) {
            var room = data.rooms[r];
            defModels[r] = genRoomModel(room);

            if(!tilesetMap.exists(room.tileset)) {
                var i = 1;
                var w = Std.int(decorationsSpritesheet.width / 16);
                var h = Std.int(decorationsSpritesheet.height / 16);
                var map:Map<Int, Rectangle> = [];
                for(c in 0...w) {
                    for(r in 0...h) {
                        var rec = new Rectangle(r * 16, c * 16, 16, 16);
                        map.set(i, rec);
                        i++;
                    }
                }
                tilesetMap.set(room.tileset, map);
            } 
            models.set(r, {x: room.x, y: room.y, i: r, m: defModels[r]});
        }
    }

    function genRoomModel(room:RoomData) {
        var img = Raylib.GenImageColor(room.width, room.height, Raylib.BLACK);
        for(i in 0...room.width) {
            for(j in 0...room.height) {
                if(room.solids[(i * room.width) + j] != 0) Raylib.ImageDrawPixel(cpp.RawPointer.addressOf(img), i, j, Raylib.WHITE);
            }
        }

        var mesh = Raylib.GenMeshCubicmap(img, this.size);
        var model = Raylib.LoadModelFromMesh(mesh);
        Raylib.UnloadImage(img);

        untyped __cpp__("{0}.materials[0].maps[MATERIAL_MAP_ALBEDO].texture = {1}", model, solidSpritesheet.spritesheet);
        return model;
    }

    public function isWall(x:Int, y:Int):Bool {
        for(m in models) {
            if(m == null) continue;
            var r = data.rooms[m.i];
            if(r == null) continue;
            for(i in 0...r.width) {
                for(j in 0...r.height) {
                    if(r.solids[(i * r.width)+j] != 0) if(Raylib.CheckCollisionRecs(new Rectangle(x,y,size.x,size.z), new Rectangle((m.x)+(i*size.x), (m.y)+(j*size.z), size.x, size.z))) return true;
                }
            } 
        }
        return false;
    }

    public function draw(camera:Camera3DImpl) {
        for(m in models) {
            if(m == null) continue;
            Raylib.DrawModel(m.m, new Vector3(m.x, 0, m.y), 1, Raylib.WHITE);
            var d = data.rooms[m.i];
            for(i in 0...d.width) {
                for(j in 0...d.width) {
                    var t = d.foreground[(i*d.width)+j];
                    if(t != 0) {
                        Raylib.DrawBillboardPro(camera, decorationsSpritesheet.spritesheet, tilesetMap.get(d.tileset).get(t), new Vector3((m.x)+(i*size.x), 0, (m.y)+(j*size.z)), new Vector3(0,1,0),new Vector2(2,2),new Vector2(0,0), 0, Raylib.WHITE);
                    }
                }
            }
        }
    }

    public function unload() {
        for(m in defModels) Raylib.UnloadModel(m);
        solidSpritesheet.unload();
        decorationsSpritesheet.unload();
    }
}
