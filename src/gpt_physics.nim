#[ Simple 2D physics, provided by ChatGPT,
    on request by: Florent Monnier ]#
#[ To the extent permitted by law, and to the extent permitted
    by the terms of use of chatgpt, you can use, study, modify,
    redistribute, and relicense this library ]#

import std/math

type
  Point* = object
    x*, y*: cdouble

type
  Vector* = object
    x*, y*: cdouble

type
  Segment* = object
    a*, b*: Point

type
  Circle*[T] = object
    center*: Point
    radius*: cdouble
    inertia*: Vector
    is_static*: bool  # static circles don't move
    custom*: T


# Function to apply gravity to a circle
proc apply_gravity*[T](circle: var Circle[T], g: Vector, dt: cdouble) =
  circle.inertia.x += g.x * dt
  circle.inertia.y += g.y * dt


# Function to normalize a vector (x, y)
proc normalize_vector*(v: Vector): Vector =
  let magnitude = sqrt(v.x * v.x + v.y * v.y)
  if magnitude == 0:
    Vector(x: 0, y: 0)  # Handle the zero vector case to avoid division by zero
  else:
    Vector(x: v.x / magnitude, y: v.y / magnitude)


# Function to handle collision between a circle and a segment
proc collision_circle_segment*[T](circle: var Circle[T], segment: Segment, restitution: cdouble) =
  let cx = circle.center.x
  let cy = circle.center.y
  let r = circle.radius

  let vx = circle.inertia.x
  let vy = circle.inertia.y

  let a = segment.a
  let b = segment.b

  # Calculate the minimum and maximum x and y values of the segment
  let min_x = min(segment.a.x, segment.b.x)
  let min_y = min(segment.a.y, segment.b.y)
  let max_x = max(segment.a.x, segment.b.x)
  let max_y = max(segment.a.y, segment.b.y)

  # Quick check if the circle can be in collision
  if (cx + r >= min_x) and (cx - r <= max_x) and (cy + r >= min_y) and (cy - r <= max_y):
    # Calculate the direction vector of the segment
    let dx = segment.b.x - segment.a.x
    let dy = segment.b.y - segment.a.y

    # Calculate the vector from the start of the segment to the center of the circle
    let fx = cx - segment.a.x
    let fy = cy - segment.a.y

    # Calculate the parameter t for the projection of the circle's center on the segment
    let t = (fx * dx + fy * dy) / (dx * dx + dy * dy)

    # Calculate the point of projection on the segment
    var proj_x: cdouble = 0
    var proj_y: cdouble = 0

    if t < 0:
      proj_x = a.x
      proj_y = a.y
    elif t > 1:
      proj_x = b.x
      proj_y = b.y
    else:
      proj_x = a.x + t * dx
      proj_y = a.y + t * dy

    # Calculate the distance between the center of the circle and the projection point
    let diff_x = cx - proj_x
    let diff_y = cy - proj_y
    let distance = sqrt(diff_x * diff_x + diff_y * diff_y)

    # Check for collision
    if distance <= r:
      # Collision detected, calculate the new velocity vector
      let normal_x = (cx - proj_x) / distance
      let normal_y = (cy - proj_y) / distance
      let dot_product = vx * normal_x + vy * normal_y

      # Update the velocity vector by inverting the normal component and applying restitution
      if not circle.is_static:
        circle.inertia.x = vx - (1 + restitution) * dot_product * normal_x
        circle.inertia.y = vy - (1 + restitution) * dot_product * normal_y

      # Separate the circle from the segment to avoid consecutive collisions
      let penetration_depth = r - distance
      if not circle.is_static:
        circle.center.x = cx + normal_x * penetration_depth
        circle.center.y = cy + normal_y * penetration_depth


# Function to handle collision between two circles
proc collision_circle_circle*(circle1, circle2: var Circle, restitution: cdouble) =
  let dx = circle2.center.x - circle1.center.x
  let dy = circle2.center.y - circle1.center.y
  let distance = sqrt(dx * dx + dy * dy)
  let overlap = circle1.radius + circle2.radius - distance

  if overlap > 0.0:
    let normal = normalize_vector(Vector(x: dx, y: dy))
    let relative_velocity_x = circle1.inertia.x - circle2.inertia.x
    let relative_velocity_y = circle1.inertia.y - circle2.inertia.y
    let dot_product = relative_velocity_x * normal.x + relative_velocity_y * normal.y

    if dot_product > 0.0:
      # Resolve the collision by adjusting the velocities
      let impulse = (1 + restitution) * dot_product / (circle1.radius + circle2.radius)
      if not circle1.is_static:
        circle1.inertia.x -= impulse * normal.x
        circle1.inertia.y -= impulse * normal.y

      if not circle2.is_static:
        circle2.inertia.x += impulse * normal.x
        circle2.inertia.y += impulse * normal.y

      # Separate the circles to avoid consecutive collisions
      let separation = overlap / 2.0
      if not circle1.is_static:
        circle1.center.x -= normal.x * separation
        circle1.center.y -= normal.y * separation

      if not circle2.is_static:
        circle2.center.x += normal.x * separation
        circle2.center.y += normal.y * separation


# Function to update the position of multiple circles and handle collisions
proc update_circles*(circles: var seq[Circle], segments: seq[Segment], gravity: Vector, dt, restitution: cdouble) =
  for i in 0 ..< circles.len:
    if not circles[i].is_static:
      # Apply gravity to the circle's velocity
      apply_gravity(circles[i], gravity, dt)
     
      # Update the circle's position based on its velocity
      circles[i].center.x += circles[i].inertia.x * dt
      circles[i].center.y += circles[i].inertia.y * dt
     
      # Check for collisions with each segment
      for segment in segments:
        collision_circle_segment(circles[i], segment, restitution)

  # Check for collisions between circles
  # Outer loop: process each circle except the last one
  for i in 0 ..< circles.len:
    # Inner loop: compare with all subsequent circles
    for j in (i+1) ..< circles.len:
      # Check collision between current pair of circles
      collision_circle_circle(circles[i], circles[j], restitution)

