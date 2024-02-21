shader_type spatial;


// HOW TO:
// 1. Load this shader on a plane mesh, set it's x and y size to your preference
// 2. The Subdivisions should be one less that it's size on that axis; so if you did 512, then make it 511 on subdivisons
// 3. You then need a Heightmap image and a Normalmap Image; Make sure these are imported as "VRAM UNCOMPRESSED"
// 4. You must have a ROAD MASK for it to show anything.  Road Masks check for white to draw roads. Use BLACK for no roads.
// 5 Add a Biome Mask Image -- again, import as VRAM UNCOMPRESSED!
// 6. Play around with values and textures to your hearts content.

// More Stuff to know~

// All sorts of interesting height maps to take inspiration from or use online! Search "Desert Height Map" on google for an example!
// Otherwise generating varying types of noise or even drawing the images work great!
// About Biome Masks: Red for Biome 1, Green for Biome 2, and Blue for Biome 3 -- Anything not colored will default to Biome 1
// The Height Controls can act strangely, I have added some default values to keep you from getting messed up.
// You can adjust the Terrain Size to scale this and acheive more interesting large landscapes
// -- make sure you pass this number to your collision detection!
// You can Set Different Textures for each biome! Up to 3 Biomes supported.
// And You can set what textures are used by roads
// The Normal Map helps the lighting. You can make a normal map from your height map with NormalMapOnline for free!
// Really REALLY big Images affect performance, as you might expect.
// This doesn't handle LOD or stitching LODs for you, sorry. 



// Uniforms
uniform sampler2D heightmap;
uniform sampler2D normalmap;
uniform sampler2D texture_albedo : source_color;
uniform sampler2D biome_mask : source_color; // Biome mask texture
uniform sampler2D bottom_texture_1 : source_color; // Texture for bottom biome of type 1
uniform sampler2D middle_texture_1 : source_color; // Texture for middle biome of type 1
uniform sampler2D top_texture_1 : source_color; // Texture for top biome of type 1
uniform sampler2D bottom_texture_2 : source_color; // Texture for bottom biome of type 2
uniform sampler2D middle_texture_2 : source_color; // Texture for middle biome of type 2
uniform sampler2D top_texture_2 : source_color; // Texture for top biome of type 2
uniform sampler2D bottom_texture_3 : source_color; // Texture for bottom biome of type 3
uniform sampler2D middle_texture_3 : source_color; // Texture for middle biome of type 3
uniform sampler2D top_texture_3 : source_color; // Texture for top biome of type 3
uniform sampler2D road_mask : source_color; // Road mask texture
uniform sampler2D road_texture : source_color; // Road texture

uniform float amplitude = 200; // Controls overall Height
uniform float min_bottom_height = 0.0; // The minimum height at which you can expect bottom textures to show
uniform float min_middle_height = 30.0; // The minimum height at which you can expect middle textures to show
uniform float max_top_height = 90.0; // The maximum height for top textures.
uniform float tex_size; // How big or small your textures will appear!
uniform float terrain_size; // How big we stretch the heightmap image! Don't forget to pass this value to however your doing collisions!

varying float vertex_y;
varying vec2 texture_position;

void vertex() {
    vec3 world_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    texture_position = (world_vertex.xz + 0.5) / (terrain_size * float(textureSize(heightmap, 0).x));
    VERTEX.y = texture(heightmap, texture_position).r * amplitude;
    vertex_y = VERTEX.y;
}


void fragment() {
    // Sample biome mask
    vec3 biome_mask_color = texture(biome_mask, texture_position).xyz;

    // Sample road mask
    vec3 road_mask_color = texture(road_mask, texture_position).xyz;

    // If there is a white pixel on the road mask, use road texture
    vec3 final_albedo;
    if (road_mask_color.r > 0.9 || road_mask_color.g > 0.9 || road_mask_color.b > 0.9) {
        final_albedo = texture(road_texture, texture_position * tex_size).xyz;
    } else {
        // Select textures based on biome mask
        vec3 bottom_albedo;
        vec3 middle_albedo;
        vec3 top_albedo;

        // Sample textures for each biome
        bottom_albedo = texture(bottom_texture_1, texture_position * tex_size).xyz;
        middle_albedo = texture(middle_texture_1, texture_position * tex_size).xyz;
        top_albedo = texture(top_texture_1, texture_position * tex_size).xyz;

        // Mix textures based on the intensity of each color channel in the biome mask
        bottom_albedo = mix(bottom_albedo, texture(bottom_texture_2, texture_position * tex_size).xyz, biome_mask_color.b);
        bottom_albedo = mix(bottom_albedo, texture(bottom_texture_3, texture_position * tex_size).xyz, biome_mask_color.b);

        middle_albedo = mix(middle_albedo, texture(middle_texture_2, texture_position * tex_size).xyz, biome_mask_color.g);
        middle_albedo = mix(middle_albedo, texture(middle_texture_3, texture_position * tex_size).xyz, biome_mask_color.g);

        top_albedo = mix(top_albedo, texture(top_texture_2, texture_position * tex_size).xyz, biome_mask_color.r);
        top_albedo = mix(top_albedo, texture(top_texture_3, texture_position * tex_size).xyz, biome_mask_color.r);

        // Calculate weights for terrain types
        float bottom_weight = smoothstep(min_bottom_height, min_middle_height, vertex_y);
        float top_weight = smoothstep(min_middle_height, max_top_height, vertex_y);

        // Mix terrain types based on weights
        final_albedo = mix(bottom_albedo, middle_albedo, bottom_weight);
        final_albedo = mix(final_albedo, top_albedo, top_weight);
    }

    // Output final albedo
    ALBEDO = final_albedo;
    NORMAL_MAP = texture(normalmap, texture_position).rgb;
}


