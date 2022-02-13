#!/usr/bin/env node

const fs = require("fs");
const path = require("path");

const meshesDir = __dirname + "/../scene3d/assets/meshes";
const lettersDir = __dirname + "/../scene3d/prefabs/icons/letters";
// fs.readdirSync(lettersDir).forEach((file) => {
//     console.log(file);
// });

const goContents = fs.readFileSync(lettersDir + "/icon_letter_A.go", { encoding: "utf-8" });
const letters = "BCDEFGHIJKLMNOPRSTUVWXYZ0123456789".split("");

letters.forEach((letter) => {
    const filename = lettersDir + "/icon_letter_" + letter + ".go";

    const lua = fs.readFileSync(meshesDir + "/icon_letter_" + letter + ".lua", { encoding: "utf-8" });
    const size = lua.match(/M\.size = vmath\.vector3\(([\d\.]+), *([\d\.]+), *([\d\.]+)\)/);
    const maxDimension = Math.max(size[1], size[2], size[3]);

    const contents = goContents
        .replace(/letter_A/g, "letter_" + letter)
        .replace(/92\.5750017166/g, maxDimension.toFixed(10));

    console.log("Write '" + letter + "'");
    fs.writeFileSync(filename, contents, { encoding: "utf-8" });
});
