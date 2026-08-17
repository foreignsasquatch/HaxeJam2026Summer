import raylib.Raylib;
import raylib.Types;
import jam.Aseprite;

class Level {
    var ase:Aseprite;
    var cubicmaps:Array<Model> = [];
    var cubicmapTextures:Array<Texture> = [];

    public function new(file:String) {
        ase = new Aseprite(file);
        for(i in 0...ase.ase.layers.length) {
            var img = Raylib.LoadImageFromTexture(ase.genTexture(i, 0));
            var mesh = Raylib.GenMeshCubicmap(img, new Vector3(1,1,1));
            var model = Raylib.LoadModelFromMesh(mesh);
            Raylib.UnloadImage(img);
        }
    }

    public function draw() {
    }

    public function unload() {
        for(c in cubicmaps) Raylib.UnloadModel(c);
        ase.unload();
    }
}
