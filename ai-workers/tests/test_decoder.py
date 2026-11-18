import sys
import unittest
from pathlib import Path

_worker_root = str(Path(__file__).resolve().parent.parent)
if _worker_root not in sys.path:
    sys.path.insert(0, _worker_root)

from worker.config import scrub_credentials, validate_rtsp_url
from worker.decoder import RTSPStreamDecoder, CameraStreamHealthData

class TestRTSPDecoderAndSanitization(unittest.TestCase):
    def test_credential_scrubbing(self):
        url_with_pass = "rtsp://admin:secretPass123@192.168.1.100:554/live/ch0"
        scrubbed = scrub_credentials(url_with_pass)
        self.assertNotIn("secretPass123", scrubbed)
        self.assertIn("rtsp://***:***@192.168.1.100:554/live/ch0", scrubbed)

        error_msg = "Connection failed to rtsp://operator:p@ssword!@factory.internal:8554/stream"
        scrubbed_err = scrub_credentials(error_msg)
        self.assertNotIn("p@ssword!", scrubbed_err)

    def test_rtsp_url_validation(self):
        # Valid URLs
        self.assertTrue(validate_rtsp_url("rtsp://192.168.1.50/stream1"))
        self.assertTrue(validate_rtsp_url("rtsp://admin:pass@192.168.1.50:554/live/sub"))
        self.assertTrue(validate_rtsp_url("rtsps://camera.lan:322/ch0?token=xyz"))

        # Invalid URLs (command injection vectors, wrong protocols)
        self.assertFalse(validate_rtsp_url("http://192.168.1.50/stream"))
        self.assertFalse(validate_rtsp_url("rtsp://192.168.1.50/stream; rm -rf /"))
        self.assertFalse(validate_rtsp_url("rtsp://`whoami`@192.168.1.50/"))
        self.assertFalse(validate_rtsp_url(""))

    def test_ffmpeg_cmd_construction_shell_false(self):
        decoder = RTSPStreamDecoder(
            camera_id="cam-test",
            rtsp_url="rtsp://admin:pass@192.168.1.10:554/ch0",
            width=640,
            height=360
        )
        cmd = decoder.build_ffmpeg_cmd()
        # Verify argument list structure for shell=False
        self.assertIsInstance(cmd, list)
        self.assertIn("-rtsp_transport", cmd)
        self.assertIn("tcp", cmd)
        self.assertIn("-vf", cmd)
        self.assertIn("scale=640:360", cmd)
        self.assertIn("image2pipe", cmd)
        self.assertIn("bgr24", cmd)
        self.assertIn("rawvideo", cmd)
        self.assertEqual(cmd[-1], "-")

    def test_health_telemetry_defaults(self):
        health = CameraStreamHealthData("cam-01")
        self.assertFalse(health.online)
        self.assertEqual(health.fps_decoded, 0.0)
        self.assertEqual(health.dropped_frames, 0)
        self.assertEqual(health.last_frame_utc_ms, 0)

    def test_subprocess_lifecycle_and_terminate(self):
        decoder = RTSPStreamDecoder(
            camera_id="cam-lifecycle",
            rtsp_url="rtsp://localhost:8554/live",
            width=320,
            height=240
        )
        # Mock process
        import io
        from unittest.mock import MagicMock
        mock_proc = MagicMock()
        mock_proc.stdout = io.BytesIO(b"")
        mock_proc.stderr = io.BytesIO(b"")
        mock_proc.poll.return_value = None

        decoder.process = mock_proc
        decoder._terminate_process()

        self.assertIsNone(decoder.process)
        mock_proc.terminate.assert_called_once()
        self.assertTrue(mock_proc.stdout.closed)
        self.assertTrue(mock_proc.stderr.closed)

    def test_reconnection_loop_backoff(self):
        decoder = RTSPStreamDecoder(
            camera_id="cam-recon",
            rtsp_url="rtsp://localhost:8554/stream",
            width=320,
            height=240
        )
        # Test stop sets online=False
        decoder.start()
        decoder.stop()
        self.assertFalse(decoder.health.online)
        self.assertFalse(decoder._running)

if __name__ == '__main__':
    unittest.main()
