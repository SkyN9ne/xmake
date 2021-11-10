--!A cross-platform build utility based on Lua
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
-- Copyright (C) 2015-present, TBOOX Open Source Group.
--
-- @author      ruki
-- @file        xmake.lua
--

-- generate bridge.rs.cc/h to call rust library in c++ code
-- @see https://cxx.rs/build/other.html
rule("rust.cxxbridge")
    set_extensions(".rs")
    before_build_file(function (target, sourcefile, opt)
        print(sourcefile)
    end)

-- define rule: rust.build
rule("rust.build")
    set_sourcekinds("rc")
    on_load(function (target)
        if target:is_static() then
            target:set("extension", ".rlib")
            target:add("arflags", "--crate-type=lib")
        elseif target:is_shared() then
            target:add("shflags", "--crate-type=dylib")
            -- fix cannot satisfy dependencies so `std` only shows up once
            -- https://github.com/rust-lang/rust/issues/19680
            --
            -- but it will link dynamic @rpath/libstd-xxx.dylib,
            -- so we can no longer modify and set other rpath paths
            target:add("shflags", "-C prefer-dynamic")
        elseif target:is_binary() then
            target:add("ldflags", "--crate-type=bin")
        end
        target:data_set("inherit.links.deplink", false)
    end)
    on_build("build.target")

-- define rule: rust
rule("rust")

    -- add build rules
    add_deps("rust.build")

    -- inherit links and linkdirs of all dependent targets by default
    add_deps("utils.inherit.links")
