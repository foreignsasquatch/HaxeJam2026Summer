import raylib.Raylib;
import raylib.Types;

class A {
    public static var bullet:Texture;
    public static var particle:Texture;
    public static var font:Font;

    public static function load() {
        bullet = Raylib.LoadTexture("content/bullet.png");
        particle = Raylib.LoadTexture("content/particle.png");
        font = Raylib.LoadFont("content/dungeon-mode.ttf");
    }

    public static function unload() {
        Raylib.UnloadTexture(bullet);
        Raylib.UnloadTexture(particle);
        Raylib.UnloadFont(font);
    }
}
