#!/usr/bin/env -S deno run --allow-read --allow-net --allow-env
// Report whether Foxglove will actually be able to draw a ROS2-CDR .mcap.
//
// A screenshot only proves a window rendered. The things that silently render
// nothing are: a channel that is not `cdr`, a null or truncated schema (a msgdef
// missing its `====` separated Header block loads fine and draws nothing), and a
// body that decodes to all-zero or all-NaN values, which looks exactly like a
// panel that is switched off.

import { McapIndexedReader } from "https://esm.sh/@mcap/core@2.1.6"
import { decompress as zstdDecompress } from "https://esm.sh/fzstd@0.1.1"
import lz4 from "https://esm.sh/lz4js@0.2.0"
// esm.sh serves this one CommonJS-style: the named exports live on `default`.
import rosmsg from "https://esm.sh/@foxglove/rosmsg@5.0.4"
const parseMessageDefinition = rosmsg.parse
import { MessageReader } from "https://esm.sh/@foxglove/rosmsg2-serialization@3.0.1"

const path = Deno.args[0]
if (path === undefined) {
    console.error("usage: mcap_check <file.mcap> [seconds-into-the-file]")
    Deno.exit(2)
}
const probeAt = Number(Deno.args[1] ?? 0)

const file = await Deno.open(path, { read: true })
const size = (await file.stat()).size
const readable = {
    size: async () => BigInt(size),
    read: async (offset, length) => {
        const buffer = new Uint8Array(Number(length))
        await file.seek(Number(offset), Deno.SeekMode.Start)
        let filled = 0
        while (filled < buffer.length) {
            const got = await file.read(buffer.subarray(filled))
            if (got === null) {
                break
            }
            filled += got
        }
        return buffer
    },
}
const reader = await McapIndexedReader.Initialize({
    readable,
    decompressHandlers: {
        zstd: (bytes, decompressedSize) => zstdDecompress(bytes, new Uint8Array(Number(decompressedSize))),
        lz4: (bytes) => new Uint8Array(lz4.decompress(bytes)),
    },
})

const start = Number(reader.statistics?.messageStartTime ?? 0n) / 1e9
const end = Number(reader.statistics?.messageEndTime ?? 0n) / 1e9
console.log(`${path}`)
console.log(`  ${reader.statistics?.messageCount ?? 0} messages, ${(end - start).toFixed(1)} s, ${(size / 1e9).toFixed(2)} GB`)
console.log(`  probing ${probeAt.toFixed(1)} s in\n`)

/** Summarise a decoded message enough to tell "real data" from "structurally valid nothing". */
function describe(message) {
    // A PointCloud2 also carries `data` and `width`, so it has to be matched ahead
    // of the image cases or it gets reported as a one-row picture.
    if (message.point_step !== undefined) {
        const count = message.width * message.height
        const floats = new Float32Array(message.data.buffer, message.data.byteOffset, Math.floor(message.data.byteLength / 4))
        const finite = floats.some((value) => Number.isFinite(value) && value !== 0)
        return `${count} points, fields ${message.fields.map((f) => f.name).join(",")}` +
            `${finite ? "" : "  NO FINITE VALUES"}`
    }
    if (message.pose !== undefined && message.twist !== undefined) {
        const { x, y, z } = message.pose.pose.position
        return `pos [${x.toFixed(3)}, ${y.toFixed(3)}, ${z.toFixed(3)}] ${message.header.frame_id}->${message.child_frame_id}` +
            (x === 0 && y === 0 && z === 0 ? "  ALL ZERO" : "")
    }
    if (message.data instanceof Uint8Array && message.width !== undefined) {
        const nonZero = message.data.some((byte) => byte !== 0)
        return `${message.width}x${message.height} ${message.encoding ?? message.format}` +
            ` ${message.data.length} bytes${nonZero ? "" : "  ALL ZERO"}`
    }
    if (message.data instanceof Uint8Array && message.format !== undefined) {
        return `${message.format} ${message.data.length} bytes` +
            (message.data.some((byte) => byte !== 0) ? "" : "  ALL ZERO")
    }
    if (message.linear_acceleration !== undefined) {
        const { x, y, z } = message.linear_acceleration
        return `acc [${x.toFixed(3)}, ${y.toFixed(3)}, ${z.toFixed(3)}]` +
            (x === 0 && y === 0 && z === 0 ? "  ALL ZERO" : "")
    }
    if (message.transforms !== undefined) {
        return `${message.transforms.length} transforms: ` +
            message.transforms.map((t) => `${t.header.frame_id}->${t.child_frame_id}`).join(", ")
    }
    if (message.k !== undefined || message.K !== undefined) {
        const k = message.k ?? message.K
        return `${message.width}x${message.height} fx=${k[0].toFixed(1)} fy=${k[4].toFixed(1)}`
    }
    return Object.keys(message).join(",")
}

