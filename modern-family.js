const Realm = require("realm");

// -- 0 --
// Define schema
const Parent = {
    name: "Parent",
    primaryKey: "name",
    properties: {
        name: "string",
        city: "string",
        children: "Child[]",
        marriedTo: "Parent",
    }
};

const Child = {
    name: "Child",
    properties: {
        name: "string",
        age: "int",
        parents: { type: "linkingObjects", objectType: "Parent", property: "children" },
    }
};

// Open the database
const realm = new Realm({ path: "modern-family.realm", schema: [Parent, Child] });
realm.write(() => {
    realm.deleteAll(); // remove all objects from previous run
});

// -- 1 --
// First weddings
realm.write(() => {
    // Alice and Bob are married
    const alice = realm.create(Parent.name, { name: "Alice", city: "Stockholm" });
    const bob = realm.create(Parent.name, { name: "Bob", city: "Stockholm "});
    alice.marriedTo = bob;
    bob.marriedTo = alice;

    // Charlie and Dorothy are married
    const charlie = realm.create(Parent.name, { name: "Charlie", city: "Helsinki" });
    const dorothy = realm.create(Parent.name, { name: "Dorothy", city: "Helsinki "});
    charlie.marriedTo = dorothy;
    dorothy.marriedTo = charlie;
});

// -- 2 --
// Kids arrive
realm.write(() => {
    // Alice and Bob
    const alice = realm.objectForPrimaryKey(Parent.name, "Alice");
    const bob = realm.objectForPrimaryKey(Parent.name, "Bob");

    const alma = realm.create(Child.name, { name: "Alma", age: 14 });
    const bill = realm.create(Child.name, { name: "Bill", age: 12 });
    [alma, bill].forEach(c => {
        alice.children.push(c);
        bob.children.push(c);
    });

    // Charlie and Dorothy
    const charlie = realm.objectForPrimaryKey(Parent.name, "Charlie");
    const dorothy = realm.objectForPrimaryKey(Parent.name, "Dorothy");

    const charlotte = realm.create(Child.name, { name: "Charlotte", age: 5 });
    const dillon = realm.create(Child.name, { name: "Dillon", age: 8 });
    const chuck = realm.create(Child.name, { name: "Chuck", age: 11 });
    [charlotte, dillon, chuck].forEach(c => {
        charlie.children.push(c);
        dorothy.children.push(c);
    });
});

// -- 3 --
// Alice and Bob split up
realm.write(() => {
    const alice = realm.objectForPrimaryKey(Parent.name, "Alice");
    const bob = realm.objectForPrimaryKey(Parent.name, "Bob");

    alice.marriedTo = null;
    bob.marriedTo = null;
});

// -- 4 --
// Alice meets Eric and they move to Oslo
realm.write(() => {
    const alice = realm.objectForPrimaryKey(Parent.name, "Alice");

    const eric = realm.create(Parent.name, { name: "Eric", city: "Oslo", marriedTo: alice });
    alice.marriedTo = eric;
    alice.city = "Oslo";
});

// -- 5 --
// Alice and Eric have a child
realm.write(() => {
    const alice = realm.objectForPrimaryKey(Parent.name, "Alice");
    const eric = realm.objectForPrimaryKey(Parent.name, "Eric");

    const ellen = realm.create(Child.name, { name: "Ellen", age: 1 });
    alice.children.push(ellen);
    eric.children.push(ellen);
});

// -- 6 --
// 15 years pass
realm.write(() => {
    realm.objects(Child.name).forEach(c => c.age += 15 );
});

// -- 7 --
// Alice dies
realm.write(() => {
    realm.delete(realm.objectForPrimaryKey(Parent.name, "Alice"));
});

// -- 8 --
// Queries
console.log("Children with one parent:");
let childrenWithOneParent = realm.objects(Child.name).filtered("parents.@count = 1");
childrenWithOneParent.forEach(c => console.log(`  ${c.name} (${c.age})`));

console.log("Unmarried parents:");
let singles = realm.objects(Parent.name).filtered("marriedTo = null");
singles.forEach(p => console.log(`  ${p.name}`));

realm.close();
process.exit(0);