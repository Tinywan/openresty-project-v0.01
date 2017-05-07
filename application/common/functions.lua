-- 全局的表package
MathFun = {}
-- 以下把所有的函数放在这个全局表中
-- +
function MathFun.Add(a,b)
    return a+b
end

-- -
function MathFun.Minus(a,b)
    return a-b
end

-- *
function MathFun.Multi(a,b)
    return a*b
end
-- /
function MathFun.Div(a,b)
    return a/b
end
