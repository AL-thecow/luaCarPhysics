-- require "luarocks.loader"
-- run tests in terminal with: Lua test.lua 
-- for more verbose output use: Lua test.lua -v
luaunit = require('luaunit')
require ("constants")

TestVector = {}
    test1 = Vector.new(5,math.pi/3)
    test2 = Vector.new(5,math.pi/3)

    function TestVector:testVectorAddition()
        local sum = test1 + test2
        luaunit.assertEquals(sum.m,10)
        luaunit.assertEquals(sum.d,math.pi/3)
    end
    function TestVector:testVectorSubtraction()
        local sub = test1 - test2
        luaunit.assertEquals(sub.m,0)
        luaunit.assertEquals(sub.d,0)
    end
    function TestVector:testVectorUnit()
        local unit = unit(test1)
        luaunit.assertEquals(unit.m,1)
        luaunit.assertEquals(unit.d,math.pi/3)
    end
    function TestVector:testVectorNormalizePositiveRadians()
        local v = Vector.new(5,7 * math.pi/3)
        local testNormal = normalize(v)
        luaunit.assertEquals(testNormal.m,v.m)
        luaunit.assertEquals(testNormal.d,math.pi/3)
    end
    function TestVector:testVectorNormalizeNegativeRadians()
        local v = Vector.new(5,-11 * math.pi/3)
        local testNormal = normalize(v)
        luaunit.assertEquals(testNormal.m,v.m)
        luaunit.assertEquals(testNormal.d,math.pi/3)
    end
    function TestVector:testVectorComponents()
        luaunit.assertEquals(test1:x(),test1.m * math.cos(test1.d))
        luaunit.assertEquals(test1:y(),test1.m * math.sin(test1.d))
    end
    function TestVector:testVectorDotProduct()
        local dot1 = dot(test1,-test2)
        local dot2 = dot(test2,-test1)
        local testdot = -25
        luaunit.assertEquals(dot1,dot2)
        luaunit.assertEquals(dot1,testdot)
    end

os.exit( luaunit.LuaUnit.run() )