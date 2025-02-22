struct VertexInput {
    @location(0) pos: vec2<f32>;
};

struct VertexOutput {
    @builtin(position) coords: vec4<f32>;
    @location(0) center:       vec2<f32>;
    @location(1) radius:       f32;
    @location(2) stroke_width: f32;
    @location(3) fill_color:   u32;
    @location(4) stroke_color: u32;
    
};

let MAX_CLIPPINGS = 64;


struct GlobalsUniform {
    @location(0) resolution:      vec2<f32>;
    @location(1) layer_clippings: array<mat2x2<f32>, MAX_CLIPPINGS>;
};

@group(0)
@binding(0)
var<uniform> globals: GlobalsUniform;

struct InstanceInput {
    @location(1) center:       vec2<f32>;
    @location(2) radius:       f32;
    @location(3) stroke_width: f32;
    @location(4) fill_color:   u32;
    @location(5) stroke_color: u32;
    @location(6) z:            f32;
};

@stage(vertex)
fn vs_main(
    model: VertexInput,
    instance: InstanceInput,
) -> VertexOutput {
    var out: VertexOutput;

    out.coords = vec4<f32>(model.pos, instance.z, 1.0);
    // Y-axis is opposite
    out.center = vec2<f32>(instance.center.x, globals.resolution.y - instance.center.y);
    out.radius = instance.radius;
    out.stroke_width = instance.stroke_width;
    out.fill_color = instance.fill_color;
    out.stroke_color = instance.stroke_color;
    
    return out;
}

@stage(fragment)
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    // width to apply anti-aliase
    let HALF_PIXEL = 0.5;

    var fill_color:   vec4<f32> = unpack4x8unorm(in.fill_color);
    var stroke_color: vec4<f32> = unpack4x8unorm(in.stroke_color);

    var dist_fill         = distance(in.coords.xy, in.center) - in.radius;
    var dist_stroke_inner = distance(in.coords.xy, in.center) - (in.radius - in.stroke_width * 0.5);
    var dist_stroke_outer = distance(in.coords.xy, in.center) - (in.radius + in.stroke_width * 0.5);

    // TODO: A poor-man's anti-aliasing. I don't know how to do it correctly atm...
    fill_color.a *= clamp(HALF_PIXEL - dist_fill, 0.0, 1.0);
    stroke_color.a *= min(
        clamp(HALF_PIXEL - dist_stroke_outer, 0.0, 1.0),  // if it's inside of the outer boundary
        clamp(dist_stroke_inner + HALF_PIXEL, 0.0, 1.0),  // if it's outside of the inner boundary
    );

    // alpha blending
    var out_a = stroke_color.a + fill_color.a * (1.0 - stroke_color.a);
    if (out_a == 0.0) {
        return vec4<f32>(0.0);
    } else {
        return vec4<f32>(
            (stroke_color.rgb * stroke_color.a + 
                fill_color.rgb * fill_color.a * (1.0 - stroke_color.a)) / out_a,
            out_a
        );
    }
}
