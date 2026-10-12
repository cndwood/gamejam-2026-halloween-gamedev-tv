# Wave difficulty

The central WaveSpawner owns all spawn points and tracks a shared wave budget. Skeleton stats are assigned before entering the world. Entrances are picked randomly per batch.

Waves begin with 18 enemies and gain 5 per wave, capped at 100. Batches start at 3–5 enemies; the maximum grows every three waves to 8. Within-batch gaps are 0.3–0.75 seconds, and between-batch gaps are 0.9–1.9 seconds. Timing shrinks 4% per wave to half its initial range, with a 0.12-second minimum gap. The announcement delay remains 1.4 seconds.

| Wave | Enemies | HP | Base speed | Door damage | Attack interval | Break |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | 18 | 3 | 65 | 2 | 1.30s | 8s |
| 5 | 38 | 4 | 81 | 3 | 1.14s | 6s |
| 10 | 63 | 6 | 101 | 5 | 0.94s | 3.5s |
| 30 | 100 | 10 | 110 | 6 | 0.80s | 3s |

Movement varies ±10% per skeleton. Attack intervals allow the 0.7-second animation to complete. Waves finish after their full budget spawns and all enemies die or are removed. Pause freezes scheduling; game over stops it. Door HP, healing, repair duration and upgrades remain unchanged. Tune wave sizes and timing on the controller; enemy scaling is in get_enemy_stats(). Active-player playtesting is needed to judge final balance.
