from dataclasses import dataclass

X_TO_ARROW = {
    32: 'L',
    96: 'B',
    160: 'T',
    224: 'R',
    288: 'X',
    352: 'Z',
}

INITIAL_DELAY = 128
FPS = 60


@dataclass
class Event:
    type: str
    time: int
    firstLevelData: bool
    repeated: bool

    def __init__(self, x, time, type):
        self.type = X_TO_ARROW[x]
        self.time = INITIAL_DELAY + time // FPS
        self.firstLevelData = x <= 224
        self.repeated = type == 3

        if self.repeated:
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

        x, _y, time, type, _hit_sound, _hit_sample = line.split(',')

        events.append(
            Event(int(x), int(time), int(type))
        )

        if line.startswith('['):
            in_hit_section = False

    return events


def event_to_lua_pony_code(events):
    # levelData = "L-32,R-32,T-32,B-32,l-8-8,R-40"
    # levelData2 = "X-16,Z-64,x-4-5,z-4-5"
    # levelDuration = 128 + 128 + 16 + 40 + 128
    level_data = []
    level_data2 = []
    level_duration = 0
    last_event_time = INITIAL_DELAY
    symbol = ""

    for event in events:
        level_duration = max(level_duration, event.time)
        symbol = event.type + '-' + str(event.time - last_event_time)

        if event.firstLevelData:
            level_data.append(symbol)
        else:
            level_data2.append(symbol)

        last_event_time = event.time

    return f"\nlevelData = \"{','.join(level_data)}\"\nlevelData2 = \"{','.join(level_data2)}\"\nlevelDuration = {level_duration}"


if __name__ == '__main__':
    input_file = 'chippi.osu'
    osu_events = extract_events_from_osu(input_file)
    print(event_to_lua_pony_code(osu_events))
