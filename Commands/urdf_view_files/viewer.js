// viewer.js — three.js scene scaffolding (Z-up, like URDF) and the render loop.

import * as THREE from "three"
import { OrbitControls } from "https://esm.sh/three@0.160.0/examples/jsm/controls/OrbitControls.js?external=three"

export function createViewer(container) {
    const scene = new THREE.Scene()
    scene.background = new THREE.Color(0x14171c)

    const camera = new THREE.PerspectiveCamera(50, 1, 0.001, 1000)
    camera.up.set(0, 0, 1) // URDF is Z-up
    camera.position.set(0.6, -0.8, 0.5)

    const renderer = new THREE.WebGLRenderer({ antialias: true })
    renderer.setPixelRatio(window.devicePixelRatio)
    container.appendChild(renderer.domElement)

    scene.add(new THREE.AmbientLight(0xffffff, 0.8))
    const sun = new THREE.DirectionalLight(0xffffff, 0.6)
    sun.position.set(1, -1, 2)
    scene.add(sun)

    const grid = new THREE.GridHelper(2, 20, 0x2c333d, 0x222831)
    grid.rotation.x = Math.PI / 2 // lay flat on XY (Z-up)
    scene.add(grid)

    const controls = new OrbitControls(camera, renderer.domElement)
    controls.enableDamping = true
    controls.dampingFactor = 0.1

    function resize() {
        const width = container.clientWidth
        const height = container.clientHeight
        camera.aspect = width / height
        camera.updateProjectionMatrix()
        renderer.setSize(width, height)
    }
    resize()
    window.addEventListener("resize", resize)

    const updaters = []
    function onFrame(callback) {
        updaters.push(callback)
    }

    function loop() {
        requestAnimationFrame(loop)
        for (const update of updaters) {
            update()
        }
        controls.update()
        renderer.render(scene, camera)
    }
    loop()

    return { scene, camera, renderer, controls, onFrame }
}
