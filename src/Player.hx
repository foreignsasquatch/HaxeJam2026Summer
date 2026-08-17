import raylib.Raymath.*;
import raylib.Types;
import raylib.Raylib;

class Player {
    var gravity = 32.;
    var jumpForce = 12.;
    
    var maxSpeed = 20.;
    var maxAcceleration = 150.;
 
    var friction = 0.86;
    var airDrag = 0.85;

    var control = 15.;
    public var height = 1.;

    public var position:Vector3;
    public var velocity:Vector3;
    public var dir:Vector3;
    public var isGrounded:Bool = true;
    
    public function new() {
        position = new Vector3(0, 0, 0);
        velocity = new Vector3(0, 0, 0);
        dir = new Vector3(0, 0, 0);
    }

    public function update(rot:Float, side:Int, forward:Int, jump:Bool, dt:Float) {
        updateBody(rot, side, forward, jump, dt);
    }

    function updateBody(rot:Float, side:Int, forward:Int, jump:Bool, dt:Float) {
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

        if(position.y <= 0) {
            position.y = 0;
            position.y = 0;
            isGrounded = true;
        }
    }

    public function draw() {
    }
}
