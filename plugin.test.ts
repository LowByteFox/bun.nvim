import { describe, it, expect } from "bun:test";

it("I am a test", () => {
    expect(2+2).toBe(4)
});

describe("A group", () => {
    it("I'll fail", () => {
        throw new Error();
    });

    it("I am fine", () => {
        console.log("See?")
    });

    describe("A nested group", () => {
        it("A nested test", () => {
            console.log("I am fine as well")
        });
    });
})
