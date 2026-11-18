# DATA SOURCES & SYNTHETIC MEDIA MANIFEST
## Industrial AI Surveillance Platform — Local Development Baseline
**Status:** Public Domain / Synthetic Generated Media Only  
**License:** CC0 / Public Domain  
**Restriction:** Zero real employee footage, zero real factory video, zero real biometric data (`docs/governance/OWNER_AUTHORIZATION_LOCAL_DEV.md`).

---

## 1. Synthetic Video Streams Manifest

| File Relative Path | Resolution / FPS | Duration | Content Description | Generation Method / Command | SHA-256 Checksum | License |
|---|---|---|---|---|---|---|
| `data/synthetic/test_stream_01.mp4` | 640×360 @ 10 FPS | 15s (Looped) | Test pattern with simulated green/red bounding box crossing zone polygon | FFmpeg `testsrc` filter with `drawbox` moving coordinates | `SYNTHETIC_GENERATED_AT_RUNTIME` | CC0 Public Domain |
| `data/synthetic/test_stream_02.mp4` | 640×360 @ 10 FPS | 15s (Looped) | Factory floor synthetic background with simulated moving object | FFmpeg `smptebars` with noise overlay | `SYNTHETIC_GENERATED_AT_RUNTIME` | CC0 Public Domain |

---

## 2. Exact Generation Commands

```bash
# Stream 1: Simulated worker crossing boundary
ffmpeg -y -f lavfi -i testsrc=duration=15:size=640x360:rate=10 \
  -vf "drawbox=x='if(lte(t,5),100+t*20,200)':y=100:w=50:h=100:color=red@0.8:t=fill" \
  -c:v libx264 -pix_fmt yuv420p data/synthetic/test_stream_01.mp4

# Stream 2: Normal factory corridor background
ffmpeg -y -f lavfi -i testsrc=duration=15:size=640x360:rate=10 \
  -vf "drawbox=x=50:y=50:w=120:h=120:color=blue@0.5:t=2" \
  -c:v libx264 -pix_fmt yuv420p data/synthetic/test_stream_02.mp4
```
