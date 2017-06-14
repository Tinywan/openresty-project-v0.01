--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2017/6/13
-- Time: 14:26
-- To change this template use File | Settings | File Templates.
--

foo =  function(val)
    if val then
        return val
    end

    if not val then
        return val + 10
    end
    return val
end

print(foo(12))
