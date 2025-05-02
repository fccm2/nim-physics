import gpt_physics
import random
import pages

let cnv = getElementById("c1")
let ctx = cnv.getContext2d()

proc draw_bg() =
  ctx.beginPath()
  ctx.fillStyle(255, 255, 255)
  ctx.rect(0, 0, 340, 240)
  ctx.fill()

proc draw_c(c: Circle) =
  ctx.beginPath()
  ctx.fillStyle(240, 180, 20)
  ctx.circle(c.center.x, c.center.y, c.radius)
  ctx.fill()

proc draw_ln(s: Segment) =
  ctx.beginPath()
  ctx.strokeStyle(10, 230, 80)
  ctx.lineWidth(1.4)
  ctx.moveTo(s.a.x, s.a.y)
  ctx.lineTo(s.b.x, s.b.y)
  ctx.stroke()

# main

randomize()  # initialises the seed

var circles = @[
  Circle[void](center: Point(x: 100, y: 50), radius: 8.4,  inertia: Vector(x:  2.0, y: 0), is_static: false),
  Circle[void](center: Point(x: 30,  y: 10), radius: 12.6, inertia: Vector(x: -1.0, y: 0), is_static: false),
  Circle[void](center: Point(x: 60,  y: 20), radius: 10.9, inertia: Vector(x:  1.4, y: 0), is_static: false),
  Circle[void](center: Point(x: 80,  y: 50), radius: 9.6,  inertia: Vector(x: -0.6, y: 0), is_static: false),
  Circle[void](center: Point(x: 120, y: 30), radius: 6.2,  inertia: Vector(x:  0.8, y: 0), is_static: false),
  Circle[void](center: Point(x: 140, y: 40), radius: 8.2,  inertia: Vector(x:  0.8, y: 0), is_static: false),
]

var segments = @[
  Segment(a: Point(x: 10.0, y: 230.0), b: Point(x: 330.0, y: 230.0)),  # Horizontal segment

  Segment(a: Point(x:  60.0, y: 140.0), b: Point(x: 160.0, y: 160.0)),
  Segment(a: Point(x: 280.0, y: 170.0), b: Point(x: 305.0, y: 155.0)),
  Segment(a: Point(x: 190.0, y: 190.0), b: Point(x: 250.0, y: 190.0)),

  Segment(a: Point(x:  10.0, y: 110.0), b: Point(x:  10.0, y: 230.0)),  # Left
  Segment(a: Point(x: 330.0, y: 100.0), b: Point(x: 330.0, y: 230.0)),  # Right
]

let gravity = Vector(x: 0, y: 1.6)
let restitution: cdouble = 0.8  # Coefficient of restitution (0.8 means 20% energy loss)
let dt: cdouble = 0.2

proc animate() =
  update_circles(circles, segments, gravity, dt, restitution)
  draw_bg()
  for circle in circles:
    draw_c(circle)
  for segment in segments:
    draw_ln(segment)

setInterval(animate, 1000 div 20)

