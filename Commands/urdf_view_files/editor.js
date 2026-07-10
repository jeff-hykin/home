// editor.js — picking, axis-constrained drag editing, and URDF download.

import * as THREE from "three"
import { setJointXyz, serializeUrdf } from "./urdf-model.js"

const AXIS_DIR = { x: new THREE.Vector3(1, 0, 0), y: new THREE.Vector3(0, 1, 0), z: new THREE.Vector3(0, 0, 1) }

// parameter along axis line (point A, unit dir U) closest to the pick ray
function closestParamOnAxis(ray, A, U) {
    const w0 = new THREE.Vector3().subVectors(A, ray.origin)
    const b = U.dot(ray.direction)
    const denom = 1 - b * b
    if (Math.abs(denom) < 1e-6) {
        return null // axis nearly parallel to the view ray
    }
    const d = U.dot(w0)
    const e = ray.direction.dot(w0)
    return (b * e - d) / denom
}

export function installEditor(viewer, model, frames, callbacks) {
    const { camera, controls, renderer } = viewer
    const canvas = renderer.domElement
    const raycaster = new THREE.Raycaster()
    const pointer = new THREE.Vector2()

    let drag = null
    const undoStack = []

    function setPointer(event) {
        const rect = canvas.getBoundingClientRect()
        pointer.x = ((event.clientX - rect.left) / rect.width) * 2 - 1
        pointer.y = -((event.clientY - rect.top) / rect.height) * 2 + 1
        raycaster.setFromCamera(pointer, camera)
    }

    function pick() {
        const hits = raycaster.intersectObjects(frames.pickables, false)
        return hits.length ? hits[0].object.userData : null
    }

    canvas.addEventListener("pointerdown", (event) => {
        setPointer(event)
        const hit = pick()
        if (!hit) {
            return
        }
        if (hit.kind === "sphere") {
            frames.setSelected(hit.linkName)
            callbacks.onSelect(hit.linkName)
            return
        }
        // axis arrow: only editable if the link has an incoming joint (root is fixed)
        const joint = model.jointByChild.get(hit.linkName)
        if (!joint) {
            return
        }
        frames.setSelected(hit.linkName)
        callbacks.onSelect(hit.linkName)

        const frame = frames.framesByLink.get(hit.linkName)
        const axisWorldDir = AXIS_DIR[hit.axis].clone()
            .applyQuaternion(frame.group.getWorldQuaternion(new THREE.Quaternion()))
            .normalize()
        const startWorldPos = frame.group.getWorldPosition(new THREE.Vector3())
        const startParam = closestParamOnAxis(raycaster.ray, startWorldPos, axisWorldDir)
        if (startParam === null) {
            return
        }
        drag = { joint, frame, axisWorldDir, startWorldPos, startParam, prevXyz: [...joint.xyz] }
        controls.enabled = false
        canvas.setPointerCapture(event.pointerId)
    })

    canvas.addEventListener("pointermove", (event) => {
        if (!drag) {
            return
        }
        setPointer(event)
        const param = closestParamOnAxis(raycaster.ray, drag.startWorldPos, drag.axisWorldDir)
        if (param === null) {
            return
        }
        const newWorldPos = drag.startWorldPos.clone()
            .addScaledVector(drag.axisWorldDir, param - drag.startParam)
        const parentGroup = drag.frame.group.parent
        const newLocal = parentGroup.worldToLocal(newWorldPos.clone())
        drag.frame.group.position.copy(newLocal)
        setJointXyz(drag.joint, [newLocal.x, newLocal.y, newLocal.z])
        frames.refreshLines()
        callbacks.onChange(drag.joint.child)
    })

    function endDrag(event) {
        if (!drag) {
            return
        }
        const moved = drag.joint.xyz.some((value, index) => value !== drag.prevXyz[index])
        if (moved) {
            undoStack.push({ joint: drag.joint, frame: drag.frame, prevXyz: drag.prevXyz })
        }
        drag = null
        controls.enabled = true
        if (event) {
            canvas.releasePointerCapture(event.pointerId)
        }
    }
    canvas.addEventListener("pointerup", endDrag)
    canvas.addEventListener("pointercancel", endDrag)

    addEventListener("keydown", (event) => {
        if (event.key === "Escape") {
            frames.setSelected(null)
            callbacks.onSelect(null)
            return
        }
        if (event.key.toLowerCase() !== "z" || !(event.ctrlKey || event.metaKey)) {
            return
        }
        event.preventDefault()
        const entry = undoStack.pop()
        if (!entry) {
            return
        }
        setJointXyz(entry.joint, entry.prevXyz)
        entry.frame.group.position.set(...entry.prevXyz)
        frames.refreshLines()
        frames.setSelected(entry.joint.child)
        callbacks.onSelect(entry.joint.child)
    })

    document.getElementById("download").addEventListener("click", () => {
        const blob = new Blob([serializeUrdf(model)], { type: "application/xml" })
        const url = URL.createObjectURL(blob)
        const anchor = document.createElement("a")
        const robotName = model.dom.querySelector("robot")?.getAttribute("name") ?? "robot"
        anchor.href = url
        anchor.download = `${robotName}.modified.urdf`
        anchor.click()
        URL.revokeObjectURL(url)
    })
}
