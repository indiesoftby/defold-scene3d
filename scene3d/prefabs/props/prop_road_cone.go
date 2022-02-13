components {
  id: "prop"
  component: "/scene3d/scripts/prefabs/primitive.script"
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
    value: "0.937625050545"
    type: PROPERTY_TYPE_NUMBER
  }
}
embedded_components {
  id: "collision_dynamic"
  type: "collisionobject"
  data: "collision_shape: \"/scene3d/assets/meshes/prop_road_cone.convexshape\"\n"
  "type: COLLISION_OBJECT_TYPE_DYNAMIC\n"
  "mass: 1.0\n"
  "friction: 0.75\n"
  "restitution: 0.1\n"
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
  data: "material: \"/scene3d/materials/basic_color.material\"\n"
  "vertices: \"/scene3d/assets/meshes/prop_road_cone.buffer\"\n"
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
embedded_components {
  id: "collision_static"
  type: "collisionobject"
  data: "collision_shape: \"/scene3d/assets/meshes/prop_road_cone.convexshape\"\n"
  "type: COLLISION_OBJECT_TYPE_STATIC\n"
  "mass: 0.0\n"
  "friction: 0.75\n"
  "restitution: 0.1\n"
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
