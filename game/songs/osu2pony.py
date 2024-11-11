from dataclasses import dataclass

X_TO_ARROW = {
    32: 'L',
    96: 'X',
    160: 'R',
}

INITIAL_DELAY = 128
FPS = 60
MAX_ACCEPTABLE_X = 160


@dataclass
class Event:
    type: str
    time: int
    repeats: int
    levelData: int
    repeated: bool

    def __init__(self, x, time, time2, type):
        self.type = X_TO_ARROW[x]
        self.time = round(INITIAL_DELAY + time / FPS)
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

    for line in osu_lines:
        if line.startswith('[HitObjects]'):
            in_hit_section = True
            continue

        if not in_hit_section:
            continue

        x, _y, time, type, _hit_sound, hit_sample = line.split(',')
        time2 = hit_sample.split(':')[0]

        if int(x) <= MAX_ACCEPTABLE_X:
            events.append(
                Event(int(x), int(time), int(time2), int(type))
            )

        if line.startswith('['):
            in_hit_section = False

    return events


def event_to_lua_pony_code(events):
    level_data = []
    level_data2 = []
    level_data3 = []
    level_duration = 0

    for event in events:
        level_duration = max(level_duration, event.time)
        symbol = event.type + '-' + str(event.time)

        # if event.repeated:
        #     symbol += '-' + str(event.repeats)

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
