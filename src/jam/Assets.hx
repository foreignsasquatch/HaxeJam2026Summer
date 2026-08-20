package jam;

import haxe.Timer;
import sys.FileSystem;
import haxe.DynamicAccess;
import haxe.Json;
import sys.io.File;

class Assets {
    public static var ase:Map<String, Aseprite> = [];
    public static var entities:DynamicAccess<DynamicAccess<Dynamic>>;
    
    public static function load() {
        var start = Timer.stamp();
        loadFolder('content');

        entities = Json.parse(File.getContent("content/entities.json"));
        var totalLoadTime = Std.string(Timer.stamp() - start);
        totalLoadTime = totalLoadTime.substring(0, 4);
        trace('All assets have been loaded in ${totalLoadTime}s');
    }

    public static function loadFolder(folder:String) {
        var things = FileSystem.readDirectory(folder);
        for(i in things) {
            if(FileSystem.isDirectory(folder+'/'+i)) {
                loadFolder(folder+"/"+i); 
            }
            if(raylib.Raylib.IsFileExtension(i, ".ase")) loadImage(folder+"/"+i);
        }
    }

    public static function loadImage(file:String) {
        if(!FileSystem.exists(file)) trace('Asset $file does not exist.');
        else {
            ase.set(file, new Aseprite(file));
            trace('Loaded $file');
        }
    }

    public static function unload() {
        for(a in ase) a.unload();
        trace("All assets have been unloaded.");
    }
}