let problems = 0
const channels = [...reader.channelsById.values()].sort((a, b) => a.topic.localeCompare(b.topic))
for (const channel of channels) {
    const schema = reader.schemasById.get(channel.schemaId)
    const count = Number(reader.statistics?.channelMessageCounts.get(channel.id) ?? 0)
    let label = `  ${channel.topic}  (${count})`

    if (channel.messageEncoding !== "cdr") {
        console.log(`${label}\n      BAD  message_encoding=${channel.messageEncoding}, Foxglove wants cdr`)
        problems++
        continue
    }
    if (schema === undefined || schema.data.length === 0) {
        console.log(`${label}\n      BAD  no schema attached`)
        problems++
        continue
    }
    const text = new TextDecoder().decode(schema.data)
    // A msgdef that names a sub-type it does not go on to define is the truncation
    // that loads cleanly and then draws nothing.
    const referenced = [...text.matchAll(/^\s*([a-z_]+\/[A-Za-z0-9_]+)/gm)].map((m) => m[1])
    const defined = new Set([schema.name, ...[...text.matchAll(/^MSG:\s*(\S+)/gm)].map((m) => m[1])])
    const missing = [...new Set(referenced)].filter((name) => {
        const short = name.split("/").pop()
        return ![...defined].some((have) => have.split("/").pop() === short)
    })

    // Where a channel sits on the timeline, relative to the file's own start.
    // A stream written with stamps from a different clock still decodes perfectly
    // and then sits somewhere Foxglove's playhead never reaches.
    let firstTime = null
    let lastTime = null
    for await (const message of reader.readMessages({ topics: [channel.topic] })) {
        firstTime = Number(message.logTime) / 1e9
        break
    }
    for await (const message of reader.readMessages({ topics: [channel.topic], reverse: true })) {
        lastTime = Number(message.logTime) / 1e9
        break
    }
    label += firstTime === null ? "" : `  [${(firstTime - start).toFixed(1)} .. ${(lastTime - start).toFixed(1)} s]`

    let sample = null
    let error = null
    try {
        const messageReader = new MessageReader(parseMessageDefinition(text, { ros2: true }))
        const at = BigInt(Math.round((start + probeAt) * 1e9))
        for await (const message of reader.readMessages({ topics: [channel.topic], startTime: at })) {
            sample = messageReader.readMessage(message.data)
            break
        }
        if (sample === null) {
            for await (const message of reader.readMessages({ topics: [channel.topic] })) {
                sample = messageReader.readMessage(message.data)
                break
            }
        }
    } catch (thrown) {
        error = thrown.message
    }

    if (error !== null) {
        console.log(`${label}\n      BAD  ${schema.name}: ${error}`)
        problems++
        continue
    }
    if (sample === null) {
        console.log(`${label}\n      BAD  ${schema.name}: no message could be read`)
        problems++
        continue
    }
    const described = describe(sample)
    const suspect = missing.length > 0 || /ALL ZERO|NO FINITE/.test(described)
    console.log(`${label}\n      ${suspect ? "BAD " : "ok  "} ${schema.name}: ${described}` +
        (missing.length > 0 ? `  undefined sub-types: ${missing.join(", ")}` : ""))
    if (suspect) {
        problems++
    }
}

file.close()
console.log(problems === 0 ? "\nall channels decode" : `\n${problems} channel(s) Foxglove will not draw`)
Deno.exit(problems === 0 ? 0 : 1)
