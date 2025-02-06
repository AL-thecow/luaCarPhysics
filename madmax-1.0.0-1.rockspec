package = "madmax"
version = "1.0.0-1"
rockspec_format = "3.0"
source = {
   url = "*** please add URL for source tarball, zip or repository here ***"
}
description = {
   homepage = "*** please enter a project homepage ***",
   license = "*** please specify a license ***"
}
dependencies = {
   "lua >= 5.1, < 5.5",
   "luaunit >= 3.4"

}
test_dependencies = {
  "luaunit >= 3.4"
}
build = {
   type = "builtin",
   modules = {
      conf = "conf.lua",
      constants = "constants.lua",
      draw = "draw.lua",
      main = "main.lua",
      player = "player.lua"
   }
}
test = {
  type = "command",
  script = "test.lua"
}
