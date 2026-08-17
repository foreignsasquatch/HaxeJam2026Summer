package jam;

interface GameState {
    public function update(dt:Float):Void;
    public function draw():Void;
    public function unload():Void;
}
