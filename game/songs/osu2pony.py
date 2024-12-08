from dataclasses import dataclass

X_TO_ARROW = {
    32: {
        'arrow': 'L',
        'repeat_x_adjustment': 0,
        'first_element_timestamp_diff': 8,
        'next_element_timestamp_diff': 8,
    },
    96: {
        'arrow': 'X',
        'repeat_x_adjustment': -16,
        'first_element_timestamp_diff': 14,
        'next_element_timestamp_diff': 3,
    },
    160: {
        'arrow': 'R',
        'repeat_x_adjustment': 0,
        'first_element_timestamp_diff': 16,
        'next_element_timestamp_diff': 8,
    },
}

INITIAL_SHIFT_X = 64 + 8
FPS = 60
MAX_ACCEPTABLE_X = 160
FREQUENCY = 1000 / FPS
INITIAL_DELAY = INITIAL_SHIFT_X * FREQUENCY
BASE_ARROW_LENGTH = 16


@dataclass
class Event:
    type: str
    time: int
    repeats: int
    levelData: int
    repeated: bool

    def __init__(self, x, time, time2, type):
        self.type = X_TO_ARROW[x]['arrow']
        self.levelData = (x - 32) // 64
        self.repeated = type == 128
        self.repeats = 0

        if self.repeated:
            repeat_x_adjustment = X_TO_ARROW[x]['repeat_x_adjustment']
            first_element_timestamp_diff = X_TO_ARROW[x]['first_element_timestamp_diff']

            duration = BASE_ARROW_LENGTH + first_element_timestamp_diff + repeat_x_adjustment
            duration /= FREQUENCY
            frame_diff = (time2 - time) / FREQUENCY
            all_repeats = (frame_diff - duration) / X_TO_ARROW[x]['next_element_timestamp_diff']
            self.repeats = round(all_repeats)
            self.type = self.type.lower()
            time += repeat_x_adjustment

        self.time = round((time - INITIAL_DELAY) / FREQUENCY)


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
