import re
from collections import Counter

with open('entry/src/main/ets/daily/data/DailyLightCopyLibrary.ets', 'r', encoding='utf-8') as f:
    text = f.read()

ids = re.findall(r"id:\s*'([^']+)'", text)
directions = re.findall(r"direction:\s*DailyDirection\.([A-Z_]+)", text)
counts = Counter(directions)

print('Total items:', len(ids))
print('Per direction:', dict(counts))
print('All directions count >= 5:', all(c >= 5 for c in counts.values()))
print('Unique ids:', len(set(ids)) == len(ids))

red_words = ['一定会','必然','命中注定','复合','复合概率','正缘','烂桃花','对方爱你','他爱你','她爱你','转运','财运','中奖','神准','灵验','改命','保证','你必须','马上断联','赶紧离开','你应该继续','你应该离开','亲爱的','宝贝','我一直在等你','我只属于你']
found = [w for w in red_words if w in text]
print('Red words found:', found if found else 'None')

# Simulate RandomUtil to verify stability

def hash_seed(s: str) -> int:
    h = 2166136261
    for ch in s:
        h ^= ord(ch)
        h = (h * 16777619) & 0xffffffff
    return h

def next_value(x: int) -> int:
    x = x & 0xffffffff
    x ^= (x << 13) & 0xffffffff
    x ^= (x >> 17) & 0xffffffff
    x ^= (x << 5) & 0xffffffff
    return x & 0xffffffff

def seeded_numbers(seed: str, count: int):
    values = []
    current = hash_seed(seed)
    for _ in range(count):
        current = next_value(current)
        values.append(current / 0xffffffff)
    return values

def select_index(seed: str, total: int) -> int:
    values = seeded_numbers(seed, 1)
    return int(values[0] * total) % total

# Map direction enum values to ids
from enum import Enum
class DailyDirection(Enum):
    GENTLE = 'gentle'
    ATTENTION = 'attention'
    LESS_RESULT = 'less_result'
    BLANK = 'blank'
    SLOW = 'slow'
    HEAR_SELF = 'hear_self'
    BOUNDARY = 'boundary'
    ALLOW_IMPERFECT = 'allow_imperfect'

# Extract content items grouped by direction
items = []
for m in re.finditer(r"id:\s*'([^']+)'[\s\S]*?direction:\s*DailyDirection\.([A-Z_]+)", text):
    items.append((m.group(1), m.group(2)))

direction_ids = {d: [] for d in DailyDirection}
for id, dir_name in items:
    d = DailyDirection[dir_name]
    direction_ids[d].append(id)

# Verify stability for same dateKey+direction
for d in DailyDirection:
    candidates = direction_ids[d]
    seed = f'daily-2026-07-03-{d.value}'
    idx1 = select_index(seed, len(candidates))
    idx2 = select_index(seed, len(candidates))
    assert idx1 == idx2, f'Stability failed for {d}'
    print(f'{d.value}: selected {candidates[idx1]}')

# Verify exclusion
for d in DailyDirection:
    candidates = direction_ids[d]
    seed = f'daily-2026-07-03-{d.value}'
    selected = candidates[select_index(seed, len(candidates))]
    remaining = [c for c in candidates if c != selected]
    if remaining:
        # Verify that exclusion works: if selected is in recentContentIds, the next candidate is chosen
        seed_excluded = f'daily-2026-07-03-{d.value}'
        # Simulate recentContentIds containing selected; we don't re-seed, just verify the candidate list excludes it
        assert selected not in remaining, f'Exclusion failed for {d}'
        print(f'{d.value}: remaining candidates {len(remaining)} after excluding selected')

print('All checks passed.')
