"""
Shawaf AI — Cleanroom Asset & Synthetic Video Generator
Generates:
1. Deterministic Cleanroom ONNX Model (cleanroom_yolox_nano_fp32.onnx)
   - Input: [1, 3, 416, 416] float32
   - Output: [1, 10, 6] float32 (x1, y1, x2, y2, score, class_id)
2. Synthetic MP4 videos (640x360 and 1280x720) with a moving target across defined zones.
3. Computes SHA-256 checksums and appends them to SOURCES.md.
"""

import os
import hashlib
import cv2
import numpy as np
import onnx
from onnx import helper, TensorProto


def generate_cleanroom_onnx_model(output_path: str):
    """
    Builds a minimal valid ONNX neural network model representing a detection head.
    Architecture:
    Input: 'images' [1, 3, 416, 416] (float32)
    Conv layer -> Relu -> GlobalAveragePool -> Flatten -> Gemm -> Reshape to [1, 10, 6]
    Outputs: 'detections' [1, 10, 6] (float32)
    Deterministic synthetic weights initialized with fixed random seed.
    """
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    rng = np.random.RandomState(42)

    # Inputs & Outputs
    images = helper.make_tensor_value_info('images', TensorProto.FLOAT, [1, 3, 416, 416])
    detections = helper.make_tensor_value_info('detections', TensorProto.FLOAT, [1, 10, 6])

    # Weights
    w_conv = rng.randn(16, 3, 3, 3).astype(np.float32) * 0.01
    b_conv = np.zeros(16, dtype=np.float32)
    w_fc = rng.randn(16, 60).astype(np.float32) * 0.01
    b_fc = np.zeros(60, dtype=np.float32)

    # Force first detection slot to produce a high-confidence bounding box for testing
    # [x1, y1, x2, y2, score, class_id] -> normalized [0.35, 0.40, 0.65, 0.85, 0.92, 0.0]
    b_fc[0:6] = [150.0, 160.0, 270.0, 350.0, 0.92, 0.0]

    # Reshape shape tensor
    shape_val = np.array([1, 10, 6], dtype=np.int64)

    t_w_conv = helper.make_tensor('w_conv', TensorProto.FLOAT, [16, 3, 3, 3], w_conv.flatten())
    t_b_conv = helper.make_tensor('b_conv', TensorProto.FLOAT, [16], b_conv.flatten())
    t_w_fc = helper.make_tensor('w_fc', TensorProto.FLOAT, [16, 60], w_fc.flatten())
    t_b_fc = helper.make_tensor('b_fc', TensorProto.FLOAT, [60], b_fc.flatten())
    t_shape = helper.make_tensor('shape_tensor', TensorProto.INT64, [3], shape_val.flatten())

    # Nodes
    n_conv = helper.make_node('Conv', ['images', 'w_conv', 'b_conv'], ['conv_out'], kernel_shape=[3, 3], pads=[1, 1, 1, 1])
    n_relu = helper.make_node('Relu', ['conv_out'], ['relu_out'])
    n_pool = helper.make_node('GlobalAveragePool', ['relu_out'], ['pool_out'])
    n_flatten = helper.make_node('Flatten', ['pool_out'], ['flat_out'])
    n_gemm = helper.make_node('Gemm', ['flat_out', 'w_fc', 'b_fc'], ['fc_out'], alpha=1.0, beta=1.0)
    n_reshape = helper.make_node('Reshape', ['fc_out', 'shape_tensor'], ['detections'])

    graph = helper.make_graph(
        [n_conv, n_relu, n_pool, n_flatten, n_gemm, n_reshape],
        'CleanroomYOLOXNano',
        [images],
        [detections],
        [t_w_conv, t_b_conv, t_w_fc, t_b_fc, t_shape]
    )

    model = helper.make_model(graph, producer_name='shawaf-ai-cleanroom', opset_imports=[helper.make_opsetid('', 13)])
    onnx.checker.check_model(model)
    onnx.save(model, output_path)
    print(f"Generated cleanroom ONNX model at: {output_path}")


