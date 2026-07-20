// main.js — wire everything together.

import { parseUrdf, setJointXyz, setJointRpy } from "./urdf-model.js"
import { createViewer } from "./viewer.js"
import { buildFrames } from "./frames.js"
import { installKeyboardControls } from "./controls.js"
import { installEditor } from "./editor.js"

const RAD_TO_DEG = 180 / Math.PI
const DEG_TO_RAD = Math.PI / 180

const response = await fetch("/urdf.xml")
const model = parseUrdf(await response.text())

const viewer = createViewer(document.getElementById("app"))
const frames = buildFrames(viewer, model)
installKeyboardControls(viewer)
viewer.onFrame(() => frames.updateLabelScales(viewer.camera))

const selectedEl = document.getElementById("selected")
const neighborsEl = document.getElementById("neighbors")
const treeEl = document.getElementById("tree")
const treeNodes = new Map()
const inputs = {
    px: document.getElementById("px"), py: document.getElementById("py"), pz: document.getElementById("pz"),
    rx: document.getElementById("rx"), ry: document.getElementById("ry"), rz: document.getElementById("rz"),
}
const allInputs = Object.values(inputs)

let currentLink = null

function renderPanel(linkName) {
    currentLink = linkName
    selectedEl.textContent = linkName ?? "(none)"
    const neighbors = linkName ? frames.neighborsOf(linkName) : []
    neighborsEl.textContent = linkName
        ? (neighbors.length ? "→ " + neighbors.join(", ") : "(no connections)")
        : ""

    const neighborSet = new Set(neighbors)
    for (const [name, node] of treeNodes) {
        node.classList.toggle("sel", name === linkName)
        node.classList.toggle("nbr", name !== linkName && neighborSet.has(name))
    }

    const joint = linkName ? model.jointByChild.get(linkName) : null
    if (!joint) {
        for (const input of allInputs) {
            input.value = ""
            input.disabled = true
        }
        return
    }
    for (const input of allInputs) {
        input.disabled = false
    }
    inputs.px.value = joint.xyz[0].toFixed(4)
    inputs.py.value = joint.xyz[1].toFixed(4)
    inputs.pz.value = joint.xyz[2].toFixed(4)
    inputs.rx.value = (joint.rpy[0] * RAD_TO_DEG).toFixed(2)
    inputs.ry.value = (joint.rpy[1] * RAD_TO_DEG).toFixed(2)
    inputs.rz.value = (joint.rpy[2] * RAD_TO_DEG).toFixed(2)
}

function applyInputs() {
    const joint = currentLink ? model.jointByChild.get(currentLink) : null
    if (!joint) {
        return
    }
    const values = allInputs.map((input) => parseFloat(input.value))
    if (values.some(Number.isNaN)) {
        return
    }
    const [px, py, pz, rx, ry, rz] = values
    setJointXyz(joint, [px, py, pz])
    setJointRpy(joint, [rx * DEG_TO_RAD, ry * DEG_TO_RAD, rz * DEG_TO_RAD])
    frames.applyJointToFrame(currentLink)
}
for (const input of allInputs) {
    input.addEventListener("input", applyInputs)
}

function selectFrame(linkName) {
    frames.setSelected(linkName)
    renderPanel(linkName)
}

function buildTree(linkName, depth) {
    const node = document.createElement("div")
    node.className = "treenode"
    node.textContent = linkName
    node.style.paddingLeft = `${depth * 14 + 6}px`
    node.addEventListener("click", () => selectFrame(linkName))
    node.addEventListener("mouseenter", () => frames.setHovered(linkName))
    node.addEventListener("mouseleave", () => frames.setHovered(null))
    treeEl.appendChild(node)
    treeNodes.set(linkName, node)
    for (const child of model.childrenOf.get(linkName) ?? []) {
        buildTree(child, depth + 1)
    }
}
buildTree(model.root, 0)

installEditor(viewer, model, frames, {
    onSelect: renderPanel,
    onChange: renderPanel,
})

let arrowScale = 0.5
const ARROW_STEP = 1.25
function applyArrowScale() {
    arrowScale = Math.min(5, Math.max(0.25, arrowScale))
    frames.setArrowScale(arrowScale)
}
applyArrowScale() // lower default density
document.getElementById("thicker").addEventListener("click", () => {
    arrowScale *= ARROW_STEP
    applyArrowScale()
})
document.getElementById("thinner").addEventListener("click", () => {
    arrowScale /= ARROW_STEP
    applyArrowScale()
})

// debug handle for console poking / enhancement work
globalThis.urdfView = { model, frames, viewer, renderPanel }

console.log(`urdf-view: ${model.links.length} links, root = ${model.root}`)
