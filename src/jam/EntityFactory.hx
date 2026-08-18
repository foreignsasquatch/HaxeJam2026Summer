package jam;

import jam.Serializables.EntityData;

typedef EntityFactoryT = EntityData->Entity;

class EntityFactory {
    public var entityRegister:Map<String, EntityFactoryT> = [];

    public function new() {
    }

    public function registerEntityType<T:Entity>(name:String, factory:EntityFactoryT) {
        entityRegister[name] = factory;
    }

    public function createEntity(name:String, data:EntityData) {
        var factory = entityRegister[name];
        return factory(data);
    }

    public function getAllNames():Array<String> {
        var a:Array<String> = [];
        for(k => v in entityRegister) a.push(k);
        return a;
    }
}
