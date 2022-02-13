#!/usr/bin/env node

const fs = require("fs");
const path = require("path");

const meshesDir = __dirname + "/../scene3d/assets/meshes";
const iconsDir = __dirname + "/../scene3d/prefabs/icons";

const icons = [
    "arrow_right_thick",
    "cog",
    "flag",
    "flash",
    "heart",
    "home",
    "key",
    "location",
    "lock_closed",
    "lock_open",
    "music",
    "puzzle",
    "spanner",
    "star",
    "tick",
    "video",
];

const goContents = fs.readFileSync(iconsDir + "/icon_home.go", { encoding: "utf-8" });

icons.forEach((icon) => {
    const filename = iconsDir + "/icon_" + icon + ".go";

    const lua = fs.readFileSync(meshesDir + "/icon_" + icon + ".lua", { encoding: "utf-8" });
    const size = lua.match(/M\.size = vmath\.vector3\(([\d\.]+), *([\d\.]+), *([\d\.]+)\)/);
    const maxDimension = Math.max(size[1], size[2], size[3]);

    const contents = goContents
        .replace(/icon_home/g, "icon_" + icon)
        .replace(/100\.02732873/g, maxDimension.toFixed(10));

    console.log("Write '" + icon + "'");
    fs.writeFileSync(filename, contents, { encoding: "utf-8" });
});
