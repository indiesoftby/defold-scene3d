components {
  id: "building"
  component: "/scene3d/scripts/prefabs/building.script"
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
  properties {
    id: "frustum_mesh_max_dimension"
    value: "6.0"
    type: PROPERTY_TYPE_NUMBER
  }
}
embedded_components {
  id: "collision"
  type: "collisionobject"
  data: "collision_shape: \"/scene3d/assets/meshes/buildings_ramp_3x6.convexshape\"\n"
  "type: COLLISION_OBJECT_TYPE_STATIC\n"
  "mass: 0.0\n"
  "friction: 0.5\n"
  "restitution: 0.5\n"
  "group: \"default\"\n"
  "mask: \"default\"\n"
  "linear_damping: 0.0\n"
  "angular_damping: 0.0\n"
  "locked_rotation: false\n"
  "bullet: false\n"
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
embedded_components {
  id: "mesh"
  type: "mesh"
  data: "material: \"/scene3d/materials/basic_grid_rajah.material\"\n"
  "vertices: \"/scene3d/assets/meshes/buildings_ramp_3x6.buffer\"\n"
  "textures: \"/scene3d/assets/textures/grid_10x10.png\"\n"
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
