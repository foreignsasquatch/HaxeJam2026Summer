package jam;

import raylib.Types.TraceLogLevel;
import raylib.Raylib;

class App {
    static var gameState:GameState;

    public static function run(w:Int, h:Int, t:String, g:Class<GameState>) {
        Raylib.SetTraceLogLevel(TraceLogLevel.LOG_ERROR);
        Raylib.InitWindow(w, h, t);
        Raylib.InitAudioDevice();
        Raylib.SetTargetFPS(60);
        Raylib.SetExitKey(0); 
        
        setGameState(g);
#if emscripten
        emscripten.Emscripten.set_main_loop(cpp.Callable.fromStaticFunction(update), 60, true);
#else
    while(!Raylib.WindowShouldClose()) {
        update();
    }
#end 
        gameState.unload();
        Raylib.CloseAudioDevice();
        Raylib.CloseWindow();
    }

    public static function setGameState(g:Class<GameState>) {
        if(gameState != null) gameState.unload();
        gameState = Type.createInstance(g, []);
    }

    static function update() {
        gameState.update(Raylib.GetFrameTime());

        Raylib.BeginDrawing();
        Raylib.ClearBackground(Raylib.BLACK);
        gameState.draw();
        Raylib.EndDrawing();
    }
}
