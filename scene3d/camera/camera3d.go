components {
  id: "camera3d"
  component: "/scene3d/camera/camera3d.script"
  position {
    x: 0.0
    y: 0.0
    z: 0.0
  }
  rotation {
    x: 0.0
    y: 0.0
    z: 0.0
    w: 1.0
  }
}
embedded_components {
  id: "debug_mesh"
  type: "mesh"
  data: "material: \"/scene3d/materials/primitive_atomic_tangerine.material\"\n"
  "vertices: \"/scene3d/assets/meshes/icon_camera.buffer\"\n"
  "primitive_type: PRIMITIVE_TRIANGLES\n"
  "position_stream: \"position\"\n"
  "normal_stream: \"normal\"\n"
  ""
  position {
    x: 0.0
    y: 0.0
    z: 0.0
  }
  rotation {
    x: 0.0
    y: 0.0
    z: 0.0
    w: 1.0
  }
}
