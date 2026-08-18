import imgui.IntPointer;
import imgui.FloatPointer;
import imgui.ImGui;
import cpp.RawConstPointer;
import raylib.Types;
import raylib.Raylib;
import raylib.RLights;
import jam.GameState;
import jam.App;

class Game implements GameState {
    var player:Player;
    var camera:FPSCamera;
    
    var testLevel:Level;

    var shader:Shader;
#if emscripten
    var shaderPath = "content/glsl100/";
#else
    var shaderPath = "content/glsl330/";
#end
    var ambient:Vector4;
    var ambientLoc:Int;
    var fogColor:Vector4;
    var fogColorLoc:Int;
    var fogDensity:Single;
    var fogDensityLoc:Int;
    var light:cpp.Struct<Light>;
    var lights:Array<cpp.Struct<Light>> = [];

    var paused = false;

    public function new() {
        Raylib.DisableCursor();
        RlImGui.rlImGuiSetup(true);

        testLevel = new Level("content/TestLevel.ase", "content/Tileset.ase", 2);

        player = new Player();
        player.position = testLevel.playerPosition;
        camera = new FPSCamera();

        InputHandler.mouseSensitivity = new Vector2(0.003, 0.003);
        InputHandler.lookRotation = new Vector2(0, 0);
    
        shader = Raylib.LoadShader(shaderPath+"lighting.vs", shaderPath+"fog.fs");
        shader.locs.set(SHADER_LOC_MATRIX_MODEL, Raylib.GetShaderLocation(shader, "matModel"));
        shader.locs.set(SHADER_LOC_VECTOR_VIEW, Raylib.GetShaderLocation(shader, "viewPos"));
    
        ambient = new Vector4(0.2, 0.2, 0.2, 1);
        ambientLoc =  Raylib.GetShaderLocation(shader, "ambient");
        Raylib.SetShaderValue(shader, ambientLoc, cast RawConstPointer.addressOf(ambient), SHADER_UNIFORM_VEC4);

        fogColor = Raylib.ColorNormalize(Raylib.BLUE);
        fogColorLoc = Raylib.GetShaderLocation(shader, "fogColor");
        Raylib.SetShaderValue(shader, fogColorLoc, cast RawConstPointer.addressOf(fogColor), SHADER_UNIFORM_VEC4);

        fogDensity = 0.01;
        fogDensityLoc =  Raylib.GetShaderLocation(shader, "fogDensity");
        Raylib.SetShaderValue(shader, fogDensityLoc, cast RawConstPointer.addressOf(fogDensity), SHADER_UNIFORM_FLOAT);

        untyped __cpp__("{0}.materials[0].shader = shader", testLevel.height1);
        
        light = RLights.CreateLight(1, new Vector3(6*4, 2, 2*4), new Vector3(0, 0, 0), new Color(100,100,100,255), shader);
    }

    public function update(dt:Float) {
        if(Raylib.IsKeyPressed(KEY_F5)) paused = !paused;
        if(paused && Raylib.IsCursorHidden()) Raylib.EnableCursor();

        Raylib.SetShaderValue(shader, fogColorLoc, cast RawConstPointer.addressOf(fogColor), SHADER_UNIFORM_VEC4);
        Raylib.SetShaderValue(shader, fogDensityLoc, cast RawConstPointer.addressOf(fogDensity), SHADER_UNIFORM_FLOAT);
        Raylib.SetShaderValue(shader, ambientLoc, cast RawConstPointer.addressOf(ambient), SHADER_UNIFORM_VEC4); 
        RLights.UpdateLightValues(shader, light);
    
        if(paused) return;

        if(!Raylib.IsCursorHidden()) {
            Raylib.DisableCursor();
        }

        var look = InputHandler.getLookRotation();
        var forward = InputHandler.getForwardDirection();
        var strafe = InputHandler.getStrafeDirection();

        var oldPos = player.position;

        var groundExists = testLevel.isGround(Std.int(player.position.x), Std.int(player.position.z));
        player.update(groundExists, look.x, strafe, forward, InputHandler.getJump(), dt);
        camera.update(player.isGrounded, player.position, player.height, look, forward, strafe, dt);

        if(testLevel.isWall(Std.int(player.position.x+0.5), Std.int(player.position.z+0.5))) {
            player.position.x = oldPos.x;
            player.position.z = oldPos.z;
        }

        Raylib.SetShaderValue(shader, shader.locs.get(SHADER_LOC_VECTOR_VIEW), cast RawConstPointer.addressOf(camera.camera.position.x), SHADER_UNIFORM_VEC3);    
    }

    public function draw() {
        camera.begin();
        testLevel.draw();
        Raylib.DrawCube(new Vector3(24, 2, 8), 1, 1, 1, Raylib.WHITE);
        camera.end(); 
       
        if(!paused) return;

        RlImGui.rlImGuiBegin();
        ImGui.begin("stuff");
        {
            ImGui.sliderFloat4("ambient", cast ambient.toPointer(), 0, 1);
            ImGui.sliderFloat4("fogColor", cast fogColor.toPointer(), 0, 1);
            ImGui.sliderFloat("fogDensity", FloatPointer.fromFloat(fogDensity), 0, 1);  
        }
        ImGui.end();
        RlImGui.rlImGuiEnd();
    }

    public function unload() {
        testLevel.unload();
        Raylib.UnloadShader(shader);
        RlImGui.rlImGuiShutdown();
    }

    public static function main() {
        var width = 1024;
        var height = 768;
#if emscripten
        width = 800;
        height = 600;
#end
        App.run(width, height, "horse", Game);
    }
}
