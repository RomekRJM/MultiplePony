from dataclasses import dataclass

X_TO_ARROW = {
    32: 'L',
    96: 'X',
    160: 'R',
}

INITIAL_SHIFT_X = 64 + 8
FPS = 60
MAX_ACCEPTABLE_X = 160
FREQUENCY = 1000 / FPS
INITIAL_DELAY = INITIAL_SHIFT_X * FREQUENCY


@dataclass
class Event:
    type: str
    time: int
    repeats: int
    levelData: int
    repeated: bool

    def __init__(self, x, time, time2, type):
        self.type = X_TO_ARROW[x]
        self.time = round((time - INITIAL_DELAY )/ FREQUENCY)
        self.levelData = (x - 32) // 64
        self.repeated = type == 128
        self.repeats = 0

        if self.repeated:
            self.repeats = round((time2 - time) / (FPS * 4))
            self.type = self.type.lower()


def extract_events_from_osu(file):
    with open(file, 'r') as f:
        osu_lines = f.readlines()

    in_hit_section = False
    events = []
    contains_unsupported_arrows = False
    contains_unsupported_time = False

    for line in osu_lines:
        if line.startswith('[HitObjects]'):
            in_hit_section = True
            continue

        if not in_hit_section:
            continue

        x, _y, time, type, _hit_sound, hit_sample = line.split(',')
        time2 = hit_sample.split(':')[0]

        if int(x) > MAX_ACCEPTABLE_X:
            contains_unsupported_arrows = True
        elif int(time) < INITIAL_DELAY:
            contains_unsupported_time = True
        else:
            events.append(
                Event(int(x), int(time), int(time2), int(type))
            )

        if line.startswith('['):
            in_hit_section = False

    if contains_unsupported_arrows:
        print("\nSome arrows are not supported and were skipped. Use only LEFT, TOP, BOTTOM in ArrowVortex.")

    if contains_unsupported_time:
        print(f"\nMinimum time is {INITIAL_DELAY} ms. Some arrows are scheduled before that and were skipped.")

    return events


def event_to_lua_pony_code(events):
    level_data = []
    level_data2 = []
    level_data3 = []
    level_duration = 0

    for event in events:
        level_duration = max(level_duration, event.time)
        symbol = event.type

        if event.repeated:
            symbol += '-' + str(event.repeats)

        symbol += '-' + str(event.time)

        if event.levelData == 0:
            level_data.append(symbol)
        elif event.levelData == 1:
            level_data2.append(symbol)
        else:
            level_data3.append(symbol)

    return (f"\nlevelData = \"{','.join(level_data)}\"\nlevelData2 = \"{','.join(level_data2)}\""
            f"\nlevelData3 = \"{','.join(level_data3)}\"\nlevelDuration = {level_duration}")


if __name__ == '__main__':
    input_file = 'chippi [Hard].osu'
    osu_events = extract_events_from_osu(input_file)
    print(event_to_lua_pony_code(osu_events))
