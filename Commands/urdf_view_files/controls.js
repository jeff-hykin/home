// controls.js — WASD to fly the camera, IJKL to change the viewing angle.
// Runs alongside OrbitControls (which keeps mouse orbit/zoom).

import * as THREE from "three"

const MOVE_SPEED = 0.012
const LOOK_SPEED = 0.025

export function installKeyboardControls(viewer) {
    const { camera, controls, onFrame } = viewer
    const held = new Set()

    const watched = new Set([..."wasdijklqe"])
    addEventListener("keydown", (event) => {
        // Ignore modifier chords (cmd+A, ctrl+S, …). On macOS the browser does
        // not deliver keyup for a letter while Cmd is held, so a movement key
        // pressed as part of a shortcut would otherwise stay stuck forever.
        if (event.metaKey || event.ctrlKey || event.altKey) {
            held.clear()
            return
        }
        const key = event.key.toLowerCase()
        if (watched.has(key)) {
            held.add(key)
        }
    })
    addEventListener("keyup", (event) => held.delete(event.key.toLowerCase()))
    addEventListener("blur", () => held.clear())

    const forward = new THREE.Vector3()
    const right = new THREE.Vector3()
    const offset = new THREE.Vector3()

    onFrame(() => {
        if (held.size === 0) {
            return
        }
        forward.subVectors(controls.target, camera.position).setZ(0)
        if (forward.lengthSq() < 1e-9) {
            forward.set(0, 1, 0)
        }
        forward.normalize()
        right.crossVectors(forward, camera.up).normalize()

        // WASD: translate camera and orbit target together (planar fly)
        const move = new THREE.Vector3()
        if (held.has("w")) move.add(forward)
        if (held.has("s")) move.sub(forward)
        if (held.has("d")) move.add(right)
        if (held.has("a")) move.sub(right)
        if (move.lengthSq() > 0) {
            move.normalize().multiplyScalar(MOVE_SPEED)
            camera.position.add(move)
            controls.target.add(move)
        }

        // QE: move straight up / down along world up
        const vertical = (held.has("e") ? 1 : 0) - (held.has("q") ? 1 : 0)
        if (vertical !== 0) {
            const lift = camera.up.clone().multiplyScalar(vertical * MOVE_SPEED)
            camera.position.add(lift)
            controls.target.add(lift)
        }

        // IJKL: FPS look — rotate the view direction in place (camera stays put,
        // the orbit target swings around the camera).
        offset.subVectors(controls.target, camera.position)
        if (held.has("j")) offset.applyAxisAngle(camera.up, LOOK_SPEED)
        if (held.has("l")) offset.applyAxisAngle(camera.up, -LOOK_SPEED)
        if (held.has("i") || held.has("k")) {
            const candidate = offset.clone()
            if (held.has("i")) candidate.applyAxisAngle(right, LOOK_SPEED)
            if (held.has("k")) candidate.applyAxisAngle(right, -LOOK_SPEED)
            // clamp so we never pitch fully vertical (avoids flipping)
            if (Math.abs(candidate.clone().normalize().dot(camera.up)) < 0.985) {
                offset.copy(candidate)
            }
        }
        controls.target.copy(camera.position).add(offset)
    })
}
