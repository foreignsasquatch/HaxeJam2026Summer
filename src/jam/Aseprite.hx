package jam;

import cpp.RawPointer;
import raylib.Types;
import raylib.Raylib;
import ase.Ase;
import sys.io.File;

typedef AsepriteLayer = {
    texture:Texture,
    layerID:Int,
    frameID:Int
}

@:structInit
class Tag {
  public var name(default, null):String;
  public var startFrame(default, null):Int;
  public var endFrame(default, null):Int;
  public var animationDirection(default, null):Int;

  public static function fromChunk(chunk:ase.chunks.TagsChunk.Tag):Tag {
    return {
      name: chunk.tagName,
      startFrame: chunk.fromFrame,
      endFrame: chunk.toFrame,
      animationDirection: chunk.animDirection
    }
  }
}

class Aseprite {
    public var ase:Ase;
    public var width:Int;
    public var height:Int;

    public var intermediateLayers:Array<AsepriteLayer> = [];
    public var intermediateFrames:Map<Int, Texture> = [];
    public var spritesheet:Texture;

    public var tags:Map<String, Tag> = [];
    public var duration:Map<Int, Float> = [];

    public function new(file:String) {
        ase = Ase.fromBytes(File.getBytes(file));
        width = ase.width;
        height = ase.width;

        for(frame in 0...ase.frames.length) {
            var aseFrame = ase.frames[frame];
            for(layer in 0...ase.layers.length) {
                intermediateLayers.push({
                    texture: genTexture(layer, aseFrame),
                    layerID: layer,
                    frameID: frame
                });
            }
        }

        for(frame in 0...ase.frames.length) {
            var renderTarget = Raylib.LoadRenderTexture(ase.width, ase.height);

            for(layer in intermediateLayers) {
                if(layer.frameID == frame) {
                    var sourceRec = new Rectangle(0, 0, ase.frames[frame].cel(layer.layerID).width, ase.frames[frame].cel(layer.layerID).height);
                
                    Raylib.BeginTextureMode(renderTarget);
                    Raylib.DrawTexturePro(layer.texture, sourceRec, new Rectangle(ase.frames[frame].cel(layer.layerID).xPosition, ase.frames[frame].cel(layer.layerID).yPosition, ase.frames[frame].cel(layer.layerID).width, ase.frames[frame].cel(layer.layerID).height), new Vector2(0,0), 0, Raylib.WHITE);
                    Raylib.EndTextureMode();
                }

                var image = Raylib.LoadImageFromTexture(renderTarget.texture);
                Raylib.ImageFlipVertical(RawPointer.addressOf(image));
                var texture = Raylib.LoadTextureFromImage(image);
                intermediateFrames.set(frame, texture);
                Raylib.UnloadRenderTexture(renderTarget);
            }
        }

        var spritesheetTexture = Raylib.LoadRenderTexture(ase.width * ase.frames.length, ase.height);
        var index = 0;
        for(frame in 0...ase.frames.length) {
            var f = intermediateFrames[frame];

            Raylib.BeginTextureMode(spritesheetTexture);
            Raylib.DrawTexture(f, 0 + (f.width * index), 0, Raylib.WHITE);
            Raylib.EndTextureMode();
            index++;
        }

        var image = Raylib.LoadImageFromTexture(spritesheetTexture.texture);
        Raylib.ImageFlipVertical(RawPointer.addressOf(image));
        spritesheet = Raylib.LoadTextureFromImage(image);
        Raylib.UnloadRenderTexture(spritesheetTexture);

        for(i in intermediateFrames) {
            Raylib.UnloadTexture(i);
        }
        intermediateFrames.clear();

        for(i in intermediateLayers) {
            Raylib.UnloadTexture(i.texture);
            intermediateLayers.remove(i);
        }

        for(frame in ase.frames) {
            for(chunk in frame.chunks) {
                switch (chunk.header.type) {
                    case TAGS:
                        var frameTags:ase.chunks.TagsChunk = cast chunk;

                        for(frameTagData in frameTags.tags) {
                            var animationTag = Tag.fromChunk(frameTagData);

                            if(tags.exists(frameTagData.tagName)) {
                                throw 'ERROR: This file already contains a tag named ${frameTagData.tagName}';
                            } else  {
                                tags[frameTagData.tagName] = animationTag;
                            }
                        }
                    case _:
                }
            }

            duration[ase.frames.indexOf(frame)] = frame.duration;
        }
    }

    public function genTexture(layer:Int, frame:ase.Frame):Texture {
        var layerIndex:Int = layer;
        if(frame.cel(layer) != null) {
        var celWidth:Int = frame.cel(layer).width;
        var celHeight:Int = frame.cel(layer).height;
        var celPixelData:haxe.io.Bytes = frame.cel(layerIndex).pixelData;
        var celDataPointer:cpp.Pointer<cpp.Void> = cpp.NativeArray.address(celPixelData.getData(), 0).reinterpret();
        var celImage = new Image();
        celImage.data = celDataPointer.raw;
        celImage.width = celWidth; 
        celImage.height = celHeight;
        celImage.mipmaps = 1;
        celImage.format = PixelFormat.PIXELFORMAT_UNCOMPRESSED_R8G8B8A8;
        return Raylib.LoadTextureFromImage(celImage);
        }
        return null;
    }

    public function unload() {
        Raylib.UnloadTexture(spritesheet);
    }
}
