using Mmap

FILE_NAME = "/gome/simon/Documents/Uni/cam/thesis/traces/e2_bat_fb_beta_raw_s_0_3071.raw"

"""
The following structure is used:
- nr_trials: The total number of traces collected
- nr_groups: Each nr_groups (here: 256) times, all possible inputs occur exactly once.
- nr_bytes: How many input bytes were used. This is later on scaled down to 1, but there may be additional zero bytes.
- nr_points: How many points does each trace have.

This loads two matrices in the global scope:
- B: A `nr_bytes * nr_trials` matrix, containing for each trial the input vector used (in the columns)
- X: A `nr_points * nr_trials` matrix, containing for each trial the recorded trace (in the columns)
"""

struct TLAttackMetadata
    nr_trials::Int
    nr_groups::Int
    nr_bytes::Int
    nr_points::Int
end

io = open(FILE_NAME);

bytesstart = position(io)

fs = Array{UInt8}(undef, (1))
read!(io, fs)

metadata_format = Array{UInt8}(undef, 7)
read!(io, metadata_format)
metadata_format = String(metadata_format)

@assert metadata_format == "rawe2\0\0"

metadata_nr_trials = read(io, UInt64);
metadata_nr_groups = read(io, UInt64);
metadata_nr_points = read(io, UInt64);

read(io, UInt8);
metadata_xfmt = Array{UInt8}(undef, 7)
read!(io, metadata_xfmt)
metadata_xfmt = Base.rstrip(String(metadata_xfmt), '\0')

metadata_samplingrate = read(io, Float64);
metadata_fclock = read(io, Float64);
metadata_tscale = read(io, Float64);
metadata_toffset = read(io, Float64);
metadata_vscale = read(io, Float64);
metadata_voffset = read(io, Float64);
metadata_rvalue = read(io, Float64);
metadata_dccoupling = read(io, Int64);
metadata_nr_bytes = read(io, UInt64);

read(io, UInt8)
metadata_bfmt = Array{UInt8}(undef, 7)
read!(io, metadata_bfmt)
metadata_bfmt = Base.rstrip(String(metadata_bfmt), '\0')

metadata_address = read(io, UInt64);
metadata_rifmt = Array{UInt8}(undef, 7)
read(io, UInt8)
read!(io, metadata_rifmt)
metadata_rifmt = Base.rstrip(String(metadata_rifmt), '\0')

@assert metadata_rifmt == "uint8"
ribs = 1 #  ribs = get_bytes_class(metadata.rifmt);
metadata_ridxoffset = 136;
metadata_xoffset = metadata_nr_bytes*ribs; # Changed (remove metadata_ridxoffset + ...)

@assert metadata_xfmt == "int16"
xbs = 2 #    xbs = get_bytes_class(metadata.xfmt);
metadata_boffset = metadata_xoffset + metadata_nr_trials*metadata_nr_points*xbs;

@assert metadata_bfmt == "uint8"
rbs = 1 #    rbs = get_bytes_class(metadata.bfmt);
metadata_roffset = metadata_boffset + metadata_nr_trials*metadata_nr_bytes*rbs;

@assert position(io) == metadata_ridxoffset

# metadata.rifmt, [metadata.nr_bytes, 1],'rindex';
# metadata.xfmt, [metadata.nr_points, metadata.nr_trials],'X';
# metadata.bfmt, [metadata.nr_bytes, metadata.nr_trials], 'B';
# metadata.bfmt, [metadata.nr_bytes, metadata.nr_trials], 'R'});

rindex = Mmap.mmap(io, Vector{UInt8}, (metadata_nr_bytes))
skip(io, sizeof(rindex))

X = Mmap.mmap(io, Matrix{Int16}, (metadata_nr_points, metadata_nr_trials))
skip(io, sizeof(X))

B = Mmap.mmap(io, Matrix{UInt8}, (metadata_nr_bytes, metadata_nr_trials))
skip(io, sizeof(B))

R = Mmap.mmap(io, Matrix{UInt8}, (metadata_nr_bytes, metadata_nr_trials))
skip(io, sizeof(R))

@assert eof(io)

metadata = TLAttackMetadata(metadata_nr_trials, metadata_nr_groups, metadata_nr_bytes, metadata_nr_points)
