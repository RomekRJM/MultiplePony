def read_perf(input_file):
    data = {}
    no_frames = 0

    with open(input_file, 'r') as f:
        for l in f.readlines():
            function, f1, s1, s2 = l.split(',')
            frame = int(f1)
            stat_1 = float(s1)
            stat_2 = float(s2)

            if function in data:
                data[function].append((frame, stat_1, stat_2))
            else:
                data[function] = [(frame, stat_1, stat_2)]

            no_frames = max(frame, no_frames)

    return data, no_frames


def rewrite_perf(output_file, data, no_frames, stat_no):
    with open(output_file, 'w') as f:
        header = ','.join(data.keys())
        f.write(f"frame,{header}\n")

        for frame in range(no_frames):
            line = str(frame)

            for function in data.keys():
                if len(data[function]) <= frame:
                    line += ',0'
                else:
                    line += ',' + str(data[function][frame][stat_no])

            line += '\n'
            f.write(line)


if __name__ == '__main__':
    d, nf = read_perf('perf.csv')
    rewrite_perf('perf.s1.csv', d, nf, 1)
    rewrite_perf('perf.s2.csv', d, nf, 2)
