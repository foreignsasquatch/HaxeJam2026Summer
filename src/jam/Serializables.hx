package jam;

typedef EntityData = {
    x:Int,
    y:Int,
    id:String,
}

typedef RoomData = {
    x:Int,
    y:Int,
    width:Int,
    height:Int,
    foreground:Array<Int>,
    background:Array<Int>,
    solids:Array<Int>,
    tileset:String,
    type:Int,
    entities:Array<EntityData>
};

typedef LevelData = {
    rooms:Array<RoomData>,
    gridSize:Int
};
