import sys
import unittest
from pathlib import Path

_worker_root = str(Path(__file__).resolve().parent.parent)
if _worker_root not in sys.path:
    sys.path.insert(0, _worker_root)

from worker.sampler import MultiRateFrameSampler

class TestMultiRateFrameSampler(unittest.TestCase):
    def setUp(self):
        self.sampler = MultiRateFrameSampler({
            "intrusion": 2.0,   # 500 ms interval
            "ppe": 0.5,         # 2000 ms interval
        })

    def test_initial_sampling(self):
        # Both should sample on the first check
        self.assertTrue(self.sampler.should_sample("intrusion", now_mono=0.0))
        self.assertTrue(self.sampler.should_sample("ppe", now_mono=0.0))

    def test_interval_enforcement(self):
        now = 100.0
        # Trigger initial samples
        self.assertTrue(self.sampler.should_sample("intrusion", now_mono=now))
        self.assertTrue(self.sampler.should_sample("ppe", now_mono=now))

        # At t = 100.3s (300ms elapsed): neither should sample
        self.assertFalse(self.sampler.should_sample("intrusion", now_mono=now + 0.3))
        self.assertFalse(self.sampler.should_sample("ppe", now_mono=now + 0.3))

        # At t = 100.51s (510ms elapsed): intrusion should sample (2.0 FPS), but NOT PPE (0.5 FPS)
        self.assertTrue(self.sampler.should_sample("intrusion", now_mono=now + 0.51))
        self.assertFalse(self.sampler.should_sample("ppe", now_mono=now + 0.51))

        # At t = 102.05s (2050ms elapsed): PPE should now sample
        self.assertTrue(self.sampler.should_sample("ppe", now_mono=now + 2.05))

    def test_time_until_next_sample(self):
        now = 50.0
        self.sampler.should_sample("intrusion", now_mono=now)
        rem = self.sampler.time_until_next_sample("intrusion", now_mono=now + 0.2)
        self.assertAlmostEqual(rem, 0.3, places=2)

    def test_dynamic_rate_update(self):
        self.sampler.set_rate("custom", 10.0)
        self.assertEqual(self.sampler.get_rate("custom"), 10.0)
        with self.assertRaises(ValueError):
            self.sampler.set_rate("invalid", -1.0)

if __name__ == '__main__':
    unittest.main()
