import { describe, test, expect, it } from "bun:test";

describe("a group",(): void => {
    test("A test", function() {
        throw new Error();
    });

    describe("bun", () => {
        test("the best", () => {
            console.log("runtime ever")
        });
    });

    test("A test1", function() {
        expect(4).toBe(4)
    });

    it("second test", () => {
        expect(8).toBe(8);
    });

});

describe("uwu", () => {
    test("huh", () => {
        console.log("YAYn't")
    });
});