def generate_synthetic_video(output_path: str, width: int, height: int, frames: int = 150, fps: float = 15.0):
    """
    Renders a deterministic synthetic MP4 video depicting an industrial floor with:
    - Floor grid lines
    - Visual safety zone polygon outline (Teal #2DD4BF)
    - Moving simulated target (Yellow/Red box) walking into the restricted safety zone
    """
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    out = cv2.VideoWriter(output_path, fourcc, fps, (width, height))

    # Zone polygon points (normalized to width/height)
    zone_pts = np.array([
        [int(width * 0.40), int(height * 0.35)],
        [int(width * 0.85), int(height * 0.35)],
        [int(width * 0.85), int(height * 0.80)],
        [int(width * 0.40), int(height * 0.80)],
    ], np.int32)

    for i in range(frames):
        # Background: dark industrial floor (#0B111E)
        frame = np.full((height, width, 3), (30, 17, 11), dtype=np.uint8)

        # Floor grid lines
        for y in range(0, height, 40):
            cv2.line(frame, (0, y), (width, y), (45, 25, 18), 1)
        for x in range(0, width, 40):
            cv2.line(frame, (x, 0), (x, height), (45, 25, 18), 1)

        # Safety zone polygon fill & border (#2DD4BF -> BGR: 191, 212, 45)
        overlay = frame.copy()
        cv2.fillPoly(overlay, [zone_pts], (191, 212, 45))
        cv2.addWeighted(overlay, 0.20, frame, 0.80, 0, frame)
        cv2.polylines(frame, [zone_pts], isClosed=True, color=(191, 212, 45), thickness=2)

        # Text label
        cv2.putText(frame, "ZONE: BNF-CRANE-01 [RESTRICTED]", (zone_pts[0][0] + 10, zone_pts[0][1] + 25),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.45, (191, 212, 45), 1, cv2.LINE_AA)

        # Simulated moving worker entering zone:
        # Starts outside at x=0.15*width, moves diagonally into zone across 150 frames
        t = i / float(frames)
        start_x = width * 0.15
        target_x = width * 0.60
        curr_x = int(start_x + t * (target_x - start_x))
        curr_y = int(height * 0.50 + np.sin(t * 3.14) * (height * 0.05))

        bw, bh = int(width * 0.08), int(height * 0.22)
        x1, y1 = curr_x - bw // 2, curr_y - bh // 2
        x2, y2 = x1 + bw, y1 + bh

        # Check if inside zone
        inside = (curr_x >= zone_pts[0][0] and curr_x <= zone_pts[1][0] and
                  y2 >= zone_pts[0][1] and y2 <= zone_pts[2][1])

        box_color = (0, 0, 255) if inside else (0, 215, 255)  # Red if intrusion, Gold if safe
        cv2.rectangle(frame, (x1, y1), (x2, y2), box_color, 2)

        # Foot contact point indicator
        cv2.circle(frame, (curr_x, y2), 4, (0, 255, 0), -1)

        # Bounding box label
        label = "PERSON [ALERT]" if inside else "PERSON"
        cv2.putText(frame, label, (x1, y1 - 6), cv2.FONT_HERSHEY_SIMPLEX, 0.40, box_color, 1, cv2.LINE_AA)

        out.write(frame)

    out.release()
    print(f"Generated synthetic video ({width}x{height}, {frames} frames) at: {output_path}")


def compute_sha256(file_path: str) -> str:
    h = hashlib.sha256()
    with open(file_path, 'rb') as f:
        while chunk := f.read(65536):
            h.update(chunk)
    return h.hexdigest()


if __name__ == '__main__':
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    model_path = os.path.join(base_dir, 'data', 'models', 'cleanroom_yolox_nano_fp32.onnx')
    vid_360 = os.path.join(base_dir, 'data', 'synthetic', 'synthetic_intrusion_640x360.mp4')
    vid_720 = os.path.join(base_dir, 'data', 'synthetic', 'synthetic_intrusion_1280x720.mp4')

    generate_cleanroom_onnx_model(model_path)
    generate_synthetic_video(vid_360, 640, 360, frames=150, fps=15.0)
    generate_synthetic_video(vid_720, 1280, 720, frames=150, fps=15.0)

    model_hash = compute_sha256(model_path)
    vid360_hash = compute_sha256(vid_360)
    vid720_hash = compute_sha256(vid_720)

    print("\n--- Checksums ---")
    print(f"cleanroom_yolox_nano_fp32.onnx: {model_hash}")
    print(f"synthetic_intrusion_640x360.mp4: {vid360_hash}")
    print(f"synthetic_intrusion_1280x720.mp4: {vid720_hash}")

    sources_path = os.path.join(base_dir, 'data', 'SOURCES.md')
    with open(sources_path, 'a', encoding='utf-8') as f:
        f.write("\n## 5. Verified File Hashes\n\n")
        f.write(f"- `data/models/cleanroom_yolox_nano_fp32.onnx`: `{model_hash}`\n")
        f.write(f"- `data/synthetic/synthetic_intrusion_640x360.mp4`: `{vid360_hash}`\n")
        f.write(f"- `data/synthetic/synthetic_intrusion_1280x720.mp4`: `{vid720_hash}`\n")
    print(f"Updated {sources_path}")
