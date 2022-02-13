#!/usr/bin/env node

// https://coolors.co/687378-d9d9d3-38b2cb-0baaad-94d2bd-e9d8a6-ffcd70-fd905e-ef766b-e2797d
const palette = [{"name":"Nickel","hex":"687378","rgb":[104,115,120],"cmyk":[13,4,0,53],"hsb":[199,13,47],"hsl":[199,7,44],"lab":[48,-3,-4]},{"name":"Timberwolf","hex":"d9d9d3","rgb":[217,217,211],"cmyk":[0,0,3,15],"hsb":[60,3,85],"hsl":[60,7,84],"lab":[87,-1,3]},{"name":"Pacific Blue","hex":"38b2cb","rgb":[56,178,203],"cmyk":[72,12,0,20],"hsb":[190,72,80],"hsl":[190,59,51],"lab":[67,-25,-22]},{"name":"Verdigris","hex":"0baaad","rgb":[11,170,173],"cmyk":[94,2,0,32],"hsb":[181,94,68],"hsl":[181,88,36],"lab":[63,-34,-12]},{"name":"Middle Blue Green","hex":"94d2bd","rgb":[148,210,189],"cmyk":[30,0,10,18],"hsb":[160,30,82],"hsl":[160,41,70],"lab":[80,-24,4]},{"name":"Medium Champagne","hex":"e9d8a6","rgb":[233,216,166],"cmyk":[0,7,29,9],"hsb":[45,29,91],"hsl":[45,60,78],"lab":[87,-2,27]},{"name":"Maximum Yellow Red","hex":"ffcd70","rgb":[255,205,112],"cmyk":[0,20,56,0],"hsb":[39,56,100],"hsl":[39,100,72],"lab":[85,7,52]},{"name":"Atomic Tangerine","hex":"fd905e","rgb":[253,144,94],"cmyk":[0,43,63,1],"hsb":[19,63,99],"hsl":[19,98,68],"lab":[71,37,44]},{"name":"Salmon","hex":"ef766b","rgb":[239,118,107],"cmyk":[0,51,55,6],"hsb":[5,55,94],"hsl":[5,80,68],"lab":[64,46,28]},{"name":"Candy Pink","hex":"e2797d","rgb":[226,121,125],"cmyk":[0,46,45,11],"hsb":[358,46,89],"hsl":[358,64,68],"lab":[63,41,16]}];

palette.forEach((p) => {
    console.log(p.name);
    console.log("    x: " + (p.rgb[0] / 255).toFixed(5));
    console.log("    y: " + (p.rgb[1] / 255).toFixed(5));
    console.log("    z: " + (p.rgb[2] / 255).toFixed(5));
});

let markdown = [];
palette.forEach((p) => {
    markdown.push(`![#${p.hex}](https://via.placeholder.com/15/${p.hex}/000000?text=+) ${p.name}`)
});
console.log(markdown.join(", "));