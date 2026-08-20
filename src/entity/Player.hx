package entity;
import jam.Assets;
import jam.Serializables.EntityData;
import jam.Aseprite;
import raylib.Raymath.*;
import raylib.Types;
import raylib.Raylib;

class Player extends jam.Entity {
    var gravity = 32.;
    var jumpForce = 12.;
    
    var maxSpeed = 12.5;
    var maxAcceleration = 150.;
 
    var friction = 0.86;
    var airDrag = 0.9;

    var control = 15.;
    public var height = 1.;

    public var position:Vector3;
    public var velocity:Vector3;
    public var dir:Vector3;
    public var isGrounded:Bool = true;

    var look:Vector2;

    var hand:Texture;
    var frame = 0;

    public static var money:Int = -10000; 

    public function new(e:EntityData) {
        super(e);
        position = new Vector3(x, 0, y);
        velocity = new Vector3(0, 0, 0);
        dir = new Vector3(0, 0, 0);
        
        hand = Raylib.LoadTexture("content/hand.png");
    }

    var l = 15;
    var frameCounter = 15;
    extern overload inline function update(groundExists:Bool, look:Vector2, side:Int, forward:Int, jump:Bool, dt:Float):Void {
        if(frameCounter == 0) {frame = 0;frameCounter =l;}
        else frameCounter--;
        this.look = look;
        var rot = look.x;
        updateBody(groundExists, rot, side, forward, jump, dt);
        if(InputHandler.getShoot()) shoot();
    }

    function shoot() {
        Bullet.playerBullets.push(new Bullet(position.x, position.y + height - 0.5,position.z, look));
        frame = 1;
        money += 100;
    }

    function updateBody(groundExists:Bool, rot:Float, side:Int, forward:Int, jump:Bool, dt:Float) {
        var input = new Vector2(side, -forward);
        if(side != 0 && forward != 0) input = Vector2Normalize(input);

        if(!isGrounded) velocity.y = velocity.y - gravity * dt;

        if(isGrounded && jump) {
            velocity.y = jumpForce;
            isGrounded = false;
        }

        // TODO: Understand how it works
        var front = new Vector3(Math.sin(rot), 0, Math.cos(rot));
        var right = new Vector3(Math.cos(-rot), 0, Math.sin(-rot)); 

        var desiredDir = new Vector3(input.x * right.x + input.y * front.x, 0.0, input.x * right.z + input.y * front.z);
        dir = Vector3Lerp(dir, desiredDir, control * dt);

        var decel = isGrounded ? friction : airDrag;
        var hvel = new Vector3(velocity.x * decel, 0, velocity.z * decel);

        var hvelLength = Vector3Length(hvel);
        if(hvelLength < (maxSpeed * 0.01)) hvel = new Vector3(0, 0, 0);

        // strafing
        var speed = Vector3DotProduct(hvel, dir);

        var maxSpeed = maxSpeed;
        var acceleration = Clamp(maxSpeed - speed, 0., maxAcceleration * dt);
        hvel.x = hvel.x + dir.x * acceleration;
        hvel.z = hvel.z + dir.z * acceleration;

        velocity.x = hvel.x;
        velocity.z = hvel.z;

        position.x = position.x + velocity.x * dt;
        position.y = position.y + velocity.y * dt;
        position.z = position.z + velocity.z * dt;

        if(position.y <= 0 && groundExists) {
            position.y = 0;
            isGrounded = true;
        }

        if(!groundExists) {
            isGrounded = false;
        }
    }

    overload extern inline function draw() {
    }

    public function drawUI() {
        var s = 6;        
        Raylib.DrawTexturePro(hand, new Rectangle(frame * 64, frame * 64, 64, 64), new Rectangle((Raylib.GetScreenWidth()/2)-((s*64)/2), (Raylib.GetScreenHeight())-(s*64), 64 * s, 64 * s), new Vector2(0, 0), 0, Raylib.WHITE);
    }

    public function unload() {
        Raylib.UnloadTexture(hand);
    }
}
