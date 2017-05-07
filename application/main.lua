package.path = package.path ..';..\\?.lua';
require("lua.functions")
ngx.say("Hello")
ngx.say(MathFun.Add(12,90))
