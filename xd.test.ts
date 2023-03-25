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

describe("2nd group", () => {
    test("huh", () => {
        console.log("YAYn't")
    });
});

it("xd", () => {})

describe("Top", () => {
    describe("Nested", () => {
        describe("Nested Nested", () => {
            describe("Nested 3 times", () => {
                describe("Nested 4 times", () => {
                    describe("Nested 5 times", () => {
                        describe("Nested 6 times", () => {
                            describe("Nested 7 times", () => {
                                describe("Nested 8 times", () => {
                                    describe("Nested 9 times", () => {
                                        it("just a test", () => {});
                                    })
                                })
                            })
                        })
                    })
                })
            })
        })
    })
})
